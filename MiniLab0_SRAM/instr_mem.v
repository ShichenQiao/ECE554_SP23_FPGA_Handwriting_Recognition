module IM(clk,addr,rd_en,instr);

input clk;
input [15:0] addr;
input rd_en;			// asserted when instruction read desired

output reg [15:0] instr;	//output of insturction memory

reg [15:0]instr_mem[0:2047];

/////////////////////////////////////
// Memory is latched on clock low //
///////////////////////////////////
always @(negedge clk)
  if (rd_en)
    instr <= instr_mem[addr];

initial begin
  $readmemh("C:\Users\12239\Desktop\ECE554\Erics552PipelinedProc\Erics552PipelinedProc\SourceCode\instr.hex",instr_mem);
end

endmodule
