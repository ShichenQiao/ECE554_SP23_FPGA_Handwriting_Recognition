
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
localparam ADDi 	= 5'b00000;
localparam ADDZi 	= 5'b00001;
localparam SUBi 	= 5'b00010;
localparam ANDi		= 5'b00011;
localparam NORi		= 5'b00100;
localparam SLLi		= 5'b00101;
localparam SRLi		= 5'b00110;
localparam SRAi		= 5'b00111;
localparam LWi		= 5'b01000;
localparam SWi		= 5'b01001;
localparam LHBi		= 5'b01010;
localparam LLBi		= 5'b01011;
localparam BRi		= 5'b01100;
localparam JALi		= 5'b01101;
localparam JRi		= 5'b01110;
localparam HLTi		= 5'b01111;

////////////////////////////////
// Encodings for src0 select //
//////////////////////////////
localparam RF2SRC0 	= 2'b00;
localparam IMM_BR2SRC0 = 2'b01;			// 12-bit SE for branch target
localparam IMM_JMP2SRC0 = 2'b10;		// 12-bit SE for jump target
localparam IMM2SRC0 = 2'b11;			// 8-bit SE Address immediate for LW/SW

////////////////////////////////
// Encodings for src1 select //
//////////////////////////////
localparam RF2SRC1	= 2'b00;
localparam IMM2SRC1 = 2'b01;			// 16-bit data immediate for LLB/LHB
localparam NPC2SRC1 = 2'b10;			// nxt_pc to src1 for JAL instruction



