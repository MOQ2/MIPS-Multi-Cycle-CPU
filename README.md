# Multi-Cycle Processor Implementation

This project implements a 16-bit multi-cycle processor in SystemVerilog. The processor supports various instructions including arithmetic, logical, memory, and control flow operations.

## Architecture Overview

The processor implements a multi-cycle architecture with the following main components:

- **Datapath**: Contains ALU, registers, and data paths
- **Control Units**: Main Control, ALU Control, and PC Control
- **Memory**: Instruction Memory and Data Memory
- **Register File**: 8 general-purpose registers (16-bit each)

### Key Components

1. **ALU (Arithmetic Logic Unit)**
   - Supports ADD, SUB, and AND operations
   - Generates flags: Zero, Negative, Overflow

2. **Control Units**
   - Main Control: Manages control signals for different stages
   - ALU Control: Determines ALU operation
   - PC Control: Handles program counter updates and branching

3. **Memory System**
   - Instruction Memory: Stores program instructions
   - Data Memory: Stores data with read/write capabilities
   - Memory-mapped I/O support

### Instruction Set

The processor supports the following instruction types:

1. **R-Type Instructions**
   - AND, ADD, SUB

2. **I-Type Instructions**
   - ADDI, ANDI
   - LW (Load Word)
   - SW (Store Word)
   - LBU/LBS (Load Byte Unsigned/Signed)

3. **Branch Instructions**
   - BEQ (Branch if Equal)
   - BNE (Branch if Not Equal)
   - BGT (Branch if Greater Than)
   - BLT (Branch if Less Than)

4. **Jump Instructions**
   - J (Jump)
   - CALL
   - RET (Return)
   - SV (Special Vector)

### Pipeline Stages

The processor executes instructions in multiple cycles:
1. Fetch
2. Decode
3. Execute
4. Memory Access (if needed)
5. Write Back (if needed)

## Files Description

- `multi_cycle_processor.sv`: Top-level module integrating all components
- `ALU_Control.sv`: ALU control logic
- `Alu.sv`: Arithmetic Logic Unit implementation
- `Main_Control.sv`: Main control unit
- `PC_Control.sv`: Program counter control logic
- `Register_File.sv`: Register file implementation
- `Register.sv`: Single register module
- `Date_Memory.sv`: Data memory implementation
- `Mux_*.sv`: Various multiplexer modules
- `extender_*.sv`: Sign extension modules

## Usage

1. Load the program into instruction memory using `mycode.dat`
2. Initialize data memory using `DataMemory.dat`
3. Run the simulation using the testbench
4. Monitor register and memory contents during execution

## Testing

The project includes a testbench (`testbench.sv`) that:
- Initializes the processor
- Provides clock and reset signals
- Monitors execution
- Displays register contents and execution status

## Implementation Details

- 16-bit data path
- 8 general-purpose registers
- Support for both byte and word operations
- Sign extension support for immediate values
- Multi-cycle implementation for instruction execution
- Comprehensive branching support with condition flags