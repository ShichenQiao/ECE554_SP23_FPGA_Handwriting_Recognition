###########################################################
# MAIN:
#   R0 - hard-wired 0
# 	R1 - snapshot trigger
# 	R2 - pointer to weight ROM
# 	R3 - pointer of image MEM
# 	R4 - input matrix size
# 	R5 - output matrix size
#	R6 - convolution input channel length
#	R7 - convolution output channel length
# 	R27 - Snapshot status
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
LW		R27, R30, 8					# get the snapshot request status
SUBI	R27, R27, 1					# check if it is one
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

###########################
# First Convolution Layer #
###########################

# Load R2 with 0x00020000, starting address of kernels for this layer
LLB		R2, 0
LHB		R2, 2

# Load R3 with 0, input image is stored in DM 0 ~ 1023
LLB		R3, 0

# Load R4 with 32 since the pre-processed image is 32 by 32
LLB		R4, 32

# Input channel length of this layer is 1
LLB		R6, 1

# Output channel length of this layer is 6
LLB		R7, 6

# Store outputs to DM 1024 through 5727
LLB		R29, 1024

JAL		CONV

###############################
# First Average Pooling Layer #
###############################


############################
# Second Convolution Layer #
############################
# Load R2 with 0x00020096, starting address of kernels for this layer
LLB		R2, 0x96
LHB		R2, 2

# Load R3 with 5728, input image of this layer is stored in DM 5728 ~ 6903
LLB		R3, 5728

# Load R4 with 14 since the input image is 14 by 14
LLB		R4, 14

# Input channel length of this layer is 6
LLB		R6, 6

# Output channel length of this layer is 16
LLB		R7, 16

# Store outputs to DM 0 through 1599
LLB		R29, 1599

JAL		CONV

################################
# Second Average Pooling Layer #
################################



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
B		GTE, BYPASS_RELU_NN1
LLB		R28, 0
BYPASS_RELU_NN1:
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
B		GTE, BYPASS_RELU_NN2
LLB		R28, 0
BYPASS_RELU_NN2:
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



##############################################
# CONV:
#	A function call to a conv layer
#       5x5 kernel, 1 stride
#
#	Params:
#       R2 - addr_kernel (start address of kernel)
#       R3 - addr_image (start address of image)
#       R4 - side_length_input (input side_length)
#       R6 - in_channel_length (repeat the convolution calculation for multiple images with the same kernel)
#       R7 - out_channel_length (repeat the convolution calculation for same image with different kernels)
#       R29 - addr_output (start addres of output address, increase by one when a pixel is calcuated)
#
#	Return:
#	None
#
#	Internal Reg Usage:
#       R4 - side_length_output, same reg as input (will set to side_length_input - 4 to reflect the output side_length)
#       R8 - x_result, x location of output iamges ( start as 0, increase by one one a pixel is calcuated. set to 0 when reach side_length_output)
#       R9 - y_result, y location of output iamges ( start as 0, increase by one when x_result reaches side_length_output )
#       R10 - pix_sum (sum of result at a result_pix)
#       R11~R15 - 5 weight registers (shared between all 25 weights)
#       R16~R20 - 5 pix registers (shared between 25 pixels, it also stores the mult result)
#       R21 - image_length (use this jump distance to switch between input channels)
#       R22 - base (a temp base location for pixel load)
#       R23 - temp (intermediate for base address calculation
#       R24 - channel_id (a downcounter for keep track of the channel id in process)
#
################################################
# major mechanism for pix calcualtion
###############################################################################################################################################
# to get the result_pix[y][x] at channel_id: (y is the vetical location of output pixel, x is the horizontal location of output pixel)        #
#                                                                                                                                             #
# mult the image_pix with kernel                                                                                                              #
# image_pixs are at:                                                                                                                          #
#  addr_image[(side_length_output*(y+0)+x+channel_id*image_length)~(side_length_output*(y+0)+x+4+channel_id*image_length),                    #
#             (side_length_output*(y+1)+x+channel_id*image_length)~(side_length_output*(y+1)+x+4+channel_id*image_length),                    #
#             (side_length_output*(y+2)+x+channel_id*image_length)~(side_length_output*(y+2)+x+4+channel_id*image_length),                    #
#             (side_length_output*(y+3)+x+channel_id*image_length)~(side_length_output*(y+3)+x+4+channel_id*image_length),                    #
#             (side_length_output*(y+4)+x+channel_id*image_length)~(side_length_output*(y+4)+x+4+channel_id*image_length)]                    #
###############################################################################################################################################
CONV:
# callee-save
PUSH R2
PUSH R3
PUSH R4
PUSH R6
PUSH R7
PUSH R8
PUSH R9
PUSH R10
PUSH R11
PUSH R12
PUSH R13
PUSH R14
PUSH R15
PUSH R16
PUSH R17
PUSH R18
PUSH R19
PUSH R20
PUSH R21
PUSH R22
PUSH R23
PUSH R24
PUSH R29

