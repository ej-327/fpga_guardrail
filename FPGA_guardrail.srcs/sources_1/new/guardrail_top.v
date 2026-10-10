`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2026 11:05:12 PM
// Design Name: 
// Module Name: guardrail_top
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


module guardrail_top(
    input wire clk, //100 MHz system clock
    input wire RsRx, //USB-UART Receive pin
    output wire RsTx, //USB-UART Transmit pin
    output wire [15:0] led, //16 physical LEDs on board
    output wire [3:0] an, //4 anodes for 7-seg display
    output wire [6:0] seg //7-seg
);
       
   //Internal wires, physical traces connecting modules
   wire [7:0] rx_data;
   wire rx_done;
   
   wire match_assert;
   
   wire [7:0] tx_data;
   wire tx_start;
   wire tx_done; 
   
   wire trip_flag;
   
   //Wire trip flag to all 16 board LEDs
   assign led = {16{trip_flag}};
   
   //Serial Reciever
    uart_rx receiver (
        .clk(clk),
        .rx(RsRx),
        .data(rx_data),
        .rx_done(rx_done)
);


    //Parallel Pattern Matcher
    pattern_matcher inspector (
        .clk(clk),
        .rx_done(rx_done),
        .data_in(rx_data),
        .match_assert(match_assert)
);

    //Hardware Kill-Switch
    policy_enforcer enforcer (
        .clk(clk),
        .rx_done(rx_done),
        .data_in(rx_data),
        .match_assert(match_assert),
        .tx_start(tx_start),
        .data_out(tx_data),
        .trip_flag(trip_flag)
);

    //Serial Transmitter
    uart_tx transmitter (
        .clk(clk),
        .tx_start(tx_start),
        .data_in(tx_data),
        .tx(RsTx),
        .tx_done(tx_done)
);

    //Visual Display
    seven_seg display (
    .clk(clk),
    .trip_flag(trip_flag),
    .an(an),
    .seg(seg)
);

       
       
endmodule
