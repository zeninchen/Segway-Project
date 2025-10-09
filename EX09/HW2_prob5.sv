//the correct code for first module
//the orginial module is incorrect, it ignore the change in D, and the latch will change 
//the q through out the clk high period, the orginial, doesn't account for the change in D, 
//when the clock is high 
//the always should detect the change in D as well, and change the output when the Q is high
module latch(d,clk,q);
    input d, clk;
    output reg q;
    always @(clk,d)
        if (clk)
            q <= d;
endmodule

//active high synchronous reset d flip flop
module dff_hs(d,clk,q,r);
    input d, clk,r;
    output reg q;
    always_ff @(posedge clk) begin
        if (r)
            q <= 1'b0;
        else
            q <= d;
    end
endmodule

//a D-FF with asynchronous active lowreset and an active high enable.
module dff_la(d,clk,q,r,en);
    input d, clk,r,en;
    output reg q;
    always_ff @(posedge clk, negedge r) begin
        if (!r)
            q <= 1'b0;
        else if (en)
            q <= d;
    end
endmodule

//with active high synchronous reset, and an active high synchronous set.
module dff_hs_s(d,clk,q,r,s);
    input d, clk,r,s;
    output reg q;
    always_ff @(posedge clk) begin
        if (r)
            q <= 1'b0;
        else if (s)
            q <= 1'b1;
        else
            q <= d;
    end
endmodule
//Q5, yes, during sysnethesis,  always_ff will let system verilog know that it should act like flip flop 