# set image_length to be (side_length_input * side_length_input)
MUL R21, R4, R4

# set side_length_putput to be (side_length_input - kernel_size + 1)
SUBI R4, R4, 4

# set x_result, y_result before process one image/filter
ADD R8, R0, R0
ADD R9, R0, R0

# Before process one pixel, the x_result, y_result, addr_output, addr_kernel, side_length_output must be set correctly
PIX_PROC:

# reset pix_sum 
ADD R10, R0, R0

# get weight0-4
LW R11, R2,0
LW R12, R2,1
LW R13, R2,2
LW R14, R2,3
LW R15, R2,4

# get pix0-4 from all input channels, add process five values from each channel at a time
SUBI R24, R6, 1               # get zero-based channel-id, used as a down counter
PIX0_4:
# base = addr_image[(y+0) * side_length_output + x + channel_id*image_length]
ADDI R22, R9, 0                              
MUL R22, R22, R4
ADD R22, R22, R8
MUL R23, R24, R21
ADD R22, R22, R23
ADD R22, R22, R3

LW R16, R22, 0
LW R17, R22, 1
LW R18, R22, 2
LW R19, R22, 3
LW R20, R22, 4

MULF R16, R11, R16            # store the mult result at pix[n] to avoid dependency
MULF R17, R12, R17
ADDF R10, R10, R16
MULF R18, R13, R18
ADDF R10, R10, R17
MULF R19, R14, R19
ADDF R10, R10, R18
MULF R20, R15, R20
ADDF R10, R10, R19
ADDF R10, R10, R20       #unavoidable dependency 
SUBI R24, R24, 1
B GTE, PIX0_4             # if there are more channels to process, process them. 


# get weight5-9
LW R11, R2,5
LW R12, R2,6
LW R13, R2,7
LW R14, R2,8
LW R15, R2,9

# get pix5-9 from all input channels, add process five values from each channel at a time
SUBI R24, R6, 1               # get zero-based channel-id, used as a down counter
PIX5_9:
# base = addr_image[(y+1) * side_length_output + x + channel_id*image_length]
ADDI R22, R9, 1                              
MUL R22, R22, R4
ADD R22, R22, R8
MUL R23, R24, R21
ADD R22, R22, R23
ADD R22, R22, R3

LW R16, R22, 0
LW R17, R22, 1
LW R18, R22, 2
LW R19, R22, 3
LW R20, R22, 4

MULF R16, R11, R16            # store the mult result at pix[n] to avoid dependency
MULF R17, R12, R17
ADDF R10, R10, R16
MULF R18, R13, R18
ADDF R10, R10, R17
MULF R19, R14, R19
ADDF R10, R10, R18
MULF R20, R15, R20
ADDF R10, R10, R19
ADDF R10, R10, R20       #unavoidable dependency 
SUBI R24, R24, 1
B GTE, PIX5_9             # if there are more channels to process, process them. 

# get weight10-14
LW R11, R2,10
LW R12, R2,11
LW R13, R2,12
LW R14, R2,13
LW R15, R2,14

# get pix10-14 from all input channels, add process five values from each channel at a time
SUBI R24, R6, 1               # get zero-based channel-id, used as a down counter
PIX10_14:
# base = addr_image[(y+2) * side_length_output + x + channel_id*image_length]
ADDI R22, R9, 2                              
MUL R22, R22, R4
ADD R22, R22, R8
MUL R23, R24, R21
ADD R22, R22, R23
ADD R22, R22, R3

LW R16, R22, 0
LW R17, R22, 1
LW R18, R22, 2
LW R19, R22, 3
LW R20, R22, 4

