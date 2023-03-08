# The purpose of this asm to test the translation for every single command
ADD R31, R0, R15
ADDZ R1, R2, R3
SUB R31, R30, R29
AND R4, R5, R6
NOR R7, R7, R7

SLL R1, R31, 19
SRL R30, R2, 0x1F
SRA R1, R2, 15

LW R16, R16, 0xFF
SW R17, R19, 0

LHB R9, 0xDEAD
LLB R9, 0xBEEF

B neq, TEST
B eq, TEST
B GT, TEST
B LT, TEST
B GTE, TEST
B LTE, TEST
B OVFL, TEST
B UNCOND, TEST

JAL test




TEST:

JR R5

LWI R1, R2, 255

PUSH R2
POP R3

MUL R1, R2, R31
UMUL R7, R8, R9
ADDF R10, R11, R12
SUBF R13, R14, R15
MULF R16, R17, R18
ITF R19, R20
FTI R21, R22

HLT

