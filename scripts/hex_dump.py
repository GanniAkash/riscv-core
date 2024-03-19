#!/usr/bin/env python3
instr_list = []
with open('out/sample.hex', 'r', encoding='utf-8') as f:
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
            C = 1
            for i in range(0, 2*int(byte_count, 16), 8):
                instr = line[i:i+8]
                INSTR = ''.join(reversed([instr[j:j+2] for j in
                                          range(0, len(instr), 2)]))
                instr_list.append([hex(addressn+(4*C))[2:], INSTR])
                C = C + 1

with open('out/dump', 'w', encoding='utf-8') as f:
    for insta in instr_list:
        f.write(str(insta[0]) + " " + insta[1] + "\n")
