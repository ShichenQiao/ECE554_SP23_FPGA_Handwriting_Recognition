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
SW	R0, R2, 1
SW	R0, R2, 2
# J
LLB R3, 0x80
LHB R3, 0x29
SW	R3, R2, 0	# write character
JAL	wait

# loc = 20,0
LLB	R3, 0x14
SW	R3, R2, 1
SW	R0,	R2, 2
# Q
LLB R3,	0x00
LHB	R3, 0x2D
SW	R3, R2, 0
JAL	wait

# loc = 60,0
LLB	R3, 0x3C
SW	R3, R2, 1
SW	R0,	R2, 2
# H
LLB	R3, 0x80
LHB	R3, 0x28
SW	R3, R2, 0
JAL wait

# loc = 80,0
LLB	R3, 0x50
SW	R3, R2, 1
SW	R0,	R2, 2
# Z
LLB	R3, 0x80
LHB R3, 0x31
SW	R3,	R2, 0
JAL wait

# loc = 120,0
LLB	R3, 0x78
SW	R3, R2, 1
SW	R0,	R2, 2
# H
LLB	R3, 0x80
LHB	R3, 0x28
SW	R3, R2, 0
JAL wait

# loc = 160,0
LLB	R3, 0xA0
SW	R3, R2, 1
SW	R0,	R2, 2
# Q
LLB R3,	0x00
LHB	R3, 0x2D
SW	R3, R2, 0
JAL	wait

# loc = 180,0
LLB	R3, 0xB4
SW	R3, R2, 1
SW	R0,	R2, 2
# Q
LLB R3,	0x00
LHB	R3, 0x2D
SW	R3, R2, 0
JAL	wait

# loc = 200,0
LLB	R3, 0xC8
SW	R3, R2, 1
SW	R0,	R2, 2
# L
LLB	R3, 0x80
LHB	R3, 0x2A
SW	R3, R2, 0
JAL wait

# loc = 0,50
SW	R0, R2, 1
LLB	R3, 0x32
SW	R3, R2, 2
# image 0
LLB	R3, 0x40
SW	R3, R2, 0
JAL	wait

# loc = 200,50
LLB	R3, 0xC8
SW	R3, R2, 1
LLB	R3, 0x32
SW	R3, R2, 2
# image 1
LLB	R3, 0x41
SW	R3, R2, 0
JAL	wait

# loc = 400,50
LLB	R3, 0x90
LHB	R3, 0x01
SW	R3, R2, 1
LLB	R3, 0x32
SW	R3, R2, 2
# image 2
LLB	R3, 0x42
SW	R3, R2, 0
HLT



# waiting routine
wait:
LLB R4, 0x00
LHB	R4, 0x10	# load R4 for waiting
loop:
SUB	R4, R4, R1	# R4 <- R4 - 1
B	neq, loop
JR	R15