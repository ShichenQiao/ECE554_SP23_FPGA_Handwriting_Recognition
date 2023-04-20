##############################################
#
#	A function call to a conv layer
#       5x5 kernel, 1 stride
#
#	Params:
#       R2 - side_length_input (input side_length)
#       R3 - in_channel_length (repeat the convolution calculation for multiple images with the same kernel)
#       R4 - out_channel_length (repeat the convolution calculation for same image with different kernels)
#       R5 - addr_kernel (start address of kernel)
#       R6 - addr_image (start address of image)
#       R7 - addr_output (start addres of output address, increase by one when a pixel is calcuated)
#       
#
#	Return:
#	None
#
#	Internal Reg Usage:
#       R2 - side_length_output, same reg as input (will set to side_length_input - 4 to reflect the output side_length)
#       R8 - x_result, x location of output iamges ( start as 0, increase by one one a pixel is calcuated. set to 0 when reach side_length_output)
#       R9 - y_result, y location of output iamges ( start as 0, increase by one when x_result reaches side_length_output )
#       R10 - pix_sum (sum of result at a result_pix)
#       R11~R15 - 5 weight registers (shared between all 25 weights)
#       R16~R20 - 5 pix registers (shared between 25 pixels, it also stores the mult result)
#       R21 - image_length (use this jump distance to switch between input channels)
#       R22 - base (a temp base location for pixel load)
#       R23 - temp (intermediate for base address calculation)
#
################################################
# major mechanism for pix calcualtion
###############################################################################################################################################
# to get the result_pix[y][x] at channel_id: (y is the vetical location of output pixel, x is the horizontal location of output pixel)        #
#                                                                                                                                             #
# mult the image_pix with kernel                                                                                                              #
# kernels are at :                                                                                                                            #
#  addr_kernel[(channel_id*25+0)~(channel_id*25+9),                                                                                           #
#              (channel_id*25+5)~(channel_id*25+10),                                                                                          #
#              (channel_id*25+10)~(channel_id*25+14),                                                                                         #
#              (channel_id*25+15)~(channel_id*25+19),                                                                                         #
#              (channel_id*25+20)~(channel_id*25+24)]                                                                                         #
# image_pixs are at:                                                                                                                          #
#  addr_image[(side_length_input*(y+0)+x+channel_id*image_length)~(side_length_input*(y+0)+x+4+channel_id*image_length),                    #
#             (side_length_input*(y+1)+x+channel_id*image_length)~(side_length_input*(y+1)+x+4+channel_id*image_length),                    #
#             (side_length_input*(y+2)+x+channel_id*image_length)~(side_length_input*(y+2)+x+4+channel_id*image_length),                    #
#             (side_length_input*(y+3)+x+channel_id*image_length)~(side_length_input*(y+3)+x+4+channel_id*image_length),                    #
#             (side_length_input*(y+4)+x+channel_id*image_length)~(side_length_input*(y+4)+x+4+channel_id*image_length)]                    #
###############################################################################################################################################

CONV:

# callee-save
PUSH R2
PUSH R3
PUSH R4
PUSH R5
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

# set image_length to be (side_length_input * side_length_input)
MULT image_length, side_length_input, side_length_input

# set side_length_output to be (side_length_input - kernel_size + 1)
SUBI side_length_output, side_length_input, 4

# set x_result, y_result before process one image/filter
ADD x_result, R0, R0
ADD y_result, R0, R0

# Before process one pixel, the x_result, y_result, addr_output, addr_kernel, side_length_output must be set correctly
PIX_PROC:

# reset pix_sum 
ADD pix_sum, R0, R0

# get weight0-4
LW weight0, addr_kernel,0
LW weight1, addr_kernel,1
LW weight2, addr_kernel,2
LW weight3, addr_kernel,3
LW weight4, addr_kernel,4

