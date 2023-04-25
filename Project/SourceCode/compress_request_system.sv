module compress_request_system(
input clk,
input rst_n,
input [7:0] uncompress_addr_x,
input [7:0] uncompress_addr_y,
input we,
input compress_wdata,
input pause,
output reg compress_req,
output compress_start
);

// This signal indicates the process of compressing the image. 1 indicates the compression started and is in process, 0 indicates that the compress is finished/idle.
reg compress_proc;

    // Compressor snapshot request system
    always @(negedge clk, negedge rst_n)
         if(!rst_n)
              compress_req <= 1'b0;
          else if (compress_proc && uncompress_addr_x == 223 && uncompress_addr_y == 223)
              compress_req <= 1'b0;
          else if (we)
              compress_req <= compress_wdata;

    always @(negedge clk, negedge rst_n)
         if(!rst_n)
              compress_proc <= 1'b0;
            else if (compress_start)
                compress_proc <= 1'b1;
            else if (compress_proc && uncompress_addr_x == 223 && uncompress_addr_y == 223)
                compress_proc <=1'b0;
                
    assign compress_start = ((compress_req | !pause) && uncompress_addr_x == 8'h0 && uncompress_addr_y == 8'h0);

endmodule
