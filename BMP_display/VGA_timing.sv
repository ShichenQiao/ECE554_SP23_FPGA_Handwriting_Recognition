module VGA_timing(clk25MHz, rst_n, VGA_BLANK_N, VGA_HS, VGA_SYNC_N, VGA_VS, xpix, ypix, addr_lead);
				
  input clk25MHz,rst_n;				// 25MHz clk, and asynch active low reset
  output logic VGA_BLANK_N;			// assert (low) during non-active pixels
  output logic VGA_HS;				// active low horizontal synch
  output VGA_SYNC_N;				// I think we just tie it low
  output logic VGA_VS;				// active low vertical synch
  output [9:0] xpix;				// x pixel location
  output reg [8:0] ypix;			// y pixel location
  output reg [18:0] addr_lead;		// address for videoRam.  Leads by 1.
  
  ///////////////////////
  // Needed Registers //
  /////////////////////
  reg [6:0] Htmr;		// used to time various durations of horizontal control
  reg [5:0] Vtmr;		// used to time various durations of vertical control
  reg [9:0] xpix_int;	// x pixel location (external version gated off when not in frame)
  
  /////////////////
  // SM outputs //
  ///////////////
  logic clr_Htmr,clr_Vtmr;
  logic en_pix_advance,en_frame;
  
  wire end_of_line;
  wire end_of_frame;
  
  ///////////////////////////////
  // define timing parameters //
  /////////////////////////////
  localparam HsynchWidth = 7'd95;		// 96 - 1
  localparam HBPWidth = 7'd47;			// 48 - 1
  localparam Columns = 10'd639;			// 640 - 1
  localparam HFPWidth = 7'd15;			// 16 - 1
 
  localparam VsynchWidth = 6'd1;		// 2 - 1	lines
  localparam VBPWidth = 6'd32;			// 33 - 1
  localparam Rows = 9'd479;				// 480 - 1
  localparam VFPWidth = 6'd9;			// 10 - 1 
  
  //localparam HsynchWidth = 7'd3;		// 96 - 1
  //localparam HBPWidth = 7'd7;			// 48 - 1
  //localparam Columns = 10'd7;			// 640 - 1
  //localparam HFPWidth = 7'd3;			// 16 - 1
 
  //localparam VsynchWidth = 9'd1;		// 2 - 1	lines
  //localparam VBPWidth = 9'd3;			// 33 - 1
  //localparam Rows = 9'd5;				// 480 - 1
  //localparam VFPWidth = 9'd1;			// 10 - 1 
	  
  /////////////////////////////////
  // Implement Horizontal timer //
  ///////////////////////////////
  always_ff @(posedge clk25MHz, negedge rst_n)
    if (!rst_n)
	  Htmr <= 7'h00;
	else if (clr_Htmr)
	  Htmr <= 7'h00;
	else
	  Htmr <= Htmr + 1;

  ///////////////////////////////
  // Implement Vertical timer //
  /////////////////////////////
  always_ff @(posedge clk25MHz, negedge rst_n)
    if (!rst_n)
	  Vtmr <= 9'h000;
	else if (clr_Vtmr)
	  Vtmr <= 9'h000;
	else if (end_of_line) 
	  Vtmr <= Vtmr + 1;
	  
  ///////////////////////////////
  // Implement pixel counters //
  /////////////////////////////  
  always_ff @(posedge clk25MHz, negedge rst_n)
    if (!rst_n)
	  xpix_int <= 10'h000;
	else if (end_of_line)
	  xpix_int <= 10'h000;
	else if (en_pix_advance)
	  xpix_int <= xpix_int + 1;
		
  assign end_of_line = (xpix_int==Columns) ? 1'b1 : 1'b0;
  assign xpix = xpix_int & {{10{en_frame}}};
  
  always_ff @(posedge clk25MHz, negedge rst_n)
    if (!rst_n)
	  ypix <= 9'h000;
	else if (end_of_frame)
	  ypix <= 9'h000;
	else if ((end_of_line) && en_frame)
	  ypix <= ypix + 1;
	  
  always_ff @(posedge clk25MHz, negedge rst_n)
    if (!rst_n)
	  addr_lead <= 19'h00001;
	else if ((end_of_line) && (ypix==Rows))
	  addr_lead <= 19'h00000;
	else if (en_pix_advance & en_frame)
	  addr_lead <= addr_lead + 1;
  		
  assign end_of_frame = ((ypix==Rows) && (end_of_line)) ? 1'b1 : 1'b0;
  
	  
  typedef enum reg[1:0] {H_SYNCH,H_BP,H_LINE,H_FP} Hstate_t;
  Hstate_t Hstate, nxt_Hstate;
  
  typedef enum reg[1:0] {V_SYNCH,V_BP,V_FRAME,V_FP} Vstate_t;
  Vstate_t Vstate, nxt_Vstate;

  ///////////////////////////////////////////////
  // Infer state flops for Horizontal machine //
  /////////////////////////////////////////////
  always_ff @(posedge clk25MHz, negedge rst_n)
    if (!rst_n)
	  Hstate <= H_SYNCH;
	else
	  Hstate <= nxt_Hstate;

  ///////////////////////////////////////////////////////////////
  // State transition and output logic for Horizontal machine //
  /////////////////////////////////////////////////////////////  
  always_comb begin
	clr_Htmr = 1'b0;
	en_pix_advance = 1'b0;
	VGA_HS = 1'b1;
	nxt_Hstate = Hstate;

    case (Hstate)
	  H_SYNCH : begin
		VGA_HS = 1'b0;
		if (Htmr==HsynchWidth) begin
		  clr_Htmr = 1'b1;
		  nxt_Hstate = H_BP;
		end
	  end
	  H_BP : begin
		if (Htmr==HBPWidth) begin
		  clr_Htmr = 1'b1;
		  nxt_Hstate = H_LINE;
		end
	  end
	  H_LINE : begin
	    en_pix_advance = 1'b1;
	    if (end_of_line) begin
		  clr_Htmr = 1'b1;
          nxt_Hstate = H_FP;
		end
	  end
	  H_FP : begin
		if (Htmr==HFPWidth) begin
		  clr_Htmr = 1'b1;
		  nxt_Hstate = H_SYNCH;
		end	    
	  end
	endcase
  end
  
  /////////////////////////////////////////////
  // Infer state flops for Vertical machine //
  ///////////////////////////////////////////
  always_ff @(posedge clk25MHz, negedge rst_n)
    if (!rst_n)
	  Vstate <= V_SYNCH;
	else
	  Vstate <= nxt_Vstate;

  /////////////////////////////////////////////////////////////
  // State transition and output logic for Vertical machine //
  ///////////////////////////////////////////////////////////  
  always_comb begin
	clr_Vtmr = 1'b0;
	VGA_VS = 1'b1;
	en_frame = 1'b0;
	nxt_Vstate = Vstate;

    case (Vstate)
	  V_SYNCH : begin
		VGA_VS = 1'b0;
		if ((Vtmr==VsynchWidth) && end_of_line) begin
		  clr_Vtmr = 1'b1;
		  nxt_Vstate = V_BP;
		end
	  end
	  V_BP : begin
		if ((Vtmr==VBPWidth) && end_of_line) begin
		  clr_Vtmr = 1'b1;
		  nxt_Vstate = V_FRAME;
		end
	  end
	  V_FRAME : begin
	    en_frame = 1'b1;
	    if (end_of_frame) begin
		  clr_Vtmr = 1'b1;
          nxt_Vstate = V_FP;
		end
	  end
	  V_FP : begin
		if ((Vtmr==VFPWidth) && end_of_line) begin
		  clr_Vtmr = 1'b1;
		  nxt_Vstate = V_SYNCH;
		end	    
	  end
	endcase
  end
  
  assign VGA_BLANK_N = en_pix_advance & en_frame;
  
  assign VGA_SYNC_N = 1'b0;
  
endmodule

