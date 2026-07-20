# ============================================================
# Comprehensive self-checking test program for riscv32_top
# Fail counter = x31 (starts at 0 after reset; incremented on
# every failed check). Testbench declares PASS iff x31==0.
# ============================================================

# ---------- SECTION A: R-type ALU ----------
li   x1, 50
li   x2, 20
add  x3, x1, x2          # 70
sub  x4, x1, x2          # 30
sll  x5, x2, x1          # shamt = x1&31 = 18 ; 20<<18
srl  x6, x1, x2          # shamt = x2&31 = 20 ; 50>>20 = 0
sra  x7, x1, x2          # 0 (positive operand)
slt  x8, x2, x1          # 20<70 -> 1
sltu x9, x2, x1          # 1
xor  x10, x1, x2         # 50^20 = 38
or   x11, x1, x2         # 50|20 = 54
and  x12, x1, x2         # 50&20 = 16

li x30, 70
beq x3,x30,a1
addi x31,x31,1
a1:
li x30, 30
beq x4,x30,a2
addi x31,x31,1
a2:
li x30, 5242880
beq x5,x30,a3
addi x31,x31,1
a3:
li x30, 0
beq x6,x30,a4
addi x31,x31,1
a4:
beq x7,x30,a5
addi x31,x31,1
a5:
li x30, 1
beq x8,x30,a6
addi x31,x31,1
a6:
beq x9,x30,a7
addi x31,x31,1
a7:
li x30, 38
beq x10,x30,a8
addi x31,x31,1
a8:
li x30, 54
beq x11,x30,a9
addi x31,x31,1
a9:
li x30, 16
beq x12,x30,a10
addi x31,x31,1
a10:

sw x31, 200(x0)          # checkpoint: fail-count after R-type ALU section

# ---------- SECTION B: I-type ALU (incl. Bug1 regression) ----------
li   x22, 1
slli x23, x22, 4         # 16  (independent path, doesn't use negative ADDI)
sub  x30, x0, x23        # ground truth: 0-16 = -16, built via SUB not ADDI
addi x13, x0, -16        # value under test: bit10 of imm is 1 (regression case)
beq x13,x30,b0
addi x31,x31,1
b0:

li   x15, 5
slti x16, x15, 10        # 1
sltiu x17, x15, 10       # 1
slti x18, x15, 3         # 0
xori x19, x15, 6         # 5^6=3
ori  x20, x15, 6         # 5|6=7
andi x21, x15, 6         # 5&6=4
li x24, -8
srli x25, x24, 1         # 0x7FFFFFFC (logical)
srai x26, x24, 1         # 0xFFFFFFFC (arithmetic, sign-extended)

li x30, 1
beq x16,x30,b2
addi x31,x31,1
b2:
beq x17,x30,b3
addi x31,x31,1
b3:
li x30, 0
beq x18,x30,b4
addi x31,x31,1
b4:
li x30, 3
beq x19,x30,b5
addi x31,x31,1
b5:
li x30, 7
beq x20,x30,b6
addi x31,x31,1
b6:
li x30, 4
beq x21,x30,b7
addi x31,x31,1
b7:
li x30, 16
beq x23,x30,b8
addi x31,x31,1
b8:
li x30, 0x7FFFFFFC
beq x25,x30,b9
addi x31,x31,1
b9:
li x30, -4
beq x26,x30,b10
addi x31,x31,1
b10:

sw x31, 204(x0)          # checkpoint: fail-count after I-type ALU section

# ---------- SECTION C: LUI / AUIPC ----------
lui  x1, 0x12345
addi x1, x1, 0x111       # 0x12345111
li   x30, 0x12345111
beq  x1,x30,c1
addi x31,x31,1
c1:

auipc_check:
auipc x2, 0
li x30, auipc_check      # ground truth = this instruction's own address
beq x2,x30,c2
addi x31,x31,1
c2:

sw x31, 208(x0)          # checkpoint: fail-count after U-type (LUI/AUIPC) section

