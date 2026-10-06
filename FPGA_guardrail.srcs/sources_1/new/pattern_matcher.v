`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2026 07:58:24 PM
// Design Name: 
// Module Name: pattern_matcher
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


module pattern_matcher(
    input wire clk, //100 MHz clock
    input wire rx_done, //Trigger pulse from uart_rx when new byte arrives
    input wire [7:0] data_in, //8-bit ASCII char from uart_rx
    output reg match_assert //Hardware interrupt asserted if threat is matched
        );
        
    //16 byte Sliding WIndow Array
    reg [7:0] window [0:15];
    integer i;
    
    initial begin
        for (i = 0; i < 16; i = i+1) begin
            window[i] <= 8'h00; //Initialize window w/ null characters
        end
    end 
    
    //SLiding-Window Register
    always @(posedge clk) begin
        if (rx_done) begin
            for (i = 15; i > 0; i = i - 1) begin
            window[i] <= window[i-1];
        end
        //Drop new char into front of window
        window[0] <= data_in; 
    end
end
    //Combinational DFA
    
    always @(*) begin
    
    //Default: No threat 
    match_assert = 0;
    
    //Threat 1: IGNORE
    if (window[5] == "I" &&
        window[4] == "G" &&
        window[3] == "N" &&
        window[2] == "O" &&
        window[1] == "R" &&
        window[0] == "E")
        begin
        
        match_assert = 1; //Trigger
    end
    
    //Threat 2: SYSTEM:
    if (window[6] == "S" &&
        window[5] == "Y" &&
        window[4] == "S" &&
        window[3] == "T" && 
        window[2] == "E" &&
        window[1] == "M" &&
        window[0] == ":")
        begin
        
        match_assert = 1; //Trigger
    end
    
    //Threat 3: Structured Numeric PII. Mock SSN Type format XXX-XX-XXXX
    if ((window[10] >= "0" && window[10] <= "9") &&
        (window[9]  >= "0" && window[9]  <= "9") &&
        (window[8]  >= "0" && window[8]  <= "9") &&
        (window[7]  == "-") &&
        (window[6]  >= "0" && window[6]  <= "9") &&
        (window[5]  >= "0" && window[5]  <= "9") &&
        (window[4]  == "-") &&
        (window[3]  >= "0" && window[3]  <= "9") &&
        (window[2]  >= "0" && window[2]  <= "9") &&
        (window[1]  >= "0" && window[1]  <= "9") &&
        (window[0]  >= "0" && window[0]  <= "9")) 
        begin
        
        match_assert = 1; //Trigger
    end
        
    
end

        
        
        
    
endmodule
