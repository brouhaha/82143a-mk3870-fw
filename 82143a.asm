; Disassembly of HP 82143A printer microcontroller firmware
; Copyright 2023 Eric Smith
; Copyright is NOT claimed on the original HP 82143A ROM binary
; SPDX-License-Identifier: GPL-3.0-only

; Assembles with Macro Assembler AS (asl):
; http://john.ccac.rwth-aachen.de:8000/as/

	cpu mk3870
	intsyntax +0xhex

; scratchpad registers directly accessible:

r0	    equ   0x00
int_state   equ   0x01	; state for interrupt handler
r2          equ   0x02
buf_ptr     equ   0x03	; buffer current pointer
end_ptr     equ   0x04	; buffer end pointer
r5          equ   0x05
r6          equ   0x06
r7          equ   0x07
r8          equ   0x08
;j          equ   0x09  ; J is predefined - used to save W in interrupt
ra          equ   0x0a  ; HU is predefined, but it's used as a GPR
rb          equ   0x0b	; HL is predefined, but it's used as a GPR

; scratchpad registers not directly accessible
; by normal register instructions:
;ku         equ   0x0e  ; used by interrupt to save suborutine return address
;kl         equ   0x0f
;qu         equ   0x0e	; used by interrupt to save KU
;ql         equ   0x0f  ; used by intrerrupt to save IS

pix_buf	    equ   0x10  ; buffer for a column of pixels

char_buf    equ   0x14
char_end    equ   0x3f



; port 0:
p_hwstat equ 0
;     bit 7 (pin 16): in  LB   low battery
;     bit 6 (pin 17): in  OOPS printer mech out of paper switch
;     bit 5 (pin 18): in  PA   paper advance switch
;     bit 4 (pin 19): in  PRT  print switch
;     bit 3 (pin 6):  in  SMB  print mode switch
;     bit 2 (pin 5):  in  SMA  print mode switch
;     bit 1 (pin 4):  n/c
;     bit 0 (pin 3):  in  CON  calculator control line (41C on?)

; port 1:
p_home equ 1
p_motor equ 1
;     bit 7 (pin 25): in  HOME printer mech home switch
;     bit 6 (pin 24): n/c
;     bit 5 (pin 23): n/c
;     bit 4 (pin 22): n/c
;     bit 3 (pin 34): out RBRK reverse motor brake
;     bit 2 (pin 35): out FBRK forward motor brake
;     bit 1 (pin 36): out REV  reverse motor
;     bit 0 (pin 37): out FWD  forward motor

; port 4: writing causes a low pulse on /STROBE (pin 7), n/c
p_npic equ 4
;     bit 7 (pin 15): DD0
;     bit 6 (pin 14): DD1
;     bit 5 (pin 13): DD2
;     bit 4 (pin 12): n/c
;     bit 3 (pin 11): n/c
;     bit 2 (pin 10): n/c
;     bit 1 (pin 9):  n/c
;     bit 0 (pin 8):  n/c

; port 5: printhead drive
p_printhead equ 5
;     bit 7 (pin 26): n/c
;     bit 6 (pin 27): out R1 
;     bit 5 (pin 28): out R2
;     bit 4 (pin 29): out R3
;     bit 3 (pin 30): out R4
;     bit 2 (pin 31): out R5
;     bit 1 (pin 32): out R6
;     bit 0 (pin 33): out R7

; port 6, interrupt control port:
p_int_ctl equ 6
;     bit 7: divide by 20 prescale
;     bit 6: divide by  5 prescale
;     bit 5: divide by  2 prescale
;     bit 4: pulse width/interval timer
;     bit 3: start/stop timer
;     bit 2: ext int active level
;     bit 1: timer interrupt enable
;     bit 0: external interrupt enable
; values used in 82143A: 0x00, 0x81, 0x8a, 0x8b, 0x0ea

; port 7, binary timer
p_timer   equ 7

; external interrupt comes from the printer mech encoder


