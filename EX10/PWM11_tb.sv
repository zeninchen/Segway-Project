//PWM11 testbench
module PWM11_tb;
    logic clk;
    logic rst_n;
    logic [10:0] duty;
    logic PWM1;
    logic PWM2;
    logic PWM_synch;
    logic ovr_I_blank;

    // Instantiate the DUT (Device Under Test)
    PWM11 dut (
        .clk(clk),
        .rst_n(rst_n),
        .duty(duty),
        .PWM1(PWM1),
        .PWM2(PWM2),
        .PWM_synch(PWM_synch),
        .ovr_I_blank(ovr_I_blank)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units clock period
    end

    // Test sequence
    initial begin
        $monitor("Time: %0t | rst_n: %b | duty_cycle: %d | PWM1: %b | PWM2: %b | PWM_synch: %b | ovr_I_blank: %b", 
                 $time, rst_n, duty, PWM1, PWM2, PWM_synch, ovr_I_blank);
        // Initialize inputs
        rst_n = 0;
        //start with 50% duty cycle
        duty_cycle = 11'h3FF;

        // Apply reset
        #15;
        rst_n = 1;
        repeat (32) begin
            //duty_cycle = duty_cycle + 11'd128; // Increment duty cycle by 128
            #1280; // Wait for 128 clock cycles (128 * 10 time units)
        end
        //change to 75% duty cycle
        duty_cycle = 11'h5FF;
        //let each duty cycle run for 128 clock cycles
        repeat (32) begin
            #1280; // Wait for 128 clock cycles (128 * 10 time units)
        end
        //change to 25% duty cycle
        duty_cycle = 11'h1FF;
        //let each duty cycle run for 128 clock cycles
        repeat (32) begin
            #1280; // Wait for 128 clock cycles (128 * 10 time units)
        end


        $stop;
    end

endmodule