#################################
##Test POP/PUSH basic function ##
#################################
LLB		R1, 0x5678
LHB		R1, 0x1234		# R1 contains 0x12345678
LLB		R2, 0x5678
LHB		R2, 0x1234		# R2 contains 0x12345678
PUSH	R1
ADDI	R1, R1, 0x78
SUBI	R1, R1, 0xCD		# alter R1 content
POP		R1
SUB		R3, R1, R2		# R3 should be 0
B		NEQ, L_FAIL

##############################################
## A specific test for a bug we encountered ##
## This code mimics a 2 * 2 average polling ##
##############################################
LLB		R3, 8			# R3 contains 8
LLB		R4, 8			# R4 contains 8
LW		R7, R3, 0		# R7 <- DMem[8]
LW		R8, R3, 1		# R8 <- DMem[9]
PUSH	R3				# push R3 to stack
ADD		R3, R3, R4		# R3 contians 16
LW		R9, R3, 0		# R9 <- DMem[16]
LW		R10, R3, 1		# R10 <- DMem[17]
POP		R3				# restore R3
ADDI	R3, R3, 2		# R3 should be 10 here
						# but it was 2
						# see bypass signals fixes in id stage

#################################
##Multiple POP/PUSH operations ##
#################################
LLB		R2, 0x0222
LLB		R3, 0x0333
LLB		R4, 0x0444
LLB		R5, 0x0555
LLB		R6, 0x0666
LLB		R7, 0x0777
LLB		R8, 0x0888
LLB		R9, 0x0999
# callee-saves
PUSH	R2
PUSH	R3
PUSH	R4
PUSH	R5
PUSH	R6
PUSH	R7
PUSH	R8
PUSH	R9
ADD		R2, R0, R0
ADD		R3, R0, R0
ADD		R4, R0, R0
ADD		R5, R0, R0
ADD		R6, R0, R0
ADD		R7, R0, R0
ADD		R8, R0, R0
ADD		R9, R0, R0
# callee-restores
POP		R9
POP		R8
POP		R7
POP		R6
POP		R5
POP		R4
POP		R3
POP		R2
LLB		R12, 0x0222
LLB		R13, 0x0333
LLB		R14, 0x0444
LLB		R15, 0x0555
LLB		R16, 0x0666
LLB		R17, 0x0777
LLB		R18, 0x0888
LLB		R19, 0x0999
SUB		R2, R2, R12
B		NEQ, L_FAIL
SUB		R3, R3, R13
B		NEQ, L_FAIL
SUB		R4, R4, R14
B		NEQ, L_FAIL
SUB		R5, R5, R15
B		NEQ, L_FAIL
SUB		R6, R6, R16
B		NEQ, L_FAIL
SUB		R7, R7, R17
B		NEQ, L_FAIL
SUB		R8, R8, R18
B		NEQ, L_FAIL
SUB		R9, R9, R19
B		NEQ, L_FAIL
B		UNCOND, L_PASS

#########################
##Pass routine at 0xAD ##
#########################
MEM 0x00AD
L_PASS:
B		UNCOND, L_PASS

#########################
##Fail routine at 0xDD ##
#########################
MEM 0x00DD
L_FAIL:
B		UNCOND, L_FAIL