; calculator interface:
; PON  use by printer to turn on calculator when paper advance or print key is pressed
; DD0  data, bidirectional
; DD1  clock
; DD2  direction, low for transfer from printer to NPIC, high for NPIC to printer
; DD3  power status of printer to NPIC, low when printer unpowered


; status code infromation:
;    15   sma - mode switch A, 1 for TRACE
;    14   smb - mode switch B, 1 for NORM
;    13   prt - print key
;    12   adv - paper advance key

;    11   oop - out of paper
;    10   lb  - low battery
;     9   idl - idle
;     8   be  - buffer empty

;     7   lca - lower-case alpha
;     6   sco - special colunm output
;     5   dwm - double-wide mode
;     4   teo - type of end-of-line

;     3  eol - last end-of-lline
;     2  hld - hold for paper
;     1      - unused
;     0      - unused


; 44-byte buffer


; control codes:
;   a1..b7  skip 1-23 character positions
;   b9..be  skip 1-6 columns
;   d0..d7  set values of dwm, sco, and lca based on low three bits
;   e0, e8  end of line left justify, or right justify if bit 3 set (e8)
;   fc..fd  self-test
;   fe..ff  set paper advance ignore, fe = advance button active, ff = ignored

eol_lj	equ	0xe0
eol_rj	equ	0xe8


; additional codes the 82143A doesn't use, but the 82162A HP-IL printer does:
;   80..8f  prepare for 1-16 bar codes
;   a0      skip 0 character positions
;   b8      skip 0 columns
;   bf      skip 7 columns
;   fc..fd  set escape mode



reset:          li   0x10
                lr   is,a
                lis  0x0
                outs p_motor	; turn off motor
                outs p_hwstat	; allows use as inputs
                lr   i,a	; clear scratchpad 0x10 through 0x13, leave IS pointing to 0x14
                lr   i,a
                lr   i,a
                lr   i,a

                lr   r7,a

                li   0x14
                lr   buf_ptr,a	; buffer pointer
                inc
                lr   end_ptr,a	; buffer end+1 pointer

                li   eol_lj	; store an end left justify in buffer at 0x14
                lr   d,a

                li   0x0ea
                outs p_int_ctl	; prescaler 200, interval timer running
				; timer interrupt enabled, external interrupt disabled

                ins  p_home
                sl   1		; XXX why checking bit 6? - possibly factory test
                bm   a001d
                jmp  a02f4

a001d:          jmp  a053f


; Internal interrupt from timer
; When the CPU recognizes an interrupt, it disables interrupts,
; copies PC0 to PC1, and loads PC0 with 0x0020 (here).
int_interrupt:  lr   qu,a	; save A in QU (0x0e)
                lr   j,w	; save W (processor status) in J (r9)
                lr   a,is
                lr   ql,a	; save IS in QL (0x0f)

                lr   k,p	; save subroutine return address in K (r12, r13)

                lr   a,int_state
                ci   0x04
                bz   state_4	; 4
                bc   state_0123	; 0-3
                ci   0x06
                bz   state_6	; 6
                bc   state_5	; 5
                ci   0x07
                bnc  state_7	; 7
                br   halt	; 8 or more


state_4:        lr   a,r8
                sl   1
                bp   a003f
                lis  0x0
                lr   int_state,a


state_7:        ds   int_state
a003f:          lr   a,r8
                oi   0x40
                lr   r8,a
                lis  0x1
                outs p_motor
                lis  0x0
                outs p_timer
                br   a0070


; interrupt state 5
state_5:        ds   r0
                bnz  a0070
                lis  0x0
                outs p_motor
                ins  p_home
                bp   a0073

                lis  0x0	; stop timer
                outs p_int_ctl

                lr   a,r8
                ni   0x10
                lr   a,r8
                bnz  a006d
                lr   a,buf_ptr
                lr   is,a
                lr   a,s
                lr   ra,a
                sr   4
                ci   0x0e
                li   0x13
                lr   is,a
                lr   a,s
                bnz  a006d
                ds   r6
                ni   0x0f7
                as   ra
                ai   0x20
                lr   s,a
