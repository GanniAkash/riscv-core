#!/usr/bin/env python3
import sys

FILE = sys.argv[1]


def binstr_to_signed_int(binstr):
    """ Converts a signed binary string to integer """

    if binstr[0] == '1':
        unsigned_value = int(binstr, 2)
        value = unsigned_value - (1 << len(binstr))
    else:
        value = int(binstr, 2)
    return value


with open(FILE, 'r', encoding='utf-8') as f:
    for line in f.readlines():
        addr, inst = line.strip().split(" ")
        inst = format(int(inst, 16), '032b')
        op = inst[-7:]
        rd = inst[-12:-7]
        rs1 = inst[-20:-15]
        rs2 = inst[-25:-20]
        funct3 = inst[-15:-12]
        funct7 = inst[-32:-25]

        # print(addr, op, funct3, rd, rs1)
        print(f'0x{addr}:', "\t", end="")

        if op == '0000011':  # loads
            imm = inst[:12]
            if funct3 == '000':
                print(f"lb x{int(rd, 2)}, {binstr_to_signed_int(imm)}(x{int(rs1, 2)})")
            elif funct3 == '001':
                print(f"lh x{int(rd, 2)}, {binstr_to_signed_int(imm)}(x{int(rs1, 2)})")
            elif funct3 == '010':
                print(f"lw x{int(rd, 2)}, {binstr_to_signed_int(imm)}(x{int(rs1, 2)})")
            elif funct3 == '100':
                print(f"lbu x{int(rd, 2)}, {binstr_to_signed_int(imm)}(x{int(rs1, 2)})")
            elif funct3 == '101':
                print(f"lhu x{int(rd, 2)}, {binstr_to_signed_int(imm)}(x{int(rs1, 2)})")
            else:
                print("nop loads")
        elif op == '0010011':  # I-type
            imm = inst[:12]
            if funct3 == '000':
                print(f"addi x{int(rd, 2)}, x{int(rs1, 2)}, {binstr_to_signed_int(imm)}")
            elif funct3 == '010':
                print(f"slti x{int(rd, 2)}, x{int(rs1, 2)}, {binstr_to_signed_int(imm)}")
            elif funct3 == '011':
                print(f"sltiu x{int(rd, 2)}, x{int(rs1, 2)}, {binstr_to_signed_int(imm)}")
            elif funct3 == '100':
                print(f"xori x{int(rd, 2)}, x{int(rs1, 2)}, {binstr_to_signed_int(imm)}")
            elif funct3 == '110':
                print(f"ori x{int(rd, 2)}, x{int(rs1, 2)}, {binstr_to_signed_int(imm)}")
            elif funct3 == '111':
                print(f"andi x{int(rd, 2)}, x{int(rs1, 2)}, {binstr_to_signed_int(imm)}")
            elif funct3 == '001':
                print(f"slli x{int(rd, 2)}, x{int(rs1, 2)}, {int(imm[-6:], 2)}")
            elif funct3 == '101' and funct7 == '0000000':
                print(f"srli x{int(rd, 2)}, x{int(rs1, 2)}, {int(imm[-6:], 2)}")
            elif funct3 == '101' and funct7 == '0100000':
                print(f"srai x{int(rd, 2)}, x{int(rs1, 2)}, {int(imm[-6:], 2)}")
            else:
                print("nop I")
        elif op == '0010111':  # auipc
            imm = inst[:21]
            print(f"auipc x{int(rd, 2)}, {int(imm, 2)}")
        elif op == '0100011':  # stores
            imm = funct7 + rd
            if funct3 == '000':
                print(f"sb x{int(rs2, 2)}, {binstr_to_signed_int(imm)}(x{int(rs1, 2)})")
            elif funct3 == '001':
                print(f"sh x{int(rs2, 2)}, {binstr_to_signed_int(imm)}(x{int(rs1, 2)})")
            elif funct3 == '010':
                print(f"sw x{int(rs2, 2)}, {binstr_to_signed_int(imm)}(x{int(rs1, 2)})")
            else:
                print("nop store")
        elif op == '0110011':  # R-type
            if funct3 == '000' and funct7[1] == '0':
                print(f"add x{int(rd, 2)}, x{int(rs1, 2)}, x{int(rs2, 2)}")
            elif funct3 == '000' and funct7[1] == '1':
                print(f"sub x{int(rd, 2)}, x{int(rs1, 2)}, x{int(rs2, 2)}")
            elif funct3 == '001':
                print(f"sll x{int(rd, 2)}, x{int(rs1, 2)}, x{int(rs2, 2)}")
            elif funct3 == '010':
                print(f"slt x{int(rd, 2)}, x{int(rs1, 2)}, x{int(rs2, 2)}")
            elif funct3 == '011':
                print(f"sltu x{int(rd, 2)}, x{int(rs1, 2)}, x{int(rs2, 2)}")
            elif funct3 == '100':
                print(f"xor x{int(rd, 2)}, x{int(rs1, 2)}, x{int(rs2, 2)}")
            elif funct3 == '101' and funct7[1] == '0':
                print(f"srl x{int(rd, 2)}, x{int(rs1, 2)}, x{int(rs2, 2)}")
            elif funct3 == '101' and funct7[1] =='1':
                print(f"sra x{int(rd, 2)}, x{int(rs1, 2)}, x{int(rs2, 2)}")
            elif funct3 == '110':
                print(f"or x{int(rd, 2)}, x{int(rs1, 2)}, x{int(rs2, 2)}")
            elif funct3 == '111':
                print(f"and x{int(rd, 2)}, x{int(rs1, 2)}, x{int(rs2, 2)}")
            else:
                print("nop r")
        elif op == '0110111':  # lui
            imm = inst[:21]
            print(f"lui x{int(rd, 2)}, {int(imm, 2)}")
        elif op == '1100011':  # Branches
            imm = funct7[0] + rd[0] + funct7[1:] + rd[:-1] + '0'
            if funct3 == '000':
                print(f"beq x{int(rs1, 2)}, x{int(rs2, 2)}, {binstr_to_signed_int(imm)}")
            elif funct3 == '001':
                print(f"bne x{int(rs1, 2)}, x{int(rs2, 2)}, {binstr_to_signed_int(imm)}")
            elif funct3 == '100':
                print(f"blt x{int(rs1, 2)}, x{int(rs2, 2)}, {binstr_to_signed_int(imm)}")
            elif funct3 == '101':
                print(f"bge x{int(rs1, 2)}, x{int(rs2, 2)}, {binstr_to_signed_int(imm)}")
            elif funct3 == '110':
                print(f"bltu x{int(rs1, 2)}, x{int(rs2, 2)}, {binstr_to_signed_int(imm)}")
            elif funct3 == '111':
                print(f"bgeu x{int(rs1, 2)}, x{int(rs2, 2)}, {binstr_to_signed_int(imm)}")
            else:
                print("nop branch")
        elif op == '1100111':  # jalr
            imm = inst[:12]
            print(f"jalr x{int(rd, 2)}, x{int(rs1, 2)}, {binstr_to_signed_int(imm)}")
        elif op == '1101111':  # jal
            temp = inst[:21]
            imm = temp[0] + temp[-8:] + temp[-9] + temp[1:11] + '0'
            print(f"jal x{int(rd, 2)}, {binstr_to_signed_int(imm)}")
        else:
            print("nop")
