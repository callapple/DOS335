*
* DOS 3.3.5 - Patch/Boot program
*
* (c) 1987, Rick Sutcliffe (Arjay Enterprises)
* (s) 2020, Antoine Vignau
*

	xc
	xc
	mx	%11
	org	$8100
	lst	off

*----------------------------

zparam	=	$48
scratch	=	$50
flag	=	$80
buffer	=	$BB00
dispatch	=	$c50d

KBD	EQU	$C000
KBDSTROBE	EQU	$C010
INIT	EQU	$FB2F
HOME	EQU	$FC58
COUT	EQU	$FDED
SETKBD	EQU	$FE89
SETVID	EQU	$FE93

*----------------------------

L8100	LDA	$C501	; Do we have a Smartport card?
	CMP	#$20
	BNE	L8116
	LDA	$C503
	ORA	$C507
	BNE	L8116
	LDA	$C505
	CMP	#$03
	BEQ	L8117

*----------------------------
* 1- QUIT
*----------------------------

L8116	RTS

*----------------------------

L8117	LDA	$03D2	; Where is DOS located?
	CMP	#$9D
	BNE	L813E
	LDA	$03D5
	CMP	#$9D
	BNE	L813E
	LDA	$AAB3
	BNE	L812F
	LDA	$76
	INC
	BEQ	L8139
L812F	LDA	$0100
	CMP	#$03
	BNE	L8139
	JMP	L81ED

*----------------------------

L8139	LDA	#$8D
	STA	L8509+$20

*----------------------------

L813E	STA	$C0E8	; stop drive
	JSR	SETKBD	; say hello
	JSR	SETVID
	JSR	INIT
L814A	JSR	HOME
	LDA	#>msgHELLO
	LDX	#<msgHELLO
	JSR	printSTR
	LDA	#>msgSELECT
	LDX	#<msgSELECT
	JSR	printSTR
	BIT	KBDSTROBE
L815E	LDA	KBD
	BPL	L815E
	BIT	KBDSTROBE
	CMP	#"1"
	BEQ	L8116
	CMP	#"2"
	BNE	L817F

*----------------------------
* 2- SEE SOME INSTRUCTIONS
*----------------------------

	JSR	HOME
	LDA	#>msgABOUT
	LDX	#<msgABOUT
	JSR	printSTR
L8178	LDA	KBD
	BPL	L8178
	BMI	L814A

*----------------------------

L817F	CMP	#"3"
	BEQ	L818E

	BIT	L8509+$20
	BPL	L815E

	CMP	#"4"
	BEQ	L81ED
	BNE	L815E

*----------------------------
* 3- BOOT DOS 3.3 (AND PATCH)
*----------------------------

L818E	CLC		; move Disk II controller ROM
	XCE
	REP	#$30
	LDY	#$8000
	LDX	#$C600
	LDA	#$00FF
	MVN	$000000,$000000
	MX	%11
	SEC
	XCE
	LDX	#$FF	; search for the final JMP
L81A2	LDA	$8000,X
	CMP	#$4C
	BEQ	L81AC
	DEX
	BNE	L81A2
L81AC	LDA	#$60	; make it a JSR
	STA	$8000,X
	JSR	$8000	; call it
	LDA	#$60
	STA	$084A	; put a RTS
	JSR	$0801	; read DOS 3.3
	LDA	#$6C	; put a JMP ($)
	STA	$084A

	LDA	#$3B	; make our patch
	STA	scratch
	LDA	$08FE
	STA	scratch+1
	LDY	#$00
	LDA	(scratch),Y
	PHA
	LDA	#$60
	STA	(scratch),Y
	JSR	$084A
	LDY	#$00
	PLA
	STA	(scratch),Y
	BIT	$51
	BMI	L81E7
	LDA	#$60
	STA	$1C25
	JSR	$1B03
L81E7	JSR	L81ED
	JMP	$B73B	; and jump

*----------------------------
* 4- MODIFY DOS IN MEMORY
*----------------------------

