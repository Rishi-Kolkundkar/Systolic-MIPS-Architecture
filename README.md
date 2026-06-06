# MIPS SoC with Integrated Systolic Array NPU

This repository contains a gate-level structural Verilog implementation of a System-on-Chip (SoC) featuring a 5-stage pipelined MIPS32 core, a memory-mapped Neural Processing Unit (NPU) accelerator with a simple branch predictor and cache. 

The primary focus of this project is the integration of a custom hardware accelerator capable of parallel matrix multiplication via a 2D Systolic Array, completely offloading intensive compute tasks from the main CPU pipeline.

## System Architecture

### 1. Neural Processing Unit (NPU) & Systolic Array
The NPU is designed to accelerate $A \times B$ matrix operations. It is accessed by the main CPU via Memory-Mapped I/O (MMIO) and bypasses the standard data cache.
* **Array Dimensions:** 4x4 grid of Processing Elements (PEs).
* **Processing Elements:** Each PE contains an 8-bit multiplier and a 32-bit accumulator (MAC). Data flows horizontally (Matrix A) and vertically (Matrix B) on each clock edge.
* **Data Slicer:** A custom 32-to-8 bit slicing unit that unpacks 32-bit words from the CPU into byte-sized streams fed into the array edges.
* **Finite State Machine (FSM):** Controls the hardware execution lifecycle:
  * `IDLE`: Waits for the CPU to write a `1` to the Control Register.
  * `LOAD`: Fetches the buffered Row-Major and Column-Major matrices.
  * `COMPUTE`: Pushes data through the array pipelines.
  * `DRAIN`: A staggered capture mechanism that catches the horizontal wave of computed outputs and writes them to a 16-register output buffer.

### 2. MIPS Pipelined CPU
A structural 5-stage pipeline (IF, ID, EX, MEM, WB) built mostly in a structural gate-level manner.
* **Hazard Management:** Full Data Forwarding Unit and Hazard Detection Unit to handle RAW dependencies and pipeline flushes natively.
* **Branch Prediction:** Integrated branch prediction logic to minimize control hazard penalties.
* **ISA Expansion:** Modified Control Unit and Decode-Stage Sign Extender to natively support `lui` (Load Upper Immediate) and `ori` (OR Immediate). This allows for 32-bit constant generation in software without expanding the ALU datapath or violating the 32-bit RISC instruction limit.

### 3. Memory Subsystem & Bus Routing
An Address Decoder dynamically routes CPU load/store traffic based on the target address, supporting seamless communication between the CPU and the AI accelerator.

**Memory Map:**
| Address Range | Target Hardware | Description |
| :--- | :--- | :--- |
| `0x0000_0000` - `0x7FFF_FFFF` | Main Memory / Cache | Standard data variables and stack space. |
| `0x8000_0000` - `0x8000_000C` | NPU Matrix A Buffer | 4 words (Row-Major format). |
| `0x8000_0010` - `0x8000_001C` | NPU Matrix B Buffer | 4 words (Column-Major format). |
| `0x8000_0020` | NPU Control Reg | Write `1` to trigger Systolic execution. |
| `0x8000_0030` - `0x8000_006C` | NPU Output Buffer | 16 words containing the final computed matrix. |

## Verification & Testing

The SoC has been rigorously simulated and verified using a suite of structural tests designed to prove the physical integrity of the datapath:
* **Integer Overflow & Bridging Tests:** The NPU is stressed using alternating bit-patterns (`0xAAAAAAAA`, `0x55555555`) and maximum 8-bit thresholds (`0xFFFFFFFF`) to verify that no structural wires are bridged and the 32-bit accumulators do not overflow.
* **Pipeline Coherency:** Software routines explicitly test the Forwarding Unit by placing `sw` instructions directly after data generation, forcing the CPU to resolve Data Hazards while talking to the NPU.

## Simulation Instructions

The project is entirely written in Verilog and simulated using Icarus Verilog (`iverilog`).

**To compile and run the simulation:**
```bash
# Compile all Verilog modules
iverilog -o cpu.vvp *.v

# Execute the simulation
vvp cpu.vvp
