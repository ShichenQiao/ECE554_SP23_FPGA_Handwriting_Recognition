# R1 - 1
# R2 - pointer to weight matrix
# R3 - pointer of image matrix
# R4 - pointer to DM
# R5 - loop index
# R6 through R16 - compute regs
# R17 -	loop number 9 (i <= 9)
# R18 -	current number
# R19 -	current number - current max
# R20 -	9 - i
# R21 -	current max
# R22 -	current max index
# R23 - SW status
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

####################
# RESTORE POINTERS #
####################

# Load R2 with 0x00020000
LLB		R2, 0
LHB		R2, 2

# Load R29 with 10
LLB		R29, 10

# Load R30 with 1000
LLB		R30, 1000

#########################
# MATRIX MULTIPLY STAGE #
#########################

MATRIX_LOOP:
# Load R3 with 0x00010000
LLB		R3, 0
LHB		R3, 1

# Load R4 with 0x00000000
LLB		R4, 0

# Load R5 with 784
LLB		R5, 784

MUL_LOOP:
# FP multiply
LW		R6, R3, 0
LW		R7, R2, 0				# weights are in FP format
ITF		R6, R6					# but image is in int (0 ~ 255)
MULF	R8, R6, R7
SW		R8, R4, 0				# store product to DM

# increment pointers
ADD		R2, R2, R1
ADD		R3, R3, R1
ADD		R4, R4, R1

# loop back when not finished
SUB		R5, R5, R1
B		NEQ, MUL_LOOP

# Load R4 with 0x00000000
LLB		R4, 0

# Load R5 with 784/7 = 112
LLB		R5, 112

LV1_ADD:
LW		R6, R4, 0
LW		R7, R4, 1
LW		R8, R4, 2
LW		R9, R4, 3
LW		R10, R4, 4
LW		R11, R4, 5
LW		R12, R4, 6

ADDF	R6, R6, R7
ADDF	R8, R8, R9
ADDF	R10, R10, R11

ADDF	R6, R6, R8
ADDF	R10, R10, R12

ADDF	R6, R6, R10
SW		R6, R4, 0

LLB		R7, 7
ADD		R4, R4, R7

# loop back when not finished
SUB		R5, R5, R1
B		NEQ, LV1_ADD

# Load R4 with 0x00000000
LLB		R4, 0

# Load R5 with 112/7 = 16
LLB		R5, 16

LV2_ADD:
LW		R6, R4, 0
LW		R7, R4, 7
LW		R8, R4, 14
LW		R9, R4, 21
LW		R10, R4, 28
LW		R11, R4, 35
LW		R12, R4, 42

ADDF	R6, R6, R7
ADDF	R8, R8, R9
ADDF	R10, R10, R11

ADDF	R6, R6, R8
ADDF	R10, R10, R12

ADDF	R6, R6, R10
SW		R6, R4, 0

LLB		R7, 49
ADD		R4, R4, R7

# loop back when not finished
SUB		R5, R5, R1
B		NEQ, LV2_ADD

# Load R25 with 49
LLB		R25, 49

# Load R4 with 0
LLB		R4, 0

LW		R6, R4, 0
ADD		R4, R4, R25
LW		R7, R4, 0
ADD		R4, R4, R25
LW		R8, R4, 0
ADD		R4, R4, R25
LW		R9, R4, 0
ADD		R4, R4, R25
LW		R10, R4, 0
ADD		R4, R4, R25
LW		R11, R4, 0
ADD		R4, R4, R25
LW		R12, R4, 0
ADD		R4, R4, R25
LW		R13, R4, 0
ADD		R4, R4, R25

ADDF	R6, R6, R7
ADDF	R8, R8, R9
ADDF	R10, R10, R11
ADDF	R12, R12, R13

ADDF	R6, R6, R8
ADDF	R10, R10, R12

ADDF	R14, R6, R10

LW		R6, R4, 0
ADD		R4, R4, R25
LW		R7, R4, 0
ADD		R4, R4, R25
LW		R8, R4, 0
ADD		R4, R4, R25
LW		R9, R4, 0
ADD		R4, R4, R25
LW		R10, R4, 0
ADD		R4, R4, R25
LW		R11, R4, 0
ADD		R4, R4, R25
LW		R12, R4, 0
ADD		R4, R4, R25
LW		R13, R4, 0

ADDF	R6, R6, R7
ADDF	R8, R8, R9
ADDF	R10, R10, R11
ADDF	R12, R12, R13

ADDF	R6, R6, R8
ADDF	R10, R10, R12

ADDF	R15, R6, R10

ADDF	R16, R14, R15
SW		R16, R30, 0
ADD		R30, R30, R1

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
