###########################################################
# MAIN:
#   R0 - hard-wired 0
# 	R1 - snapshot trigger
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
# CNN Architecture (LeNet-Like Structure)
#	Input image after hardware compression -> 28 (height) * 28 (width) * 1 (channel)
#	(Hardware) Padding 2 pixels on each of the 4 sides -> 32 * 32 * 1
#	Convolution with 5 * 5 * 6 kernels -> 28 * 28 * 6
#	ReLU activation
#	Average pooling with 2 * 2 kernels and stride=2 -> 14 * 14 * 6
#	Convolution with 5 * 5 * 16 kernels -> 10 * 10 * 16
#	ReLU activation
#	Average pooling with 2 * 2 kernels and stride=2 -> 5 * 5 * 16
#	(Implicit) Flatten -> 1 * 400
#	120 Fully connected neurons -> 1 * 120
#	ReLU activation
#	84 Fully connected neurons -> 1 * 84
#	ReLU activation
#	10 Fully connected neurons -> 1 * 10
#	Output = 1 of 10 classes
#
# Data Memory Usage:
#	0 ~ 1023 - Preprocessed input image after HW padding (2 on each side)
#	1024 ~ 5727 - Output of first convolution layer
#	5728 ~ 6903 - Output of first pooling layer
#	(reusage start)
#	0 ~ 1599 - Output of second convolution layer
#	1600 ~ 1999 - Output of second pooling layer
#	2000 ~ 2119 - Output of first full NN layer
#	2120 ~ 2203 - Output of first full NN layer
#	(reusage end)
#	6950 ~ 7973 - Workzone for matrix multiplications
#	8000 ~ 8009 - Final Scores of the 10 classes
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
SUBI	R6, R6, 1					# check if it is one
B		NEQ, SNAPSHOT_WAIT			# if the status is still 1(meaning waiting for snapshot), then keep waiting

###############
# Pre Process #
###############

# Load R3 with 0x00010000, input image is stored in image mem
LLB		R3, 0
LHB		R3, 1

# Load R4 with 1024, input dimension of the input layer is 1024 (32 * 32 padded image)
LLB		R4, 1024

JAL		PRE_PROCESS

###############
# Input Layer #
###############

# Load R2 with 0x00020000, input weight of the input layer is stored in weight rom
LLB		R2, 0
LHB		R2, 2

# Load R3 with 0, input image of the input layer is stored in DM 0 ~ 1023
LLB		R3, 0









#################
# 400 -> 120 NN #
#################

# Load R3 with 1600, input image of this layer is stored in DM 1600 through 1999
LLB		R3, 1600

# Load R4 with 400, input dimension of this layer is 400
LLB		R4, 400

# Load R5 with 120, output dimension of this layer is 120
LLB		R5, 120

# Load R29 with 2000, outputs of this layer are stored at DM 2000 through 2119
LLB		R29, 2000

NN1_LOOP:
# Call matrix multiplication and store result to DM
JAL		MATRIX_MUL
ADDF	R28, R28, R0
B		GTE, BYPASS_RELU3
LLB		R28, 0
BYPASS_RELU3:
SW		R28, R29, 0
ADDI	R29, R29, 1
ADD		R2, R2, R4

# loop back when not finished
SUBI	R5, R5, 1
B		NEQ, NN1_LOOP

################
# 120 -> 84 NN #
################

# Load R3 with 2000, input image of this layer is stored in DM 2000 through 2119
LLB		R3, 2000

# Load R4 with 120, input dimension of this layer is 120
LLB		R4, 120

# Load R5 with 84, output dimension of this layer is 84
LLB		R5, 84

# Load R29 with 2120, outputs of this layer are stored at DM 2120 through 2203
LLB		R29, 2120

NN2_LOOP:
# Call matrix multiplication and store result to DM
JAL		MATRIX_MUL
ADDF	R28, R28, R0
B		GTE, BYPASS_RELU4
LLB		R28, 0
BYPASS_RELU4:
SW		R28, R29, 0
ADDI	R29, R29, 1
ADD		R2, R2, R4

# loop back when not finished
SUBI	R5, R5, 1
B		NEQ, NN2_LOOP

###############
# 84 -> 10 NN #
###############

# Load R3 with 2120, input image of this layer is stored in DM 2120 through 2203
LLB		R3, 2120

# Load R4 with 84, input dimension of this layer is 84
LLB		R4, 84

# Load R5 with 10, output dimension of this layer is 10
LLB		R5, 10

# Load R29 with 8000 to store final output scores at DM 8000 through 8009
LLB		R29, 8000

NN3_LOOP:
# Call matrix multiplication and store result to DM
JAL		MATRIX_MUL
SW		R28, R29, 0
ADDI	R29, R29, 1
ADD		R2, R2, R4

# loop back when not finished
SUBI	R5, R5, 1
B		NEQ, NN3_LOOP

################
# OUTPUT LAYER #
################

# Load R29 with 8000, final Scores of the 10 classes are stored in DM 8000 through 8009
LLB		R29, 8000

JAL		OUTPUT_LAYER

B		UNCOND, CLASSIFY



###########################################################
# PRE_PROCESS:
#	Convert image from int to FP format.
#	Reading from image mem, writing to DM 0 ~ 1023
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

# load R5 with 0, so that pre-processed image is stored at DM 0 ~ 1023
LLB		R5, 0

PRE_LOOP:
LW		R6, R3, 0
ITF		R6, R6
SW		R6, R5, 0

# increment pointers
ADDI	R3, R3, 1
ADDI	R5, R5, 1

# loop back when not finished
SUBI	R4, R4, 1
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

# load R5 with 6950, pointing to work zone at DM 6950 ~ 7973
LLB		R5, 6950

# multiplications
MUL_LOOP:
LW		R6, R3, 0
LW		R7, R2, 0
MULF	R8, R6, R7
SW		R8, R5, 0

# increment pointers
ADDI	R2, R2, 1
ADDI	R3, R3, 1
ADDI	R5, R5, 1

# loop back when not finished
SUBI	R4, R4, 1
B		NEQ, MUL_LOOP

# load R5 with 6950, pointing to work zone at DM 6950 ~ 7973
LLB		R5, 6950
# R28 <- 0x00000000
LLB		R28, 0
# restore R4
POP		R4

# additions
SEQ_ADD:
LW		R8, R5, 0
ADDF	R28, R28, R8

# increment pointer
ADDI	R5, R5, 1

# loop back when not finished
SUBI	R4, R4, 1
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
LLB		R8, 0
# load 0 into R2
LLB		R2, 0x0000
# load 9 into R3
LLB		R3, 0x0009

# load next number
LOAD_NEXT:
SUB		R6, R3, R2
B		LT, DONE
LW		R4, R29, 0
SUBF	R5, R4, R7					# result in POS_INF at the first time
B		GT, NEW_MAX
ADDI	R2, R2, 1					# increment loop index
ADDI	R29, R29, 1					# increment address
B		UNCOND, LOAD_NEXT

# when current number > current max
# current max <- current number
# current max index <- loop index
NEW_MAX:
ADD		R7, R4, R0
ADD		R8, R2, R0
ADDI	R2, R2, 1					# increment loop index
ADDI	R29, R29, 1					# increment address
B		UNCOND, LOAD_NEXT

# max found, print to SPART
DONE:
ADD		R8, R8, R9					# R8 <- R8 + 0x0030
SW		R8, R30, 4					# print to SPART

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
