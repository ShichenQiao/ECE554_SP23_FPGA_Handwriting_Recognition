// This module will decode two instructions in parallel. 
// Depends on the dependency of the decoded instructions, it could stall the pc by 1 cycle or 2 cycles
// to ensure correctness. 
module id(clk,rst_n,instr,zr_EX_DM,br_instr_ID_EX,jmp_imm_ID_EX,jmp_reg_ID_EX,
          jmp_imm_EX_DM,ext_alu_EX_DM,stack_pop_EX_DM, rf_re0,rf_re1,
          rf_we_DM_WB,rf_p0_addr,rf_p1_addr,rf_dst_addr_DM_WB,alu_func_ID_EX, stack_push_ID_EX, stack_pop_ID_EX, src0sel_ID_EX,
          src1sel_ID_EX,dm_re_EX_DM,dm_we_EX_DM,im_re_EX_DM, clk_z_ID_EX,clk_nv_ID_EX,clk_z_ID_ext_EX, clk_nv_ID_ext_EX, instr_ID_EX,
          cc_ID_EX, stall_IM_ID,stall_ID_EX,stall_EX_DM,hlt_DM_WB,byp0_EX,byp0_DM, byp0_stack_pop, byp1_stack_pop,
          byp1_EX,byp1_DM, byp0_ext_EX, byp1_ext_EX, flow_change_ID_EX);

input clk,rst_n;
input [31:0] instr0, instr1;                     // instruction to decode and execute direct from IM, flop first
input zr0_EX_DM, zr1_EX_DM;                         // zero flag from ALU (used for ADDZ)
input flow_change0_ID_EX, flow_change1_ID_EX;// under review

output reg jmp_imm0_ID_EX, jmp_imm1_ID_EX;
output reg jmp_reg0_ID_EX, jmp_reg1_ID_EX;
output reg br_instr0_ID_EX, br_instr1_ID_EX;              // set if instruction is branch instruction
output reg jmp_imm0_EX_DM, jmp_imm1_EX_DM;               // needed for JAL in dst_mux
output reg ext_alu0_EX_DM, ext_alu1_EX_DM;               // needed for ext_ALU in dst_mux
output reg stack_pop0_EX_DM, stack_pop1_EX_DM;             // needed for stack in dst_mux
output reg rf_re0;                      // asserted if instruction 0 needs to read operand 0 from RF
output reg rf_re1;                      // asserted if instruction 0 needs to read operand 1 from RF
output reg rf_re2;                      // asserted if instruction 1 needs to read operand 0 from RF
output reg rf_re3;                      // asserted if instruction 1 needs to read operand 1 from RF
output reg rf_we0_DM_WB;                 // set if instruction 1 is writing back to RF
output reg rf_we1_DM_WB;                 // set if instruction is writing back to RF
output reg [4:0] rf_p0_addr;            // normally instr0[4:0] but for LHB and SW it is instr[20:16]
output reg [4:0] rf_p1_addr;            // normally instr0[12:8]
output reg [4:0] rf_p2_addr;            // normally instr1[4:0] but for LHB and SW it is instr[20:16]
output reg [4:0] rf_p3_addr;            // normally instr1[12:8]

output reg [4:0] rf_dst_addr0_DM_WB;     // normally instr0[20:16] but for JAL it is forced to 31
output reg [4:0] rf_dst_addr1_DM_WB;     // normally instr1[20:16] but for JAL it is forced to 31
output reg [2:0] alu_func0_ID_EX, alu_func1_ID_EX;        // select ALU operation to be performed
output reg stack_push0_ID_EX;            // stack_push to be performed, from instruction0
output reg stack_push1_ID_EX;            // stack_push to be performed, from instruction1
output reg stack_pop0_ID_EX;             // stack_pop to be performed, from instruction0
output reg stack_pop1_ID_EX;             // stack_pop to be performed, from instruction1

