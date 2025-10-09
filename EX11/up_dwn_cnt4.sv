module up_dwn_cnt4(
    input logic en,
    input logic clk,
    input logic rst_n,
    input logic dwn,
    output logic [3:0] cnt
);
    //if dwn is high, count down, else count up
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            cnt <= 4'b0;
        else if(en) begin
            if(dwn) begin
                if(cnt == 4'b0)
                    cnt <= 4'b1111;
                else
                    cnt <= cnt - 1'b1;
            end
            else begin
                if(cnt == 4'b1111)
                    cnt <= 4'b0;
                else
                    cnt <= cnt + 1'b1;
            end
        end
    end


endmodule