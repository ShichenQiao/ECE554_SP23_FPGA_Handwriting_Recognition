##############################################
#
#	A function call to a conv layer
#       5x5 kernel, 1 stride
#
#	Params:
#	R2 - pointer to kernel matrix
#	R3 - pointer of image matrix
#       R4 - out address (Data memory)
#	R5 - out channel length
#       
#
#	Return:
#	None
#
#	Reg Usage:
#	R1 - 1
#	R4 - intermediate mult result store address
#	R6 - image pixel value
#	R7 - weight value
#	R8 - multiplication result
#
################################################

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

LW R6, R2, 0
LW R7, R3, 0




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
# R30 <- 0x00000000
ADD		R30, R0, R0
# restore R5
POP		R5

# additions
SEQ_ADD:
LW		R8, R4, 0
ADD		R30, R30, R8

# loop back when not finished
SUB		R5, R5, R1
B		NEQ, SEQ_ADD

# restore saved registers
POP	R8
POP	R7
POP	R6
POP	R5
POP	R4
POP	R3
POP	R2