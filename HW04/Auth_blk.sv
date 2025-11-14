module Auth_blk(
    input logic RX,
    input logic clk,
    input logic rst_n,
    input logic rider_off,
    output logic pwr_up
);
    localparam letter_G = 8'h47; //letter 'G' --> pwr up code
    localparam letter_S = 8'h53; //letter 'S' --> when the app is disconnected
    logic [7:0] rx_data;
    logic rx_rdy;
    logic clr_rx_rdy;
    //instantiate UART_rx module
    UART_rx uart_receiver(
        .clk(clk),
        .rst_n(rst_n),
        .RX(RX),
        .clr_rdy(clr_rx_rdy),
        .rx_data(rx_data),
        .rdy(rx_rdy)
    );
    typedef enum logic[1:0] {IDLE, POWER_ON, DISCONNECTED} state_t;
    state_t state, next_state;
    //state register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        //default values
        next_state = state;
        pwr_up = 1'b0;
        clr_rx_rdy = 1'b0;
        unique case (state)
            IDLE: begin
                if (rx_rdy && (rx_data == letter_G)) begin
                    next_state = POWER_ON;
                    pwr_up = 1'b1;
                    clr_rx_rdy = 1'b1;
                end
            end
            POWER_ON: begin
                pwr_up = 1'b1;
                //stay in power on state until rider_off signal is true
                if (rx_rdy && (rx_data == letter_S)) begin
                    next_state = DISCONNECTED;
                    clr_rx_rdy = 1'b1;
                    if (rider_off) begin
                        next_state = IDLE;
                    end
                end
                
            end
            DISCONNECTED: begin
                pwr_up = 1'b1;
                if (rider_off) begin
                    next_state = IDLE;
                    pwr_up = 1'b0;
                end
                else if(rx_rdy && (rx_data == letter_G)) begin
                    next_state = POWER_ON;
                    pwr_up = 1'b1;
                    clr_rx_rdy = 1'b1;
                end
            end
            default: next_state = IDLE;
        endcase
    end

endmodule