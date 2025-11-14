module balance_cntrl(
    input logic [15:0] ptch,
    //Signed 16-bit pitch rate frominertial_interface. Used for D_term
    input logic [15:0] ptch_rt,
    //18-bit integrator accumulation register
    //input logic [17:0] integrator,
    //add clk and rst_n 
    input logic clk,
    input logic rst_n,
    //a vld input that will indicate when a new inertial sensor reading
    //is valid
    input logic vld,
    //two new single bit inputs called pwr_up & rider_off
    input logic pwr_up,
    input logic rider_off,
    input logic [11:0] steer_pot,
    input logic en_steer,
    output logic signed [11:0] lft_spd,
    output logic signed [11:0] rght_spd,
    output logic too_fast
);
    //instantiate PID module
    logic [11:0] PID_cntrl;
    logic [7:0] ss_tmr;
    PID #(1) PID_inst(
        .ptch(ptch),
        .ptch_rt(ptch_rt),
        .clk(clk),
        .rst_n(rst_n),
        .vld(vld),
        .pwr_up(pwr_up),
        .rider_off(rider_off),
        .PID_cntrl(PID_cntrl),
        .ss_tmr(ss_tmr)
    );
    
    //instantiate SegwayMath module
    
    SegwayMath segway_math_inst(
        .PID_cntrl(PID_cntrl),
        .ss_tmr(ss_tmr),
        .steer_pot(steer_pot),
        .en_steer(en_steer),
        .pwr_up(pwr_up),
        .lft_spd(lft_spd),
        .rght_spd(rght_spd),
        .too_fast(too_fast)
    );

endmodule