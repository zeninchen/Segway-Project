module counter (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    input  logic        up_dwn_n,
    output logic [3:0]  cnt
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cnt <= 4'd0;
        else if (en) begin
            if (up_dwn_n)
                cnt <= cnt + 1;
            else
                cnt <= cnt - 1;
        end
    end

endmodule
