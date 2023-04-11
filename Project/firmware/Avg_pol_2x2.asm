###########################################################
# AVG_POOL:
#	2 * 2 average pooling across all channels
#
#	Params:
#	R3 - layer starting address
#	R4 - image width
#	R6 - number of image channels
#	R29 - output starting address
#
#	Return:
#	None
#
#	Reg Usage:
#	R0 - 0
#	R2 - 0.25F
#	R7 - pooled pixel
#	R8 - pooled pixel
#	R9 - pooled pixel
#	R10 - pooled pixel
#	R11 - image y index
#	R12 - image x index
#	R13 - avg from 4 pixels
#
###########################################################
AVG_POOL:
# callee-saves
PUSH	R2
PUSH	R3
PUSH	R4
PUSH	R6
PUSH	R7
PUSH	R8
PUSH	R9
PUSH	R10
PUSH	R11
PUSH	R12
PUSH	R13
PUSH	R29

# R2 <- 0.25F
LLB		R2, 0x0000
LHB		R2, 0x3E80

# outer loop - loop for number of channels
OUTER:						# new image
ADD		R11, R4, R0			# reset image y index

# inner y loop - loop for image width/2
INNERX:						# new line
ADD		R12, R4, R0			# reset image x index

# inner x loop - loop for image width/2
INNERY:

# load 4 pixels pointed by R3
# into R7 to R10
LW		R7, R3, 0
LW		R8, R3, 1
LW		R9, R3, 28
LW		R10, R3, 29
# increment R3 by 2
ADDI	R3, R3, 2

# find avg - store avg into R13
ADDF	R13, R0, R7
ADDF	R13, R13, R8
ADDF	R13, R13, R9
ADDF	R13, R13, R10
MULF	R13, R13, R2
# store avg into DM pointed by R29
SW		R13, R29, 0
# increment R29 to point to next
ADDI	R29, R29, 1
# end inner x loop, decrement R12 by 2
# also increment R3 by 30 so it points to the second next line
ADDI	R3, R3, 30
SUBI	R12, R12, 2
B		NEQ, INNERX

# end inner y loop, decrement R11 by 2
SUBI	R11, R11, 2
B		NEQ, INNERY

# end outer loop, decrement R6 by 1
SUBI	R6, R6, 1
B		NEQ, OUTER

# callee-restores
POP		R29
POP		R13
POP		R12
POP		R11
POP		R10
POP		R9
POP		R8
POP		R7
POP		R6
POP		R4
POP		R3
POP		R2

JR		R31