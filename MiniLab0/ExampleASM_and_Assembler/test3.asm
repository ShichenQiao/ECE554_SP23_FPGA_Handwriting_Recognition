llb R1,0x04
Add R2,R1,R1
llb R3,0x7f
sw R2,R3,0
lw R4,R3,0
jr R4
hlt
add R5,R4,R4
JAl d1
d1:	
B eq,Dead
addz R6,R0,R0
B neq,Dead
addz R7,R4,R4
b eq,Dead
and R8,R7,R3
sll R9,R8,2
SRA R10,R9,2
SRL R11,R10,3
nor R12,R11,R10
sw R12,R3,0
JAL d2
hlt

Dead:
llb R15,0xef
lhb R15,0xbe
hlt

d2:
lw R15,R3,0
jr R15
hlt