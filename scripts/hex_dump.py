#!/usr/bin/env python3
import sys

FILE = sys.argv[1]
#instr_list = ['00000013']*1024
instr_list = []

with open(FILE, 'r', encoding='utf-8') as f:
    for line in f:

        if line[0] != ':':
            continue

        line = line[1:]
        byte_count = line[:2]
        address = line[2:6]
        addressn = int(address, 16)
        record_type = line[6:8]
        checksum = line[-3:]
        line = line[8:-3]
        if record_type == "00":
            C = 0
            for i in range(0, 2*int(byte_count, 16), 8):
                instr = line[i:i+8]
                INSTR = ''.join(reversed([instr[j:j+2] for j in
                                          range(0, len(instr), 2)]))
                instr_list.append([hex(addressn+(4*C))[2:], INSTR])
                # instr_list[(addressn + (4*C))//4] = INSTR
                C = C + 1

with open('out/dump', 'w', encoding='utf-8') as f:
    for insta in instr_list:
        #f.write(str(insta[0]) + " " + insta[1] + "\n")
        f.write(insta[1] + "\n")
        # f.write(insta + "\n")

        
