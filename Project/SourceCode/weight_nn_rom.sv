module weight_nn_rom(clk,raddr,rdata);

  input clk;
  //input [12:0] raddr;
  input [15:0] raddr;
  output reg [31:0] rdata;
  
  reg [31:0]rom[0:50815];   //The current weight mem is 32 bit floating point x (28x28) x 10

  initial
    $readmemh("../weightnn.hex",rom);

  always @(negedge clk) begin
    rdata <= rom[raddr];
  end

endmodule
