module rst_synch(
    input logic RST_n,
    input logic clk,
    output logic rst_n
);
    /*It will have an interface of:
RST_n = raw input from push button
clk = clock, and we use negative edge
rst_n = our syncrhronized output which will
form the global reset to the rest of our chip.*/
    logic inter_val;
    always_ff @(negedge clk or negedge RST_n) begin
        //asych reset both flops
        if (!RST_n)begin
            inter_val <= 1'b0;
            rst_n <= 1'b0;
        end
        else begin
            //propagate the values
            inter_val <= 1'b1;
            rst_n <= inter_val;
        end
    end
    
endmodule