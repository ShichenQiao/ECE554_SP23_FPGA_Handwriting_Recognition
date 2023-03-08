// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Thu Jul 11 11:26:45 2013
// ============================================================================

//`define ENABLE_HPS
//`define ENABLE_USB

module DE1_SoC_CAMERA(

      ///////// CLOCK2 /////////
      input              CLOCK2_50,

      ///////// CLOCK /////////
      input              CLOCK_50,

      ///////// DRAM /////////
      output      [12:0] DRAM_ADDR,
      output      [1:0]  DRAM_BA,
      output             DRAM_CAS_N,
      output             DRAM_CKE,
      output             DRAM_CLK,
      output             DRAM_CS_N,
      inout       [15:0] DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_RAS_N,
      output             DRAM_UDQM,
      output             DRAM_WE_N,


      ///////// KEY /////////
      input       [3:0]  KEY,

      ///////// LEDR /////////
      output      [9:0]  LEDR,

      ///////// SW /////////
      input       [9:0]  SW,

      ///////// VGA /////////
      output      [7:0]  VGA_B,
      output             VGA_BLANK_N,
      output             VGA_CLK,
      output      [7:0]  VGA_G,
      output             VGA_HS,
      output      [7:0]  VGA_R,
      output             VGA_SYNC_N,
      output             VGA_VS,
		
		//////////// GPIO1, GPIO1 connect to D5M - 5M Pixel Camera //////////
	   input		   [11:0] D5M_D,
      input		          D5M_FVAL,
      input		          D5M_LVAL,
      input		          D5M_PIXLCLK,
      output		       D5M_RESET_N,
      output		       D5M_SCLK,
      inout		          D5M_SDATA,
      input		          D5M_STROBE,
      output		       D5M_TRIGGER,
      output		       D5M_XCLKIN
);


//=======================================================
//  REG/WIRE declarations
//=======================================================
wire			 [15:0]			Read_DATA1;
wire	       [15:0]			Read_DATA2;

wire			 [11:0]			mCCD_DATA;
wire								mCCD_DVAL;
wire								mCCD_DVAL_d;
wire	       [15:0]			X_Cont;
wire	       [15:0]			Y_Cont;
wire	       [9:0]			X_ADDR;
wire	       [31:0]			Frame_Cont;
wire								DLY_RST_0;
wire								DLY_RST_1;
wire								DLY_RST_2;
wire								DLY_RST_3;
wire								DLY_RST_4;
wire								Read;
reg		    [11:0]				rCCD_DATA;
reg								rCCD_LVAL;
reg								rCCD_FVAL;

wire	       [11:0]			dCCD_R;
wire	       [11:0]			dCCD_G;
wire	       [11:0]			dCCD_B;
wire							dCCD_DVAL;

wire	       [11:0]			sCCD_R;
wire	       [11:0]			sCCD_G;
wire	       [11:0]			sCCD_B;
wire							sCCD_DVAL;

wire								sdram_ctrl_clk;
wire	       [9:0]			oVGA_R;   				//	VGA Red[9:0]
wire	       [9:0]			oVGA_G;	 				//	VGA Green[9:0]
wire	       [9:0]			oVGA_B;   				//	VGA Blue[9:0]

//power on start
wire             				auto_start;
//=======================================================
//  Structural coding
//=======================================================
// D5M
assign	D5M_TRIGGER	=	1'b1;  // tRIGGER
assign	D5M_RESET_N	=	DLY_RST_1;

assign   VGA_CTRL_CLK = VGA_CLK;


//fetch the high 8 bits
assign  VGA_R = oVGA_R[9:2];
assign  VGA_G = oVGA_G[9:2];
assign  VGA_B = oVGA_B[9:2];

//D5M read 
always@(posedge D5M_PIXLCLK)
begin
	rCCD_DATA 	<=	D5M_D;
	rCCD_LVAL	<=	D5M_LVAL;
	rCCD_FVAL	<=	D5M_FVAL;
end


//auto start when power on
assign auto_start = ((KEY[0])&&(DLY_RST_3)&&(!DLY_RST_4))? 1'b1:1'b0;
//Reset module
Reset_Delay			u2	(	
							.iCLK(CLOCK_50),
							.iRST(KEY[0]),
							.oRST_0(DLY_RST_0),
							.oRST_1(DLY_RST_1),
							.oRST_2(DLY_RST_2),
							.oRST_3(DLY_RST_3),
							.oRST_4(DLY_RST_4)
						   );
//D5M image capture
CCD_Capture			u3	(	
							.oDATA(mCCD_DATA),
							.oDVAL(mCCD_DVAL),
							.oX_Cont(X_Cont),
							.oY_Cont(Y_Cont),
							.oFrame_Cont(Frame_Cont),
							.iDATA(rCCD_DATA),
							.iFVAL(rCCD_FVAL),
							.iLVAL(rCCD_LVAL),
							.iSTART(!KEY[3]|auto_start),
							.iEND(!KEY[2]),
							.iCLK(~D5M_PIXLCLK),
							.iRST(DLY_RST_2)
						   );
