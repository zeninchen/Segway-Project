module SegwayMath(
    //Signed 12-bit control from PID that dictates frwrd/rev drive of motors to maintain platform balance
    input logic signed [11:0] PID_cntrl,
    //Unsigned 8-bit scaling quantity used to provide a soft-start to control loop. PID_cntrl is scaled by this timer that ramps up slowly from power on
    input logic [7:0] ss_tmr,
    /*12-bit unsigned measure of steering potentiometer.
    Comes from
    A2D_intf. Limited and converted to
    signed version internal to
    Segway_math*/
    input logic [11:0] steer_pot,
    //Indicates steering has been enabled. Enabled by rider having equal weight distribution on load cells.
    input logic en_steer,
    //If ~pwr_up then both lft_spd & rght_spd are forced to zero
    input logic pwr_up,
    //Desired output speed/torque for each of left/right motors. 12-bit signed quantity
    output logic signed [11:0] lft_spd,
    output logic signed [11:0] rght_spd,
    //If either lft_spd or right_spd exceed 12’d1792 then this signal is asserted. Used to warn rider of approaching control limits.output logic warn_limit
    output logic too_fast
);
    logic signed [11:0] PID_ss;
    logic signed [19:0] PID_cntrl_ext;
    /*PID_cntrl is signed, and the multiply should be signed. Zero extend ss_tmr
    to form a 9-bit quantity that is multiplied by PID_cntrl to form a 20-bit
product. You must still cast the zero extended ss_tmr to signed to infer a
signed multiply ( $signed({1’b0,ss_tmr}) should be multiplied by PID_cntrl )
20 Steering control is added in next*/
    assign PID_cntrl_ext = PID_cntrl * $signed({1'b0,ss_tmr}); //multiply to form a 20-bit signed result
    assign PID_ss = PID_cntrl_ext >>> 8; //divide by 256 to form a 12-bit signed result
    logic signed [11:0] steer_signed;
    logic [12:0] lft_torque, rght_torque;
    logic signed [12:0] lft_shaped, rght_shaped;
    //steering_logic module to compute left/right torques, do the connect by name
    steering_logic steer_inst(
        .steer_pot(steer_pot),
        .en_steer(en_steer),
        .PID_ss(PID_ss),
        .lft_torque(lft_torque),
        .rght_torque(rght_torque)
    );
    
    //we use the deadzone_shaping module to do the deadzone shaping for the left side
    deadzone_shaping deadzone_left(
        .lft_torque(lft_torque),
        .pwr_up(pwr_up),
        .lft_shaped(lft_shaped)
    );

    //we use the deadzone_shaping module to do the deadzone shaping for the right side
    deadzone_shaping deadzone_right(
        .lft_torque(rght_torque),
        .pwr_up(pwr_up),
        .lft_shaped(rght_shaped)
    );

    //we saturate the lft_shaped & rght_shaped to be 12-bit signed values
    //we assign the saturated value to lft_spd & rght_spd
    saturate_12bit_signed saturate_left(
        .in(lft_shaped),
        .out(lft_spd)
    );
    saturate_12bit_signed saturate_right(
        .in(rght_shaped),
        .out(rght_spd)
    );

    //if either lft_spd or right_spd exceed 12’d1792 then too_fast signal is true. Used to warn rider of approaching control limits.
    //otherwise, the signal is false
    assign too_fast = (lft_spd > 12'sd1536 || rght_spd > 12'sd1536);
endmodule



module steering_logic(
    input logic [11:0] steer_pot,
    input logic en_steer,
    input logic signed [11:0] PID_ss,
    output logic  [12:0] lft_torque,
    output logic  [12:0] rght_torque
);
    //saturate or reduce the 12-bit unsigned steer_pot to between 0x200 & 0xE00(unsigned)
    logic [11:0] steer_limited;
    assign steer_limited = (steer_pot < 12'h200) ? 12'h200 : (steer_pot > 12'hE00) ? 12'hE00 : steer_pot;
    //substract 12’h7ff from the limited value and times 3/16
    logic signed [11:0] steer_offset;
    logic signed [11:0] steer_difference;
    assign steer_difference = $signed(steer_limited) - 12'sh7FF;
    //times decimal value d3/d16
    assign steer_offset = (steer_difference *3)>>>4;

    //for the left torque, we add the steer_offset to PID_ss if en_steer is true
    //otherwise we just pass through PID_ss 
    //we sign extend both PID_ss & steer_offset to 13-bits before adding
    assign lft_torque = en_steer ? $signed({PID_ss[11],PID_ss}) + $signed({steer_offset[11],steer_offset}) : $signed({PID_ss[11],PID_ss});
    //for the right torque, we subtract the steer_offset from PID_ss if en_steer is true
    //otherwise we just pass through PID_ss
    //we sign extend both PID_ss & steer_offset to 13-bits before subtracting
    assign rght_torque = en_steer ? $signed({PID_ss[11],PID_ss}) - $signed({steer_offset[11],steer_offset}) : $signed({PID_ss[11],PID_ss});
endmodule


module saturate_12bit_signed(
    input logic signed [12:0] in,
    output logic signed [11:0] out
);
    //if the input is greater than 2047, we set the output to be 2047
    //if the input is less than -2048, we set the output to be -2048
    //otherwise we just pass through the lower 12-bits of the input
    logic gt;
    logic lt;
    //assign gt = in > 13'sd2047;
    //assign lt = in < -13'sd2048;
    assign gt = |in[12:11] ; //true if in>2047 //contain 1
    assign lt = ~(&in[12:11]); //true if in<-2048 //contain 0
    assign out = in[12] ?(lt?12'sd2047: in[11:0]) : (gt) ? -12'sd2048 : in[11:0];
endmodule



module deadzone_shaping(
    input logic signed [12:0] lft_torque,
    input logic pwr_up,
    output logic signed [12:0] lft_shaped
);
    /*localparams:
MIN_DUTY = 13’h0A8
LOW_TORQUE_BAND = 7’h2A
GAIN_MULT = 4’h4.
*/
    localparam signed [12:0] MIN_DUTY = 13'sh0A8;
    localparam signed [6:0] LOW_TORQUE_BAND = 7'sh2A;
    //don't make it signed, because we are going to use it to multiply with a signed number
    localparam [3:0] GAIN_MULT = 4'sh4;

    logic signed [12:0]lft_torque_comp;
    logic signed [12:0] lft_torque_gain;
    logic signed [12:0] lft_shaped_1;
    logic [12:0] abs_lft_torque;
    logic abs_t_c_grt_low_band;
    //if the absolute value of lft_torque is greater than LOW_TORQUE_B
    //lft_torque[12] bit is true, we assign lft_torque_comp to be addition of lft_torque and MIN_DUTY
    //otherwise we assigne them to be subtraction
    assign lft_torque_comp = lft_torque[12] ? lft_torque - MIN_DUTY : lft_torque + MIN_DUTY;
    //we times lft_torque by GAIN_MULT to form a (13-bit signed) lft_torque_gain
    //even though 13bit *4bit is 17bit, we only care about the upper 13-bits
    
    assign lft_torque_gain = lft_torque * $signed(GAIN_MULT);
    //if the absolute value of lft_torque is greater than LOW_TORQUE_BAND, we assign it to be lft_torque_comp
    //other wise we assign it to be lft_torque_comp times GAIN_MULT (using the abs module)
    //logic aboslute_value for both left and right
    
    abs abs_left(
        .in(lft_torque),
        .out(abs_lft_torque)
    );
    assign abs_t_c_grt_low_band = (abs_lft_torque > LOW_TORQUE_BAND);
    assign lft_shaped_1 = abs_t_c_grt_low_band ? lft_torque_comp : lft_torque_gain;

    //if pwr_up is false, we assign lft_shaped to be zero, otherwise we just pass lft_shaped_1 through
    assign lft_shaped = pwr_up ? lft_shaped_1 : 13'sd0;

endmodule



module abs(
    input logic signed [12:0] in,
    output logic [12:0] out
);
    assign out = (in[12]) ? -in : in;
endmodule