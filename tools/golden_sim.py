import sys
sys.path.insert(0,'/home/claude/asm')
from asm import assemble_full

def u32(x): return x & 0xFFFFFFFF
def s32(x):
    x = u32(x)
    return x - (1<<32) if x & 0x80000000 else x

def run(src, max_steps=2000):
    out, labels = assemble_full(src)
    mem_i = {addr: word for addr,mnem,args,word in out}
    prog_end = max(mem_i.keys()) + 4

    regs = [0]*32
    dmem = bytearray(4096)
    pc = 0
    steps = 0

    def rd_reg(i): return 0 if i==0 else regs[i]
    def wr_reg(i,v):
        if i!=0: regs[i] = u32(v)

    def load_word(addr):
        return int.from_bytes(dmem[addr:addr+4], 'little')
    def store_word(addr, val, mask=0xF):
        b = bytearray(dmem[addr:addr+4])
        vb = u32(val).to_bytes(4,'little')
        for i in range(4):
            if mask & (1<<i):
                b[i] = vb[i]
        dmem[addr:addr+4] = b

    halt_addr = labels.get('halt')

    while steps < max_steps:
        if pc not in mem_i:
            print(f"PC 0x{pc:x} out of program range - stopping")
            break
        word = mem_i[pc]
        opcode = word & 0x7F
        rd = (word>>7)&0x1F
        funct3 = (word>>12)&0x7
        rs1 = (word>>15)&0x1F
        rs2 = (word>>20)&0x1F
        funct7 = (word>>25)&0x7F
        imm_i = s32((word>>20)) if not (word>>20)&0x800 else s32((word>>20)|0xFFFFF000)
        # proper sign extension for I-imm (12 bits)
        imm_i = word >> 20
        if imm_i & 0x800: imm_i |= 0xFFFFF000
        imm_i = s32(imm_i)

        imm_s = ((word>>25)<<5) | ((word>>7)&0x1F)
        if imm_s & 0x800: imm_s |= 0xFFFFF000
        imm_s = s32(imm_s)

        imm_b = (((word>>31)&1)<<12)|(((word>>7)&1)<<11)|(((word>>25)&0x3F)<<5)|(((word>>8)&0xF)<<1)
        if imm_b & 0x1000: imm_b |= 0xFFFFE000
        imm_b = s32(imm_b)

        imm_u = word & 0xFFFFF000

        imm_j = (((word>>31)&1)<<20)|(((word>>12)&0xFF)<<12)|(((word>>20)&1)<<11)|(((word>>21)&0x3FF)<<1)
        if imm_j & 0x100000: imm_j |= 0xFFE00000
        imm_j = s32(imm_j)

        next_pc = pc + 4
        v1 = rd_reg(rs1); v2 = rd_reg(rs2)

        if opcode == 0b0110011:  # R-type
            if   funct3==0b000: res = (v1-v2) if funct7 else (v1+v2)
            elif funct3==0b001: res = u32(v1) << (v2 & 0x1F)
            elif funct3==0b010: res = 1 if s32(v1) < s32(v2) else 0
            elif funct3==0b011: res = 1 if u32(v1) < u32(v2) else 0
            elif funct3==0b100: res = v1 ^ v2
            elif funct3==0b101: res = (s32(v1) >> (v2&0x1F)) if funct7 else (u32(v1) >> (v2&0x1F))
            elif funct3==0b110: res = v1 | v2
            elif funct3==0b111: res = v1 & v2
            wr_reg(rd, res)
        elif opcode == 0b0010011:  # I-type ALU
            if   funct3==0b000: res = v1 + imm_i
            elif funct3==0b010: res = 1 if s32(v1) < imm_i else 0
            elif funct3==0b011: res = 1 if u32(v1) < u32(imm_i) else 0
            elif funct3==0b100: res = v1 ^ imm_i
            elif funct3==0b110: res = v1 | imm_i
            elif funct3==0b111: res = v1 & imm_i
            elif funct3==0b001: res = u32(v1) << (imm_i & 0x1F)
            elif funct3==0b101:
                shamt = imm_i & 0x1F
                res = (s32(v1) >> shamt) if (word>>25)&0x20 else (u32(v1) >> shamt)
            wr_reg(rd, res)
        elif opcode == 0b0000011:  # loads
            addr = u32(v1 + imm_i)
            if funct3==0b000: val = s32(dmem[addr]) if dmem[addr]<0x80 else dmem[addr]-256
            elif funct3==0b001:
                h = int.from_bytes(dmem[addr:addr+2],'little')
                val = h-65536 if h&0x8000 else h
            elif funct3==0b010: val = s32(load_word(addr))
            elif funct3==0b100: val = dmem[addr]
            elif funct3==0b101: val = int.from_bytes(dmem[addr:addr+2],'little')
            wr_reg(rd, val)
        elif opcode == 0b0100011:  # stores
            addr = u32(v1 + imm_s)
            if funct3==0b000: dmem[addr] = u32(v2) & 0xFF
            elif funct3==0b001: dmem[addr:addr+2] = (u32(v2)&0xFFFF).to_bytes(2,'little')
            elif funct3==0b010: dmem[addr:addr+4] = u32(v2).to_bytes(4,'little')
        elif opcode == 0b1100011:  # branches
            taken = False
            if   funct3==0b000: taken = v1==v2
            elif funct3==0b001: taken = v1!=v2
            elif funct3==0b100: taken = s32(v1) < s32(v2)
            elif funct3==0b101: taken = s32(v1) >= s32(v2)
            elif funct3==0b110: taken = u32(v1) < u32(v2)
            elif funct3==0b111: taken = u32(v1) >= u32(v2)
            if taken: next_pc = u32(pc + imm_b)
        elif opcode == 0b1101111:  # jal
            wr_reg(rd, pc+4)
            next_pc = u32(pc + imm_j)
        elif opcode == 0b1100111:  # jalr
            wr_reg(rd, pc+4)
            next_pc = u32((v1 + imm_i) & ~1)
        elif opcode == 0b0110111:  # lui
            wr_reg(rd, imm_u)
        elif opcode == 0b0010111:  # auipc
            wr_reg(rd, u32(pc + imm_u))
        else:
            print(f"unknown opcode at pc={pc:x}: {opcode:07b}")
            break

        if halt_addr is not None and pc == halt_addr and next_pc == halt_addr:
            break
        pc = next_pc
        steps += 1

    return regs, dmem, steps

if __name__ == '__main__':
    src = open('/home/claude/asm/program.s').read()
    regs, dmem, steps = run(src)
    print(f"Ran {steps} instructions")
    print("x31 (fail count) =", regs[31])
    for i in range(1,32):
        if regs[i] != 0:
            print(f"x{i} = 0x{u32(regs[i]):08x} ({s32(regs[i])})")