a006d:          sl   4
                sr   4
                lr   r8,a
a0070:          jmp  int_return

a0073:          li   0x19
                outs p_timer
                lis  0x2
                outs p_motor
                lis  0x6	; set interrupt state to 6
                lr   int_state,a
                lis  0x0
                lr   ra,a
                br   a0070


state_6:        ins  p_home
                bm   a00c4
                ds   ra
                bnz  a0070


halt:           di
                lis  0x0	; turn off printhead and motor
                outs p_printhead
                outs p_motor

                lis  0x0	; stop timer and disable interrupts
                outs p_int_ctl

a008a:          br   a008a	; wait forever


; subroutine entry
a008c:          ds   buf_ptr
                lr   a,buf_ptr
                ci   0x13
                bnz  a0095
                ai   0x2c
                lr   buf_ptr,a
a0095:          pop		; subroutine return


state_0123:     li   pix_buf	; output one pixel column
                lr   is,a
                lr   a,i
                outs p_printhead

                jmp  a023f


; address 009e - possibly just junk to align with 0x00a0
; for external interrupt vector
                db   0x69, 0x00


; External interrupt from encoder
ext_interrupt:  lr   qu,a	; save A in QU (0x0e)
                lr   j,w	; save W (processor status) in J (r9)
                lr   a,is	; save IS in QL (0x0f)
                lr   ql,a

                li   pix_buf	; output one pixel column
                lr   is,a
                lr   a,s
                outs p_printhead

                lis  0x0
                lr   i,a
                lr   k,p	; save subroutine return address in K (r12, r13)

                lis  0x0	; stop timer and disable interrupts
                outs p_int_ctl

                ds   r0
                bz   a00c4

                li   0x8b	; prescaler 20, interval timer running, timer int and ext int (encoder) enabled
                outs p_int_ctl

                li   0x0e7
                outs p_timer
                lr   a,r8
                ni   0x40
                bz   a00c1
                lr   a,r8
                ni   0x0bf
                lr   r8,a
                lis  0x1
a00c1:          outs p_motor
                br   a0134

a00c4:          lis  0x0
                outs p_printhead
                outs p_motor

                li   0x0ea	; prescaler 200, interval timer mode, timer running,
				; timer interrupt enabled, external interrupt disabled
                outs p_int_ctl

                lis  0x0a
                outs p_timer
                lis  0x5	; set interrupt state to 5
                lr   int_state,a
                li   0x20
                lr   r0,a
                lis  0x0c
                outs p_motor
                br   int_return

a00d5:          lr   a,r8
                bz   a00f8
                ni   0x10
                bz   a00e9
                lr   a,r6
                sl   1
                bm   a012c
                lr   a,r0
                ci   0x60
                bnc  a012c
                lis  0x1
                lr   r0,a
                br   a012c

a00e9:          as   rb
                bnz  a0129
                lr   a,r8
                ni   0x24
                ci   0x20
                lr   a,r8
                bz   a00f8
                bp   a00fb
                ni   0x0df
a00f8:          ds   r2
                br   a00fd

a00fb:          oi   0x20
a00fd:          lr   r8,a
                ni   0x02
                bnz  a010a
a0102:          lr   a,r2
                ci   0x05
                bm   a0119
                as   r2
                bz   a0119
a010a:          lr   a,s
                sl   1
                bz   a0119
                lisl 2
                lr   a,d
                com
                ns   d
                lr   s,a
                lis  0x3	; set interrupt state to 3
                lr   int_state,a
                li   0x48
                br   a011d

a0119:          lis  0x2	; set interrupt state to 2
                lr   int_state,a
                li   0x66
a011d:          lr   ra,a
                ins  p_timer
                as   ra
                bc   a0123
                lis  0x4
a0123:          outs p_timer

                li   0x8a	; prescaler 20, interval timer running, timer int enabled, ext int (encoder) disabled
                outs p_int_ctl

                br   int_return

