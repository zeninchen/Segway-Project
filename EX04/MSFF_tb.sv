module MSFF_tb;

    logic clk;
    logic d;
    logic q;

    // Instantiate the DUT
    MSFF dut (
        .clk(clk),
        .d(d),
        .q(q)
    );

    // Clock generation: 10 time unit period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus and check
    initial begin
        d = 0;
        // Wait for 5 clock cycles
        repeat (5) @(posedge clk);

        // Change d to high at clock cycle 5
        d = 1;
        @(posedge clk);

        // Set d back to low
        d = 0;
        // Wait for 5 more clock cycles (total 10)
        repeat (4) @(posedge clk);

        // Change d to high at clock cycle 10
        d = 1;
        @(posedge clk); // Wait for next clock edge

        // Check if q follows d
        if (q == d) begin
            $display("YAHOO! q equals d after d changes to high at 10th clock cycle!");
        end else begin
            $display("q did NOT follow d after 10 clock cycles.");
        end

        #20;
        $stop;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t | clk=%b | d=%b | q=%b", $time, clk, d, q);
    end

endmodule