module weight_rom(clk,raddr,rdata);

  input clk;
  input [12:0] raddr;
  output reg [31:0] rdata;
  
  reg [31:0]mem[0:7830];   //The current weight mem is 32 bit floating point x (28x28) x 10

  always @(posedge clk) begin
    rdata <= mem[raddr];
  end

endmodule
