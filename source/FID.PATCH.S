*
* DOS 3.3.5 - Patch for FID on 3.5" disk drives
*
* (c) 1987, Rick Sutcliffe (Arjay Enterprises)
* (s) 2020, Antoine Vignau
*

	xc
	xc
	mx	%11
	org	$11e0
	lst	off

*----------------------------

L11E0	STX	$1393
	STX	$1930
	TXA
	ASL
	ASL
	TAY
	STY	$1392
	LDX	#$03
	CLC
L11F0	LDA	$198D,Y
	BEQ	L11F6
	SEC
L11F6	STA	$1931,X
	DEY
	DEX
	BPL	L11F0
	BCC	$11D7
	LDX	$1987
	STX	$192F
	BNE	$11A4
	NOP
