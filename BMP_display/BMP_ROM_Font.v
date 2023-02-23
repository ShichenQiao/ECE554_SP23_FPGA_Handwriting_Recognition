module BMP_ROM_Font(clk,addr,dout);

input clk;				// 50MHz clock
input [13:0] addr;
output reg [8:0] dout;	// pixel out

  reg [8:0] rom[0:8705];
  
  initial
    $readmemh("Font.hex",rom);
  
  always @(posedge clk)
    dout <= rom[addr];

endmodule
