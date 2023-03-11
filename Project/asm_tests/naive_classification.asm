# R1 - pointer to weight matrix
# R2 - pointer of image matrix
# R3 - pointer to DM
# R4 - 1
# R5 - loop index
# R6 through R16 - compute regs
# R29 - matrix index
# R30 - result pointer, results will be in DM at addr = 1000 through 1009

# Load R1 with 0x00020000
LLB R1, 0
LHB R1, 2

# Load R4 with 0x00000001
LLB R4, 1

# Load R29 with 10
LLB R29, 10

# Load R30 with 1000
LLB R30, 1000

MATRIX_LOOP:
# Load R2 with 0x00010000
LLB R2, 0
LHB R2, 1

# Load R3 with 0x00000000
LLB R3, 0

# Load R5 with 784
LLB R5, 784

MUL_LOOP:
# FP multiply
LW R6, R2, 0
LW R7, R1, 0		# weights are in FP format
ITF R6, R6			# but image is in int (0 ~ 255)
MULF R8, R6, R7
SW R8, R3, 0		# store product to DM

# increment pointers
ADD R1, R1, R4
ADD R2, R2, R4
ADD R3, R3, R4

# loop back when not finished
SUB R5, R5, R4
B NEQ, MUL_LOOP

# Load R3 with 0x00000000
LLB R3, 0

# Load R5 with 784/7 = 112
LLB R5, 112

LV1_ADD:
LW R6, R3, 0
LW R7, R3, 1
LW R8, R3, 2
LW R9, R3, 3
LW R10, R3, 4
LW R11, R3, 5
LW R12, R3, 6

ADDF R6, R6, R7
ADDF R8, R8, R9
ADDF R10, R10, R11

ADDF R6, R6, R8
ADDF R10, R10, R12

ADDF R6, R6, R10
SW R6, R3, 0

LLB R7, 7
ADD R3, R3, R7

# loop back when not finished
SUB R5, R5, R4
B NEQ, LV1_ADD

# Load R3 with 0x00000000
LLB R3, 0

# Load R5 with 112/7 = 16
LLB R5, 16

LV2_ADD:
LW R6, R3, 0
LW R7, R3, 7
LW R8, R3, 14
LW R9, R3, 21
LW R10, R3, 28
LW R11, R3, 35
LW R12, R3, 42

ADDF R6, R6, R7
ADDF R8, R8, R9
ADDF R10, R10, R11

ADDF R6, R6, R8
ADDF R10, R10, R12

ADDF R6, R6, R10
SW R6, R3, 0

LLB R7, 49
ADD R3, R3, R7

# loop back when not finished
SUB R5, R5, R4
B NEQ, LV2_ADD

# Load R3 with 147
LLB R3, 147

LW R6, R3, -147
LW R7, R3, -98
LW R8, R3, -49
LW R9, R3, 0
LW R10, R3, 49
LW R11, R3, 147
LW R12, R3, 196
LW R13, R3, 245

ADDF R6, R6, R7
ADDF R8, R8, R9
ADDF R10, R10, R11
ADDF R12, R12, R13

ADDF R6, R6, R8
ADDF R10, R10, R12

ADDF R14, R6, R10

# Load R3 with 392 + 147 = 539
LLB R3, 539

LW R6, R3, -147
LW R7, R3, -98
LW R8, R3, -49
LW R9, R3, 0
LW R10, R3, 49
LW R11, R3, 147
LW R12, R3, 196
LW R13, R3, 245

ADDF R6, R6, R7
ADDF R8, R8, R9
ADDF R10, R10, R11
ADDF R12, R12, R13

ADDF R6, R6, R8
ADDF R10, R10, R12

ADDF R15, R6, R10

ADDF R16, R14, R15
SW R16, R30, 0
ADD R30, R30, R4

# loop back when not finished
SUB R29, R29, R4
B NEQ, MATRIX_LOOP





# Load R30 with 1000
LLB R30, 1000

#######################################################
##
## Find the index of max value given a base DM address
## that points to 10 consecutive 32-bit IEEE-754 FP
## numbers
##
## Designer: Haining QIU
##
## R30		-	address to a number
## R1		-	int 1
## R2		-	loop index i
## R3		-	loop number 9 (i <= 9)
## R4		-	current number
## R5		-	current number - current max
## R6		-	9 - i
## R8		-	0x0000C004 address of MM UART transmission buffer
## R9		-	0x00000030 ASCII number offset
## R11		-	current max
## R12		-	current max index
##
#######################################################
# load 0x0000C004 into R8
LLB		R8, 0xC004
LHB		R8, 0x0000
# load 0x00000030 into R9
LLB		R9, 0x0030
# load negative infinity into R11
LLB		R11, 0x0000
LHB 	R11, 0xFF80
# initialize R12 to 0
ADD		R12, R0, R0
# load 1 into R1
LLB		R1, 0x0001
# load 0 into R2
LLB		R2, 0x0000
# load 9 into R3
LLB		R3, 0x0009

# load next number
loadNext:
SUB		R6, R3, R2
B lt,	done
LW		R4, R30, 0
SUBF	R5, R4, R11		# result in POS_INF at the first time
B gt,	newMax
ADD		R2, R2, R1		# increment loop index
ADD		R30, R30, R1	# increment address
B uncond,	loadNext

# when current number > current max
# current max <- current number
# current max index <- loop index
newMax:
ADD		R11, R4, R0
ADD		R12, R2, R0
ADD		R2, R2, R1		# increment loop index
ADD		R30, R30, R1	# increment address
B uncond,	loadNext

# max found, print to SPART
done:
ADD		R2, R12, R9		# R2 <- R2 + 0x0030
SW		R2, R8, 0		# print to SPART
HLT
