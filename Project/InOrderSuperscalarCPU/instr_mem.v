module IM(clk,addr0,addr1,instr0,instr1);
/////////////////////////////////////////////////////////////////////////////\\
// This module implements the instruction memory logic. It takes one address  \\
// inputs and fetch the two sequential instructions from the instruction memory\\
// The instruction memory is already read_enabled because there is no reason   //
// to not read an instruction                                                 //
///////////////////////////////////////////////////////////////////////////////

input clk;
input [13:0] addr0,addr1;


output reg [31:0] instr0, instr1;                // output of insturction memory

reg [31:0]instr_mem[0:255];           // 16K*32 instruction memory

///////////////////////////////////
// Memory is flopped on negedge //
/////////////////////////////////
always @(negedge clk)
  instr0 <= instr_mem[addr0];
  instr1 <= instr_mem[addr1];

initial begin
  $readmemh("../instr.hex",instr_mem);
end

endmodule
