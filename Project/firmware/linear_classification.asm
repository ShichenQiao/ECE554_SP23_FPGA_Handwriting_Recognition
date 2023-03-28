# R1 - 1
# R2 - pointer to weight matrix
# R3 - pointer of image matrix
# R4 - pointer to DM
# R5 - loop index
# R16 - reserved for result of matrix multiplication
# R17 -	loop number 9 (i <= 9)
# R18 -	current number
# R19 -	current number - current max
# R20 -	9 - i
# R21 -	current max
# R22 -	current max index
# R23 - SW status / Snapshot status
# R24 - SW1 mask
# R25 - step size
# R27 -	0x00000030 ASCII number offset
# R28 -	0x0000C000 base address of peripherals
# R29 - matrix index
# R30 - result pointer, results will be in DM at addr = 1000 through 1009

# Load R1 with 1
LLB		R1, 1

# Load R24 with 2 for SW1
LLB		R24, 2

# load R28 with 0x0000C000
LLB		R28, 0xC000
LHB		R28, 0x0000

CLASSIFY:
# Check switch values
LW		R23, R28, 1
AND		R23, R23, R24
B		EQ, CLASSIFY			# wait until SW1 is ON to classify

SW              R1, R28, 8         #send one snapshot request
SNAPSHOT_WAIT:
LW		R23, R28, 8        #get the snapshot request status
SUB             R23, R23, R1       # check if it is one
B               NEQ, SNAPSHOT_WAIT # if the status is still 1(meaning waiting for snapshot), then keep waiting


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

# Load R29 with 10
LLB		R29, 10

# Load R30 with 1000
LLB		R30, 1000

#########################
# MATRIX MULTIPLY STAGE #
#########################

MATRIX_LOOP:
# Call matrix multiplication and store result to DM
JAL		MATRIX_MUL
SW		R16, R30, 0
ADD		R30, R30, R1
ADD		R2, R2, R5

# loop back when not finished
SUB		R29, R29, R1
B		NEQ, MATRIX_LOOP

# Load R30 with 1000 for the output stage
LLB		R30, 1000

##############################
# CLASIFICATION OUTPUT STAGE #
##############################

# load 0x00000030 into R27
LLB		R27, 0x0030
# load negative infinity into R21
LLB		R21, 0x0000
LHB		R21, 0xFF80
# initialize R22 to 0
ADD		R22, R0, R0
# load 0 into R5
LLB		R5, 0x0000
# load 9 into R17
LLB		R17, 0x0009

# load next number
LOAD_NEXT:
SUB		R20, R17, R5
B		LT, DONE
LW		R18, R30, 0
SUBF	R19, R18, R21			# result in POS_INF at the first time
B		GT, NEW_MAX
ADD		R5, R5, R1				# increment loop index
ADD		R30, R30, R1			# increment address
B		UNCOND, LOAD_NEXT

# when current number > current max
# current max <- current number
# current max index <- loop index
NEW_MAX:
ADD		R21, R18, R0
ADD		R22, R5, R0
ADD		R5, R5, R1				# increment loop index
ADD		R30, R30, R1			# increment address
B		UNCOND, LOAD_NEXT

# max found, print to SPART
DONE:
ADD		R22, R22, R27			# R22 <- R22 + 0x0030
SW		R22, R28, 4				# print to SPART

B		UNCOND, CLASSIFY






##############################################
#
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
#	R16 - result of matrix calculation	
#
#	Reg Usage:
#	R1 - 1
#	R4 - intermediate mult result store address
#	R6 - image pixel value
#	R7 - weight value
#	R8 - multiplication result
#
################################################
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
# R16 <- 0x00000000
ADD		R16, R0, R0
# restore R5
POP		R5

# additions
SEQ_ADD:
LW		R8, R4, 0
ADD		R16, R16, R8

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