L81ED	CLC		; move our code in the DOS area
	XCE
	REP	#$30
	LDY	#$BEAF	; read/write patch
	LDX	#L82D9
	LDA	#$0107
	MVN	$000000,$000000

	LDY	#$B601	; T0/S0 patch
	LDX	#L829F
	LDA	#$0039
	MVN	$000000,$000000
	STA	$B3A0

	MX	%11
	SEC
	XCE
	LDA	$C5FF	; get the smartport entry
	INC
	INC
	INC
	STA	LBF0B+1	; ...point
	STA	LBF46+1
	STA	LBF53+1
	STA	LBF84+1
	LDA	#$20	; JSR
	STA	$BD06
	LDA	#<LBEB1	; $BEB1
	STA	$BD07
	LDA	#>LBEB1
	STA	$BD08
	LDA	#$06
	STA	$A95B
	LDA	$AEB3
	ORA	#$0C
	CMP	#$0C
	BNE	L8247
	LDA	#$08
	STA	$AEB3
	LDA	#$C8
	STA	$AEB5
L8247	LDA	$B75E
	CMP	#$02
	BNE	L825A
	LSR
	STA	$B715
	STA	$B75E
	LDA	#$1F
	STA	$B7A3

L825A	LDA	$BCDF
	ORA	$BCFF
	BEQ	L829E

	LDA	$9D00
	STA	$40
	LDA	$9D00+1
	STA	$40+1
	LDY	#$00
	STA	($40),Y
	LDX	$AAB1
	CPX	#$03
	BNE	L8288
	DEX
	STX	$AAB1
	LDY	#$25
	LDA	($40),Y
	STA	$9D00+1
	DEY
	LDA	($40),Y
	STA	$9D00

L8288	LDY	#$23
	LDA	($40),Y
	STA	LBEE2+1
	STA	LBFAE+3
	STA	LBF26+2
	DEY
	LDA	($40),Y
	STA	LBFAE+2
	STA	LBF26+1
L829E	RTS

*----------------------------
* PATCHES TO DOS 3.3
*----------------------------

*--- This is T0/S0

L829F	=	*

	ORG	$B601

LB601	LDA	$C5FF	; B601
	INC
	INC
	INC
	STA	$0822
	LDA	$08FE
	INC
	ADC	$08FF
	STA	$0837
	LDA	$08FF
	LSR
	STA	$0838
LB61B	DEC	$0837
	DEC	$0837
	JSR	dispatch
	DB	$01
	DA	$0834
	DEC	$0838
	BPL	LB61B
	INC	$0837
	LDX	#$50
	JMP	($0836)

*---

	DB	$03	; This is $0834
	DB	$01
	DA	$0000
	DA	$0000
	DB	$00

*----------------------------

	ORG

L82D9	=	*

	ORG	$BEAF

LBEAF	DB	$80	; BEAF
	DB	$97

LBEB1	STY	$06F8
	LDA	(zparam),Y
	INC
	LSR
	ROR	$80
	STA	LBFAE+1
	STA	LBFB5+1
	DEY
	LDA	(zparam),Y
	CMP	#$50
	BNE	LBF45
	LDX	#$0F
LBEC9	LDA	scratch,X
	PHA
	DEX
	BPL	LBEC9

	LDY	#$0C	; the RWTS command
	LDA	(zparam),Y
	STA	LBF13+1
	CMP	#$04
	BEQ	LBF50
	LDY	#$05
	LDA	(zparam),Y
	PHA
	AND	#$01
	CLC
LBEE2	ADC	#>buffer
	STA	LBF26+2
	PLA
	LSR
	STA	scratch
	STZ	$51
	DEY
	LDA	#$00
	XBA
	LDA	(zparam),Y
	CLC
	XCE
	REP	#$30
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC	scratch
	BIT	flag-1
	BPL	LBF06
	CLC
	ADC	#$0320
LBF06	STA	LBFAE+4
	MX	%11
	SEC
	XCE
LBF0B	JSR	dispatch
	DB	$01
	DA	LBFAE
	BCS	LBF3A
LBF13	LDA	#$00
	BEQ	LBF38
	LSR
	LDY	#$08
	PHP
	CLC
	XCE
	PLP
	REP	#$30
	LDA	(zparam),Y
	TAY
	LDA	#$00FF
LBF26	LDX	#buffer
	BCS	LBF2F
	PHX
	PHY
	PLX
	PLY
