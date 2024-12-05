# RISC Machine Project

## Overview

This project focuses on designing and building a Reduced Instruction Set Computer (RISC) architecture using synthesizable Verilog HDL. The RISC machine is designed with modular components and incorporates instruction pipelining to improve performance. It supports a subset of ARMv7 instructions and includes features like a datapath, instruction memory, register file, and memory-mapped I/O.

## Key Features

### Core Components
1. **CPU Controller:** Manages the execution process through a finite-state machine, coordinating instruction fetch, decode, execute, memory access, and write-back stages.
2. **RAM Module:** Stores program instructions and data, while supporting memory-mapped I/O for device interaction.
3. **Arithmetic Logic Unit (ALU):** Handles essential operations such as addition, subtraction, and comparisons.
4. **Register File:** Provides high-speed access to general-purpose registers for efficient execution.
5. **Instruction Decoder:** Interprets binary instructions and generates control signals for ARMv7 operations, including CMP, SUB, LDR, and STR.


### Data Flow and Pipelining
1. **Datapath Design:** Ensures smooth data transfer between components like the ALU, register file, and RAM. The datapath facilitates efficient execution across all pipeline stages.
2. **Pipelined Execution:** Implements a multi-stage pipeline to enhance instruction throughput, minimizing hazards and improving overall performance.

### Supported Instructions
1. **Arithmetic and Logical Operations:** Includes basic operations like CMP (compare) and SUB (subtract).
2. **Memory Access:** Features LDR (load) and STR (store) for moving data between the CPU and memory.
3. **Control Operation:** Supports HALT to stop execution safely.

## Testing and Validation

1. **Simulation with Test Benches:** Verified the functionality of each component and instruction set using ModelSim. Extensive test cases were written to ensure the design operates reliably.
2. **FPGA Deployment:** The RISC design was synthesized for the DE1-SoC FPGA board. LEDs and switches were used for real-time debugging and output validation.
3. **Assembler Integration:** An assembler was used to convert assembly code into machine-readable instructions, enabling systematic testing of individual commands.

## How to Use

### Prerequisites

- Verilog simulation tools like ModelSim
- Quartus software for synthesis and FPGA programming
- DE1-SoC FPGA board for hardware testing

### Steps to Run the Project

1. Clone the repository containing the Verilog code and supporting files.
2. Open the project in Quartus and compile it to generate the bitstream.
3. Simulate the design in ModelSim using provided test benches to verify behavior.
4. Upload the design onto the DE1-SoC FPGA and use on-board switches and LEDs for testing.

## Author

Vishal Thilak
