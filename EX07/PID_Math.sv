module PID_Math (
    //Signed 16-bit pitch signal frominertial_interface
    input logic [15:0] ptch,
    //Signed 16-bit pitch rate frominertial_interface. Used for D_term
    input logic [15:0] ptch_rt,
    //18-bit integrator accumulation register
    input logic [17:0] integrator,
    //12-bit signed result of PID control
    output logic [11:0] PID_cntrl
);
    logic is_negative;
    logic contain1, contain0;
    logic signed [9:0] ptch_err_sat;
    logic signed [14:0] P_term;
    logic signed [14:0] I_term;
    logic signed [12:0] D_term;
    logic signed [15:0] P_extend;
    logic signed [15:0] I_extend;
    logic signed [15:0] D_extend;
    /*P_COEFF = signed 5’h09*/
    localparam signed P_COFF = 5'h09;
    assign is_negative = ptch[15];
    //if the input is negative, we need to check if the bit [14:10] contains any 0s
    //if it is, we set the output to maximum negative value -256
    //if the input is positive, we need to check if the bit [14:10] contains any 1s
    //if it is, we set the output to maximum positive value 255
    //otherwise, we set the output to the input value
    //contain0 is true if there is at least one 0 in the range [14:10]
    //contain1 is true if there is at least one 1 in the range [14:10]
    assign contain1=|ptch[14:9];
    assign contain0=~(&ptch[14:9]);
    assign ptch_err_sat = (is_negative) ? (contain0 ? 10'h200 : ptch[9:0]) : (contain1 ? 10'h1FF : ptch[9:0]);

    //P_term = P_COFF * ptch_err_sat
    assign P_term = ptch_err_sat*P_COFF ;

    /*I_term will be a 15-bit signed quantity and is simply integrator/64. One might question why I_term needs to be 15-bits. An 18-bit value divided by 64 should be able to fit in a 12-bit value. This is true, but later we will see we
have to modify some of the math to speed up simulations. For this reason we
will keep I_term at 15-bits.*/
    assign I_term={{3{integrator[17]}},integrator[17:6]};

    //D_term = -(ptch_rt/64)
    assign D_term = -{{3{ptch_rt[15]}},ptch_rt[15:6]};

    //PID_cntrl = P_term + I_term + D_term
    //sign extend each term to 16-bits before adding
    assign P_extend = { {1{P_term[14]}}, P_term};
    assign I_extend = { {1{I_term[14]}}, I_term};
    assign D_extend = { {3{D_term[12]}}, D_term};
    //add the three extended terms together and assign the lower 12-bits to PID_cn
    //and saturate to 12-bits signed
    logic signed [15:0] PID_sum;
    assign PID_sum = P_extend + I_extend + D_extend;
    //assign PID_cntrl = (PID_sum[15])? (~(&PID_sum[15:11]) ? -12'sh0800 : PID_sum[11:0]) : (|PID_sum[15:12] ? 12'sh07FF : PID_sum[11:0]);
    //more concise way to write the same saturation logic
    assign PID_cntrl = (PID_sum > 16'sh07FF) ? 12'sh07FF : (PID_sum < -16'sh0800) ? -12'sh0800 : PID_sum[11:0];
    
endmodule