LBF2F	MVN	$000000,$000000

	PHP
	MX	%11
	SEC
	XCE
	PLP
	BCC	LBF46

LBF38	CLC
	HEX	B0
LBF3A	SEC

LBF3B	LDX	#$0F
LBF3D	PLY
	STY	scratch,X
	DEX
	BPL	LBF3D
	PLY
	PLY
LBF45	RTS

LBF46	JSR	dispatch
	DB	$02
	DA	LBFAE
	BCS	LBF3A
	BRA	LBF3B
LBF50	STZ	LBFAE+4

LBF53	JSR	dispatch
	DB	$00
	DA	LBFAE
	BCS	LBF3A
	XCE
	REP	#$30
	LDA	#$2032
	STA	$B3EF
	LDA	$BB01	; 400k
	CMP	#$0320
	BCS	LBF70
	SEC
	XCE
	BRA	LBF3A
	MX	%00
LBF70	CMP	#$0640	; or 800k
LBF73	PHP
	MX	%11
	SEC
	XCE
	PLP
	LDA	LBFAE+1
	ROL
	DEC
	STA	$B5F8
	LDA	#$1F
	STA	$B3BD

LBF84	JSR	dispatch
	DB	$03
	DA	LBFB5
	BCS	LBF3B

	LDA	$B5F8
	LSR
	BCS	LBFA7
	LDA	#$04
	STA	$AEB3
	LDA	#$60
	STA	$AEFF
	JSR	$AE96
	LDA	#$20
	STA	$AEFF
	DEC	$B5F8
LBFA7	LDA	#$08
	STA	$AEB3
	BNE	LBF38

LBFAE	DB	$03	; Read/Write command
	DB	$01
	DA	buffer
	DA	$0000
	DB	$00

LBFB5	DB	$01
	DB	$01

*----------------------------
* The text messages

	ORG
	ORG	$0083E1

msgHELLO
	ASC	"     DOS 3.3.5 Patch/Boot program"8D8D
	ASC	" Copyright 1987   by    Rick Sutcliffe"8D
	ASC	"         (Arjay Enterprises)"8D8D
	ASC	"Box 1253 Aldergrove BC Canada  V0X 1A0"8D
	ASC	8D8D
	ASC	"  Sold with Ampermanager by A.P.P.L.E."8D
	ASC	8D
	ASC	"or separately as Shareware - $10 please"8D
	ASC	8D8D
	ASC	"Do you wish to:"8D8D
	ASC	"  1. Quit and do nothing"8D
	ASC	"  2. See some instructions"8D
L8509	ASC	"  3. Boot a DOS3.3 disk in S6,D1"00
	ASC	"  4. Modify DOS in memory and continue"00

msgSELECT
	ASC	8D8D
	ASC	"Press the key for your selection ===> "00

msgABOUT
	ASC	"     About  DOS 3.3.5       Version 1.2"8D
	ASC	8D
	ASC	"Once DOS 3.3.5 has been installed, "8D
	ASC	" - you can init bootable 3.5 inch disks"8D
	ASC	"      (provided your DOS allows this)"8D
	ASC	" - you cannot init 5 1/4 inch disks"8D
	ASC	" - data I/O is o.k. with both."8D8D
	ASC	"If your GS has at least 400K set aside"8D
	ASC	"as a RAM drive, you can init that too,"8D
	ASC	"and use either 400K or 800K on it."8D8D
	ASC	"In any event, you use slot 5 drive 1 to"8D
	ASC	"access the first 400K on device one,"8D
	ASC	"and slot 5 drive 2 for the second 400K."8D
	ASC	8D
	ASC	"Use ,D3 & ,D4 for device 2 (ramdrive?)"8D
	ASC	"and ,D5 and ,D6 for device 3"8D8D
	ASC	"Access other slots in the normal way."8D
	ASC	"You may BSAVE DOS335PATCH, A$8100,L$713"8D
	ASC	8D
	ASC	"Press any key to return to menu ===> "00

*----------------------------

printSTR	STA	scratch+1
	STX	scratch
	LDY	#$00
L8803	LDA	(scratch),Y
	BEQ	L8812
	JSR	COUT
	INC	scratch
	BNE	L8803
	INC	scratch+1
	BNE	L8803
L8812	RTS
