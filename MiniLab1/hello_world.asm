################################ Use of each register in this program ################################
# R0  -- Stores 0
# R1  -- Stores 1
# R2  -- Character holder, use this register to hard code character and send to tx, load to this value and then call SEND
# R3  -- Base address of the external port (0xCOOO)
# R4  -- Status Register value holder
# R5  -- Memory Character pointer
# R6  -- Mask to get TX_empty
# R7  -- Mask to get RX_filled
# R8  -- Character <CR>
# R9  -- Store 13-bits division buffer of baud rate
# R10 -- Store switch input
# R11 -- Store switch masks
# R13 -- Return pointer for inner function call
# R14 -- Return pointer for inner-inner function call
# R15 -- Return address of function call
################################ End of definition ###################################################
################################ Hard coded variables ################################################
#store 0x0001 in R1
LLB R1, 0x01

#store 0xC000 in R3
LLB R3, 0x00
LHB R3, 0xC0

# R6  -- Mask to get TX_empty
LLB R6, 0xF0
LHB R6, 0x00

# R7  -- Mask to get RX_filled
LLB R7, 0x0F

# R8  -- Character <CR>
LLB R8, 0x0D

################################ End hard-coded variables ############################################
################################ Begin of Baud rate change ###########################################
# Check switch values
LW R10, R3, 0x1  # read from switch

# Check if SW-configured baud is enabled (SW9 HIGH indicates enabled, LOW indicates disabled)
LLB R11, 0
LHB R11, 2
AND R11, R11, R10
B eq, DONE_BAUD		# if SW9 is low, use default baud rate 115200

LLB R11, 7		# mask out SW 0 through 2
AND R10, R10, R11	# ignore status of SW 3 through 9 from here

# Compare switch values with different setting 3'b000 is fastest, 3'b111 is slowest
LLB R11, 0
SUB R11, R10, R11
B EQ, BAUD_0
LLB R11, 1
SUB R11, R10, R11
B EQ, BAUD_1
LLB R11, 2
SUB R11, R10, R11
B EQ, BAUD_2
LLB R11, 3
SUB R11, R10, R11
B EQ, BAUD_3
LLB R11, 4
SUB R11, R10, R11
B EQ, BAUD_4
LLB R11, 5
SUB R11, R10, R11
B EQ, BAUD_5
LLB R11, 6
SUB R11, R10, R11
B EQ, BAUD_6
LLB R11, 7
SUB R11, R10, R11
B EQ, BAUD_7

BAUD_0:
LLB R9, 0x36
JAL SET_BAUD
B uncond, DONE_BAUD
BAUD_1:
LLB R9, 0x6C
JAL SET_BAUD
B uncond, DONE_BAUD
BAUD_2:
LLB R9, 0xD9
LHB R9, 0
JAL SET_BAUD
B uncond, DONE_BAUD
BAUD_3:
LLB R9, 0xB2
LHB R9, 1
JAL SET_BAUD
B uncond, DONE_BAUD
BAUD_4:
LLB R9, 0x64
LHB R9, 3
JAL SET_BAUD
B uncond, DONE_BAUD
BAUD_5:
LLB R9, 0x16
LHB R9, 5
JAL SET_BAUD
B uncond, DONE_BAUD
BAUD_6:
LLB R9, 0x2C
LHB R9, 0xA
JAL SET_BAUD
B uncond, DONE_BAUD
BAUD_7:
LLB R9, 0x58
LHB R9, 0x14
JAL SET_BAUD

DONE_BAUD:

################################ Begin of Baud rate change ###########################################
################################ Begin of operation ##################################################
JAL CLEAR # Clear the screen

JAL MOVECENTER # Move to the center of the screen

########## print “Hello World!\n” ##########
#print "H" (0x48)
LLB R2, 0x48     # store a byte in R2
JAL SEND
#print "e" (0x65)
LLB R2, 0x65     # store a byte in R2
JAL SEND
#print "l" (0x6C)
LLB R2, 0x6C     # store a byte in R2
JAL SEND
#print "l" (0x6C)
LLB R2, 0x6C     # store a byte in R2
JAL SEND
#print "o" (0x6F)
LLB R2, 0x6F     # store a byte in R2
JAL SEND
#print " " (0x20)
LLB R2, 0x20     # store a byte in R2
JAL SEND
#print "W" (0x57)
LLB R2, 0x57     # store a byte in R2
JAL SEND
#print "o" (0x6F)
LLB R2, 0x6F     # store a byte in R2
JAL SEND
#print "r" (0x72)
LLB R2, 0x72     # store a byte in R2
JAL SEND
#print "l" (0x6C)
LLB R2, 0x6C     # store a byte in R2
JAL SEND
#print "d" (0x64)
LLB R2, 0x64     # store a byte in R2
JAL SEND
#print "!" (0x21)
LLB R2, 0x21     # store a byte in R2
JAL SEND
#print "\n" (0x0A)
LLB R2, 0x0A     # store a byte in R2
JAL SEND
########## end print “Hello World!\n” ######

