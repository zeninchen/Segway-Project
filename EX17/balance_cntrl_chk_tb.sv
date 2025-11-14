module balance_cntrl_chk_tb ();
    //instantiate the iDUT
    logic clk;
    logic rst_n;
    logic signed [15:0] ptch;
    logic signed [15:0] ptch_rt;
    logic vld;
    logic pwr_up;
    logic rider_off;
    logic [11:0] steer_pot;
    logic en_steer;
    logic signed [11:0] lft_spd;
    logic signed [11:0] rght_spd;
    logic too_fast;
    int error_count = 0;
    balance_cntrl iDUT (
        .ptch(ptch),
        .ptch_rt(ptch_rt),
        .clk(clk),
        .rst_n(rst_n),
        .vld(vld),
        .pwr_up(pwr_up),
        .rider_off(rider_off),
        .steer_pot(steer_pot),
        .en_steer(en_steer),
        .lft_spd(lft_spd),
        .rght_spd(rght_spd),
        .too_fast(too_fast)       
    );
    //clock generation
    always
        #5 clk = ~clk;
    //Declare a "memory" of type reg that is 49-bits wide and has 1500 entries. This is your stimulus memory
    reg [48:0] stimulus_memory [0:1499];

    //Declare a "memory" of type reg that is 25-bits wide and has 1500 entries. This is your expected response memory
    reg [24:0] expected_response_memory [0:1499];

    logic [48:0] stim;
    logic [24:0] resp;
    
    initial begin
        $readmemh("balance_cntrl_stim.hex",stimulus_memory);
        $readmemh("balance_cntrl_resp.hex",expected_response_memory);
        clk = 0;
        rst_n = 0;
        force iDUT.ss_tmr = 8'hFF; //force ss_tmr to max value to disable its effect
        @(negedge clk);
        rst_n = 1;

        @(posedge clk);
        //in a for loop going over 1500 entries assign an entry of the stim memory
        //to the stim vector that drives the DUT inputs
        //count for how many errors occur
        
        for (int i=0; i<1500; i=i+1) begin
            stim = stimulus_memory[i];
            {rst_n, vld, ptch, ptch_rt, pwr_up, rider_off, steer_pot,  en_steer} = stim;
            resp = expected_response_memory[i];
            @(posedge clk);
            #1;
            //compare DUT outputs to expected response memory entry
            if ({lft_spd, rght_spd, too_fast} !== resp) begin
                //display the inputs
                
                $display("Testcase %0d Failed: Expected lft_spd=%0d, rght_spd=%0d, too_fast=%0b but got lft_spd=%0d, rght_spd=%0d, too_fast=%0b",
                         i, resp[24:13], resp[12:1], resp[0], lft_spd, rght_spd, too_fast);
                $display("Inputs were: rst_n=%0b, vld=%0b, ptch=%0d, ptch_rt=%0d, pwr_up=%0b, rider_off=%0b, steer_pot=%0d, en_steer=%0b",
                         rst_n, vld, ptch, ptch_rt, pwr_up, rider_off, steer_pot, en_steer);
                $stop;
                error_count = error_count + 1;
            end 
        end
        //display error count
        $display("Total Errors: %0d", error_count);
        release iDUT.ss_tmr;
        $display("GOOD: All Testcases Passed");
        $stop;
    end

endmodule