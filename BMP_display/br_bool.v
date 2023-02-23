module br_bool(clk,rst_n,clk_z_ID_EX,clk_nv_ID_EX,br_instr_ID_EX,
               jmp_imm_ID_EX,jmp_reg_ID_EX,cc_ID_EX,zr,ov,neg,
			   zr_EX_DM,flow_change_ID_EX);

//////////////////////////////////////////////////////
// determines branch or not based on cc, and flags //
////////////////////////////////////////////////////
input clk,rst_n;
input clk_z_ID_EX;			// from ID, tells us to flop the zero flag
input clk_nv_ID_EX;			// from ID, tells us to flop the overflow flag
input br_instr_ID_EX;		// from ID, tell us if this is a branch instruction
input jmp_imm_ID_EX;		// from ID, tell us this is jump immediate instruction
input jmp_reg_ID_EX;		// from ID, tell us this is jump register instruction
input [2:0] cc_ID_EX;		// condition code from instr[11:9]
input zr,ov,neg;			// flag bits from ALU

output reg flow_change_ID_EX;		// asserted if we should take branch or jumping
output reg zr_EX_DM;				// goes to ID for ADDZ

reg neg_EX_DM,ov_EX_DM;

/////////////////////////
// Flop for zero flag //
///////////////////////
always @(posedge clk, negedge rst_n)
  if (!rst_n)
    zr_EX_DM  <= 0;
  else if (clk_z_ID_EX) 
    zr_EX_DM  <= zr;

	
/////////////////////////////////////
// Flops for negative and ov flag //
///////////////////////////////////
always @(posedge clk, negedge rst_n)
  if (!rst_n)
    begin
      ov_EX_DM  <= 0;
	  neg_EX_DM <= 0;
	end
  else if (clk_nv_ID_EX)
    begin
      ov_EX_DM  <= ov;
	  neg_EX_DM <= neg;
	end

always @(br_instr_ID_EX,cc_ID_EX,zr_EX_DM,ov_EX_DM,neg_EX_DM,jmp_reg_ID_EX,jmp_imm_ID_EX) begin

  flow_change_ID_EX = jmp_imm_ID_EX | jmp_reg_ID_EX;	// jumps always change the flow
  
  if (br_instr_ID_EX)
    case (cc_ID_EX)
	  3'b000 : flow_change_ID_EX = ~zr_EX_DM;
	  3'b001 : flow_change_ID_EX = zr_EX_DM;
	  3'b010 : flow_change_ID_EX = ~zr_EX_DM & ~neg_EX_DM;
	  3'b011 : flow_change_ID_EX = neg_EX_DM;
	  3'b100 : flow_change_ID_EX = zr_EX_DM | (~zr_EX_DM & ~neg_EX_DM);
	  3'b101 : flow_change_ID_EX = neg_EX_DM | zr_EX_DM;
	  3'b110 : flow_change_ID_EX = ov_EX_DM;
	  3'b111 : flow_change_ID_EX = 1;
	endcase
end

endmodule