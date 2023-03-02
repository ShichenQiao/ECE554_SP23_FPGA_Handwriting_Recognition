module RAW2GRAY(oGrey,
				oDVAL,
				iX_Cont,
				iY_Cont,
				iDATA,
				iDVAL,
				iCLK,
				iRST,
				oEdge
				);

input	[10:0]	iX_Cont;
input	[10:0]	iY_Cont;
input	[11:0]	iDATA;
input			iDVAL;
input			iCLK;
input			iRST;
output	[11:0]	oGrey;
output			oDVAL;
output			oEdge;
wire	[11:0]	mDATA_0;
wire	[11:0]	mDATA_1;
wire	[12:0]	mDATA_sum;
reg		[12:0]	mDATA_d;
reg		[13:0]	mCCD_G;
reg				mDVAL;
reg				mEdge;

assign	oGrey	=	mCCD_G[13:2];
assign	oDVAL	=	mDVAL;
assign  oEdge   =   mEdge;

assign mDATA_sum = (mDATA_0+mDATA_1);

Line_Buffer1 	u0	(	.clken(iDVAL),
						.clock(iCLK),
						.shiftin(iDATA),
						.taps0x(mDATA_1),
						.taps1x(mDATA_0)	);
					
always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	begin
		mCCD_G	<=	0;
		mDATA_d	<=	0;
		mDVAL	<=	0;
	end
	else
	begin
		mDATA_d	<= 	mDATA_sum;
		mDVAL	<=	{iY_Cont[0]|iX_Cont[0]}	?	1'b0	:	iDVAL;
		mEdge   <=  (iY_Cont==0||iX_Cont==0||iY_Cont==11'd479||iX_Cont==11'd639);
		mCCD_G	<=	mDATA_sum+mDATA_d;
	end
end

endmodule