output reg [1:0] src0sel0_ID_EX;         // select source for src0 bus for instruction0 
output reg [1:0] src1sel0_ID_EX;         // select source for src1 bus for instruction0
output reg [1:0] src0sel1_ID_EX;         // select source for src0 bus for instruction1 
output reg [1:0] src1sel1_ID_EX;         // select source for src1 bus for instruction1
output reg dm_re0_EX_DM, dm_re1_EX_DM;   // asserted on loads
output reg dm_we0_EX_DM, dm_we1_EX_DM;                 // asserted on stores
output reg im_re0_EX_DM, im_re1_EX_DM;                 // asserted on load from instruction memory
output reg clk_z0_ID_EX, clk_z1_ID_EX;                 // asserted for instructions that should modify zero flag
output reg clk_nv0_ID_EX, clk_nv0_ID_EX;                // asserted for instructions that should modify negative and ov flags
output reg clk_z0_ID_ext_EX, clk_z1_ID_ext_EX;             // asserted for instructions that should modify zero flag from ext_alu
output reg clk_nv0_ID_ext_EX, clk_nv1_ID_ext_EX;            // asserted for instructions that should modify negative and ov flag from ext_alu
output [15:0] instr0_ID_EX, instr1_ID_EX;              // lower 16-bits needed for immediate based instructions
output reg [2:0] cc0_ID_EX, cc1_ID_EX;              // condition code bits for branch determination from instr[26:24]

// TODO: Under review
output stall_IM_ID;                     // asserted for hazards and halt instruction, stalls IM_ID flops
output stall_ID_EX;                     // asserted for hazards and halt instruction, stalls ID_EX flops
output stall_EX_DM;                     // asserted for hazards and halt instruction, stalls EX_DM flops
output reg hlt_DM_WB;                   // needed for register dump
output reg byp0_EX,byp0_DM;             // bypasing controls for RF_p0
output reg byp1_EX,byp1_DM;             // bypassing controls for RF_p1
output reg byp0_ext_EX, byp1_ext_EX;    // bypassing controls for ext_ALU
output reg byp0_stack_pop, byp1_stack_pop; //bypassing controls for stack
////////////////////////////////////////////////////////////////
// Register type needed for assignment in combinational case //
//////////////////////////////////////////////////////////////
// instruction0
reg br_instr0;
reg jmp_imm0;
reg jmp_reg0;
reg rf_we0;
reg hlt0;
reg [4:0] rf_dst_addr0;
reg [2:0] alu_func0;
reg [1:0] src0sel0,src1sel0;
reg dm_re0;
reg dm_we0;
reg im_re0;
reg stack_push0;
reg stack_pop0;
reg clk_z0;
reg clk_nv0;
reg clk_ext_z0;
reg clk_ext_nv0;
reg cond_ex0;
reg ext_alu0;

// instruction 1
reg br_instr1;
reg jmp_imm1;
reg jmp_reg1;
reg rf_we1;
reg hlt1;
reg [4:0] rf_dst_addr1;
reg [2:0] alu_func1;
reg [1:0] src0sel1,src1sel1;
reg dm_re1;
reg dm_we1;
reg im_re1;
reg stack_push1;
reg stack_pop1;
reg clk_z1;
reg clk_nv1;
reg clk_ext_z1;
reg clk_ext_nv1;
reg cond_ex1;
reg ext_alu1;

/////////////////////////////////
// Registers needed for flops //
///////////////////////////////
reg [31:0] instr0_IM_ID, instr1_IM_ID;          // flop capturing the instruction to be decoded
reg rf_we0_ID_EX,rf_we0_EX_DM, rf_we1_ID_EX,rf_we1_EX_DM;
reg [4:0] rf_dst_addr0_ID_EX,rf_dst_addr0_EX_DM, rf_dst_addr1_ID_EX,rf_dst_addr1_EX_DM;
reg dm_re0_ID_EX, dm_re1_ID_EX;
reg dm_we0_ID_EX, dm_we1_ID_EX;
reg im_re0_ID_EX, im_re1_ID_EX;
reg hlt0_ID_EX,hlt0_EX_DM, hlt1_ID_EX,hlt1_EX_DM;
reg [15:0] instr0_ID_EX, instr1_ID_EX;        // only need lower 16-bits for immediate values
reg flow_change0_EX_DM, flow_change1_EX_DM;         // needed to pipeline flow_change_ID_EX
reg cond_ex0_ID_EX, cond_ex1_ID_EX;             // needed for ADDZ knock down of rf_we
reg ext_alu1_ID_EX, ext_alu1_ID_EX;             // flop one cycle for ext_alu dst_mux


