/*generate a testbench for the module arith.sv
The stimulus you apply should test both addition and subtraction
The stimulus you apply should test for overflow conditions.*/
module arith_tb();
    reg [7:0] A,B;		// two 8-bit quantities to be addes/subtracted
    reg SUB;				// if high operation is A - B, otherwise A + B
    wire [7:0] SUM;		// result of arithmetic operation
    wire OV;				// overflow if operands are interpretted as signed.
    //////// Instantiate DUT /////////
    arith iDUT(.A(A),.B(B),.SUB(SUB),.SUM(SUM),.OV(OV));
    initial begin
        $display("Time\tSUB\tA\tB\tSUM\tOV");
        $monitor("%0t\t%b\t%0d\t%0d\t%0d\t%b", $time, SUB, A, B, SUM, OV);
    end

    // Helper task to check results
    task check_case;
        input [7:0] exp_sum;
        input exp_ov;
        input [7:0] test_A, test_B;
        input test_SUB;
        begin
            if (SUM !== exp_sum || OV !== exp_ov) begin
                $display("ERROR: Test failed for A=%0d, B=%0d, SUB=%b. Got SUM=%0d, OV=%b. Expected SUM=%0d, OV=%b", 
                    test_A, test_B, test_SUB, SUM, OV, exp_sum, exp_ov);
                $stop;
            end
        end
    endtask

    // Stimulus block
    initial begin
        // Addition, no overflow: 10 + 20 = 30, OV=0
        A = 8'd10; B = 8'd20; SUB = 0; #10;
        check_case(8'd30, 1'b0, A, B, SUB);

        // Addition, overflow: 127 + 1 = -128, OV=1
        A = 8'd127; B = 8'd1; SUB = 0; #10;
        check_case(8'd128, 1'b1, A, B, SUB);

        // Subtraction, no overflow: 50 - 20 = 30, OV=0
        A = 8'd50; B = 8'd20; SUB = 1; #10;
        check_case(8'd30, 1'b0, A, B, SUB);

        // Subtraction, overflow: -128 - 1 = 127, OV=1
        A = 8'd128; B = 8'd1; SUB = 1; #10;
        check_case(8'd127, 1'b1, A, B, SUB);

        // Addition, negative numbers: -60 + -70 = -130 (wraps to 126), OV=1
        A = 8'd196; B = 8'd186; SUB = 0; #10; // 196 = -60, 186 = -70
        check_case(8'd126, 1'b1, A, B, SUB);

        // Subtraction, negative numbers: -128 - 1 = 127, OV=1
        A = 8'd128; B = 8'd1; SUB = 1; #10;
        check_case(8'd127, 1'b1, A, B, SUB);

        // Edge case: 0 + 0 = 0, OV=0
        A = 8'd0; B = 8'd0; SUB = 0; #10;
        check_case(8'd0, 1'b0, A, B, SUB);

        // Edge case: 0 - 0 = 0, OV=0
        A = 8'd0; B = 8'd0; SUB = 1; #10;
        check_case(8'd0, 1'b0, A, B, SUB);

        $display("yahoo");
        $stop;
    end

endmodule
    

