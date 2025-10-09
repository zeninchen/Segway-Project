module adder_tb;
/*Create a testbench that exhaustively tests all combinations of inputs.
The testbench should also instantiate or implement a behavioral implementation
of the adder to be used as the “golden reference”. The testbench should be self
checking and should error out and stop if there is a miscompare between the
“gold” model and your DUT. It should finish with a happy message if all goes
well.*/
    reg [3:0] A;       // First operand
    reg [3:0] B;       // Second operand
    reg       cin;       // Carry input
    wire [3:0] Sum;    // Sum output
    wire      co;      // Carry out
    integer i, j, k;   // Loop variables
    integer errors;    // Error counter
    reg [4:0] expected; // Expected result

    // Instantiate the adder module
    adder dut (
        .A(A),
        .B(B),
        .cin(cin),
        .Sum(Sum),
        . co(Co)
    );

    // Exhaustively test all combinations of A, B, and cin
    initial begin
        errors = 0; // Initialize error counter
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                for (k = 0; k < 2; k = k + 1) begin
                    A = i[3:0];
                    B = j[3:0];
                    cin = k[0];
                    #1; // Wait for outputs to stabilize
                    expected = A + B + cin; // Calculate expected result (Golden Reference)
                    if ({co, Sum} !== expected) begin
                        $display("Error: A=%b, B=%b, cin=%b => Expected Sum=%b, Co=%b but got Sum=%b, Co=%b", A, B, cin, expected[3:0], expected[4], Sum, Co);
                        errors = errors + 1;
                    end
                end
            end
        end
        if (errors == 0) begin
            $display("All tests passed!");
        end else begin
            $display("%d tests failed.", errors);
        end
        $stop; 
    end
endmodule