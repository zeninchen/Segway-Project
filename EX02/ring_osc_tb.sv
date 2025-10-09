module ring_osc (
    input wire EN,
    output wire OUT
);

    // Internal wires
    wire and_out, not1_out;

    nand #5 (and_out,EN,OUT);
    not #5 (not1_out,and_out);
    not #5 (OUT, not1_out);
   
    // Final output

endmodule

module ring_osc_tb;

    // Declare signals for DUT ports
    logic EN;
    logic OUT;
    bit test_passed = 0; // Flag for test pass

    // Instantiate the DUT
    ring_osc dut (
        .EN(EN),
        .OUT(OUT)
    );

// Oscillate EN: 30 time unit period, 15 high, 15 low
    initial begin
        EN = 0;
        forever begin
            #15 EN = ~EN;
        end
    end

    // Stimulus and output check
    initial begin
        $monitor("Time=%0t | EN=%b | OUT=%b", $time, EN, OUT);

        // Check for output during simulation
        repeat (100) begin
            #5;
            if (OUT && !test_passed) begin
                test_passed = 1;
                $display("YAHOO! Test Passed!");
            end
        end

    

        $finish;
    end

endmodule