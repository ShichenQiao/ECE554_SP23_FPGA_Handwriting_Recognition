
LLB R1, 1
LLB R2, 100
LLB R3, 200
LLB R4, 4  # old value, should stay same
LLB R5, 3  # each matrix is 3 values
LLB R6, 4  # should give 4 results
LLB R7, 7
LLB R8, 8

LLB R30, 0

# initialize weight matrix and image matrix

SW R8, R2, 0
SW R8, R2, 1
SW R8, R2, 2
SW R8, R2, 3
SW R8, R2, 4
SW R8, R2, 5
SW R8, R2, 6
SW R8, R2, 7
SW R8, R2, 8
SW R8, R2, 9
SW R8, R2, 10
SW R8, R2, 11

SW R7, R3, 0
SW R7, R3, 1
SW R7, R3, 2
MATRIX_LOOP:
# Call matrix multiplication and store result to DM
JAL		MATRIX_MUL
SW		R29, R30, 0
ADD		R30, R30, R1
ADD		R2, R2, R5

# loop back when not finished
SUB		R6, R6, R1
B		NEQ, MATRIX_LOOP

HLT


###########################################################
# MATRIX_MUL:
#	A function call to a matrix calculation.
#	This is NOT a tree-adder implementation.
#	This function does callee-save.
#
#	Params:
#	R2 - pointer to weight matrix
#	R3 - pointer of image matrix
#	R5 - matrix size
#
#	Return:
#	R29 - result of matrix calculation	
#
#	Reg Usage:
#	R1 - 1
#	R4 - intermediate mult result store address
#	R6 - image pixel value
#	R7 - weight value
#	R8 - multiplication result
#
###########################################################
MATRIX_MUL:
# callee-save
PUSH	R2
PUSH	R3
PUSH	R4
PUSH	R5
PUSH	R6
PUSH	R7
PUSH	R8

# save R5 for later use
PUSH	R5

# R4 <- 0x00000000
ADD		R4, R0, R0

# multiplications
MUL_LOOP:
LW		R6, R3, 0
LW		R7, R2, 0
ITF		R6, R6
MULF	R8, R6, R7
SW		R8, R4, 0

# increment pointers
ADD		R2, R2, R1
ADD		R3, R3, R1
ADD		R4, R4, R1

# loop back when not finished
SUB		R5, R5, R1
B		NEQ, MUL_LOOP

# R4 <- 0x00000000
ADD		R4, R0, R0
# R29 <- 0x00000000
ADD		R29, R0, R0
# restore R5
POP		R5

# additions
SEQ_ADD:
LW		R8, R4, 0
ADD		R29, R29, R8

# loop back when not finished
SUB		R5, R5, R1
B		NEQ, SEQ_ADD

# restore saved registers
POP		R8
POP		R7
POP		R6
POP		R5
POP		R4
POP		R3
POP		R2

JR		R31