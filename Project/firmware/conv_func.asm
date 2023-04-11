##############################################
# CONV:
#	A function call to a conv layer
#       5x5 kernel, 1 stride
#
#	Params:
#       R2 - addr_kernel (start address of kernel)
#       R3 - addr_image (start address of image)
#       R4 - side_length_input (input side_length)
#       R6 - in_channel_length (repeat the convolution calculation for multiple images with the same kernel)
#       R7 - out_channel_length (repeat the convolution calculation for same image with different kernels)
#       R29 - addr_output (start addres of output address, increase by one when a pixel is calcuated)
#
#	Return:
#	None
#
#	Internal Reg Usage:
#       R4 - side_length_output, same reg as input (will set to side_length_input - 4 to reflect the output side_length)
#       R8 - x_result, x location of output iamges ( start as 0, increase by one one a pixel is calcuated. set to 0 when reach side_length_output)
#       R9 - y_result, y location of output iamges ( start as 0, increase by one when x_result reaches side_length_output )
#       R10 - pix_sum (sum of result at a result_pix)
#       R11~R15 - 5 weight registers (shared between all 25 weights)
#       R16~R20 - 5 pix registers (shared between 25 pixels, it also stores the mult result)
#       R21 - image_length (use this jump distance to switch between input channels)
#       R22 - base (a temp base location for pixel load)
#       R23 - temp (intermediate for base address calculation
#       R24 - channel_id (a downcounter for keep track of the channel id in process)
#
################################################
# major mechanism for pix calcualtion
###############################################################################################################################################
# to get the result_pix[y][x] at channel_id: (y is the vetical location of output pixel, x is the horizontal location of output pixel)        #
#                                                                                                                                             #
# mult the image_pix with kernel                                                                                                              #
# image_pixs are at:                                                                                                                          #
#  addr_image[(side_length_output*(y+0)+x+channel_id*image_length)~(side_length_output*(y+0)+x+4+channel_id*image_length),                    #
#             (side_length_output*(y+1)+x+channel_id*image_length)~(side_length_output*(y+1)+x+4+channel_id*image_length),                    #
#             (side_length_output*(y+2)+x+channel_id*image_length)~(side_length_output*(y+2)+x+4+channel_id*image_length),                    #
#             (side_length_output*(y+3)+x+channel_id*image_length)~(side_length_output*(y+3)+x+4+channel_id*image_length),                    #
#             (side_length_output*(y+4)+x+channel_id*image_length)~(side_length_output*(y+4)+x+4+channel_id*image_length)]                    #
###############################################################################################################################################

CONV:

# callee-save
PUSH R2
PUSH R3
PUSH R4
PUSH R6
PUSH R7
PUSH R8
PUSH R9
PUSH R10
PUSH R11
PUSH R12
PUSH R13
PUSH R14
PUSH R15
PUSH R16
PUSH R17
PUSH R18
PUSH R19
PUSH R20
PUSH R21
PUSH R22
PUSH R23
PUSH R24
PUSH R29

# set image_length to be (side_length_input * side_length_input)
MUL R21, R4, R4

# set side_length_putput to be (side_length_input - kernel_size + 1)
SUBI R4, R4, 4

# set x_result, y_result before process one image/filter
ADD R8, R0, R0
ADD R9, R0, R0

# Before process one pixel, the x_result, y_result, addr_output, addr_kernel, side_length_output must be set correctly
PIX_PROC:

# reset pix_sum 
ADD R10, R0, R0

# get weight0-4
LW R11, R2,0
LW R12, R2,1
LW R13, R2,2
LW R14, R2,3
LW R15, R2,4

# get pix0-4 from all input channels, add process five values from each channel at a time
SUBI R24, R6, 1               # get zero-based channel-id, used as a down counter
PIX0_4:
# base = addr_image[(y+0) * side_length_output + x + channel_id*image_length]
ADDI R22, R9, 0                              
MUL R22, R22, R4
ADD R22, R22, R8
MUL R23, R24, R21
ADD R22, R22, R23
ADD R22, R22, R3

LW R16, R22, 0
LW R17, R22, 1
LW R18, R22, 2
LW R19, R22, 3
LW R20, R22, 4

MULF R16, R11, R16            # store the mult result at pix[n] to avoid dependency
MULF R17, R12, R17
ADDF R10, R10, R16
MULF R18, R13, R18
ADDF R10, R10, R17
MULF R19, R14, R19
ADDF R10, R10, R18
MULF R20, R15, R20
ADDF R10, R10, R19
ADDF R10, R10, R20       #unavoidable dependency 
SUBI R24, R24, 1
B GTE, PIX0_4             # if there are more channels to process, process them. 


# get weight5-9
LW R11, R2,5
LW R12, R2,6
LW R13, R2,7
LW R14, R2,8
LW R15, R2,9

# get pix5-9 from all input channels, add process five values from each channel at a time
SUBI R24, R6, 1               # get zero-based channel-id, used as a down counter
PIX5_9:
# base = addr_image[(y+1) * side_length_output + x + channel_id*image_length]
ADDI R22, R9, 1                              
MUL R22, R22, R4
ADD R22, R22, R8
MUL R23, R24, R21
ADD R22, R22, R23
ADD R22, R22, R3

LW R16, R22, 0
LW R17, R22, 1
LW R18, R22, 2
LW R19, R22, 3
LW R20, R22, 4