########## ask for response ################
JAL INDENT  # Call INDENT to insert 36 spaces
# Ask for name:
#"Name?"
#print "N" (0x4E)
LLB R2, 0x4E     # store a byte in R2
JAL SEND
#print "a" (0x61)
LLB R2, 0x61     # store a byte in R2
JAL SEND
#print "m" (0x6D)
LLB R2, 0x6D     # store a byte in R2
JAL SEND
#print "e" (0x65)
LLB R2, 0x65     # store a byte in R2
JAL SEND
#print ":" (0x3A)
LLB R2, 0x3A     # store a byte in R2
JAL SEND
#print " " (0x20)
LLB R2, 0x20     # store a byte in R2
JAL SEND
########## end for response ################

########## read response ###################
# Reading response:
# String start pointer 0x01FF -> R5
LLB R5, 0xFF
LHB R5, 0x01

# For loop
READ:
JAL WAIT_CHAR
LW R2, R3, 4     # read the first response into processor
SW R2, R5, 0     # store the char in data mem[ptr]
JAL SEND
SUB R5, R5, R1   # decrement the counter
# Check response with CR (0x0D)
SUB R2, R8, R2
B neq, READ      # if not CR, keep reading

#print "\n" (0x0A)
LLB R2, 0x0A     # store a byte in R2
JAL SEND
########## end reading response ########

########## print response ##############

JAL INDENT  # Call INDENT to insert 36 spaces

#print "H" (0x48)
LLB R2, 0x48     # store a byte in R2
JAL SEND
#print "e" (0x65)
LLB R2, 0x65     # store a byte in R2
JAL SEND
#print "l" (0x6C)
LLB R2, 0x6C     # store a byte in R2
JAL SEND
#print "l" (0x6C)
LLB R2, 0x6C     # store a byte in R2
JAL SEND
#print "o" (0x6F)
LLB R2, 0x6F     # store a byte in R2
JAL SEND
#print " " (0x20)
LLB R2, 0x20     # store a byte in R2
JAL SEND


########## print name from R5 ##############
# String start pointer 0x01FF -> R5
LLB R5, 0xFF
LHB R5, 0x01
PRINT:
JAL WAIT    # call wait to clear buffer before print
LW R2, R5, 0    # Get char from memory
JAL SEND
SUB R5, R5, R1  # Decrement counter
SUB R2, R2, R8
B neq, PRINT    # If not CR, keep printing
########## end print name ##################

HLT

################################ Functions ##################################################

#WAIT: Wait till there is an availiable space in the tx_buffer
WAIT:
LW R4, R3, 5        # read the status register and store the data in R4
AND R4, R4, R6      # apply mask and check if it has at least one availiable spot
B eq, WAIT          # if it has 0 availiable spot, wait
JR R15

#WAIT_CHAR: Wait till there is a character availiable in the rx_buffer
WAIT_CHAR:
LW R4, R3, 5        # read the status register and store the data in R4
AND R4, R4, R7      # keep the lower 4 bits
B eq, WAIT_CHAR     # if it is 0, wait (nothing to fetch)
JR R15

#INDENT: Indent 36 space before printing
INDENT:
ADD R14, R15, R0
# cursorrt(n) CUF       Move cursor right n columns     ^[[36C
LLB R2, 0x1B     # store a byte in R2
JAL SEND
LLB R2, 0x5B     # store a byte in R2
JAL SEND
LLB R2, 0x33     # store a byte in R2
JAL SEND
LLB R2, 0x36     # store a byte in R2
JAL SEND
LLB R2, 0x43     # store a byte in R2
JAL SEND
JR R14

# SEND: When this function is called, the data to send must be stored in R2
#       It will wait till there is one availiable spot and send the data.
SEND:
ADD R13, R15, R0
JAL WAIT         # call WAIT to ensure there is one empty spot
SW R2, R3, 4     # send lower byte of R2 to SPART queue
JR R13

# SET_BAUD: When this function is called, the 13-bits division buffer of baud rate is in R9
SET_BAUD: 
ADD R13, R15, R0
SW R9, R3, 0x6 # set lower byte of R9 to SPART Division Buffer lower byte
SRL R9, R9, 8    # shift by 8 bits to prepare the higher byte of the div buffer
SW R9, R3, 0x7 # set higher byte of R9 to SPART Division Buffer higher byte
JR R13

# CLEAR: Clear the screen
CLEAR:
ADD R14, R15, R0
#clearscreen ED2       Clear entire screen                    ^[[2J (0x1B,0x5B,0x32,0x4A)
LLB R2, 0x1B     # store a byte in R2
JAL SEND
LLB R2, 0x5B     # store a byte in R2
JAL SEND
LLB R2, 0x32     # store a byte in R2
JAL SEND
LLB R2, 0x4A     # store a byte in R2
JAL SEND
JR R14

# MOVECENTER: Move cursor to the "center"(9,36) of display 
MOVECENTER:
ADD R14, R15, R0
#hvpos(v,h) CUP        Move cursor to screen location v,h     ^[[9;36f
LLB R2, 0x1B     # store a byte in R2
JAL SEND
LLB R2, 0x5B     # store a byte in R2
JAL SEND
LLB R2, 0x39     # store a byte in R2
JAL SEND
LLB R2, 0x3B     # store a byte in R2
JAL SEND
LLB R2, 0x33     # store a byte in R2
JAL SEND
LLB R2, 0x37     # store a byte in R2
JAL SEND
LLB R2, 0x66     # store a byte in R2
JAL SEND
JR R14