###########################################################
# MAIN:
# 	R1 - 1
# 	R2 - pointer to weight matrix
# 	R3 - pointer of image matrix
# 	R4 - pointer to DM
# 	R5 - loop index
# 	R6 - matrix index
# 	R20 - loop number 9 (i <= 9)
# 	R21 - current number
# 	R22 - current number - current max
# 	R23 - 9 - i
# 	R24 - current max
# 	R25 - current max index
# 	R26 - Snapshot status
# 	R27 - 0x00000030 ASCII number offset
# 	R28 - 0x0000C000 base address of peripherals
# 	R29 - reserved for result of matrix multiplication
# 	R30 - result pointer, results will be in DM at addr = 1000 through 1009
#	R31 - reserved for JAL/JR
#
###########################################################

#################
# HARDWARE INIT #
#################

# Load R1 with 1
LLB		R1, 1

# load R28 with 0x0000C000
LLB		R28, 0xC000
LHB		R28, 0x0000

CLASSIFY:
SW		R1, R28, 8					# send one snapshot request
SNAPSHOT_WAIT:
LW		R26, R28, 8					# get the snapshot request status
SUB		R26, R26, R1				# check if it is one
B		NEQ, SNAPSHOT_WAIT			# if the status is still 1(meaning waiting for snapshot), then keep waiting

####################
# RESTORE POINTERS #
####################

# Load R2 with 0x00020000
LLB		R2, 0
LHB		R2, 2

# Load R3 with 0x00010000
LLB		R3, 0
LHB		R3, 1

# Load R4 with 0x00000000
LLB		R4, 0

# Load R5 with 784
LLB		R5, 784

# Load R6 with 10
LLB		R6, 10

# Load R30 with 1000
LLB		R30, 1000

#########################
# MATRIX MULTIPLY STAGE #
#########################

MATRIX_LOOP:
# Call matrix multiplication and store result to DM
JAL		MATRIX_MUL
SW		R29, R30, 0
ADD		R30, R30, R1
ADD		R2, R2, R5

# loop back when not finished
SUB		R6, R6, R1
B		NEQ, MATRIX_LOOP

# Load R30 with 1000 for the output stage
LLB		R30, 1000

##############################
# CLASIFICATION OUTPUT STAGE #
##############################

# load 0x00000030 into R27
LLB		R27, 0x0030
# load negative infinity into R24
LLB		R24, 0x0000
LHB		R24, 0xFF80
# initialize R25 to 0
ADD		R25, R0, R0
# load 0 into R5
LLB		R5, 0x0000
# load 9 into R20
LLB		R20, 0x0009

# load next number
LOAD_NEXT:
SUB		R23, R20, R5
B		LT, DONE
LW		R21, R30, 0
SUBF	R22, R21, R24			# result in POS_INF at the first time
B		GT, NEW_MAX
ADD		R5, R5, R1				# increment loop index
ADD		R30, R30, R1			# increment address
B		UNCOND, LOAD_NEXT

# when current number > current max
# current max <- current number
# current max index <- loop index
NEW_MAX:
ADD		R24, R21, R0
ADD		R25, R5, R0
ADD		R5, R5, R1				# increment loop index
ADD		R30, R30, R1			# increment address
B		UNCOND, LOAD_NEXT

# max found, print to SPART
DONE:
ADD		R25, R25, R27			# R25 <- R25 + 0x0030
SW		R25, R28, 4				# print to SPART

B		UNCOND, CLASSIFY



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
ADDF	R29, R29, R8

# increment pointer
ADD		R4, R4, R1

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