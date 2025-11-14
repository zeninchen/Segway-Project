
module UART_rx (
    input logic clk,
    input logic rst_n,
    input logic RX,
    input logic clr_rdy,
    output logic [7:0] rx_data,
    output logic rdy
);
    
    //preset the rx, because idle is high, and start bit is low
    //double flop for metastability
    //we will only use RX_sync2 in the rest of the design
    logic RX_sync1, RX_sync2;
    logic shift;
    logic start;
    logic receiving;
    logic [3:0] bit_cnt; // when it hits 9 we are done
    logic [12:0] baud_cnt; //13-bit counter to count down
    logic [8:0] rx_shift_reg; //shift register with start and stop bits
    logic set_ready;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            RX_sync1 <= 1'b1;
            RX_sync2 <= 1'b1;
        end 
        else begin
            RX_sync1 <= RX;
            RX_sync2 <= RX_sync1;
        end
    end

    //two states: idle and receiving
    typedef enum logic {IDLE, RECEIVING} state_t;
    state_t curr_state, next_state;
    //state register
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end
    
    //next state logic
    always_comb begin
        //default values
        next_state = curr_state;
        set_ready = 1'b0;
        start=1'b0;
        receiving=1'b0;
        unique case (curr_state)
            IDLE: begin
                if (!RX_sync2) begin //start bit detected
                    next_state = RECEIVING;
                    start=1'b1;                   
                end
            end
            RECEIVING: begin
                receiving=1'b1;
                if (bit_cnt == 4'd10) begin //after receiving 8 data bits and 1 stop bit
                    next_state = IDLE;
                    set_ready = 1'b1;
                end
            end             
        endcase
    end


    
    
    assign rx_data = rx_shift_reg[7:0]; //outputs the data bits only
    always_ff @(posedge clk) begin
        if (shift) begin //shift the data from the MSB
            rx_shift_reg <= {RX_sync2, rx_shift_reg[8:1]};
        //else hold the value
        end
    end

    //baud rate generator
    //it will assert shift for one clock when it counts to max
    
    //bitwise or 
    assign shift = ~(|baud_cnt); //shift is high when it  counts down to 0
    always_ff @(posedge clk)begin
        if(start)
            baud_cnt <= 13'd2604;
        else if(shift) 
            baud_cnt <= 13'd5208; //reset the counter
        else if(receiving)
            baud_cnt <= baud_cnt - 1'b1; //count down only when receiving is asserted
        //else hold the value
    end

    //counter for how many times we have shifted
    
    always_ff @(posedge clk) begin
        if(start) //when starting, reset the counter
            bit_cnt <= 4'b0;
        else if(shift) //increment only when shifting
            bit_cnt <= bit_cnt + 1'b1;
        //else hold the value  
    end


    


    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n ) //when resetting or clearing ready, clear rdy
            rdy <= 1'b0;
        else if (clr_rdy||start)
            rdy <= 1'b0;
        else if (set_ready) //set rdy when we have received a byte, but we start again we should stop
            rdy <= 1'b1;
        //else hold the value  
    end

endmodule