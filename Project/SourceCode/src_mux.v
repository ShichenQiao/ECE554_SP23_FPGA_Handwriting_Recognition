module src_mux(clk,stall_ID_EX,stall_EX_DM,src0sel_ID_EX,src1sel_ID_EX,p0,p1,
               imm_ID_EX,pc_ID_EX,p0_EX_DM,src0,src1,dst_EX_DM,dst_DM_WB, dst_ext_EX_DM,
               byp0_EX,byp0_DM,byp1_EX,byp1_DM, byp0_ext_EX, byp1_ext_EX);

input clk;
input stall_ID_EX,stall_EX_DM;                  // stall signal
input [1:0] src0sel_ID_EX,src1sel_ID_EX;        // mux selectors for src0 and src1 busses
input [31:0] p0;                                // port 0 from register file
input [31:0] p1;                                // port 1 from register file
input [31:0] pc_ID_EX;                          // Next PC for JAL instruction
input [15:0] imm_ID_EX;                         // immediate from instruction stream goes on src0
input [31:0] dst_EX_DM;                         // EX_DM results for bypassing RF reads
input [31:0] dst_ext_EX_DM;                     // ext_EX_DM results for bypassing RF reads
input [31:0] dst_DM_WB;                         // DM_WB results for bypassing RF reads
input byp0_EX,byp1_EX;                          // From ID, selects EX results to bypass RF sources
input byp0_ext_EX, byp1_ext_EX;                 // From ID, selects ext_EX results to bypass RF sources
input byp0_DM,byp1_DM;                          // From ID, selects DM results to bypass RF sources
output reg [31:0] p0_EX_DM;                     // need to output this as data for SW instructions
output [31:0] src0,src1;                        // source busses

/////////////////////////////////
// registers needed for flops //
///////////////////////////////
reg [31:0] p0_ID_EX,p1_ID_EX;		// need to flop register file outputs to form _ID_EX versions

wire[31:0] RF_p0,RF_p1;				// output of bypass muxes for RF sources
/////////////////////
// include params //
///////////////////
`include "common_params.inc"

/////////////////////////////////////////////////
// Flop the read ports from the register file //
///////////////////////////////////////////////
always @(posedge clk)
  if (!stall_ID_EX)
    begin
      p0_ID_EX <= p0;
      p1_ID_EX <= p1;
    end
	
/////////////////////////////
// Bypass Muxes for port0 //
///////////////////////////
assign RF_p0 = (byp0_EX) ? dst_EX_DM :		// EX gets priority because it represents more recent data
               (byp0_ext_EX) ? dst_ext_EX_DM :
               (byp0_DM) ? dst_DM_WB :
			   p0_ID_EX;
	
/////////////////////////////
// Bypass Muxes for port1 //
///////////////////////////
assign RF_p1 = (byp1_EX) ? dst_EX_DM :		// EX gets priority because it represents more recent data
               (byp1_ext_EX) ? dst_ext_EX_DM :
               (byp1_DM) ? dst_DM_WB :
			   p1_ID_EX;	
			   
////////////////////////////////////////////////////
// Need to pipeline the data to be stored for SW //
//////////////////////////////////////////////////
always @(posedge clk)
  if (!stall_EX_DM)
    p0_EX_DM <= RF_p0;
	
assign src0 = (src0sel_ID_EX == RF2SRC0) ? RF_p0 : 
              (src0sel_ID_EX == IMM_BR2SRC0) ? {{20{imm_ID_EX[11]}},imm_ID_EX[11:0]} :		// branch immediates
              (src0sel_ID_EX == IMM_JMP2SRC0) ? {{20{imm_ID_EX[11]}},imm_ID_EX[11:0]} :	// JMP immediates
              {{24{imm_ID_EX[7]}},imm_ID_EX[7:0]};		// for address immediates for DM operations

assign src1 = (src1sel_ID_EX == RF2SRC1) ? RF_p1 : 
              (src1sel_ID_EX == NPC2SRC1) ? pc_ID_EX :	// for JAL
              {{16{imm_ID_EX[15]}},imm_ID_EX[15:0]};    // for LHB/LLB (sign extended 16-bit immediate
			  
endmodule

