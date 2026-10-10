`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2026 12:15:38 AM
// Design Name: 
// Module Name: seven_seg
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


module seven_seg(
    input wire clk, 
    input wire trip_flag, // 0 - SAFE ; 1 - INJ
    output reg [3:0] an, // Anodes to select active digit
    output reg [6:0] seg // 7 cathodes to light up segments
    );
    
    //20-bit counter to divide 100 MHz to 95 Hz
    reg [19:0] refresh_counter = 0;
    
    //Top 2 bits of the counter will dictate which 4 digits is active
    wire [1:0] active_digit;
    assign active_digit = refresh_counter[19:18];
    
    // Refresh Counter
    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
    end
    
    //Anode & Segment Multiplexer
    always @(*) begin
        case (active_digit)
        
            2'b00: begin
                an = 4'b1110; //Active Digit 0
                if (trip_flag == 0)
                    seg = 7'b0000110; //'E'
                else
                    seg =7'b1111001; //'1'
            end
            
            2'b01: begin
                an = 4'b1101; //Active Digit 1
                if (trip_flag == 0)
                    seg = 7'b0001110; //'F'
                else 
                    seg = 7'b1100001;//'J'
            end
            
            2'b10: begin
                an = 4'b1011; //Active Digit 2
                if (trip_flag == 0)
                    seg = 7'b0001000; //'A'
                else
                    seg = 7'b1100001; //'n'
            end
            
            2'b11: begin
                an = 4'b0111; //Active Digit 3
                if (trip_flag == 0) 
                    seg = 7'b0010010; //'S'
                else 
                    seg = 7'b1111001; //'I'
            end
            
            default: begin
                an = 4'b1111; //All off
                seg = 7'b1111111;
            end
       endcase
    end        
    
    
    
endmodule

