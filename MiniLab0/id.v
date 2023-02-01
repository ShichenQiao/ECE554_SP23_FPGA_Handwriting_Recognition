module id(clk,rst_n,instr,zr_EX_DM,br_instr_ID_EX,jmp_imm_ID_EX,jmp_reg_ID_EX,
          jmp_imm_EX_DM,rf_re0,rf_re1,
          rf_we_DM_WB,rf_p0_addr,rf_p1_addr,rf_dst_addr_DM_WB,alu_func_ID_EX,src0sel_ID_EX,
		  src1sel_ID_EX,dm_re_EX_DM,dm_we_EX_DM,clk_z_ID_EX,clk_nv_ID_EX,instr_ID_EX,
		  cc_ID_EX, stall_IM_ID,stall_ID_EX,stall_EX_DM,hlt_DM_WB,byp0_EX,byp0_DM,
		  byp1_EX,byp1_DM,flow_change_ID_EX);

input clk,rst_n;
input [15:0] instr;					// instruction to decode and execute direct from IM, flop first
input zr_EX_DM;						// zero flag from ALU (used for ADDZ)
input flow_change_ID_EX;

output reg jmp_imm_ID_EX;
output reg jmp_reg_ID_EX;
output reg br_instr_ID_EX;			// set if instruction is branch instruction
output reg jmp_imm_EX_DM;			// needed for JAL in dst_mux
output reg rf_re0;					// asserted if instruction needs to read operand 0 from RF
output reg rf_re1;					// asserted if instruction needs to read operand 1 from RF
output reg rf_we_DM_WB;				// set if instruction is writing back to RF
output reg [3:0] rf_p0_addr;		// normally instr[3:0] but for LHB and SW it is instr[11:8]
output reg [3:0] rf_p1_addr;		// normally instr[7:4]
output reg [3:0] rf_dst_addr_DM_WB;	// normally instr[11:8] but for JAL it is forced to 15
output reg [2:0] alu_func_ID_EX;	// select ALU operation to be performed
output reg [1:0] src0sel_ID_EX;		// select source for src0 bus
output reg [1:0] src1sel_ID_EX;		// select source for src1 bus
output reg dm_re_EX_DM;				// asserted on loads
output reg dm_we_EX_DM;				// asserted on stores
output reg clk_z_ID_EX;				// asserted for instructions that should modify zero flag
output reg clk_nv_ID_EX;			// asserted for instructions that should modify negative and ov flags
output [11:0] instr_ID_EX;			// lower 12-bits needed for immediate based instructions
output [2:0] cc_ID_EX;				// condition code bits for branch determination from instr[11:9]
output stall_IM_ID;					// asserted for hazards and halt instruction, stalls IM_ID flops
output stall_ID_EX;					// asserted for hazards and halt instruction, stalls ID_EX flops
output stall_EX_DM;					// asserted for hazards and halt instruction, stalls EX_DM flops
output reg hlt_DM_WB;				// needed for register dump
output reg byp0_EX,byp0_DM;			// bypasing controls for RF_p0
output reg byp1_EX,byp1_DM;			// bypassing controls for RF_p1

////////////////////////////////////////////////////////////////
// Register type needed for assignment in combinational case //
//////////////////////////////////////////////////////////////
reg br_instr;
reg jmp_imm;
reg jmp_reg;
reg rf_we;
reg hlt;
reg [3:0] rf_dst_addr;
reg [2:0] alu_func;
reg [1:0] src0sel,src1sel;
reg dm_re;
reg dm_we;
reg clk_z;
reg clk_nv;
reg cond_ex;

/////////////////////////////////
// Registers needed for flops //
///////////////////////////////
reg [15:0] instr_IM_ID;			// flop capturing the instruction to be decoded
reg	rf_we_ID_EX,rf_we_EX_DM;
reg [3:0] rf_dst_addr_ID_EX,rf_dst_addr_EX_DM;
reg	dm_re_ID_EX;
reg	dm_we_ID_EX;
reg hlt_ID_EX,hlt_EX_DM;
reg [11:0] instr_ID_EX;		// only need lower 12-bits for immediate values
reg flow_change_EX_DM;		// needed to pipeline flow_change_ID_EX
reg cond_ex_ID_EX;			// needed for ADDZ knock down of rf_we

wire load_use_hazard,flush;

