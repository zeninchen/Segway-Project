`timescale 1ns/1ps

module saturate_tb;

    // Inputs
    reg [15:0] unsigned_err;
    reg [15:0] signed_err;
    reg [9:0] signed_D_diff;

    // Outputs
    wire [9:0] unsigned_err_sat;
    wire [9:0] signed_err_sat;
    wire [6:0] signed_D_diff_sat;

    // Instantiate the Unit Under Test (UUT)
    saturate uut (
        .unsigned_err(unsigned_err),
        .signed_err(signed_err),
        .signed_D_diff(signed_D_diff),
        .unsigned_err_sat(unsigned_err_sat),
        .signed_err_sat(signed_err_sat),
        .signed_D_diff_sat(signed_D_diff_sat)
    );

    // Task to check outputs
    task check_output;
        input [9:0] expected_unsigned_err_sat;
        input [9:0] expected_signed_err_sat;
        input [6:0] expected_signed_D_diff_sat;
        begin
            if (unsigned_err_sat !== expected_unsigned_err_sat ||
                signed_err_sat !== expected_signed_err_sat ||
                signed_D_diff_sat !== expected_signed_D_diff_sat) begin
                $display("Test failed for inputs: unsigned_err=%h, signed_err=%h, signed_D_diff=%h", unsigned_err, signed_err, signed_D_diff);
                $display("Expected: unsigned_err_sat=%h, signed_err_sat=%h, signed_D_diff_sat=%h", expected_unsigned_err_sat, expected_signed_err_sat, expected_signed_D_diff_sat);
                $display("Got: unsigned_err_sat=%h, signed_err_sat=%h, signed_D_diff_sat=%h", unsigned_err_sat, signed_err_sat, signed_D_diff_sat);
                $stop;
            end
        end
    endtask

    initial begin
        // Test cases
        // Unsigned error tests
        unsigned_err = 16'h3FFF; signed_err = 16'h0; signed_D_diff = 10'h0; #10;
        check_output(10'h3FF, 10'h0, 7'h0); // Max value for unsigned_err

        unsigned_err = 16'h03FF; signed_err = 16'h0; signed_D_diff = 10'h0; #10;
        check_output(10'h3FF, 10'h0, 7'h0); // Within range

        unsigned_err = 16'h0001; signed_err = 16'h0; signed_D_diff = 10'h0; #10;
        check_output(10'h001, 10'h0, 7'h0); // Small value

        // Signed error tests
        unsigned_err = 16'h0; signed_err = 16'h0400; signed_D_diff = 10'h0; #10;
        check_output(10'h0, 10'h1FF, 7'h0); // Max positive value

        unsigned_err = 16'h0; signed_err = -16'h0400; signed_D_diff = 10'h0; #10;
        check_output(10'h0, 10'h200, 7'h0); // Max negative value

        unsigned_err = 16'h0; signed_err = 16'h0001; signed_D_diff = 10'h0; #10;
        check_output(10'h0, 10'h001, 7'h0); // Small positive value

        // Signed D_diff tests
        unsigned_err = 16'h0; signed_err = 16'h0; signed_D_diff = 10'h080; #10;
        check_output(10'h0, 10'h0, 7'h3F); // Max positive value

        unsigned_err = 16'h0; signed_err = 16'h0; signed_D_diff = -10'h080; #10;
        check_output(10'h0, 10'h0, -7'h40); // Max negative value

        unsigned_err = 16'h0; signed_err = 16'h0; signed_D_diff = 10'h001; #10;
        check_output(10'h0, 10'h0, 7'h001); // Small positive value

        // If all tests pass
        $display("Yahoo! All test cases passed.");
        $stop;
    end

endmodule
