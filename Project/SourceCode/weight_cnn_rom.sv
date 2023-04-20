module weight_cnn_rom(clk,raddr,rdata);

  input clk;
  //input [12:0] raddr;
  input [15:0] raddr;
  output reg [31:0] rdata;
  
  reg [31:0]rom[0:63653];   // CNN kernels and weights

  initial
    $readmemh("../weightcnn.hex",rom);

  always @(negedge clk) begin
    rdata <= rom[raddr];
  end

endmodule
