module PID_Math_tb;

    // Testbench signals
    logic [15:0] ptch;
    logic [15:0] ptch_rt;
    logic [17:0] integrator;
    logic [11:0] PID_cntrl;

    // Instantiate the DUT
    PID_Math dut (
        .ptch(ptch),
        .ptch_rt(ptch_rt),
        .integrator(integrator),
        .PID_cntrl(PID_cntrl)
    );

    // Simulation
    initial begin
        // Initialize signals
        ptch = 16'hFF00;       // Start at -256
        ptch_rt = 16'h0FFF;    // Start ramp down from +4095
        integrator = 18'h3C000; // Start ramp up from 245760

        $monitor("Time=%0t | ptch=%h | ptch_rt=%h | integrator=%h | PID_cntrl=%h", 
                 $time, ptch, ptch_rt, integrator, PID_cntrl);

        
        //ptch is going to go up the whole time, integrator is going to fo up and then down for two times, and ptch_rt is going to go down and then up for four times
        
        //there ill be total of 8 cycles
        //1st cycle
        // ptch go up, ptch_rt go down, integrator go up
        repeat (64) begin
            #2; 
            ptch = ptch + 16'h0001; // Increment by 1
            ptch_rt = ptch_rt - 16'h0100; // Decrement by 256
            integrator = integrator + 18'h0080; // Decrement by 256
        end

        //2nd cycle
        // ptch go up, ptch_rt go up, integrator go up
        repeat (64) begin
            #2; 
            ptch = ptch + 16'h0001; // Increment by 1
            ptch_rt = ptch_rt + 16'h0100; // Increment by 256
            integrator = integrator + 18'h0080; // Increment by 256
        end

        //3rd cycle
        // ptch go up, ptch_rt go down, integrator go down
        repeat (64) begin
            #2; 
            ptch = ptch + 16'h0001; // Increment by 1
            ptch_rt = ptch_rt - 16'h0100; // Decrement by 256
            integrator = integrator - 18'h0080; // Decrement by 256
        end

        //4th cycle
        // ptch go up, ptch_rt go up, integrator continue to go down
        repeat (64) begin
            #2; 
            ptch = ptch + 16'h0001; // Increment by 1
            ptch_rt = ptch_rt + 16'h0100; // Increment by 256
            integrator = integrator - 18'h0080; // Decrement by 256
        end

        //5th
        // ptch go up, ptch_rt go down, integrator go up
        repeat (64) begin
            #2; 
            ptch = ptch + 16'h0001; // Increment by 1
            ptch_rt = ptch_rt - 16'h0100; // Decrement by 256
            integrator = integrator + 18'h0080; // Increment by 256
        end
        //6th
        // ptch go up, ptch_rt go up, integrator go up
        repeat (64) begin
            #2; 
            ptch = ptch + 16'h0001; // Increment by 1
            ptch_rt = ptch_rt + 16'h0100; // Increment by 256
            integrator = integrator + 18'h0080; // Increment by 256
        end

        //7th
        // ptch go up, ptch_rt go down, integrator go down
        repeat (64) begin
            #2; 
            ptch = ptch + 16'h0001; // Increment by 1
            ptch_rt = ptch_rt - 16'h0100; // Decrement by 256
            integrator = integrator - 18'h0080; // Decrement by 256
        end
        //8th
        // ptch go up, ptch_rt go up, integrator go down
        repeat (64) begin
            #2; 
            ptch = ptch + 16'h0001; // Increment by 1
            ptch_rt = ptch_rt + 16'h0100; // Increment by 256
            integrator = integrator - 18'h0080; // Increment by 256
        end


        $stop; // Stop the simulation instead of finishing it
    end

endmodule