// TODO: under review
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
    instr0_IM_ID <= 32'h5800_0000;     // LLB R0, #0000
    instr1_IM_ID <= 32'h5800_0000;     // LLB R0, #0000
  else if (!stall_IM_ID) // TODO: under review
    instr_IM_ID <= instr;        // flop raw instruction from IM

/////////////////////////////////////////////////////////////
// Pipeline control signals needed in EX stage and beyond //
///////////////////////////////////////////////////////////
always @(posedge clk)
  if (!stall_ID_EX)
    begin
      br_instr0_ID_EX    <= br_instr0 & !flush;
      jmp_imm0_ID_EX     <= jmp_imm0 & !flush;
      jmp_reg0_ID_EX     <= jmp_reg0 & !flush;
      rf_we0_ID_EX       <= rf_we0 & !load_use_hazard & !flush;
      rf_dst_addr0_ID_EX <= rf_dst_addr0;
      alu_func0_ID_EX    <= alu_func0;
      stack_push0_ID_EX  <= stack_push0 & !load_use_hazard & !flush;
      stack_pop0_ID_EX   <= stack_pop0 & !flush;
      src0sel0_ID_EX     <= src0sel0;
      src1sel0_ID_EX     <= src1sel0;
      dm_re0_ID_EX       <= dm_re0 & !load_use_hazard & !flush;
      dm_we0_ID_EX       <= dm_we0 & !load_use_hazard & !flush;
      im_re0_ID_EX       <= im_re0 & !load_use_hazard & !flush;
      clk_z0_ID_EX       <= clk_z0 & !load_use_hazard & !flush;
      clk_nv0_ID_EX      <= clk_nv0 & !load_use_hazard & !flush;
      clk_z0_ID_ext_EX   <= clk_ext_z0 & !load_use_hazard & !flush;
      clk_nv0_ID_ext_EX  <= clk_ext_nv0 & !load_use_hazard & !flush;
      instr0_ID_EX       <= instr0_IM_ID[15:0];
      cc0_ID_EX          <= instr0_IM_ID[26:24];
      cond_ex0_ID_EX     <= cond_ex0;
      ext_alu0_ID_EX     <= ext_alu0 & !load_use_hazard & !flush; //TODO: is the load_use_hazard and flush needed?

      br_instr1_ID_EX    <= br_instr1 & !flush;
      jmp_imm1_ID_EX     <= jmp_imm1 & !flush;
      jmp_reg1_ID_EX     <= jmp_reg1 & !flush;
      rf_we1_ID_EX       <= rf_we1 & !load_use_hazard & !flush;
      rf_dst_addr1_ID_EX <= rf_dst_addr1;
      alu_func1_ID_EX    <= alu_func1;
      stack_push1_ID_EX  <= stack_push1 & !load_use_hazard & !flush;
      stack_pop1_ID_EX   <= stack_pop1 & !flush;
      src0sel1_ID_EX     <= src0sel1;
      src1sel1_ID_EX     <= src1sel1;
      dm_re1_ID_EX       <= dm_re1 & !load_use_hazard & !flush;
      dm_we1_ID_EX       <= dm_we1 & !load_use_hazard & !flush;
      im_re1_ID_EX       <= im_re1 & !load_use_hazard & !flush;
      clk_z1_ID_EX       <= clk_z1 & !load_use_hazard & !flush;
      clk_nv1_ID_EX      <= clk_nv1 & !load_use_hazard & !flush;
      clk_z1_ID_ext_EX   <= clk_ext_z1 & !load_use_hazard & !flush;
      clk_nv1_ID_ext_EX  <= clk_ext_nv1 & !load_use_hazard & !flush;
      instr1_ID_EX       <= instr1_IM_ID[15:0];
      cc1_ID_EX          <= instr1_IM_ID[26:24];
      cond_ex1_ID_EX     <= cond_ex1;
      ext_alu1_ID_EX     <= ext_alu1 & !load_use_hazard & !flush; //TODO: is the load_use_hazard and flush needed?

    end

