module rst_synch(clk,RST_n,pll_locked,rst_n);

input clk;           // 50MHz clock
input RST_n;         // non synched reset from push button
input pll_locked;    // don't deassert reset till PLL is locked
output reg rst_n;    // synched on deassert to negedge of clock

reg q1;

////////////////////////////////////////////////
// rst_n is asserted asynch, but deasserted  //
// syncronized to negedge clock.  Two flops //
// are used for metastability purposes.    //
////////////////////////////////////////////
always @(negedge clk, negedge RST_n)
  if (!RST_n)
    begin
      q1    <= 1'b0;
      rst_n <= 1'b0;
    end
  else
    begin
      q1    <= pll_locked;
      rst_n <= q1;
    end

endmodule