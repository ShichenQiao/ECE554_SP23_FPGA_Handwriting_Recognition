module cpu(clk,rst_n,rdata,addr,re,we,wdata);

input clk,rst_n;

input [15:0] rdata;				// exteral data input from the switches, 16'hDEAD if addr != 16'hC001
output [15:0] addr;				// rename dst_EX_DM to addr as a top level port
output re;						// rename dm_re_EX_DM to re as a top level port
output we;						// rename dm_we_EX_DM to we as a top level port
output [15:0] wdata;			// rename p0_EX_DM to wdata as a top level port

wire [15:0] instr;				// instruction from IM
wire [11:0] instr_ID_EX;		// immediate bus
wire [15:0] src0,src1;			// operand busses into ALU
wire [15:0] dst_EX_DM;			// result from ALU
wire [15:0] dst_ID_EX;			// result from ALU for branch destination
wire [15:0] pc_ID_EX;			// nxt_pc to source mux for JR
wire [15:0] pc_EX_DM;			// nxt_pc to store in reg15 for JAL
wire [15:0] iaddr;				// instruction address
wire [15:0] dm_rd_data_EX_DM;	// data memory read data
wire [15:0] rf_w_data_DM_WB;	// register file write data
wire [15:0] p0,p1;				// read ports from RF
wire [3:0] rf_p0_addr;			// address for port 0 reads
wire [3:0] rf_p1_addr;			// address for port 1 reads
wire [3:0] rf_dst_addr_DM_WB;	// address for RF write port
wire [2:0] alu_func_ID_EX;		// specifies operation ALU should perform
wire [1:0] src0sel_ID_EX;		// select for src0 bus
wire [1:0] src1sel_ID_EX;		// select for src1 bus
wire [2:0] cc_ID_EX;			// condition code pipeline from instr[11:9]
wire [15:0] p0_EX_DM;			// data to be stored for SW

wire dm_re_EX_DM, dm_we_EX_DM;	// DM enable signals from id
wire [15:0] dst_mux_data_in;	// data selection mux output (between internal and external rdata)
wire DM_we;						// DM write enable (only when address < 0x2000)

// output some original logic as ports to MiniLab0 toplevel
assign addr = dst_EX_DM;
assign re = dm_re_EX_DM;
assign we = dm_we_EX_DM;
assign wdata = p0_EX_DM;

// when addr < 0x2000, use internal data, otherwise, use external data
assign dst_mux_data_in = |addr[15:13] ? rdata : dm_rd_data_EX_DM;

// enable DM write only when addr < 0x2000 and dm_we_EX_DM is set
assign DM_we = ~|addr[15:13] & dm_we_EX_DM;

//////////////////////////////////
// Instantiate program counter //
////////////////////////////////
pc iPC(.clk(clk), .rst_n(rst_n), .stall_IM_ID(stall_IM_ID), .pc(iaddr), .dst_ID_EX(dst_ID_EX),
       .pc_ID_EX(pc_ID_EX), .pc_EX_DM(pc_EX_DM), .flow_change_ID_EX(flow_change_ID_EX));
	   
