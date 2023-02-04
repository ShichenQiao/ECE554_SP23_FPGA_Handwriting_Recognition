			ADD R1, R0, R0
			LHB R1, 0xC0
RDSW:		LW  R2, R1, 1
			SW  R2, R1, 0
			B UNCOND, RDSW