//D5M raw date convert to RGB data

RAW2GRAY				u4	(	
							.iCLK(D5M_PIXLCLK),
							.iRST(DLY_RST_1),
							.iDATA(mCCD_DATA),
							.iDVAL(mCCD_DVAL),
//							.oRed(dCCD_R),
							.oGrey(dCCD_G),
//							.oBlue(dCCD_B),
							.oDVAL(dCCD_DVAL),
							.iX_Cont(X_Cont),
							.iY_Cont(Y_Cont)
						   );

						   assign	dCCD_R = dCCD_G;
						   assign	dCCD_B = dCCD_G;

assign {sCCD_R,sCCD_G,sCCD_B,sCCD_DVAL}={dCCD_R,dCCD_G,dCCD_B,dCCD_DVAL};
							

												
sdram_pll 			u6	(
							.refclk(CLOCK_50),
							.rst(1'b0),
							.outclk_0(sdram_ctrl_clk),
							.outclk_1(DRAM_CLK),
							.outclk_2(D5M_XCLKIN),    //25M
					      .outclk_3(VGA_CLK)       //25M

						   );



//SDRam Read and Write as Frame Buffer
Sdram_Control	   u7	(	//	HOST Side						
						   .RESET_N(KEY[0]),
							.CLK(sdram_ctrl_clk),

							//	FIFO Write Side 1
							.WR1_DATA({1'b0,sCCD_G[11:7],sCCD_B[11:2]}),
							.WR1(sCCD_DVAL),
							.WR1_ADDR(0),
                     .WR1_MAX_ADDR(640*480),
						   .WR1_LENGTH(8'h50),
		               .WR1_LOAD(!DLY_RST_0),
							.WR1_CLK(~D5M_PIXLCLK),

							//	FIFO Write Side 2
							.WR2_DATA({1'b0,sCCD_G[6:2],sCCD_R[11:2]}),
							.WR2(sCCD_DVAL),
							.WR2_ADDR(23'h100000),
							.WR2_MAX_ADDR(23'h100000+640*480),
							.WR2_LENGTH(8'h50),
							.WR2_LOAD(!DLY_RST_0),				
							.WR2_CLK(~D5M_PIXLCLK),

                     //	FIFO Read Side 1
						   .RD1_DATA(Read_DATA1),
				        	.RD1(Read),
				        	.RD1_ADDR(0),
                     .RD1_MAX_ADDR(640*480),
							.RD1_LENGTH(8'h50),
							.RD1_LOAD(!DLY_RST_0),
							.RD1_CLK(~VGA_CTRL_CLK),
							
							//	FIFO Read Side 2
						   .RD2_DATA(Read_DATA2),
							.RD2(Read),
							.RD2_ADDR(23'h100000),
                     .RD2_MAX_ADDR(23'h100000+640*480),
							.RD2_LENGTH(8'h50),
                   	.RD2_LOAD(!DLY_RST_0),
							.RD2_CLK(~VGA_CTRL_CLK),
										
							//	SDRAM Side
						   .SA(DRAM_ADDR),
							.BA(DRAM_BA),
							.CS_N(DRAM_CS_N),
							.CKE(DRAM_CKE),
							.RAS_N(DRAM_RAS_N),
							.CAS_N(DRAM_CAS_N),
							.WE_N(DRAM_WE_N),
							.DQ(DRAM_DQ),
							.DQM({DRAM_UDQM,DRAM_LDQM})
						   );
							
				
//D5M I2C control
I2C_CCD_Config 	u8	(	//	Host Side
							.iCLK(CLOCK2_50),
							.iRST_N(DLY_RST_2),
							.iEXPOSURE_ADJ(KEY[1]),
							.iEXPOSURE_DEC_p(SW[0]),
							.iZOOM_MODE_SW(SW[9]),
							//	I2C Side
							.I2C_SCLK(D5M_SCLK),
							.I2C_SDAT(D5M_SDATA)
						   );
//VGA DISPLAY
VGA_Controller	  u1	(	//	Host Side
							.oRequest(Read),
							.iRed(Read_DATA2[9:0]),
					      .iGreen({Read_DATA1[14:10],Read_DATA2[14:10]}),
						   .iBlue(Read_DATA1[9:0]),
						
							//	VGA Side
							.oVGA_R(oVGA_R),
							.oVGA_G(oVGA_G),
							.oVGA_B(oVGA_B),
							.oVGA_H_SYNC(VGA_HS),
							.oVGA_V_SYNC(VGA_VS),
							.oVGA_SYNC(VGA_SYNC_N),
							.oVGA_BLANK(VGA_BLANK_N),
							//	Control Signal
							.iCLK(VGA_CTRL_CLK),
							.iRST_N(DLY_RST_2),
							.iZOOM_MODE_SW(SW[9])
						   );

endmodule
