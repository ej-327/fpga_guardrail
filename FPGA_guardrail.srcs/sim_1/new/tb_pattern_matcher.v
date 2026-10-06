`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2026 10:39:07 AM
// Design Name: 
// Module Name: tb_pattern_matcher
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


module tb_pattern_matcher();
    
reg clk;
    reg rx_done;
    reg [7:0] data_in;
    wire match_assert;

    pattern_matcher uut (
        .clk(clk),
        .rx_done(rx_done),
        .data_in(data_in),
        .match_assert(match_assert)
    );

    always #5 clk = ~clk;

    task send_char;
        input [7:0] char;
        begin
            @(negedge clk);
            data_in = char;
            rx_done = 1;     
            
            @(negedge clk);
            rx_done = 0;     
            
            
            #100;
        end
    endtask

    initial begin
        clk = 0;
        rx_done = 0;
        data_in = 8'h00;
        
        #100; 
        //Mock IGNORE token
        send_char("I");
        send_char("G");
        send_char("N");
        send_char("O");
        send_char("R");
        send_char("E");
        
        #200; 
        // --- TEST 2: Clear window and fire Mock SSN ---
        send_char(" "); 
        send_char("1");
        send_char("2");
        send_char("3");
        send_char("-");
        send_char("4");
        send_char("5");
        send_char("-");
        send_char("6");
        send_char("7");
        send_char("8");
        send_char("9");
        
        #200; 
        
        $finish; // End simulation
    end

endmodule