a0129:          ds   rb
                bz   a0102

a012c:          lis  0x4	; set interrupt state to 4
                lr   int_state,a

int_return:     lr   a,ql	; restore IS from QL (0x0f)
                lr   is,a
                lr   w,j	; restore W (processor status) from J (r9)
                lr   a,qu	; restore A from QU

                ei		; enable interrupts, but not before next nstruction
                pk		; direct subroutine call instruction being used as a return
				; PC1 := PC0; PC0 := K


a0134:          lr   a,r0
                ci   0x0a9
                bc   a00d5
                com
                bz   a0156
                ci   0x55
                bnz  a0143
                jmp  halt

a0143:          ins  p_timer
                ci   0x0aa
                bc   a012c
                li   0x4b
                lr   ra,a
a014b:          ins  p_home
                bm   a0143
                ds   ra
                bnz  a014b
                li   0x0aa
                lr   r0,a
                br   a012c

a0156:          lr   a,buf_ptr
                lr   is,a
                lr   a,s
                sr   4
                sr   1
                ci   0x07
                bnz  a0165
                li   0x0ff
                lr   s,a
                pi   a04fd	; subroutine call
a0165:          lr   a,buf_ptr
                lr   ra,a
                li   0x0a8
                lr   rb,a
a016a:          lr   a,buf_ptr
                lr   is,a
                lr   a,s
                com
                bp   a01e5
                lr   a,0x8
                ni   0x02
                lis  0x1
                bnz  a0178
                ai   0x06
a0178:          lr   r0,a
a0179:          lr   a,r8
                ni   0x04
                lr   a,r0
                bz   a0182
                as   r0
                bc   a01d5
a0182:          com
                inc
                bz   a018a
                as   rb
                bnc  a01d5
                lr   rb,a
a018a:          lr   a,buf_ptr
                com
                inc
                as   end_ptr
                ci   0x01
                bz   a0196
                ci   0x0d5
                bnz  a01a3
a0196:          lr   a,ra
                xs   end_ptr
                lr   a,ra
                bz   a019e
                lr   end_ptr,a
                br   a01fc

a019e:          ai   0x40
                lr   ra,a
                br   a01fc

a01a3:          pi   a04fd	; subroutine call
                br   a016a

a01a8:          lr   a,r8
                lr   r2,a
                ni   0x08
                as   s
                sl   4
                sr   4
                lr   r8,a
                lr   a,r2
                ni   0x07
                ai   0x0d0
                lr   s,a
                li   0x13	; move point to begining of buffer?
                lr   is,a
                lr   a,s
                sr   4
                sl   4
                as   r8
                lr   s,a
                br   a018a

a01c0:          ci   0x6f
                lr   a,s
                bnc  a01d0
                ni   0x1f
                lr   r0,a
                sl   1
                sl   1
                sl   1
                com
                as   r0
                com
                br   a01d2

a01d0:          ni   0x07
a01d2:          lr   r0,a
                br   a0179

a01d5:          lr   a,r8
                ni   0x0f7
                lr   r8,a
                lr   a,s
                ni   0x0e0
                ci   0x0a0
                bnz  a01f9
                li   0x0ff
                lr   s,a
                br   a01f5

a01e5:          lr   a,s
                sl   1
                bp   a01c0
                sl   1
                bp   a01a8
                lr   a,r8
                ni   0x0f7
                lr   r8,a
                lr   a,s
                ni   0x08
                as   r8
                lr   r8,a
a01f5:          lr   a,buf_ptr
                xs   ra
                bz   a0210
a01f9:          pi   a008c	; subroutine call
a01fc:          lr   a,buf_ptr
                lr   r2,a
                lr   a,ra
                ni   0x3f
                lr   buf_ptr,a
a0202:          lr   a,r2
                lr   is,a
                xs   buf_ptr
                bnz  a0222
a0207:          lr   a,rb
                ci   0x0a8
                bz   a0210
                lr   a,r8
                sl   4
                bp   a0212
