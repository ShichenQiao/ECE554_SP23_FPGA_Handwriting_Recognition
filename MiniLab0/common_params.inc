
///////////////////////////////////////
// Create defines for ALU functions //
/////////////////////////////////////
localparam ADD	= 3'b000;
localparam SUB 	= 3'b001;
localparam AND	= 3'b010;
localparam NOR	= 3'b011; 
localparam SLL	= 3'b100;
localparam SRL	= 3'b101;
localparam SRA	= 3'b110;
localparam LHB  = 3'b111;

//////////////////////////////////////////
// Create defines for Opcode encodings //
////////////////////////////////////////
localparam ADDi 	= 4'b0000;
localparam ADDZi 	= 4'b0001;
localparam SUBi 	= 4'b0010;
localparam ANDi		= 4'b0011;
localparam NORi		= 4'b0100;
localparam SLLi		= 4'b0101;
localparam SRLi		= 4'b0110;
localparam SRAi		= 4'b0111;
localparam LWi		= 4'b1000;
localparam SWi		= 4'b1001;
localparam LHBi		= 4'b1010;
localparam LLBi		= 4'b1011;
localparam BRi		= 4'b1100;
localparam JALi		= 4'b1101;
localparam JRi		= 4'b1110;
localparam HLTi		= 4'b1111;

////////////////////////////////
// Encodings for src0 select //
//////////////////////////////
localparam RF2SRC0 	= 2'b00;
localparam IMM_BR2SRC0 = 2'b01;			// 7-bit SE for branch target
localparam IMM_JMP2SRC0 = 2'b10;		// 12-bit SE for jump target
localparam IMM2SRC0 = 2'b11;			// 4-bit SE Address immediate for LW/SW

////////////////////////////////
// Encodings for src1 select //
//////////////////////////////
localparam RF2SRC1	= 2'b00;
localparam IMM2SRC1 = 2'b01;			// 8-bit data immediate for LLB/LHB
localparam NPC2SRC1 = 2'b10;			// nxt_pc to src1 for JAL instruction