# ---------- SECTION D: store/load byte/half/word ----------
li x1, 0x12345678
sw x1, 0(x0)
lb  x2, 0(x0)
lb  x3, 1(x0)
lb  x4, 3(x0)
lbu x5, 0(x0)
lh  x6, 0(x0)
lh  x7, 2(x0)
lhu x8, 2(x0)

li x30, 0x78
beq x2,x30,d1
addi x31,x31,1
d1:
li x30, 0x56
beq x3,x30,d2
addi x31,x31,1
d2:
li x30, 0x12
beq x4,x30,d3
addi x31,x31,1
d3:
li x30, 0x78
beq x5,x30,d4
addi x31,x31,1
d4:
li x30, 0x5678
beq x6,x30,d5
addi x31,x31,1
d5:
li x30, 0x1234
beq x7,x30,d6
addi x31,x31,1
d6:
beq x8,x30,d7
addi x31,x31,1
d7:

li x9, 0x81828384
sw x9, 4(x0)
lb  x10, 4(x0)           # 0xFFFFFF84 (sign ext)
lbu x11, 4(x0)           # 0x00000084
lh  x12, 4(x0)           # 0xFFFF8384
lhu x13, 4(x0)           # 0x00008384
lb  x14, 7(x0)           # 0xFFFFFF81
lh  x15, 6(x0)           # 0xFFFF8182

li x30, -124
beq x10,x30,d8
addi x31,x31,1
d8:
li x30, 0x84
beq x11,x30,d9
addi x31,x31,1
d9:
li x30, -31868
beq x12,x30,d10
addi x31,x31,1
d10:
li x30, 0x8384
beq x13,x30,d11
addi x31,x31,1
d11:
li x30, -127
beq x14,x30,d12
addi x31,x31,1
d12:
li x30, -32382
beq x15,x30,d13
addi x31,x31,1
d13:

li x16, 0xAAAA
sh x16, 4(x0)            # only low half of word@4 changes
lw x17, 4(x0)
li x30, 0x8182AAAA
beq x17,x30,d14
addi x31,x31,1
d14:

li x18, 0xEE
sb x18, 4(x0)            # only lowest byte changes
lw x19, 4(x0)
li x30, 0x8182AAEE
beq x19,x30,d15
addi x31,x31,1
d15:

sw x31, 212(x0)          # checkpoint: fail-count after load/store section

# ---------- SECTION E: branches ----------
li x20, 5
li x21, 5
li x22, 9
li x23, -1
li x24, 1

beq x20,x21,e1
addi x31,x31,1
e1:
beq x20,x22,e2bad
jal x0, e2ok
e2bad:
addi x31,x31,1
e2ok:

bne x20,x22,e3
addi x31,x31,1
e3:
bne x20,x21,e4bad
jal x0, e4ok
e4bad:
addi x31,x31,1
e4ok:

blt x23,x24,e5           # -1 < 1 signed -> true
addi x31,x31,1
e5:
bltu x23,x24,e6bad       # 0xFFFFFFFF < 1 unsigned -> false
jal x0, e6ok
e6bad:
addi x31,x31,1
e6ok:

bge x24,x23,e7           # 1 >= -1 signed -> true
addi x31,x31,1
e7:
bgeu x24,x23,e8bad       # 1 >= 0xFFFFFFFF unsigned -> false
jal x0, e8ok
e8bad:
addi x31,x31,1
e8ok:

sw x31, 216(x0)          # checkpoint: fail-count after B-type (branch) section

# ---------- SECTION F: JAL / JALR ----------
jal_target:
jal x25, jal_landing
addi x31,x31,1
jal_landing:
li x30, jal_target
addi x30, x30, 4
beq x25,x30,f1
addi x31,x31,1
f1:

jalr_target:
jalr x26, x0, jalr_landing
addi x31,x31,1
jalr_landing:
li x30, jalr_target
addi x30, x30, 4
beq x26,x30,f2
addi x31,x31,1
f2:

sw x31, 220(x0)          # checkpoint: fail-count after JAL/JALR section

# ---------- done: report result ----------
sw x31, 252(x0)           # word offset 63 -> final total fail count
halt:
jal x0, halt
