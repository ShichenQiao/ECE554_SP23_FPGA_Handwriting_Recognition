module I2C_tb();

  reg clk,rst_n,wrt;
  reg [15:0] data;
  reg ack;
  
  wire SDA,SCL;
  wire done;
  wire err;
  
  assign (strong0,weak1) SDA = (ack) ? 1'b0 : 1'b1;
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  I2C24Wrt iDUT(.clk(clk),.rst_n(rst_n),.data16(data),.wrt(wrt),.done(done),
           .err(err),.SCL(SCL),.SDA(SDA));
		   
  initial begin
    rst_n = 0;
	clk = 0;
	data = 16'h6699;
	wrt = 0;
	ack = 0;
	@(negedge clk);
	rst_n = 1;
	
	repeat(100) @(posedge clk);
	wrt = 1;
	@(posedge clk);
	wrt = 0;
	
	repeat(9)@(posedge SCL);
	ack = 1;
	@(negedge SCL);
	ack = 0;
	
	repeat(9)@(posedge SCL);
	ack = 1;
	@(negedge SCL);
	ack = 0;
	
	repeat(9)@(posedge SCL);
	ack = 1;
	@(negedge SCL);
	ack = 0;
	
	@(posedge done);
	
	repeat(50) @(posedge clk);
	$stop();
	

  end
  
  always
    #5 clk = ~clk;
	
endmodule