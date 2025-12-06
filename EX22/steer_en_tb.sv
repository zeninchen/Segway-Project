module steer_en_tb;


  logic clk, rst_n;
  logic signed [11:0] lft_spd, rght_spd;
  // Outputs
  logic en_steer, rider_off;
  localparam size = 16199;
  // stimulus and expected response memories
  reg [23:0] mem_stim   [0:size-1];
  reg [3:0]  mem_expect [0:size-1];
  logic [23:0] stim;
  logic [3:0]  resp;
  int failed = 0;
  

  // DUT
  steer_en iDUT(
    .clk       (clk),
    .rst_n     (rst_n),
    .lft_spd   (lft_spd),
    .rght_spd  (rght_spd),
    .en_steer  (en_steer),
    .rider_off (rider_off)
  );


  // ==========================================================
  // Clock and reset
  // ==========================================================
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100 MHz 
  end

  initial begin  
    $readmemh("steer_en_stim.hex", mem_stim);
    $readmemh("steer_en_resp.hex", mem_expect);
    rst_n = 0;

    @(posedge clk);
    rst_n = 1;
    @(posedge clk);
    
    
    for (int i = 0; i < size; i=i+1) begin
      stim = mem_stim[i];
      {lft_spd, rght_spd} = stim;
      resp = mem_expect[i];
        

      @(posedge clk);

      if ({iDUT.sum_lt_min, iDUT.sum_gt_min, iDUT.diff_gt_1_4,iDUT.diff_gt_15_16} !== resp) begin
          //display the left and right speeds along with expected and actual outputs
          $display("At test %0d: lft_spd=%0d, rght_spd=%0d", i, lft_spd, rght_spd);
          $display("TEST FAILED at test %0d: Expected sum_lt_min=%0b, sum_gt_min=%0b, diff_gt_1_4=%0b, diff_gt_15_16=%0b but got sum_lt_min=%0b, sum_gt_min=%0b, diff_gt_1_4=%0b, diff_gt_15_16=%0b",
                  i,
                  resp[3], resp[2], resp[1], resp[0],
                  iDUT.sum_lt_min, iDUT.sum_gt_min, iDUT.diff_gt_1_4, iDUT.diff_gt_15_16);
        failed = failed + 1;
      end 
    end

        
    if (failed == 0) begin
        $display("WOOOHOOO   ALL TESTS PASSED!");
    end else begin
        $display("WEEWEEE     SOME TESTS FAILED.");
        //display number of failed tests
        $display("Number of failed tests: %0d", failed);
    end
    $stop;
  end

endmodule