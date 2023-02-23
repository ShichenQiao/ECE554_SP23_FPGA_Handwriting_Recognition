module pc(clk,rst_n,stall_IM_ID,dst_ID_EX,
          pc,pc_ID_EX,flow_change_ID_EX,pc_EX_DM);
////////////////////////////////////////////////////////////////////////////\
// This module implements the program counter logic. It normally increments \\
// the PC by 1, but when a branch is taken will add the 9-bit immediate      \\
// field to the PC+1.  In case of a jmp_imm it will add the 12-bit immediate //
// field to the PC+1.  In the case of a jmp_reg it will use the register    //
// port zero (p0) register access as the new value of the PC.  It also     //
// provides PC+1 as nxt_pc for JAL instructions.                          //
///////////////////////////////////////////////////////////////////////////
input clk,rst_n;
input flow_change_ID_EX;			// asserted from branch boolean on jump or taken branch
input stall_IM_ID;					// asserted if we need to stall the pipe
input [15:0] dst_ID_EX;				// branch target address comes in on this bus

output [15:0] pc;					// the PC, forms address to instruction memory
output reg [15:0] pc_ID_EX;			// needed in EX stage for Branch instruction
output reg [15:0] pc_EX_DM;			// needed in dst_mux for JAL instruction

reg [15:0] pc,pc_IM_ID;

wire [15:0] nxt_pc;

/////////////////////////////////////
// implement incrementer for PC+1 //
///////////////////////////////////
assign nxt_pc = pc + 1;

////////////////////////////////
// Implement the PC register //
//////////////////////////////
always @(posedge clk, negedge rst_n)
  if (!rst_n)
    pc <= 16'h0000;
  else if (!stall_IM_ID)	// all stalls stall the PC
    if (flow_change_ID_EX)
      pc <= dst_ID_EX;
    else
	  pc <= nxt_pc;
	  
////////////////////////////////////////////////
// Implement the PC pipelined register IM_ID //
//////////////////////////////////////////////
always @(posedge clk)
  if (!stall_IM_ID)
    pc_IM_ID <= nxt_pc;		// pipeline PC points to next instruction
	
////////////////////////////////////////////////
// Implement the PC pipelined register ID_EX //
//////////////////////////////////////////////
always @(posedge clk)
  pc_ID_EX <= pc_IM_ID;	// pipeline it down to EX stage for jumps
	
////////////////////////////////////////////////
// Implement the PC pipelined register EX_DM //
//////////////////////////////////////////////
always @(posedge clk)
  pc_EX_DM <= pc_ID_EX;	// pipeline it down to DM stage for saved register for JAL

endmodule