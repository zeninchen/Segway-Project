module A2D_tb;
    logic clk;
    logic rst_n;
    logic nxt;
    logic [11:0]lft_ld;
    logic [11:0]rgt_ld;
    logic [11:0]steer_pot;
    logic [11:0]batt;
    logic a2d_SS_n;
    logic SCLK;
    logic MOSI;
    logic MISO;


    //clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        
        //wait for a few updates
        repeat(12)begin
            @(posedge clk);
            nxt = 1;
            @(posedge clk);
            nxt = 0;
            
            @(posedge iDUT.update);
            @(posedge clk);          
        end
        repeat(10)@(posedge clk);
        $stop;
    end



    //instance of iDUT
    A2D_intf iDUT(
        .clk(clk),
        .rst_n(rst_n),
        .nxt(nxt),
        .lft_ld(lft_ld),
        .rght_ld(rgt_ld),
        .steer_pot(steer_pot),
        .batt(batt),
        .SS_n(a2d_SS_n),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO)
    );
    //instance of ADC interface
    ADC128S ADC_inst(
        .clk(clk),
        .rst_n(rst_n),
        .SS_n(a2d_SS_n),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO)
    );
endmodule