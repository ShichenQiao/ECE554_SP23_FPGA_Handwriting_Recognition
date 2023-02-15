module IM(clk,addr,rd_en,instr);

input clk;
input [15:0] addr;
input rd_en;							// asserted when instruction read desired

output reg [15:0] instr;				//output of insturction memory

reg [15:0]instr_mem[0:16383];			// 16K*16 instruction memory

///////////////////////////////////
// Memory is flopped on negedge //
/////////////////////////////////
always @(negedge clk)
  if (rd_en)
    instr <= instr_mem[addr];

initial begin
  $readmemh("C:/Users/13651/Desktop/ECE554/Minilab0/MiniLab0/assembly/complex.hex",instr_mem);
end

endmodule
