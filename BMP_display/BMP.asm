#store 0x0001 in R1
LLB R1, 0x01

#store 0xC000 in R3
LLB R3, 0x00
LHB R3, 0xC0

# generate instruction:
# [13:0] ctrl
# add_fnt - ctrl[13]     add a character
# fnt_indx - ctrl[12:7]  one of 42 characters // 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ =>,()
# add_img - ctrl[6]      pulse high for one clock to add image
# rem_img - ctrl[5]      pulse high for one clock to remove image
# image_indx - ctrl[4:0] index of image in image memory (32 possible)

LLB R2, 0x40 # image 0, add image

SW R2, R3, 0x8 #store the image