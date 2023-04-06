###########################################################
# Avg_pol_2x2: will do callee-saves
# args:
#	R3 - image width
#	R4 - layer starting address
#	R5 - number of image channels
#	R6 - output starting address
#
# usage:
#	R0 - 0
#	R2 - 0.25F
#	R7 - polled pixel
#	R8 - polled pixel
#	R9 - polled pixel
#	R10 - polled pixel
#	R11 - image y index
#	R12 - image x index
#	R13 - avg from 4 pixels
#
###########################################################

# callee-saves
PUSH	R2
PUSH	R7
PUSH	R8
PUSH	R9
PUSH	R10
PUSH	R11
PUSH	R12
PUSH	R13
# R2 <- 0.25F
LLB		R2, 0x0000
LHB		R2, 0x3E80

# outer loop - loop for number of channels
OUTER:						# new image
ADD		R11, R3, R0			# reset image y index

# inner y loop - loop for image width/2
INNERX:						# new line
ADD		R12, R3, R0			# reset image x index

# inner x loop - loop for image width/2
INNERY:

# load 4 pixels pointed by R4
# into R7 to R10
LW		R7, R4, 0
LW		R8, R4, 1
LW		R9, R4, 28
LW		R10, R4, 29
# increment R4 by 2
ADDI	R4, R4, 2

# find avg - store avg into R13
ADDF	R13, R0, R7
ADDF	R13, R13, R8
ADDF	R13, R13, R9
ADDF	R13, R13, R10
MULF	R13, R13, R2
# store avg into DM pointed by R6
SW		R13, R6, 0
# increment R6 to point to next
ADDI	R6, R6, 1
# end inner x loop, decrement R12 by 2
# also increment R4 by 30 so it points to the second next line
ADDI	R4, R4, 30
SUBI	R12, R12, 2
B		NEQ, INNERX

# end inner y loop, decrement R11 by 2
SUBI	R11, R11, 2
B		NEQ, INNERY

# end outer loop, decrement R5 by 1
SUBI	R5, R5, 1
B		NEQ, OUTER

# callee-restores
POP		R13
POP		R12
POP		R11
POP		R10
POP		R9
POP		R8
POP		R7
POP		R2