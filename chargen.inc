; Disassembly of HP 82143A printer microcontroller firmware
; Copyright 2023 Eric Smith
; Copyright is NOT claimed on the original HP 82143A ROM binary
; SPDX-License-Identifier: GPL-3.0-only

cb_row  set     0
cb_col0 set     0
cb_col1 set     0
cb_col2 set     0
cb_col3 set     0
cb_col4 set     0

charbit macro   s
cb_col0 set     (cb_col0 >> 1) | (0x40 * (substr(s, 0, 1) != ' '))
cb_col1 set     (cb_col1 >> 1) | (0x40 * (substr(s, 1, 1) != ' '))
cb_col2 set     (cb_col2 >> 1) | (0x40 * (substr(s, 2, 1) != ' '))
cb_col3 set     (cb_col3 >> 1) | (0x40 * (substr(s, 3, 1) != ' '))
cb_col4 set     (cb_col4 >> 1) | (0x40 * (substr(s, 4, 1) != ' '))
cb_row	set	cb_row+1
	if	cb_row==7
	db	cb_col4 & 0x7f, cb_col3 & 0x7f, cb_col2 & 0x7f, cb_col1 & 0x7f, cb_col0 & 0x7f
cb_row  set     0
cb_col0 set     0
cb_col1 set     0
cb_col2 set     0
cb_col3 set     0
cb_col4 set     0
	endif
        endm

; character 00
cg_nul: charbit "     "
        charbit "  O  "
        charbit " OOO "
        charbit "OOOOO"
        charbit " OOO "
        charbit "  O  "
        charbit "     "

; character 01
        charbit "     "
        charbit "     "
        charbit " O O "
        charbit "  O  "
        charbit " O O "
        charbit "     "
        charbit "     "

; character 02
        charbit "OOOOO"
        charbit "     "
        charbit "O   O"
        charbit " O O "
        charbit "  O  "
        charbit " O O "
        charbit "O   O"

; character 03
        charbit "     "
        charbit "  O  "
        charbit " O   "
        charbit "OOOOO"
        charbit " O   "
        charbit "  O  "
        charbit "     "

; character 04
        charbit "     "
        charbit "     "
        charbit " OO O"
        charbit "O  O "
        charbit "O  O "
        charbit "O  O "
        charbit " OO O"

; character 05
        charbit " OOO "
        charbit "O   O"
        charbit "OOOO "
        charbit "O   O"
        charbit "OO  O"
        charbit "O OO "
        charbit "O    "

; character 06
        charbit "OOOOO"
        charbit "O   O"
        charbit "O    "
        charbit "O    "
        charbit "O    "
        charbit "O    "
        charbit "O    "

; character 07
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "O O O"
        charbit " OOO "
        charbit "  O  "

; character 08
        charbit "     "
        charbit "  O  "
        charbit "  O  "
        charbit " O O "
        charbit " O O "
        charbit "O   O"
        charbit "OOOOO"

; character 09
        charbit "     "
        charbit "     "
        charbit " OOOO"
        charbit "O  O "
        charbit "O  O "
        charbit "O  O "
        charbit " OO  "

; character 0a
        charbit "     "
        charbit "  O  "
        charbit " OOO "
        charbit "OOOOO"
        charbit " OOO "
        charbit "  O  "
        charbit "     "

; character 0b
        charbit "     "
        charbit "O    "
        charbit " O   "
        charbit "  O  "
        charbit " O O "
        charbit "O   O"
        charbit "O   O"

; character 0c
        charbit "     "
        charbit "     "
        charbit " O  O"
        charbit " O  O"
        charbit " O  O"
        charbit " OOO "
        charbit "O    "

; character 0d
        charbit "     "
        charbit "    O"
        charbit "   O "
        charbit "  O  "
        charbit " OO  "
        charbit "O  O "
        charbit "OOOOO"

; character 0e
        charbit "     "
        charbit "     "
        charbit "    O"
        charbit " OOO "
        charbit "O O  "
        charbit "  O  "
        charbit "  O  "

; character 0f
        charbit " OOO "
        charbit "  O  "
        charbit " OOO "
        charbit "O O O"
        charbit " OOO "
        charbit "  O  "
        charbit " OOO "

; character 10
        charbit " OOO "
        charbit "O   O"
        charbit "O   O"
        charbit "OOOOO"
        charbit "O   O"
        charbit "O   O"
        charbit " OOO "

