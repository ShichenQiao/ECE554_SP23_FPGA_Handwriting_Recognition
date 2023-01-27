///////////////////////////////////////////////////////////////////////
// SPI monarch module that transmits and receives 16-bit packets    //
// cmd[15:0] is 16-bit packet that goes out on MOSI, rd_data[7:0]  //
// is the 8-bit word that came back on MISO.                      //
// wrt is control signal to initiate a transaction. done is      //
// asserted when transaction is complete. SCLK is currently set //
// for 1:32 of clk (1.6MHz).                                   //
// This SPI unit shifts MOSI on SCLK fall, and samples MISO   //
// on SCLK rise.  SCLK is normally high.                     //
// Deliberately obfuscated version of code.                 //
/////////////////////////////////////////////////////////////

module SPI_M(clk,rst_n,SS_n,SCLK,MISO,MOSI,wrt,done,rd_data,cmd);

  input clk,rst_n,wrt,MISO;
  input [15:0] cmd;					
  output reg SS_n, done;			
  output SCLK,MOSI;
  
  output [15:0] rd_data;				

  typedef enum reg[1:0] {S0,S1,S2,S3} state_t;
  
  state_t n000,n001;			
  reg [4:0] n002;
  reg [3:0] n003;
  reg [15:0] n004;			
  reg n005;				
  

  logic n006, n007, n008;
  logic n009, n010,n011;


  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
      n000 <= S0;
    else
      n000 <= n001;

	  
  always_ff @(posedge clk)
    if (n011)
	  n005 <= MISO;
  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  n004 <= 16'h0000;
	else if (wrt)
      n004 <= cmd;
    else if (n008)
      n004 <= {n004[14:0],n005};

 
  always_ff @(posedge clk)
    if (n006)
      n003 <= 4'b0000;
    else if (n007)
      n003 <= n003 + 1'b1;

 
  always_ff @(posedge clk)
    if (n006)
      n002 <= 5'b10110;
    else
      n002 <= n002 + 1'b1;

  assign SCLK = n002[4];		
  
 
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  done <= 1'b0;
	else if (n009)
	  done <= 1'b1;
	else if (n010)
	  done <= 1'b0;
	  

  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  SS_n <= 1'b1;
	else if (n009)
	  SS_n <= 1'b1;
	else if (n010)
	  SS_n <= 1'b0;
	  
 
  always_comb
    begin
      n006 = 0; 
      n007 = 0;
      n008 = 0;
	  n011 = 0;
      n009 = 0;
	  n010 = 0;
	  n001 = S0;

      case (n000)
        S0 : begin
          n006 = 1;
          if (wrt) 
		    begin
			  n010 = 1;
              n001 = S1;
			end
          else 
		    n001 = S0;
        end
		S1 : begin
		  if (&n002) begin
		    n001 = S2;
	      end else
		    n001 = S1;
		end
        S2 : begin
          n007 = (&n002) ? 1'b1 : 1'b0;
		  n011 = (n002==5'b01111) ? 1'b1 : 1'b0;
          n008 = (&n002) ? 1'b1 : 1'b0;
		  if (n002[4] && (n003==4'hF))
		    n001 = S3;
          else
            n001 = S2;         
        end
        S3 : begin
          if (&n002[4:1])
		    begin
			  n001 = S0;
			  n008 = 1;
			  n009 = 1;
			end
		  else
		    n001 = S3;
        end
      endcase
    end
  
  assign rd_data = n004[15:0];
  assign MOSI = n004[15];

endmodule 
