module PB_release(
    input logic PB,
    input logic clk,
    input logic rst_n,
    output logic released
);

    logic clk1_out;
    logic clk2_out;
    logic clk3_out;
    //these flops are asynch preset not reset

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            //preset all the clock
            clk1_out <= 1'b1;
            clk2_out <= 1'b1;
            clk3_out <= 1'b1;
        end
        else begin
            //propagate the value through the clock
            clk1_out <= PB;
            clk2_out <= clk1_out;
            clk3_out <= clk2_out;
        end
    end

    //released is high when clk2_out is high and clk3_out is low
    assign released = clk2_out & ~clk3_out;



endmodule