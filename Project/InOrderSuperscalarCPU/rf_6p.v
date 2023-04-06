module rf_6p(p0_addr, p1_addr, p2_addr, p3_addr, re0,re1,re2,re3, dst_addr0, dst_addr1, dst0, dst1, we0, we1, hlt);
////////////////////////////////////////////////////////////////////////////
// Six ported register file.  Four read ports (p0 , p1, p2, p3), and     //
// two write port (dst0, dst1).  Data is written on clock high, and     //
// read on clock low. If write into same address, the second data will //
// overwrite the first data. ///////////////////////////////////////////
//////////////////////

    input clk;
    input [4:0] p0_addr, p1_addr, p2_addr, p3_addr;     // four read port addresses
    input re0,re1,re2,re3;                              // read enables (power not functionality)
    input [4:0] dst_addr0, dst_addr1;                   // write address
    input [31:0] dst0, dst1;                            // dst bus
    input we0, we1;                                     // write enable
    input hlt;                                          // not a functional input.  Used to dump register contents when
                                                        // test is halted. (No longer used)

    output [31:0] p0,p1,p2,p3;                          // output read ports

    wire r0_bypass_dst1, r0_bypass_dst0, r1_bypass_dst1, r1_bypass_dst0, r2_bypass_dst1, r2_bypass_dst0, r3_bypass_dst1, r3_bypass_dst0; // RF bypass
    reg [31:0] p0_raw, p1_raw, p2_raw, p3_raw;          // raw read output from SRAM

    /////////////////////////////////////////////////////////////////////
    // Instantiate a memory block and manually connect the w/r signals //
    // M10K does not support this many ports. Must use onboard logic   //
    /////////////////////////////////////////////////////////////////////
    reg [31:0] mem [31:0];    // 32 by 32 SRAM block

    // negedge triggered memory
    always @(negedge clk) begin
// Desired behavior:
//        if ((dst_addr0==5'h00 && we0) || (w_addr1 == 5'h00 && we1))
//            mem[5'h00] <= (w_addr1 == 5'h00 && we1) ? dst1 : dst0;
//        if ((dst_addr0==5'h01 && we0) || (w_addr1 == 5'h01 && we1))
//            mem[5'h01] <= (w_addr1 == 5'h01 && we1) ? dst1 : dst0;
//        if ((dst_addr0==5'h02 && we0) || (w_addr1 == 5'h02 && we1))
//            mem[5'h02] <= (w_addr1 == 5'h02 && we1) ? dst1 : dst0;
//        if ((dst_addr0==5'h03 && we0) || (w_addr1 == 5'h03 && we1))
//            mem[5'h03] <= (w_addr1 == 5'h03 && we1) ? dst1 : dst0;
//        if ((dst_addr0==5'h04 && we0) || (w_addr1 == 5'h04 && we1))
//            mem[5'h04] <= (w_addr1 == 5'h04 && we1) ? dst1 : dst0;
//        if ((dst_addr0==5'h05 && we0) || (w_addr1 == 5'h05 && we1))
//            mem[5'h05] <= (w_addr1 == 5'h05 && we1) ? dst1 : dst0;
//        if ((dst_addr0==5'h06 && we0) || (w_addr1 == 5'h06 && we1))
//            mem[5'h06] <= (w_addr1 == 5'h06 && we1) ? dst1 : dst0;
//        if ((dst_addr0==5'h07 && we0) || (w_addr1 == 5'h07 && we1))
//            mem[5'h07] <= (w_addr1 == 5'h07 && we1) ? dst1 : dst0;
//        if ((dst_addr0==5'h08 && we0) || (w_addr1 == 5'h08 && we1))
//            mem[5'h08] <= (w_addr1 == 5'h08 && we1) ? dst1 : dst0;
//        if ((dst_addr0==5'h09 && we0) || (w_addr1 == 5'h09 && we1))
//            mem[5'h09] <= (w_addr1 == 5'h09 && we1) ? dst1 : dst0;
        if(we0)
            mem[dst_addr0] <= dst0;
        if(we1)
            mem[dst_addr1] <= dst1;
        if(re0)
            p0_raw <= mem[p0_addr];
        if(re1)
            p1_raw <= mem[p1_addr];
        if(re2)
            p2_raw <= mem[p2_addr];
        if(re3)
            p3_raw <= mem[p3_addr];
    end

    // Bypass if any read register is the same as the write register and both re and we are high
    assign r0_bypass_dst1 = (~|(p0_addr ^ dst_addr1) & re0 & we1);
    assign r0_bypass_dst0 = (~|(p0_addr ^ dst_addr0) & re0 & we0);
    assign r1_bypass_dst1 = (~|(p1_addr ^ dst_addr1) & re1 & we1);
    assign r1_bypass_dst0 = (~|(p1_addr ^ dst_addr0) & re1 & we0);
    assign r2_bypass_dst1 = (~|(p2_addr ^ dst_addr1) & re2 & we1);
    assign r2_bypass_dst0 = (~|(p2_addr ^ dst_addr0) & re2 & we0);
    assign r3_bypass_dst1 = (~|(p3_addr ^ dst_addr1) & re3 & we1);
    assign r3_bypass_dst0 = (~|(p3_addr ^ dst_addr0) & re3 & we0);
    // R0 always stay at 32'h0000_0000
    // bypass logic:
    // if two writes write into same register, bypass the later one (dst1)
    // if two writes write into different registers, by pass the corresponding input
    //   - bypass dst1 if r_addr == dst_addr1 && re && we1
    //   - bypass dst0 if r_addr == dst_addr0 && re && we0
    assign p0 = ~|p0_addr ? 32'h0000_0000 : (r0_bypass_dst1 ?  dst1 : (r0_bypass_dst0 ? dst0 : p0_raw));
    assign p1 = ~|p1_addr ? 32'h0000_0000 : (r1_bypass_dst1 ?  dst1 : (r1_bypass_dst0 ? dst0 : p1_raw));
    assign p2 = ~|p2_addr ? 32'h0000_0000 : (r2_bypass_dst1 ?  dst1 : (r2_bypass_dst0 ? dst0 : p2_raw));
    assign p3 = ~|p3_addr ? 32'h0000_0000 : (r3_bypass_dst1 ?  dst1 : (r3_bypass_dst0 ? dst0 : p3_raw));

endmodule
