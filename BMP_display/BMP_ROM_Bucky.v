module BMP_ROM_Bucky(clk,addr,dout);

input clk;				// 50MHz clock
input [15:0] addr;		
output reg [8:0] dout;	// pixel out

  reg [8:0] rom[0:17169];
  
  initial
    $readmemh("Bucky.hex",rom);
  
  always @(posedge clk)
    dout <= rom[addr];

endmodule
