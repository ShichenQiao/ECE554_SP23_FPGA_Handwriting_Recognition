module CODEC_cfg(clk,rst_n,SDA,SCL,cfg_done);

  input clk, rst_n;

  output reg cfg_done;
  output SCL;			// I2C clock
  inout SDA;			// I2C data

  // 7 16-bit commands to send
  localparam bit [15:0] cmds [0:6] = '{
    16'h0105,
	16'h0305,
	16'h0812,
	16'h0A06,
	16'h0C62,
	16'h0E01,
	16'h1201
  };

  logic [17:0] timer;
  logic clr_timer;
  logic [2:0] idx;		// index of current cmd being sent in the cmds array
  logic [15:0] cmd;
  logic inc_idx;
  logic wrt;
  logic done, err;		// not used

  assign cmd = cmds[idx];

  typedef enum logic [1:0] {IDLE, WCFG, WAIT, DONE} state_t;
  state_t state, nxt_state;

  // state reg
  always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
	  state <= IDLE;
	else
	  state <= nxt_state;

  // 18 bit timer
  always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
	  timer <= '0;
	else if (clr_timer)
	  timer <= '0;
	else
	  timer <= timer + 1;

  // command index
  always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
	  idx <= 3'b000;
	else if (inc_idx)
	  idx <= idx + 1;

  // SM control
  always_comb begin
    inc_idx = 1'b0;
	wrt = 1'b0;
	cfg_done = 1'b0;
	clr_timer = 1'b0;
    nxt_state = state;

    case(state)
	  IDLE: begin
	    if(&timer)
		  nxt_state = WCFG;
	  end
	  WCFG: begin
	    wrt = 1'b1;
		clr_timer = 1'b1;
		nxt_state = WAIT;
	  end
	  WAIT: begin
	    if(&timer[10:0]) begin		// wait 2048 cycles for SPI transmission
		  if(idx == 6) begin
		    nxt_state = DONE;
		  end
		  else begin
		    inc_idx = 1'b1;
			nxt_state = WCFG;
		  end
		end
	  end
	  DONE: begin
	    cfg_done = 1'b1;
	  end
	endcase
  end

  /////////////////////////////
  // Instantiate I2C Master //
  ///////////////////////////
  I2C24Wrt iDUT(.clk(clk),.rst_n(rst_n),.data16(cmd),.wrt(wrt),.done(done),
           .err(err),.SCL(SCL),.SDA(SDA));

endmodule
