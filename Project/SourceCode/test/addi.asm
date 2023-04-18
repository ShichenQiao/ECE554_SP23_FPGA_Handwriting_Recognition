############################
##Test ADDi basic function ##
############################
## adding two positive numbers
## with correct output
LLB		R1, 0x6655		# R1 contains 0x00006655
ADDI	R1, R1, 0x11	# R1 should be 0x00006666
LLB		R4, 0x6666		# R4 contains 0x00006666 
SUB		R4, R1, R4		# compare R3 to known right answer
B		NEQ, L_FAIL		# branch to fail routine

############################
##Test ADDi basic function ##
############################
## adding two positive numbers
## with overflow
LLB		R1, 0xfffe		# R1 contains 0xfffffffe
LHB		R1, 0x7fff		# R1 contains 0x7ffffffe
ADDI	R1, R1, 0x55	# R1 should be 0x7fffffff
LLB		R4, 0xffff		# R4 contains 0xffffffff
LHB		R4, 0x7fff		# R4 contains 0x7fffffff
SUB		R4, R1, R4		# compare R3 to known right answer
B		NEQ, L_FAIL		# branch to fail routine

############################
##Test ADDi basic function ##
############################
## adding two negative numbers
## with overflow
LLB		R1, 0x0055		# R1 contains 0x00000055
LHB		R1, 0x8000		# R1 contains 0x80000055
ADDI	R1, R1, 0x80	# R1 should be 0x80000000
LLB		R4, 0x0000		# R4 contains 0x00000000
LHB		R4, 0x8000		# R4 contains 0x80000000
SUB		R4, R1, R4		# compare R3 to known right answer
B		NEQ, L_FAIL		# branch to fail routine

############################
##Test ADDi basic function ##
############################
## adding two negative numbers
## with correct output
LLB		R1, 0xff80		# R1 contains 0xffffff80
ADDI	R1, R1, 0x80	# R1 should be 0xffffff00
LLB		R4, 0xff00		# R4 contains 0xffffff00
SUB		R4, R1, R4		# compare R3 to known right answer
B		NEQ, L_FAIL		# branch to fail routine

##############################################
##Test that ADDi does not set negative flag ##
##############################################
## adding two positive numbers
## should not set negative flag
LLB		R1, 0x6655		# R1 contains 0x00006655
ADDI	R1, R1, 0x11	# R1 should be 0x00006666
B		LT, L_FAIL		# branch to fail routine if negative flag is set
B		LTE, L_FAIL		# branch to fail routine if negative flag is set and zero flag is set

#####################################
##Test that ADDi sets negative flag ##
#####################################
## adding two positive numbers
## should set negative
LLB		R1, 0xffd5		# R1 contains 0xffffffd5
ADDI	R1, R1, 0x80	# R3 should be 0xffffff55
B		GTE, L_FAIL		# branch to fail if negative flag is not set
B		GT, L_FAIL		# branch to fail if negative flag is not set and zero flag is set

###########################################
##Test that ADDi does not set carry flag ##
###########################################
## adding two positive numbers
## should not set overflow
LLB		R1, 0x6655		# R1 contains 0x00006655
ADDI	R1, R1, 0x11	# R3 should be 0x00006666
B		OVFL, L_FAIL	# branch to fail routine if overflow

##################################
##Test that ADDi sets carry flag ##
##################################
## adding two positive numbers
## should set overflow
LLB		R1, 0xfffe		# R contains 0xfffffffe
LHB		R1, 0x7fff		# R contains 0x7ffffffe
ADDI	R1, R1, 0x55	# R3 should be 0x7fffffff
B		OVFL, L_PASS	# branch to pass routine if overflow
B		UNCOND, L_FAIL	# branch to fail routine

#########################
##Pass routine at 0xAD ##
#########################
MEM 0x00AD
L_PASS:
B		UNCOND, L_PASS

#########################
##Fail routine at 0xDD ##
#########################
MEM 0x00DD
L_FAIL:
B		UNCOND, L_FAIL