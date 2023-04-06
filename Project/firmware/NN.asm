###########################################################
# MAIN:
#   R0 - hard-wired 0
# 	R1 - 1
# 	R2 - pointer to weight ROM
# 	R3 - pointer of image MEM
# 	R4 - input matrix size
# 	R5 - output matrix size
# 	R6 - Snapshot status
# 	R28 - reserved for result of matrix multiplication
# 	R29 - DM pointer to output matrix
# 	R30 - 0x0000C000 base address of peripherals
#	R31 - reserved for JAL/JR
#
###########################################################

#################
# HARDWARE INIT #
#################

# Load R1 with 1
LLB		R1, 1

# load R30 with 0x0000C000
LLB		R30, 0xC000
LHB		R30, 0x0000

CLASSIFY:
SW		R1, R30, 8					# send one snapshot request
SNAPSHOT_WAIT:
LW		R6, R30, 8					# get the snapshot request status
SUB		R6, R6, R1					# check if it is one
B		NEQ, SNAPSHOT_WAIT			# if the status is still 1(meaning waiting for snapshot), then keep waiting

###############
# Pre Process #
###############

# Load R3 with 0x00010000, input image is stored in image mem
LLB		R3, 0
LHB		R3, 1

# Load R4 with 784, input dimension of the input layer is 784
LLB		R4, 784

JAL		PRE_PROCESS

###############
# INPUT LAYER #
###############

# Load R2 with 0x00020000, input weight of the input layer is stored in weight rom
LLB		R2, 0
LHB		R2, 2

# Load R3 with 0, input image of the input layer is stored in DM 0 ~ 783
LLB		R3, 0

# Load R5 with 64, output dimension of the input layer is 64
LLB		R5, 64

# Load R29 with 1568 to store middle layer input at DM 1568 through 1631
LLB		R29, 1568

INPUT_LAYER_LOOP:
# Call matrix multiplication and store result to DM
JAL		MATRIX_MUL
SW		R28, R29, 0
ADD		R29, R29, R1
ADD		R2, R2, R4

# loop back when not finished
SUB		R5, R5, R1
B		NEQ, INPUT_LAYER_LOOP

################
# MIDDLE LAYER #
################

# Load R3 with 1568 for the middle layer, input image of the middle layer is stored in DM 1568 through 1631
LLB		R3, 1568

# Load R4 with 64, input dimension of the middle layer is 64
LLB		R4, 64

# Load R5 with 10, output dimension of the middle layer is 10
LLB		R5, 10

# Load R29 with 2000 to store output scores at DM 2000 through 2009
LLB		R29, 2000

MIDDLE_LAYER_LOOP:
# Call matrix multiplication and store result to DM
JAL		MATRIX_MUL
SW		R28, R29, 0
ADD		R29, R29, R1
ADD		R2, R2, R4

# loop back when not finished
SUB		R5, R5, R1
B		NEQ, MIDDLE_LAYER_LOOP

################
# OUTPUT LAYER #
################

# Load R29 with 2000, input image of the output layer is stored in DM 2000 through 2009
LLB		R29, 2000

JAL		OUTPUT_LAYER

B		UNCOND, CLASSIFY



###########################################################
# PRE_PROCESS:
#	Convert image from int to FP format.
#	Reading from image mem, writing to DM 0 ~ 783
#
#	Params:
#	R3 - pointer of image matrix
#	R4 - matrix size
#
#	Return:
#	None	
#
#	Reg Usage:
#	R0 - hard-wired 0
#	R1 - 1
#	R5 - DM pointer
#	R6 - temp reg holding value being converted
#	R31 - reserved for JAL/JR
#
###########################################################
PRE_PROCESS:
# callee-save
PUSH	R3
PUSH	R4
PUSH	R5
PUSH	R6

# load R5 with 0, so that pre-processed image is stored at DM 0 ~ 783
LLB		R5, 0

PRE_LOOP:
LW		R6, R3, 0
ITF		R6, R6
SW		R6, R5, 0

