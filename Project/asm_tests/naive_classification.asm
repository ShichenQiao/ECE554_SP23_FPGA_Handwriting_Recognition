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
LW R6, R1, 0
LW R7, R2, 0
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
