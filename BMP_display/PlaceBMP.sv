module PlaceBMP(clk,rst_n,add_fnt,fnt_indx,add_img,rem_img,image_indx,
                xloc,yloc,waddr,wdata,we);

  
  input clk,rst_n;
  input add_fnt;			// add a character
  input [5:0] fnt_indx;	// one of 42 characters
  // 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ =>,()
  input add_img;			// pulse high for one clock to add image
  input rem_img;			// pulse high for one clock to remove image
  input [4:0] image_indx; 	// index of image in image memory (32 possible)
  input [9:0] xloc;			// x location of image to register
  input [8:0] yloc;			// y location of image to register
  output reg [18:0] waddr;		// write address to videoMem
  output logic [8:0] wdata;		// write 9-bit pixel to videoMem
  output reg we;
  
  //////////////////////////////////////////
  // Declare any internal registers next //
  ////////////////////////////////////////
  reg [15:0] bmp_addr;				// address to local ROMs that contain images
  reg [15:0] bmp_addr_end;
  reg [13:0] font_addr;
  reg [3:0] font_x_cnt;
  reg [3:0] font_y_cnt;
  reg [9:0] xwid;					// stores x width of image
  reg [18:0] waddr_wrap;			// holds when to advance linear address into videoMem
  reg [4:0] indx;					// 
  reg [5:0] font_indx;				// 1 of 42
  reg rem;							// set if removing image
  
  typedef enum reg[2:0] {IDLE,ADV1,ADV2,XRD,YRD,WRT,WRT2} state_t;
  
  state_t state, nxt_state;
  
  ///////////////////////////
  // Outputs of SM follow //
  /////////////////////////  
  logic captureIndx,captureXwid,captureYwid;
  logic bmp_addr_inc;
  logic waddr_init,waddr_inc;
  logic fnt_addr_inc;
  
  ///////////////////////////
  // Internal nets follow //
  /////////////////////////
  wire [8:0] bmp_read0;
  wire [9:0] bmp_read1;
  wire [9:0] bmp_read2;			// add more for more images
  wire [8:0] bmp_read;			// muxed output from BMP ROM
  wire waddr_wrap_en;
  wire fnt_wrap;
 
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  xwid <= 10'h000;
	else if (captureXwid)
	  xwid <= bmp_read;
  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  bmp_addr_end <= 16'h0000;
	else if (captureXwid)
	  bmp_addr_end <= bmp_read;		// bmp_read is currently = xwidth
    else if (captureYwid)
      bmp_addr_end <= bmp_addr_end*bmp_read + 16'd2;	
	  
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    bmp_addr <= 16'h0000;
	  else if (captureIndx)
	    bmp_addr <= 16'h0000;
	  else if (bmp_addr_inc)
	    bmp_addr <= bmp_addr + 1;
		
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    font_addr <= 16'h0000;
	  else if (captureIndx)
	    font_addr <= 4'd13*fnt_indx;
	  else if (fnt_wrap)
	    font_addr <= font_addr + 10'd531;	// 544 - 13
	  else if (fnt_addr_inc)
	    font_addr <= font_addr + 1;
		
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    font_x_cnt <= 4'h0;
	  else if (fnt_wrap | captureIndx)
	    font_x_cnt <= 4'h0;
	  else if (fnt_addr_inc)
	    font_x_cnt <= font_x_cnt + 1;
	  
  assign fnt_wrap = (font_x_cnt==4'd13) ? 1'b1 : 1'b0;
  
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    font_y_cnt <= 4'h0;
	  else if (captureIndx)
	    font_y_cnt <= 4'h0;
	  else if (fnt_wrap)
	    font_y_cnt <= font_y_cnt + 1;
  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  indx <= 5'h00;
	else if (captureIndx)
	  indx <= image_indx;
	  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  font_indx <= 6'h00;
	else if (captureIndx)
	  font_indx <= fnt_indx;
	  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  rem <= 1'b0;
	else if (captureIndx)
	  rem <= rem_img;
		
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    waddr <= 18'h00000;
	  else if (captureIndx)
	    waddr <= yloc*10'd640 + xloc;
	  else if (waddr_wrap_en)
	    waddr <= waddr + (18'd641 - xwid);
	  else if (fnt_wrap)
	    waddr <= waddr + 18'd628;
	  else if (waddr_inc)
	    waddr <= waddr + 1;

  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    waddr_wrap <= 18'h00000;
	  else if (captureYwid)
	    waddr_wrap <= waddr + (xwid - 9'h001);
	  else if (waddr_wrap_en)
	    waddr_wrap <= waddr_wrap + 18'd640;
		
  assign waddr_wrap_en = (waddr==waddr_wrap) ? 1'b1 : 1'b0;
		
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  state <= IDLE;
	else
	  state <= nxt_state;
  
  always_comb begin
    nxt_state = state;
    captureIndx = 0;
	captureXwid = 0;
	captureYwid = 0;
	bmp_addr_inc = 0;
	waddr_init = 0;
	waddr_inc = 0;
	fnt_addr_inc = 0;
	we = 0;
	wdata = 9'hxxx;

	case (state)
	  IDLE: begin
	    if (add_img | rem_img) begin
		  captureIndx = 1;
		  nxt_state = ADV1;
		end else if (add_fnt) begin
		  captureIndx = 1;
		  nxt_state = ADV2;
		end
	  end
	  ADV1: begin	// this state is about advancing bmp_address
	    bmp_addr_inc = 1;
		nxt_state = XRD;
	  end
	  ADV2: begin	// this state is about advancing bmp_address
	    fnt_addr_inc = 1;
		nxt_state = WRT2;
	  end
	  XRD: begin
	    captureXwid = 1;
		bmp_addr_inc = 1;
		nxt_state = YRD;
	  end
	  YRD: begin
	    captureYwid = 1;
		bmp_addr_inc = 1;
		waddr_init = 1;
		nxt_state = WRT;
	  end
	  WRT: begin
	    if (bmp_addr<bmp_addr_end) begin
		  bmp_addr_inc = 1;
		  wdata = (rem) ? 9'h000 : bmp_read;
		  we = (bmp_read==9'h088) ? 1'b0 : 1'b1;	// 64,32,16 is treated as transparent
		  waddr_inc = 1;
		end else
		  nxt_state = IDLE;
	  end
	  WRT2: begin
	    if ((font_y_cnt==4'd15) && (fnt_wrap))
		  nxt_state = IDLE;
		else if (fnt_wrap) begin
		  nxt_state = ADV2;
		end else begin
		  fnt_addr_inc = 1;
		  wdata = bmp_read;
		  we = (bmp_read==9'h088) ? 1'b0 : 1'b1;	// 64,32,16 is treated as transparent
		  waddr_inc = 1;
		end
	  end
	  default: nxt_state = IDLE;
	endcase
	  
  end
  
  /////////////////////////////////
  // BMP ROMs and mux are below //
  ///////////////////////////////
  BMP_ROM_Font  iROM0(.clk(clk),.addr(font_addr),.dout(bmp_read0));
  BMP_ROM_Mario iROM1(.clk(clk),.addr(bmp_addr),.dout(bmp_read1));
  BMP_ROM_Bucky iROM2(.clk(clk),.addr(bmp_addr),.dout(bmp_read2));
  assign bmp_read = (fnt_addr_inc) ? bmp_read0 :
                    (indx==5'd01) ? bmp_read1 :
					bmp_read2;
  
endmodule