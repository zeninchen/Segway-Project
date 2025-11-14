module PWM11(
    input logic clk,
    input logic rst_n,
    input logic [10:0] duty, 
    output logic PWM1,
    output logic PWM2,
    output logic PWM_synch,
    output logic ovr_I_blank
);
    logic [10:0] counter;
    logic PWM1_set;
    logic PWM2_set;
    logic PWM1_reset;
    logic PWM2_reset;
    localparam [10:0] NONOVERLAP = 11'h040;
    //counter
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= 11'b0;
        else if (counter == 11'd2047) //reset at max count
            counter <= 11'b0;
        else
            counter <= counter + 1'b1;
    end

    assign PWM_synch = ~|counter; //when all the counter is 0, PWM_synch is high
    
    //set is high when the condition is met and reset is low
    assign PWM1_set = (counter >= NONOVERLAP)&&!PWM1_reset;
    assign PWM1_reset = (counter >= duty);
    //clock for PWM1
    //PWM1 set and reset are both posedge triggered
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            PWM1 <= 1'b0;
        else if (PWM1_reset) //reset has higher priority
            PWM1 <= 1'b0;
        else if (PWM1_set)
            PWM1 <= 1'b1;
        
    end

    assign PWM2_set = (counter>=duty + NONOVERLAP)&&!PWM2_reset;
    assign PWM2_reset = (&counter); //reset at max count
    //clock for PWM2
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            PWM2 <= 1'b0;
        else if (PWM2_reset)//reset has higher priority
            PWM2 <= 1'b0;
        else if (PWM2_set)
            PWM2 <= 1'b1;
        
    end

    //when NONOVERLAP<cnt<NONOVERLAP+128 or NONOVERLAP+duty<cnt<NONOVERLAP+duty+128
    //assert ovr_I_blank 
    assign ovr_I_blank = ((counter > NONOVERLAP) && (counter < NONOVERLAP + 11'd128)) ||
                        ((counter > (duty + NONOVERLAP)) && (counter < (duty + NONOVERLAP + 11'd128)));
endmodule

