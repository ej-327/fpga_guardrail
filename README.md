# FPGA Hardware Guardrail

This hardware security coprocessor was built by me in order to explore the advantageous of physical and wire speed filtering for Large Language Model (LLM) type text streams simulated through a python script. Software based filters process strings in sequence, which poorly scales and adds unpredictable latency spikes. The goal of this experiment is to completely bypass the CPU's sequential processing by using an AMD Artix-7 FPGA, it intercepts USB-UART characters and drops malicious prompt injections with zero clock cycle processing delay or O(1) latency.

In order for the the FPGA to receive data, the board has to take in raw ASCII characters over a USB cable, shift them through a 16-byte rolling window, and check the text against hardcoded blacklisted patterns with the use of pure combinational logic. Once a prompt injection vector is detected("SYSTEM:" or "IGNORE"), or private data such as an SSN, a hardware kill switch drops, dropping a payload and masking remaining outbound characters with asterisks. This triggers all 16 LEDs to turn on, and a INJ1 message appears on the Basys 3's 7-segment display. It remains in a locked state until a physical reset button (btnC) is pushed.


## Hardware Specs & Performance

Metrics sourced directly from Vivado Implementation Report targeting Digilent Basys 3 (XC7A35T-1CPG236C):
* **System Clock & Baud Rate:** Runs at 100 MHz with a custom UART transceiver operating at 115200 baud or 868 clock cycles per bit.
* **Logic Utilization:** System used 108 Look Up Tables (LUTs) and 184 Flip Flops.
* **Reaction Latency:** O(1) time with a parallel Deterministic Finite Automaton which evaluated entire 16-byte window on a single clock cycle.

## System Architecture

```text
[Host PC (Python Script)] ---> Streams AI Tokens over USB ---> [Basys 3 FPGA] 
                                                                     |
[uart_rx.v] (Turns incoming electrical bits into 8-bit ASCII bytes) <+
     |
[pattern_matcher.v] (16-byte sliding window & parallel DFA inspection) 
     |
[policy_enforcer.v] (Hardware kill-switch & inline multiplexer) 
     |
[uart_tx.v] (Echoes safe text back to PC, or sends '*' redaction tokens) 
```

## Verilog Modules & Software

* **uart_rx.v & uart_tx.v**: Wrote the serial communication backcone in order to handle 115200 baud transfers of data.
* **pattern_matcher.v**: Main intelligence core. Has a rolling history containing the most recent 16 bytes. Parallel combinational gates monitor these bytes for suspicious prompt injections such as "IGNORE" and "SYSTEM:", while also watching for sensitive data such as structured numeric PII patterns like mock SSNs.
* **policy_enforcer.v**: Circuit breaker. If text remains clean, bytes route to the TX buffer back to the host. If a threat is percieved, an internal register will latch high, dropping the entire packet and replacing it with a 8'h2A error token.
* **seven_seg.v**: Translates statee into multiplexed signals to drive the FPGA's 4-digit display to throw a SAFE is text is clean or INJ1 if text is suspected as a threat.
* **guardrail_top.v & Basys3_Master.xdc**: Master Hardware wrapper. Wires all submodules together and maps them to silicon pins on the FPGA.
* **host_llm_streamer.py**: Python script running from host PC, using pyserial library. Feeds a mock AI text string into the board with delays in order to verify physical drop multiplexer and real time reset logic.

## How to Build and Run

1. **Synthesize the Hardware:** Create an RTL project in AMD Vivado targeting part xc7a35tcpg236-1. Add all Verilog design files and the Basys3_Master.xdc constraints file. Run Synthesis, Implementation, and Generate Bitstream to flash your Basys 3 board.
2. **Run the Host Streamer:** Find your board's COM port in Windows Device Manager and update the SERIAL_PORT variable in the Python script. Then run python host_llm_streamer.py in your terminal.
3. **Watch it Trip:** Benign text will echo back to your terminal while the board displays SAFE and lights up green. When the script sends an injection attack, the board's 16 LEDs will instantly light up solid red, the display will switch to INJ1, and your terminal output will drop the packet and output * asterisks instead. You then press the center button (btnC) on the physical board to reset the hardware latch.
