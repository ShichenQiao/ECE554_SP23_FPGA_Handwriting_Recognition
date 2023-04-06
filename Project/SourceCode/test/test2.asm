B UNCOND, L_PASS

#########################
##Fail routine at 0xAD ##
#########################
MEM 0x00AD
L_PASS:B UNCOND, L_PASS

#########################
##Fail routine at 0xDD ##
#########################
MEM 0x00DD
L_FAIL: B UNCOND, L_FAIL