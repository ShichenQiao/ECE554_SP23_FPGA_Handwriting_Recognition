module dst_mux(clk,dm_re_EX_DM,dm_rd_data_EX_DM,pc_EX_DM,dst_EX_DM,rf_w_data_DM_WB,jmp_imm_EX_DM);
////////////////////////////////////////////////////////////////////////
// Simple 2:1 mux determining if ALU or DM is source for write to RF //
//////////////////////////////////////////////////////////////////////
input clk;
input dm_re_EX_DM;
input jmp_imm_EX_DM;
input [15:0] dm_rd_data_EX_DM;		// input from DM
input [15:0] pc_EX_DM;				// from PC for JAL saving to R15
input [15:0] dst_EX_DM;				// input from ALU

output reg[15:0] rf_w_data_DM_WB;		// output to be written to RF

always @(posedge clk)
  if (dm_re_EX_DM)
    rf_w_data_DM_WB <= dm_rd_data_EX_DM;
  else if (jmp_imm_EX_DM)
    rf_w_data_DM_WB <= pc_EX_DM;
  else
    rf_w_data_DM_WB <= dst_EX_DM;

endmodule