/////////////////////
// include params //
///////////////////
`include "common_params.inc"
	
	
///////////////////////////////////
// Flop the instruction from IM //
/////////////////////////////////
always @(posedge clk, negedge rst_n)
  if (!rst_n)
    instr_IM_ID <= 16'hb000;			// LLB R0, #0000
  else if (!stall_IM_ID)
    instr_IM_ID <= instr;				// flop raw instruction from IM
	
/////////////////////////////////////////////////////////////
// Pipeline control signals needed in EX stage and beyond //
///////////////////////////////////////////////////////////
always @(posedge clk)
  if (!stall_ID_EX)
    begin
	  br_instr_ID_EX 	<= br_instr & !flush;
	  jmp_imm_ID_EX   	<= jmp_imm & !flush;
	  jmp_reg_ID_EX   	<= jmp_reg & !flush;
	  rf_we_ID_EX     	<= rf_we & !load_use_hazard & !flush;
	  rf_dst_addr_ID_EX	<= rf_dst_addr;
	  alu_func_ID_EX    <= alu_func;
	  src0sel_ID_EX		<= src0sel;
	  src1sel_ID_EX		<= src1sel;
	  dm_re_ID_EX       <= dm_re;
	  dm_we_ID_EX       <= dm_we & !load_use_hazard & !flush;
	  clk_z_ID_EX		<= clk_z & !load_use_hazard & !flush;
	  clk_nv_ID_EX		<= clk_nv & !load_use_hazard & !flush;
	  instr_ID_EX		<= instr_IM_ID[11:0];
	  cond_ex_ID_EX 	<= cond_ex;
	end
	
//////////////////////////////////////////////////////////////
// Pipeline control signals needed in MEM stage and beyond //
////////////////////////////////////////////////////////////
always @(posedge clk)
  if (!stall_EX_DM)
    begin
	  rf_we_EX_DM		<= rf_we_ID_EX & (!(cond_ex_ID_EX & !zr_EX_DM));	// ADDZ
	  rf_dst_addr_EX_DM <= rf_dst_addr_ID_EX;
      dm_re_EX_DM		<= dm_re_ID_EX;
	  dm_we_EX_DM		<= dm_we_ID_EX;
	  jmp_imm_EX_DM 	<= jmp_imm_ID_EX;
	end
	
	
always @(posedge clk) begin
  rf_we_DM_WB 		<= rf_we_EX_DM;
  rf_dst_addr_DM_WB <= rf_dst_addr_EX_DM;
end


/////////////////////////////////////////////////////////////
// Flops for bypass control logic (these are ID_EX flops) //
///////////////////////////////////////////////////////////
always @(posedge clk, negedge rst_n)
  if (!rst_n) 
    begin
	  byp0_EX <= 1'b0;
	  byp0_DM <= 1'b0;
	  byp1_EX <= 1'b0;
	  byp1_DM <= 1'b0;
	end
  else
    begin
	  byp0_EX <= (rf_dst_addr_ID_EX==rf_p0_addr) ? (rf_we_ID_EX & |rf_p0_addr) : 1'b0;
	  byp0_DM <= (rf_dst_addr_EX_DM==rf_p0_addr) ? (rf_we_EX_DM & |rf_p0_addr) : 1'b0;
	  byp1_EX <= (rf_dst_addr_ID_EX==rf_p1_addr) ? (rf_we_ID_EX & |rf_p1_addr) : 1'b0;
	  byp1_DM <= (rf_dst_addr_EX_DM==rf_p1_addr) ? (rf_we_EX_DM & |rf_p1_addr) : 1'b0;
	end
	
///////////////////////////////////////////
// Flops for pipelining HLT instruction //
/////////////////////////////////////////
always @(posedge clk, negedge rst_n)
  if (!rst_n)
    begin
	  hlt_ID_EX <= 1'b0;
	  hlt_EX_DM <= 1'b0;
	  hlt_DM_WB <= 1'b0;
    end
  else
    begin
	  hlt_ID_EX <= hlt & !flush | hlt_ID_EX;	// once set stays set
	  hlt_EX_DM <= hlt_ID_EX;
	  hlt_DM_WB <= hlt_EX_DM;
	end
	
//////////////////////////////////////////
// Have to pipeline flow_change so can //
// flush the 2 following instructions //
///////////////////////////////////////	
always @(posedge clk, negedge rst_n)
  if (!rst_n)
    flow_change_EX_DM <= 1'b0;
  else if(!stall_EX_DM)
    flow_change_EX_DM <= flow_change_ID_EX;

assign flush = flow_change_ID_EX | flow_change_EX_DM | hlt_ID_EX | hlt_EX_DM;

////////////////////////////////
// Load Use Hazard Detection //
//////////////////////////////	
assign load_use_hazard = (((rf_dst_addr_ID_EX==rf_p0_addr) && rf_re0) || 
                          ((rf_dst_addr_ID_EX==rf_p1_addr) && rf_re1)) ? dm_re_ID_EX : 1'b0;
						  
assign stall_IM_ID = hlt_ID_EX | load_use_hazard;
assign stall_ID_EX = 1'b0; // hlt_EX_DM;
assign stall_EX_DM = 1'b0; // hlt_EX_DM;

assign cc_ID_EX = instr_ID_EX[11:9];

//////////////////////////////////////////////////////////////
// default to most common state and override base on instr //
////////////////////////////////////////////////////////////
always @(instr_IM_ID) begin
  br_instr = 0;
  jmp_imm = 0;
  jmp_reg = 0;
  rf_re0 = 0;
  rf_re1 = 0;
  rf_we = 0;
  rf_p0_addr = instr_IM_ID[3:0];
  rf_p1_addr = instr_IM_ID[7:4];
  rf_dst_addr = instr_IM_ID[11:8];
  alu_func = ADD;
  src0sel = RF2SRC0;
  src1sel = RF2SRC1;
  dm_re = 0;
  dm_we = 0;
  clk_z = 0;
  clk_nv = 0;
  hlt = 0;
  cond_ex = 0;
  
  case (instr_IM_ID[15:12])
    ADDi : begin
	  rf_re0 = 1;
	  rf_re1 = 1;
	  rf_we = 1;
      clk_z = 1;
      clk_nv = 1;
	end
	ADDZi : begin
	  rf_re0 = 1;
	  rf_re1 = 1;
	  rf_we = 1;	// potentially knocked down in next pipe reg
      clk_z = 1;
      clk_nv = 1;
	  cond_ex = 1;	// this is a conditionally executing instruction
	end
	SUBi : begin
	  rf_re0 = 1;
	  rf_re1 = 1;
	  rf_we = 1;
      alu_func = SUB;	
      clk_z = 1;
      clk_nv = 1;	  
	end
	ANDi : begin
	  rf_re0 = 1;
	  rf_re1 = 1;
	  rf_we = 1;
      alu_func = AND;
	  clk_z = 1;
	end
	NORi : begin
	  rf_re0 = 1;
	  rf_re1 = 1;
	  rf_we = 1;
      alu_func = NOR;
	  clk_z = 1;
	end	
	SLLi : begin
	  rf_re1 = 1;
	  rf_we = 1;
      alu_func = SLL;
	  clk_z = 1;
	end	
	SRLi : begin
	  rf_re1 = 1;
	  rf_we = 1;
      alu_func = SRL;
	  clk_z = 1;
	end	
	SRAi : begin
	  rf_re1 = 1;
	  rf_we = 1;
      alu_func = SRA;
	  clk_z = 1;
	end
	LWi : begin
	  src0sel = IMM2SRC0;		// sign extended address offset
	  rf_re1 = 1;
	  rf_we = 1;
	  dm_re = 1;
	end
	SWi : begin
	  src0sel = IMM2SRC0;					// sign extended address offset
	  rf_re1 = 1;							// read register that contains address base
	  rf_re0 = 1;							// read register to be stored
	  rf_p0_addr = instr_IM_ID[11:8];		// register to be stored is encoded in [11:8]
	  dm_we = 1;
	end
	LHBi : begin
	  rf_re0 = 1;
	  rf_p0_addr = instr_IM_ID[11:8];		// need to preserve lower byte, access it so can be recycled
	  src1sel = IMM2SRC1;					// access 8-bit immediate.
	  rf_we = 1;
	  alu_func = LHB;
	end
	LLBi : begin
	  rf_re0 = 1;					// access zero from reg0 and ADD
	  rf_p0_addr = 4'h0;			// reg0 contains zero
	  src1sel = IMM2SRC1;			// access 8-bit immediate
	  rf_we = 1;
	end
    BRi : begin
	  src0sel = IMM_BR2SRC0;		// 8-bit SE immediate
	  src1sel = NPC2SRC1;			// nxt_pc is routed to source 1
	  br_instr = 1;
	end
	JALi : begin
	  src0sel = IMM_JMP2SRC0;		// 12-bit SE immediate
	  src1sel = NPC2SRC1;			// nxt_pc is routed to source 1
	  rf_we = 1;
	  rf_dst_addr = 4'hF;			// for JAL we write nxt_pc to reg15
	  jmp_imm = 1;
	end
	JRi : begin
	  rf_re0 = 1;					// access zero from reg0 and ADD
	  rf_p0_addr = 4'h0;
	  rf_re1 = 1;					// read register to jump to on src1
	  jmp_reg = 1;
	end
	HLTi : begin
	  hlt = 1;
	end
	
  endcase
end

endmodule
  
  