/////////////////////////////////////
// Instantiate instruction memory //
///////////////////////////////////
// iaddr only use lower 14 bits because it's a 16KB IM
IM iIM(.clk(clk), .addr(iaddr[13:0]), .rd_en(1'b1), .instr(instr));

//////////////////////////////////////////////
// Instantiate register instruction decode //
////////////////////////////////////////////
id	iID(.clk(clk), .rst_n(rst_n), .instr(instr), .zr_EX_DM(zr_EX_DM), .br_instr_ID_EX(br_instr_ID_EX),
        .jmp_imm_ID_EX(jmp_imm_ID_EX), .jmp_reg_ID_EX(jmp_reg_ID_EX), .jmp_imm_EX_DM(jmp_imm_EX_DM), .rf_re0(rf_re0),
		.rf_re1(rf_re1), .rf_we_DM_WB(rf_we_DM_WB), .rf_p0_addr(rf_p0_addr), .rf_p1_addr(rf_p1_addr),
		.rf_dst_addr_DM_WB(rf_dst_addr_DM_WB), .alu_func_ID_EX(alu_func_ID_EX),
		.src0sel_ID_EX(src0sel_ID_EX), .src1sel_ID_EX(src1sel_ID_EX), .dm_re_EX_DM(dm_re_EX_DM),
		.dm_we_EX_DM(dm_we_EX_DM), .clk_z_ID_EX(clk_z_ID_EX), .clk_nv_ID_EX(clk_nv_ID_EX),
		.instr_ID_EX(instr_ID_EX), .cc_ID_EX(cc_ID_EX), .stall_IM_ID(stall_IM_ID),
		.stall_ID_EX(stall_ID_EX), .stall_EX_DM(stall_EX_DM), .hlt_DM_WB(hlt_DM_WB),
		.byp0_EX(byp0_EX), .byp0_DM(byp0_DM), .byp1_EX(byp1_EX), .byp1_DM(byp1_DM),
		.flow_change_ID_EX(flow_change_ID_EX));
	   
////////////////////////////////
// Instantiate register file //
//////////////////////////////
rf iRF(.clk(clk), .p0_addr(rf_p0_addr), .p1_addr(rf_p1_addr), .p0(p0), .p1(p1),
       .re0(rf_re0), .re1(rf_re1), .dst_addr(rf_dst_addr_DM_WB), .dst(rf_w_data_DM_WB),
 	   .we(rf_we_DM_WB), .hlt(hlt_DM_WB));
	   
///////////////////////////////////
// Instantiate register src mux //
/////////////////////////////////
src_mux ISRCMUX(.clk(clk), .stall_ID_EX(stall_ID_EX), .stall_EX_DM(stall_EX_DM),
                .src0sel_ID_EX(src0sel_ID_EX), .src1sel_ID_EX(src1sel_ID_EX), .p0(p0), .p1(p1),
                .imm_ID_EX(instr_ID_EX), .pc_ID_EX(pc_ID_EX), .p0_EX_DM(p0_EX_DM),
				.src0(src0), .src1(src1), .dst_EX_DM(dst_EX_DM), .dst_DM_WB(rf_w_data_DM_WB),
			    .byp0_EX(byp0_EX), .byp0_DM(byp0_DM), .byp1_EX(byp1_EX), .byp1_DM(byp1_DM));
	   
//////////////////////
// Instantiate ALU //
////////////////////
alu iALU(.clk(clk), .src0(src0), .src1(src1), .shamt(instr_ID_EX[3:0]), .func(alu_func_ID_EX),
         .dst(dst_ID_EX), .dst_EX_DM(dst_EX_DM), .ov(ov), .zr(zr), .neg(neg));		   
//////////////////////////////
// Instantiate data memory //
////////////////////////////
// addr only use lower 13 bits because it's a 8KB DM
DM iDM(.clk(clk),.addr(dst_EX_DM[12:0]), .re(dm_re_EX_DM), .we(DM_we), .wrt_data(p0_EX_DM),
       .rd_data(dm_rd_data_EX_DM));

//////////////////////////
// Instantiate dst mux //
////////////////////////
dst_mux iDSTMUX(.clk(clk), .dm_re_EX_DM(dm_re_EX_DM), .dm_rd_data_EX_DM(dst_mux_data_in),
                .dst_EX_DM(dst_EX_DM), .pc_EX_DM(pc_EX_DM), .rf_w_data_DM_WB(rf_w_data_DM_WB),
				.jmp_imm_EX_DM(jmp_imm_EX_DM));
	
/////////////////////////////////////////////
// Instantiate branch determination logic //
///////////////////////////////////////////
br_bool iBRL(.clk(clk), .rst_n(rst_n), .clk_z_ID_EX(clk_z_ID_EX), .clk_nv_ID_EX(clk_nv_ID_EX),
             .br_instr_ID_EX(br_instr_ID_EX), .jmp_imm_ID_EX(jmp_imm_ID_EX),
			 .jmp_reg_ID_EX(jmp_reg_ID_EX), .cc_ID_EX(cc_ID_EX), .zr(zr), .ov(ov),
			 .zr_EX_DM(zr_EX_DM), .neg(neg), .flow_change_ID_EX(flow_change_ID_EX));	
	   
endmodule
