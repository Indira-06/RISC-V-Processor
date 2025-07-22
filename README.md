# RISC-V Processor (Sequential & Pipelined) Implementation in Verilog

This project implements a 64-bit RISC-V processor in Verilog using both **sequential** and **5-stage pipelined** architectures.

## Project Structure

- [Report.pdf](Report.pdf)
- [results/](results/)
- [pipelined/](pipelined/)
  - Holds the pipelined Verilog implementation ([cpu_pipelined.v](pipelined/verilog/cpu_pipelined.v))
- - [sequential/](sequential/)
  - Houses the single-cycle Verilog files, test scripts, and memory files ([data_memory.v](sequential/modules/data_memory.v), [instruction_memory.v](sequential/modules/instruction_memory.v)).
  - [testcases/](sequential/testcases/) holds example assembly programs (e.g., [1.s](sequential/testcases/1.s)).
  - [test_sequential.sh](sequential/test_sequential.sh) runs the Verilog testbench on a specified .s file.
  - [reset_memory.sh](sequential/reset_memory.sh) resets the data memory to all zeros.
- [README.md](README.md)
  - Main documentation.

## Key Features of the Pipelined Processor

- **Five-Stage Pipeline:** Includes Instruction Fetch (IF), Decode (ID), Execute (EX), Memory Access (MEM), and Writeback (WB).
- **Branch Handling:** Implements static branch prediction using an always-taken strategy.
- **Data Hazard Mitigation:** Uses forwarding to resolve most data hazards; introduces pipeline stalls only for load-use dependencies.
- **Control Hazard Resolution:** Flushes the pipeline upon detecting branch mispredictions to maintain correctness.
- **Improved Performance:** Benchmark test cases demonstrate higher instruction throughput compared to the sequential design.

## How to Run

### Sequential Implementation

Add the assembly code in the `sequential/testcases` directory and run the following commands to test the code. A few examples are provided there already to refer to syntax. `sequential/modules/data_memory.hex` contains the data memory, which is long term.

```bash
cd sequential
chmod +x test_sequential.sh
./test_sequential.sh <filename>.s
```

### Pipelined Implementation

The pipelined implementation features a 5-stage pipeline with hazard detection, data forwarding, and branch prediction. To run tests on the pipelined CPU:

```sh
cd pipelined
chmod +x test_pipelined.sh
./test_pipelined.sh <filename>.s
```
### Test Cases:
The following assembly programs test different features and edge cases of the RISC-V CPU:
- 2.s: Exercises loops with data dependencies; verifies correct data forwarding
- 4.s: Validates branch prediction logic using unconditional branches
- 7.s: Tests control hazard handling with branches and mispredictions
- 8.s: Demonstrates detection of load-use hazards and correct pipeline stalling

## Supported Assembly Instructions

This implementation supports a subset of the RISC-V instruction set:
- **R-type**: `add`, `sub`, `or`, `and`, `addi`
- **I-type**: `addi`, `ld` (load doubleword)
- **S-type**: `sd` (store doubleword)
- **B-type**: `beq` (branch if equal)
- **Special**: `nop` (no operation)

### NOTES: 
- `ld` and `sd` operate as 64-bit equivalents of `lw` and `sw`, but only doubleword access is supported in this implementation.
- Ensure all memory accesses use addresses that are multiples of 8, as the data memory supports 64-bit word-aligned operations only.

---
