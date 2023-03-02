module imgproc(	oRed,
				oGreen,
				oBlue,
				oDVAL,
				iX_Cont,
				iY_Cont,
				iDATA,
				iDVAL,
				iCLK,
				iRST,
				iSW
				);
parameter GWIDTH=12;				
				
input	[10:0]	iX_Cont;
input	[10:0]	iY_Cont;
input	[11:0]	iDATA;
input			iDVAL;
input			iCLK;
input			iRST;
input 			iSW;
output	[11:0]	oRed;
output	[11:0]	oGreen;
output	[11:0]	oBlue;
output			oDVAL;
wire	[11:0]	mDATA_0;
wire	[11:0]	mDATA_1;
reg		[11:0]	mDATAd_0;
reg		[11:0]	mDATAd_1;

wire [GWIDTH-1:0]	cGrey;
wire				cDVAL,cEdge;
wire [GWIDTH-1:0] gb_out[0:2];
wire				gbDVAL,gbEdge;
wire [GWIDTH-1:0] conv_out;
wire conv_val;

RAW2GRAY	R2G	(
					.oGrey(cGrey),
					.oDVAL(cDVAL),
					.iX_Cont(iX_Cont),
					.iY_Cont(iY_Cont),
					.iDATA(iDATA),
					.iDVAL(iDVAL),
					.iCLK(iCLK),
					.iRST(iRST),
					.oEdge(cEdge)
					);

grey_buffer	GB	(
					.clk(~iCLK),
					.rst(iRST),
					.enable(cDVAL),
					.iEdge(cEdge),
					.oEdge(gbEdge),
					.sr_in(cGrey),
					.sr_tap_one(gb_out[0]), 
					.sr_tap_two(gb_out[1]), 
					.sr_out(gb_out[2]),
					.valid(gbDVAL)
					);

conv3x3	CONV	(
					.iCLK(iCLK),
					.iRST(iRST),
					.iEN(gbDVAL&cDVAL),
					.iX0(gb_out[0]),
					.iX1(gb_out[1]),
					.iX2(gb_out[2]),
					.iSW(iSW),
					.iEdge(gbEdge),
					.oY(conv_out),
					.oEN(conv_val)
					);

assign oRed = conv_out;
assign oGreen = conv_out;
assign oBlue = conv_out;
assign oDVAL = conv_val;
					
endmodule
