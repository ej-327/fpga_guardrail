`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2026 05:26:18 PM
// Design Name: 
// Module Name: policy_enforcer
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


module policy_enforcer(
    input wire clk, 
    input wire rx_done, //Pulse when new byte arrive from re
    input wire [7:0] data_in, //Incoming ASCII char
    input wire match_assert, //High if pattern matcher detects threat
    output reg tx_start, //Trigger to send byte back to PC
    output reg [7:0] data_out, //Safe byte or redacted aler token
    output reg trip_flag //Latches high to trigger the board LEDs
   
    );
    
    //Internal memory to hold the defensive state
    reg tripped = 0;
    
    always @(posedge clk) begin
        //Latching Memory
        if (match_assert == 1) begin
            tripped <= 1;
        end
        
        //Route internal memory state to output wire (red LED)
        trip_flag <= tripped;
        
        //Data Path Multiplexer
        if (tripped == 1 || match_assert == 1) begin
            //Drop condition: mask data with asterik '*'
            data_out <= 8'h2A;
            tx_start <= rx_done; //Transmiter send masked token
            
        end else begin
            //Pass condition: Route bytes cleanly through
            data_out <= data_in;
            tx_start <= rx_done; //Trigger transmitter to send original texg
        end
    end
        
    
    
endmodule
