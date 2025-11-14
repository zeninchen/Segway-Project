module PID (
    //Signed 16-bit pitch signal frominertial_interface
    input logic signed [15:0] ptch,
    //Signed 16-bit pitch rate frominertial_interface. Used for D_term
    input logic signed [15:0] ptch_rt,
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
    //12-bit signed result of PID control
    output logic signed [11:0] PID_cntrl,
    //add ss_tmr as an output which will be the upper bits of a timer
    //used to effect a soft start
    output logic [7:0] ss_tmr
);
    //add a parameter for fast_sim mode
    parameter fast_sim = 0;
    logic is_negative;
    logic contain1, contain0;
    logic signed [9:0] ptch_err_sat;
    logic [17:0] integrator; //integrator register
    logic signed [14:0] P_term;
    logic signed [14:0] I_term;
    logic signed [12:0] D_term;
    logic signed [15:0] P_extend;
    logic signed [15:0] I_extend;
    logic signed [15:0] D_extend;
    /*P_COEFF = signed 5’h09*/
    localparam P_COFF = 5'h09;
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
    //cast P_COFF to signed before multiplying
    assign P_term = ptch_err_sat* $signed(P_COFF);

    //integrator logic
    logic ov; //overflow flag for integrator
    logic signed [17:0] integrator_plus_ptch;
    logic signed [17:0] ptch_err_ext;
    logic mux1_en;
    logic [17:0] mux1_out;
    logic [17:0] mux2_out;

    //sign extend ptch_err_sat to 18-bits
    assign ptch_err_ext = { {8{ptch_err_sat[9]}}, ptch_err_sat};
    //integrator + ptch_err_sat
    assign integrator_plus_ptch = integrator + ptch_err_ext;
    
    //overflow detection logic
    assign ov = (integrator[17] == ptch_err_ext[17]) && (integrator_plus_ptch[17] != integrator[17]);
    //mux1, if enabled, out is integrator plus error pitch, else out is integrator
    assign mux1_en = ~ov&&vld;//mux i enabled when no overflow and vld is high
    assign mux1_out = mux1_en ? integrator_plus_ptch : integrator;

    //mux2, if rider_off is high, out is 0, else out is mux1_out
    assign mux2_out = rider_off ? 18'sh00000 : mux1_out;

    //integrator register
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            integrator <= 18'sh00000;
        else//just propagate the value from mux2 to integrator
            integrator <= mux2_out;
    end
    /*I_term will be a 15-bit signed quantity and is simply integrator/64. One might question why I_term needs to be 15-bits. An 18-bit value divided by 64 should be able to fit in a 12-bit value. This is true, but later we will see we
have to modify some of the math to speed up simulations. For this reason we
will keep I_term at 15-bits.*/
    generate 
        if(fast_sim==1)
            //see if saturation is needed for [15:1] bits
            //the I term is signed and if any of the bits [17:15] are not all 0s or all 1s, we have to saturate
            assign I_term = (integrator[17])? (~(&integrator[17:15]) ? 15'h4000 : integrator[15:1]) : (|integrator[17:15] ? 15'h3FFF : integrator[15:1]);

            
        else
            assign I_term={{3{integrator[17]}},integrator[17:6]};
    endgenerate
    

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
    assign PID_cntrl = (PID_sum[15])? (~(&PID_sum[15:11]) ? -12'sd2048 : PID_sum[11:0]) : 
                        (|PID_sum[15:11] ? 12'sd2047 : PID_sum[11:0]);
    //more concise way to write the same saturation logic
    //assign PID_cntrl = (PID_sum > 16'sh07FF) ? 12'sh7FF : (PID_sum < -16'sh0800) ? -12'sh800 : PID_sum[11:0];
    
    //soft start timer logic
    logic [26:0] cnt; //27-bit counter to count to 50 million
    logic mux1_en_ss;
    logic [26:0] mux1_out_ss;
    logic [26:0] mux2_out_ss;
    //It is a one shot timer. Once it starts counting and gets near full (bits [26:19]
    //set) it freezes.
    assign ss_tmr = cnt[26:19]; //upper 8 bits of the counter
    assign mux1_en_ss = &ss_tmr; //if all bits of ss_tmr are 1, freeze the counter
    generate
        if(fast_sim==1) begin
        //increase by 256 each clock cycle for fast sim

            assign mux1_out_ss = mux1_en_ss ? cnt : cnt + 9'd256;
        end
        else begin
            assign mux1_out_ss = mux1_en_ss ? cnt : cnt + 1'b1;
            
        end
    endgenerate
    
    //if pwr_up is high, load  mux1_out else load 0
    assign mux2_out_ss = pwr_up ?  mux1_out_ss : 27'b0;

    //counter register
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            cnt <= 27'b0;
        else
            cnt <= mux2_out_ss;
    end
endmodule
