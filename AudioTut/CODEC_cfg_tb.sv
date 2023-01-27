module CODEC_cfg_tb();

  logic clk, rst_n;
  logic cfg_done;
  logic SCL;			// I2C clock

  CODEC_cfg iDUT(
    .clk(clk),
	.rst_n(rst_n),
	.SDA(SDA),
	.SCL(SCL),
	.cfg_done(cfg_done)
  );

  logic is_acking;
  assign is_acking = (iDUT.iDUT.state == 3'h2) || (iDUT.iDUT.state == 3'h4) || (iDUT.iDUT.state == 3'h6);
  assign (strong0,weak1) SDA = is_acking ? 1'b0 : 1'b1;

  initial begin
    clk = 1'b0;
	rst_n = 1'b0;
	@(posedge clk);
	@(negedge clk);
	rst_n = 1'b1;

	repeat(262145) @(posedge clk);		// wait until the 18-bit timer expire, 262145 = 2^18 + 1
	if(iDUT.wrt !== 1'b1) begin			// check functionality of tx_done
	  $display("ERROR: first command should be sent right after the 18-bit timer expire!");
	  $stop();
	end
	if(iDUT.cmd !== 16'h0105) begin			// check accuracy of tx_done
	  $display("ERROR: first command should be 16'h0105!");
	  $stop();
	end

	repeat(2049) @(posedge clk);		// wait 2048 cycles in between commands
	if((iDUT.wrt !== 1'b1) || (iDUT.cmd !== 16'h0305)) begin
	  $display("ERROR: second command incorrect!");
	  $stop();
	end
	repeat(2049) @(posedge clk);		// wait 2048 cycles in between commands
	if((iDUT.wrt !== 1'b1) || (iDUT.cmd !== 16'h0812)) begin
	  $display("ERROR: second command incorrect!");
	  $stop();
	end
	repeat(2049) @(posedge clk);		// wait 2048 cycles in between commands
	if((iDUT.wrt !== 1'b1) || (iDUT.cmd !== 16'h0A06)) begin
	  $display("ERROR: second command incorrect!");
	  $stop();
	end
	repeat(2049) @(posedge clk);		// wait 2048 cycles in between commands
	if((iDUT.wrt !== 1'b1) || (iDUT.cmd !== 16'h0C62)) begin
	  $display("ERROR: second command incorrect!");
	  $stop();
	end
	repeat(2049) @(posedge clk);		// wait 2048 cycles in between commands
	if((iDUT.wrt !== 1'b1) || (iDUT.cmd !== 16'h0E01)) begin
	  $display("ERROR: second command incorrect!");
	  $stop();
	end
	repeat(2049) @(posedge clk);		// wait 2048 cycles in between commands
	if((iDUT.wrt !== 1'b1) || (iDUT.cmd !== 16'h1201)) begin
	  $display("ERROR: second command incorrect!");
	  $stop();
	end
	repeat(2049) @(posedge clk);		// wait 2048 cycles after last command
	if(cfg_done !== 1'b1) begin
	  $display("ERROR: did not raise cfg_done after all commands!");
	  $stop();
	end

	repeat(5) @(posedge clk);		// for better looking waveform
	$display("ALL TESTS PASSED!!!");
	$stop();
  end

  always
	#5 clk = ~clk;

endmodule
