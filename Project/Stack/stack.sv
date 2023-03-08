// This is a 32x1024 stack for PUSH and POP instructions
// Only one operation can be performed at a time
module stack(clk, rst_n, push, pop, wdata,rdata);
  input clk;                  // system clock
  input push;                 // write into stack
  input pop;                  // pop from stack
  input [31:0] wdata;         // data to write
  output [31:0] rdata;        // read data output
  
  reg [31:0] mem [1023:0];    // 32 by 1024 SRAM block
  
  reg [10:0] addr;            // 10 bit address for stack pointer, 1 extra bit for 1024th data
  wire full, empty;           // signals to control the edge behavior

  assign rdata = mem[addr];
  assign full = addr == 11'h400;
  assign empty = addr == 10'h000;

  // negedge triggered memory
  always @(negedge clk) begin
    if(push & ~full)
      mem[addr] <= wdata;
  end

  always @(negedge clk, negedge rst_n) begin
    if (!rst_n)
      addr <= 11'h000;
    else if (push & ~full)
      addr <= addr + 11'h001;
    else if (pop & ~empty)
      addr <= addr - 11'h001;
  end
  
endmodule