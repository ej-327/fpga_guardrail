`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2026 06:57:24 PM
// Design Name: 
// Module Name: uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tx(

    input wire clk,
    input wire tx_start,
    input wire [7:0] data_in,
    output reg tx,
    output reg tx_done
    );
        
    parameter CLKS_PER_BIT = 868;
    
    //FSM
    
    parameter IDLE = 2'b00;
    parameter START_BIT = 2'b01;
    parameter SEND_BITS = 2'b10;
    parameter STOP_BIT = 2'b11;
    
    reg [9:0] clock_count = 0;
    reg [1:0] state = IDLE;
    reg [2:0] bit_index = 0;
    reg [7:0] saved_data = 0;
    
    always @(posedge clk) begin
    
        case(state)
        
IDLE:begin
   
    tx <= 1;    //UART lines natively rest @ high voltage
    tx_done <= 0;   //Reset the completion strobe
    bit_index <= 0; //Reset the index counter
    
    //Wait for the main board to trigger a transmission
    if (tx_start == 1) begin
        saved_data <= data_in; // Snapshot payload immediately
        clock_count <= 0;
        state <= START_BIT;
    end else begin
        clock_count <= 0;
    end
    
    end
    
START_BIT:begin
    tx <= 0;    //Drive line low to signal the PC
    
    //Hold line low for one bit period
    if (clock_count < CLKS_PER_BIT - 1) begin
        clock_count <= clock_count + 1;
    end else begin 
        clock_count <= 0;
        state <= SEND_BITS;
    end
end
    
SEND_BITS:begin

    tx <= saved_data[bit_index]; //Push current bit onto wire

//Hold bit on line for exactly one full bit period
    if (clock_count < CLKS_PER_BIT - 1) begin
        clock_count <= clock_count +1;
        
    end else begin
        clock_count <= 0;
        
    //Check if we have sent all bits
    if (bit_index < 7) begin
        bit_index <= bit_index +1;
    end else begin
        bit_index <= 0;
        state <= STOP_BIT;
    end
end
end



STOP_BIT:begin

    tx <= 1; //Drive line back high to signal end of character

    //Hold the stop bit for exactly one full bit period
    if (clock_count < CLKS_PER_BIT - 1) begin
        clock_count <= clock_count + 1;
        
    end else begin
        tx_done <= 1; //Pulse completion strobe for one clock cycle
        clock_count <= 0; //Reset timer
        state <= IDLE; //Return to idle state to wait for next trigger
    end
end

default: state <= IDLE;

endcase

end
    
    
    
endmodule