a0210:          lis  0x0
                lr   rb,a
a0212:          lr   a,ra
                lr   3,a
                lis  0x4	; set interrupt state to 4
                lr   int_state,a
                lis  0x1
                lr   r2,a
                lr   a,r8
                oi   0x0e0
                lr   r8,a
                lis  0x0
                com
                lr   r0,a
                jmp  a012c

a0222:          lr   a,s
                lr   int_state,a
                lr   a,buf_ptr
                lr   is,a
                lr   a,s
                lr   r0,a
                lr   a,int_state
                lr   s,a
                lr   a,r2
                lr   is,a
                lr   a,r0
                lr   s,a
                pi   a04fd	; subroutine call
                xs   r2
                bz   a0207
                ds   r2
                lr   a,r2
                ci   0x13
                bm   a0202
                li   0x3f
                lr   r2,a
                br   a0202

a023f:          lr   a,int_state
                com
                ci   0x0fd
                bnc  a0257
                li   0x14
                outs p_timer
                bz   a0250
                lr   a,d
                lr   s,a
a024c:          ds   int_state	; decrement interrupt state
                jmp  int_return

a0250:          lr   a,i
                lr   d,a
                lisl 0
                lis  0x0
                lr   s,a
                br   a024c

a0257:          li   0x70
                outs p_timer
                lis  0x0
                as   rb
                bnz  a029a
                lr   a,r8
                sl   1
                sl   1
                bp   a029f
a0263:          lr   a,buf_ptr
                lr   is,a
                lr   a,s
                lr   ra,a
                li   0x11
                lr   is,a
                lis  0x0
                lr   s,a
                lr   a,r2
                ci   0x01
                bz   a029f
                bp   a02ac
                ci   0x06
                bnz  a029d

                dci  cg_nul	; get base of char gen into data counter
                lr   a,ra
                com
                bp   a029a
                lr   a,r8
                ni   0x01
                lr   a,ra
                bz   a028e
                ci   'A'-1
                bp   a028e
                ci   'Z'
                bm   a028e
                ai   0x20	; convert upper case character to lower case
a028e:          adc		; add to the data counter five times to find cg_base + 5*char
                adc
                adc
                adc
                adc
                lm
                lr   s,a
a0295:          pi   a04e9	; subroutine call
                br   a029f

a029a:          dci  cg_spc
a029d:          lm
                lr   s,a
a029f:          li   0x11
                lr   is,a
                lr   a,d
                lr   s,a
                lis  0x4	; set interrupt state to 4
                lr   int_state,a

                li   0x8b	; prescaler 20, interval timer running, timer int and ext int (encoder) enabled
                outs p_int_ctl

                jmp  int_return

a02ac:          lr   a,ra
                com
                bp   a02c3
                lr   a,r8
                ni   0x02
                bnz  a02b9
a02b5:          lis  0x7
                lr   r2,a
                br   a029f

a02b9:          lis  0x1
                lr   r2,a
                lr   a,r0
                sr   1
                bz   a029f
                lr   a,ra
                lr   s,a
                br   a0295

a02c3:          lr   a,ra
                sl   1
                bp   a02e2
                sl   1
                bm   a02d7
                lr   a,r8
                ni   0x0f0
                as   ra
                ai   0x30
                lr   r8,a
a02d1:          pi   a04e9	; subroutine call
                jmp  a0263

a02d7:          lr   a,r0
                ci   0x60
                bnc  a02de
                lis  0x1
                lr   r0,a
a02de:          lis  0x1
                lr   r2,a
                br   a029f

a02e2:          ni   0x3f
                bz   a02d1
                ci   0x30
                bz   a02d1
                lr   a,buf_ptr
                lr   is,a
                ds   s
                lr   a,s
                ci   0x0b7
                bnc  a02de
                br   a02b5

a02f4:          lis  0x1
                outs p_timer
                lr   r6,a
                lr   r0,a
                lis  0x5	; set interrupt state to 5
                lr   int_state,a
                li   0x80
                lr   r8,a
                ei

                br   a0309

