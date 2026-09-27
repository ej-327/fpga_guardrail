module uart_rx(
    input wire clk, //100MHz system clock
    input wire rx, //incoming serial data line
    output reg [7:0] data, //8-bit ASCII character output
    output reg rx_done //Pulses high when byte is finally received
);

parameter CLKS_PER_BIT = 868;

//FSM
parameter IDLE = 2'b00;
parameter READ_BITS = 2'b01;
parameter STOP_CHECK = 2'b10;

reg [1:0] state = IDLE;
reg [9:0] clock_count = 0;
reg [2:0] bit_index = 0;

always @(posedge clk) begin
    case (state)
    
IDLE:begin

    rx_done <= 0;
    bit_index <= 0;
    
    // If a start bit is detected which indicated line drops to 0
    if (rx == 0) begin
        //Wait for half bit period to find center
        if ( clock_count < (CLKS_PER_BIT / 2) ) begin
        clock_count <= clock_count + 1;
        end else begin
            clock_count <= 0; //Reset counter for data bits
            state  <= READ_BITS;
            end
        end else begin
        clock_count <= 0;
        end
    end
    

READ_BITS: begin

//Wait for one full bit period
    if (clock_count < CLKS_PER_BIT - 1) begin
        clock_count <= clock_count + 1;
    end else begin
        clock_count <= 0;
        
        //Sample  the line and store the bit
        data[bit_index] <= rx;
        
        //Check if we have recieved all 8 bits
        if (bit_index < 7) begin
            bit_index <= bit_index + 1;
        end else begin 
            bit_index <= 0;
            state <= STOP_CHECK;
        end
    end
end


STOP_CHECK: begin
    //Wait for duration of stop bit
    if (clock_count < CLKS_PER_BIT - 1) begin
        clock_count <= clock_count +1;
    end else begin
        rx_done <= 1; // Signal full byte is ready
        clock_count <= 0; //Reset counter
        state <= IDLE; // Return to start; Wait for another character
    end
end
endcase

end
endmodule
    
    
    
    
       