// this module decode the instr into control signals
module instr_decode(instr, br_instr, jmp_im, jmp_reg, rf_re0, rf_re1, rf_we, rf_p0_addr, 
                    rf_p1_addr, rf_dst_addr, alu_func, src0sel, src1sel, dm_re, dm_we, im_re, 
                    clk_z, clk_nv, clk_ext_z, clk_ext_nv, hlt, cond_ex, ext_alu, stack_pop, stack_push);
input [31:0] instr;
output reg br_instr;
output reg jmp_imm;
output reg jmp_reg;
output reg rf_re0;
output reg rf_re1;
output reg rf_we;
output reg [4:0] rf_p0_addr;
output reg [4:0] rf_p1_addr;
output reg [4:0] rf_dst_addr;
output reg [2:0] alu_func;
output reg [1:0] src0sel;
output reg [1:0] src1sel;
output reg dm_re;
output reg dm_we;
output reg im_re;
output reg clk_z;
output reg clk_nv;
output reg clk_ext_z;
output reg clk_ext_nv;
output reg hlt;
output reg cond_ex;
output reg ext_alu;
output reg stack_pop;
output reg stack_push;

///////////////////////////////////////////////////////////////
// default to most common state and override base on instr0 //
/////////////////////////////////////////////////////////////
always @(instr) begin
  br_instr = 0;
  jmp_imm = 0;
  jmp_reg = 0;
  rf_re0 = 0;
  rf_re1 = 0;
  rf_we = 0;
  rf_p0_addr = instr_IM_ID[4:0];
  rf_p1_addr = instr_IM_ID[12:8];
  rf_dst_addr = instr_IM_ID[20:16];
  alu_func = ADD;
  src0sel = RF2SRC0;
  src1sel = RF2SRC1;
  dm_re = 0;
  dm_we = 0;
  im_re = 0;
  clk_z = 0;
  clk_nv = 0;
  clk_ext_z = 0;
  clk_ext_nv = 0;
  hlt = 0;
  cond_ex = 0;
  ext_alu = 0;
  stack_pop = 0;
  stack_push = 0;

  case (instr_IM_ID[31:27])
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
      rf_we = 1;    // potentially knocked down in next pipe reg
      clk_z = 1;
      clk_nv = 1;
      cond_ex = 1;    // this is a conditionally executing instruction
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
      src0sel = IMM2SRC0;        // sign extended address offset
      rf_re1 = 1;
      rf_we = 1;
      dm_re = 1;
    end
    SWi : begin
      src0sel = IMM2SRC0;                    // sign extended address offset
      rf_re1 = 1;                            // read register that contains address base
      rf_re0 = 1;                            // read register to be stored
      rf_p0_addr = instr_IM_ID[20:16];        // register to be stored is encoded in [20:16]
      dm_we = 1;
    end
    LHBi : begin
      rf_re0 = 1;
      rf_p0_addr = instr_IM_ID[20:16];        // need to preserve lower byte, access it so can be recycled
      src1sel = IMM2SRC1;                    // access 16-bit immediate.
      rf_we = 1;
      alu_func = LHB;
    end
    LLBi : begin
      rf_re0 = 1;                    // access zero from reg0 and ADD
      rf_p0_addr = 5'h00;            // reg0 contains zero
      src1sel = IMM2SRC1;            // access 16-bit immediate
      rf_we = 1;
    end
    BRi : begin
      src0sel = IMM_BR2SRC0;         // 12-bit SE immediate
      src1sel = NPC2SRC1;            // nxt_pc is routed to source 1
      br_instr = 1;
    end
    JALi : begin
      src0sel = IMM_JMP2SRC0;        // 12-bit SE immediate
      src1sel = NPC2SRC1;            // nxt_pc is routed to source 1
      rf_we = 1;
      rf_dst_addr = 5'h1F;            // for JAL we write nxt_pc to reg31
      jmp_imm = 1;
    end
    JRi : begin
      rf_re0 = 1;                    // access zero from reg0 and ADD
      rf_p0_addr = 5'h00;
      rf_re1 = 1;                    // read register to jump to on src1
      jmp_reg = 1;
    end
    LWIi : begin
      src0sel = IMM2SRC0;        // sign extended address offset
      rf_re1 = 1;
      rf_we = 1;
      im_re = 1;
    end
    PUSHi : begin
      stack_push = 1;
      rf_re1 = 1;
    end
    POPi : begin
      stack_pop = 1;
      rf_we = 1;
    end
    ADDIi : begin
      src0sel = IMM2SRC0;        // sign extended intermediate
      rf_re1 = 1;
      rf_we = 1;
      clk_z = 1;
      clk_nv = 1;
    end
    SUBIi : begin
      src0sel = IMM2SRC0;        // sign extended intermediate
      rf_re1 = 1;
      rf_we = 1;
      clk_z = 1;
      clk_nv = 1;
      alu_func = SUB;    
    end
    MULi : begin
      rf_re0 = 1;
      rf_re1 = 1;
      rf_we = 1;
      clk_ext_z = 1;
      clk_ext_nv = 1;
      ext_alu = 1;
      alu_func = MUL;
    end
    UMULi : begin
      rf_re0 = 1;
      rf_re1 = 1;
      rf_we = 1;
      clk_ext_z = 1;
      clk_ext_nv = 1;
      ext_alu = 1;
      alu_func = UMUL;
    end
    ADDFi : begin
      rf_re0 = 1;
      rf_re1 = 1;
      rf_we = 1;
      clk_ext_z = 1;
      clk_ext_nv = 1;
      ext_alu = 1;
      alu_func = ADDF;
    end
    SUBFi : begin
      rf_re0 = 1;
      rf_re1 = 1;
      rf_we = 1;
      clk_ext_z = 1;
      clk_ext_nv = 1;
      ext_alu = 1;
      alu_func = SUBF;
    end
    MULFi : begin
      rf_re0 = 1;
      rf_re1 = 1;
      rf_we = 1;
      clk_ext_z = 1;
      clk_ext_nv = 1;
      ext_alu = 1;
      alu_func = MULF;
    end
    ITFi : begin
      rf_re1 = 1;
      rf_we = 1;
      ext_alu = 1;
      alu_func = ITF;
    end
    FTIi : begin
      rf_re1 = 1;
      rf_we = 1;
      ext_alu = 1;
      alu_func = FTI;
    end
    HLTi : begin
      hlt = 1;
    end
    
  endcase
end

endmodule