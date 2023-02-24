# R1	-	0x0001
# R2	-	0xC008
# R3	-	external wdata
# R4	-	waiting counter
#store 0x0001 in R1
LLB R1, 0x01

#store 0xC000 in R3
# 0xC008 ctrl
# 0xC009 xloc
# 0xC00A yloc
LLB R2, 0x08
LHB R2, 0xC0

# generate instruction:
# [13:0] ctrl
# add_fnt - ctrl[13]     add a character
# fnt_indx - ctrl[12:7]  one of 42 characters // 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ =>,()
# add_img - ctrl[6]      pulse high for one clock to add image
# rem_img - ctrl[5]      pulse high for one clock to remove image
# image_indx - ctrl[4:0] index of image in image memory (32 possible)

##### INITIALS #####
# loc = 0,0
LLB R3, 0x00
SW	R3, R2, 1
SW	R3, R2, 2

# J
LLB R3, 0x00
LHB R3, 0x2A
SW	R3, R2, 0	# write character
LLB R4, 0x00
LHB	R4, 0x10	# load R4 for waiting
JAL	wait

# loc = 25,0
LLB	R3, 0x19
SW	R3, R2, 1
LLB R3, 0x00
SW	R3,	R2, 2

# Q
LLB R3,	0x00
LHB	R3, 0x32
SW	R3, R2, 0
HLT

# waiting routine
wait:
SUB	R4, R4, R1	# R4 <- R4 - 1
B	neq, wait
JR	R15