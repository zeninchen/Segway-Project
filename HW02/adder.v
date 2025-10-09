module adder(
    input  [3:0] A,
    input  [3:0] B,
    input  cin,
    output [3:0] Sum,
    output co
);
    //wire cout_sum;
    assign {co, Sum} = A + B + cin;
endmodule



