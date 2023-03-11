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
## R5		-	loop index i
## R17		-	loop number 9 (i <= 9)
## R18		-	current number
## R19		-	current number - current max
## R20		-	9 - i
## R21		-	current max
## R22		-	current max index
## R28		-	0x0000C004 address of MM UART transmission buffer
## R27		-	0x00000030 ASCII number offset
##
#######################################################
# load 0x0000C004 into R28
LLB		R28, 0xC004
LHB		R28, 0x0000
# load 0x00000030 into R27
LLB		R27, 0x0030
# load negative infinity into R21
LLB		R21, 0x0000
LHB 	R21, 0xFF80
# initialize R22 to 0
ADD		R22, R0, R0
# load 1 into R1
LLB		R1, 0x0001
# load 0 into R5
LLB		R5, 0x0000
# load 9 into R17
LLB		R17, 0x0009

# load next number
loadNext:
SUB		R20, R17, R5
B lt,	done
LW		R18, R30, 0
SUBF	R19, R18, R21		# result in POS_INF at the first time
B gt,	newMax
ADD		R5, R5, R1		# increment loop index
ADD		R30, R30, R1	# increment address
B uncond,	loadNext

# when current number > current max
# current max <- current number
# current max index <- loop index
newMax:
ADD		R21, R18, R0
ADD		R22, R5, R0
ADD		R5, R5, R1		# increment loop index
ADD		R30, R30, R1	# increment address
B uncond,	loadNext

# max found, print to SPART
done:
ADD		R22, R22, R27		# R5 <- R5 + 0x0030
SW		R22, R28, 0		# print to SPART
HLT