# get pix0-4 from all input channels, add process five values from each channel at a time
SUBI channel_id, in_channel_length, 1               # get zero-based channel-id, used as a down counter
PIX0_4:
# base = addr_image[(y+0) * side_length_output + x + channel_id*image_length]
ADDI base, y_result, 0
MULT base, base, side_length_output
ADD base, base, x_result
MULT temp, channel_id, image_length
ADD base, base, temp
ADD base, base, addr_image

LW pix0, base, 0
LW pix1, base, 1
LW pix2, base, 2
LW pix3, base, 3
LW pix4, base, 4

MULTF pix0, weight0, pix0            # store the mult result at pix[n] to avoid dependency
MULTF pix1, weight1, pix1
ADDF pix_sum, pix_sum, pix0
MULTF pix2, weight2, pix2
ADDF pix_sum, pix_sum, pix1
MULTF pix3, weight3, pix3
ADDF pix_sum, pix_sum, pix2
MULTF pix4, weight4, pix4
ADDF pix_sum, pix_sum, pix3
ADDF pix_sum, pix_sum, pix4       #unavoidable dependency 
SUBI channel_id, channel_id, 1
B GTE, PIX0_4             # if there are more channels to process, process them. 

SUBI channel_id, in_channel_length, 1               # get zero-based channel-id, used as a down counter
PIX5_9:
MUL temp, kernel_id, 25
ADD base, addr_kernel, temp
# get weight5-9
LW weight0, base,5
LW weight1, base,6
LW weight2, base,7
LW weight3, base,8
LW weight4, base,9

# get pix5-9 from all input channels, add process five values from each channel at a time

# base = addr_image[(y+1) * side_length_output + x + channel_id*image_length]
ADDI base, y_result, 1                              
MULT base, base, side_length_output
ADD base, base, x_result
MULT temp, channel_id, image_length
ADD base, base, temp
ADD base, base, addr_image

LW pix0, base, 0
LW pix1, base, 1
LW pix2, base, 2
LW pix3, base, 3
LW pix4, base, 4

MULTF pix0, weight0, pix0            # store the mult result at pix[n] to avoid dependency
MULTF pix1, weight1, pix1
ADDF pix_sum, pix_sum, pix0
MULTF pix2, weight2, pix2
ADDF pix_sum, pix_sum, pix1
MULTF pix3, weight3, pix3
ADDF pix_sum, pix_sum, pix2
MULTF pix4, weight4, pix4
ADDF pix_sum, pix_sum, pix3
ADDF pix_sum, pix_sum, pix4       #unavoidable dependency 
SUBI channel_id, channel_id, 1
B GTE, PIX5_9             # if there are more channels to process, process them. 

# get weight10-14
LW weight0, addr_kernel,10
LW weight1, addr_kernel,11
LW weight2, addr_kernel,12
LW weight3, addr_kernel,13
LW weight4, addr_kernel,14

# get pix10-14 from all input channels, add process five values from each channel at a time
SUBI channel_id, in_channel_length, 1               # get zero-based channel-id, used as a down counter
PIX10_14:
# base = addr_image[(y+2) * side_length_output + x + channel_id*image_length]
ADDI base, y_result, 2                              
MULT base, base, side_length_output
ADD base, base, x_result
MULT temp, channel_id, image_length
ADD base, base, temp
ADD base, base, addr_image

LW pix0, base, 0
LW pix1, base, 1
LW pix2, base, 2
LW pix3, base, 3
LW pix4, base, 4

MULTF pix0, weight0, pix0            # store the mult result at pix[n] to avoid dependency
MULTF pix1, weight1, pix1
ADDF pix_sum, pix_sum, pix0
MULTF pix2, weight2, pix2
ADDF pix_sum, pix_sum, pix1
MULTF pix3, weight3, pix3
ADDF pix_sum, pix_sum, pix2
MULTF pix4, weight4, pix4
ADDF pix_sum, pix_sum, pix3
ADDF pix_sum, pix_sum, pix4       #unavoidable dependency 
SUBI channel_id, channel_id, 1
B GTE, PIX10_14             # if there are more channels to process, process them. 

