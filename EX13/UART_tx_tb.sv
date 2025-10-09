module UART_tx_tb;
    //instance of the DUT
    logic clk;
    logic rst_n;
    logic [7:0] tx_data;
    logic trmt;
    logic TX;
    logic tx_done;

    logic [9:0]tx_data_recieve; //signal to recieve the data from TX line
    UART_tx dut (
        .clk(clk),
        .rst_n(rst_n),
        .trmt(trmt),
        .tx_data(tx_data),
        .TX(TX),
        .tx_done(tx_done)
    );

     // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units clock period
    end

    initial begin
        //monitor the signals
        $monitor("Time: %0t | rst_n: %b | trmt: %b | tx_data: %h | TX: %b | tx_done: %b", 
                 $time, rst_n, trmt, tx_data, TX, tx_done);
        // Initialize inputs
        rst_n = 0;
        tx_data = 8'hA5;
        trmt = 1'b0;
        // assert load data for 1 clock cycle
        #15;
        rst_n = 1;
        trmt = 1'b1;
        #10;
        trmt = 1'b0;

        //repeat for 5208*10 clock cycles to transmit the whole byte
        repeat(52080*2) @(posedge clk);


        //check some other input
        rst_n = 0;
        tx_data = 8'h3C;
        trmt = 1'b0;
        // assert load data for 1 clock cycle
        #15;
        rst_n = 1;
        trmt = 1'b1;
        #10;
        trmt = 1'b0;
        //repeat for 5208*10 clock cycles to transmit the whole byte
        repeat(52080) @(posedge clk);

        #200; //wait for some time
        $stop;
    end
        
endmodule