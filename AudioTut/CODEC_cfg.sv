module CODEC_cfg(clk,rst_n,SDA,SCL,cfg_done);
				   
  input clk, rst_n;

  output reg cfg_done;
  output SCL;			// I2C clock
  inout SDA;			// I2C data
 
  << You fill in the implementation >>
  
  /////////////////////////////
  // Instantiate I2C Master //
  ///////////////////////////
  I2C24Wrt iDUT(.clk(clk),.rst_n(rst_n),.data16(cmd),.wrt(wrt),.done(done),
           .err(err),.SCL(SCL),.SDA(SDA));
 
endmodule
	  