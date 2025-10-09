module SegwayMath_tb;
    // Testbench signals
    logic signed [11:0] PID_cntrl;
    logic [7:0] ss_tmr;
    logic [11:0] steer_pot;
    logic en_steer;
    logic pwr_up;
    logic signed [11:0] lft_spd, rght_spd;
    logic too_fast;

    // Instantiate the DUT
    SegwayMath dut (
        .PID_cntrl(PID_cntrl),
        .ss_tmr(ss_tmr),
        .steer_pot(steer_pot),
        .en_steer(en_steer),
        .pwr_up(pwr_up),
        .lft_spd(lft_spd),
        .rght_spd(rght_spd),
        .too_fast(too_fast)
    );

    // // Test 1: Original scenario
    // initial begin
    //     // Initialize signals
    //     PID_cntrl = 12'h5FF; // +1535
    //     ss_tmr = 8'h00;
    //     steer_pot = 12'h800; // Midpoint (doesn't matter, steer_en=0)
    //     en_steer = 1'b0;
    //     pwr_up = 1'b1;

    //     $display("Test 1: ss_tmr ramp, PID_cntrl constant, steer_en=0");
    //     $display("Time\tss_tmr\tPID_cntrl\tlft_spd\trght_spd\ttoo_fast");
    //     $monitor("%0t\t%h\t%h\t%0d\t%0d\t%b", $time, ss_tmr, PID_cntrl, lft_spd, rght_spd, too_fast);

    //     // Ramp up ss_tmr from 0 to 8'hFF, PID_cntrl constant
    //     repeat (255) begin
    //         #2;
    //         ss_tmr = ss_tmr + 1;
    //     end

    //     // Hold ss_tmr at max, ramp PID_cntrl from 12'h5FF(1535) to 12'hE00(-512)
    //     repeat (2048) begin
    //         #2;
    //         PID_cntrl = PID_cntrl - 16'h0001;
    //     end

    //     $stop;
    // end

    // Test 2: New scenario per user specification
    initial begin
        //#10000; // Wait for test 1 to finish (adjust as needed)
        // Initialize signals for test 2
        PID_cntrl = 12'h3FF; // 1023
        ss_tmr = 8'hFF;      // Hold at max
        steer_pot = 12'h000; // Start at 0
        en_steer = 1'b1;     // Steering enabled
        pwr_up = 1'b1;       // Power up

        $display("\nTest 2: PID_cntrl ramps down, steer_pot sweeps, steer_en=1, pwr_up falls at end");
        $display("Time\tss_tmr\tPID_cntrl\tsteer_pot\tlft_spd\trght_spd\ttoo_fast");
        $monitor("%0t\t%h\t%h\t%h\t%0d\t%0d\t%b", $time, ss_tmr, PID_cntrl, steer_pot, lft_spd, rght_spd, too_fast);

        // Ramp PID_cntrl from 12'h3FF (1023) down to 12'hC00 (-1024)
        // Ramp steer_pot from 0 to 0xFFE in parallel
        repeat (2048) begin
            #2;
            
            PID_cntrl = PID_cntrl - 1;
            //increment the steer pot by 2 each time
            if(steer_pot != 12'hFFE) steer_pot = steer_pot + 2;
        end

        // Drop pwr_up at the end
        #100;
        pwr_up = 1'b0;
        #100;
        $stop;
    end
endmodule
