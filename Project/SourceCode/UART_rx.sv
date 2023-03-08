module UART_rx(
    input clk, rst_n,        // 50MHz system clock & asynch active low reset
    input RX,                // serial data input
    input clr_rdy,           // knocks down rdy when asserted
    input [12:0] baud_div,   // Modify baud rate
    output [7:0]rx_data,     // byte received
    output logic rdy         // asserted when byte received, and stays high till start bit of next byth starts or until clr_rdy asserted
);

    logic start;                // SM output to start a UART receiving
    logic receiving;            // SM output indicating a UART is receiving data
    logic set_rdy;              // SM output to set rdy
    logic shift;                // asserted when ready to shift in next bit
    logic [8:0]rx_shft_reg;     // output of the shift register
    logic [12:0]baud_cnt;       // output of the baud counter
    logic [3:0]bit_cnt;         // output of the bit counter
    logic RX_sync;              // double flopped RX input
    logic RX_FF1;               // intermediate value between the two flops that doble flops RX

    typedef enum logic {IDLE, RECE} state_t;
    state_t state, nxt_state;

    // double flop RX to synchronize
    always_ff @(posedge clk, negedge rst_n)
        if(!rst_n) begin
            // pre set RX_sync for UART
            RX_FF1 <= 1'b1;
            RX_sync <= 1'b1;
        end
        else begin
            RX_FF1 <= RX;
            RX_sync <= RX_FF1;
        end

    // the shift register
    always_ff @(posedge clk)
        if(shift)
            rx_shft_reg <= {RX_sync, rx_shft_reg[8:1]};        // append the data with a start bit

    assign rx_data = rx_shft_reg[7:0];                        // output the received byte

    // the baud counter
    always_ff @(posedge clk)
        if(start)
            baud_cnt <= {1'b0,baud_div[12:1]};                // set the baud counter to half of a baud period at the start of a receiving
        else if(shift)
            baud_cnt <= baud_div;                             // set the baud counter to the full baud period when shifting
        else if(receiving)
            baud_cnt <= baud_cnt - 13'h0001;                  // count up when transmitting

    assign shift = (baud_cnt == 13'h0000);                    // assert shift when baud_cnt reaches 0

    // the bit counter
    always_ff @(posedge clk)
        if(start)
            bit_cnt <= 4'h0;                                  // reset the bit counter if init is asserted
        else if(shift)
            bit_cnt <= bit_cnt + 4'h1;                        // count up when shifted a bit

    // SM state register
    always_ff @(posedge clk, negedge rst_n)
        if(!rst_n)
            state <= IDLE;
        else
            state <= nxt_state;
            
    // control SM
    always_comb begin
        // default all outputs to prevent unintended latches
        nxt_state = state;
        start = 1'b0;
        receiving = 1'b0;
        set_rdy = 1'b0;
        
        case(state)
            RECE: begin
                receiving = 1'b1;
                if(bit_cnt == 4'd10) begin                    // finish receiving when all 10 bits are received
                    set_rdy = 1'b1;
                    nxt_state = IDLE;
                end
            end
            default:            // is IDLE
                if(RX_sync == 1'b0) begin                    // wait until RX is low to begin receiving
                    start = 1'b1;
                    nxt_state = RECE;
                end
        endcase
    end

    // SR flop generating tx_done, set_rdy is S, (start | clr_rdy) is R
    always_ff @(posedge clk, negedge rst_n)
        if(!rst_n)
            rdy <= 1'b0;
        else if(start | clr_rdy)
            rdy <= 1'b0;
        else if(set_rdy)
            rdy <= 1'b1;

endmodule
