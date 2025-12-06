
module inertial_testbench;
    // Testbench code would go here
    
    localparam PTCH_RT_OFFSET=16'h0050;
    logic clk;
    logic rst_n;
    logic vld;
    logic [15:0] ptch_rt;
    logic [15:0] AZ;
    logic [15:0] ptch;

    //initiat e the DUT
    inertial_integrator dut (
        .clk(clk),
        .rst_n(rst_n),
        .vld(vld),
        .ptch_rt(ptch_rt),
        .AZ(AZ),
        .ptch(ptch)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units clock period
    end

    // Stimulus generation
    initial begin
        // Initialize signals
        rst_n = 0;
        vld = 0;
        ptch_rt = 16'h0000;
        AZ = 16'h00A0; // Set to offset value initially

        // Release reset
        @(posedge clk);
        rst_n = 1;

        // FIRST TEST CASE // SHOULD DRO{}
        ptch_rt = 16'h1000 + PTCH_RT_OFFSET; 
        AZ = 16'h0000;
        vld = 1;

        repeat (500) @(posedge clk);
        ptch_rt = PTCH_RT_OFFSET; // zero out



        repeat (1000) @(posedge clk);
        ptch_rt = PTCH_RT_OFFSET - 16'h1000; // negative pitch rate
        

        repeat (500) @(posedge clk);
        ptch_rt = PTCH_RT_OFFSET; // zero out


        repeat (1000) @(posedge clk);
        AZ = 16'h0800;
        // Add more test cases as needed

        // Finish simulation
        repeat (1000) @(posedge clk);
        $stop;
    end



endmodule 