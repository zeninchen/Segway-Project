module SPI_mnrch_tb;
    logic clk;
    logic rst_n;
    // SPI signals
    logic SCLK;
    logic MOSI;
    logic SS_n;
    logic MISO;
    // Control signals
    logic wrt;
    logic[15:0] wt_data;
    logic[15:0] rd_data;
    logic done;
    logic INT;
    SPI_mnrch iDUT(
        .clk(clk),
        .rst_n(rst_n),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .SS_n(SS_n),
        .MISO(MISO),
        .wrt(wrt),
        .wt_data(wt_data),
        .rd_data(rd_data),
        .done(done)
    );
    // SPI_iNEMO1(SS_n,SCLK,MISO,MOSI,INT)
    SPI_iNEMO1 iSPI_INEMO1(
        .SS_n(SS_n),
        .SCLK(SCLK),
        .MISO(MISO), 
        .MOSI(MOSI),
        .INT(INT)
    );
    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        // Add stimulus here
        @(posedge clk);
        wrt = 1;
        wt_data = 16'h8Fxx; // Example data to write
        @(posedge clk);
        wrt = 0;
        @(posedge done);
        $display("Read Data: %h", rd_data);
        //check if the read data is 16'hxx6A
        
        if (rd_data[7:0] === 8'h6A)
            $display("GOOD: Read data matches expected value.");
        else begin 
            $display("ERROR: Read data does not match expected value.");
            $stop;
        end


        
        @(posedge clk);
        //writing 02 to addres 0D
        @(posedge clk);
        wrt = 1;
        wt_data = 16'h0D02; // Example data to write
        @(posedge clk);
        wrt = 0;
        @(posedge done);
        @(posedge clk);
        //@(posedge iSPI_INEMO1.NEMO_setup);
        if(iSPI_INEMO1.NEMO_setup===1'b1)
            $display("GOOD: NEMO_setup is set after writing 02 to address 0D.");
        else begin
            $display("ERROR: NEMO_setup is not set after writing 02 to address 0D.");
            $stop; 
        end
                //reading from address A2
        @(negedge clk);
        
        @(posedge INT);
        @(posedge clk);
        wrt = 1;
        wt_data = 16'hA200; // Example address to read
        $display("checking line 1");
        @(posedge clk);
        wrt = 0;
        @(posedge done);    
        //check if Rd_data 8'h63                             
        if (rd_data[7:0] === 8'h63)
            $display("GOOD: low pitch in rd_data is correct.");
        else begin
            $display("ERROR: low pitch in rd_data is incorrect.");
            $display("Read Data: %h", rd_data);
            $stop; 

        end
        @(posedge clk);
        //check the high pitch
        wrt=1;
        wt_data=16'hA300; //address to read high pitch
        @(posedge clk);
        wrt=0;
        @(posedge done);
        if(rd_data[7:0]===8'h56)
            $display("GOOD: High pitch is correct.");
        else begin
            $display("ERROR: High pitch is incorrect.");
            $display("Read Data: %h", rd_data);
            $stop;
        end

        //check the next line
        
        @(posedge INT);
        @(posedge clk);
        wrt = 1;
        wt_data = 16'hA200; // Example address to read
        $display("checking line 2");
        @(posedge clk);
        wrt = 0;
        @(posedge done);    
        //check if Rd_data 8'h0d                             
        if (rd_data[7:0] === 8'h0D)
            $display("GOOD: low pitch in rd_data is correct.");
        else begin
            $display("ERROR: low pitch in rd_data is incorrect.");
            $display("Read Data: %h", rd_data);
            $stop; 

        end
        @(posedge clk);
        //check the high pitch
        wrt=1;
        wt_data=16'hA300; //address to read high pitch
        @(posedge clk);
        wrt=0;
        @(posedge done);
        if(rd_data[7:0]===8'hCD)
            $display("GOOD: High pitch is correct.");
        else begin
            $display("ERROR: High pitch is incorrect.");
            $display("Read Data: %h", rd_data);
            $stop;
        end
        $display("TEST COMPLETED");
        $stop;
    end
endmodule