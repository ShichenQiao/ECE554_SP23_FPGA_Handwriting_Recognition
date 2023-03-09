LLB R1, 0x1234
LLB R2, 0xABCD
PUSH R1
PUSH R2

POP R3   # should receive 0xABCD
POP R4   # should receive 0x1234