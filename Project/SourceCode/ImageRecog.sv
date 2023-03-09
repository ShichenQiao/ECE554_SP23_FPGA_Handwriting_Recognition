module ImageRecog(

    //////////// CLOCK //////////
    input                           ref_clk,

    //////////// SDRAM //////////    
    output            [12:0]        DRAM_ADDR,
    output             [1:0]        DRAM_BA,
    output                          DRAM_CAS_N,
    output                          DRAM_CKE,
    output                          DRAM_CLK,
    output                          DRAM_CS_N,
    inout             [15:0]        DRAM_DQ,
    output                          DRAM_LDQM,
    output                          DRAM_RAS_N,
    output                          DRAM_UDQM,
    output                          DRAM_WE_N,

    //////////// RST_n ////////
    input                           RST_n,
    //////////// KEY //////////
    input              [3:0]        KEY,

    //////////// LED //////////
    output reg         [9:0]        LEDR,

    //////////// SW //////////
    input              [9:0]        SW,

    //////////// VGA //////////
    output                          VGA_BLANK_N,
    output             [7:0]        VGA_B,
    output                          VGA_CLK,
    output             [7:0]        VGA_G,
    output                          VGA_HS,
    output             [7:0]        VGA_R,
    output                          VGA_SYNC_N,
    output                          VGA_VS,

    //////////// GPIO_1, GPIO_1 connect to D5M - 5M Pixel Camera //////////
    input             [11:0]        D5M_D,
    input                           D5M_FVAL,
    input                           D5M_LVAL,
    input                           D5M_PIXCLK,
    output                          D5M_RESET_N,
    output                          D5M_SCLK,
    inout                           D5M_SDATA,
    input                           D5M_STROBE,
    output                          D5M_TRIGGER,
    output                          D5M_XCLKIN
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
    wire rst_n;                		// synchronized active low reset
    wire [31:0] addr;            	// dst_EX_DM, result from ALU
    wire [31:0] rdata;            	// exteral data input from the switches, 16'hDEAD if addr != 32'hC001
    wire [31:0] wdata;            	// data from cpu that will reflect on LEDs if addr == 32'hC000 during write
    wire update_LED;            	// update LED status if addr == 32'hC000 and we is set
    wire [7:0] spart_databus;       // databus for communcation with spart
    wire re, we;					// read enable and write enable from proc
    wire spart_cs_n;				// active low chip select signal for spart
    wire clk;
//=======================================================
//  Structural coding
//=======================================================
	// If no external memory mapped device is used, put 32'hDEAD on rdata
    assign rdata = ((addr == 32'h0000C001) & re) ? {22'h000000, SW} :			// 32'hC001 maps to switches, only lower 10 bits are used since only 10 SWs
                   (addr[31:2]==30'h00003001 & re) ? {24'h000000,spart_databus} :	// 16'hC004 - 16'hC007 maps to spart's bidirectional data bus
				   32'h0000DEAD;        
 
    assign spart_databus = (addr[31:2]==32'h00003001 & we) ? wdata[7:0] : 8'hzz;		// spart databus traffic control

    assign spart_cs_n = ~(addr[31:2]==32'h3001 & (we | re));				// enable spart only when addr is correct and either read or write is enabled

    assign update_LED = (addr == 32'h0000C000) & we;            // make testbench more straight forward, LEDs map to 16'hC000

    // Considering LED as a "memory", so picked negedge trigged flops
    always @(negedge clk, negedge rst_n)
        if(!rst_n)
            LEDR <= 10'h000;                	// LED output default to all OFF
        else if (update_LED)
            LEDR <= wdata[9:0];                	// data is 32 bit, but only have 10 LEDs, use lower bits

//=======================================================
//  Initialize modules
//=======================================================
    // push button input synchronization
    rst_synch irst_synch(
        .RST_n(RST_n),
        .clk(clk),
        .rst_n(rst_n),
        .pll_locked(pll_locked)
    );

    // iCPU
    cpu iCPU(
		.clk(clk),
		.rst_n(rst_n),
		.rdata(rdata),
		.addr(addr),
		.re(re),
		.we(we),
		.wdata(wdata)
	);

    // spart transmittion protocol
    spart iSPART(
		.clk(clk),
		.rst_n(rst_n),
		.iocs_n(spart_cs_n),
		.iorw_n(~we),			// read on high, write on low
		.tx_q_full(),			// not used because proc should read status register to "access" this value
		.rx_q_empty(),			// not used because proc should read status register to "access" this value
		.ioaddr(addr[1:0]),
		.databus(spart_databus),
		.TX(TX),
		.RX(RX)
	);

    PLL iPLL(
        .refclk(ref_clk),
        .rst(~RST_n),
        .outclk_0(clk),             // 50M
        .outclk_1(sdram_ctrl_clk),  // 100M
        .outclk_2(DRAM_CLK),        // 100M with phase 7500ps shift
        .outclk_3(D5M_XCLKIN),      //25M
        .outclk_4(VGA_CLK),         //25M
        .locked(pll_locked)
    );


endmodule
