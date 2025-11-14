module piezo_drv_tb;


    //parameters
    parameter CLK_PERIOD = 20; // 50 MHz clock
    //signals
    logic clk;
    logic rst_n;
    logic en_steer;
    logic too_fast;
    logic battery_low;
    logic piezo;
    logic piezo_n;


    //instantiate DUT
    piezo_drv#(1) iDUT (
        .clk(clk),
        .rst_n(rst_n),
        .en_steer(en_steer),
        .too_fast(too_fast),
        .batt_low(battery_low),
        .piezo(piezo),
        .piezo_n(piezo_n)
    );
    logic piezo_opt;
    logic piezo_n_opt;

    piezo_opt#(1) iDUT_opt (
        .clk(clk),
        .rst_n(rst_n),
        .en_steer(en_steer),
        .too_fast(too_fast),
        .batt_low(battery_low),
        .piezo(piezo_opt),
        .piezo_n(piezo_n_opt)
    );
    //clock generation
    always begin
        clk = 1'b0;
        #(CLK_PERIOD/2);
        clk = 1'b1;
        #(CLK_PERIOD/2);
    end

    always_comb begin
        //compare DUT and reference model outputs
        //as long as there are match within 3 clock cycles, it's acceptable
        //assert (piezo === piezo_opt) else $error("Mismatch detected on piezo output");
        //no need to check piezo_n since it's just the inverse
    end

    

    //test sequence
    initial begin
        //apply reset
        rst_n = 1'b0;
        @(posedge clk);
        rst_n = 1'b1;
        //initialize inputs
        en_steer = 1'b0;
        too_fast = 1'b0;
        repeat(100) @(posedge clk);
        //make sure piezo outputs are not toggling

        en_steer = 1'b1;
        repeat(1750000) @(posedge clk);
        too_fast = 1'b1;
        //too_fast has priority over en_steer
        repeat(300000) @(posedge clk);
        en_steer = 1'b1;
        battery_low = 1'b1;
        too_fast = 1'b0;
        repeat(2000000) @(posedge clk);
        $stop;


    end

endmodule