//////////////////////////////////////////////////////////////
// Pipeline control signals needed in MEM stage and beyond //
////////////////////////////////////////////////////////////
// TODO: under review
always @(posedge clk)
  if (!stall_EX_DM)
    begin
      rf_we_EX_DM       <= rf_we_ID_EX & (!(cond_ex_ID_EX & !zr_EX_DM));    // ADDZ
      rf_dst_addr_EX_DM <= rf_dst_addr_ID_EX;
      dm_re_EX_DM       <= dm_re_ID_EX;
      dm_we_EX_DM       <= dm_we_ID_EX;
      im_re_EX_DM       <= im_re_ID_EX;
      jmp_imm_EX_DM     <= jmp_imm_ID_EX;
      ext_alu_EX_DM     <= ext_alu_ID_EX;
      stack_pop_EX_DM   <= stack_pop_ID_EX;
    end


always @(posedge clk) begin
  rf_we_DM_WB       <= rf_we_EX_DM;
  rf_dst_addr_DM_WB <= rf_dst_addr_EX_DM;
end


/////////////////////////////////////////////////////////////
// Flops for bypass control logic (these are ID_EX flops) //
///////////////////////////////////////////////////////////
always @(posedge clk, negedge rst_n)
  if (!rst_n) 
    begin
      byp0_EX <= 1'b0;
      byp0_ext_EX <= 1'b0;
      byp0_stack_pop <= 1'b0;
      byp0_DM <= 1'b0;
      byp1_EX <= 1'b0;
      byp1_ext_EX <= 1'b0;
      byp1_stack_pop <= 1'b0;
      byp1_DM <= 1'b0;
    end
  else
    begin
      byp0_EX <= (rf_dst_addr_ID_EX==rf_p0_addr) ? (rf_we_ID_EX & |rf_p0_addr & !ext_alu_ID_EX) : 1'b0;
      byp0_ext_EX <= (rf_dst_addr_ID_EX==rf_p0_addr) ? (rf_we_ID_EX & |rf_p0_addr & ext_alu_ID_EX) : 1'b0;
      byp0_stack_pop <= (rf_dst_addr_ID_EX==rf_p0_addr) ? (rf_we_ID_EX & |rf_p0_addr & stack_pop_ID_EX) : 1'b0;
      byp0_DM <= (rf_dst_addr_EX_DM==rf_p0_addr) ? (rf_we_EX_DM & |rf_p0_addr) : 1'b0;
      byp1_EX <= (rf_dst_addr_ID_EX==rf_p1_addr) ? (rf_we_ID_EX & |rf_p1_addr & !ext_alu_ID_EX) : 1'b0;
      byp1_ext_EX <= (rf_dst_addr_ID_EX==rf_p1_addr) ? (rf_we_ID_EX & |rf_p1_addr & ext_alu_ID_EX) : 1'b0;
      byp1_stack_pop <= (rf_dst_addr_ID_EX==rf_p1_addr) ? (rf_we_ID_EX & |rf_p1_addr & stack_pop_ID_EX) : 1'b0;
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
      hlt_ID_EX <= hlt & !flush | hlt_ID_EX;    // once set stays set
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
                          ((rf_dst_addr_ID_EX==rf_p1_addr) && rf_re1)) ? (dm_re_ID_EX | im_re_ID_EX) : 1'b0;

assign stall_IM_ID = hlt_ID_EX | load_use_hazard;
assign stall_ID_EX = 1'b0; // hlt_EX_DM;
assign stall_EX_DM = 1'b0; // hlt_EX_DM;

// decode for instruciton 0
instr_decode INSTR0_DECODE(instr, br_instr, jmp_im, jmp_reg, rf_re0, rf_re1, rf_we, rf_p0_addr, 
                    rf_p1_addr, rf_dst_addr, alu_func, src0sel, src1sel, dm_re, dm_we, im_re, 
                    clk_z, clk_nv, clk_ext_z, clk_ext_nv, hlt, cond_ex, ext_alu, stack_pop, stack_push);

// decode for instruction 1
instr_decode INSTR1_DECODE(instr, br_instr, jmp_im, jmp_reg, rf_re0, rf_re1, rf_we, rf_p0_addr, 
                    rf_p1_addr, rf_dst_addr, alu_func, src0sel, src1sel, dm_re, dm_we, im_re, 
                    clk_z, clk_nv, clk_ext_z, clk_ext_nv, hlt, cond_ex, ext_alu, stack_pop, stack_push);

endmodule
