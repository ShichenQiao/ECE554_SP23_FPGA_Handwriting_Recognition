module IM(clk,addr,rd_en,instr);

input clk;
input [15:0] addr;
input rd_en;			// asserted when instruction read desired

output reg [15:0] instr;	//output of insturction memory

reg [15:0]instr_mem[0:16383];

/////////////////////////////////////
// Memory is latched on clock low //
///////////////////////////////////
always @(addr,rd_en,clk)
  if (~clk & rd_en)
    instr <= instr_mem[addr];

initial begin
  $readmemh("C:/Users/13651/Desktop/ECE554/Minilab0/MiniLab0/demo.hex",instr_mem);
end

endmodule