; character 11
        charbit " OOO "
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit " O O "
        charbit "OO OO"

; character 12
        charbit "  OO "
        charbit " O   "
        charbit "  O  "
        charbit " OOO "
        charbit "O   O"
        charbit "O   O"
        charbit " OOO "

; character 13
        charbit "  O  "
        charbit "     "
        charbit " OOO "
        charbit "O   O"
        charbit "OOOOO"
        charbit "O   O"
        charbit "O   O"

; character 14
        charbit "  O  "
        charbit "     "
        charbit " OOO "
        charbit "O  O "
        charbit "O  O "
        charbit "O  O "
        charbit " OO O"

; character 15
        charbit " O O "
        charbit "     "
        charbit " OOO "
        charbit "O   O"
        charbit "OOOOO"
        charbit "O   O"
        charbit "O   O"

; character 16
        charbit " O O "
        charbit "     "
        charbit " OOO "
        charbit "O  O "
        charbit "O  O "
        charbit "O  O "
        charbit " OO O"

; character 17
        charbit " O O "
        charbit " OOO "
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit " OOO "

; character 18
        charbit " O O "
        charbit "     "
        charbit " OOO "
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit " OOO "

; character 19
        charbit " O O "
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit " OOO "

; character 1a
        charbit " O O "
        charbit "     "
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit " OOO "

; character 1b
        charbit " OOOO"
        charbit "O O  "
        charbit "O O  "
        charbit "OOOOO"
        charbit "O O  "
        charbit "O O  "
        charbit "O OOO"

; character 1c
        charbit "     "
        charbit "     "
        charbit " O O "
        charbit "O O O"
        charbit "O OOO"
        charbit "O O  "
        charbit " O OO"

; character 1d
        charbit "     "
        charbit "   O "
        charbit "OOOOO"
        charbit "  O  "
        charbit "OOOOO"
        charbit " O   "
        charbit "     "

; character 1e
        charbit "  OO "
        charbit " O  O"
        charbit " O   "
        charbit "OOO  "
        charbit " O   "
        charbit " O  O"
        charbit "OOOO "

; character 1f
        charbit "O O O"
        charbit " O O "
        charbit "O O O"
        charbit " O O "
        charbit "O O O"
        charbit " O O "
        charbit "O O O"

; character 20
cg_spc: charbit "     "
        charbit "     "
        charbit "     "
        charbit "     "
        charbit "     "
        charbit "     "
        charbit "     "

; character 21
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "     "
        charbit "  O  "

; character 22
        charbit "     "
        charbit " O O "
        charbit " O O "
        charbit "     "
        charbit "     "
        charbit "     "
        charbit "     "

; character 23
        charbit " O O "
        charbit " O O "
        charbit "OOOOO"
        charbit " O O "
        charbit "OOOOO"
        charbit " O O "
        charbit " O O "

; character 24
        charbit "  O  "
        charbit " OOOO"
        charbit "O O  "
        charbit " OOO "
        charbit "  O O"
        charbit "OOOO "
        charbit "  O  "

; character 25
        charbit "OO   "
        charbit "OO  O"
        charbit "   O "
        charbit "  O  "
        charbit " O   "
        charbit "O  OO"
        charbit "   OO"

; character 26
        charbit " O   "
        charbit "O O  "
        charbit "O O  "
        charbit " O   "
        charbit "O O O"
        charbit "O  O "
        charbit " OO O"

; character 27
        charbit "     "
        charbit "  O  "
        charbit "  O  "
        charbit "     "
        charbit "     "
        charbit "     "
        charbit "     "

; character 28
        charbit "   O "
        charbit "  O  "
        charbit " O   "
        charbit " O   "
        charbit " O   "
        charbit "  O  "
        charbit "   O "

; character 29
        charbit " O   "
        charbit "  O  "
        charbit "   O "
        charbit "   O "
        charbit "   O "
        charbit "  O  "
        charbit " O   "

; character 2a
        charbit "     "
        charbit "  O  "
        charbit "O O O"
        charbit " OOO "
        charbit "O O O"
        charbit "  O  "
        charbit "     "

; character 2b
        charbit "     "
        charbit "  O  "
        charbit "  O  "
        charbit "OOOOO"
        charbit "  O  "
        charbit "  O  "
        charbit "     "

; character 2c
        charbit "     "
        charbit "     "
        charbit "     "
        charbit "     "
        charbit "  O  "
        charbit "  O  "
        charbit " O   "

