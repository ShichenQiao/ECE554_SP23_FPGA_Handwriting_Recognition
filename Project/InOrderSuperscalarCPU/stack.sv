// This is a 32x1024 stack for PUSH and POP instructions
// It will allow two instructions in the same cycle.
// It can perform two push, two pop, push+pop or pop+push
// pop0 and pop1 are for instr_0, push1 and pop1 are for inst_1, single instruction CANNOT enable both push&pop (eg. push1+pop1)
module stack(clk, rst_n, push0, push1, pop0, pop1, wdata0, wdata1,stack0_EX_DM, stack1_EX_DM);
  input clk;                                    // system clock
  input rst_n;                                  // active low async reset
  input push0, push1;                           // write into stack
  input pop0, pop1;                             // pop from stack
  input [31:0] wdata0, wdata1;                  // data to write
  output reg [31:0] stack0_EX_DM, stack1_EX_DM; // flopped stack read result

  // internal reg/wire
  wire [31:0] rdata0, rdata1;                    // read data output

  reg [10:0] addr;            // 10 bit address for stack pointer, 1 extra bit for 1024th data
  wire full, empty;           // signals to control the edge behavior
  wire near_full, near_empty; // signals to control the behavior where there is only one slot to pop/push
  wire address_a, wren_a, address_b, wren_b; // control signal for M10K ram

  assign full = addr == 11'h400;
  assign near_full = addr == 11'h3FF;
  assign empty = addr == 10'h000;
  assign near_empty = addr == 10'h001;

  // if push0 & pop1, bypass input to output, addr does not change
  // if pop0 & push1, return previous result and replace the previous memory with new address, addr does not change
  // if push0, push wdata0 into stack, addr += 1
  // if push1, push wdata1 into stack, addr += 1
  // if pop0, pop data into stack0_EX_DM, addr -= 1
  // if pop1, pop data into stack1_EX_DM, addr -= 1
  // if push0 & push1, push wdata0 first and then push wdata1, addr += 2
  // if pop0 & pop1, pop, data into stack0_EX_DM and stack1_EX_DM, respectively, addr -= 2
  // else, illegal operations


  // negedge triggered memory
  /*
  always @(negedge clk) begin
    if(push0 & push1 & ~near_full & ~full)begin
      mem[addr]   <= wdata0;
      mem[addr+1] <= wdata1;
    end 
    else if (push0 & ~full & ~pop1)
      mem[addr] <= wdata0;
    else if (push1 & ~full)
      mem[addr] <= wdata1;

    if(pop0 & pop1 & ~near_empty & ~empty)begin
      rdata0 <= mem[addr];
      rdata1 <= mem[addr-1];
    end else if(pop0 & ~empty)
      rdata0 <= mem[addr];
    else if(pop1 & ~empty)
      rdata1 <= mem[addr];
  end
*/

  // addr control logic
  always @(negedge clk, negedge rst_n) begin
    if (!rst_n)
      addr <= 11'h000;
    else if ((push0 & pop1) | (push1 & pop0))
      addr <= addr;
    else if (push0 & push1 & ~near_full & ~full)
      addr <= addr + 11'h002;
    else if ((push0 | push1) & ~full)
      addr <= addr + 11'h001;
    else if (pop0 & pop1 & ~near_empty & ~empty)
      addr <= addr - 11'h002;
    else if ((pop0 | pop1) & ~empty)
      addr <= addr - 11'h001;
  end

  //////////////////////////
	// Flop the ALU result //
	////////////////////////
	always @(posedge clk) begin
		stack0_EX_DM <= rdata0;
		stack1_EX_DM <= push0 & pop1 ? wdata0 : rdata1;
  end

  // address_a always serves the first/single instruction
  assign address_a = addr;
  assign wren_a = push0 & ~full; // if push0 is requested & stack is not full, then push the first data to address_a

  // if two pushes, then the second port must serve the second push command
  // if two pops, then the second port must serve the second pop command
  // other case: use the addr for single instrution or don't care for illegal cases
  assign address_b = (push0 & push1) ? (addr+1) : (pop0 & pop1) ? (addr - 1) : addr;
  assign wren_b = (push0 & push1 & ~near_full & ~full) | (~push0 & push1 & ~full); // push the second data if there are space for two push request or only one push request

  /////////////////////////////////////////
  // Instantiate 2 port ram with M10K IP //
  /////////////////////////////////////////
  ram_2p STACK_MEM(.clock(clk), .address_a(address_a), .address_b(address_b), .data_a(wdata0), .data_b(wdata1), .wren_a(wren_a), .wren_b(wren_b), .q_a(rdata0), .q_b(rdata1));

endmodule