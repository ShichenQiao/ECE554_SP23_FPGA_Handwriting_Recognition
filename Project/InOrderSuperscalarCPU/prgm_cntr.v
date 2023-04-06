module pc(clk,rst_n,stall1_IM_ID, stall2_IM_ID, dst_ID_EX,
          pc,pc_ID_EX,flow_change_ID_EX,pc_EX_DM);
////////////////////////////////////////////////////////////////////////////\
// This module implements the program counter logic. It normally increments \\
// the PC by 2, but when there is a dependency in the previous instruction,  \\
// then it may increment the PC by 1 or 0.                                    \\
// When a branch is taken will add the 9-bit immediate                         \\ 
// field to the PC+1.  In case of a jmp_imm it will add the 12-bit immediate   //
// field to the PC+1.  In the case of a jmp_reg it will use the register      //
// port zero (p0) register access as the new value of the PC.  It also       //
// provides PC+1 as nxt_pc for JAL instructions.                            //
/////////////////////////////////////////////////////////////////////////////
input clk,rst_n;
input flow_change_ID_EX;            // asserted from branch boolean on jump or taken branch
input stall1_IM_ID, stall2_IM_ID;                    // asserted if we need to stall the pipe
input [31:0] dst_ID_EX;                // branch target address comes in on this bus

output [31:0] pc;                    // the PC, forms address to instruction memory
output reg [31:0] pc_ID_EX;            // needed in EX stage for Branch instruction
output reg [31:0] pc_EX_DM;            // needed in dst_mux for JAL instruction

reg [31:0] pc,pc_IM_ID;

wire [31:0] nxt_pc;
wire [31:0] nxt_2pc;

/////////////////////////////////////
// implement incrementer for PC+1 //
///////////////////////////////////
assign nxt_pc = pc + 32'h0000_0001;

/////////////////////////////////////
// implement incrementer for PC+2 //
///////////////////////////////////
assign nxt_2pc = pc + 32'h0000_0002;

////////////////////////////////
// Implement the PC register //
//////////////////////////////
always @(posedge clk, negedge rst_n)
  if (!rst_n)
    pc <= 32'h0000_0000;
  else if (!stall2_IM_ID)    // This happens if instr0 or instr1 waits for dm access from previous cycle
    if (flow_change_ID_EX)
      pc <= dst_ID_EX;
    else if (stall1_IM_ID) // This happens if instr1 waits for instr0 and cannot execute in parallel
      pc <= nxt_pc;
    else
      pc <= nxt_2pc;

////////////////////////////////////////////////
// Implement the PC pipelined register IM_ID //
//////////////////////////////////////////////
always @(posedge clk)
  if (!stall1_IM_ID)
    pc_IM_ID <= nxt_pc;        // pipeline PC points to next instruction

////////////////////////////////////////////////
// Implement the PC pipelined register ID_EX //
//////////////////////////////////////////////
always @(posedge clk)
  pc_ID_EX <= pc_IM_ID;    // pipeline it down to EX stage for jumps

////////////////////////////////////////////////
// Implement the PC pipelined register EX_DM //
//////////////////////////////////////////////
always @(posedge clk)
  pc_EX_DM <= pc_ID_EX;    // pipeline it down to DM stage for saved register for JAL

endmodule