# RV32I RISC-V Core (Verilog)

A pipelined RV32I RISC-V CPU core implemented in Verilog, with a
self-checking testbench covering every instruction format (R, I, S, B,
U, J), verified against an independently-written golden ISA model.

**Scope**: base RV32I integer instruction set. No CSR registers, no
traps/interrupts, no misaligned memory access support — this is a
clean, minimal core focused on getting the core datapath right, not a
full application-class implementation.

---

## Architecture

A 2-stage pipeline (fetch/decode → execute/writeback):

```
        ┌────────┐     ┌──────────────┐     ┌──────────────────┐
 PC ───▶│ Fetch  │────▶│ Decode +      │────▶│ Execute (ALU) +   │───▶ writeback
        │        │     │ Reg Read      │     │ Load/Store/Branch │
        └────────┘     └──────────────┘     └──────────────────┘
```

- **Register file** with single-cycle forwarding (a result being
  written back this cycle can be forwarded to an instruction reading
  that same register this cycle), covering the common back-to-back
  dependent-instruction case without a full hazard-detection/stall
  unit.
- **AHB-style data memory interface** (`HTRANS`, `HREADY`, `HRESP`)
  for loads/stores.
- Branch/jump resolution happens combinationally in the same cycle the
  instruction is fetched, so there is no branch delay slot.

### Modules

| Module | Responsibility |
|---|---|
| `pc` | Next-PC computation (sequential vs. branch/jump target) |
| `pipeline_reg_1` | PC pipeline register |
| `instruction_decoder` | Raw instruction field extraction |
| `decoder` | Control signal generation |
| `imm_generator` | Immediate decoding for all formats |
| `immediate_adder` | Branch/jump/load-store address computation |
| `branch_unit` | Branch condition evaluation + JAL/JALR redirect |
| `register_file` | 32×32-bit regs, with same-cycle write forwarding |
| `store_unit` | Store data/mask generation + AHB bus signaling |
| `pipeline_reg_2` | Execute-stage pipeline register |
| `load_unit` | Load data extraction (byte/half/word, sign/zero-extend) |
| `alu` | Arithmetic/logic operations |
| `wb_mux_sel_unit` | Writeback source selection |

---

## Bugs found and fixed

These were caught by manual code review before ever running a
simulation, then confirmed and regression-tested afterward.

### 1. ADDI (and other I-type ALU ops) silently computed as subtraction

The decoder reused the R-type ALU control encoding
(`{funct7[5], funct3}`) for I-type instructions too. `funct7[5]` isn't
a real field on I-type instructions — it's just bit 10 of the
immediate. Any `ADDI` with a negative immediate that happened to have
that bit set (e.g. `addi sp, sp, -16`, used constantly in function
prologues) was silently executed as a subtraction instead.

**Fix**: only let that bit affect ALU control for the one I-type case
where it's actually meaningful (`SRLI` vs. `SRAI`); force it to 0
otherwise.

### 2. JAL / JALR never redirected the PC

The `branch_unit` only asserted `branch_taken` for the conditional
branch opcode. JAL and JALR computed the correct target address and
correctly wrote the link register, but the core then just continued
to `PC+4` anyway — every `call`/`ret`/`j`/`tail` was silently a no-op
as far as control flow was concerned.

**Fix**: assert `branch_taken` unconditionally for the JAL and JALR
opcodes as well.

### 3. Loads never asserted a valid AHB bus transfer

`HTRANS` (the "this is a real bus transaction" signal) was only ever
driven high for stores. Loads presented a valid address but never
told the bus a transfer was happening, so a real AHB-compliant slave
would never respond — `data_in` would come back stale/undefined.

**Fix**: added a `mem_rd_req` signal from the decoder, and gated
`HTRANS` on load-or-store instead of store-only (write-specific
signals like `wr_req`/write-mask still only assert on an actual
store).

---

## Verification

### Testbench (`sim/riscv32_tb.v`)

Self-contained — includes the DUT instantiation, clock/reset
generation, a synchronous instruction ROM, and a small AHB-style data
memory model, plus 215 pre-assembled instructions and all
self-checking logic. No external files needed to compile and run it.

The instruction/data memories are deliberately **synchronous, one-cycle
latency**, matching the core's actual timing (the core's
`imaddr_out` is really *next*-cycle's PC, not the current one) — this
detail matters and is documented inline in the testbench, since a
naively combinational memory model would silently mask real timing
bugs (including Bug 3 above).

