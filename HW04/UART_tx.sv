module UART_tx(
    input logic clk,
    input logic rst_n,
    input logic trmt, //Asserted for 1 clock to initiate transmission
    input logic [7:0] tx_data, //Byte to trasmit
    output logic TX, //serial data output
    output logic tx_done //asserted when byte is done trassmitting. 
                            // stays high till next byte transmitted
);

    logic load; //comes from state machine, to load the shift register
    logic shift; //comes from baud rate generator, to shift the shift register
    logic trassmitting; //comes from state machine, indicates we are trassmitting
    logic [8:0] tx_shift_reg; //shift register with start and stop bits
    assign TX = tx_shift_reg[0];// outputs the LSB first
    //loading and shifting control flip-flops
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            tx_shift_reg <= 9'b111111111; //presetting
        else if(load)
                tx_shift_reg <={tx_data,1'b0}; //load start bit (0) and data
        else if(shift) begin//shift in the one stop bit (1)
            tx_shift_reg <= {1'b1,tx_shift_reg[8:1]};
        end
        //else hold the value   
    end


    //baud rate generator
    logic [12:0] baud_cnt; //13-bit counter to count to 5208
    //it will assert shift for one clock when it counts to max
    assign shift = baud_cnt == 13'd5208; //shift is high when it counts to 5208
    always_ff @(posedge clk) begin
        if(load || shift) //when loading or shifting, reset the counter
            baud_cnt <= 13'b0;
        else if(trassmitting) //count only when trassmitting is asserted
            baud_cnt <= baud_cnt + 1'b1;
        //else hold the value  
    end

    //counter for how many times we have shifted
    logic [3:0] bit_cnt; // when it hits 10 we are done
    always_ff @(posedge clk) begin
        if(load) //when loading, reset the counter
            bit_cnt <= 4'b0;
        else if(shift) //increment only when shifting
            bit_cnt <= bit_cnt + 1'b1;
        //else hold the value  
    end

    //done flip-flop
    //when bit_cnt hits 10, we are done
    logic set_done; //comes from state machine, to set the done flag
    always_ff @(posedge clk) begin
        if(load) ///when loading a new byte, clear done
            tx_done <= 1'b0;
        else if(set_done) 
            tx_done <= 1'b1;
        //else hold the value  
    end

    //state machine
    //two states: idle and trassmitting
    typedef enum logic {IDLE, TRASSMITTING} state_t;
    state_t curr_state, next_state;
    //state register
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end
    //next state logic
    always_comb begin
        //default values
        next_state = curr_state;
        load = 1'b0;
        set_done = 1'b0;
        trassmitting = 1'b0;
        unique case(curr_state)
            IDLE: begin
                if(trmt) begin //start trassmitting when trmt is asserted
                    next_state = TRASSMITTING;
                    load = 1'b1; //load the shift register
                end
                //else stay in IDLE
            end
            TRASSMITTING: begin
                trassmitting = 1'b1; //indicate we are trassmitting
                if(bit_cnt == 4'd10) begin //when we have shifted 10 times, we are done
                    next_state = IDLE;
                    set_done = 1'b1; //set the done flag
                end
            end
        endcase
    end

endmodule