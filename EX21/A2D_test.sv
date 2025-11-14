module A2D_test(clk,RST_n,SEL,LED,SCLK,SS_n,MOSI,MISO);

  input clk,RST_n;		// clk and unsynched reset from PB
  input SEL;			// from 2nd PB, cycle through outputs
  input MISO;			// from A2D
  
  output [7:0] LED;
  output SS_n;			// active low slave select to A2D
  output SCLK;			// SCLK to A2D SPI
  output MOSI;
  
  ////////////////////////////////////////////////////////////
  // Declare any needed internal registers (like counters) //
  //////////////////////////////////////////////////////////
  logic [11:0] lft_ld;
  logic [11:0] rght_ld;
  logic [11:0] steer_pot;
  logic [11:0] batt;
  
  ///////////////////////////////////////////////////////
  // Declare any needed internal signals as type wire //
  /////////////////////////////////////////////////////
  wire nxt;
  wire en_2bit;
  logic [1:0] en_led;
  //assign the led signals to the upper 8 bits of the selected output
  assign LED[7:0] = (en_led == 2'b00) ? lft_ld[11:4] :
                    (en_led == 2'b01) ? rght_ld[11:4] :
                    (en_led == 2'b10) ? steer_pot[11:4] :
                    (en_led == 2'b11) ? batt[11:4] : 8'b00000000;

  //////////////////////////////////////////////////
  // Infer 19-bit counter to set conversion rate //
  ////////////////////////////////////////////////
  logic [18:0] cnt_19bit;
  assign nxt = &cnt_19bit; // when all bits are 1
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_19bit <= 19'h00000;
    else if(nxt)// when full
        cnt_19bit <= 19'h00000;
    else
        cnt_19bit <= cnt_19bit + 19'h00001;
  end
  
  ////////////////////////////////////////////////////////////////
  // Infer 2-bit counter to select which output to map to LEDs //
  //////////////////////////////////////////////////////////////
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        en_led <= 2'b00;
    else if(en_2bit) // when PB released
        en_led <= en_led + 2'b01;
  end
	  
  //////////////////////////////////////////////////////
  // Infer Mux to select which output to map to LEDs //
  //////////////////////////////////////////////////// 

	
  //////////////////////
  // Instantiate DUT //
  ////////////////////  
  A2D_intf iDUT(.clk(clk),.rst_n(rst_n),.nxt(nxt),.lft_ld(lft_ld),
                .rght_ld(rght_ld),.steer_pot(steer_pot),.batt(batt),
				.SS_n(SS_n),.SCLK(SCLK),.MOSI(MOSI),.MISO(MISO));
			   
  ///////////////////////////////////////////////
  // Instantiate Push Button release detector //
  /////////////////////////////////////////////
  PB_release iPB(.clk(clk),.rst_n(rst_n),.PB(SEL),.released(en_2bit));
  
  /////////////////////////////////////
  // Instantiate reset synchronizer //
  ///////////////////////////////////
  rst_synch iRST(.clk(clk),.RST_n(RST_n),.rst_n(rst_n));   
	  
endmodule
  