; character 2d
        charbit "     "
        charbit "     "
        charbit "     "
        charbit "OOOOO"
        charbit "     "
        charbit "     "
        charbit "     "

; character 2e
        charbit "     "
        charbit "     "
        charbit "     "
        charbit "     "
        charbit "     "
        charbit " OO  "
        charbit " OO  "

; character 2f
        charbit "     "
        charbit "    O"
        charbit "   O "
        charbit "  O  "
        charbit " O   "
        charbit "O    "
        charbit "     "

; character 30
        charbit " OOO "
        charbit "O   O"
        charbit "O  OO"
        charbit "O O O"
        charbit "OO  O"
        charbit "O   O"
        charbit " OOO "

; character 31
        charbit "  O  "
        charbit " OO  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit " OOO "

; character 32
        charbit " OOO "
        charbit "O   O"
        charbit "    O"
        charbit "  OO "
        charbit " O   "
        charbit "O    "
        charbit "OOOOO"

; character 33
        charbit "OOOOO"
        charbit "    O"
        charbit "   O "
        charbit "  OO "
        charbit "    O"
        charbit "O   O"
        charbit " OOO "

; character 34
        charbit "   O "
        charbit "  OO "
        charbit " O O "
        charbit "O  O "
        charbit "OOOOO"
        charbit "   O "
        charbit "   O "

; character 35
        charbit "OOOOO"
        charbit "O    "
        charbit "OOOO "
        charbit "    O"
        charbit "    O"
        charbit "O   O"
        charbit " OOO "

; character 36
        charbit "  OO "
        charbit " O   "
        charbit "O    "
        charbit "OOOO "
        charbit "O   O"
        charbit "O   O"
        charbit " OOO "

; character 37
        charbit "OOOOO"
        charbit "    O"
        charbit "   O "
        charbit "  O  "
        charbit " O   "
        charbit " O   "
        charbit " O   "

; character 38
        charbit " OOO "
        charbit "O   O"
        charbit "O   O"
        charbit " OOO "
        charbit "O   O"
        charbit "O   O"
        charbit " OOO "

; character 39
        charbit " OOO "
        charbit "O   O"
        charbit "O   O"
        charbit " OOOO"
        charbit "    O"
        charbit "   O "
        charbit " OO  "

; character 3a
        charbit "     "
        charbit "     "
        charbit "  O  "
        charbit "     "
        charbit "     "
        charbit "  O  "
        charbit "     "

; character 3b
        charbit "     "
        charbit "     "
        charbit "  O  "
        charbit "     "
        charbit "  O  "
        charbit "  O  "
        charbit " O   "

; character 3c
        charbit "   O "
        charbit "  O  "
        charbit " O   "
        charbit "O    "
        charbit " O   "
        charbit "  O  "
        charbit "   O "

; character 3d
        charbit "     "
        charbit "     "
        charbit "OOOOO"
        charbit "     "
        charbit "OOOOO"
        charbit "     "
        charbit "     "

; character 3e
        charbit " O   "
        charbit "  O  "
        charbit "   O "
        charbit "    O"
        charbit "   O "
        charbit "  O  "
        charbit " O   "

; character 3f
        charbit " OOO "
        charbit "O   O"
        charbit "    O"
        charbit "   O "
        charbit "  O  "
        charbit "     "
        charbit "  O  "

; character 40
        charbit " OOO "
        charbit "O   O"
        charbit "O OOO"
        charbit "O O O"
        charbit "O OOO"
        charbit "O    "
        charbit " OOO "

; character 41
        charbit " OOO "
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit "OOOOO"
        charbit "O   O"
        charbit "O   O"

; character 42
        charbit "OOOO "
        charbit "O   O"
        charbit "O   O"
        charbit "OOOO "
        charbit "O   O"
        charbit "O   O"
        charbit "OOOO "

; character 43
        charbit " OOO "
        charbit "O   O"
        charbit "O    "
        charbit "O    "
        charbit "O    "
        charbit "O   O"
        charbit " OOO "

; character 44
        charbit "OOOO "
        charbit " O  O"
        charbit " O  O"
        charbit " O  O"
        charbit " O  O"
        charbit " O  O"
        charbit "OOOO "

; character 45
        charbit "OOOOO"
        charbit "O    "
        charbit "O    "
        charbit "OOOO "
        charbit "O    "
        charbit "O    "
        charbit "OOOOO"

