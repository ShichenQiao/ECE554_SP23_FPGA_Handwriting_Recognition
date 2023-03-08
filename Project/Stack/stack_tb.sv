////////////////////////////////////////////////////////
//
// 32-bit x 1024 stack TESTBENCH
// 
// Designer: Harry Zhao
//
// The stack allows perform SINGLE operation at a time, 
// PUSH or POP. 
//
///////////////////////////////////////////////////////

module stack_tb();

  logic clk, rst_n;
  logic push, pop;
  logic [31:0] wdata;
  logic [31:0] rdata;

  stack iDUT(.clk(clk), 
             .rst_n(rst_n), 
             .push(push), 
             .pop(pop), 
             .wdata(wdata),
             .rdata(rdata));

  logic [31:0] local_stack [1023:0];

  initial begin
    clk = 1'b0;          // assumed to be 50MHz
    rst_n = 1'b0;        // only reset the DUT here once throughout this TB
    push = 1'b0;
    pop = 1'b0;
    @(posedge clk);
    @(negedge clk) rst_n = 1'b1;

    //////////////////////////////////////////////////////////////////////////////
    // Test 1: Push one random data and pop the data out to confirm the data.  //
    ////////////////////////////////////////////////////////////////////////////
    // 
    // Repeat this test 10000 times
    for(int i = 0; i < 10000; i++) begin
      @(posedge clk);
      wdata = $random();
      push = 1'b1;
      pop = 1'b0;

      @(posedge clk);
      push = 1'b0;
      pop = 1'b1;

      @(posedge clk);
      if (rdata !== wdata) begin
        $display("TEST 1 failed: push data %f != pop data %f", wdata, rdata);
        $stop();
      end
    end
    $display("TEST 1 passed: push one data and pop one data passes after 10000 random tests");
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // Test 2: Overflow the stack and pop all elements to make sure the first 1024 pushes are saved.  //
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // 
    // Fill the stack
    for(int i = 0; i < 1024; i++) begin
      @(posedge clk);
      wdata = $random();
      local_stack[i] = wdata;
      push = 1'b1;
      pop = 1'b0;
    end
    // Overflow the stack
    for(int i = 0; i < 2000; i++) begin
      @(posedge clk);
      wdata = $random();
      push = 1'b1;
      pop = 1'b0;
    end
    // Retrive the data from the stack
    for(int i = 1023; i >= 0; i--) begin
      @(posedge clk);
      wdata = $random();
      local_stack[i] = wdata;
      push = 1'b0;
      pop = 1'b1;
      @(posedge clk);
      if (rdata !== local_stack[i]) begin
        $display("TEST 2 failed: push data %f != pop data %f", local_stack[i], rdata);
        $stop();
      end
    end
    $display("TEST 2 passed: all 1024 data are retrived correctly after overflowing the stack");

    ////////////////////////////////////////////////////
    // Test 3: Underflow the stack and repeat test1  //
    //////////////////////////////////////////////////
    // 
    // Under flow the stack
    for(int i = 0; i < 2000; i++) begin
      @(posedge clk);
      wdata = $random();
      push = 1'b0;
      pop = 1'b1;
    end
    // Repeat this test 10000 times
    for(int i = 0; i < 10000; i++) begin
      @(posedge clk);
      wdata = $random();
      push = 1'b1;
      pop = 1'b0;

      @(posedge clk);
      push = 1'b0;
      pop = 1'b1;

      @(posedge clk);
      if (rdata !== wdata) begin
        $display("TEST 3 failed: push data %f != pop data %f after underflow", wdata, rdata);
        $stop();
      end
    end

    $display("TEST 3 passed: test 1 and test 2 still works after underflow the stack.");

    $display("Yahoo!! All tests passed");
    $stop();
  end

  always
    #5 clk = ~clk;

endmodule
