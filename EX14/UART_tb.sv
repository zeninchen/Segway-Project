module UART_tb;
       //instance of the DUT
    logic clk;
    logic rst_n;
    logic [7:0] tx_data;
    logic trmt;
    logic TX;
    logic tx_done;



    logic [9:0]tx_data_recieve; //signal to recieve the data from TX line
    UART_tx transmitter (
        .clk(clk),
        .rst_n(rst_n),
        .trmt(trmt),
        .tx_data(tx_data),
        .TX(TX),
        .tx_done(tx_done)
    );

    logic rdy;
    logic [7:0] rx_data;
    logic clr_rdy;

    UART_rx dut (
        .clk(clk),
        .rst_n(rst_n),
        .RX(TX),
        .clr_rdy(clr_rdy),
        .rx_data(rx_data),
        .rdy(rdy)
    );

     // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units clock period
    end

    initial begin
        //monitor the some tx_data and tx_done  and the UART_rx input and output
        $monitor("Time: %0t | tx_data: %h | tx_done: %b | RX: %b | rx_data: %h | rdy: %b | clr_rdy: %b", 
                 $time, tx_data, tx_done, TX, rx_data, rdy, clr_rdy);
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
        //assert clr_rdy low
        clr_rdy = 1'b0;
        @(posedge tx_done); //wait for tx_done to be asserted
        //check if the data recieved is correct
        if(rx_data == tx_data)
            $display("Test 1 Passed: Data recieved correctly: %h", rx_data);
        else begin
            $display("Test 1 Failed: Data recieved incorrectly: %h", rx_data);
            $stop();
        end
        repeat(5208) @(posedge clk);
        //assert clr_rdy high to check if rdy goes low
        clr_rdy = 1'b1;
        repeat(5208) @(posedge clk);



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
        //assert clr_rdy low
        clr_rdy = 1'b0;

        //repeat for 5208*10 clock cycles to transmit the whole byte
        repeat(52080) @(posedge clk);
        
        @(posedge tx_done);
        //check if the data recieved is correct
        if(rx_data == tx_data)
            $display("Test 2 Passed: Data recieved correctly: %h", rx_data);
        else begin 
            $display("Test 2 Failed: Data recieved incorrectly: %h", rx_data);
            $stop();
        end
        //try immediately reading trasmit a new data without resetting
        @(posedge clk);
        tx_data = 8'hB5;
        trmt = 1'b1;
        @(posedge clk);
        trmt = 1'b0;
        //repeat for 5208*10 clock cycles to transmit the whole byte
        repeat(52080) @(posedge clk);
        //assert clr_rdy high to check if rdy goes low
        @(posedge tx_done);
        if(rx_data == tx_data)
            $display("Test 3 Passed: Data recieved correctly: %h", rx_data);
        else begin
            $display("Test 3 Failed: Data recieved incorrectly: %h", rx_data);
            $stop();
        end

        #200; //wait for some time
        $stop;
    end 
endmodule