; character 46
        charbit "OOOOO"
        charbit "O    "
        charbit "O    "
        charbit "OOOO "
        charbit "O    "
        charbit "O    "
        charbit "O    "

; character 47
        charbit " OOO "
        charbit "O   O"
        charbit "O    "
        charbit "O    "
        charbit "O  OO"
        charbit "O   O"
        charbit " OOOO"

; character 48
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit "OOOOO"
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"

; character 49
        charbit " OOO "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit " OOO "

; character 4a
        charbit "    O"
        charbit "    O"
        charbit "    O"
        charbit "    O"
        charbit "    O"
        charbit "O   O"
        charbit " OOO "

; character 4b
        charbit "O   O"
        charbit "O  O "
        charbit "O O  "
        charbit "OO   "
        charbit "O O  "
        charbit "O  O "
        charbit "O   O"

; character 4c
        charbit "O    "
        charbit "O    "
        charbit "O    "
        charbit "O    "
        charbit "O    "
        charbit "O    "
        charbit "OOOOO"

; character 4d
        charbit "O   O"
        charbit "OO OO"
        charbit "O O O"
        charbit "O O O"
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"

; character 4e
        charbit "O   O"
        charbit "O   O"
        charbit "OO  O"
        charbit "O O O"
        charbit "O  OO"
        charbit "O   O"
        charbit "O   O"

; character 4f
        charbit " OOO "
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit " OOO "

; character 50
        charbit "OOOO "
        charbit "O   O"
        charbit "O   O"
        charbit "OOOO "
        charbit "O    "
        charbit "O    "
        charbit "O    "

; character 51
        charbit " OOO "
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit "O O O"
        charbit "O  O "
        charbit " OO O"

; character 52
        charbit "OOOO "
        charbit "O   O"
        charbit "O   O"
        charbit "OOOO "
        charbit "O O  "
        charbit "O  O "
        charbit "O   O"

; character 53
        charbit " OOO "
        charbit "O   O"
        charbit "O    "
        charbit " OOO "
        charbit "    O"
        charbit "O   O"
        charbit " OOO "

; character 54
        charbit "OOOOO"
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "

; character 55
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit " OOO "

; character 56
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit " O O "
        charbit " O O "
        charbit "  O  "
        charbit "  O  "

; character 57
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit "O O O"
        charbit "O O O"
        charbit "OO OO"
        charbit "O   O"

; character 58
        charbit "O   O"
        charbit "O   O"
        charbit " O O "
        charbit "  O  "
        charbit " O O "
        charbit "O   O"
        charbit "O   O"

; character 59
        charbit "O   O"
        charbit "O   O"
        charbit " O O "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "

; character 5a
        charbit "OOOOO"
        charbit "    O"
        charbit "   O "
        charbit "  O  "
        charbit " O   "
        charbit "O    "
        charbit "OOOOO"

; character 5b
        charbit " OOO "
        charbit " O   "
        charbit " O   "
        charbit " O   "
        charbit " O   "
        charbit " O   "
        charbit " OOO "

; character 5c
        charbit "     "
        charbit "O    "
        charbit " O   "
        charbit "  O  "
        charbit "   O "
        charbit "    O"
        charbit "     "

; character 5d
        charbit " OOO "
        charbit "   O "
        charbit "   O "
        charbit "   O "
        charbit "   O "
        charbit "   O "
        charbit " OOO "

; character 5e
        charbit "  O  "
        charbit " OOO "
        charbit "O O O"
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "

; character 5f
        charbit "     "
        charbit "     "
        charbit "     "
        charbit "     "
        charbit "     "
        charbit "     "
        charbit "OOOOO"

; character 60
        charbit " OOO "
        charbit "  O  "
        charbit "  O  "
        charbit "     "
        charbit "     "
        charbit "     "
        charbit "     "

; character 61
        charbit "     "
        charbit "     "
        charbit " OOO "
        charbit "    O"
        charbit " OOOO"
        charbit "O   O"
        charbit " OOOO"

; character 62
        charbit "O    "
        charbit "O    "
        charbit "O OO "
        charbit "OO  O"
        charbit "O   O"
        charbit "O   O"
        charbit "OOOO "

; character 63
        charbit "     "
        charbit "     "
        charbit " OOO "
        charbit "O    "
        charbit "O    "
        charbit "O   O"
        charbit " OOO "

