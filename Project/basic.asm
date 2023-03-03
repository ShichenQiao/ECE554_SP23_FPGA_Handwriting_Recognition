LLB	R30, 0x0001	//r30 <- 00000001
LHB	R30, 0x0000
LLB	R1, 0x0000	//r1 <- 00000000
LHB	R1, 0x0000
LLB	R2, 0x0100	//r2 <- 00000000
LHB	R2, 0x0000

//load data

LLB	R3, 0x0001	//r3 <- 00000001
SW	R3, R1, 0	//r3 -> mem[r1+0]

ADD	R3, R3, 1	//r3 <- 00000002
SW	R3, R1, 1	//r3 -> mem[r1+1]

ADD	R3, R3, 1	//r3 <- 00000003
SW	R3, R1, 2	//r3 -> mem[r1+2]

ADD	R3, R3, 1	//r3 <- 00000004
SW	R3, R1, 3	//r3 -> mem[r1+3]

ADD	R3, R3, 1	//r3 <- 00000005
SW	R3, R1, 4	//r3 -> mem[r1+4]

ADD	R3, R3, 1	//r3 <- 00000006
SW	R3, R1, 5	//r3 -> mem[r1+5]

ADD	R3, R3, 1	//r3 <- 00000007
SW	R3, R1, 6	//r3 -> mem[r1+6]

ADD	R3, R3, 1	//r3 <- 00000008
SW	R3, R1, 7	//r3 -> mem[r1+7]

//load input
LLB	R4, 0x1111	//r4 <- 0x11111111
LHB	R4, 0x1111

//MUL & UMUL
LW	R3, R1, 3	//r3 <- 4
MUL	R4, R4, R3	//r4 <- r4*r3 = 0x44444444
LW	R3, R1, 1	//r3 <- 2
UMUL	R4, R4, R3	//r4 <- r4*r3 = 0x88888888