MULF R16, R11, R16            # store the mult result at pix[n] to avoid dependency
MULF R17, R12, R17
ADDF R10, R10, R16
MULF R18, R13, R18
ADDF R10, R10, R17
MULF R19, R14, R19
ADDF R10, R10, R18
MULF R20, R15, R20
ADDF R10, R10, R19
ADDF R10, R10, R20       #unavoidable dependency 
SUBI R24, R24, 1
B GTE, PIX5_9             # if there are more channels to process, process them. 

# get weight10-14
LW R11, R2,10
LW R12, R2,11
LW R13, R2,12
LW R14, R2,13
LW R15, R2,14

# get pix10-14 from all input channels, add process five values from each channel at a time
SUBI R24, R6, 1               # get zero-based channel-id, used as a down counter
PIX10_14:
# base = addr_image[(y+2) * side_length_output + x + channel_id*image_length]
ADDI R22, R9, 2                              
MUL R22, R22, R4
ADD R22, R22, R8
MUL R23, R24, R21
ADD R22, R22, R23
ADD R22, R22, R3

LW R16, R22, 0
LW R17, R22, 1
LW R18, R22, 2
LW R19, R22, 3
LW R20, R22, 4

MULF R16, R11, R16            # store the mult result at pix[n] to avoid dependency
MULF R17, R12, R17
ADDF R10, R10, R16
MULF R18, R13, R18
ADDF R10, R10, R17
MULF R19, R14, R19
ADDF R10, R10, R18
MULF R20, R15, R20
ADDF R10, R10, R19
ADDF R10, R10, R20       #unavoidable dependency 
SUBI R24, R24, 1
B GTE, PIX10_14             # if there are more channels to process, process them. 

# get weight15-19
LW R11, R2,15
LW R12, R2,16
LW R13, R2,17
LW R14, R2,18
LW R15, R2,19

# get pix15-19 from all input channels, add process five values from each channel at a time
SUBI R24, R6, 1               # get zero-based channel-id, used as a down counter
PIX15_19:
# base = addr_image[(y+3) * side_length_output + x + channel_id*image_length]
ADDI R22, R9, 3                              
MUL R22, R22, R4
ADD R22, R22, R8
MUL R23, R24, R21
ADD R22, R22, R23
ADD R22, R22, R3

LW R16, R22, 0
LW R17, R22, 1
LW R18, R22, 2
LW R19, R22, 3
LW R20, R22, 4

MULF R16, R11, R16            # store the mult result at pix[n] to avoid dependency
MULF R17, R12, R17
ADDF R10, R10, R16
MULF R18, R13, R18
ADDF R10, R10, R17
MULF R19, R14, R19
ADDF R10, R10, R18
MULF R20, R15, R20
ADDF R10, R10, R19
ADDF R10, R10, R20       #unavoidable dependency 
SUBI R24, R24, 1
B GTE, PIX15_19             # if there are more channels to process, process them. 

# get weight20-24
LW R11, R2,20
LW R12, R2,21
LW R13, R2,22
LW R14, R2,23
LW R15, R2,24

# get pix20-24 from all input channels, add process five values from each channel at a time
SUBI R24, R6, 1               # get zero-based channel-id, used as a down counter
PIX20_24:
# base = addr_image[(y+4) * side_length_output + x + channel_id*image_length]
ADDI R22, R9, 4                              
MUL R22, R22, R4
ADD R22, R22, R8
MUL R23, R24, R21
ADD R22, R22, R23
ADD R22, R22, R3

LW R16, R22, 0
LW R17, R22, 1
LW R18, R22, 2
LW R19, R22, 3
LW R20, R22, 4

MULF R16, R11, R16            # store the mult result at pix[n] to avoid dependency
MULF R17, R12, R17
ADDF R10, R10, R16
MULF R18, R13, R18
ADDF R10, R10, R17
MULF R19, R14, R19
ADDF R10, R10, R18
MULF R20, R15, R20
ADDF R10, R10, R19
ADDF R10, R10, R20       #unavoidable dependency 
SUBI R24, R24, 1
B GTE, PIX20_24             # if there are more channels to process, process them. 

# store the result at location [y][x], and update x, y, addr_output
ADDF R10, R10, R0
B GTE, BYPASS_RELU_CONV
LLB R10, 0
BYPASS_RELU_CONV:
SW R10, R29, 0
ADDI R29, R29, 1
SUB R23, R8, R4
B NEQ, NOT_SWITCH_LINE                      #if the x does not reach the end of the line, do not increment line
SUB R23, R9, R4
B EQ, DONE_ONE_CHANNEL                  # if x_result reaches the end and y_result reaches the end, all pixels are computed for one channel
ADD R8, R0, R0         # reset x to 0 and increment y
ADDI R9, R9, 1
B UNCOND, PIX_PROC      # work on the next pix

NOT_SWITCH_LINE:
ADDI R8, R8, 1
B UNCOND, PIX_PROC      # work on the next pix

DONE_ONE_CHANNEL:
SUBI R7, R7, 1
B EQ, DONE
#update the kernel and reprocess the entire image
ADDI R2, R2, 25
ADD R8, R0, R0
ADD R9, R0, R0
B UNCOND, PIX_PROC

DONE:
# restore all registers and return
POP R29
POP R24
POP R23
POP R22
POP R21
POP R20
POP R19
POP R18
POP R17
POP R16
POP R15
POP R14
POP R13
POP R12
POP R11
POP R10
POP R9
POP R8
POP R7
POP R6
POP R4
POP R3
POP R2

JR R31