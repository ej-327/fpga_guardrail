`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2026 10:53:33 AM
// Design Name: 
// Module Name: tb_uart_tx
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


module tb_uart_tx();

reg clk;
    reg tx_start;
    reg [7:0] data_in;
    wire tx;
    wire tx_done;

    uart_tx uut (
        .clk(clk),
        .tx_start(tx_start),
        .data_in(data_in),
        .tx(tx),
        .tx_done(tx_done)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        tx_start = 0;
        data_in = 0;

        #100;

        data_in = 8'h41;
        tx_start = 1;
        #10;          
        tx_start = 0;

        #100000;

        // Finish simulation
        $finish;
    end

endmodule
