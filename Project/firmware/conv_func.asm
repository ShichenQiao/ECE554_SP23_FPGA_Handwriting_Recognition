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

# internal variables
# x_result ( start as 0. increase by one one a pixel is calcuated. set to 0 when reach side_length)
# y_result ( start as 0. increase by one when x_result reaches side_length)
# addr_result (start as 0, increase by one when a pixel is calcuated)

# restore saved registers
POP	R8
POP	R7
POP	R6
POP	R5
POP	R4
POP	R3
POP	R2