### Test program (`sim/program.s`)

215 instructions across six sections, each ending with a checkpoint so
results can be reported per category rather than as one aggregate
number:

| Section | Coverage |
|---|---|
| A — R-type | add, sub, sll, srl, sra, slt, sltu, xor, or, and |
| B — I-type | addi (incl. the Bug 1 regression case), slti, sltiu, xori, ori, andi, slli, srli, srai |
| C — U-type | lui, auipc |
| D — Load/Store | lb, lh, lw, lbu, lhu, sb, sh, sw — sign/zero extension, all byte/half offsets within a word, partial-write masking |
| E — B-type | beq, bne, blt, bge, bltu, bgeu — each tested taken *and* not-taken, including a signed-vs-unsigned discriminating case (`blt` vs. `bltu` on -1 vs. 1) |
| F — JAL/JALR | link-register correctness and actual control transfer |

**Self-checking mechanism**: register `x31` is a running fail counter,
starting at 0 (guaranteed by reset). Every check follows the same
pattern:

```asm
li   x30, <expected_value>
beq  <result>, x30, pass_label
addi x31, x31, 1        # only reached on mismatch
pass_label:
```

41 such checks in total. The testbench reads `x31` (via memory
snapshots taken at each section boundary) and reports PASS/FAIL per
category plus an overall result.

### Independent cross-check (`tools/golden_sim.py`)

Before trusting `program.s`'s own expected values, they were checked
against a second, completely independent implementation: a
from-scratch Python behavioral simulator of the RV32I ISA, executing
the same assembled program. It also reports a 0 fail-count,
confirming the test program's expectations are internally consistent
— this isn't just "the RTL agrees with my testbench," it's "two
independently-written implementations of the ISA agree with each
other," which is a meaningfully stronger check.

### Tooling (`tools/`)

- `asm.py` — a small RV32I assembler (all six instruction formats,
  two-pass label resolution, `li` pseudo-instruction) used to turn
  `program.s` into the hex instructions embedded in the testbench.
- `golden_sim.py` — the golden ISA simulator described above.
- `build_hex.py` — regenerates hex output from `program.s` if it's
  ever edited (only needed if you want to modify the test program;
  not needed to run the testbench as-is).

---

## Running the testbench

### Vivado (XSim)

1. Add `rtl/*.v` as **Design Sources** and `sim/riscv32_tb.v` as a
   **Simulation Source**.
2. Set `riscv32_tb` as the simulation top module.
3. **Simulation Settings → Simulation tab → `xsim.simulate.runtime`** —
   set to `all` (the default 1000ns is too short; this program needs
   ~2500ns to finish and report results).
4. Run Behavioral Simulation. Check the Tcl console for the result
   banner.

### Icarus Verilog

```sh
iverilog -o sim rtl/*.v sim/riscv32_tb.v
vvp sim
```

### Expected output

```
====================================================
 RISCV32 TOP - PER-CATEGORY REGRESSION RESULT
====================================================
 R-type  (ALU reg-reg)      : PASS  (fails=0)
 I-type  (ALU reg-imm)      : PASS  (fails=0)
 U-type  (LUI/AUIPC)        : PASS  (fails=0)
 Load/Store (I-type/S-type) : PASS  (fails=0)
 B-type  (branches)         : PASS  (fails=0)
 JAL/JALR                   : PASS  (fails=0)
----------------------------------------------------
 OVERALL: PASS -- all 41 checks passed
====================================================
```

---

## Repository structure

```
.
├── rtl/                 # synthesizable core (per-module .v files)
├── sim/
│   ├── riscv32_tb.v      # self-contained testbench — run this
│   └── program.s         # test program source (readable assembly)
├── tools/
│   ├── asm.py             # RV32I assembler
│   ├── golden_sim.py      # independent golden ISA simulator
│   └── build_hex.py       # regenerates hex from program.s
└── README.md
```

---

## Known limitations / not implemented

- No CSR registers, no `ecall`/`ebreak`/trap handling
- No misaligned memory access support
- Forwarding covers only the immediate next-cycle RAW hazard; no
  general stall/hazard-detection unit
- Data memory model in the testbench never asserts wait states
  (`HREADY` tied high) — bus back-pressure behavior is untested

## Possible next steps

- JALR test with a non-zero base register and non-word-aligned target
- Back-to-back dependent load→ALU hazard test (only ALU→ALU and
  ALU→store are currently covered)
- CSR/trap support with corresponding illegal-instruction tests
