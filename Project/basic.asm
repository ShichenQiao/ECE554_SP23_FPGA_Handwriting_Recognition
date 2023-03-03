# R0	-	always set to 0, write forbidden
# R1 to R7, R9 are free to use
# R8	-	0xC004 address of memory mapped UART transmission buffer
# R11	-	0xC000 LEDR debug address
# R13	-	masking reg to extract status reg info
# R14	-	stores reading from SPART status reg
# R15	-	jump address

// LLB ASCII
// <ESC>[2J		-	clear screen
LLB	R1, 0x1B		// ESC
LLB	R2, 0x5B		// [
LLB	R3, 0x32		// 2
LLB	R4, 0x4A		// J
// <ESC>[5;5H	-	centering
LLB	R5, 0x35		// 5
LLB	R6, 0x3B		// ;
LLB	R7, 0x48		// H
// UART address
LLB	R8, 0x04
LHB R8, 0xC0		// R8 <- 0xC004
// Masking for tx queue
LLB R13, 0x80
LHB R13, 0x00		// R13 <- 0x0080
// Debug LED address
LLB R11, 0x00
LHB R11, 0xC0
// ST to SPART
SW	R1, R8, 0		// 0xC004 <- R1 ESC
SW	R2, R8, 0		// 0xC004 <- R2 [
SW	R3, R8, 0		// 0xC004 <- R3 2
SW	R4, R8, 0		// 0xC004 <- R4 J
SW	R1, R8, 0		// 0xC004 <- R1 ESC
SW	R2, R8, 0		// 0xC004 <- R2 [
SW	R5, R8, 0		// 0xC004 <- R5 5
SW	R6, R8, 0		// 0xC004 <- R6 ;
SW	R5, R8, 0		// 0xC004 <- R5 5
// Hello World
LLB R2, 0x65		// e
LLB R3, 0x6C		// l
LLB R4, 0x6F		// o
LLB R5, 0x20		// SPACE
LLB R6, 0x57		// W
LLB R9, 0x72		// r
LLB R1, 0x64		// d
// JAL routine waiting and polling
JAL	pollingtx		// jump to polling routine

##################

// ST to SPART
SW	R7, R8, 0		// H
SW	R7, R8, 0		// H
SW	R2, R8, 0		// e
SW	R3, R8, 0		// l
SW	R3, R8, 0		// l
SW	R4, R8, 0		// o
SW	R5, R8, 0		// SPACE
SW	R6, R8, 0		// W
// <CR>Name:<SPACE>
LLB R7, 0x0D		// <CR>
LLB	R10, 0x4E		// N
LLB R5, 0x61		// a
LLB R12, 0x6D		// m
LLB R6, 0x3A		// :
// JAL routine waiting and polling
JAL	pollingtx		// jump to polling routine

##################

// ST to SPART
SW	R4, R8, 0		// o
SW	R9, R8, 0		// r
SW	R3, R8, 0		// l
SW	R1, R8, 0		// d
SW	R7, R8, 0		// <CR>
SW	R10, R8, 0		// N
SW	R5, R8, 0		// a
SW	R12, R8, 0		// m
LLB R5, 0x20		// SPACE
// JAL routine waiting and polling
JAL	pollingtx		// jump to polling routine
// ST to SPART
SW	R2, R8, 0		// e
SW	R6, R8, 0		// :
SW	R5, R8, 0		// <SPACE>

################## Done printing ##################

# R7	-	stores ascii value of <CR>
# R5	-	internal data memory address
# R1	-	stores user input char

LLB	R5, 0x00		// R5 <- 0x0000
// Masking for rx queue, also used to increment index
LLB R13, 0x01		// R13 <- 0x0001

// read stat reg of rx filled entries
pollingrx:
LW	R14, R8, 1		// R14 <- 0xC005 stat reg
AND R12, R13, R14	// R12 <- R14 & 0x0001
B	eq, pollingrx	// rx q empty then loop

// store data in rx queue into internal data memory
LW	R1, R8, 0		// R1 <- 0xC004
SW	R1, R8, 0		// echo input
SW	R1, R5, 0		// DM[R5] <- R1
ADD R5, R5, R13		// R5 <- R5 + 1
SW	R5, R11, 0		// LED <- R5 debug
// loop until user types <CR>
SUB	R2, R1, R7		// compare user input with <CR>
B	neq, pollingrx	// if not, loop back

// user input done, greet user
LLB	R1, 0x48		// H
LLB R2, 0x65		// e
LLB R3, 0x6C		// l
LLB R4, 0x6F		// o
LLB R6, 0x20		// SPACE



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
LLB	R30, 0x0001	//r30 <- 00000001
LHB	R30, 0x0000
LLB	R16, 0x0000	//r16 <- 00000000
LHB	R16, 0x0000
LLB	R17, 0x0100	//r17 <- 00000000
LHB	R17, 0x0000

//load data

LLB	R18, 0x0001	//r18 <- 00000001
SW	R18, R16, 0	//r18 -> mem[r16+0]

ADD	R18, R18, 1	//r18 <- 00000002
SW	R18, R16, 1	//r18 -> mem[r16+1]

ADD	R18, R18, 1	//r18 <- 00000003
SW	R18, R16, 2	//r18 -> mem[r16+2]

ADD	R18, R18, 1	//r18 <- 00000004
SW	R18, R16, 3	//r18 -> mem[r16+3]

ADD	R18, R18, 1	//r18 <- 00000005
SW	R18, R16, 4	//r18 -> mem[r16+4]

ADD	R18, R18, 1	//r18 <- 00000006
SW	R18, R16, 5	//r18 -> mem[r16+5]

ADD	R18, R18, 1	//r18 <- 00000007
SW	R18, R16, 6	//r18 -> mem[r16+6]

ADD	R18, R18, 1	//r18 <- 00000008
SW	R18, R16, 7	//r18 -> mem[r16+7]

//load input
LLB	R19, 0x1111	//r19 <- 0x11111111
LHB	R19, 0x1111

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MUL & UMUL
LW	R18, R16, 3	//r18 <- 4
MUL	R19, R19, R18	//r19 <- r19*r18 = 0x44444444
LLB	R20, 0x4444
LHB	R20, 0x4444
SUB	R20, R20, R19	//r20 <- r20-r19
B	eq, fail
SW	R3, R8, 0		// l
SW	R3, R8, 0		// l
SW	R4, R8, 0		// o


LW	R18, R16, 1	//r18 <- 2
UMUL	R19, R19, R18	//r19 <- r19*r18 = 0x88888888

LLB	R20, 0x8888
LHB	R20, 0x8888
SUB	R20, R20, R19	//r20 <- r20-r19
B	eq, fail
SW	R3, R8, 0		// l
SW	R3, R8, 0		// l
SW	R4, R8, 0		// o



HLT


fail:
SW	R1, R8, 0		// H
SW	R2, R8, 0		// e


// routine to read stat reg of tx available entries & wait
pollingtx:
LW	R14, R8, 1		// R14 <- 0xC005 stat reg
SUB R14, R14, R13	// R14 <- R14 - 0x0080 check if tx q empty
SW	R13, R11, 0		// debug LEDR <- 0x0080
B	lt, pollingtx	// tx q not empty then loop
JR	R15










