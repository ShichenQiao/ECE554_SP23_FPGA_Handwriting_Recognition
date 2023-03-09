module weight_rom(clk,raddr,rdata);

  input clk;
  input [12:0] raddr;
  output reg [31:0] rdata;
  
  reg [31:0]rom[0:7830];   //The current weight mem is 32 bit floating point x (28x28) x 10

  initial
    $readmemh("../weight.hex",rom);

  always @(posedge clk) begin
    rdata <= rom[raddr];
  end

  initial begin
    $readmemh("../weights.hex", mem);
  end

endmodule
