			ADD R1, R0, R0
			LHB R1, 0xC0			# R0 <= 0xC000
			LLB R3, 0xFF
			LHB R3, 0x03			# R3 <= 0x03FF (meaning all 10 SW are ON)
INPUT:		LW  R2, R1, 1			# read switch(addr=0xC001) status to R2
			SUB R4, R2, R3			# check if all switches are ON
			B EQ, EXIT				# if all SWs are ON, Halt for good
			SW  R2, R1, 0			# otherwise, reflect SW status to LEDs
			B UNCOND, INPUT			# then loop back to read SW
EXIT:		HLT						# all LEDs but the one corresponding to the last switch pulled up are ON
