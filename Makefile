# Disassembly of HP 82143A printer microcontroller firmware
# Copyright 2023 Eric Smith
# SPDX-License-Identifier: GPL-3.0-only

all: check 82143a.bin 82143a.lst

82143a.p 82143a.lst: 82143a.asm chargen.inc
	asl $< -o $*.p -L

%.bin: %.p
	p2bin $? $@

check: 82143a.bin
	echo "59a8fb99cb121c142493782e0e2f645e567b4f16d4225221c05b24625f1aa483 82143a.bin" | sha256sum -c -