# increment pointers
ADD		R3, R3, R1
ADD		R5, R5, R1

# loop back when not finished
SUB		R4, R4, R1
B		NEQ, PRE_LOOP

POP		R6
POP		R5
POP		R4
POP		R3

JR		R31



###########################################################
# MATRIX_MUL:
#	A function call to a matrix multiplication.
#	This is NOT a tree-adder implementation.
#	This function does callee-save.
#
#	Params:
#	R2 - pointer to weight matrix
#	R3 - pointer of image matrix
#	R4 - matrix size
#
#	Return:
#	R28 - result of matrix multiplication	
#
#	Reg Usage:
#	R0 - hard-wired 0
#	R1 - 1
#	R5 - intermediate mult result store address
#	R6 - image pixel value
#	R7 - weight value
#	R8 - multiplication result
#	R31 - reserved for JAL/JR
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

# save R4 for later use
PUSH	R4

# load R5 with 784, so that DM 0 ~ 783 is preserved for the original input image
LLB		R5, 784

# multiplications
MUL_LOOP:
LW		R6, R3, 0
LW		R7, R2, 0
MULF	R8, R6, R7
SW		R8, R5, 0

# increment pointers
ADD		R2, R2, R1
ADD		R3, R3, R1
ADD		R5, R5, R1

# loop back when not finished
SUB		R4, R4, R1
B		NEQ, MUL_LOOP

# load R5 with 784, so that DM 0 ~ 783 is preserved for the original input image
LLB		R5, 784
# R28 <- 0x00000000
ADD		R28, R0, R0
# restore R4
POP		R4

# additions
SEQ_ADD:
LW		R8, R5, 0
ADDF	R28, R28, R8

# increment pointer
ADD		R5, R5, R1

# loop back when not finished
SUB		R4, R4, R1
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



###########################################################
# OUTPUT_LAYER:
#	A function call to find max score in the output layer
#
#	Params:
#	R29 - base pointer to the output layer
#
#	Return:
#	None
#
#	Reg Usage:
#	R0 - hard-wired 0
#	R1 - 1
#	R2 - loop index i
#	R3 - loop terminate condition = 9
#	R4 - current number
#	R5 - current number - current max
#	R6 - 9 - i
#	R7 - current max
#	R8 - current max index
#	R9 - 0x00000030 ASCII number offset
# 	R30 - 0x0000C000 base address of peripherals
#	R31 - reserved for JAL/JR
#
###########################################################
OUTPUT_LAYER:
# callee-save
PUSH	R2
PUSH	R3
PUSH	R4
PUSH	R5
PUSH	R6
PUSH	R7
PUSH	R8
PUSH	R9
PUSH	R29

# load 0x00000030 into R9
LLB		R9, 0x0030
# load negative infinity into R7
LLB		R7, 0x0000
LHB		R7, 0xFF80
# initialize R8 to 0
ADD		R8, R0, R0
# load 0 into R2
LLB		R2, 0x0000
# load 9 into R3
LLB		R3, 0x0009

# load next number
LOAD_NEXT:
SUB		R6, R3, R2
B		LT, DONE
LW		R4, R29, 0
SUBF	R5, R4, R7				# result in POS_INF at the first time
B		GT, NEW_MAX
ADD		R2, R2, R1				# increment loop index
ADD		R29, R29, R1			# increment address
B		UNCOND, LOAD_NEXT

# when current number > current max
# current max <- current number
# current max index <- loop index
NEW_MAX:
ADD		R7, R4, R0
ADD		R8, R2, R0
ADD		R2, R2, R1				# increment loop index
ADD		R29, R29, R1			# increment address
B		UNCOND, LOAD_NEXT

# max found, print to SPART
DONE:
ADD		R8, R8, R9				# R8 <- R8 + 0x0030
SW		R8, R30, 4				# print to SPART

# restore saved registers
POP		R29
POP		R9
POP		R8
POP		R7
POP		R6
POP		R5
POP		R4
POP		R3
POP		R2

JR		R31
