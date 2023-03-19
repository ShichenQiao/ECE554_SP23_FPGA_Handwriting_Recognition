module image_compressor_tb();

logic clk, rst_n;				// 25MHz clk and rst_n
logic start;					// signals a valid pixel input
								// starting from address 0
logic [7:0] pix_color_in;		// 8-bit pixel color
logic [7:0] pix_haddr;			// pixel column address 0 to 223
logic [7:0] pix_vaddr;			// pixel row address 0 to 223

logic sram_wr;					// SRAM write enable
logic [7:0] pix_color_out;		// 8-bit pixel color output
								// that's averaged from 8*8 block
								
logic [9:0] compress_addr;		// pixel address after compression
								// ranging from 0 to 783 (28*28
logic [9:0] expected_addr;
image_compressor iDUT(.clk(clk),.rst_n(rst_n),.start(start),.pix_color_in(pix_color_in),.pix_haddr(pix_haddr),.pix_vaddr(pix_vaddr),.pix_color_out(pix_color_out),.compress_addr(compress_addr),.sram_wr(sram_wr));

logic [7:0] matrix [0:223][0:223];
logic [7:0] compress_matrix[0:873];
logic [13:0] temp_sum;
initial begin
  clk = 0;
  rst_n = 0;
  start =0;
  pix_color_in = 0;
  pix_haddr = 0;
  pix_vaddr = 0;
  temp_sum = 0;
  expected_addr = 0;
  
// prepare matrix
  for (int i = 0;i<224;i++) begin
    for (int j = 0;j<224;j++) begin
      matrix[i][j] = $random();
    end
  end
  for (int i = 0;i<28;i++) begin
    for (int j = 0;j<28;j++) begin
      for (int k = 0;k<8;k++) begin
        for (int m = 0;m<8;m++) begin
           temp_sum = temp_sum + matrix[i*8+k][j*8+m];
        end
      end
      compress_matrix[i*28+j] = temp_sum[13:6];
      temp_sum = 0;
    end
  end

  @(posedge clk);
  @(negedge clk);
  rst_n = 1;
  start = 1;
  pix_color_in = matrix[0][0];
  pix_haddr = 0;
  pix_vaddr = 0; 
  @(negedge clk);
      start = 0;
  for (int i = 0;i<224;i++) begin
    for (int j = 0;j<224;j++) begin
      if(i == 0 && j == 0)
	continue;
      pix_color_in = matrix[i][j];
      pix_haddr = j;
      pix_vaddr = i;  
      @(posedge clk);
      if(sram_wr && compress_matrix[compress_addr] !== pix_color_out) begin
        $display("write wrong data into compressed image!: write data %h != expected data %h at addr %h ", pix_color_out, compress_matrix[compress_addr],compress_addr );
        $stop();
      end
      if (sram_wr && compress_addr !== expected_addr) begin
        $display("not writing to expected addr: expect: %h, got: %h",expected_addr, compress_addr);
        $stop();
      end else if(sram_wr)
        expected_addr = expected_addr + 1;
    end

    for (int j = 0;j<400;j++) begin
      pix_color_in = 8'h00;   //insert non_valid color
      pix_haddr = 8'hFF;   //insert non_valid addr
      pix_vaddr = 8'hFF;   //insert non_valid addr
      @(negedge clk);
    end
  end
        $display("Spring_Break_start_signal:on");
        $stop();
end

always
  #5 clk = ~clk;
endmodule
