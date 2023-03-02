module conv3x3(iCLK, iRST, iEN, iX0, iX1, iX2, oY, oEN, iSW, iEdge);
parameter XWIDTH=12;
parameter YWIDTH=12;

input iCLK, iRST, iEN, iEdge;
input [XWIDTH-1:0] iX0, iX1, iX2;
input iSW;
output [YWIDTH-1:0] oY;
output oEN;

wire [YWIDTH-1:0] oY_vertical, oY_horizontal;

reg [XWIDTH-1:0] fin [0:2][0:2];
reg edges [0:1];
reg oEN;

wire [XWIDTH+2:0] left_row, right_row;
assign left_row = (fin[0][0]+fin[2][0])+{fin[1][0],1'b0};
assign right_row = (fin[0][2]+fin[2][2])+{fin[1][2],1'b0};
assign oY_horizontal = left_row>right_row?(left_row-right_row):(right_row-left_row);

wire [XWIDTH+2:0] top_row, bottom_row;
assign top_row = (fin[0][0]+fin[0][2])+{fin[0][1],1'b0};
assign bottom_row = (fin[2][0]+fin[2][2])+{fin[2][1],1'b0};
assign oY_vertical = top_row>bottom_row?(top_row-bottom_row):(bottom_row-top_row);

assign oY=edges[1]?(iSW?oY_vertical:oY_horizontal):0;

//wire [XWIDTH+2:0] neighbors;
//assign neighbors = ((fin[0][0]+fin[0][1])+(fin[0][2]+fin[1][0])) +
//								((fin[1][2]+fin[2][0])+(fin[2][1]+fin[2][2]));
//assign oY = (neighbors[XWIDTH+2:3]>fin[1][1])?(neighbors[XWIDTH+2:3]-fin[1][1]):(fin[1][1]-neighbors[XWIDTH+2:3]);
								
integer i,j;					
always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	begin
		oEN<=0;
		for (i=0; i<3; i=i+1) 
		begin
			for (j=0; j<3; j=j+1) 
			begin
				fin[i][j] <= 0;
			end
		end
	end
	else
	begin
		oEN<=iEN;
		fin[0][0] <= iX0;
		fin[1][0] <= iX1;
		fin[2][0] <= iX2;
		edges[0] <= iEdge;
		edges[1] <= edges[0];
		
		for (i=0; i<3; i=i+1) 
		begin
			fin[i][1] <= fin[i][0];
			fin[i][2] <= fin[i][1];
		end	
	end
end

endmodule