# get weight15-19
LW weight0, addr_kernel,15
LW weight1, addr_kernel,16
LW weight2, addr_kernel,17
LW weight3, addr_kernel,18
LW weight4, addr_kernel,19

# get pix15-19 from all input channels, add process five values from each channel at a time
SUBI channel_id, in_channel_length, 1               # get zero-based channel-id, used as a down counter
PIX15_19:
# base = addr_image[(y+3) * side_length_output + x + channel_id*image_length]
ADDI base, y_result, 3                              
MULT base, base, side_length_output
ADD base, base, x_result
MULT temp, channel_id, image_length
ADD base, base, temp
ADD base, base, addr_image

LW pix0, base, 0
LW pix1, base, 1
LW pix2, base, 2
LW pix3, base, 3
LW pix4, base, 4

MULTF pix0, weight0, pix0            # store the mult result at pix[n] to avoid dependency
MULTF pix1, weight1, pix1
ADDF pix_sum, pix_sum, pix0
MULTF pix2, weight2, pix2
ADDF pix_sum, pix_sum, pix1
MULTF pix3, weight3, pix3
ADDF pix_sum, pix_sum, pix2
MULTF pix4, weight4, pix4
ADDF pix_sum, pix_sum, pix3
ADDF pix_sum, pix_sum, pix4       #unavoidable dependency 
SUBI channel_id, channel_id, 1
B GTE, PIX15_19             # if there are more channels to process, process them. 

# get weight20-24
LW weight0, addr_kernel,20
LW weight1, addr_kernel,21
LW weight2, addr_kernel,22
LW weight3, addr_kernel,23
LW weight4, addr_kernel,24

# get pix20-24 from all input channels, add process five values from each channel at a time
SUBI channel_id, in_channel_length, 1               # get zero-based channel-id, used as a down counter
PIX20_24:
# base = addr_image[(y+4) * side_length_output + x + channel_id*image_length]
ADDI base, y_result, 4                              
MULT base, base, side_length_output
ADD base, base, x_result
MULT temp, channel_id, image_length
ADD base, base, temp
ADD base, base, addr_image

LW pix0, base, 0
LW pix1, base, 1
LW pix2, base, 2
LW pix3, base, 3
LW pix4, base, 4

MULTF pix0, weight0, pix0            # store the mult result at pix[n] to avoid dependency
MULTF pix1, weight1, pix1
ADDF pix_sum, pix_sum, pix0
MULTF pix2, weight2, pix2
ADDF pix_sum, pix_sum, pix1
MULTF pix3, weight3, pix3
ADDF pix_sum, pix_sum, pix2
MULTF pix4, weight4, pix4
ADDF pix_sum, pix_sum, pix3
ADDF pix_sum, pix_sum, pix4       #unavoidable dependency 
SUBI channel_id, channel_id, 1
B GTE, PIX20_24             # if there are more channels to process, process them. 

# store the result at location [y][x], and update x, y, addr_output
SW pix_sum, addr_output, 0
ADDI addr_output, addr_output, 1
SUB temp, x_result, side_length_output
B NEQ, NOT_SWITCH_LINE                      #if the x does not reach the end of the line, do not increment line
SUB temp, y_result, side_length_output
B EQ, DONE_ONE_CHANNEL                  # if x_result reaches the end and y_result reaches the end, all pixels are computed for one channel
ADD x_result, R0, R0         # reset x to 0 and increment y
ADDI y_result, y_result, 1
B UNCOND, PIX_PROC      # work on the next pix

NOT_SWITCH_LINE:
ADDI x_result, x_result, 1
B UNCOND, PIX_PROC      # work on the next pix

DONE_ONE_CHANNEL:
SUBI out_channel_length, out_channel_length, 1
B EQ, DONE
#update the kernel and reprocess the entire image
ADDI addr_kernel, addr_kernel, 25
ADD x_result, R0, R0
ADD y_result, R0, R0
B UNCOND PIX_PROC

DONE:
# restore all registers and return
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
POP R5
POP R4
POP R3
POP R2

JR R31