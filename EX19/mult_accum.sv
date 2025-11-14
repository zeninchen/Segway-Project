module mult_accum(clk,clr,en,A,B,accum);

input clk,clr,en;
input [15:0] A,B;
output reg [63:0] accum;

reg [31:0] prod_reg;
reg en_stg2;
reg en_latch;
reg en_stg2_latch;
wire prob_clock;
wire accum_clock;
///////////////////////////////////////////
// Generate and flop product if enabled //
/////////////////////////////////////////
assign prob_clock = clk & en_latch;
always_ff @(posedge prob_clock)    
    prod_reg <= A*B;

/////////////////////////////////////////////////////
// Pipeline the enable signal to accumulate stage //
///////////////////////////////////////////////////

always_ff @(posedge clk)
    en_stg2 <= en;


///////////////////////////////////////////
assign accum_clock = clk & en_stg2_latch  ;
always_ff @(posedge accum_clock)
    if (clr)
      accum <= 64'h0000000000000000;
    else 
      accum <= accum + prod_reg;

//latch for gated clocks 
//for prod_reg
always_latch begin
    if (!clk) en_latch <= en;
end

  
end
//for accum
always_latch begin
    if (!clk) en_stg2_latch <= en_stg2 | clr;
end

    

endmodule