a0300:          ni   0x0bf
                lr   r7,a
                lis  0x0
                lr   r0,a
a0305:          lr   a,r7
                ni   0x0df
                lr   r7,a
a0309:          ins  p_home
                ni   0x20
                bnz  a0368
                jmp  a03a3

a0311:          lr   a,r8
                com
                bp   a0309
                ins  p_hwstat
                sl   1		; check out-of-paper switch
                bm   a0322
                lr   a,r7
                com
                bp   a0322
                lr   a,r6
                ni   0x3f
                bnz  a034c
a0322:          lr   a,end_ptr
                xs   buf_ptr
                bz   a034c
                ins  p_hwstat
                sl   1
                lr   a,r6
                bp   a032d
                oi   0x40
a032d:          oi   0x80
                lr   r6,a
                ins  p_hwstat
                sl   1		; check PA
                sl   1
                lr   a,r7
                bp   a0300
                sl   1		; check PRT
                bm   a0305
                sl   1		; shceck SMB
                bm   a033f
                ds   r0
                bnz  a0309
a033f:          lr   a,r7
                oi   0x20
                lr   r7,a
                lr   a,r8
                oi   0x0b0
                lr   r8,a
                lis  0x2
                lr   r2,a
                com
                br   a0357

a034c:          lis  0x1
                lr   r2,a
                lr   a,r6
                ni   0x0bf
                lr   r6,a
                lr   a,r8
                oi   0x0a0
                lr   r8,a
                lis  0x0
a0357:          lr   r0,a
                lr   a,r6
                sl   1
                sr   1
                lr   r6,a
                lis  0x4	; set interrupt state to 4
                lr   int_state,a

                lis  0x0	; stop timer and disable interrupts
                outs p_int_ctl

                lis  0x2
                outs p_timer

                li   0x8b	; prescaler 20, interval timer running, timer int and ext int (encoder) enabled
                outs p_int_ctl

                ei

                br   a0309

a0368:          ins  p_hwstat
                sl   1		; check out-of-paper
                bp   a0372
                lr   a,7
                oi   0x80
                lr   r7,a
                br   a03dc

a0372:          di
                lr   a,buf_ptr
                ni   0x3f
                xs   end_ptr
                ei

                bz   a03dc
                ins  p_hwstat
                ni   0x02	; XXX why check P01, not connected
                bz   a03dc
                ins  p_npic
                lr   r5,a
                lis  0x0
                outs p_npic
                ins  p_printhead	; XXX why test P47? not connected
                bm   a0389
                lr   a,r5
                com
                lr   r5,a
a0389:          li   0x13	; move point to begining of buffer?
                lr   is,a
                lr   a,s
                ni   0x20
                bnz  a03a0
                lr   a,r5
                ci   0x0d	; carriage return?
                bz   a03dc
                ci   0x0a	; line feed?
                bnz  a03a0
                ins  p_hwstat
                ni   0x08	; SMB switch?
                ai   0x0e0
                lr   r5,a
a03a0:          jmp  a046b

a03a3:          di
                lr   a,buf_ptr
                ni   0x3f
                xs   end_ptr
                ei

                lis  0x0
                bnz  a03ae
                li   0x80
a03ae:          lr   r5,a

                li   0x20	; pulse DD2 (direction) low
                outs p_npic
                lis  0x0
                outs p_npic

a03b4:          bt   0,a03b4	; XXX 3-cycle nop?
                ins  p_npic
                ni   0x80
                sr   1
                as   r5
                lr   r5,a

                li   0x40	; pulse DD1 (clock) low
                outs p_npic
                lis  0x0
                outs p_npic

                bt   0,a03b4	; XXX 3-cycle nop?
                ins  p_npic
                sr   1
                sr   1
                as   r5
                lr   r5,a
                ins  p_hwstat
                sl   1		; test out-of-paper
                bp   a03d0
                lr   a,r7
                com
                bm   a03d7
