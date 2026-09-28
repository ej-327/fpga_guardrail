`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2026 02:55:01 PM
// Design Name: 
// Module Name: tb_uart_rx
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


module tb_uart_rx();
// Testbench variables to connect to our module
    reg clk;
    reg rx;
    wire [7:0] data;
    wire rx_done;

    // Instantiate the hardware module we want to test
    uart_rx uut (
        .clk(clk),
        .rx(rx),
        .data(data),
        .rx_done(rx_done)
    );
    
    // 1. Generate the 100 MHz System Clock
    // 100 MHz = 10 nanosecond period. We invert the clock every 5 ns.
    always #5 clk = ~clk;

    // 2. Task to simulate the PC sending a byte at 115,200 baud
    task send_byte;
        input [7:0] char_to_send;
        integer i;
        begin
            // Send Start Bit (Drive line to 0)
            rx = 0;
            #8680; // Wait 868 clock cycles (868 cycles * 10 ns = 8680 ns)
            
            // Send 8 Data Bits (UART sends the Least Significant Bit first)
            for (i = 0; i < 8; i = i + 1) begin
                rx = char_to_send[i];
                #8680;
            end
            
            // Send Stop Bit (Drive line back to 1)
            rx = 1;
            #8680;
        end
    endtask

    // 3. The main simulation sequence
    initial begin
        // Set the baseline idle state
        clk = 0;
        rx = 1; // UART lines rest at high voltage
        
        // Wait 100 ns for the system to stabilize
        #100;
        
        // Fire the character 'A' (Hex 41, Binary 01000001) at the receiver
        send_byte(8'h41);
        
        // Wait a brief moment to observe the rx_done strobe light on the graph
        #20000;
        
        // Terminate the simulation
        $finish;
    end
endmodule
