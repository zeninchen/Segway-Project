
/*
FOUR HOT STATE MACHINE
*/






module inertial_integrator(
    input logic clk,
    input logic rst_n,
    input logic vld,
    input logic [15:0] ptch_rt,
    input logic [15:0] AZ,
    output logic signed [15:0] ptch
);


    //internal signals
    logic [26:0] ptch_int;
    logic [15:0] ptch_rt_comp;
    logic  signed [15:0] AZ_comp;
    localparam AZ_OFFSET=16'h00A0;
    localparam PTCH_RT_OFFSET=16'h0050;
    assign ptch_rt_comp = ptch_rt - PTCH_RT_OFFSET;
    assign AZ_comp = AZ - AZ_OFFSET;
    

    logic signed [25:0] ptch_acc_product;
    logic signed [15:0] ptch_acc;
    //the trignometric constant multiplication
    assign ptch_acc_product = AZ_comp * $signed(327);
    // pitch angle calculated
    // from accel only
    assign ptch_acc = {{3{ptch_acc_product[25]}},ptch_acc_product[25:13]};
    logic signed [26:0] fusion_ptch_offset;
    //select fusion offset based on comparison of ptch from accel and integrator
    assign fusion_ptch_offset = (ptch_acc>ptch) ? 1024 : -1024;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            ptch_int <= 27'h0000000;
        else if(vld) 
            //the integrator including fusion correction
            ptch_int <= ptch_int - {{11{ptch_rt_comp[15]}},ptch_rt_comp} + fusion_ptch_offset;        
    end
    assign ptch = ptch_int[26:11];
endmodule

