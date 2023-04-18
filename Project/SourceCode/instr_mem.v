module IM(clk,addr,rd_en,instr);

input clk;
input [13:0] addr;
input rd_en;                            // asserted when instruction read desired

output reg [31:0] instr;                // output of insturction memory

reg [31:0]instr_mem[0:1023];           // 1K*32 instruction memory

///////////////////////////////////
// Memory is flopped on negedge //
/////////////////////////////////
always @(negedge clk)
  if (rd_en)
    instr <= instr_mem[addr];

initial begin
  $readmemh("../instr.hex",instr_mem);
end

endmodule