a03d0:          lr   a,r5
                com
                bp   a03d7
                sl   1
                bp   a044e
a03d7:          lr   a,r5
                sl   1
                sl   1
                bm   a03e6
a03dc:          ins  p_hwstat
                ni   0x30	; test PA and PRT switches
                bz   a03e2	;   neither
                lis  0x1
a03e2:          outs p_hwstat	; XXX why write P01? not connected - factory test?
                jmp  a0311

a03e6:          lr   a,r7
                sr   4
                sl   4
                oi   0x05
                lr   r7,a
                li   0x13	; move point to begining of buffer?
                lr   is,a
                lr   a,s
                sr   4
                lr   r5,a
                lr   a,r7
                ni   0x10
                as   r5
                lr   r5,a
                lr   a,r6
                ni   0x40
                sr   1
                as   r5
                sl   1
                sl   1
a03fe:          lr   r5,a
                li   0x60	; drive DD0 (data) high, DD1 (clock) low, DD2 (ddirection) low
                outs p_npic
                lr   a,r5
                ni   0x80	; drive DD0 (data) based on the MSB of r5, and DD2 high
                com
                ni   0x0a0	; complement DD0 (data) and drive DD2 (clock) low
                outs p_npic
                lr   a,r7
                ni   0x07
                bz   a0413
                ds   r7
                lr   a,r5
                sl   1
                br   a03fe

a0413:          lr   a,r7
                sl   4
                bp   a041b
                lis  0x0
                outs p_npic	; release all DDn lines
                br   a03dc

a041b:          lr   a,r7
                oi   0x0f
                lr   r7,a
                ins  p_hwstat
                sr   1
                sr   1
                lr   r5,a
                sr   1
                sl   4
                bp   a042b
                lr   a,r7
                oi   0x80
                lr   r7,a
a042b:          lr   a,r6
                ni   0x80
                sr   1
                as   r5
                lr   r5,a

                di
                lr   a,buf_ptr
                ni   0x3f
                com
                as   end_ptr
                ei

                bz   a043f
                ci   0x0d4
                lis  0x0
                bnz  a0441
a043f:          li   0x80
a0441:          as   r5
                br   a03fe

a0444:          lr   a,r6
                com
                bm   a03dc
                pi   a052a	; subroutine csll
                jmp  a033f

a044e:          lr   a,r7
                oi   0x07
                lr   r7,a
                lis  0x0
a0453:          lr   r5,a
                li   0x40	; pulse DD1 (clock) low
                outs p_npic
a0457:          lis  0x0
                outs p_npic
                bt   0,a0457	; XXX 3-cycle nop?
                ins  p_npic
                com
                ni   0x80
                as   r5
                lr   r5,a
                lr   a,r7
                ni   0x07
                lr   a,r5
                bz   a046b
                sr   1
                ds   r7
                br   a0453

a046b:          lr   a,r5
                com
                bz   a04dd
                sr   1
                bz   a04e2
                sr   1
                bz   a0444
                lr   a,r5
                com
                bm   a0491
                ci   0x17
                bz   a0491
                ci   0x1f
                bz   a0491
                ci   0x27
                bc   a04ca
                ci   0x2f
                bc   a0491
                ci   0x3f
                bc   a04ca
                ci   0x5f
                bnc  a04ca
a0491:          lr   a,end_ptr
                lr   is,a
                lr   a,r5
                lr   s,a
                lr   a,end_ptr
                ci   char_end
                bnz  a049c
                li   0x13
a049c:          inc
                lr   end_ptr,a
                li   0x13
                lr   is,a
                lr   a,r5
                sr   4
                ci   0x0e
                lr   a,r7
                bnz  a04b7
                oi   0x10
                lr   r7,a
                lr   a,r5
                sl   4
                lr   r5,a

                di
                lr   a,r6
                inc
                lr   r6,a
                lr   a,s
                sl   1
                sr   1
                br   a04c7

