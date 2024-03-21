OUTDIR = out
TESTDIR = tests
SRCDIR = /Users/akash/Documents/Scripts/Digital/risc-v
SCRIPTDIR = scripts
synth = /Users/akash/Documents/Scripts/Digital/synth.sh

VCD_FILE = $(OUTDIR)/output.vcd
DUMP = $(OUTDIR)/dump
HEX = $(OUTDIR)/test_script.hex
ELF = $(OUTDIR)/test_script.elf
OBJ = $(OUTDIR)/test_script.o
SRC_FILES = $(wildcard $(TESTDIR)/*.sv)
TESTBENCH_FILE = $(TESTDIR)/tb_core.sv
TESTFILE = $(TESTDIR)/test_script.c
LINKER = $(TESTDIR)/linker.ld

.PHONY: all clean

all: $(VCD_FILE)

$(VCD_FILE): $(SRC_FILES) $(DUMP)
	$(synth) -cr -I $(SRCDIR) -b tb_core -o $(OUTDIR)/core $(TESTBENCH_FILE)
	vvp $(OUTDIR)/core.o &

$(DUMP): $(HEX)
	python $(SCRIPTDIR)/hex_dump.py $(HEX)

$(HEX): $(ELF)
	riscv32-unknown-elf-objcopy -O ihex $(ELF) -D $(HEX)

$(ELF): $(LINKER) $(OBJ)
	riscv32-unknown-elf-ld -T$(LINKER) $(OBJ) -o $(ELF)

$(OBJ): $(TESTFILE)
	riscv32-unknown-elf-gcc -c $(TESTFILE) -o $(OBJ) -march=rv32i -mabi=ilp32 -lgcc -lc

clean:
	rm -rf $(OUTDIR)/*