; character 64
        charbit "    O"
        charbit "    O"
        charbit " OO O"
        charbit "O  OO"
        charbit "O   O"
        charbit "O   O"
        charbit " OOOO"

; character 65
        charbit "     "
        charbit "     "
        charbit " OOO "
        charbit "O   O"
        charbit "OOOO "
        charbit "O    "
        charbit " OOO "

; character 66
        charbit "  O  "
        charbit " O O "
        charbit " O   "
        charbit "OOO  "
        charbit " O   "
        charbit " O   "
        charbit " O   "

; character 67
        charbit "     "
        charbit "     "
        charbit " OOOO"
        charbit "O   O"
        charbit " OOOO"
        charbit "    O"
        charbit "  OO "

; character 68
        charbit "O    "
        charbit "O    "
        charbit "O OO "
        charbit "OO  O"
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"

; character 69
        charbit "  O  "
        charbit "     "
        charbit " OO  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit " OOO "

; character 6a
        charbit "   O "
        charbit "     "
        charbit "   O "
        charbit "   O "
        charbit "   O "
        charbit "O  O "
        charbit " OO  "

; character 6b
        charbit " O   "
        charbit " O   "
        charbit " O  O"
        charbit " O O "
        charbit " OO  "
        charbit " O O "
        charbit " O  O"

; character 6c
        charbit " OO  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit " OOO "

; character 6d
        charbit "     "
        charbit "     "
        charbit " O O "
        charbit "O O O"
        charbit "O O O"
        charbit "O   O"
        charbit "O   O"

; character 6e
        charbit "     "
        charbit "     "
        charbit "O OO "
        charbit "OO  O"
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"

; character 6f
        charbit "     "
        charbit "     "
        charbit " OOO "
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit " OOO "

; character 70
        charbit "     "
        charbit "     "
        charbit "OOOO "
        charbit "O   O"
        charbit "OO  O"
        charbit "O OO "
        charbit "O    "

; character 71
        charbit "     "
        charbit "     "
        charbit " OOO "
        charbit "O  O "
        charbit "O OO "
        charbit " O O "
        charbit "   OO"

; character 72
        charbit "     "
        charbit "     "
        charbit "O OO "
        charbit "OO  O"
        charbit "O    "
        charbit "O    "
        charbit "O    "

; character 73
        charbit "     "
        charbit "     "
        charbit " OOO "
        charbit "O    "
        charbit " OOO "
        charbit "    O"
        charbit "OOOO "

; character 74
        charbit "     "
        charbit " O   "
        charbit "OOO  "
        charbit " O   "
        charbit " O   "
        charbit " O O "
        charbit "  O  "

; character 75
        charbit "     "
        charbit "     "
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit "O  OO"
        charbit " OO O"

; character 76
        charbit "     "
        charbit "     "
        charbit "O   O"
        charbit "O   O"
        charbit "O   O"
        charbit " O O "
        charbit "  O  "

; character 77
        charbit "     "
        charbit "     "
        charbit "O   O"
        charbit "O   O"
        charbit "O O O"
        charbit "O O O"
        charbit " O O "

; character 78
        charbit "     "
        charbit "     "
        charbit "O   O"
        charbit " O O "
        charbit "  O  "
        charbit " O O "
        charbit "O   O"

; character 79
        charbit "     "
        charbit "     "
        charbit "O   O"
        charbit " O O "
        charbit "  O  "
        charbit "  O  "
        charbit " O   "

; character 7a
        charbit "     "
        charbit "     "
        charbit "OOOOO"
        charbit "   O "
        charbit "  O  "
        charbit " O   "
        charbit "OOOOO"

; character 7b
        charbit "     "
        charbit "     "
        charbit "    O"
        charbit "OOOO "
        charbit " O O "
        charbit " O O "
        charbit " O O "

; character 7c
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "
        charbit "  O  "

; character 7d
        charbit "     "
        charbit "  O  "
        charbit "   O "
        charbit "OOOOO"
        charbit "   O "
        charbit "  O  "
        charbit "     "

; character 7e
        charbit "OOOOO"
        charbit "O   O"
        charbit " O   "
        charbit "  O  "
        charbit " O   "
        charbit "O   O"
        charbit "OOOOO"

; character 7f
        charbit "O    "
        charbit "O    "
        charbit "O    "
        charbit "OOOOO"
        charbit "O    "
        charbit "O    "
        charbit "O    "

