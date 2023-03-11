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
B lt	done
LW		R4, R30, 0
SUBF	R5, R4, R11		# result in POS_INF at the first time
B gt	newMax
ADD		R2, R2, R1		# increment loop index
ADD		R30, R30, R1	# increment address
B uncond	loadNext

# when current number > current max
# current max <- current number
# current max index <- loop index
newMax:
ADD		R11, R4, R0
ADD		R12, R2, R0
ADD		R2, R2, R1		# increment loop index
ADD		R30, R30, R1	# increment address
B uncond	loadNext

# max found, print to SPART
done:
ADD		R2, R2, R9		# R2 <- R2 + 0x0030
SW		R2, R8, 0		# print to SPART
HLT
