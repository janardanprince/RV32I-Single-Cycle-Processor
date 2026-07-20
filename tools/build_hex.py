#!/usr/bin/env python3
"""
build_hex.py -- regenerate program.hex from program.s

Usage:
    python3 build_hex.py

Reads program.s (RV32I assembly, see asm.py for supported mnemonics),
assembles it, and writes program.hex: one 32-bit instruction per line,
plain lowercase hex, no '0x' prefix, no addresses -- exactly the format
Verilog's $readmemh expects.

Run this any time you edit program.s, then re-run the Vivado/Icarus
simulation -- riscv32_tb.v loads program.hex via $readmemh at time 0,
so there is nothing else to regenerate or copy/paste by hand.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from asm import assemble_full

HERE = os.path.dirname(os.path.abspath(__file__))
SRC  = os.path.join(HERE, "program.s")
OUT  = os.path.join(HERE, "program.hex")

def main():
    with open(SRC) as f:
        src = f.read()
    out, labels = assemble_full(src)
    with open(OUT, "w") as f:
        for addr, mnem, args, word in out:
            f.write(f"{word:08x}\n")
    print(f"Assembled {len(out)} instructions ({out[-1][0]+4} bytes) from {SRC}")
    print(f"Wrote {OUT}")

if __name__ == "__main__":
    main()
