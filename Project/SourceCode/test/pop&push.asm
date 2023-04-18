#################################
##Test POP/PUSH basic function ##
#################################
LLB		R1, 0x5678
LHB		R1, 0x1234		# R1 contains 0x12345678
LLB		R2, 0x5678
LHB		R2, 0x1234		# R2 contains 0x12345678
PUSH	R1
ADDI	R1, 0x78
SUBI	R1, 0xCD		# alter R1 content
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