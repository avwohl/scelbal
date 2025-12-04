;https://pastraiser.com/cpu/i8008/i8008_opcodes.html
;https://www.youtube.com/watch?v=sOpMrVnjYeY
;intel 8008 mnemonics for 1972 --> 8080 opcode assembler
;assembled in code order

	org	0000H
a16	equ	1000H
d8	equ	55H

;opcodes 00-0F
	NOP 
	INB 
	DCB 
	LBI d8
	RLC 
	INC 
	DCC 
	LCI d8 
	RRC
;opcodes 10-1F 
	IND 
	DCD 
	LDI d8
	RAL 
	INE 
	DCE 
	LEI d8 
	RAR 
;opcodes 20-2F
	INH 
	DCH 
	LHI d8
	INL 
	DCL 
	LLI d8 
;opcodes 30-3F
   	LXI SP,a16		;8080 mnemonic, to init SP
   	LXI B,a16		;not supported
   	LXI D,a16		;not supported
   	LXI H,a16		;not supported
   	LXI PSW,a16	;not supported
	INA		;not allowed
	DCA		;not allowed
	INM		;not supported
	DCM		;not supported
	LMI d8
	LAI d8 
;opcodes 40-4F
	LBB 
	LBC 
	LBD 
	LBE 
	LBH 
	LBL 
	LBM
	LBA 
	LCB 
	LCC 
	LCD 
	LCE 
	LCH 
	LCL 
	LCM 
	LCA
;opcodes 50-5F
	LDB 
	LDC 
	LDD 
	LDE 
	LDH 
	LDL 
	LDM
	LDA 
	LEB 
	LEC 
	LED 
	LEE 
	LEH 
	LEL 
	LEM 
	LEA
;opcodes 60-6F
	LHB 
	LHC 
	LHD 
	LHE 
	LHH 
	LHL 
	LHM
	LHA 
	LLB 
	LLC 
	LLD 
	LLE 
	LLH 
	LLL 
	LLM 
	LLA
;opcodes 70-7F
	LMB 
	LMC 
	LMD 
	LME 
	LMH 
	LML 
	HLT
	LMA 
	LAB 
	LAC 
	LAD 
	LAE 
	LAH 
	LAL 
	LAM
;opcodes 80-8F
	ADB
	ADC
	ADD
	ADE
	ADH
	ADL
	ADM
	ADA
	ACB
	ACC
	ACD
	ACE
	ACH
	ACL
	ACM
	ACA
;opcodes 90-9F
	SUB
	SUC
	SUD
	SUE
	SUH
	SUL
	SUM
	SUA
	SBB
	SBC
	SBD
	SBE
	SBH
	SBL
	SBM
	SBA
;opcodes A0-AF
	NDB
	NDC
	NDD
	NDE
	NDH
	NDL 
	NDM 
	NDA
	XRB 
	XRC 
	XRD 
	XRE 
	XRH 
	XRL 
	XRM
	XRA
;opcodes B0-BF 
	ORB 
	ORC 
	ORD 
	ORE 
	ORH 
	ORL 
	ORM 
	ORA 
	CPB 
	CPC 
	CPD 
	CPE 
	CPH 
	CPL 
	CPM
	CPA
;opcodes C0-CF
	RFZ 
   	JFZ a16 
   	JMP a16 
   	CFZ a16 
	ADI d8 
	RST 0 
	RZ 
	RET 
   	JZ a16 
   	CZ a16 
   	CAL a16 
	ACI d8 
	RST 1
;opcodes D0-DF
	RFC 
	JFC a16 
	OUT 10
	OUT 11 
	OUT 12 
	OUT 13 
	OUT 14 
	OUT 15 
	OUT 16 
	OUT 17
	OUT 20 
	OUT 21 
	OUT 22  
	OUT 23 
	OUT 24 
	OUT 25 
	OUT 26 
	OUT 27
	OUT 30
	OUT 31
	OUT 32
	OUT 33
	OUT 34
	OUT 35
	OUT 36
	OUT 37
   	CFC a16 
	SUI d8 
	RST 2 
	RC 
   	JC a16 
	INP 0 
	INP 1 
	INP 2 
	INP 3 
	INP 4 
	INP 5 
	INP 6 
	INP 7
   	CC a16 
	SBI d8 
	RST 3
;opcodes E0-EF
	RFP 
   	JFP a16 
   	CFP a16 
	NDI d8 
	RST 4 
	RP 
   	JP a16
   	CP a16
	XRI d8 
	RST 5
;opcodes F0-FF
	RFS 
   	JFS a16 
   	CFS a16 
	ORI d8 
	RST 6 
	RS 
   	JS a16
   	CS a16
	CPI d8 
	RST 7 

	END