MULF R16, R11, R16            # store the mult result at pix[n] to avoid dependency
MULF R17, R12, R17
ADDF R10, R10, R16
MULF R18, R13, R18
ADDF R10, R10, R17
MULF R19, R14, R19
ADDF R10, R10, R18
MULF R20, R15, R20
ADDF R10, R10, R19
ADDF R10, R10, R20       #unavoidable dependency 
SUBI R24, R24, 1
B GTE, PIX10_14             # if there are more channels to process, process them. 

# get weight15-19
LW R11, R2,15
LW R12, R2,16
LW R13, R2,17
LW R14, R2,18
LW R15, R2,19

# get pix15-19 from all input channels, add process five values from each channel at a time
SUBI R24, R6, 1               # get zero-based channel-id, used as a down counter
PIX15_19:
# base = addr_image[(y+3) * side_length_output + x + channel_id*image_length]
ADDI R22, R9, 3                              
MUL R22, R22, R4
ADD R22, R22, R8
MUL R23, R24, R21
ADD R22, R22, R23
ADD R22, R22, R3

LW R16, R22, 0
LW R17, R22, 1
LW R18, R22, 2
LW R19, R22, 3
LW R20, R22, 4

MULF R16, R11, R16            # store the mult result at pix[n] to avoid dependency
MULF R17, R12, R17
ADDF R10, R10, R16
MULF R18, R13, R18
ADDF R10, R10, R17
MULF R19, R14, R19
ADDF R10, R10, R18
MULF R20, R15, R20
ADDF R10, R10, R19
ADDF R10, R10, R20       #unavoidable dependency 
SUBI R24, R24, 1
B GTE, PIX15_19             # if there are more channels to process, process them. 

# get weight20-24
LW R11, R2,20
LW R12, R2,21
LW R13, R2,22
LW R14, R2,23
LW R15, R2,24

# get pix20-24 from all input channels, add process five values from each channel at a time
SUBI R24, R6, 1               # get zero-based channel-id, used as a down counter
PIX20_24:
# base = addr_image[(y+4) * side_length_output + x + channel_id*image_length]
ADDI R22, R9, 4                              
MUL R22, R22, R4
ADD R22, R22, R8
MUL R23, R24, R21
ADD R22, R22, R23
ADD R22, R22, R3

LW R16, R22, 0
LW R17, R22, 1
LW R18, R22, 2
LW R19, R22, 3
LW R20, R22, 4

MULF R16, R11, R16            # store the mult result at pix[n] to avoid dependency
MULF R17, R12, R17
ADDF R10, R10, R16
MULF R18, R13, R18
ADDF R10, R10, R17
MULF R19, R14, R19
ADDF R10, R10, R18
MULF R20, R15, R20
ADDF R10, R10, R19
ADDF R10, R10, R20       #unavoidable dependency 
SUBI R24, R24, 1
B GTE, PIX20_24             # if there are more channels to process, process them. 

# store the result at location [y][x], and update x, y, addr_output
ADDF R10, R10, R0
B GTE, BYPASS_RELU_CONV
LLB R10, 0
BYPASS_RELU_CONV:
SW R10, R29, 0
ADDI R29, R29, 1
SUB R23, R8, R4
B NEQ, NOT_SWITCH_LINE                      #if the x does not reach the end of the line, do not increment line
SUB R23, R9, R4
B EQ, DONE_ONE_CHANNEL                  # if x_result reaches the end and y_result reaches the end, all pixels are computed for one channel
ADD R8, R0, R0         # reset x to 0 and increment y
ADDI R9, R9, 1
B UNCOND, PIX_PROC      # work on the next pix

NOT_SWITCH_LINE:
ADDI R8, R8, 1
B UNCOND, PIX_PROC      # work on the next pix

DONE_ONE_CHANNEL:
SUBI R7, R7, 1
B EQ, DONE_CONV
#update the kernel and reprocess the entire image
ADDI R2, R2, 25
ADD R8, R0, R0
ADD R9, R0, R0
B UNCOND, PIX_PROC

DONE_CONV:
# restore all registers and return
POP R29
POP R24
POP R23
POP R22
POP R21
POP R20
POP R19
POP R18
POP R17
POP R16
POP R15
POP R14
POP R13
POP R12
POP R11
POP R10
POP R9
POP R8
POP R7
POP R6
POP R4
POP R3
POP R2

JR R31



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
