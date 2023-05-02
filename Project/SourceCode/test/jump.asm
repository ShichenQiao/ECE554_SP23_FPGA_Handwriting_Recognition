############################
##Test JAL basic function ##
############################
JAL label

JAL label2
B		UNCOND, L_FAIL

label3:
B		UNCOND, L_PASS

label2:
JAL label3

label:
JR  R31
B		UNCOND, L_FAIL


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