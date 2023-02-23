module BMP_ROM_image(clk,addr,dout);

input clk;				// 50MHz clock
input [15:0] addr;		
output reg [8:0] dout;	// pixel out

  reg [8:0] rom[0:17169];  //modify this for different image
  
  initial
    $readmemh("Bucky.hex",rom);  //modify this to get the correct hex file
  
  always @(posedge clk)
    dout <= rom[addr];

endmodule
