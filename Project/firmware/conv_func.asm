##############################################
#
#	A function call to a conv layer
#       5x5 kernel, 1 stride
#
#	Params:
#	R2 - pointer to kernel matrix
#	R3 - pointer of image matrix
#       R4 - input iamge side length
#       R5 - out address (Data memory)
#	R6 - out channel length
#       
#
#	Return:
#	None
#
#	Reg Usage:
#	R1 - 1
#	R4 - intermediate mult result store address
#	R6 - image pixel value
#	R7 - weight value
#	R8 - multiplication result
#
################################################

# callee-save
PUSH	R2
PUSH	R3
PUSH	R4
PUSH	R5
PUSH	R6
PUSH	R7
PUSH	R8

# to get the result_pix[0]:
# mult the image_pix with kernel
# pixels are at:
#         [(side_length*0+0)~(side_length*0+4),
#          (side_length*1+0)~(side_length*1+4),
#          (side_length*2+0)~(side_length*2+4),
#          (side_length*3+0)~(side_length*3+4),
#          (side_length*4+0)~(side_length*4+4)] 

# to get the result_pix[1]:
# mult the image_pix with kernel
# pixels are at:
#         [(side_length*0+0+1)~(side_length*0+4+1),
#          (side_length*1+0+1)~(side_length*1+4+1),
#          (side_length*2+0+1)~(side_length*2+4+1),
#          (side_length*3+0+1)~(side_length*3+4+1),
#          (side_length*4+0+1)~(side_length*4+4+1)] 

# to get the result_pix[27]:
# mult the image_pix with kernel
# pixels are at:
#         [(side_length*0+0+27)~(side_length*0+4+27),
#          (side_length*1+0+27)~(side_length*1+4+27),
#          (side_length*2+0+27)~(side_length*2+4+27),
#          (side_length*3+0+27)~(side_length*3+4+27),
#          (side_length*4+0+27)~(side_length*4+4+27)] 

# to get the result_pix[28]:
# mult the image_pix with kernel
# pixels are at:
#         [(side_length*1+0)~(side_length*1+4),
#          (side_length*2+0)~(side_length*2+4),
#          (side_length*3+0)~(side_length*3+4),
#          (side_length*4+0)~(side_length*4+4),
#          (side_length*5+0)~(side_length*5+4)] 

# provided variables
# side_length_input (input side_length)
# channel_length (repeat the convolution calculation for same image with different kernels)
# addr_kernel (start address of kernel)
# addr_image (start address of image)
# addr_output (start addres of output address)

# internal variables
# side_length_output (will set to side_length_input - 4 to reflect the output side_length)
# x_result ( start as 0, increase by one one a pixel is calcuated. set to 0 when reach side_length_output)
# y_result ( start as 0, increase by one when x_result reaches side_length_output )
# addr_result (start as 0, increase by one when a pixel is calcuated)
# pix_sum (start_ sum of result at a result_pix)
# pix_mult (mult result of a weight and a input_pix)
# addr_kernel_weight (address of a kernel_weight, start as 0, increment by 1 after each multiplication, reset to 0 after completing one pixel)

SUBI side_length_output, side_length_input, 4

# set x_result, y_result before process one image/filter
ADD x_result, R0, R0
ADD y_result, R0, R0


# set kernel_weight address to 0
ADD addr_kernel_weight, R0, R0


# get weight0-4
LW weight0, addr_kernel_weight,0
LW weight1, addr_kernel_weight,1
LW weight2, addr_kernel_weight,2
LW weight3, addr_kernel_weight,3
LW weight4, addr_kernel_weight,4


# restore saved registers
POP	R8
POP	R7
POP	R6
POP	R5
POP	R4
POP	R3
POP	R2