a04b7:          ni   0x0ef
                lr   r7,a
                lr   a,r5
                sr   4
                ci   0x0d
                bnz  a04ca
                lr   a,r5
                sl   4
                lr   r5,a

                di
                lr   a,s
                ni   0x08f
a04c7:          as   r5
                lr   s,a
                ei

a04ca:          ins  p_hwstat
                sl   1		; check out-of-paper
                lr   a,r7
                bm   a04d1
                ni   0x7f
a04d1:          lr   r7,a
                lis  0x0
a04d3:          lr   r5,a
                lr   a,r8
                com
                bp   a04da
                lr   a,r5
                lr   r0,a
a04da:          jmp  a03dc

a04dd:          lr   a,r7
                oi   0x40
                br   a04e5

a04e2:          lr   a,r7
                ni   0x0bf
a04e5:          lr   r7,a
                lis  0x1
                br   a04d3


; subroutine entry
a04e9:          lr   a,buf_ptr
                ci   char_end
                bc   a04fd	; branch to the subroutine, which will return to our caller
                lr   is,a
                li   0x0ff
                lr   s,a
                lr   a,end_ptr
                ci   char_end
                bnz  a04f9
                li   0x13
a04f9:          inc
                lr   end_ptr,a
                lr   buf_ptr,a
                pop		; subroutine return


; subroutine entry
a04fd:          lr   a,buf_ptr
                ci   0x3e
                bp   a0504
                li   0x13
a0504:          inc
                lr   buf_ptr,a
                pop		; subroutine return


; subroutine entry
a0507:          lr   a,r5
                outs p_hwstat	; XXX why write hardware stat?
                lr   a,r7
                outs p_npic
                ins  p_home
                xs   r5
                lis  0x1
                bnz  a057b
                ins  p_printhead	; XXX why read printhead
                xs   r7
                lis  0x2
                bnz  a057b
                lis  0x0
                outs p_hwstat	; XXX why write hardware stat?
                outs p_npic
                lr   a,r5
                outs p_motor
                lr   a,r7
                outs p_printhead
                ins  p_hwstat
                xs   r5
                lis  0x4
                bnz  a057b
                ins  p_npic
                xs   r7
                lis  0x8
                bnz  a057b

                lis  0x0	; turn off motor and printhead
                outs p_motor
                outs p_printhead
                pop		; subroutine return


; subroutine entry
a052a:          lis  0x8
                lr   rb,a
                lis  0x0	; set interrupt state to 0
                lr   int_state,a
                lr   r5,a
a052f:          lm
                as   r5
                lnk
                lr   r5,a
                ds   int_state	; decrement interrupt state
                bnz  a052f
                ds   rb
                bnz  a052f
                lr   a,r5
                com
                lis  0x1
                bnz  a057a
                pop		; subroutine return


a053f:          ins  p_home
                ni   0x40	; XXX why read P16? not connected - factory test?
                bnz  a053f
                li   0x5a
                lr   r5,a
                li   0x0aa
                lr   r7,a
                pi   a0507	; sbubrouinte call
                li   0x0a5
                lr   r5,a
                li   0x55
                lr   r7,a
                pi   a0507	; subroutine call
                pi   a052a	; subroutine call
                lis  0x1
                lr   r0,a

                li   0x81	; prescaler 20, interval timer stopped, timer int disabled, ext int enabled (encoder)
                outs p_int_ctl

                lis  0x0
                outs p_npic	; release all DDn lines
                ei

a0561:          lr   a,int_state
                sr   1
                bnz  a056b
                ds   rb
                bnz  a0561
                lis  0x2
                br   a057a

a056b:          lis  0x0
                lr   rb,a
a056d:          lis  0x1
                lr   r0,a
                lr   a,int_state
                ci   0x06
                li   0x0ff
                bz   a057b
                ds   rb
                bnz  a056d
                lis  0x4
a057a:          sl   4
a057b:          lr   r2,a
                outs p_npic	; release all DDn lines
                jmp  halt

		include "chargen.inc"
