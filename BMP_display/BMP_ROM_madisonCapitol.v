module BMP_ROM_madisonCapitol(clk,addr,dout);

  input clk;     // 50MHz clock
  input [15:0] addr;
  output reg [8:0] dout;   // 9-bit color pixel out

  reg [8:0] rom[0:5601];

  initial
    $readmemh("madisonCapitol.hex",rom);

  always @(posedge clk)
    dout <= rom[addr];

endmodule
