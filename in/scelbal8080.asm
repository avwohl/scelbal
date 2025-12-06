;;; This is the Scelbi Basic Program from 1974 known as
;;; SCELBAL by Mark G. Arnold (MGA) and Nat Wadsworth  
;;;
;;;  Copyright 1975 Scelbi Computer Consulting, Inc.
;;;  All rights reserved
;;;
;;; MGA gives permission to use SCELBAL for 
;;; educational, historical, non-commercial purposes.
;;; Versions of this have been circulating on the web since
;;; about 2000; this version is authorized by MGA (Mar 2012)
;;; with the understanding no warranty is expressed or implied.
;;; As stated in the original, "no responsibility is assumed for
;;; for inaccuracies or for the success or failure of
;;; various applications to which the information herein
;;; may be applied."
;;; 
;;; SCELBAL is the only open-source, floating-point 
;;; high-level language ever implemented on Intel's first
;;; general-purpose microprocessor, the 8008.  It was
;;; published in book form:
;;;
;;;  SCELBAL: A Higher-Level Language for 8008/8080 Systems
;;;
;;; (Tiny BASIC only used 16-bit integers; the MCM\70
;;; was a closed system; calculators implemented with 8008
;;; were floating-point, but not high-level.)
;;;
;;; This version is modified to assemble with the
;;; as8 assembler (using the -octal option) 
;;; for the Intel 8008 by Thomas E. Jones.
;;; This current form is made up non-relocatable so that
;;; locations of all code and data is identical to the
;;; original SCELBAL documents and patches.  It should be
;;; reasonable after debugging code to convert this to a
;;; relocatable and ROMable code with variables in RAM.
;;; This code originates from a version made by 
;;;
;;;    Steve Loboyko in 2001.
;;;
;;; This version has all 3 patches for SCELBAL (the two
;;; pasted in the original manual, and a third which was
;;; written in SCELBAL UPDATE publication, as well as
;;; a couple changes to constants which didn't actually
;;; require a patch, just changes to bytes of data or
;;; arguments to an instruction--one of these (Tucker) was 
;;; incorrect and restored to original by MGA March 2012).
;;; 
;;; This comment must be incorporated with any version of SCELBAL
;;; downloaded, distributed, posted or disemenated.
	

ENDPGRAM:	EQU	02DH                      ;MGA 4/10/12 as in orig; for his ROMable Loboyko said 077       [077]
BGNPGRAM:	EQU	01BH                      ;MGA 4/10/12 as in orig; for his ROMable Loboyko said 044       [044]
	
;;; Here are labels originally attempting to make the code
;;; relocatable.  These 4 pages contain variable data
;;; which needs to be relocated from ROM to RAM.
;;; I can't vouch for ALL references to these pages in
;;; the code being switched to these labels, but they
;;; seem to be.
	
OLDPG1:	EQU	00100H
OLDPG26:	EQU	01600H
OLDPG27:	EQU	01700H
OLDPG57:	EQU	02F00H

;;; =========================================================================
;;; Page 1 (0100H-01FFH) Variable/Constant Offset Definitions
;;; These are LOW BYTE offsets used with H=HIGH OLDPG1
;;; =========================================================================

;;; Floating Point Constants
OFS_FP_CONST_1:	EQU	004H	; FP constant +1.0 (4 bytes)
OFS_EXP_COUNTER:	EQU	00BH	; Exponent counter (1 byte)
OFS_FP_TEMP:	EQU	00CH	; FP temp storage (4 bytes)
OFS_FP_CONST_NEG1:	EQU	014H	; FP constant -1.0 (4 bytes)
OFS_SCRATCH_PAD1:	EQU	018H	; Scratch pad area (16 bytes)
OFS_RND_CONST1:	EQU	028H	; Random number constant 1
OFS_RND_CONST2:	EQU	030H	; Random number constant 2
OFS_SCRATCH_PAD2:	EQU	034H	; Scratch pad area (12 bytes)

;;; Sign and Mode Indicators
OFS_SIGN_IND1:	EQU	040H	; Sign indicator 1 (2 bytes)
OFS_BITS_COUNTER:	EQU	042H	; Bits counter (1 byte)
OFS_SIGN_IND2:	EQU	043H	; Sign indicator 2 (2 bytes)
OFS_INP_DIG_CNT:	EQU	045H	; Input digit counter
OFS_TEMP_STORE:	EQU	046H	; Temporary storage
OFS_OUT_DIG_CNT:	EQU	047H	; Output digit counter
OFS_FP_MODE_IND:	EQU	048H	; FP mode indicator

;;; Floating Point Accumulator (FPACC)
OFS_FPACC_EXT:	EQU	050H	; FPACC extension (4 bytes)
OFS_FPACC:	EQU	054H	; FPACC LSW (start of 4-byte FPACC)
OFS_FPACC_LSW:	EQU	054H	; FPACC Least Significant Word
OFS_FPACC_NSW:	EQU	055H	; FPACC Next Significant Word
OFS_FPACC_MSW:	EQU	056H	; FPACC Most Significant Word
OFS_FPACC_EXP:	EQU	057H	; FPACC Exponent

;;; Floating Point Operand (FPOP)
OFS_FPOP_EXT:	EQU	058H	; FPOP extension (4 bytes)
OFS_FPOP:	EQU	05CH	; FPOP LSW (start of 4-byte FPOP)
OFS_FPOP_LSW:	EQU	05CH	; FPOP Least Significant Word
OFS_FPOP_NSW:	EQU	05DH	; FPOP Next Significant Word
OFS_FPOP_MSW:	EQU	05EH	; FPOP Most Significant Word
OFS_FPOP_EXP:	EQU	05FH	; FPOP Exponent

;;; Additional page 1 offsets (early addresses)
OFS_EXP_TEMP:	EQU	003H	; Exponent temp storage
OFS_FP_TEMP_0F:	EQU	00FH	; FP temp +3
OFS_SCRATCH_1F:	EQU	01FH	; Scratch pad +7

;;; FPACC/FPOP adjacent offsets for E register
OFS_FPACC_LSW_M1:	EQU	053H	; FPACC LSW minus 1
OFS_FPOP_EXT_59:	EQU	059H	; FPOP extension +1 (working area)
OFS_FP_WORK_61:	EQU	061H	; FP work +1 (partial product)

;;; Floating Point Working Area (24 bytes at 060H-077H)
OFS_FP_WORK:	EQU	060H	; FP working area start
OFS_FP_WORK_63:	EQU	063H	; FP working area +3
OFS_FP_WORK_65:	EQU	065H	; FP working area +5
OFS_FP_WORK_66:	EQU	066H	; FP working area +6
OFS_FP_WORK_68:	EQU	068H	; FP working area +8
OFS_FP_WORK_6A:	EQU	06AH	; FP working area +A
OFS_FP_WORK_6B:	EQU	06BH	; FP working area +B
OFS_FP_WORK_6C:	EQU	06CH	; FP working area +C
OFS_FP_WORK_6E:	EQU	06EH	; FP working area +E
OFS_FP_WORK_6F:	EQU	06FH	; FP working area +F
OFS_FP_WORK_70:	EQU	070H	; FP working area +10
OFS_FP_WORK_74:	EQU	074H	; FP working area +14
OFS_FP_WORK_76:	EQU	076H	; FP working area +16 (output MSW)
OFS_FP_WORK_77:	EQU	077H	; FP working area +17

;;; Temporary Register Storage and Constants
OFS_TEMP_REGS:	EQU	080H	; Temp register storage (D,E,H,L)
OFS_FP_CONST_10:	EQU	088H	; FP constant +10.0
OFS_FP_CONST_0P1:	EQU	08CH	; FP constant +0.1

;;; Counters and Stack Pointers
OFS_GETINP_CNT:	EQU	090H	; GETINP counter
OFS_ARITH_STKPTR:	EQU	097H	; Arithmetic stack pointer
OFS_FA_STKPTR:	EQU	098H	; FUN/ARRAY stack pointer
OFS_ARITH_STACK:	EQU	098H	; Arithmetic stack (variable)

;;; FOR/NEXT Storage (in TEMP_AREA2 at 0C4H-0CFH)
OFS_FN_STEP:	EQU	0C4H	; FOR/NEXT step size (4 bytes)
OFS_FN_STEP_C6:	EQU	0C6H	; FOR/NEXT step +2
OFS_FN_LIMIT:	EQU	0C8H	; FOR/NEXT limit value (4 bytes)
OFS_FN_TEMP:	EQU	0CCH	; FOR/NEXT temp (4 bytes)

;;; Keyword lookup table entries (in page 1)
OFS_KW_THEN:	EQU	0D0H	; THEN keyword
OFS_KW_TO:	EQU	0D5H	; TO keyword
OFS_KW_STEP:	EQU	0D8H	; STEP keyword
OFS_KW_LIST:	EQU	0DDH	; LIST keyword
OFS_KW_RUN:	EQU	0E2H	; RUN keyword
OFS_KW_SCR:	EQU	0E6H	; SCR keyword
OFS_MSG_READY:	EQU	0EAH	; READY message

;;; Temporary and Working Storage
OFS_TEMP_F0:	EQU	0F0H	; Temp storage at F0H
OFS_TEMP_F3:	EQU	0F3H	; Temp storage at F3H
OFS_TEMP_F4:	EQU	0F4H	; Temp storage at F4H
OFS_TEMP_F6:	EQU	0F6H	; Temp storage at F6H
OFS_TEMP_F7:	EQU	0F7H	; Temp storage at F7H
OFS_LOOKUP_CNT:	EQU	0F8H	; Look-up counter
OFS_TEMP_OP:	EQU	0F9H	; Temp OP storage

;;; =========================================================================
;;; Page 26 (1600H-16FFH) Line Buffer and Pointer Offset Definitions
;;; These are LOW BYTE offsets used with H=HIGH OLDPG26
;;; =========================================================================

OFS_LINE_INP_BUF:	EQU	000H	; Line input buffer start (CC + 79 chars)
OFS_PARSER_TOKEN:	EQU	07EH	; Parser token storage
OFS_EVAL_CURRENT:	EQU	080H	; EVAL current pointer
OFS_SYNTAX_PTR:	EQU	081H	; Syntax counter/pointer
OFS_SCAN_PTR:	EQU	082H	; SCAN pointer
OFS_TOKEN_STORE:	EQU	083H	; TOKEN storage location
OFS_TEMP_ARRAY:	EQU	084H	; Temp array pointer
OFS_TEMP_085:	EQU	085H	; Temp storage at 85H
OFS_ARRAY_SETUP:	EQU	086H	; Array setup pointer
OFS_LOOP_COUNTER:	EQU	087H	; Loop counter
OFS_OP_STKPTR:	EQU	088H	; Operator stack pointer
OFS_TAB_FLAG:	EQU	07FH	; TAB flag
OFS_FUNC_TBL_BASE:	EQU	0BCH	; Function lookup table base (less 4)
OFS_EVAL_PTR:	EQU	0BEH	; EVAL pointer
OFS_EVAL_FINISH:	EQU	0BFH	; EVAL finish pointer
OFS_LINENUM_BUF:	EQU	0E0H	; Line number buffer
OFS_AUX_LINENUM:	EQU	0E8H	; Auxiliary line number buffer
OFS_COL_COUNTER:	EQU	023H	; Column counter
OFS_COL_024:	EQU	024H	; Column area +1

;;; Page 26 Symbol Buffer (at offset 050H, same as Page 27 start)
OFS_SYMBOL_BUF:	EQU	050H	; Symbol buffer start
OFS_SYMBOL_CHAR1:	EQU	051H	; Symbol buffer 1st character
OFS_SYMBOL_CHAR2:	EQU	052H	; Symbol buffer 2nd character

;;; =========================================================================
;;; Page 27 (1700H-17FFH) Keyword Table and Variables Offset Definitions
;;; These are LOW BYTE offsets used with H=HIGH OLDPG27
;;; =========================================================================

OFS_KEYWORD_TBL:	EQU	000H	; Keyword table start
OFS_GOSUB_STK_BASE:	EQU	03BH	; GOSUB stack base (page 26)
OFS_ARRAY_TEMP:	EQU	03EH	; Array temp / GOSUB stack offset
OFS_SYMVAR_CNT:	EQU	03FH	; Symbol variables counter
OFS_ARRAY_VAR:	EQU	04CH	; Array variables table
OFS_SYMBOL_BUF_64:	EQU	064H	; Symbol buffer in page 27 (alternate)
OFS_FA_STACK_TEMP:	EQU	083H	; F/A stack temp storage
OFS_VARIABLES_TBL:	EQU	088H	; Variables lookup table start

;;; =========================================================================
;;; User Program Buffer Offset (used with BGNPGRAM page)
;;; =========================================================================

OFS_USER_PROG:	EQU	000H	; User program buffer start


;;; Page zero will contain the I/O Routines.  These are actually
;;; just as suggested by Scelbal Manual for Serial I/O.

	ORG	00040H                             ; save a bit of space before this
	
save:	
load:	JMP	EXEC                          ; By default, save and load isn't implemented.

INPORT:	EQU	005H
OUTPORT:	EQU	00EH

;;; HERE IS THE USER DEFINED CHARACTER INPUT TO READ FROM SERIAL PORT
	
CINP:	IN	INPORT
	ANA	A
	JM	CINP
	XRA	A
	MVI	B,044H

MORE1:	DCR	B
	JNZ	MORE1
	OUT	OUTPORT
	CALL	TIMER
	CALL	NEXBIT
	CALL	NEXBIT
	CALL	NEXBIT
	CALL	NEXBIT
	CALL	NEXBIT
	CALL	NEXBIT
	CALL	NEXBIT
	CALL	NEXBIT

STOP:	MVI	A,001H
	OUT	OUTPORT
	MOV	A,B
	RLC
	MVI	B,0CCH

MORE3:	DCR	B
	JNZ	MORE3
	RET

NEXBIT:	IN	INPORT
	ANI	080H
	RLC
	OUT	OUTPORT
	RRC
	ADD	B
	RRC
TIMER:	MVI	B,08BH
MORE2:	DCR	B
	JNZ	MORE2
	MOV	B,A
	RET
;;; no user defined functions yet, stop here if we see one.
UDEFX:	HLT

;;; HERE IS THE USER DEFINED PRINT ROUTINE FOR A SERIAL PORT
	
CPRINT:	ANA	A
	RAL
	OUT	OUTPORT
	RAR
	CALL	TIMER
	CALL	BITOUT
	CALL	BITOUT
	CALL	BITOUT
	CALL	BITOUT
	CALL	BITOUT
	CALL	BITOUT
	CALL	BITOUT
	CALL	BITOUT
	MOV	B,A
	MVI	A,001H
	OUT	OUTPORT
	MOV	A,B
	CALL	TIMER
	MVI	B,043H
	JMP	MORE3

BITOUT:	OUT	OUTPORT
	RRC
	CALL	TIMER
	RET
;;; THE ABOVE MUST CONCLUDE BEFORE BY PAGE 1 STARTS
	
	
;;; Page one has many constants and variables.
;;; See docs/variable_map.txt for detailed address mapping

	ORG	00100H
	DS	4                                   ; (reserved padding)
FP_CONST_1:                                     ; Floating point constant +1.0
	DB	000H,000H,040H,001H
	DS	3                                   ; (reserved padding)
EXP_COUNTER:                                    ; Exponent counter
	DB	000H
FP_TEMP:                                        ; Floating point number temp storage
	DB	000H,000H,000H,000H
	DS	4                                   ; (reserved padding)
FP_CONST_NEG1:                                  ; Floating point constant -1.0
	DB	000H,000H,0C0H,001H
SCRATCH_PAD1:                                   ; Scratch pad area (16 bytes)
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
RND_CONST1:                                     ; Random number generator constant
	DB	001H,050H,072H,002H
	DS	4                                   ; (reserved padding)
RND_CONST2:                                     ; Random number generator constant
	DB	003H,068H,06FH,00CH
SCRATCH_PAD2:                                   ; Scratch pad area (12 bytes)
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
SIGN_IND1:                                      ; Sign indicator
	DB	000H,000H
BITS_COUNTER:                                   ; Bits counter
	DB	000H
SIGN_IND2:                                      ; Sign indicator
	DB	000H,000H
INP_DIG_CNT:                                    ; Input digit counter
	DB	000H
TEMP_STORE:                                     ; Temporary storage
	DB	000H
OUT_DIG_CNT:                                    ; Output digit counter
	DB	000H
FP_MODE_IND:                                    ; FP mode indicator
	DB	000H
	DS	7                                   ; (not assigned - 0149H-014FH)
FPACC_EXT:                                      ; FPACC extension
	DB	000H,000H,000H,000H
FPACC:                                          ; FPACC (LSW, NSW, MSW, Exponent)
	DB	000H,000H,000H,000H
FPOP_EXT:                                       ; FPOP extension
	DB	000H,000H,000H,000H
FPOP:                                           ; FPOP (LSW, NSW, MSW, Exponent)
	DB	000H,000H,000H,000H
FP_WORK_AREA:                                   ; Floating point working area (24 bytes)
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DS	8                                   ; (not assigned - 0178H-017FH)
TEMP_REGS:                                      ; Temporary register storage (D,E,H,L)
	DB	000H,000H,000H,000H
	DS	4                                   ; (not assigned - 0184H-0187H)
FP_CONST_10:                                    ; Floating point constant +10.0
	DB	000H,000H,050H,004H
FP_CONST_0P1:                                   ; Floating point constant +0.1
	DB	067H,066H,066H,0FDH
GETINP_CNT:                                     ; GETINP counter
	DB	000H
	DS	6                                   ; (not assigned - 0191H-0196H)
ARITH_STKPTR:                                   ; Arithmetic stack pointer
	DB	000H
ARITH_STACK:                                    ; Arithmetic stack (variable length)
	DB	000H

	ORG	001BAH
KW_SAVE:                                        ; "SAVE" keyword (length + chars)
	DB	004H
	DB	"SAVE"
KW_LOAD:                                        ; "LOAD" keyword (length + chars)
	DB	004H
	DB	"LOAD"
TEMP_AREA2:                                     ; Temp area (STEP, FOR/NEXT, ARRAY PTR)
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H

;;; Keyword table at location 01D0H (01#320 octal)
KW_THEN:
	DB	004H
	DB	"THEN"
KW_TO:
	DB	002H
	DB	"TO"
KW_STEP:
	DB	004H
	DB	"STEP"
KW_LIST:
	DB	004H
	DB	"LIST"
KW_RUN:
	DB	003H
	DB	"RUN"
KW_SCR:
	DB	003H
	DB	"SCR"

;;; Messages
MSG_READY:                                      ; "READY" message with control chars
	DB	00BH                                ; Length = 11
	DB	094H,08DH,08AH                      ; CTRL-T, CR, LF
	DB	"READY"
	DB	08DH,08AH,08AH                      ; CR, LF, LF
MSG_AT_LINE:                                    ; " AT LINE " message
	DB	009H                                ; Length = 9
	DB	" AT LINE "
;;; END OF PAGE 01

	
	ORG	00200H                             ; START PAGE 02, THE CODE
	

SYNTAX:	CALL	CLESYM                     ;Clear the SYMBOL BUFFER area
           MVI	L,OFS_LINENUM_BUF                   ;Set L to start of LINE NUMBER BUFFER
           MVI	H,HIGH OLDPG26           ;** Set H to page of LINE NUMBER BUFFER
           MVI	M,000H                   ;Initialize line number buff by placing zero as (cc)
           MVI	L,OFS_SYNTAX_PTR                   ;Change pointer to syntax counter/pointer storage loc.
           MVI	M,001H                   ;Set pointer to first character (after cc) in line buffer
SYNTX1:	MVI	L,OFS_SYNTAX_PTR                      ;Set pointer to syntax cntr/pntr storage location
           CALL	GETCHR                  ;Fetch the character pointed to by contents of syntax
           JZ	SYNTX2                    ;Cntr/pntr from the line input buffer. If character was
           CPI	0B0H                     ;A space, ignore. Else, test to see if character was ASCII
           JM	SYNTX3                    ;Code for a decimal digit. If not a decimal digit, consider
           CPI	0BAH                     ;Line number to have been processed by jumping
           JP	SYNTX3                    ;Over the remainder of this SYNTX1 section.
           MVI	L,OFS_LINENUM_BUF                   ;If have decimal digit, set pointer to start of LINE
           CALL	CONCT1                  ;NUMBER BUFFER and append incoming digit there.
SYNTX2:	MVI	L,OFS_SYNTAX_PTR                      ;Reset L to syntax cntr/pntr storage location. Call sub-
           CALL	LOOP                    ;Routine to advance pntr and test for end of inr)ut buffer
           JNZ	SYNTX1                   ;If not end of input buffer, go back for next digit
           MVI	L,OFS_TOKEN_STORE                   ;If end of buffer, only had a line number in the line.
           MVI	M,000H                   ;Set pntr to TOKEN storage location. Set TOKEN = 000.
           RET                          ;Return to caller.
SYNTX3:	MVI	L,OFS_SYNTAX_PTR                      ;Reset pointer to syntax cntr/pntr and fetch
           MOV	B,M                      ;Position of next character after the line number
           MVI	L,OFS_SCAN_PTR                   ;Change pntr to SCAN pntr storage location
           MOV	M,B                      ;Store address when SCAN takes up after line number
SYNTX4:	MVI	L,OFS_SCAN_PTR                      ;Set pntr to SCAN pntr stomge location
           CALL	GETCHR                  ;Fetch the character pointed to by contents of the SCAN
           JZ	SYNTX6                    ;Pointer storage location. If character was ASCII code
           CPI	0BDH                     ;For space, ignore. Else, compare character with "=" sign
           JZ	SYNTX7                    ;If is an equal sign, go set TOKEN for IMPLIED LET.
           CPI	0A8H                     ;Else, compare character with left parenthesis " ( "
           JZ	SYNTX8                    ;If left parenthesis, go set TOKEN for implied array LET
           CALL	CONCTS                  ;Otherwise, concatenate the character onto the string
; MGA 4/2012 begin "fast SYNTX5" patch: 
; the following patch doubles the overall speed of execution.  
; It is similar to the approach taken on 8080 SCELBAL II in 1978 
; it adhears to the rules for patches in issue 1 of SCELBAL update 
;SYNTX6:   these four lines moved up w/o label
           MVI	L,OFS_SCAN_PTR                   ;Set L to SCAN pointer storage location
;           LHI \HB\OLDPG26        ;** Set H to page of SCAN pointer stomge location
;MGA 4/2012 except LHI needed at original place, not here 
           CALL	LOOP                    ;Call routine to advance pntr & test for end of In buffer
           JNZ	SYNTX4                   ;Go back and add another character to SYMBOL BUFF
SYNTX6:   ; MGA 4/2012 label here 

           MVI	L,OFS_TOKEN_STORE                   ;Being constructed in the SYMBOL BUFFER. Now set
           MVI	M,001H                   ;Up TOKEN storage location to an initial value of 001.
           MVI	H,HIGH OLDPG27           ;** Set H to point to start of KEYWORD TABLE.
           MVI	L,OFS_KEYWORD_TBL        ;Set L to point to start of KEYWORD TABLE.
SYNTX5:	MVI	D,HIGH OLDPG26              ;** Set D to page of SYMBOL BUFFER
           MVI	E,OFS_SYMBOL_BUF                   ;Set E to start of SYMBOL BUFFER
           CALL	STRCP                   ;Compare char string presently in SYMBOL BUFFER
           RZ                           ;With entry in KEYWORD TABLE. Exit if match.
           CALL	SWITCH                  ;TOKEN will be set to keyword found. Else, switch
SYNTXL:	INR	L                           ;Pointers to get table address back and advance pntr to
           MOV	A,M                      ;KEYWORD TABLE. Now look for start of next entry
           ANI	0C0H                     ;In KEYWORD TABLE by looking for (cc) byte which
           JNZ	SYNTXL                   ;Will NOT have a one in the two most sig. bits. Advance
           CALL	SWITCH                  ;Pntr til next entry found. Then switch pointers apin so
           MVI	L,OFS_TOKEN_STORE                   ;Table pointer is in D&E. Put addr of TOKEN in L.
           MVI	H,HIGH OLDPG26           ;** And page of TOKEN in H. Fetch the value currently
           MOV	B,M                      ;In TOKEN and advance it to account for going on to
           INR	B                        ;The next entry in the KEYWORD TABLE.
           MOV	M,B                      ;Restore the updated TOKEN value back to storage.
           CALL	SWITCH                  ;Restore the keyword table pointer back to H&L.
           MOV	A,B                      ;Put TOKEN count in ACC.
           CPI	00DH                     ;See if have tested all entries in the keyword table.
           JNZ	SYNTX5                   ;If not, continue checking the keyword table.
;MGA 4/2012 3 of 4 lines removed below (keep LHI)
           MVI	H,HIGH OLDPG26           ;** Set H to page of SCAN pointer stomge location
; MGA 4/2012 end of "fast SYNTX5" patch: 
           MVI	L,OFS_TOKEN_STORE                   ;And search table for KEYWORD again. Unless reach
           MVI	M,0FFH                   ;End of line input buffer. In which case set TOKEN=377
           RET                          ;As an error indicator and exit to calling routine.
SYNTX7:	MVI	L,OFS_TOKEN_STORE                      ;Set pointer to TOKEN storage register. Set TOKEN
           MVI	M,00DH                   ;Equal to 015 when "=" sign found for IMPLIED LET.
           RET                          ;Exit to calling routine.
SYNTX8:	MVI	L,OFS_TOKEN_STORE                      ;Set pointer to TOKEN storage register. Set TOKEN
           MVI	M,00EH                   ;Equal to 016 when "(" found for IMPLIED array LET.
           RET                          ;Exit to calling routine.

                                  ;The following are subroutines used by SYNTAX and
                                  ;other routines in SCELBAL.

BIGERR:	MVI	A,0C2H                      ;Load ASCII code for letters B and G to indicate BIG
           MVI	C,0C7H                   ;ERROR (for when buffer, stack,etc., overflows).
ERROR:	CALL	ECHO                        ;Call user provided display routine to print ASCII code
           MOV	A,C                      ;In accumulator. Transfer ASCII code from C to ACC
           CALL	ECHO                    ;And repeat to display error codes.
           JMP	FINERR                   ;Go cpmplete error message (AT LINE) as required.
GETCHR:	MOV	A,M                         ;Get pointer from memory location pointed to by H&L
           CPI	050H                     ;See if within range of line input buffer.
           JP	BIGERR                    ;If not then have an overflow condition = error.
           MOV	L,A                      ;Else can use it as addr of character to fetch from the
           MVI	H,HIGH OLDPG26           ;** LINE INPUT BUFFER by setting up H too.
           MOV	A,M                      ;Fetch the character from the line input buffer.
           CPI	0A0H                     ;See if it is ASCII code for space.
           RET                          ;Return to caller with flags set according to comparison.
CLESYM:	MVI	L,OFS_SYMBOL_BUF                      ;Set L to start of SYMBOL BUFFER.
           MVI	H,HIGH OLDPG26           ;** Set H to page of SYMBOL BUFFER.
           MVI	M,000H                   ;Place a zero byte at start of SYMBOL BUFFER.
           RET                          ;To effectively clear the buffer. Then exit to caller.


                                  ;Subroutine to concatenate (append) a character to the
                                  ;SYMBOL BUFFER. Character must be alphanumeric.

CONCTA:	CPI	0C1H                        ;See if character code less than that for letter A.
           JM	CONCTN                    ;If so, go see if it is numeric.
           CPI	0DBH                     ;See if character code greater than that for letter Z.
           JM	CONCTS                    ;If not, have valid alphabetical character.
CONCTN:	CPI	0B0H                        ;Else, see if character in valid numeric range.
           JM	CONCTE                    ;If not, have an error condition.
           CPI	0BAH                     ;Continue to check for valid number.
           JP	CONCTE                    ;If not, have an error condition.
CONCTS:	MVI	L,OFS_SYMBOL_BUF                      ;If character alphanumeric, can concatenate. Set pointer
           MVI	H,HIGH OLDPG26           ;** To starting address of SYMBOL BUFFER.
CONCT1:	MOV	C,M                         ;Fetch old character count in SYMBOL BUFFER.
           INR	C                        ;Increment the value to account for adding new
           MOV	M,C                      ;Character to the buffer. Restore updated (cc).
           MOV	B,A                      ;Save character to be appended in register B.
           CALL	INDEXC                  ;Add (cc) to address in H & L to get new end of buffer
           MOV	M,B                      ;Address and append the new character to buffer
           MVI	A,000H                   ;Clear the accumulator
           RET                          ;Exit to caller
CONCTE:	JMP	SYNERR                      ;If character to be appended not alphanumeric, ERROR!

                                  ;Subroutine to compare
                                  ;character strings pointed to by
                                  ;register pairs D & E and H & L.

STRCP:	MOV	A,M                          ;Fetch (cc) of first string.
           CALL	SWITCH                  ;Switch pointers and fetch length of second string (cc)
           MOV	B,M                      ;Into register B. Compare the lengths of the two strings.
           CMP	B                        ;If they are not the same
           RNZ                          ;Return to caller with flags set to non-zero condition
           CALL	SWITCH                  ;Else, exchange the pointers back to first string.
STRCPL:	CALL	ADV                        ;Advance the pointer to string number 1 and fetch a
           MOV	A,M                      ;Character from that string into the accumulator.
           CALL	SWITCH                  ;Now switch the pointers to string number 2.
           CALL	ADV                     ;Advance the pointer in line number 2.
STRCPE:	CMP	M                           ;Compare char in stxing 1 (ACC) to string 2 (memory)
           RNZ                          ;If not equal, return to cauer with flags set to non-zero
           CALL	SWITCH                  ;Else, exchange pointers to restore pntr to string 1
           DCR	B                        ;Decrement the string length counter in register B
           JNZ	STRCPL                   ;If not finiahed, continue testing entire string
           RET                          ;If complete match, return with flag in zero condition
STRCPC:	MOV	A,M                         ;Fetch character pointed to by pointer to string 1
           CALL	SWITCH                  ;Exchange pointer to examine string 2
           JMP	STRCPE                   ;Continue the string comparison loop

                                  ;Subroutine to advance the two byte
                                  ;value in CPU registers H and L.

ADV:	INR	L                              ;Advance value in register L.
           RNZ                          ;If new value not zero, return to caller.
           INR	H                        ;Else must increment value in H
           RET                          ;Before retuming to caller

                                  ;Subroutine to advance a buffer pointer
                                  ;and test to see if the end of the buffer
                                  ;has been reached.

LOOP:	MOV	B,M                           ;Fetch memory location pointed to by H & L into B.
           INR	B                        ;Increment the value.
           MOV	M,B                      ;Restore it back to memory.
           MVI	L,OFS_LINE_INP_BUF       ;Change pointer to start of INPUT LINE BUFFER
           MOV	A,M                      ;Fetch buffer length (cc) value into the accumulator
           DCR	B                        ;Make value in B original value
           CMP	B                        ;See if buffer length same as that in B
           RET                          ;Return with flags yielding results of the comparison

                                  ;The following subroutine is used to
                                  ;input characters from the system's
                                  ;input device (such as a keyboard)
                                  ;into the LINE INPUT BUFFER. Routine has limited
                                  ;editing capability included.
                                  ;(Rubout = delete previous character(s) entered.)
;;; This label, STRIN:	should be location 03 014
STRIN:	MVI	C,000H                       ;Initialize register C to zero.
STRIN1:	CALL	CINPUT                     ;Call user provided device input subroutine to fetch one
           CPI	0FFH                     ;Character from the input device. Is it ASCII code for
           JNZ	NOTDEL                   ;Rubout? Skip to next section if not rubout.
           MVI	A,0DCH                   ;Else, load ASCII code for backslash into ACC.
           CALL	ECHO                    ;Call user display driver to present backslash as a delete
           DCR	C                        ;Indicator. Now decrement the input character counter.
           JM	STRIN                     ;If at beginning of line do NOT decrement H and L.
           CALL	DEC                     ;Else, decrement H & L line pointer to erase previous
           JMP	STRIN1                   ;Entry, then go back for a new input.
NOTDEL:	CPI	083H                        ;See if character inputted was'CONTROL C'
           JZ	CTRLC                     ;If so, stop inputting and go back to the EXECutive
           CPI	08DH                     ;If not, see if character was carriage-return
           JZ	STRINF                    ;If so, have end of line of input
           CPI	08AH                     ;If not, see if character was line-feed
           JZ	STRIN1                    ;If so, ignore the input, get another character
           CALL	ADV                     ;If none of the above, advance contents of H & L
           INR	C                        ;Increment the character counter
           MOV	M,A                      ;Store the new character in the line input buffer
           MOV	A,C                      ;Put new character count in the accumulator
           CPI	050H                     ;Make sure maximum buffer size not exceeded
           JP	BIGERR                    ;If buffer size exceeded, go display BG error message
           JMP	STRIN1                   ;Else can go back to look for next input
STRINF:	MOV	B,C                         ;Transfer character count from C to B
           CALL	SUBHL                   ;Subtract B from H & L to get starting address of
           MOV	M,C                      ;The string and place the character count (cc) there
           CALL	CRLF                    ;Provide a line ending CR & LF combination on the
           RET                          ;Display device. Then exit to caller.

                                  ;Subroutine to subtract contents of CPU register B from
                                  ;the two byte value in CPU registers H & L.

SUBHL:	MOV	A,L                          ;Load contents of register L into the accumulator
           SUB	B                        ;Subtract the contents of register B
           MOV	L,A                      ;Restore the new value back to L
           RNC                          ;If no carry, then no underflow. Exit to caller.
           DCR	H                        ;Else must also decrement contents of H.
           RET                          ;Before retuming to caller.

                                  ;Subroutine to display a character string on the system's
                                  ;display device.

TEXTC:	MOV	C,M                          ;Fetch (cc) from the first location in the buffer (H & L
           MOV	A,M                      ;Pointing there upon entry) into register B and ACC.
           ANA	A                        ;Test the character count value.
           RZ                           ;No display if (cc) is zero.
TEXTCL:	CALL	ADV                        ;Advance pointer to next location in buffer
           MOV	A,M                      ;Fetch a character from the buffer into ACC
           CALL	ECHO                    ;Call the user's display driver subroutine
           DCR	C                        ;Decrement the (cc)
           JNZ	TEXTCL                   ;If character counter not zero, continue display
           RET                          ;Exit to caller when (cc) is zero.

                                  ;Subroutine to provide carriage-return and line-feed
                                  ;combination to system's display device. Routine also
                                  ;initializes a column counter to zero. Column counter
                                  ;is used by selected output routines to count the num-
                                  ;ber of characters that have been displayed on a line.

CRLF:	MVI	A,08DH                        ;Load ASCII code for carriage-return into ACC
           CALL	ECHO                    ;Call user provided display driver subroutine
           MVI	A,08AH                   ;Load ASCII code for line-feed into ACC
           CALL	ECHO                    ;Call user provided display driver subroutine
           MVI	L,OFS_COL_COUNTER                   ;Set L to point to COLUMN COUNTER storage location
           MVI	H,HIGH OLDPG1            ;** Set H to page of COLUMN COUNTER
           MVI	M,001H                   ;Initialize COLUMN COUNTER to a value of one
           MOV	H,D                      ;Restore H from D (saved by ECHO subroutine)
           MOV	L,E                      ;Restore L from E (saved by ECHO subroutine)
           RET                          ;Then exit to calling routine

                                  ;Subroutine to decrement double-byte value in CPU
                                  ;registers H and L.

DEC:	DCR	L                              ;Decrement contents of L
           INR	L                        ;Now increment to exercise CPU flags
           JNZ	DECNO                    ;If L not presently zero, skip decrementing H
           DCR	H                        ;Else decrement H
DECNO:	DCR	L                            ;Do the actual decrement of L
           RET                          ;Return to caller


                                  ;Subroutine to index the value in CPU registers H and L
                                  ;by the contents of CPU register B.

INDEXB:	MOV	A,L                         ;Load L into the accumulator
           ADD	B                        ;Add B to that value
           MOV	L,A                      ;Restore the new value to L
           RNC                          ;If no carry,  return to caller
           INR	H                        ;Else, increment value in H
           RET                          ;Before returning to caller

                                  ;The following subroutine is used to
                                  ;display the ASCII encoded character in the ACC on the
                                  ;system's display device. This routine calls a routine
                                  ;labeled CINPUT which must be provided by the user to
                                  ;actually drive the system's output device. The subroutine
                                  ;below also increments an output column counter each time
                                  ;it is used.

ECHO:	MOV	D,H                           ;Save entry value of H in register D
           MOV	E,L                      ;And save entry value of L in register E
           MVI	L,OFS_COL_COUNTER                   ;Set L to point to COLUMN COUNTER storage location
           MVI	H,HIGH OLDPG1            ;** Set H to page of COLUMN COUNTER
           MOV	B,M                      ;Fetch the value in the COLUMN COUNTER
           INR	B                        ;And increment it for each character displayed
           MOV	M,B                      ;Restore the updated count in memory
           CALL	CPRINT                  ;tt Call the user's device driver subroutine
           MOV	H,D                      ;Restore entry value of H from D
           MOV	L,E                      ;Restore entry value of L from E
           RET                          ;Return to calling routine
CINPUT:	JMP	CINP                        ;Reference to user defined input subroutine

;;; The label EVAL: SHOULD BE AT 03 224
EVAL:	MVI	L,OFS_ARITH_STKPTR                        ;Load L with address of ARITHMETIC STACK pointer
           MVI	H,HIGH OLDPG1            ;** Set H to page of ARITHMETIC STACK pointer
           MVI	M,094H                   ;Initialize ARITH STACK pointer value to addr minus 4
           INR	L                        ;Advance memory pointer to FUN/ARRAY STACK pntr
           MVI	H,HIGH OLDPG26           ;** Set H to page of FUN/ARRAY STACK pointer
           MVI	M,000H                   ;Initialize FUNIARRAY STACK pointer to start of stack
           CALL	CLESYM                  ;Initialize the SYMBOL BUFFER to empty condition
           MVI	L,OFS_OP_STKPTR                   ;Load L with address of OPERATOR STACK pointer
           MVI	M,000H                   ;Initialize OPERATOR STACK pointer value
           MVI	L,OFS_EVAL_PTR                   ;Set L to address of EVAL pointer (start of expression)
           MOV	B,M                      ;Fetch the EVAL pointer value into register B
           MVI	L,OFS_EVAL_CURRENT                   ;Set up a working pointer register in this location
           MOV	M,B                      ;And initialize EVAL CURRENT pointer
SCAN1:	MVI	L,OFS_EVAL_CURRENT                       ;Load L with address of EVAL CURRENT pointer
           CALL	GETCHR                  ;Fetch a character in the expression being evaluated
           JZ	SCAN10                    ;If character is a space, jump out of this section
           CPI	0ABH                     ;See if character is a "+" sign
           JNZ	SCAN2                    ;If not, continue checking for an operator
           MVI	L,OFS_PARSER_TOKEN                   ;If yes, set pointer to PARSER TOKEN storage location
           MVI	M,001H                   ;Place TOKEN value for "+" sign in PARSER TOKEN
           JMP	SCANFN                   ;Go to PARSER subroutine entry point
SCAN2:	CPI	0ADH                         ;See if character is a minus ("-") sign
           JNZ	SCAN4                    ;If not, continue checking for an operator
           MVI	L,OFS_SYMBOL_BUF                   ;If yes, check the length of the symbol stored in the
           MOV	A,M                      ;SYMBOL BUFFER by fetching the (cc) byte
           ANA	A                        ;And testing to see if (cc) is zero
           JNZ	SCAN3                    ;If length not zero, then not a unary minus indicator
           MVI	L,OFS_PARSER_TOKEN                   ;Else, check to see if last operator was a right parenthesi
           MOV	A,M                      ;By fetching the value in the PARSER TOKEN storage
           CPI	007H                     ;Location and seeing if it is token value for ")"
           JZ	SCAN3                     ;If last operator was I')" then do not have a unary minus
           CPI	003H                     ;Check to see if last operator was C4*~2
           JZ	SYNERR                    ;If yes, then have a syntax error
           CPI	005H                     ;Check to see if last operator was exponentiation
           JZ	SYNERR                    ;If yes, then have a syntax error
           MVI	L,OFS_SYMBOL_BUF                   ;If none of the above, then minus sign is unary, put
           MVI	M,001H                   ;Character string representing the
           INR	L                        ;Value zero in the SYMBOL BUFFER in string format
           MVI	M,0B0H                   ;(Character count (cc) followed by ASCII code for zero)
SCAN3:	MVI	L,OFS_PARSER_TOKEN                       ;Set L to address of PARSER TOKEN storage location
           MVI	M,002H                   ;Set PARSER TOKEN value for minus operator
SCANFN:	CALL	PARSER                     ;Call the PARSER subroutine to process current symbol
           JMP	SCAN10                   ;And operator. Then jump to continue processing.
SCAN4:	CPI	0AAH                         ;See if character fetched from expression is
           JNZ	SCAN5                    ;If not, continue checking for an operator
           MVI	L,OFS_PARSER_TOKEN                   ;If yes, set pointer to PARSER TOKEN storage location
           MVI	M,003H                   ;Place TOKEN value for "*" (multiplication) operator in
           JMP	SCANFN                   ;PARSER TOKEN and go to PARSER subroutine entry
SCAN5:	CPI	0AFH                         ;See if character fetched from expression is
           JNZ	SCAN6                    ;If not, continue checking for an operator
           MVI	L,OFS_PARSER_TOKEN                   ;If yes, set pointer to PARSER TOKEN storage location
           MVI	M,004H                   ;Place TOKEN value for "/" (division) operator in
           JMP	SCANFN                   ;PARSER TOKEN and go to PARSER subroutine entry
SCAN6:	CPI	0A8H                         ;See if character fetched from expression is
           JNZ	SCAN7                    ;If not, continue checking for an operator
           MVI	L,OFS_FA_STKPTR                   ;If yes, load L with address of FUN/ARRAY STACK
           MOV	B,M                      ;Pointer. Fetch the value in the stack pointer. Increment
           INR	B                        ;It to indicate number of "(" operators encountered.
           MOV	M,B                      ;Restore the updated stack pointer back to memory
           CALL	FUNARR                  ;Call subroutine to process possible FUNCTION or
           MVI	L,OFS_PARSER_TOKEN                   ;ARRAY variable subscript. Ihen set pointer to
           MVI	M,006H                   ;PARSER TOKEN storage and set value for operator
           JMP	SCANFN                   ;Go to PARSER subroutine entry point.
SCAN7:	CPI	0A9H                         ;See if character fetched from expression is
           JNZ	SCAN8                    ;If not, continue checking for an operator
           MVI	L,OFS_PARSER_TOKEN                   ;If yes, load L with address of PARSER TOKEN
           MVI	M,007H                   ;Set PARSER TOKEN value to reflect ")"
           CALL	PARSER                  ;Call the  PARSER subroutine to process current symbol
	
           CALL	PRIGHT                  ;Call subroutine to handle FUNCTION or ARRAY
           MVI	L,OFS_FA_STKPTR                   ;Load L with address of FUN/ARRAY STACK pointer
           MVI	H,HIGH OLDPG26           ;** Set H to page of FUN/ARRAY STACK pointer
           MOV	B,M                      ;Fetch the value in the stack pointer. Decrement it
           DCR	B                        ;To account for left parenthesis just processed.
           MOV	M,B                      ;Restore the updated value back to memory.
           JMP	SCAN10                   ;Jump to continue processing expression.
SCAN8:	CPI	0DEH                         ;See if character fetched from expression is " t
           JNZ	SCAN9                    ;If not, continue checking for an operator
           MVI	L,OFS_PARSER_TOKEN                   ;If yes, load L with address of PARSER TOKEN
           MVI	M,005H                   ;Put in value for exponentiation
           JMP	SCANFN                   ;Go to PARSER subroutine entry point.
SCAN9:	CPI	0BCH                         ;See if character fetched is the "less than" sign
           JNZ	SCAN11                   ;If not, continue checking for an operator
           MVI	L,OFS_EVAL_CURRENT                   ;If yes, set L to the EVAL CURRENT pointer
           MOV	B,M                      ;Fetch the pointer
           INR	B                        ;Increment it to point to the next character
           MOV	M,B                      ;Restore the updated pointer value
           CALL	GETCHR                  ;Fetch the next character in the expression
           CPI	0BDH                     ;Is the character the "= 9 $ sign?
           JZ	SCAN13                    ;If so, have 'less than or equal" combination
           CPI	0BEH                     ;Is the character the "greater than" sign?
           JZ	SCAN15                    ;If so, have "less than or greater than" combination
           MVI	L,OFS_EVAL_CURRENT                   ;Else character is not part of the operator. Set L back
           MOV	B,M                      ;To the EVAL CURRENT pointer. Fetch the pointer
           DCR	B                        ;Value and decriment it back one character in the
           MOV	M,B                      ;Expression. Restore the original pointer value.
           MVI	L,OFS_PARSER_TOKEN                   ;Have just the 'less than" operator. Set L to the
           MVI	M,009H                   ;PARSER TOKEN storage location and set the value for
           JMP	SCANFN                   ;The 'less than" sign then go to PARSER entry point.
SCAN11:	CPI	0BDH                        ;See if character fetched is the "= " sign
           JNZ	SCAN12                   ;If not, continue checking for an operator
           MVI	L,OFS_EVAL_CURRENT                   ;If yes, set L to the EVAL CURRENT pointer
           MOV	B,M                      ;Fetch the pointer
           INR	B                        ;Increment it to point to the next character
           MOV	M,B                      ;Restore the updated pointer value
           CALL	GETCHR                  ;Fetch the next character in the expression
           CPI	0BCH                     ;Is the character the "less than" sign?
           JZ	SCAN13                    ;If so, have "less than or equal" combination
           CPI	0BEH                     ;Is the character the "greater than" sign?
           JZ	SCAN14                    ;If so, have "equal or greater than" combination
           MVI	L,OFS_EVAL_CURRENT                   ;Else character is not part of the operator. Set L back
           MOV	B,M                      ;To the EVAL CURRENT pointer. Fetch the pointer
           DCR	B                        ;Value and decrement it back one character in the
           MOV	M,B                      ;Expression. Restore the original pointer value.
           MVI	L,OFS_PARSER_TOKEN                   ;Just have '~-- " operator. Set L to the PARSER TOKEN
           MVI	M,00AH                   ;Storage location and set the value for the sign.
           JMP	SCANFN                   ;Go to the PARSER entry point.
SCAN12:	CPI	0BEH                        ;See if character fetched is the "greater than" sign
           JNZ	SCAN16                   ;If not, go append the character to the SYMBOL BUFF
           MVI	L,OFS_EVAL_CURRENT                   ;If so, set L to the EVAL CURRENT pointer
           MOV	B,M                      ;Fetch the pointer
           INR	B                        ;Increment it to point to the next character
           MOV	M,B                      ;Restore the updated pointer value
           CALL	GETCHR                  ;Fetch the next character in the expression
           CPI	0BCH                     ;Is the character the "less than" sign?
           JZ	SCAN15                    ;If so, have "less than or greater than" combination
           CPI	0BDH                     ;Is the character the "= " sign?
           JZ	SCAN14                    ;If so, have the "equal to or greater than " combination
           MVI	L,OFS_EVAL_CURRENT                   ;Else character is not part of the operator. Set L back
           MOV	B,M                      ;To the EVAL CURRENT pointer. Fetch the pointer
           DCR	B                        ;Value and decrement it back one character in the
           MOV	M,B                      ;Expression. Restore the original pointer value.
           MVI	L,OFS_PARSER_TOKEN                   ;Have just the "greater than" operator. Set L to the
           MVI	M,00BH                   ;PARSER TOKEN storage location and set the value for
           JMP	SCANFN                   ;The "greater than" sign then go to PARSER entry
SCAN13:	MVI	L,OFS_PARSER_TOKEN                      ;When have 'less than or equal" combination set L to
           MVI	M,00CH                   ;PARSER TOKEN storage location and set the value.
           JMP	SCANFN                   ;Then go to the PARSER entry point.
SCAN14:	MVI	L,OFS_PARSER_TOKEN                      ;When have "equal to or greater than" combination set L
           MVI	M,00DH                   ;To PARSER TOKEN storage location and set the value.
           JMP	SCANFN                   ;Then go to the PARSER entry point.
SCAN15:	MVI	L,OFS_PARSER_TOKEN                      ;When have 'less than or greater than" combination set
           MVI	M,00EH                   ;L to PARSER TOKEN storage location and set value.
           JMP	SCANFN                   ;Then go to the PARSER entry point.
SCAN16:	CALL	CONCTS                     ;Concatenate the character to the SYMBOL BUFFER
SCAN10:	MVI	L,OFS_EVAL_CURRENT                      ;Set L to the EVAL CURRENT pointer storage location
           MVI	H,HIGH OLDPG26           ;** Set H to page of EVAL CURRENT pointer
           MOV	B,M                      ;Fetch the EVAL CURRENT pointer value into B
           INR	B                        ;Increment the pointer value to point to next character
           MOV	M,B                      ;In the expression and restore the updated value.
           MVI	L,OFS_EVAL_FINISH                   ;Set L to EVAL FINISH storage location.
           MOV	A,M                      ;Fetch the EVAL FINISH value into the accumulator.
           DCR	B                        ;Set B to last character processed in the expression.
           CMP	B                        ;See if last character was at EVAL FINISH location.
           JNZ	SCAN1                    ;If not, continue processing the expression. Else, jump
           JMP	PARSEP                   ;To final evaluation procedure and test.  (Directs routine
           HLT                          ;To a dislocated section.) Safety Halt in unused byte.
PARSER:	MVI	L,OFS_SYMBOL_BUF                      ;Load L with starting address of SYMBOL BUFFER
           MVI	H,HIGH OLDPG26           ;** Load H with page of SYMBOL BUFFER
           MOV	A,M                      ;Fetch the (cc) for  contents of SYMBOL BUFFER
           ANA	A                        ;Into the ACC and see if buffer is  empty
           JZ	PARSE                     ;If empty then no need to convert contents
           INR	L                        ;If not empty, advance buffer pointer
           MOV	A,M                      ;Fetch the first character in the buffer
           CPI	0AEH                     ;See if it is ASCII code for decimal sign
           JZ	PARNUM                    ;If yes, consider contents of buffer to be a number
           CPI	0B0H                     ;If not decimal sign, see if first character represents
           JM	LOOKUP                    ;A deciinal digit, if not, should have a variable
           CPI	0BAH                     ;Continue to test for a decimal digit
           JP	LOOKUP                    ;If not, go look up the variable nwne
PARNUM:	DCR	L                           ;If SYMBOL BUFFER contains number, decrement
           MOV	A,M                      ;Buffer pointer back to (cc) and fetch it to ACC
           CPI	001H                     ;See if length of string in buffer is just one
           JZ	NOEXPO                    ;If so, cannot have number with scientific notation
           ADD	L                        ;If not, add length to buffer pointer to
           MOV	L,A                      ;Point to last character in the buffer
           MOV	A,M                      ;Fetch the last character in buffer and see if it
           CPI	0C5H                     ;Represents letter E for Exponent
           JNZ	NOEXPO                   ;If not, cannot have number with scientific notation
           MVI	L,OFS_EVAL_CURRENT                   ;If yes, have part of a scientific number, set pointer to
           CALL	GETCHR                  ;Get the operator that follows the E and append it to
           JMP	CONCTS                   ;The SYMBOL BUFFER and return to EVAL routine
NOEXPO:	MVI	L,OFS_ARITH_STKPTR                      ;Load L with address of ARITHMETIC STACK pointer
           MVI	H,HIGH OLDPG1            ;** Load H with page of ARITHMETIC STACK pointer
           MOV	A,M                      ;Fetch AS pointer value to ACC and add four to account
           ADI	004H                     ;For the number of bytes required to store a number in
           MOV	M,A                      ;Floating point format. Restore pointer to mernory.
           MOV	L,A                      ;Then, change L to point to entry position in the AS
           CALL	FSTORE                  ;Place contents of the FPACC onto top of the AS
           MVI	L,OFS_SYMBOL_BUF                   ;Change L to point to start of the SYMBOL BUFFER
           MVI	H,HIGH OLDPG26           ;** Set H to page of the SYMBOL BUFFER
           CALL	DINPUT                  ;Convert number in the buffer to floating point format
           JMP	PARSE                    ;In the FPACC then jump to check operator sign.
LOOKUP:	MVI	L,OFS_LOOKUP_CNT                      ;Load L with address of LOOK-UP COUNTER
           MVI	H,HIGH OLDPG26           ;** Load H with page of the counter
           MVI	M,000H                   ;Initialize the counter to zero
           MVI	L,OFS_SYMBOL_BUF                   ;Load L with starting address of the SYMBOL BUFFER
           MVI	D,HIGH OLDPG27           ;** Load D with page of the VARIABLES TABLE
           MVI	E,OFS_VARIABLES_TBL                   ;Load E with start of the VARL433LES TABLE
           MOV	A,M                      ;Fetch the (cc) for the string in the SYMBOL BUFFER
           CPI	001H                     ;See if the name length is just one character. If not,
           JNZ	LOOKU1                   ;Should be two so proceed to look-up routine. Else,
           MVI	L,OFS_SYMBOL_CHAR2                   ;Change L to second character byte in the buffer and set
           MVI	M,000H                   ;It to zero to provide compatibility with entries in table
LOOKU1:	MVI	L,OFS_SYMBOL_CHAR1                      ;Load L with addr of first character in the SYMBOL
           MVI	H,HIGH OLDPG26           ;** BUFFER. Set H to page of the SYMBOL BUFFER.
           CALL	SWITCH                  ;Exchange contents of D&E with H&L so that can
           MOV	A,M                      ;Fetch the first character of a name in the VARIABLES
           INR	L                        ;TABLE. Advance the table pointer and save the
           MOV	B,M                      ;Second byte of name in B. Then advance the pointer
           INR	L                        ;Again to reach first bvte of floating point forrnatted
           CALL	SWITCH                  ;Number in table. Now exchange D&E with H&L and
           CMP	M                        ;Compare first byte in table against first char in buffer
           JNZ	LOOKU2                   ;If not the same, go try next entry in table. If same,
           INR	L                        ;Advance pointer to next char in buffer. Transfer the
           MOV	A,B                      ;Character in B (second byte in table entry) to the ACC
           CMP	M                        ;Compare it against second character in the buffer.
           JZ	LOOKU4                    ;If match, have found the name in the VARIABLES tbl.
LOOKU2:	CALL	AD4DE                      ;Call subroutine to add four to the pointer in D&E to
           MVI	L,OFS_LOOKUP_CNT                   ;Advance the table pointer over value bytes. Then set
           MVI	H,HIGH OLDPG26           ;** Up H and L to point to LOOK-UP COUNTER.
           MOV	B,M                      ;Fetch counter value (counts number of entries tested
           INR	B                        ;In the VARIABLES TABLE), increment it
           MOV	M,B                      ;And restore it back to meynory
           MVI	L,OFS_SYMVAR_CNT                   ;Load L with address of SYMBOL VARIABLES counter
           MVI	H,HIGH OLDPG27           ;** Do same for H. (Counts number of names in table.)
           MOV	A,B                      ;Place LOOK-UP COUNTER value in the accumulator.
           CMP	M                        ;Compare it with number of entries in the table.
           JNZ	LOOKU1                   ;If have not reached end of table, keep looking for name.
           MVI	L,OFS_SYMVAR_CNT                   ;If reach end of table without match, need to add name
           MVI	H,HIGH OLDPG27           ;** To table. First set H & L to the SYMBOL
           MOV	B,M                      ;VARIABLES counter. Fetch the counter value and
           INR	B                        ;Increment to account for new name being added to the
           MOV	M,B                      ;Table. Restore the updated count to meinory. Also,
           MOV	A,B                      ;Move the new counter value to the accumulator and
           CPI	015H                     ;Check to see that table size is not exceeded. If try to
           JP	BIGERR                    ;Go over 20 (decirnal) entries then have BIG error.
           MVI	L,OFS_SYMBOL_CHAR1                   ;Else, set L to point to first character in the SYMBOL
           MVI	H,HIGH OLDPG26           ;** BUFFER and set H to proper page. Set the number
           MVI	B,002H                   ;Of bytes to be transferred into register B as a counter.
           CALL	MOVEIT                  ;Move the symbol name from the buffer to the
           MOV	L,E                      ;VARIABLES TABLE. Now set up H & L with value
           MOV	H,D                      ;Contained in D & E after moving ops (points to first
           XRA	A                        ;Byte of the value to be associated with the symbol
           MOV	M,A                      ;Name.) Clear the accumulator and place zero in all four
           INR	L                        ;Bytes associated with the variable name entered
           MOV	M,A                      ;In the VARIABLES TABLE
           INR	L                        ;In order to
           MOV	M,A                      ;Assign an
           INR	L                        ;Initial value
           MOV	M,A                      ;To the variable narne
           MOV	A,L                      ;Then transfer the address in L to the acc'umulator
           SUI	004H                     ;Subtract four to reset the pointer to start of zeroing ops
           MOV	E,A                      ;Restore the address in D & E to be in same state as if
           MOV	D,H                      ;Name was found in the table in the LOOKUP routine
LOOKU4:	CALL	SAVEHL                     ;Save current address to VARIABLES TABLE
           MVI	L,OFS_ARITH_STKPTR                   ;Load L with address of ARITHMETIC STACK pointer
           MVI	H,HIGH OLDPG1            ;** Load H with page of the pointer
           MOV	A,M                      ;Fetch the AS pointer value to the accumulator
           ADI	004H                     ;Add four to account for next floating point forrnatted
           MOV	M,A                      ;Number to be stored in the stack. Restore the stack
           MOV	L,A                      ;Pointer to memory and set it up in register L too.
           CALL	FSTORE                  ;Place the value in the FPACC on the top of the
           CALL	RESTHL                  ;ARITHMETIC STACK. Restore the VARIABLES
           CALL	SWITCH                  ;TABLE pointer to H&L and move it to D&E. Now load
           CALL	FLOAD                   ;The VARIABLE value from the table to the FPACC.
PARSE:	CALL	CLESYM                      ;Clear the SYMBOL BUFFER
           MVI	L,OFS_PARSER_TOKEN                   ;Load L with address of PARSER TOKEN VALUE
           MOV	A,M                      ;And fetch the token value into the accumulator
           CPI	007H                     ;Is it token value for right parenthesis ")" ? If so, have
           JZ	PARSE2                    ;Special case where must perforin ops til find a "(" !
           ADI	0A0H                     ;Else, fon-n address to HEIRARCHY IN table and
           MOV	L,A                      ;Set L to point to HEIRARCHY IN VALUE in the table
           MOV	B,M                      ;Fetch the heirarchy value from the table to register B
           MVI	L,OFS_OP_STKPTR                   ;Set L to OPERATOR STACK pointer storage location
           MOV	C,M                      ;Fetch the OS pointer into CPU register C
           CALL	INDEXC                  ;Add OS pointer to address of OS pointer storage loc
           MOV	A,M                      ;Fetch the token value for the operator at top of the OS
           ADI	0AFH                     ;And form address to HEIRARCHY OUT table
           MOV	L,A                      ;Set L to point to HEIRARCHY OUT VALUE in the
           MOV	A,B                      ;Table. Move the HEIRARCHY IN value to the ACC.
           CMP	M                        ;Compare the HEIRARCHY IN with the HEIRARCHY
           JZ	PARSE1                    ;OUT value. If heirarchy of current operator equal to or
           JM	PARSE1                    ;Less than operator on top of OS stack, perfo
           MVI	L,OFS_PARSER_TOKEN                   ;Operation indicated in top of OS stack. Else, fetch the
           MOV	B,M                      ;Current operator token value into register B.
           MVI	L,OFS_OP_STKPTR                   ;Load L with address of the OPERATOR STACK pntr
           MOV	C,M                      ;Fetch the stack pointer value
           INR	C                        ;Increment it to account for new entry on the stack
           MOV	M,C                      ;Restore the stack pointer value to memory
           CALL	INDEXC                  ;For in pointer to next entry in OPERATOR STACK
           MOV	M,B                      ;Place the current operator token value on top of the OS
           RET                          ;Exit back to the EVAL routine.
PARSE1:	MVI	L,OFS_OP_STKPTR                      ;Load L with address of the OPERATOR STACK pntr
           MOV	A,M                      ;Fetch the stack pointer value to the accumulator
           ADD	L                        ;Add in the value of the stack pointer address to form
           MOV	L,A                      ;Address that points to top entry in the OS
           MOV	A,M                      ;Fetch the token value at the top of the OS to the ACC
           ANA	A                        ;Check to see if the token value is zero for end of stack
           RZ                           ;Exit back to the EVAL routine if stack empty
           MVI	L,OFS_OP_STKPTR                   ;Else, reset L to the OS pointer storage location
           MOV	C,M                      ;Fetch the pointer value
           DCR	C                        ;Decrement it to account for operator rernoved from
           MOV	M,C                      ;The OPERATOR STACK and restore the pointer value
           CALL	FPOPER                  ;Perform the operation obtained from the top of the OS
           JMP	PARSE                    ;Continue to compare current operator against top of OS
PARSE2:	MVI	L,OFS_OP_STKPTR                      ;Load L with address of the OPERATOR STACK pntr
           MVI	H,HIGH OLDPG26           ;** Load H with page of the pointer
           MOV	A,M                      ;Fetch the stack pointer value to the accumulator
           ADD	L                        ;Add in the value of the stack pointer address to form
           MOV	L,A                      ;Address that points to top entry in the OS
           MOV	A,M                      ;Fetch the token value at the top of the 0 S to the ACC
           ANA	A                        ;Check to see if the token value is zero for end of stack
           JZ	PARNER                    ;If end of stack, then have a parenthesis error condx
           MVI	L,OFS_OP_STKPTR                   ;Else, reset L to the OS pointer storage location
           MOV	C,M                      ;Fetch the pointer value
           DCR	C                        ;Decrement it to account for operator removed from
           MOV	M,C                      ;The OPERATOR STACK and restore the pointer value
           CPI	006H                     ;Check to see if token value is "(" to close parenthesis
           RZ                           ;If so, exit back to EVAL routine.
           CALL	FPOPER                  ;Else, perforin the op obtained from the top of the OS
           JMP	PARSE2                   ;Continue to process data in parenthesis
FPOPER:	MVI	L,OFS_TEMP_OP                      ;Load L with address of TEMP OP storage location
           MVI	H,HIGH OLDPG26           ;** Load H with page of TEMP OP storage location
           MOV	M,A                      ;Store OP (from top of OPERATOR STACK)
           MVI	L,OFS_ARITH_STKPTR                   ;Change L to address of ARff HMETIC STACK pointer
           MVI	H,HIGH OLDPG1            ;** Load H with page of AS pointer
           MOV	A,M                      ;Fetch AS pointer value into ACC
           MOV	L,A                      ;Set L to top of ARITHMETIC STACK
           CALL	OPLOAD                  ;Transfer number from ARffHMETIC STACK to FPOP
           MVI	L,OFS_ARITH_STKPTR                   ;Restore pointer to AS pointer
           MOV	A,M                      ;Fetch the pointer value to the ACC and subtract four
           SUI	004H                     ;To remove top value from the ARITHMETIC STACK
           MOV	M,A                      ;Restore the updated AS pointer to memory
           MVI	L,OFS_TEMP_OP                   ;Set L to address of TEMP OP storage location
           MVI	H,HIGH OLDPG26           ;** Set H to page of TEMP OP storage location
           MOV	A,M                      ;Fetch the operator token value to the ACC
           CPI	001H                     ;Find out which kind of operation indicated
           JZ	FPADD                     ;Perforn addition if have plus operator
           CPI	002H                     ;If not plus, see if minus
           JZ	FPSUB                     ;Perform subtraction if have minus operator
           CPI	003H                     ;If not minus, see if multiplication
           JZ	FPMULT                    ;Perform multiplication if have multiplication operator
           CPI	004H                     ;If not multiplication, see if division
           JZ	FPDIV                     ;Perform division if have division operator
           CPI	005H                     ;If not division, see if exponentiation
           JZ	INTEXP                    ;Perform exponentiation if have exponentiation operator
           CPI	009H                     ;If not exponentiation, see if "less than" operator
           JZ	LT                        ;Perform compaison for "less than" op if indicated
           CPI	00AH                     ;If not 'less than" see if have "equal" operator
           JZ	EQ                        ;Perforin comparison for "equal" op if indicated
           CPI	00BH                     ;If not "equal" see if have "greater than" operator
           JZ	GT                        ;Perform comparison for "greater than" op if indicated
           CPI	00CH                     ;If not "'greater than" see if have 'less than or equal" op
           JZ	LE                        ;Perform comparison for the combination op if indicated
           CPI	00DH                     ;See if have "equal to or greater than" operator
           JZ	GE                        ;Perform comparison for the combination op if indicated
           CPI	00EH                     ;See if have "less than or greater than" operator
           JZ	NE                        ;Perform comparison for the combination op if indicated
PARNER:	MVI	L,OFS_FA_STKPTR                      ;If cannot find operator, expression is not balanced
           MVI	H,HIGH OLDPG26           ;** Set H and L to address of F/A STACK pointer
           MVI	M,000H                   ;Clear the F/A STACK pointer to re-initialize
           MVI	A,0C9H                   ;Load ASCII code for letter I into the accumulator
           MVI	C,0A8H                   ;And code for "(" character into register C
           JMP	ERROR                    ;Go display 1( for "Imbalanced Parenthesis") error msg
LT:	CALL	FPSUB                          ;Subtract contents of FPACC from FPOP to compare
           MVI	L,OFS_FPACC_MSW                   ;Set L to point to the MSW of the FPACC (Contains
           MOV	A,M                      ;Result of the subtraction.) Fetch the MSW of the
           ANA	A                        ;FPACC to the accumulator and test to see if result is
           JM	CTRUE                     ;Positive or negative. Set up the FPACC as a function
           JMP	CFALSE                   ;Of the result obtained.
EQ:	CALL	FPSUB                          ;Subtract contents of FPACC from FPOP to compare
           MVI	L,OFS_FPACC_MSW                   ;Set L to point to the MSW of the FPACC (Contains
           MOV	A,M                      ;Result of the subtraction.) Fetch the MSW of the
           ANA	A                        ;FPACC to the accumulator and test to see if result is
           JZ	CTRUE                     ;Equal. Set up the FPACC as a function
           JMP	CFALSE                   ;Of the result obtained.
GT:	CALL	FPSUB                          ;Subtract contents of FPACC from FPOP to compare
           MVI	L,OFS_FPACC_MSW                   ;Set L to point to the MSW of the FPACC (Contains
           MOV	A,M                      ;Result of the subtraction.) Fetch the MSW of the
           ANA	A                        ;FPACC to the accumulator and test to see if result is
           JZ	CFALSE                    ;Positive, Negative, or Equal. Set up the FPACC
           JP	CTRUE                     ;As a function
           JMP	CFALSE                   ;Of the result obtained.
LE:	CALL	FPSUB                          ;Subtract contents of FPACC from FPOP to compare
           MVI	L,OFS_FPACC_MSW                   ;Set L to point to the MSW of the FPACC (Contains
           MOV	A,M                      ;Result of the subtraction.) Fetch the MSW of the
           ANA	A                        ;FPACC to the accumulator and test to see if result is
           JZ	CTRUE                     ;Positive, Negative, or Equal. Set up the FPACC
           JM	CTRUE                     ;As a function
           JMP	CFALSE                   ;Of the result obtained
GE:	CALL	FPSUB                          ;Submit contents of FPACC from FPOP to compare
           MVI	L,OFS_FPACC_MSW                   ;Set L to point to the MSW of the FPACC (Contains
           MOV	A,M                      ;Result of the subtraction.) Fetch the MSW of the
           ANA	A                        ;FPACC to the accumulator and test to see if result is
           JP	CTRUE                     ;Positive or Negative. Set up the FPACC
           JMP	CFALSE                   ;As a function of the result obtained
NE:	CALL	FPSUB                          ;Subtract contents of FPACC from FPOP to compare
           MVI	L,OFS_FPACC_MSW                   ;Set L to point to the MSW of the FPACC (Contains
           MOV	A,M                      ;Result of the subtraction.) Fetch the MSW of the
           ANA	A                        ;FPACC to the accumulator and test to see if result is
           JZ	CFALSE                    ;Equal. Set up the FPACC as a function of the result.
CTRUE:
FPONE:	MVI	L,OFS_FP_CONST_1                       ;Load L with address of floating point value +1.0
           JMP	FLOAD                    ;Load FPACC with value +1.0 and exit to caller
CFALSE:	MVI	L,OFS_FPACC_EXP                      ;Load L with address of FPACC Exponent register
           MVI	M,000H                   ;Set the FPACC Exponent to zero and then set the
           JMP	FPZERO                   ;Mantissa portion of the FPACC to zero. Exit to caller.
AD4DE:	MOV	A,E                          ;Subroutine to add four to the value in register E.
           ADI	004H                     ;Move contents of E to the ACC and add four.
           MOV	E,A                      ;Restore the updated value back to register E.
           RET                          ;Return to the calling routine.
INTEXP:	MVI	L,OFS_FPACC_MSW                      ;Load L with address of WSW of FPACC (Floating Point
           MVI	H,HIGH OLDPG1            ;** ACCumulator). Load H with page of FPACC.
           MOV	A,M                      ;Fetch MSW of the FPACC into the accumulator.
           MVI	L,OFS_EXP_TEMP                   ;Load L with address of EXP TEMP storage location
           MOV	M,A                      ;Store the FPACC MSW value in EXP TEMP location
           ANA	A                        ;Test contents of the MSW of the FPACC. ff zero, then
           JZ	FPONE                     ;Set FPACC equal to +1.0 (any nr to zero power = 1.0!)
           CM	FPCOMP                    ;If MSW indicates negative number, complement
           CALL	FPFIX                   ;The FPACC. Then convert floating point number to
           MVI	L,OFS_FPACC                   ;Fixed point. Load L with address of LSW of fixed nr
           MOV	B,M                      ;Fetch the LSW into CPU register B.
           MVI	L,OFS_EXP_COUNTER                   ;Set L to address of EXPONENT COUNTER
           MOV	M,B                      ;Place the fixed value in the EXP CNTR to indicate
           MVI	L,OFS_FPOP                   ;Number of multiplications needed (power). Now set L
           MVI	E,OFS_FP_TEMP                   ;To LSW of FPOP and E to address of FP TEMP (LSW)
           MVI	H,HIGH OLDPG1            ;** Set H to floating point working area page.
           MOV	D,H                      ;Set D to same page address.
           MVI	B,004H                   ;Set transfer (precision) counter. Call subroutine to move
           CALL	MOVEIT                  ;Contents of FPOP into FP TEMP registers to save
           CALL	FPONE                   ;Original value of FPOP. Now set FPACC to +1.0.
           MVI	L,OFS_EXP_TEMP                   ;Load L with pointer to original value of FPACC
           MOV	A,M                      ;(Stored in FP TEMP) MSW and fetch contents to ACC.
           ANA	A                        ;Test to see if raising to a negative power. If so, divide
           JM	DVLOOP                    ;Instead of multiply!
MULOOP:	MVI	L,OFS_FP_TEMP                      ;Load L with address of LSW of FP TEMP (original
           CALL	FACXOP                  ;Value in FPOP). Move FP TEMP into FPOP.
           CALL	FPMULT                  ;Multiply FPACC by FPOP. Result left in FPACC.
           MVI	L,OFS_EXP_COUNTER                   ;Load L with address of EXPONENT COUNTER.
           MOV	B,M                      ;Fetch the counter value
           DCR	B                        ;Decrement it
           MOV	M,B                      ;Restore it to memory
           JNZ	MULOOP                   ;If counter not zero, continue exponentiation process
           RET                          ;When have raised to proper power, return to caller.
DVLOOP:	MVI	L,OFS_FP_TEMP                      ;Load L with address of LSW of FP TEMP (original
           CALL	FACXOP                  ;Value in FPOP). Move FP TEMP into FPOP.
           CALL	FPDIV                   ;Divide FPACC by FPOP. Result left in FPACC.
           MVI	L,OFS_EXP_COUNTER                   ;Load L with address of EXPONENT COUNTER
           MOV	B,M                      ;Fetch the counter value
           DCR	B                        ;Decrement it
           MOV	M,B                      ;Restore to memory
           JNZ	DVLOOP                   ;If counter not zero, continue exponentiation process
           RET                          ;When have raised to proper power, return to caller.

;;; The label PRIGHT: SHOULD BE UP TO 07 003
PRIGHT:	MVI	L,OFS_FA_STKPTR                      ;Load L with address of F/A STACK pointer
           MVI	H,HIGH OLDPG26           ;** Load H with page of F/A STACK pointer
           MOV	A,M                      ;Fetch the pointer value into the ACC
           ADD	L                        ;Form pointer to top of the F/A STACK
           MOV	L,A                      ;Set L to point to top of the F/A STACK
           MOV	A,M                      ;Fetch the contents of the top of the F/A STACK into
           MVI	M,000H                   ;The ACC then clear the top of the F/A STACK
           MVI	L,OFS_TOKEN_STORE                   ;Load L with address of F /A STACK TEMP storage
           MVI	H,HIGH OLDPG27           ;** Location. Set H to page of F/A STACK TEMP
           MOV	M,A                      ;Store value from top of F/A STACK into temp loc.
           ANA	A                        ;Test to see if token value in top of stack was zero
           RZ                           ;If so, just had simple grouping parenthesis!
           JM	PRIGH1                    ;@@ If token value minus, indicates array subscript
           CPI	001H                     ;For positive token value, look for appropriate function
           JZ	INTX                      ;If token value for INTeger function, go do it.
           CPI	002H                     ;Else, see if token value for SIGN function.
           JZ	SGNX                      ;If so, go do it.
           CPI	003H                     ;Else, see if token value for ABSolute function
           JZ	ABSX                      ;If so, go do it.
           CPI	004H                     ;If not, see if token value for SQuare Root function
           JZ	SQRX                      ;If so, go do it.
           CPI	005H                     ;If not, see if token value for TAB function
           JZ	TABX                      ;If so, go do it.
           CPI	006H                     ;If not, see if token value for RaNDom function
           JZ	RNDX                      ;If so, go find a random number.
           CPI	007H                     ;If not, see if token value for CHaRacter function
           JZ	CHRX                      ;If so, go perform the function.
           CPI	008H                     ;Else, see if token for user defined machine language
           JZ	UDEFX                     ;# Function. If so, perform the User DEfined Function
           HLT                          ;Safety halt. Program should not reach this location!

;;; The label FUNARR SHOULD BE AT 07 100
FUNARR:	MVI	L,OFS_SYMBOL_BUF                      ;Load L with starting address of SYMBOL BUFFER
           MVI	H,HIGH OLDPG26           ;** Load H with page of SYMBOL BUFFER
           MOV	A,M                      ;Fetch the (cc) for contents of buffer to the ACC
           ANA	A                        ;See if (cc) is zero, if so buffer is empty, return to
           RZ                           ;Caller as have simple grouping parenthesis sign
           MVI	L,OFS_SCAN_PTR                   ;Else set L to TEMP COUNTER location
           MVI	H,HIGH OLDPG27           ;** Set H to TEMP COUNTER page
           MVI	M,000H                   ;Initialize TEMP COUNTER to zero
FUNAR1:	MVI	L,OFS_SCAN_PTR                      ;Load L with address of TEMP COUNTER
           MVI	H,HIGH OLDPG27           ;** Load H with page of TEMP COUNTER
           MOV	B,M                      ;Fetch the counter value to register B
           INR	B                        ;Increment the counter
           MOV	M,B                      ;Restore the updated value to memory
           MVI	C,002H                   ;Initialize C to a value of two for future ops
           MVI	L,OFS_FUNC_TBL_BASE                   ;Load L with starting address (less four) of FUNCTION
           MVI	H,HIGH OLDPG26           ;** LOOK-UP TABLE. Set H to table page.
           CALL	TABADR                  ;Find address of next entry in the table
           MVI	D,HIGH OLDPG26           ;** Load D with page of SYMBOL BUFFER
           MVI	E,OFS_SYMBOL_BUF                   ;Load E with starting address of SYMBOL BUFFER
           CALL	STRCP                   ;Compare entry in FUNCTION LOOK-UP TABLE with
           JZ	FUNAR4                    ;Contents of SYMBOL BUFFER. If find match, go set
           MVI	L,OFS_SCAN_PTR                   ;Up the function token value. Else, set L to the TEMP
           MVI	H,HIGH OLDPG27           ;** COUNTER and set H to the proper page. Fetch the
           MOV	A,M                      ;Current counter value and see if have tried all eight
           CPI	008H                     ;Possible functions in the table.
           JNZ	FUNAR1                   ;If not, go back and check the next entry.
           MVI	L,OFS_SCAN_PTR                   ;If have tried all of the entries in the table, set L
           MVI	H,HIGH OLDPG27           ;** As well as H to the address of the TEMP COUI,.7ER
           MVI	M,000H                   ;And reset it to zero. Now go see if have subscripted
           JMP	FUNAR2                   ;@@ Array (unless array capability not in program).
FAERR:	MVI	L,OFS_FA_STKPTR                       ;Load L with address of F/A STACK pointer
           MVI	H,HIGH OLDPG26           ;** Load H with page of F/A STACK pointer
           MVI	M,000H                   ;Clear the F/A STACK pointer to reset on an error
           MVI	A,0C6H                   ;Load the ASCII code for letter F into the ACC
           MVI	C,0C1H                   ;Load the ASCII code for letter A into register C
           JMP	ERROR                    ;Go display the FA error message
FUNAR4:	MVI	L,OFS_SCAN_PTR                      ;Load L with address of TEMP COUNTER
           MVI	H,HIGH OLDPG27           ;** Set H to page of TEMP COUNTER
           MOV	B,M                      ;Load value in counter to register B. This is FUNCTION
           MVI	L,OFS_FA_STKPTR                   ;TOKEN VALUE. Cbange- L to F/A STACK pointer.
           MVI	H,HIGH OLDPG26           ;** Load H with page of F/A STACK pointer.
           MOV	C,M                      ;Fetch the F/A STACK pointer value into register C.
           CALL	INDEXC                  ;Form the address to the top of the F/A STACK.
           MOV	M,B                      ;Store the FUNCTION TOKEN VALUE in the F/A
           JMP	CLESYM                   ;STACK. Then exit by clearing the SYMBOL BUFFER.
TABADR:	MOV	A,B                         ;Move the TEMP COUNTER value from B to ACC
TABAD1:	RLC                             ;Multiply by four using this loop to form value equal
           DCR	C                        ;To number of bytes per entry (4) times current entry
           JNZ	TABAD1                   ;In the FUNCTION LOOK-UP TABLE.
           ADD	L                        ;Add this value to the starting address of the table.
           MOV	L,A                      ;Form pointer to next entry in table
           RNC                          ;If no carry return to caller
           INR	H                        ;Else, increment H before
           RET                          ;Returning to caller

;;; The label INTX SHOULD BE AT 07 243
INTX:	MVI	L,OFS_FPACC_MSW                        ;Load L with address of MSW of the FPACC
           MVI	H,HIGH OLDPG1            ;** Load H with the page of the PPACC
           MOV	A,M                      ;Fetch the MSW of the FPACC into the accumulator
           ANA	A                        ;Test the sign of the number in the FPACC. If
           JP	INT1                      ;Positive jump ahead to integerize
           MVI	L,OFS_FP_TEMP                   ;If negative, load L with address of FP TEMP registers
           CALL	FSTORE                  ;Store the value in the FPACC in FP TEMP
           CALL	FPFIX                   ;Convert the value in FPACC from floating point to
           MVI	L,OFS_SYMBOL_BUF+3                   ;Fixed point. Load L with address of FPACC
           MVI	M,000H                   ;Extension register and clear it.
           CALL	FPFLT                   ;Convert fixed binary back to FP to integerize
           MVI	L,OFS_FP_TEMP                   ;Load L with address of FP TEMP registers
           CALL	OPLOAD                  ;Load the value in FP TEMP into FPOP
           CALL	FPSUB                   ;Subtract integerized value from original
           MVI	L,OFS_FPACC_MSW                   ;Set L to address of MSW of FPACC
           MOV	A,M                      ;Fetch the MSW of the FPACC into the accumulator
           ANA	A                        ;See if original value and integerized value the same
           JZ	INT2                      ;If so, have integer value in FP TEMP
           MVI	L,OFS_FP_TEMP                   ;Else, load L with address of FP TEMP registers
           CALL	FLOAD                   ;Restore FPACC to original (non-integerized) value
           MVI	L,OFS_FP_CONST_NEG1                   ;Set L to register containing small value
           CALL	FACXOP                  ;Set up to add small value to original value in FPACC
           CALL	FPADD                   ;Perform the addition
INT1:	CALL	FPFIX                        ;Convert the number in FPACC from floating point
           MVI	L,OFS_SYMBOL_BUF+3                   ;To fixed point. Load L with address of FPACC
           MVI	M,000H                   ;Extension register and clear it. Now convert the number
           JMP	FPFLT                    ;Back to floating point to integerize it and exit to caller
INT2:	MVI	L,OFS_FP_TEMP                        ;Load L with address of FP TEMP registers. Transfer
           JMP	FLOAD                    ;Number from FP TEMP (orig) to FPACC and return.
ABSX:	MVI	L,OFS_FPACC_MSW                        ;Load L with address of MSW of the FPACC
           MVI	H,HIGH OLDPG1            ;** Set H to page of the FPACC
           MOV	A,M                      ;Fetch the MSW of the FPACC into the accumulator
           ANA	A                        ;Test the sign of the number to see if it is positive.
           JM	FPCOMP                    ;If negative, complement the number before returning.
           RET                          ;Else, just return with absolute value in the FPACC.
SGNX:	MVI	L,OFS_FPACC_MSW                        ;Load L with address of MSW of the FPACC
           MVI	H,HIGH OLDPG1            ;** Load H with the page of the FPACC
           MOV	A,M                      ;Fetch the MSW of the FPACC into the accumulator
           ANA	A                        ;Test to see if the FPACC is zero
           RZ                           ;Return to caller if FPACC is zero
           JP	FPONE                     ;If FPACC is positive, load +1.0 into FPACC and exit
           MVI	L,OFS_FP_CONST_NEG1                   ;If FPACC is negative, set up to load -1.0 into the
           JMP	FLOAD                    ;FPACC and exit to caller
CHRX:	CALL	FPFIX                        ;Convert contents of FPACC from floating point to
           MVI	L,OFS_FPACC                   ;Fixed point. Load L with address of LSW of fixed
           MOV	A,M                      ;Value. Fetch this byte into the accumulator.
           CALL	ECHO                    ;Display the value.
           MVI	L,OFS_TAB_FLAG                   ;Set L to address of the TAB FLAG
           MVI	H,HIGH OLDPG26           ;** Set H to page of the TAB FLAG
           MVI	M,0FFH                   ;Set TAB FLAG (to inhibit display of FP value)
           RET                          ;Exit to caller.
TABX:	CALL	FPFIX                        ;Convert contents of FPACC from floating point to
TAB1:	MVI	L,OFS_FPACC                        ;Fixed point. Load L with address of 1,SW of fixed
           MOV	A,M                      ;Value. Fetch this byte into the accumulator.
           MVI	L,OFS_COL_COUNTER                   ;Load L with address of COLUMN COUNTER
           SUB	M                        ;Subtract value in C-OLUMN COUNTER from desired
           MVI	L,OFS_TAB_FLAG                   ;TAB position. Load L with address of the TAB FLAG.
           MVI	H,HIGH OLDPG26           ;** Set H to page of the TAB FLAG.
           MVI	M,0FFH                   ;Set TAB FLAG (to inhibit display of FP value)
           JM	BACKSP                    ;If beyond TAB point desired, simulate back spacing
           RZ                           ;Return to caller if at desired TAB location
TABC:	MOV	C,A                           ;Else, put difference count in register C
           MVI	A,0A0H                   ;Place ASCII code for space in ACC
TABLOP:	CALL	ECHO                       ;Display space on output device
           DCR	C                        ;Decrement displacement counter
           JNZ	TABLOP                   ;If have not reached TAB position, continue to space
           RET                          ;Else, return to calling routine.

;;; The label STOSYM should be AT 10 055
STOSYM:	MVI	L,OFS_SYNTAX_PTR                      ;Load L with address of ARRAY FLAG
           MVI	H,HIGH OLDPG27           ;** Load H with page of ARRAY FLAG
           MOV	A,M                      ;Fetch the value of the ARRAY FLAG into the ACC
           ANA	A                        ;Check to see if the flag is set indicating processing an
           JZ	STOSY1                    ;Array variable value. Jump ahead if flag not set.
           MVI	M,000H                   ;If ARRAY FLAG was set, clear it for next time.
           MVI	L,OFS_TEMP_ARRAY                   ;Then load L with address of array address storage loc
           MOV	L,M                      ;Fetch the array storage address as new pointer
           MVI	H,HIGH OLDPG57           ;tt Set H to ARRAY VALUES page   ****************
           JMP	FSTORE                   ;Store the array variable value and exit to caller.
STOSY1:	MVI	L,OFS_LOOKUP_CNT                      ;Load L with address of TEMP CNTR
           MVI	H,HIGH OLDPG26           ;** Load H with page of TEMP CNTR
           MVI	M,000H                   ;Initialize the TEMP CNTR by clearing it
           MVI	L,OFS_SYMBOL_BUF                   ;Load L with starting address of SYMBOL BUFFER
           MVI	D,HIGH OLDPG27           ;** Load D with page of VARIABLES LOOK-UP table
           MVI	E,OFS_VARIABLES_TBL                   ;Load E with starting addr of VARIABLES LOOK-UP
           MOV	A,M                      ;Table. Fetch the (cc) for the SYMBOL BUFFER into
           CPI	001H                     ;The ACC and see if length of variable name is just one
           JNZ	STOSY2                   ;Character. If not, skip next couple of instructions.
           MVI	L,OFS_SYMBOL_CHAR2                   ;Else, set pointer to second character location in the
           MVI	M,000H                   ;SYMBOL BUFFER and set it to zero
STOSY2:	MVI	L,OFS_SYMBOL_CHAR1                      ;load L with address of first character in the SYMBOL
           MVI	H,HIGH OLDPG26           ;** BUFFER. Load H with page of the buffer.
           CALL	SWITCH                  ;Exchange pointer to buffer for pointer to VARIABLES
           MOV	A,M                      ;LOOK-UP table. Fetch first char in a name from the
           INR	L                        ;Table. Advance the pointer to second char in a name.
           MOV	B,M                      ;Fetch the second character into register B.
           INR	L                        ;Advance the pointer to first byte of a value in the table.
           CALL	SWITCH                  ;Exchange table pointer for pointer to SYMBOL BUFF
           CMP	M                        ;Compare first character in buffer against first character
           JNZ	STOSY3                   ;In table entry. If no match, try next entry in the table.
           INR	L                        ;If match, advance pointer to second character in buffer.
           MOV	A,B                      ;Move second character obtained from table into ACC.
           CMP	M                        ;Compare second characters in table and buffer.
           JZ	STOSY5                    ;If same, have found the variable name in the table.
STOSY3:	CALL	AD4DE                      ;Add four to pointer in registers D&E to skip over value
           MVI	L,OFS_LOOKUP_CNT                   ;Portion of entry in table. Load L with address of TEMP
           MVI	H,HIGH OLDPG26           ;** CNTR. Load H with page of TEMP CNTR.
           MOV	B,M                      ;Fetch the counter
           INR	B                        ;Increment the counter
           MOV	M,B                      ;Restore it to storage
           MVI	L,OFS_SYMVAR_CNT                   ;Set L to address of VARIABLES CNTR (indicates
           MVI	H,HIGH OLDPG27           ;** Number of variables currently in table.) Set H too
           MOV	A,B                      ;Move the TEMP CNTR value into the ACC. (Number of
           CMP	M                        ;Entries checked.) Compare with number of entries in
           JNZ	STOSY2                   ;The table. If have not checked all entries, try next one.
           MVI	L,OFS_SYMVAR_CNT                   ;If have checked all entries, load L with address of the
           MVI	H,HIGH OLDPG27           ;** VARIABLES CNTR. Set H too. Fetch the counter
           MOV	B,M                      ;Value and incrernent it to account for
           INR	B                        ;New variable nwne that will now be
           MOV	M,B                      ;Added to the table. Save the new value.
           MOV	A,B                      ;Place the new counter value into the accumulator
           CPI	015H                     ;And check to see that adding new variable name to the
           JP	BIGERR                    ;Table will not cause table overflow. Big Error if it does!
           MVI	L,OFS_SYMBOL_CHAR1                   ;If room available in table, set L to address of first
           MVI	H,HIGH OLDPG26           ;** Caracter in the SYMBOL BUFFER. Set H too.
           MVI	B,002H                   ;Set a counter for number of characters to transfer.
           CALL	MOVEIT                  ;Move the variable name from buffer to table.
STOSY5:	CALL	SWITCH                     ;Exchange buffer pointer for table pointer.
           CALL	FSTORE                  ;Transfer new mathematical value into the table.
           JMP	CLESYM                   ;Clear the SYMBOL BUFFER and exit to calling routine.

                                  ;The subroutines below are used by some of the routines
                                  ;in this chapter as well as other parts of the program.

SAVESY:	MVI	L,OFS_SYMBOL_BUF                      ;Load L with the address of the start of the SYMBOL
           MVI	H,HIGH OLDPG26           ;** BUFFER. Load H with the page of the buffer.
           MOV	D,H                      ;Load register D with the page of the AUX SYMBOL
           MVI	E,OFS_SYMBOL_BUF_64                   ;BUFFER and set register E to start of that buffer.
           JMP	MOVECP                   ;Transfer SYMBOL BF contents to AUX SYMBOL BF

RESTSY:	MVI	L,OFS_FP_WORK+4                      ;Load L with address of start of AUX SYMBOL BUFF
           MVI	H,HIGH OLDPG26           ;** Load H with page of AUX SYMBOL BUFFER
           MOV	D,H                      ;Set D to page of SYMBOL BUFFER (same as H)
           MVI	E,OFS_SYMBOL_BUF                   ;Load E with start of SYMBOL BUFFER
MOVECP:	MOV	B,M                         ;Load (cc) for source string (first byte in source buffer)
           INR	B                        ;Add one to (cc) to include (cc) byte itself
           JMP	MOVEIT                   ;Move the source string to destination buffer

;;; The label Exec SHOULD BE AT 10 266 (This is the start of the code)
EXEC:	MVI	L,OFS_MSG_READY                        ;Load L with address of READY message
           MVI	H,HIGH OLDPG1            ;** Load H with page of READY message
           CALL	TEXTC                   ;Call subroutine to display the READY message

EXEC1:	MVI	L,OFS_LINE_INP_BUF           ;Load L with starting address of INPUT LINE BUFFER
           MVI	H,HIGH OLDPG26           ;** Load H with page of INPUT LINE BUFFER
           CALL	STRIN                   ;Call subroutine to input a line into the buffer
           MOV	A,M                      ;The STRIN subroutine will exit with pointer set to the
           ANA	A                        ;CHARACTER COUNT for the line inputted. Fetch the
           JZ	EXEC1                     ;Value of the counter, if it is zero then line was blank.
           MVI	L,OFS_KW_LIST                   ;Load L with address of LIST in look up table
           MVI	H,HIGH OLDPG1            ;Load H with address of LIST in look up table
           MVI	D,HIGH OLDPG26           ;Load D with page of line input buffer
           MVI	E,OFS_LINE_INP_BUF                   ;Load E with start of line input buffer
           CALL	STRCP                   ;Call string compare subroutine to see if first word in
           JNZ	NOLIST                   ;Input buffer is LIST. Jump 3 ahead if not LIST.
           MVI	L,OFS_USER_PROG          ;If LIST, set up pointers to start of USER PROGRAM
           MVI	H,BGNPGRAM               ;BUFFER. (Note user could alter this starting addr)   *****

                                  ;Next portion of program will LIST the contents of the
                                  ;USER PROGRAM BUFFER until an end of buffer
                                  ;(zero byte) indicator is detected.

LIST:	MOV	A,M                           ;Fetch the first byte of a line in the USER PROGRAM
           ANA	A                        ;BUFFER and see if it is zero. If so, have finished LIST
           JZ	EXEC                      ;So go back to start of Executive and display READY.
           CALL	TEXTC                   ;Else call subroutine to display a line of information
           CALL	ADV                     ;Now call subroutine to advance buffer pointer to
           CALL	CRLF                    ;Character count in next line. Also display a CR & LF.
           JMP	LIST                     ;Continue LISTing process

                                  ;If line inputted by operator did not contain a LIST comman
                                  ;continue program to see if RUN or SCRatch command.

NOLIST:	MVI	L,OFS_KW_RUN                      ;Load L with address of RUN in look up table
           MVI	H,HIGH OLDPG1            ;** Load H with address of RUN in look up table
           MVI	E,OFS_LINE_INP_BUF                   ;Load E with start of line input buffer
           MVI	D,HIGH OLDPG26           ;** Load D with page of line input buffer
           MVI	E,OFS_LINE_INP_BUF                   ;(Reserve 2 locs in case of patching by duplicating above)
           CALL	STRCP                   ;Call string compare subroutine to see if first word in
           JZ	RUN                       ;Input buffer is RUN. Go to RUN routine if match.
           MVI	D,HIGH OLDPG26           ;** If not RUN command, reset address pointers back
           MVI	E,OFS_LINE_INP_BUF                   ;To the start of the line input buffer
           MVI	L,OFS_KW_SCR                   ;Load L with address of SCR in look up table
           MVI	H,HIGH OLDPG1            ;** Load H with page of SCR in look up table
           CALL	STRCP                   ;Call string compare subroutine to see if first word in
           JNZ	NOSCR                    ;Input buffer is SCR. If not then jump ahead.
           MVI	H,HIGH OLDPG26           ;** If found SCR command then load memory pointer
           MVI	L,OFS_TEMP_F4                   ;With address of a pointer storage location. Set that
           MVI	M,BGNPGRAM               ;tt Storage location to page of start of USER PRO-  *******
           INR	L                        ;GRAM BUFFER. (Buffer start loc may be altered).
           MVI	M,000H                   ;Then adv pntr and do same for low addr portion of pntr
           MVI	L,OFS_SYMVAR_CNT                   ;Now set pointer to address of VARIABLES counter
           MVI	H,HIGH OLDPG27           ;** Storage location. Initialize this counter by placing
           MVI	M,001H                   ;The count of one into it. Now change the memory pntr
;MGA 3/31/12 put it back to 001; solves nested FOR/NEXT, but limits vars to 19
;   as the letter from James Tucker (1/77) mentioned
;   apparently, James didn't test FOR/NEXT; original Loboyko didn't have this
;;;           LMI 001                ;The count of one into it. Now change the memory pntr
;;; Apparently, in Page 3 of Issue 4 of Scelbal update (1/77) they say the above should change.
;;; This makes the SCR command clear the whole variable space, otherwise one space is lost.  
           MVI	L,OFS_SYMVAR_CNT-2                   ;To storage location for number of dimensioned arrays
           MVI	M,000H                   ;@@ And initialize to zero. (@@ = Substitute NOPs if
           MVI	L,OFS_SYMBOL_BUF                   ;@@ DIMension capability not used in package.) Also
           MVI	M,000H                   ;@@ Initialize l'st byte of array name table to zero.
           MVI	L,OFS_OP_STKPTR                   ;Set pointer to storage location for the first byte of the
           MVI	M,000H                   ;VARIABLES symbol table. Initialize it to zero too.
           INR	L                        ;Advance the pointer and zero the second location
           MVI	M,000H                   ;In the Variables table also.
           MVI	H,BGNPGRAM               ;tt Load H with page of start of USER PROGRAM    **********
           MVI	L,OFS_USER_PROG          ;BUFFER. (Buffer start location could be altered.)
           MVI	M,000H                   ;Clear first location to indicate end of user program.
           MVI	H,HIGH OLDPG57           ;@@ Load H with page of ARRAYS storage
SCRLOP:	MVI	M,000H                      ;@@ And form a loop to clear out all the locations
           INR	L                        ;@@ On the ARRAYS storage page. (@@ These become
           JNZ	SCRLOP                   ;@@ NOPs if DIMension capability deleted fm package.)
           JMP	EXEC                     ;SCRatch operations completed, go back to EXEC.

                                  ;If line inputted did not contain RUN or SCRatch com-
                                  ;mand, program continues by testing for SAVE or LOAD
                                  ;commands. If it does not find either of these com-
                                  ;mands, then operator did not input an executive com-
                                  ;mand. Program then sets up to see if the first entry in
                                  ;the line inputted is a LINE NUMBER.

NOSCR:	MVI	E,LOW KW_SAVE                       ;Load E with address of SAVE in look up table
           MVI	D,HIGH OLDPG1            ;Load D with page of look up table
           MVI	H,HIGH OLDPG26           ;Load H with page of input line buffer
           MVI	L,OFS_LINE_INP_BUF       ;Set L to start of input line buffer
           CALL	STRCP                   ;Call string compare subroutine to see if first word in
           JZ	SAVE                      ;tt Input buffer is SAVE. If so, go to user's SAVE rtn
           MVI	L,OFS_EVAL_FINISH                   ;If not SAVE then load L with address of LOAD in look
           MVI	H,HIGH OLDPG1            ;Up table and load H with page of look up table
           MVI	D,HIGH OLDPG26           ;Load D with page of input line buffer
           MVI	E,OFS_LINE_INP_BUF                   ;And L to start of input line buffer
           CALL	STRCP                   ;Call string compare subroutine to see if first word in
           JZ	LOAD                      ;tt Input buffer is LOAD. If so, go to user's LOAD rtn
           MVI	L,OFS_TEMP_F0                   ;If not LOAD then set pointer to address of storage loc
           MVI	H,HIGH OLDPG26           ;** For USER PROGRAM BUFFER pointer. Initialize this
           MVI	M,BGNPGRAM               ;tt Pointer to the starting address of the program buffer.
           INR	L                        ;Advance memory pntr. Since pointer storage requires
           MVI	M,000H                   ;Two locations, initialize the low addr portion also.
           CALL	SYNTAX                  ;Call the SYNTAX subroutine to obtain a TOKEN indi-
           MVI	L,OFS_TOKEN_STORE                   ;Cator which will be stored in this location. Upon return
           MVI	H,HIGH OLDPG26           ;** From SYNTAX subroutine set memory pointer to
           MOV	A,M                      ;The TOKEN indicator storage location and fetch the
           ANA	A                        ;Value of the TOKEN. If the value of the syntax TOKEN
           JP	SYNTOK                    ;Is positive then have a valid entry.
SYNERR:	MVI	A,0D3H                      ;However, if SYNTAX returns a negative value TOKEN
           MVI	C,0D9H                   ;Then have an error condition. Set up the letters SY in
           JMP	ERROR                    ;ASCII code and go to display error message to operator.
SYNTOK:	MVI	L,OFS_LINENUM_BUF                      ;Set pointer to start of LINE NUMBER storage area
           MOV	A,M                      ;First byte there will contain the length of the line
           ANA	A                        ;Number character string. Fetch that value (cc).
           JZ	DIRECT                    ;DIRECT If line number blank, have a DIRECT statement!
           MVI	L,OFS_TEMP_F0                   ;If have a line number must get line in input buffer into
           MVI	M,BGNPGRAM               ;tt User program buffer. Initialize pointer to user buffer.
           INR	L                        ;This is a two byte pointer so after initializing page addr
           MVI	M,000H                   ;Advance pointer and initialize location on page address

                                  ;If the line in the LINE INPUT BUFFER has a line num-
                                  ;ber then the line is to be placed in the USER PRO-
                                  ;GRAM BUFFER. It is now necessary to determine
                                  ;where the new line is to be placed in the USER PRO-
                                  ;GRAM BUFFER. This is dictated by the value of the
                                  ;new line number in relation to the line numbers cur-
                                  ;rently in the program buffer. The next portion of the
                                  ;program goes through the contents of the USER PRO-
                                  ;GRAM BUFFER comparing the values of the line num-
                                  ;bers already stored against the value of the line number
                                  ;currently being held in the LINE INPUT BUFFER.
                                  ;Appropriate action is then taken to Insert or Append,
                                  ;Change, or Delete a line in the program buffer.

GETAUX:	MVI	L,OFS_SYNTAX_PTR                      ;Set memory pointer to line character pointer storage
           MVI	H,HIGH OLDPG26           ;** Location and then initialize that storage location
           MVI	M,001H                   ;To point to the 1'st character in a line
           MVI	L,OFS_AUX_LINENUM                   ;Set memory pointer to addr of start of auxiliary line
           MVI	M,000H                   ;Number storage area and initialize first byte to zero
GETAU0:	MVI	L,OFS_SYNTAX_PTR                      ;Set memory pointer to line character pointer storage loc
           CALL	GETCHP                  ;Fetch a char in line pointed to by line pointer
           JZ	GETAU1                    ;If character is a space, skip it by going to advance pntrs
           CPI	0B0H                     ;If not a space check to see if character represents a
           JM	GETAU2                    ;Valid decimal digit in the range 0 to 9 by testing the
           CPI	0BAH                     ;ASCII code value obtained. If not a deciznal digit then
           JP	GETAU2                    ;Assume have obtained the line number. Go process.
           MVI	L,OFS_AUX_LINENUM                   ;If valid decimal digit want to append the digit to the
           MVI	H,HIGH OLDPG26           ;** Current string being built up in the auxiliary line
           CALL	CONCT1                  ;Number storage area so call sub to concat a character.
GETAU1:	MVI	L,OFS_SYNTAX_PTR                      ;Reset memory pointer to line character pntr storage loc
           MVI	H,HIGH OLDPG26           ;On the appropriate page.
           MOV	B,M
           INR	B                        ;Fetch the pointer, increment it, and restore new value
           MOV	M,B
           MVI	L,OFS_TEMP_F0                   ;Set memory pointer to pgm buff line pntr storage loc
           MVI	H,HIGH OLDPG26
           MOV	C,M                      ;Bring the high order byte of this double byte pointer
           INR	L                        ;Into CPU register C. Then advance the memory pntr
           MOV	L,M                      ;And bring the low order byte into register L. Now trans-
           MOV	H,C                      ;Fer the higher order portion into memory pointer H.
           MOV	A,M                      ;Obtain the char cntr (cc) which indicates the length of
           DCR	B                        ;The line being pointed to by the user program line pntr
           CMP	B                        ;Compare this with the value of the chars processed so
           JNZ	GETAU0                   ;Far in current line. If not equal, continue getting line n
GETAU2:	MVI	L,OFS_TEMP_F0                      ;Reset mem pntr to pgm buffer line pntr storage
           MVI	H,HIGH OLDPG26           ;** On this page and place the high order byte
           MOV	D,M                      ;Of this pointer into CPU register D
           INR	L                        ;Advance the memory pointer, fetch the second
           MOV	L,M                      ;Byte of the pgm buffer line pointer into register L
           MOV	H,D                      ;Now make the memory pointer equal to this value
           MOV	A,M                      ;Fetch the first byte of a line in the program buffer
           ANA	A                        ;Test to see if end of contents of pgm buff (zero byte)
           JNZ	NOTEND                   ;If not zero continue processing. If zero have reached
           JMP	NOSAME                   ;End of buffer contents so go APPEND line to buffer.
;;; there are some open addresses here.  Above JUMP starts at 11-304;
;;; The below label patch3 should start at 11 307
PATCH3:	MVI	L,OFS_SYNTAX_PTR                      ; ptr to A/V storage
	   MVI	H,HIGH OLDPG27                  ; MGA 3/31/12 make relocatable; prev: LHI 027
	   MVI	M,000H                          ; clear A/V flag
	   JMP	EXEC

	ORG	009DEH
NOTEND:	MVI	L,OFS_AUX_LINENUM                      ;Load L with addr of auxiliary line number storage loc
           MVI	H,HIGH OLDPG26           ;Load H with addr of aux line number storage loc
           MVI	D,HIGH OLDPG26           ;Load D with addr of line number buffer location
           MVI	E,OFS_LINENUM_BUF                   ;Load E with address of line number buffer location
           CALL	STRCP                   ;Compare line nr in input buffer with line number in
           JM	CONTIN                    ;User program buffer. If lesser in value keep looking.
           JNZ	NOSAME                   ;If greater in value then go to Insert line in pgm buffer
           MVI	L,OFS_TEMP_F0                   ;If same values then must remove the line with the same
           MVI	H,HIGH OLDPG26           ;** Line number from the user program buffer. Set up
           MOV	C,M                      ;The CPU memory pointer to point to the current
           INR	L                        ;Position in the user program buffer by retrieving that
           MOV	L,M                      ;Pointer from its storage location. Then obtain the first
           MOV	H,C                      ;Byte of data pointed to which will be the character
           MOV	B,M                      ;Count for that line (cc). Add one to the cc value to take
           INR	B                        ;Account of the (cc) byte itself and then remove that
           CALL	REMOVE                  ;Many bytes to effectively delete the line fm the user
           MVI	L,OFS_TOKEN_STORE                   ;Program buffer. Now see if line in input buffer consists
           MVI	H,HIGH OLDPG26           ;** Only of a line number by checking SYNTAX
           MOV	A,M                      ;TOKEN value. Fetch the TOKEN value from its
           ANA	A                        ;Storage location. If it is zero then input buffer only
           JZ	EXEC                      ;Contains a line number. Action is a pure Delete.
NOSAME:	MVI	L,OFS_TEMP_F0                      ;Reset memory pointer to program buffer
           MVI	H,HIGH OLDPG26           ;Line pointer storage location
           MOV	D,M                      ;Load high order byte into CPU register D
           INR	L                        ;Advance memory pointer
           MOV	E,M                      ;Load low order byte into CPU register E
           MVI	L,OFS_LINE_INP_BUF       ;Load L with address of start of line input buffer
           MVI	H,HIGH OLDPG26           ;** Do same for CPU register H
           MOV	B,M                      ;Get length of line input buffer
           INR	B                        ;Advance length by one to include (cc) byte
           CALL	INSERT                  ;Go make room to insert line into user program buffer
           MVI	L,OFS_TEMP_F0            ;Reset memory pointer to program buffer
           MVI	H,HIGH OLDPG26           ;** Line pointer storage location
           MOV	D,M                      ;Load higher byte into CPU register D
           INR	L                        ;Advance memory pointer
           MOV	E,M                      ;Load low order byte into CPU register E
           MVI	L,OFS_LINE_INP_BUF       ;Load L with address of start of line input buffer
           MVI	H,HIGH OLDPG26           ;** Do same for CPU register H
           CALL	MOVEC                   ;Call subroutine to Insert line in input buffer into the
           JMP	EXEC1                    ;User program buffer then go back to start of EXEC.
MOVEC:	MOV	B,M                          ;Fetch length of string in line input buffer
           INR	B                        ;Increment that value to provide for (cc)
MOVEPG:	MOV	A,M                         ;Fetch character from line input buffer
           CALL	ADV                     ;Advance pointer for line input buffer
           CALL	SWITCH                  ;Switch memory pointer to point to user pgm buffer
           MOV	M,A                      ;Deposit character fm input buff into user pgm buff
           CALL	ADV                     ;Advance pointer for user program buffer
           CALL	SWITCH                  ;Switch memory pntr back to point to input buffer
           DCR	B                        ;Decrement character counter stored in CPU register B
           JNZ	MOVEPG                   ;If counter does not go to zero continue transfer ops
           RET                          ;When counter equals zero return to calling routine
CONTIN:	MVI	L,OFS_TEMP_F0                      ;Reset memory pointer to program buffer
           MVI	H,HIGH OLDPG26           ;** Line pointer storage location
           MOV	D,M                      ;Load high order byte into CPU register D
           INR	L                        ;Advance memory pointer
           MOV	E,M                      ;Load low order byte into CPU register E
           MOV	H,D                      ;Now set CPU register H to high part of address
           MOV	L,E                      ;And set CPU register L to low part of address
           MOV	B,M                      ;Fetch the character counter (cc) byte fm line in
           INR	B                        ;Program buffer and add one to compensate for (cc)
           CALL	ADBDE                   ;Add length of line value to old value to get new pointer
           MVI	L,OFS_TEMP_F0                   ;Reset memory pointer to program buffer
           MVI	H,HIGH OLDPG26           ;** Line pointer storage location
           MOV	M,D                      ;Restore new high portion
           INR	L                        ;Advance memory pointer
           MOV	M,E                      ;And restore new low portion
           JMP	GETAUX                   ;Continue til find point at which to enter new line
GETCHP:	MVI	H,HIGH OLDPG26              ;** Load H with pointer page (low portion set upon
           MOV	B,M                      ;Entry). Now fetch pointer into CPU register B.
           MVI	L,OFS_TEMP_F0                   ;Reset pntr to pgm buffer line pointer storage location
           MOV	D,M                      ;Load high order byte into CPU register D
           INR	L                        ;Advance memory pointer
           MOV	E,M                      ;Load low order byte into CPU register E
           CALL	ADBDE                   ;Add pointer to pgm buffer pointer to obtain address of
           MOV	H,D                      ;Desired character. Place high part of new addr in H.
           MOV	L,E                      ;And low part of new address in E.
           MOV	A,M                      ;Fetch character from position in line in user pgm buffer
           CPI	0A0H                     ;See if it is the ASCII code for space
           RET                          ;Return to caller with flags set to indicate result
REMOVE:	CALL	INDEXB                     ;Add (cc) plus one to addr of start of line
           MOV	C,M                      ;Obtain byte from indexed location and
           CALL	SUBHL                   ;Subtract character count to obtain old location
           MOV	M,C                      ;Put new byte in old location
           MOV	A,C                      ;As well as in the Accumulator
           ANA	A                        ;Test to see if zero byte to indicate end of user pgm buff
           JZ	REMOV1                    ;If it is end of user pgm buffer, go complete process
           CALL	ADV                     ;Otherwise add one to the present pointer value
           JMP	REMOVE                   ;And continue removing chamcters from the user pgm bf
REMOV1:	MVI	L,OFS_TEMP_F4                      ;Load L with end of user pgm buffer pointer storage loc
           MVI	H,HIGH OLDPG26           ;** Load H with page of that pointer storage location
           MOV	D,M                      ;Get page portion of end of pgm buffer address
           INR	L                        ;Advance memory pointer
           MOV	A,M                      ;And get low portion of end of pgm buffer address into
           SUB	B                        ;Accumulator then subtract displacement value in B
           MOV	M,A                      ;Restore new low portion of end of pgm buffer address
           RNC                          ;If subtract did not cause carry can return now
           DCR	L                        ;Otherwise decrement memory pointer back to page
           DCR	D                        ;Storage location, decrement page value to give new page
           MOV	M,D                      ;And store new page value back in buffer pntr storage loc
           RET                          ;Then return to calling routine
INSERT:	MVI	L,OFS_TEMP_F4                      ;Load L with end of user pgm buffer pointer storage loc
           MVI	H,HIGH OLDPG26           ;** Load H with page of that pointer storage location
           MOV	A,M                      ; Get page portion of end of program buffer address
           INR	L                        ;Advance memory pointer
           MOV	L,M                      ;Load low portion of end of program buffer address
           MOV	H,A                      ;Into L and finish setting up memory pointer
           CALL	INDEXB                  ;Add (cc) of line in input buffer to form new end of
           MOV	A,H                      ;Program buffer address. Fetch new end of buffer page
           CPI	ENDPGRAM                 ;tt Address and see if this value would exceed user's
           JP	BIGERR                    ;System capabilit'y. Go display error message if so!
           CALL	SUBHL                   ;Else restore original value of end of buffer address
INSER1:	MOV	C,M                         ;Bring byte pointed to by H & L into CPU register C
           CALL	INDEXB                  ;Add displacement value to current memory pointer
           MOV	M,C                      ;Store the byte in the new location
           CALL	SUBHL                   ;Now subtract displacement value from H & L
           CALL	CPHLDE                  ;Compare this with the address stored in D & E
           JZ	INSER3                    ;If same then go finish up Insert operation
           CALL	DEC                     ;Else set pointer to the byte before the byte just
           JMP	INSER1                   ;Processed and continue the Insert operation
INSER3:
INCLIN:	MVI	L,OFS_LINE_INP_BUF          ;Load L with start of line input buffer
           MVI	H,HIGH OLDPG26           ;** Load H with page of start of line input buffer
           MOV	B,M                      ;Fetch length of the line in line input buffer
           INR	B                        ;Increment value by one to include (cc) byte
           MVI	L,OFS_TEMP_F4                   ;Set memory pointer to end of user pgrn buffer pointer
           MOV	D,M                      ;Storage location on same page and fetch page address
           INR	L                        ;Of this pointer into D. Then advance memory pointer
           MOV	E,M                      ;And get low part of this pointer into CPU register E.
           CALL	ADBDE                   ;Now add displacement (cc) of line in input buffer to
           MOV	M,E                      ;The end of program buffer pointer. Replace the updated
           DCR	L                        ;Low portion of the new pointer value back in stomge
           MOV	M,D                      ;And restore the new page value back into storage
           RET                          ;Then return to calling routine
CPHLDE:	MOV	A,H                         ;Subroutine to compare if the contents of CPU registers
           CMP	D                        ;H & L are equal to registers D & E. First compare
           RNZ                          ;Register H to D. Return with flags set if not equal. If
           MOV	A,L                      ;Equal continue by comparing register L to E.
           CMP	E                        ;IF L equals E then H & L equal to D & E so return to
           RET                          ;Calling routines with flags set to equality status
ADBDE:	MOV	A,E                          ;Subroutine to add the contents of CPU register B (single
           ADD	B                        ;Byte value) to the double byte value in registers D & E.
           MOV	E,A                      ;First add B to E to form new least significant byte
           RNC                          ;Restore new value to E and exit if no carry resulted
           INR	D                        ;If had a carry then must increment most significant byte
           RET                          ;In register D before returning to calling routine
CTRLC:	MVI	A,0DEH                       ;Set up ASCII code for t (up arrow) in Accumulator.
           MVI	C,0C3H                   ;Set up ASCII code for letter 'C' in CPU register C.
           JMP	ERROR                    ;Go display the 'Control C' condition message.
FINERR:	MVI	L,OFS_LINENUM_BUF                      ;Load L with starting address of line number storage area
           MVI	H,HIGH OLDPG26           ;** Load H with page of line number storage area
           MOV	A,M                      ;Get (cc) for line number string. If length is zero meaning
           ANA	A                        ;There is no line number stored in the buffer then jump
           JZ	FINER1                    ;Ahead to avoid displaying "AT LINE" message
           MVI	L,OFS_TEMP_F6                   ;Else load L with address of start of "AT LINE" message
           MVI	H,HIGH OLDPG1            ;** Stored on this page
           CALL	TEXTC                   ;Call subroutine to display the "AT LINE" message
           MVI	L,OFS_LINENUM_BUF                   ;Now reset L to starting address of line number storage
           MVI	H,HIGH OLDPG26           ;** Area and do same for CPU register H
           CALL	TEXTC                   ;Call subroutine to display the line number
FINER1:	CALL	CRLF                       ;Call subroutine to provide a carriage-return and line-feed
	   JMP	PATCH3
;;; The following is the old code, before patch 3
;;;           JMP EXEC               ;To the display device then return to EXECUTIVE.
DVERR:	MVI	A,0C4H                       ;Set up ASCII code for letter 'D' in Accumulator
           MVI	C,0DAH                   ;Set up ASCII code for letter 'Z' in CPU register C
           JMP	ERROR                    ;Go display the 'DZ' (divide by zero) error message
FIXERR:	MVI	A,0C6H                      ;Set up ASCII code for letter 'F' in Accumulator
           MVI	C,0D8H                   ;Set up ASCII code for letter 'X' in CPU register C
           JMP	ERROR                    ;Go display the 'FX' (FiX) error message
NUMERR:	MVI	A,0C9H                      ;Set up ASCII code for letter 'I' in Accumulator
           MVI	C,0CEH                   ;Set up ASCII code for letter 'N' in CPU register C
           MVI	L,OFS_GETINP_CNT                   ;Load L with address of pointer used by DINPUT
           MVI	H,HIGH OLDPG1            ;** Routine. Do same for register H.
           MVI	M,000H                   ;Clear the location
           JMP	ERROR                    ;Go display the'IN'(Illegal Number) error message

                                  ;The following subroutine, used by various sections of
                                  ;SCELBAL, will search the LINE INPUT BUGGER for
                                  ;a character string which is contained in a buffer starting
                                  ;at the address pointed to by CPU registers H & L when
                                  ;the subroutine is entered.

INSTR:	MVI	D,HIGH OLDPG26               ;**Set D to starting page of LINE INPUT BUFFER
           MVI	E,OFS_LINE_INP_BUF                   ;Load E with starting location of LINE INPUT BUFFER
INSTR1:	CALL	ADVDE                      ;Advancer D & E pointer to the next location (input
           CALL	SAVEHL                  ;Buffer). Now save contents of d, E, H & L vefore the
           MOV	B,M                      ;Compare operations. Get length of TEST buffer in B.
           CALL	ADV                     ;Advance H & L buffer to first char in TEST buffer.
           CALL	STRCPC                  ;Compare contents of TEST buffer against input buffer
           JZ	RESTHL                    ;For length B. If match, restore pntrs and exit to caller.
           CALL	RESTHL                  ;If no match, restore pointers for loop test.
           MVI	L,OFS_LINE_INP_BUF                   ;Load L with start of input buffer (to get the char cntr).
           MVI	H,HIGH OLDPG26           ;**Load H with page of input buffer.
           MOV	A,M                      ;Get length of buffer (cc) into the accumulator.
           CMP	E                        ;Compare with current input buffer pointer value.
           JZ	INSTR2                    ;If at end of buffer, jump ahead.
           CALL	RESTHL                  ;Else restore test string address (H&L) and input buffer
           JMP	INSTR1                   ;Address (D&E). Look gor occurrence of test string in ln.
           HLT                          ;Safety halt. If program reaches here have system failure.
INSTR2:	MVI	E,OFS_LINE_INP_BUF                      ;If reach end of input buffer without finding a match
           RET                          ;Load E with 000 as an indicator and return to caller.
ADVDE:	INR	E                            ;Subroutine to advance the pointer in the register
           RNZ                          ;Pair D & E. Advance contents of E. Return if not zero.
           INR	D                        ;If register E goes to 0 when advanced, then advance
           RET                          ;Register D too. Exit to calling routine.

;;; The label RUN should start at 13-170
RUN:	MVI	L,OFS_GOSUB_STK_BASE                         ;Load L with addr of GOSUB/RETURN stack pointer
           MVI	H,HIGH OLDPG27           ;** Load H with page of same pointer
           MVI	M,000H                   ;Initialize the GOSUB/RETURN stack pointer to zero
           MVI	L,OFS_TEMP_085                   ;Load L with addr of FOR/NEXT stack pointer
           MVI	M,000H                   ;Initialize the FOR/NEXT stack pointer to zero
           MVI	L,OFS_TEMP_F0                   ;Load L with addr of user pgm buffer line pointer
           MVI	H,HIGH OLDPG26           ;** Load H with page of user pgm buffer line pointer
           MVI	M,BGNPGRAM               ;tt Initialize pointer (may be altered by user)   *******
           INR	L                        ;Advance memory pointer to low portion of user pgm
           MVI	M,000H                   ;Buffer pointer and initialize to start of buffer
           JMP	SAMLIN                   ;Start executing user program with first line in buffer
NXTLIN:	MVI	L,OFS_TEMP_F0                      ;Load L with addr of user program buffer line pointer
           MVI	H,HIGH OLDPG26           ;** Load H with page of user pgm buffer line pointer
           MOV	D,M                      ;Place page addr of pgm buffer line pointer in D
           INR	L                        ;Advance the memory pointer
           MOV	E,M                      ;Place low addr of pgm buffer line pointer in E
           MOV	H,D                      ;Also put page addr of pgm buffer line pointer in H
           MOV	L,E                      ;And low addr of pgm buffer line pointer in L
           MOV	B,M                      ;Now fetch the (cc) of current line into register B
           INR	B                        ;Add one to account for (cc) byte itself
           CALL	ADBDE                   ;Add value in B to D&E to point to next line in
           MVI	L,OFS_TEMP_F0                   ;User program buffer. Reset L to addr of user logrn
           MVI	H,HIGH OLDPG26           ;** Buffer pointer storage location. Store the new
           MOV	M,D                      ;Updated user pgm line pointer in pointer storage
           INR	L                        ;Location. Store both the high portion
           MOV	M,E                      ;And low portion. (Now points to next line to be
           MVI	L,OFS_LINENUM_BUF                   ;Processed from user program buffer.) Change pointer
           MVI	H,HIGH OLDPG26           ;** To address of line number buffer. Fetch the last
           MOV	A,M                      ;Line number (length) processed. Test to see if it was
           ANA	A                        ;Blank. If it was blank
           JZ	EXEC                      ;Then stop processing and return to the Executive
           MOV	A,A                      ;Insert two effective NOPs here
           MOV	A,A                      ;In case of patching
SAMLIN:	MVI	L,OFS_TEMP_F0                      ;Load L with addr of user program buffer line pointer
           MVI	H,HIGH OLDPG26           ;** Load H with page of same pointer
           MOV	C,M                      ;Fetch the high portion of the pointer into register C
           INR	L                        ;Advance the memory pointer
           MOV	L,M                      ;Fetch the low portion of the pointer into register L
           MOV	H,C                      ;Now move the high portion into register H
           MVI	D,HIGH OLDPG26           ;** Set D to page of line input buffer
           MVI	E,OFS_LINE_INP_BUF                   ;Set E to address of start of line input buffer
           CALL	MOVEC                   ;Move the line ftom the user program buffer into the
           MVI	L,OFS_LINE_INP_BUF                   ;Line input buffer. Now reset the pointer to the start
           MVI	H,HIGH OLDPG26           ;** Of the line input buffer.
           MOV	A,M                      ;Fetch the first byte of the line input buffer (cc)
           ANA	A                        ;Test (cc) value to see if fetched a blank line
           JZ	EXEC                      ;If fetched a blank line, return to the Executive
           CALL	SYNTAX                  ;Else call subrtn to strip off line nr & set statement toke

DIRECT:	MVI	L,OFS_TOKEN_STORE                      ;Load L with address of syntax TOKEN storage location
           MVI	H,HIGH OLDPG26           ;** Load H with page of syntax TOKEN location
           MOV	A,M                      ;Fetch the TOKEN value into the accumulator
           CPI	001H                     ;Is it token value for REM statement? If so, ignore the
           JZ	NXTLIN                    ;Current line and go on to the next line in pgm buffer.
           CPI	002H                     ;Is it token value for IF statement?
           JZ	IF                        ;If yes, then go to the IF statement routine.
           CPI	003H                     ;Is it token value for LET statement? (Using keyword)
           JZ	LET                       ;If yes, then go to the LET statement routine.
           CPI	004H                     ;Is it token value for GOTO statement?
           JZ	GOTO                      ;If yes, then go to the GOTO statement routine.
           CPI	005H                     ;Is it token value for PRINT statement?
           JZ	PRINT                     ;If yes, then go to the PRINT statement routine.
           CPI	006H                     ;Is it token value for INPUT statement?
           JZ	INPUT                     ;If yes, then go to the INPUT statement routine.
           CPI	007H                     ;Is it token value for FOR statement?
           JZ	FOR                       ;If yes, then go to the FOR statement routine.
           CPI	008H                     ;Is it token value for NEXT statement?
           JZ	NEXT                      ;If yes, then go to the NEXT statement routine.
           CPI	009H                     ;Is it token value for GOSUB statement?
           JZ	GOSUB                     ;If yes, then go to the GOSUB statement routine.
           CPI	00AH                     ;Is it token value for RETURN statement?
           JZ	RETURN                    ;If yes, then go to the RETURN statement routine.
           CPI	00BH                     ;Is it token value for DIM statement?
           JZ	DIM                       ;If yes, then go to the DIM statement routine.
           CPI	00CH                     ;Is it token value for END statement?
           JZ	EXEC                      ;If yes, then go back to the Executive, user pgm finished!
           CPI	00DH                     ;Is it token value for IMPLIED LET statement?
           JZ	LET0                      ;If yes, then go to special LET entry point.
           CPI	00EH                     ;@@ Is it token value for ARRAY IMPLIED LET?
           JNZ	SYNERR                   ;If not, then assume a syntax error condition.
           CALL	ARRAY1                  ;@@ Else, perform array storage set up subroutine.
           MVI	L,OFS_ARRAY_SETUP                   ;@@ Set L to array pointer storage location.
           MVI	H,HIGH OLDPG26           ;@@ * * Set H to array pointer storage location.
           MOV	B,M                      ;@@ Fetch array pointer to register B.
           MVI	L,OFS_SCAN_PTR                   ;@@ Change memory pointer to syntax pntr storage loc.
           MOV	M,B                      ;@@ Save array pointer value there.
           CALL	SAVESY                  ;@@ Save array name in auxiliary symbol buffer
           JMP	LET1
PRINT:	MVI	L,OFS_SCAN_PTR                       ;Load L with address of SCAN pointer storage location
           MVI	H,HIGH OLDPG26           ;** Load H with page of SCAN pointer
           MOV	A,M                      ;Fetch the pointer value (last character scanned by the
           MVI	L,OFS_LINE_INP_BUF                   ;SYNTAX routine). Change pointer to line buffer (cc).
           CMP	M                        ;Compare pointer value to buffer length. If not equal
           JM	PRINT1                    ;Then line contains more than stand alone PRINT state-
           CALL	CRLF                    ;Ment. However, if just have PRINT statement then issue
           JMP	NXTLIN                   ;A carriage-return & line-feed combination, then exit.
PRINT1:	CALL	CLESYM                     ;Initialize the SYMBOL buffer for new entry.
           MVI	L,OFS_SCAN_PTR                   ;Load L with address of SCAN buffer pointer
           MVI	H,HIGH OLDPG26           ;** Load H with page of SCAN pointer
           MOV	B,M                      ;Pointer points to last char scanned by SYNTAX. Need
           INR	B                        ;To increment it to point to next char in statement line.
           MVI	L,OFS_TOKEN_STORE                   ;Load L with address of former TOKEN value. Use it as
           MOV	M,B                      ;Storage location for a PRINT statement pointer.
PRINT2:	MVI	L,OFS_TOKEN_STORE                      ;Set memory pointer to PRINT pointer storage location
           CALL	GETCHR                  ;Fetch character in input buffer pointed to by PRINT
           CPI	0A7H                     ;Pointer. See if it is ASCII code for single quote mark.
           JZ	QUOTE                     ;If so, go to QUOTE section to process text string.
           CPI	0A2H                     ;If not, see if it is ASCII code for double quote mark.
           JZ	QUOTE                     ;If so, go to QUOTE section to process text string.
           CPI	0ACH                     ;If not, see if it is ASCII code for comma sign.
           JZ	PRINT3                    ;If so, go evaluate expression.
           CPI	0BBH                     ;If not, see if it is ASCII code for semi-colon sign.
           JZ	PRINT3                    ;If so, go evaluate expression.
           MVI	L,OFS_TOKEN_STORE                   ;Load L with address of PRINT pointer storage location.
           CALL	LOOP                    ;Increment pointer and test for end of line.
           JNZ	PRINT2                   ;If not end of line, fetch the next character.
PRINT3:	MVI	L,OFS_SCAN_PTR                      ;Load L with address of SCAN pointer storage location
           MOV	B,M                      ;Fetch value of the pointer (last letter of KEYWORD)
           INR	B                        ;Add one to point to first character of expression
           MVI	L,OFS_EVAL_PTR                   ;Load L with addr of EVAL pointer storage location
           MOV	M,B                      ;Store addr at which EVAL should start scanning
           MVI	L,OFS_TOKEN_STORE                   ;Load L with address of PRINT pointer
           MOV	B,M                      ;Which points to field terminator
           DCR	B                        ;Decrement pointer value to last character of expression
           MVI	L,OFS_EVAL_FINISH                   ;Load L with address of EVAL FINISH pntr storage loc.
           MOV	M,B                      ;Place address value of last char in PRINT field there
           MVI	L,OFS_TEMP_F7                   ;Load L with address of QUOTE flag
           MOV	A,M                      ;Fetch the value of the QUOTE flag into the ACC
           ANA	A                        ;Test the QUOTE flag status
           JZ	PRINT4                    ;If field not quoted, proceed to evaluate expression
           MVI	M,000H                   ;If field quoted, then clear the QUOTE flag for next field
           JMP	PRINT6                   ;And skip the evaluation procedure
PRINT4:	CALL	EVAL                       ;Evaluate the current PRINT field
           MVI	L,OFS_TAB_FLAG                   ;Then load L,with address of the TAB flag
           MVI	H,HIGH OLDPG26           ;** Load H with the page of the TAB flag
           MOV	A,M                      ;Fetch the value of the TAB flag into the accumulator
           ANA	A                        ;Test the TAB flag
           MVI	L,OFS_FP_MODE_IND                   ;Change L to the FIXED/FLOAT flag location
           MVI	H,HIGH OLDPG1            ;** Change H to the FIXED/FLOAT flag page
           MVI	M,0FFH                   ;Set FIXED/FLOAT flag to fixed point
PRINT5:	CZ	PFPOUT                       ;If TAB flag not set, display value of expression
           MVI	L,OFS_TAB_FLAG                   ;Load L with address of TAB flag
           MVI	H,HIGH OLDPG26           ;** Load H with page of TAB flag
           MVI	M,000H                   ;Reset TAB flag for next PRINT field
PRINT6:	MVI	L,OFS_TOKEN_STORE                      ;Load L with address of PRINT pointer stomge location
           CALL	GETCHR                  ;Fetch the character pointed to by the PRINT pointer
           CPI	0ACH                     ;See if the last character scanned was a comma sign
           CZ	PCOMMA                    ;If so, then display spaces to next TA.B location
           MVI	L,OFS_TOKEN_STORE                   ;Reset L to address of PRINT pointer storage location
           MVI	H,HIGH OLDPG26           ;** Reset H to page of PRINT pointer stomge location
           MOV	B,M                      ;Fetch the value of the pointer into register B
           MVI	L,OFS_SCAN_PTR                   ;Change L to SCAN pointer storage location
           MOV	M,B                      ;Place end of last field processed into SCAN pointer
           MVI	L,OFS_LINE_INP_BUF                   ;Change pointer to start of line input buffer
           MOV	A,B                      ;Place pntr to last char scanned into the accumulator
           CMP	M                        ;Compare this value to the (cc) for the line buffer
           JM	PRINT1                    ;If not end of line, continue to process next field
           MVI	L,OFS_LINE_INP_BUF                   ;If end of line, fetch the last character in the line
           CALL	GETCHR                  ;And check to see if it
           CPI	0ACH                     ;Was a comma. If it was, go on to the next line in the
           JZ	NXTLIN                    ;User program buffer without displaying a CR & LF.
           CPI	0BBH                     ;If not a comma, check to see if it was a semi-colon.
           JZ	NXTLIN                    ;If so, do not provide a CR & LF combination.
           CALL	CRLF                    ;If not comma or semi-colon, provide CR & LF at end
           JMP	NXTLIN                   ;Of a PRINT statement. Go process next line of pgrm.
QUOTE:	MVI	L,OFS_TEMP_F7                       ;Load L with address of QUOTE flag
           MOV	M,A                      ;Store type of quote in flag storage location
           CALL	CLESYM                  ;Initialize the SYMBOL buffer for new entry
           MVI	L,OFS_TOKEN_STORE                   ;Load L with address of PRINT pointer
           MOV	B,M                      ;Fetch the PRINT pointer into register B
           INR	B                        ;Add one to advance over quote character
           MVI	L,OFS_TEMP_ARRAY                   ;Load L with address of QUOTE pointer
           MOV	M,B                      ;Store the beginning of the QUOTE field pointer
QUOTE1:	MVI	L,OFS_TEMP_ARRAY                      ;Load L with address of QUOTE pointer
           CALL	GETCHR                  ;Fetch the next character in the TEXT field
           MVI	L,OFS_TEMP_F7                   ;Load L with the QUOTE flag (type of quote)
           CMP	M                        ;Compare to see if latest character this quote mark
           JZ	QUOTE2                    ;If so, finish up this quote field
           CALL	ECHO                    ;If not, display the character as part of TEXT
           MVI	L,OFS_TEMP_ARRAY                   ;Reset L to QUOTE pointer storage location
           CALL	LOOP                    ;Increment QUOTE pointer and test for end of line
           JNZ	QUOTE1                   ;If not end of line, continue processing TEXT field
QUOTER:	MVI	A,0C9H                      ;If end of line before closing quote mark have an error
           MVI	C,0D1H                   ;So load ACC with I and register C with Q
           MVI	L,OFS_TEMP_F7                   ;Load L with the address of the QUOTE flag
           MVI	H,HIGH OLDPG26           ;** Load H with the page of the QUOTE flag
           MVI	M,000H                   ;Clear the QUOTE flag for future use
           JMP	ERROR                    ;Go display the IQ (Illegal Quote) error message
QUOTE2:	MVI	L,OFS_TEMP_ARRAY                      ;Load L with address of QUOTE pointer
           MOV	B,M                      ;Fetch the QUOTE pointer into register B
           MVI	L,OFS_SCAN_PTR                   ;Load L with address of SCAN pointer storage location
           MOV	M,B                      ;Store former QUOTE vointer as start of next field
           MOV	A,B                      ;Place QUOTE pointer into the accumulator
           MVI	L,OFS_LINE_INP_BUF                   ;Change L to point to start of the input line buffer
           CMP	M                        ;Compare QUOTE pointer value with (cc) value
           JNZ	PRINT1                   ;If not end of line, process next PRINT field
           CALL	CRLF                    ;Else display a CR & LF combination at the end of line
           MVI	L,OFS_TEMP_F7                   ;Load L with the address of the TAB flag
           MVI	H,HIGH OLDPG26           ;** Load H with the page of the TAB flag
           MVI	M,000H                   ;Clear the TAB flag for future use
           JMP	NXTLIN                   ;Go process next line of the program.

                                  ;The following subroutines are utilized by the PRINT
                                  ;routine.
;;; The label PFPOUT SHOULD BE AT 14 314
PFPOUT:	MVI	L,OFS_FPACC_MSW                      ;Load L with the address of the FPACC MSW (Floating
           MVI	H,HIGH OLDPG1            ;** Point ACC). Load H with page of the FPACC MSW.
           MOV	A,M                      ;Fetch the FPACC MSW into the accumulator. Test to
           ANA	A                        ;See if the FPACC MSW is zero. If so, then simply go and
           JZ	ZERO                      ;Display the value "0"
           INR	L                        ;Else advance the pointer to the FPACC Exponent
           MOV	A,M                      ;Fetch the FPACC Exponent into the accumulator
           ANA	A                        ;See if any exponent value. If not, mantissa is in range
           JZ	FRAC                      ;0.5 to 1.0. Treat number as a fraction.
           JMP	FPOUT                    ;Else perform regular numerical output routine.
ZERO:	MVI	A,0A0H                        ;Load ASCII code for space into the ACC
           CALL	ECHO                    ;Display the space
           MVI	A,0B0H                   ;Load ASCII code for 0 into the ACC
           JMP	ECHO                     ;Display 0 and exit to calling routine
FRAC:	MVI	L,OFS_FP_MODE_IND                        ;Load L with address of FIXED/FLOAT flag
           MVI	M,000H                   ;Reset it to indicate floating point mode
           JMP	FPOUT                    ;Display floating point number and return to caller
PCOMMA:	MVI	L,OFS_LINE_INP_BUF                      ;Load L with address of (cc) in line input buffer
           MOV	A,M                      ;Fetch the (cc) for the line into the ACC
           MVI	L,OFS_TOKEN_STORE                   ;Change pointer to PRINT pointer storage location
           SUB	M                        ;Subtract value of PRINT pointer from line (cc)
           RM                           ;If at end of buffer, do not TAB
           MVI	L,OFS_COL_COUNTER                   ;If not end, load L with address of COLUMN COUNTER
           MVI	H,HIGH OLDPG1            ;** Set H to page of COLUMN COUNTER
           MOV	A,M                      ;Fetch COLUMN COUNTER into the accumulator
           ANI	0F0H                     ;Find the last TAB position (multiple of 16 decimal)
           ADI	010H                     ;Add 16 (decimal) to get new TAB position
           SUB	M                        ;Subtract current position from next TAB position
           MOV	C,A                      ;Store this value in register C as a counter
           MVI	A,0A0H                   ;Load the ACC with the ASCII code for space
PCOM1:	CALL	ECHO                        ;Display the space
           DCR	C                        ;Decrement the loop counter
           JNZ	PCOM1                    ;Continue displaying spaces until loop counter is zero
           RET                          ;Then return to calling routine
LET0:	CALL	SAVESY                       ;Entry point for IMPLIED LET statement. Save the
           MVI	L,OFS_SCAN_PTR                   ;Variable (to left of the equal sign). Set L to the SCAN
           MVI	H,HIGH OLDPG26           ;** Pointer. Set H to the page of the SCAN pointer.
           MOV	B,M                      ;Fetch value of SCAN pointer. (Points to = sign in In bf)
           MVI	L,OFS_TOKEN_STORE                   ;Change pointer to LET pointer (was TOKEN value)
           MOV	M,B                      ;Place the SCAN pointer value into the LET pointer
           JMP	LET5                     ;Continue processing the LET statement line
LET:	CALL	CLESYM                        ;Initialize the SYMBOL BUFFER for new entry
           MVI	L,OFS_FP_WORK+4                   ;Load L with address of start of AUX SYMBOL BUFF
           MVI	H,HIGH OLDPG26           ;** Load H with page of AUX SYMBOL BUFFER
           MVI	M,000H                   ;Initialize AUX SYMBOL BUFFER
LET1:	MVI	L,OFS_SCAN_PTR                        ;Entry point for ARRAY IMPLIED LET statement.
           MVI	H,HIGH OLDPG26           ;** Set pointer to SCAN pointer storage location
           MOV	B,M                      ;Fetch the SCAN pointer value (last letter scanned by
           INR	B                        ;SYNTAX subroutine) and add one to next character
           MVI	L,OFS_TOKEN_STORE                   ;Change L to LET pointer storage location
           MOV	M,B                      ;Store former SCAN value (updated) in LET pointer
LET2:	MVI	L,OFS_TOKEN_STORE                        ;Set L to gtorage location of LET pointer
           CALL	GETCHR                  ;Fetch the character pointed to by the LET pointer
           JZ	LET4                      ;If character is a space, ignore it
           CPI	0BDH                     ;See if character is the equal (=) sign
           JZ	LET5                      ;If so, go process other side of the statement (after
           CPI	0A8H                     ;@@ If not, see if character is a right parenthesis
           JNZ	LET3                     ;If not, continue looking for equal sign
           CALL	ARRAY                   ;@@ If so, have subscript. Call array set up subroutine.
           MVI	L,OFS_ARRAY_SETUP                   ;@@ Load L with address of ARRAY pointer
           MVI	H,HIGH OLDPG26           ;@@ ** Load H with page of ARRAY pointer
           MOV	B,M                      ;@@ Fetch value (points to ")" character of subscript)
           MVI	L,OFS_TOKEN_STORE                   ;@@ Load L with address of LET pointer
           MOV	M,B                      ;@@ Place ARRAY pointer value as new LET pointer
           JMP	LET4                     ;@@ Continue to look for = sign in statement line
LET3:	MVI	L,OFS_FP_WORK+4                        ;Reset L to start of AUX SYMBOL BUFFER
           MVI	H,HIGH OLDPG26           ;** Load H with page of AUX SYMBOL BUFFER
           CALL	CONCT1                  ;Concatenate character to the AUX SYMBOL BUFFER
LET4:	MVI	L,OFS_TOKEN_STORE                        ;Load L with address of LET pointer storage location
           CALL	LOOP                    ;Add one to pointer and test for end of line input buffer
           JNZ	LET2                     ;If not end of line, continue looking for the equal sign
LETERR:	MVI	A,0CCH                      ;If do not find an equal sign in the LET statement line
           MVI	C,0C5H                   ;Then have a LE (Let Error). Load the code for L and E
           JMP	ERROR                    ;Into registers ACC and C and go display the error msg.
LET5:	MVI	L,OFS_TOKEN_STORE                        ;When find the equal sign, reset L to point to the LET
           MVI	H,HIGH OLDPG26           ;** Pointer and H to the proper page. Fetch the pointer
           MOV	B,M                      ;Value into register B and add one to advance pointer
           INR	B                        ;Over the equal sign to first char in the expression.
           MVI	L,OFS_EVAL_PTR                   ;Set L to point to the address of the EVAL pointer
           MOV	M,B                      ;Set EVAL pointer to start evaluating right after the
           MVI	L,OFS_LINE_INP_BUF                   ;Equal sign. Now change L to start of line input buffer.
           MOV	B,M                      ;Fetch the (cc) value into register B. (Length of line.)
           MVI	L,OFS_EVAL_FINISH                   ;Load L with EVAL FINISH pointer storage location.
           MOV	M,B                      ;Set it to stop evaluating at end of the line.
           CALL	EVAL                    ;Call the subroutine to evaluate the expression.
           CALL	RESTSY                  ;Restore the name of the variable to receive new value.
           CALL	STOSYM                  ;Store the new value for the variable in variables table.
           JMP	NXTLIN                   ;Go process next line of the program.
GOTO:	MVI	L,OFS_AUX_LINENUM                        ;Load L with start of AUX LINE NR BUFFER
           MVI	H,HIGH OLDPG26           ;** Load H with page of AUX LINE NR BUFFER
           MVI	M,000H                   ;Initialize the AUX LINE NR BUFFER to zero
           MVI	L,OFS_SCAN_PTR                   ;Load L with address of SCAN pointer storage location
           MOV	B,M                      ;Fetch pointer value (last char scanned by SYNTAX)
           INR	B                        ;Add one to skip over the last 0 in GOTO keyword
           MVI	L,OFS_TOKEN_STORE                   ;Change pointer to GOTO pointer (formerly TOKEN)
           MOV	M,B                      ;Store the updated SCAN pointer as the GOTO pointer
GOTO1:	MVI	L,OFS_TOKEN_STORE                       ;Load L with address of GOTO pointer
           CALL	GETCHR                  ;Fetch the character pointed to by the GOTO pointer
           JZ	GOTO2                     ;If character was a space, ignore it
           CPI	0B0H                     ;See if character is in the range of a decimal digit
           JM	GOTO3                     ;If not, must have end of the line number digit string
           CPI	0BAH                     ;Continue to test for decitnal digit
           JP	GOTO3                     ;If not, mugt have end of the line number digit string
           MVI	L,OFS_AUX_LINENUM                   ;If valid decimal digit, load L with addr of AUX LINE
           CALL	CONCT1                  ;NR BUFFER and concatenate digit to the buffer.
GOTO2:	MVI	L,OFS_TOKEN_STORE                       ;Reset pointer to GOTO pointer storage location
           CALL	LOOP                    ;Advance the pointer value and test for end of line
           JNZ	GOTO1                    ;If not end of line, fetch next digit in GOTO line number
GOTO3:	MVI	L,OFS_TEMP_F0                       ;Set L to user program buffer pointer storage location
           MVI	H,HIGH OLDPG26           ;** Set H to page of program buffer pointer
           MVI	M,BGNPGRAM               ;Initialize high part of pointer to start of pgm buffer
           INR	L                        ;Advance the memory point
           MVI	M,000H                   ;Initialize the low part of pointer to start of pgm buffer
GOTO4:	CALL	CLESYM                      ;Clear the SYMBOL BUFFER
           MVI	L,OFS_TEMP_ARRAY                   ;Load L with address of GOTO SEARCH pointer
           MVI	M,001H                   ;Initialize to one for first char of line
GOTO5:	MVI	L,OFS_TEMP_ARRAY                       ;Load L with address of GOTO SEARCH pointer
           CALL	GETCHP                  ;Fetch character pointed to by GOTO SEARCH pointer
           JZ	GOTO6                     ;From line pointed to in user program buffer. Ignore
           CPI	0B0H                     ;Spaces. Check to see if character is a decirnal digit.
           JM	GOTO7                     ;If not, then have processed line number at the start of
           CPI	0BAH                     ;The current line. Continue the check for a valid decimal
           JP	GOTO7                     ;Digit. If have a decirnal digit then concatenate the digit
           CALL	CONCTS                  ;Onto the current string in the SYMBOL BUFFER,
GOTO6:	MVI	L,OFS_TEMP_ARRAY                       ;Change L to the address of the GOTO SEARCH pointer
           MVI	H,HIGH OLDPG26           ;** And H to the proper page of the pointer
           MOV	B,M                      ;Fetch the GOTO SEARCH pointer value
           INR	B                        ;Increment the GOTO SEARCH pointer
           MOV	M,B                      ;And restore it back to memory
           MVI	L,OFS_TEMP_F0                   ;Change L to address of user program buffer pointer
           MOV	C,M                      ;Save the high part of this pointer value in register C
           INR	L                        ;Advance L to the low part of the pgrn buffer pointer
           MOV	L,M                      ;Now load it into L
           MOV	H,C                      ;And transfer C into H to point to start of the line
           MOV	A,M                      ;Fetch the (cc) of the current line being pointed to in the
           DCR	B                        ;User pgm buff. Decrernent B to previous value. Compare
           CMP	B                        ;GOTO SEARCH pointer value to length of current line.
           JNZ	GOTO5                    ;If not end of line then continue getting current line nr.
GOTO7:	MVI	L,OFS_SYMBOL_BUF                       ;Load L with address of start of the SYMBOL BUFFER
           MVI	H,HIGH OLDPG26           ;Set H to the page of the SYMBOL BUFFER
           MVI	D,HIGH OLDPG26           ;Set D to the page of the AUX LINE NR BUFFER
           MVI	E,OFS_AUX_LINENUM                   ;Set E to the start of the AUX LINE NR BUFFER
           CALL	STRCP                   ;Compare GOTO line number against current line nr.
           JZ	SAMLIN                    ;If they match, found GOTO line. Pick up ops there!
           MVI	L,OFS_TEMP_F0                   ;Else, set L to user program buffer pntr storage location
           MVI	H,HIGH OLDPG26           ;** Set H to page of user program buffer pointer
           MOV	D,M                      ;Fetch the high part of this pointer into register D
           INR	L                        ;Advance the memory pointer
           MOV	E,M                      ;Fetch the low part into register E
           MOV	H,D                      ;Transfer the pointer to H
           MOV	L,E                      ;And L. Fetch the (cc) of the current line into register
           MOV	B,M                      ;B and then add one to account for the (cc) byte to get
           INR	B                        ;Total length of the current line in the user pgm buffer
           CALL	ADBDE                   ;Add the total length to the pointer value in D & E
           MVI	L,OFS_TEMP_F0                   ;To get the starting address of the next line in the user
           MVI	H,HIGH OLDPG26           ;** User program buffer. Place the new value for the user
           MOV	M,D                      ;Program buffer pointer back into the user program
           INR	L                        ;Buffer pointer storage locations so that it points to the
           MOV	M,E                      ;Next line to be processed in the user program buffer.
           MVI	L,OFS_TEMP_F4                   ;Load L with address of end of user pgm buffer storage
           MOV	A,D                      ;Location (page address) and fetch end of buffer page.
           CMP	M                        ;Compare this with next line pointer (updated).
           JNZ	GOTO4                    ;If not end of buffer, keep looking for the specified line
           INR	L                        ;If have same page addresses, check the low address
           MOV	A,E                      ;Portions to see if
           CMP	M                        ;Have reached end of user program buffer
           JNZ	GOTO4                    ;If not, continue looking. If end of buffer without
GOTOER:	MVI	A,0D5H                      ;Finding specified line, then have an error condition.
           MVI	C,0CEH                   ;Load ACC and register C with code for "UN" and go
           JMP	ERROR                    ;Display "Undefined Line" error message.
IF:	MVI	L,OFS_SCAN_PTR                          ;Set L to SCAN pointer storage location.
           MVI	H,HIGH OLDPG26           ;** Load H to page of SCAN pointer storage location.
           MOV	B,M                      ;Fetch the SCAN pointer value to register B.
           INR	B                        ;Add one to advance pointer over last char scanned.
           MVI	L,OFS_EVAL_PTR                   ;Change L to address of EVAL pointer. Set up EVAL
           MOV	M,B                      ;Pointer to begin evaluation with next char in the line.
           CALL	CLESYM                  ;Clear the SYMBOL BUFFER.
           MVI	L,OFS_KW_THEN                   ;Set L to starting address of THEN in look-up table.
           MVI	H,HIGH OLDPG1            ;** Set H to page of the look-up table.
           CALL	INSTR                   ;Search for occurrence of THEN in the line input buffer.
           MOV	A,E                      ;Transfer register E to ACC. If THEN not found
           ANA	A                        ;The value in E will be zero.
           JNZ	IF1                      ;If THEN found, can evaluate the IF expression.
           MVI	L,OFS_EXP_COUNTER                   ;If THEN not found, set L to Auting address of GOTO
           MVI	H,HIGH OLDPG27           ;** In the KEYWORD look-up table. Set H to table
           CALL	INSTR                   ;Search for occurrence of GOTO in the line input buffer.
           MOV	A,E                      ;Transfer E to ACC. If GOTO not found
           ANA	A                        ;The value in E will be zero.
           JNZ	IF1                      ;If GOTO found, can evaluate the IF expression.
IFERR:	MVI	A,0C9H                       ;Set ASCII code for letter I in ACC
           MVI	C,0C6H                   ;And code for letter F in register C
           JMP	ERROR                    ;Go display the IF error message
IF1:	MVI	L,OFS_EVAL_FINISH                         ;Load L with addr of EVAL FINISH pointer storage loc
           MVI	H,HIGH OLDPG26           ;** Load H with page of storage location
           DCR	E                        ;Subtract one from pointer in E and set the EVAL
           MOV	M,E                      ;FINISH pointer so that it will evaluate up to the THEN
           CALL	EVAL                    ;Or GOTO directive. Evaluate the expression.
           MVI	L,OFS_FPACC_MSW                   ;Load L with address of FPACC Most Significant Word
           MVI	H,HIGH OLDPG1            ;** Load H with page of FPACC MSW
           MOV	A,M                      ;Fetch the FPACC MSW into the accumulator
           ANA	A                        ;Test the value of the FPACC MSW
           JZ	NXTLIN                    ;If it is zero, IF condition failed, ignore rest of line.
           MVI	L,OFS_EVAL_FINISH                   ;If not, load L with addr of EVAL FINISH pointer
           MVI	H,HIGH OLDPG26           ;** Set H to the appmpriate page
           MOV	A,M                      ;Fetch the value in the EVAL FINISH pointer
           ADI	005H                     ;Add five to skip over THEN or GOTO directive
           MVI	L,OFS_SCAN_PTR                   ;Change L to SCAN pointer stomge location
           MOV	M,A                      ;Set up the SCAN pointer to location after THEN or
           MOV	B,A                      ;GOTO directive. Also put this value in register B.
           INR	B                        ;Add one to the value in B to point to next character
           MVI	L,OFS_TEMP_ARRAY                   ;After THEN or GOTO. Change L to addr of THEN pntr
           MOV	M,B                      ;Storage location and store the pointer value.
IF2:	MVI	L,OFS_TEMP_ARRAY                         ;Load L with the address of the THEN pointer
           CALL	GETCHR                  ;Fetch the character pointed to by the THEN pointer
           JNZ	IF3                      ;If character is not a space, exit this loop
           MVI	L,OFS_TEMP_ARRAY                   ;If fetch a space, ignore. Reset L to the THEN pointer
           CALL	LOOP                    ;Add one to the THEN pointer and test for end of line
           JNZ	IF2                      ;If not end of line, keep looking for a character other
           JMP	IFERR                    ;Than a space. If reach end of line first, then error
IF3:	CPI	0B0H                           ;When find a character see if it is numeric.
           JM	IF4                       ;If not numeric, then should have a new type of
           CPI	0BAH                     ;Statement. If numeric, then should have a line number.
           JM	GOTO                      ;So process as though have a GOTO statement!
IF4:	MVI	L,OFS_LINE_INP_BUF                         ;Load L with addr of start of line input buffer.
           MOV	A,M                      ;Fetch the (cc) byte to get length of line value.
           MVI	L,OFS_TEMP_ARRAY                   ;Change L to current value of THEN pointer (where first
           SUB	M                        ;Non-space char. found after THEN or GOTO). Subtract
           MOV	B,A                      ;This value from length of line to get remainder. Now
           INR	B                        ;Have length of second statement portion. Add one for
           MOV	C,M                      ;(cc) count. Save THEN pointer value in register C.
           MVI	L,OFS_LINE_INP_BUF                   ;Reset L to start of line input buffer. Now put length of
           MOV	M,B                      ;Second statement into (cc) position of input buffer.
           MOV	L,C                      ;Set L to where second statement starts.
           MVI	D,HIGH OLDPG26           ;** Set D to page of line input buffer.
           MVI	E,001H                   ;Set E to first character position of line input buffer.
           CALL	MOVEIT                  ;Move the second statement up in line to become first!
           MVI	L,OFS_SCAN_PTR                   ;Load L with address of new SCAN pointer. Load
           MVI	M,001H                   ;It with starting position for SYNTAX scan.
           CALL	SYNTX4                  ;Use special entry to SYNTAX to get new TOKEN value.
           JMP	DIRECT                   ;Process the second statement in the original line.
GOSUB:	MVI	L,OFS_LINENUM_BUF                       ;Load L with start of LINE NUMBER BUFFER
           MVI	H,HIGH OLDPG26           ;Fetch (cc) of cuffent line number into register D
           MOV	D,M                      ;Fetch high value (page) of pgm line pointer to D
           INR	D                        ;Test contents of register by first incrementing
           DCR	D                        ;And then decrementing the value in the register
           JZ	GOSUB1                    ;If no line number, then processing a DIRECT statement
           MVI	L,OFS_TEMP_F0                   ;Else, load L with address of user pgm buff line pointer
           MOV	D,M                      ;Fetch high value (page) of pgm line pointer to D
           INR	L                        ;Advance the memory pointer
           MOV	E,M                      ;Fetch the low part of pgm line pointer to E
GOSUB1:	MVI	L,OFS_GOSUB_STK_BASE                      ;Set L to address of GOSUB STACK POINTER
           MVI	H,HIGH OLDPG27           ;** Set H to page of GOSUB STACK POINTER
           MOV	A,M                      ;Fetch value in GOSUB stack pointer to ACC
           ADI	002H                     ;Add two to current stack pointer for new data to be
           CPI	011H                     ;Placed on the stack and see if stack overflows
           JP	GOSERR                    ;If stack filled, have an error condition
           MOV	M,A                      ;Else, store updated stack pointer
           MVI	L,OFS_ARRAY_TEMP                   ;Load L with address of start of stack less offset (2)
           ADD	L                        ;Add GOSUB stack pointer to base address
           MOV	L,A                      ;To get pointer to top of stack (page byte)
           MOV	M,D                      ;Store page part of pgm buffer line pointer in stack
           INR	L                        ;Advance pointer to next byte in stack
           MOV	M,E                      ;Store low part of pgm buffer line pointer in stack
           JMP	GOTO                     ;Proceed from here as though processing a GOTO
RETURN:	MVI	L,OFS_GOSUB_STK_BASE                      ;Set L to address of GOSUB STACK POINTER
           MVI	H,HIGH OLDPG27           ;** Set H to page of GOSUB STACK POINTER
           MOV	A,M                      ;Fetch the value of GOSUB stack pointer to ACC
           SUI	002H                     ;Subtract two for data to be removed from stack
           JM	RETERR                    ;If stack underflow, then have an error condition
           MOV	M,A                      ;Restore new stack pointer to memory
           ADI	002H                     ;Add two to point to previous top of stack
           MVI	L,OFS_ARRAY_TEMP                   ;Load L with address of start of GOSUB stack less two
           ADD	L                        ;Add address of previous top of stack to base value
           MOV	L,A                      ;Set pointer to high address value in the stack
           MOV	D,M                      ;Fetch the high address value from stack to register D
           INR	D                        ;Exercise the register contents to see if high address
           DCR	D                        ;Obtained is zero. If so, original GOSUB statement was
           JZ	EXEC                      ;A DIRECT statement. Must return to Executive!
           INR	L                        ;Else, advance pointer to get low address value from the
           MOV	E,M                      ;Stack into CPU register E.
           MVI	L,OFS_TEMP_F0                   ;Load L with address of user pgm line pointer storage
           MVI	H,HIGH OLDPG26           ;** Location. Load H with page of user pgm line pntr.
           MOV	M,D                      ;Put high address from stack into pgm line pointer.
           INR	L                        ;Advance the memory pointer
           MOV	M,E                      ;Put low address from stack into pgrn line pointer.
           JMP	NXTLIN                   ;Execute the next line after originating GOSUB line!
GOSERR:	MVI	A,0C7H                      ;Load ASCII code for letter G into accumulator
           MVI	C,0D3H                   ;Load ASCII code for letter S into register C
           JMP	ERROR                    ;Go display GoSub (GS) error message.
RETERR:	MVI	A,0D2H                      ;Load ASCII code for letter R into accumulator
           MVI	C,0D4H                   ;Load ASCII code for letter T into register C
           JMP	ERROR                    ;Go display ReTurn (RT) error message.
INPUT:	CALL	CLESYM                      ;Clear the SYMBOL BUFFER
           MVI	L,OFS_SCAN_PTR                   ;Load L with address of SCAN pointer storage location
           MOV	B,M                      ;Fetch value of SCAN pointer to register B
           INR	B                        ;Increment value to point to next chamcter
           MVI	L,OFS_TOKEN_STORE                   ;Change L to point to INPUT pointer (formerly TOKEN)
           MOV	M,B                      ;Updated SCAN pointer becomes INPUT pointer
INPUT1:	MVI	L,OFS_TOKEN_STORE                      ;Load L with address of INPUT pointer
           CALL	GETCHR                  ;Fetch a character from the line input buffer
           JZ	INPUT3                    ;If character is a space, ignore it. Else,
           CPI	0ACH                     ;See if character is a comma. If so, process the
           JZ	INPUT4                    ;Variable that preceeds the comma.
           CPI	0A8H                     ;If not, see if character is a left parenthesis.
           JNZ	INPUT2                   ;If not, continue processing to build up symbolic variable
           CALL	ARRAY2                  ;@@ If so, call array subscripting subroutine
           MVI	L,OFS_ARRAY_SETUP                   ;@@ Load L with address of array set up pointer
           MVI	H,HIGH OLDPG26           ;@@ ** Load H with page of array set up pointer
           MOV	B,M                      ;@@ Fetch pointer value (point to ")" of subscript)
           MVI	L,OFS_TOKEN_STORE                   ;@@ Change pointer to address of INPUT pointer
           MOV	M,B                      ;@@ Update INPUT pointer
           JMP	INPUT3                   ;@@ Jump over concatenate instruction below
INPUT2:	CALL	CONCTS                     ;Concatenate character to SYMBOL BUFFER
INPUT3:	MVI	L,OFS_TOKEN_STORE                      ;Load L with address of INPUT pointer
           CALL	LOOP                    ;Increment INPUT pointer and test for end of line
           JNZ	INPUT1                   ;If not end of line, go get next character
           CALL	INPUTX                  ;If end of buffer, get input for variable in the SYMBOL
           CALL	STOSYM                  ;BUFFER and store the value in the VARIABLES table
           JMP	NXTLIN                   ;Then continue to interpret next statement line
INPUT4:	CALL	INPUTX                     ;Get input from user for variable in SYMBOL BUFFER
           CALL	STOSYM                  ;Store the inputted value in the VARIABLES table
           MVI	H,HIGH OLDPG26           ;** Set H to page of INPUT pointer
           MVI	L,OFS_TOKEN_STORE                   ;Set L to location of INPUT pointer
           MOV	B,M                      ;Fetch pointer value for last character examined
           MVI	L,OFS_SCAN_PTR                   ;Change L to point to SCAN pointer storage location
           MOV	M,B                      ;Update the SCAN pointer
           JMP	INPUT                    ;Continue processing statement line for next variable
INPUTX:	MVI	L,OFS_SYMBOL_BUF                      ;Load L with start of SYMBOL BUFFER (contains cc)
           MOV	A,M                      ;Fetch the (cc) (length of symbol in the buffer) to ACC
           ADD	L                        ;Add (cc) to base address to set up
           MOV	L,A                      ;Pointer to last character in the SYMBOL BUFFER
           MOV	A,M                      ;Fetch the last character in the SYMBOL BUFFER
           CPI	0A4H                     ;See if the last chamcter was a $ sign
           JNZ	INPUTN                   ;If not a $ sign, get variable value as a numerical entry
           MVI	L,OFS_SYMBOL_BUF                   ;If $ sign, reset L to start of the SYMBOL BUFFER
           MOV	B,M                      ;Fetch the (cc) for the variable in the SYMBOL BUFF
           DCR	B                        ;Subtract one from (cc) to chop off the $ sign
           MOV	M,B                      ;Restore the new (cc) for the SYMBOL BUFFER
           CALL	FP0                     ;Call subroutine to zero the floating point accumulator
           CALL	CINPUT                  ;Input one character from system input device
           MVI	L,OFS_FPACC                   ;Load L with address of the LSW of the FPACC
           MOV	M,A                      ;Place the ASCII code for the character inputted there
           JMP	FPFLT                    ;Convert value to floating point format in FPACC
INPUTN:	MVI	L,OFS_FP_WORK+4                      ;Load L with address of start of AUX SYMBOL BUFF
           MVI	H,HIGH OLDPG26           ;** Load H with page of AUX SYMBOL BUFFER
           MVI	A,0BFH                   ;Load accumulator with ASCII code for ? mark
           CALL	ECHO                    ;Call output subroutine to display the ? mark
           CALL	STRIN                   ;Input string of characters (number) fm input device
           JMP	DINPUT                   ;Convert decimal string into binary floating point nr.
FP0:	MVI	H,HIGH OLDPG1                  ;** Load H with floating point working registers page
           JMP	CFALSE                   ;Zero the floating point accumulator & exit to caller
FOR:	MVI	L,OFS_FP_WORK+4                         ;Load L with address of AUX SYMBOL BUFFER
           MVI	H,HIGH OLDPG26           ;** Load H with page of AUX SYMBOL BUFFER
           MVI	M,000H                   ;Initialize buffer by clearing first byte
           MVI	L,OFS_FP_WORK_66                   ;Load L with location of second character in buffer
           MVI	M,000H                   ;Clear that location in case of single character variable
           MVI	L,OFS_TEMP_085                   ;Load L with address of FOR/NEXT STACK pointer
           MVI	H,HIGH OLDPG27           ;** Load H with page of FOR/NEXT STACK pointer
           MOV	B,M                      ;Fetch the FOR/NEXT STACK pointer
           INR	B                        ;Increment it in preparation for pushing operation
           MOV	M,B                      ;Restore it back to its storage location
           MVI	L,OFS_TEMP_F0                   ;Load L with address of user pgrn buffer line pointer
           MVI	H,HIGH OLDPG26           ;** Set H to page of line pointer
           MOV	D,M                      ;Fetch page address of pgm buffer line pntr into D
           INR	L                        ;Advance the memory pointer to pick up low part
           MOV	E,M                      ;Fetch low address of pgm buffer line pntr into E
           MOV	A,B                      ;Restore updated FOR/NEXT STACK pointer to ACC
           RLC                          ;Rotate it left to multiply by two, then rotate it again to
           RLC                          ;Multiply by four. Add this value to the base address of
           ADI	05CH                     ;The FOR/NEXT STACK to point to the new top of
           MOV	L,A                      ;The FOR/NEXT STACK and set up to point to stack
           MVI	H,HIGH OLDPG27           ;** Set H for page of the FOR/NEXT STACK
           MOV	M,D                      ;Store the page portion of the user pgrn buffer line pntr
           INR	L                        ;In the FORINEXT STACK, advance register 4 then
           MOV	M,E                      ;Store the low portion of the pgrn line pntr on the stack
           MVI	L,OFS_KW_TO                   ;Change L to point to start of TO string which is stored
           MVI	H,HIGH OLDPG1            ;** In a text strings storage area on this page
           CALL	INSTR                   ;Search the statement line for the occurrence of TO
           MOV	A,E                      ;Register E wiU be zero if TO not found. Move E to ACC
           ANA	A                        ;To make a test
           JNZ	FOR1                     ;If TO found then proceed with FOR statement
FORERR:	MVI	A,0C6H                      ;Else have a For Error. Load ACC with ASCII code for
           MVI	C,0C5H                   ;Letter F and register C with code for letter E.
           JMP	ERROR                    ;Then go display the FE message.
FOR1:	MVI	L,OFS_SCAN_PTR                        ;Load L with address of SCAN pointer storage location
           MVI	H,HIGH OLDPG26           ;** Set H to page of the SCAN pointer
           MOV	B,M                      ;Fetch pointer value to ACC (points to letter R in the
           INR	B                        ;For directive). Increment it to point to next character
           MVI	L,OFS_TEMP_ARRAY                   ;In the line. Change register L and set this value up
           MOV	M,B                      ;As an updated FOR pointer.
           MVI	L,OFS_TOKEN_STORE                   ;Set L to address of TO pointer (formerly TOKEN)
           MOV	M,E                      ;Save pointer to TO in the TO pointer!
FOR2:	MVI	L,OFS_TEMP_ARRAY                        ;Load L with address of the FOR pointer
           CALL	GETCHR                  ;Fetch a character from the statement line
           JZ	FOR3                      ;If it is a space, ignore it
           CPI	0BDH                     ;Test to see if character is the "=" sign
           JZ	FOR4                      ;If so, variable name is in the AUX SYMBOLBUFFER
           MVI	L,OFS_FP_WORK+4                   ;If not, then set L to point to start of the AUX SYMBOL
           CALL	CONCT1                  ;BUFFER and concatenate the character onto the buffer
FOR3:	MVI	L,OFS_TEMP_ARRAY                        ;Reset L to address of the FOR pointer
           CALL	LOOP                    ;Increment the pointer and see if end of line
           JNZ	FOR2                     ;If not end of line, continue looking for the "=" sign
           JMP	FORERR                   ;If reach end of line before "=" sign, then have error
FOR4:	MVI	L,OFS_TEMP_ARRAY                        ;Set L with address of the FOR pointer
           MOV	B,M                      ;Fetch pointer value to ACC (pointing to sign)
           INR	B                        ;Increment it to skip over the "=" sign
           MVI	L,OFS_EVAL_PTR                   ;Set L to address of the EVAL pointer
           MOV	M,B                      ;Restore the updated pointer to storage
           MVI	L,OFS_TOKEN_STORE                   ;Set L to the address of the TO pointer
           MOV	B,M                      ;Fetch pointer value to ACC (pointing to letter T in TO)
           DCR	B                        ;Decrement it to point to character before the T in TO
           MVI	L,OFS_EVAL_FINISH                   ;Set L to EVAL FINISH pointer storage location
           MOV	M,B                      ;Store the EVAL FINISH pointer value
           CALL	EVAL                    ;Evaluate the expression between the "=" sign and TO
           CALL	RESTSY                  ;Directive. Place the variable name in the variables table.
           MVI	L,OFS_FP_WORK+4                   ;Load L with starting address of the AUX SYMBOL BF
           MVI	H,HIGH OLDPG26           ;** Load H with the page of the AUX SYMBOL BUFF
           MOV	A,M                      ;Fetch the (cc) for the name in the buffer
           CPI	001H                     ;See if the symbol (name) length is just one character
           JNZ	FOR5                     ;If not, go directly to place name in FOR/NEXT STACK
           MVI	L,OFS_FP_WORK_66                   ;If so, set L to point to second character location in the
           MVI	M,000H                   ;AUX SYMBOL BUFFER and set it equal to zero.
           JMP	FOR5                     ;This jump directs program over ontrs/cntrs/table area
;;; LAST LINE SHOULD START AT 17 365
;;; PATCH AREA FOLLOWS THIS
	
	ORG	01000H
FPFIX:	MVI	L,OFS_FPACC_MSW                       ;Set L to point to MSW of FPACC
           MVI	H,HIGH OLDPG1            ;** Set H to point to page of FPACC
           MOV	A,M                      ;Fetch MSW of FPACC
           MVI	L,OFS_SIGN_IND1                   ;Change pointer to SIGN indicator on same page
           MOV	M,A                      ;Place MSW of FPACC into SIGN indicator
           ANA	A                        ;Now test sign bit of MSW of FPACC
           CM	FPCOMP                    ;Two's complement value in FPACC if negative
           MVI	L,OFS_FPACC_EXP                   ;Change pointer to FPACC Exponent register
           MVI	A,017H                   ;Set accumulator to 23 (decimal) for number of bits
           MOV	B,M                      ;Load FPACC Exponent into CPU register B
           INR	B                        ;Exercise the value in register B
           DCR	B                        ;To set CPU flags
           JM	FPZERO                    ;If FPACC Exponent is negative set FPACC to zero
           SUB	B                        ;Subtract value of FPACC Exponent from 23 decimal
           JM	FIXERR                    ;If Exp larger than 23 decimal cannot convert
           MOV	C,A                      ;Else place result in register C as counter for number
FPFIXL:	MVI	L,OFS_FPACC_MSW                      ;Of rotate ops. Set pointer to MSW of FPACC
           MVI	B,003H                   ;Set precision counter (number of bytes in mantissa)
           CALL	ROTATR                  ;Rotate FPACC right the number of places indicated
           DCR	C                        ;By count in register C to effectively rotate all the
           JNZ	FPFIXL                   ;Significant bits to the left of the floating point decimal
           JMP	RESIGN                   ;Point. Go check original sign & negate answer if req'd.

                                  ;Following subroutine clears the FPACC to the zero
                                  ;condition.

FPZERO:	MVI	L,OFS_FPACC_MSW                      ;Set L to point to MSW of FPACC
           XRA	A                        ;Clear the accumulator
           MOV	M,A                      ;Set the MSW of FPACC to zero
           DCR	L                        ;Decrement the pointer
           MOV	M,A                      ;Set the next significant word of FPACC to zero
           DCR	L                        ;Decrement the pointer
           MOV	M,A                      ;Set the LSW of FPACC to zero
           DCR	L                        ;Decrement the pointer
           MOV	M,A                      ;Set the auxiliary FPACC byte to zero
           RET                          ;Exit to calling routine

                                  ;The next instruction is a special entry point to
                                  ;the FPNORM subroutine that is used when a number is
                                  ;converted from fixed to floating point. The FPNORM
                                  ;label is the entry point when a number already in float-
                                  ;ing point fonnat is to be normalized.

FPFLT:	MVI	B,017H                       ;For fixed to float set CPU register B to 23 decimal
FPNORM:	MOV	A,B                         ;Get CPU register B into ACC to check for special case
           MVI	H,HIGH OLDPG1            ;** Set H to page of FPACC
           MVI	L,OFS_FPACC_EXP                   ;Set L to FPACC Exponent byte
           ANA	A                        ;Set CPU flags to test what was in CPU register B
           JZ	NOEXC0                    ;If B was zero then do standard normalization
           MOV	M,B                      ;Else set Exponent of FPACC to 23 decimal
NOEXC0:	DCR	L                           ;Change pointer to MSW of FPACC
           MOV	A,M                      ;Fetch MSW of FPACC into accumulator
           MVI	L,OFS_SIGN_IND1                   ;Change pointer to SIGN indicator storage location
           MOV	M,A                      ;Place the MSW of FPACC there for future reference
           ANA	A                        ;Set CPU flags to test MSW of FPACC
           JP	ACZERT                    ;If sign bit not set then jump ahead to do next test
           MVI	B,004H                   ;If sign bit set, number in FPACC is negative. Set up
           MVI	L,OFS_SYMBOL_BUF+3                   ;For two's complement operation
           CALL	COMPLM                  ;And negate the value in the FPACC to make it positive
ACZERT:	MVI	L,OFS_FPACC_MSW                      ;Reset pointer to MSW of FPACC
           MVI	B,004H                   ;Set precision counter to number of bytes in FPACC
LOOK0:	MOV	A,M                          ;Plus one. Fetch a byte of the FPACC.
           ANA	A                        ;Set CPU flags
           JNZ	ACNONZ                   ;If find anything then FPACC is not zero
           DCR	L                        ;Else decrement pointer to NSW of FPACC
           DCR	B                        ;Decrement precision counter
           JNZ	LOOK0                    ;Continue checking to see if FPACC contains anything
           MVI	L,OFS_FPACC_EXP                   ;Until precision counter is zero. If reach here then
           XRA	A                        ;Reset pointer to FPACC Exponent. Clear the ACC and
           MOV	M,A                      ;Clear out the FPACC Exponent. Value of FPACC is zip!
           RET                          ;Exit to calling routine
ACNONZ:	MVI	L,OFS_SYMBOL_BUF+3                      ;If FPACC has any value set pointer to LSW minus one
           MVI	B,004H                   ;Set precision counter to number of bytes in FPACC
           CALL	ROTATL                  ;Plus one for special cases. Rotate the contents of the
           MOV	A,M                      ;FPACC to the LEFT. Pointer will be set to MSW after
           ANA	A                        ;Rotate ops. Fetch MSW and see if have anything in
           JM	ACCSET                    ;Most significant bit position. If so, have rotated enough
           INR	L                        ;If not, advance pointer to FPACC Exponent. Fetch
           MOV	B,M                      ;The value of the Exponent and decrement it by one
           DCR	B                        ;To compensate for the rotate left of the mantissa
           MOV	M,B                      ;Restore the new value of the Exponent
           JMP	ACNONZ                   ;Continue rotating ops to normalize the FPACC
ACCSET:	MVI	L,OFS_FPACC_MSW                      ;Set pntr to FPACC MSW. Now must provide room for
           MVI	B,003H                   ;Sign bit in nonnalized FPACC. Set precision counter.
           CALL	ROTATR                  ;Rotate the FPACC once to the right now.
RESIGN:	MVI	L,OFS_SIGN_IND1                      ;Set the pointer to SIGN indicator storage location
           MOV	A,M                      ;Fetch the original sign of the FPACC
           ANA	A                        ;Set CPU flags
           RP                           ;If original sign of FPACC was positive, can exit now.

FPCOMP:	MVI	L,OFS_FPACC                      ; However, if original sign was negative, must now restore
           MVI	B,003H                   ;The FPACC to negative by performing two's comple-
           JMP	COMPLM                   ;Ment on FPACC. Return to caring rtn via COMPLM.

                                  ;Floating point ADDITION. Adds contents of FPACC to
                                  ;FPOP and leaves result in FPACC. Routine first checks
                                  ;to see if either register contains zero. If so addition
                                  ;result is already present!

FPADD:	MVI	L,OFS_FPACC_MSW                       ;Set L to point to MSW of FPACC
           MVI	H,HIGH OLDPG1            ;** Do same for register H
           MOV	A,M                      ;Fetch MSW of FPACC to accumulator
           ANA	A                        ;Set CPU flags after loading op
           JNZ	NONZAC                   ;If accumulator non-zero then FPACC has some value
MOVOP:	MVI	L,OFS_FPACC                       ;But, if accumulator was zero then normalized FPACC
           MOV	D,H                      ;Must also be zero. Thus answer to addition is simply the
           MOV	E,L                      ;Value in FPOP. Set up pointers to transfer contents of
           MVI	L,OFS_FPOP                   ;FPOP to FPACC by pointing to the LSW of both
           MVI	B,004H                   ;Registers and perform the transfer. Then exit to calling
           JMP	MOVEIT                   ;Routine with answer in FPACC via MOVEIT.
NONZAC:	MVI	L,OFS_FPOP_MSW                      ;If FPACC was non-zero then check to see if FPOP has
           MOV	A,M                      ;Some value by obtaining MSW of FPOP
           ANA	A                        ;Set CPU flags after loading op. If MSW zero then
           RZ                           ;Normalized FPOP must be zero. Answer is in FPACC!

                                  ;If neither FPACC or FPOP was zero then must perform
                                  ;addition operation. Must first check to see if two num-
                                  ;bers are within significant mnge. If not, largest number
                                  ;is answer. If numbers within range, then must align ex-
                                  ;ponents before perforrning the addition of the man-
                                  ;tissa.

CKEQEX:	MVI	L,OFS_FPACC_EXP                      ;Set pointer to FPACC Exponent storage location.
           MOV	A,M                      ;Fetch the Exponent value to the accumulator.
           MVI	L,OFS_FPOP_EXP                   ;Change the pointer to the FPOP Exponent
           CMP	M                        ;Compare the values of the exponents. If they are the
           JZ	SHACOP                    ;Same then can immediately proceed to add operations.
           MOV	B,A                      ;If not the same, store FPACC Exponent size in regis B
           MOV	A,M                      ;Fetch the FPOP Exponent size into the ACC
           SBB	B                        ;Subtract the FPACC Exponent from the FPOP Exp.
           JP	SKPNEG                    ;If result is positive jump over the next few instructions
           MOV	B,A                      ;If result was negative, store the result in B
           XRA	A                        ;Clear the accumulator
           SBB	B                        ;Subtract register B to negate the original value
SKPNEG:	CPI	018H                        ;See if difference is less than 24 decimal.
           JM	LINEUP                    ;If so, can align exponents. Go do it.
           MOV	A,M                      ;If not, find out which number is largest. Fetch FPOP
           MVI	L,OFS_FPACC_EXP                   ;Exponent into ACC. Change pointer to FPACC Exp.
           SUB	M                        ;Subtract FPACC from FPOP. If result is negative then
           RM                           ;was larger. Return with answer in FPACC.
           MVI	L,OFS_FPACC                   ;If result was positive, larger value in FPOP. Set pointers
           JMP	MOVOP                    ;To transfer FPOP into FPACC and then exit to caller.
LINEUP:	MOV	A,M                         ;Fetch FPOP Exponent into accumulator.
           MVI	L,OFS_FPACC_EXP                   ;Change pointer to FPACC Exponent.
           SUB	M                        ;Subtract FPACC Exponent from FPOP Exponent. If
           JM	SHIFT0                    ;Result is negative FPACC is larger. Go shift FPOP.
           MOV	C,A                      ;If result positive FPOP larger, must shift FPACC. Store
MORACC:	MVI	L,OFS_FPACC_EXP                      ;Difference count in C. Reset pointer to FPACC Exp
           CALL	SHLOOP                  ;Call the SHift LOOP to rotate FPACC mantissa RIGHT
           DCR	C                        ;And INCREMENT Exponent. Decr difference counter
           JNZ	MORACC                   ;Continue rotate operations until diff counter is zero
           JMP	SHACOP                   ;Go do final alignment and perform addition process
SHIFT0:	MOV	C,A                         ;Routine to shift FPOP. Set difference count into reg. C
MOROP:	MVI	L,OFS_FPOP_EXP                       ;Set pointer to FPOP Exponent.
           CALL	SHLOOP                  ;Call the SHift LOOP to rotate FPOP mantissa RIGHT
           INR	C                        ;And INCREMENT Exponent. Then incr difference cntr
           JNZ	MOROP                    ;Continue rotate opemtions until diff counter is zero
;;; The below two instructions are changed by PATCH NR.1
;;;SHACOP:    LLI 123                ;Set pointer to FPACC LSW minus one to provide extra
;;;           LMI 000                ;Byte for addition ops. Clear that location to zero.
SHACOP:	CALL	PATCH1                     ; patch 1 inserts a few lines at 30-000
	   MOV	A,A
	
;;;           LLI 133
;;;           LMI 000                ;THIS IS PATCH #1
           MVI	L,OFS_FPACC_EXP                   ;Change pointer to FPACC Exponent
           CALL	SHLOOP                  ;Rotate FPACC mantissa RIGHT & Increment Exponent
           MVI	L,OFS_FPOP_EXP                   ;Change pointer to FPOP Exponent
           CALL	SHLOOP                  ;Rotate FPOP mantissa RIGHT & Increment Exponent
           MOV	D,H                      ;Rotate ops provide room for overflow. Now set up
           MVI	E,OFS_FPACC_LSW_M1                   ;Pointers to LSW minus one for both FPACC & FPOP
           MVI	B,004H                   ;(FPOP already set after SHLOOP). Set precision counter
           CALL	ADDER                   ;Call quad precision ADDITION subroutine.
           MVI	B,000H                   ;Set CPU register B to indicate standard normalization
           JMP	FPNORM                   ;Go normalize the result and exit to caller.
SHLOOP:	MOV	B,M                         ;Shifting loop. First fetch Exponent currently being
           INR	B                        ;Pointed to and Increment the value by one.
           MOV	M,B                      ;Return the updated Exponent value to memory.
           DCR	L                        ;Decrement the pointer to mantissa portion MSW
           MVI	B,004H                   ;Set precision counter
FSHIFT:	MOV	A,M                         ;Fetch MSW of mantissa
           ANA	A                        ;Set CPU flags after load ops
           JP	ROTATR                    ;If MSB not a one can do normal rotate ops
BRING1:	RAL                             ;If MSB is a one need to set up carrv bit for the negative
           JMP	ROTR                     ;Number case. Then make special entry to ROTATR sub

                                  ;The following subroutine moves the contents of a string
                                  ;of memory locations from the address pointed to by
                                  ;CPU registers H & L to the address specified by the con-
                                  ;tents of registers D & E when the routine is entered. The
                                  ;process continues until the counter in register B is zero.

MOVEIT:	MOV	A,M                         ;Fetch a word from memory string A
           INR	L                        ;Advance A string pointer
           CALL	SWITCH                  ;Switch pointer to string B
           MOV	M,A                      ;Put word from string A into string B
           INR	L                        ;Advance B string pointer
           CALL	SWITCH                  ;Switch pointer back to string A
           DCR	B                        ;Decrement loop counter
           RZ                           ;Return to calling routine when counter reaches zero
           JMP	MOVEIT                   ;Else continue transfer operations

                                  ;The following subroutine SUBTRACTS the
                                  ;contents of the FLOATING POINT ACCUMULATOR from the
                                  ;contents of the FLOATING POINT OPERAND and
                                  ;leaves the result in the FPACC. The routine merely
                                  ;negates the value in the FPACC and then goes to the
                                  ;FPADD subroutine just presented.

FPSUB:	MVI	L,OFS_FPACC                       ;Set L to address of LSW of FPACC
           MVI	H,HIGH OLDPG1            ;** Set H to page of FPACC
           MVI	B,003H                   ;Set precision counter
           CALL	COMPLM                  ;Two's complement the value in the FPACC
           JMP	FPADD                    ;Now go add the negated value to perform subtraction!

                                  ;The first part of the FLOATING POINT MULTIPLI-
                                  ;CATION subroutine calls a subroutine to check the
                                  ;original signs of the numbers that are to be multi-
                                  ;plied and perform working register clearing functions.
                                  ;Next the exponents of the numbers to be multiplied
                                  ;are added together.

FPMULT:	CALL	CKSIGN                     ;Call routine to set up registers & ck signs of numbers
ADDEXP:	MVI	L,OFS_FPOP_EXP                      ;Set pointer to FPOP Exponent
           MOV	A,M                      ;Fetch FPOP Exponent into the accumulator
           MVI	L,OFS_FPACC_EXP                   ;Change pointer to FPACC Exponent
           ADD	M                        ;Add FPACC Exponent to FPOP Exponent
           ADI	001H                     ;Add one more to total for algorithm compensation
           MOV	M,A                      ;Store result in FPACC Exponent location
SETMCT:	MVI	L,OFS_BITS_COUNTER                      ;Change pointer to bit counter storage location
           MVI	M,017H                   ;Initialize bit counter to 23 decimal

                                  ;Next portion of the FPMULT routine is the iinplernen-
                                  ;tation of the algorithm illustrated in the flow chart
                                  ;above. This portion multiplies the values of the two
                                  ;mantissas. The final value is rounded off to leave the
                                  ;23 most significant bits as the answer that is stored
                                  ;back in the FPACC.

MULTIP:	MVI	L,OFS_FPACC_MSW                      ;Set pointer to MSW of FPACC mantissa
           MVI	B,003H                   ;Set precision counter
           CALL	ROTATR                  ;Rotate FPACC (multiplier) RIGHT into carry bit
           CC	ADOPPP                    ;If carry is a one, add multiplicand to partial-product
           MVI	L,OFS_FP_WORK_66                   ;Set pointer to partial-product most significant byte
           MVI	B,006H                   ;Set precision counter (p-p register is double length)
           CALL	ROTATR                  ;Shift partial-product RIGHT
           MVI	L,OFS_BITS_COUNTER                   ;Set pointer to bit counter storage location
           MOV	C,M                      ;Fetch current value of bit counter
           DCR	C                        ;Decrement the value of the bit counter
           MOV	M,C                      ;Restore the updated bit counter to its storage location
           JNZ	MULTIP                   ;If have not multiplied for 23 (deciinal) bits, keep going
           MVI	L,OFS_FP_WORK_66                   ;If have done 23 (decimal) bits, set pntr to p-p MSW
           MVI	B,006H                   ;Set precision counter (for double length)
           CALL	ROTATR                  ;Shift partial-product once more to the RIGHT
           MVI	L,OFS_FP_WORK_63                   ;Set pointer to access 24'th bit in partial-product
           MOV	A,M                      ;Fetch the byte containing the 24'th bit
           RAL                          ;Position the 24'th bit to be MSB in the accumulator
           ANA	A                        ;Set the CPU flags after to rotate operation and test to
           CM	MROUND                    ;See if 24'th bit of p-p is a ONE. If so, must round-off
           MVI	L,OFS_SYMBOL_BUF+3                   ;Now set up pointers
           MOV	E,L                      ;To perform transfer
           MOV	D,H                      ;Of the multiplication results
           MVI	L,OFS_FP_WORK_63                   ;From the partial-product location
           MVI	B,004H                   ;To the FPACC

	
EXMLDV:	CALL	MOVEIT                     ;Perform the transfer from p-p to FPACC
           MVI	B,000H                   ;Set up CPU register B to indicate regular normalization
           CALL	FPNORM                  ;Normalize the result of multiplication
           MVI	L,OFS_SIGN_IND1+1                   ;Now set the pointer to the original SIGNS indicator
           MOV	A,M                      ;Fetch the indicator
           ANA	A                        ;Exercise the CPU flags
           RNZ                          ;If indicator is non-zero, answer is positive, can exit her
           JMP	FPCOMP                   ;If not, answer must be negated, exit via 2's complement.

                                  ;The following portions of the FPMULT
                                  ;routine set up working locations in memory by clearing
                                  ;locations for an expanded FPOP area and the partial-produc
                                  ;area. Next, the signs of the two numbers to be multiplied
                                  ;are examined. Negative numbers are negated
                                  ;in preparation for the multiplication
                                  ;algorithm. A SIGNS indicator register is set up during
                                  ;this process to indicate whether the final result of the
                                  ;multiplication should be positive or negative. (Negative
                                  ;if original signs of the two numbers to be multiplied are
                                  ;different.)

CKSIGN:	MVI	L,OFS_FP_WORK                      ;Set pointer to start of partial-product working area
           MVI	H,HIGH OLDPG1            ;** Set H to proper page
           MVI	B,008H                   ;Set up a loop counter in CPU register B
           XRA	A                        ;Clear the accumulator

CLRNEX:	MOV	M,A                         ;Now clear out locations for the partial-product
           INR	L                        ;Working registers
           DCR	B                        ;Until the loop counter
           JNZ	CLRNEX                   ;Is zero
CLROPL:	MVI	B,004H                      ;Set a loop counter
           MVI	L,OFS_FPOP_EXT                   ;Set up pointer
CLRNX1:	MOV	M,A                         ;Clear out some extra registers so that the
           INR	L                        ;FPOP may be extended in length
           DCR	B                        ;Perform clearing ops until loop counter
           JNZ	CLRNX1                   ;Is zero
           MVI	L,OFS_SIGN_IND1+1                   ;Set pointer to M/D SIGNS indicator storage location
           MVI	M,001H                   ;Set initial value of SIGNS indicator to plus one
           MVI	L,OFS_FPACC_MSW                   ;Change pointer to MSW of FPACC
           MOV	A,M                      ;Fetch MSW of mantissa into accumulator
           ANA	A                        ;Test flags
           JM	NEGFPA                    ;If MSB in MSW of FPACC is a one, number is negative
OPSGNT:	MVI	L,OFS_FPOP_MSW                      ;Set pointer to MSW of FPOP
           MOV	A,M                      ;Fetch MSW of mantissa into accumulator
           ANA	A                        ;Test flags
           RP                           ;Return to caller if number in FPOP is positive
           MVI	L,OFS_SIGN_IND1+1                   ;Else change pointer to M/D SIGNS indicator
           MOV	C,M                      ;Fetch the value in the SIGNS indicator
           DCR	C                        ;Decrement the value by one
           MOV	M,C                      ;Restore the new value back to storage location
           MVI	L,OFS_FPOP                   ;Set pointer to LSW of FPOP
           MVI	B,003H                   ;Set precision counter
           JMP	COMPLM                   ;Two's complement value of FPOP & return to caller
NEGFPA:	MVI	L,OFS_SIGN_IND1+1                      ;Set pointer to M/D SIGNS indicator
           MOV	C,M                      ;Fetch the value in the SIGNS indicator
           DCR	C                        ;Decrement the value by one
           MOV	M,C                      ;Restore the new value back to storage location
           MVI	L,OFS_FPACC                   ;Set pointer to LSW of FPACC
           MVI	B,003H                   ;Set precision counter
           CALL	COMPLM                  ;Two's complement value of FPACC
           JMP	OPSGNT                   ;Proceed to check sign of FPOP

                                  ;The following subroutine adds the double length (six regis
                                  ;multiplicand in FPOP to the partial-product register when
                                  ;called on by the multiplication algorithm.

ADOPPP:	MVI	E,OFS_FP_WORK_61                      ;Pointer to LSW of partial-product
           MOV	D,H                      ;On same page as FPOP
           MVI	L,OFS_FPOP_EXT+1                   ;LSIV of FPOP which contains extended multiplicand
           MVI	B,006H                   ;Set precision counter (double length working registers)
           JMP	ADDER                    ;Add multiplicand to partial-product & return to caller

MROUND:	MVI	B,003H                      ;Set up precision counter
           MVI	A,040H                   ;Prepare to add one to 24'th bit of partial-product
           ADD	M                        ;Add one to the 24'th bit of the partial-product
CROUND:	MOV	M,A                         ;Restore the updated byte to memory
           INR	L                        ;Advance the memory pointer to next most significant
           MVI	A,000H                   ;Byte of partial-product, then clear ACC without
           ADC	M                        ;Disturbing carry bit. Now perform add with carry to
           DCR	B                        ;Propagate any rounding in the partial-product registers.
           JNZ	CROUND                   ;If cotinter is not zero continue propagating any carry
           MOV	M,A                      ;Restore final byte to memory
           RET                          ;Exit to calling routine

FPDIV:	CALL	CKSIGN                      ;Call routine to set up registers & ck signs of numbers
           MVI	L,OFS_FPACC_MSW                   ;Set pointer to MSW of FPACC (divisor)
           MOV	A,M                      ;Fetch MSW of FPACC to accumulator
           ANA	A                        ;Exercise CPU flags
           JZ	DVERR                     ;If MSW of FPACC is zero go display 'DZ' error message
SUBEXP:	MVI	L,OFS_FPOP_EXP                      ;Set pointer to FPOP (dividend) Exponent
           MOV	A,M                      ;Get FPOP Exponent into accumulator
           MVI	L,OFS_FPACC_EXP                   ;Change pointer to FPACC (divisor) Exponent
           SUB	M                        ;Subtract divisor exponent from dividend exponent
           ADI	001H                     ;Add one for algorithm compensation
           MOV	M,A                      ;Place result in FPACC Exponent
SETDCT:	MVI	L,OFS_BITS_COUNTER                      ;Set pointer to bit counter storage location
           MVI	M,017H                   ;Initialize bit counter to 23 decimal

                                  ;Main division algorithm for mantissas

DIVIDE:	CALL	SETSUB                     ;Go subtmct divisor from dividend
           JM	NOGO                      ;If result is negative then place a zero bit in quotient
           MVI	E,OFS_FPOP                   ;If result zero or positive then move remainder after
           MVI	L,OFS_FPOP_EXT+1                   ;Subtraction from working area to become new dividend
           MVI	B,003H                   ;Set up moving pointers and initialize precision counter
           CALL	MOVEIT                  ;Perform the transfer
           MVI	A,001H                   ;Place a one into least significant bit of accumulator
           RAR                          ;And rotate it out into the carry bit
           JMP	QUOROT                   ;Proceed to rotate the carry bit into the current quotient
NOGO:	XRA	A                             ;When result is negative, put a zero in the carry bit, then
QUOROT:	MVI	L,OFS_FP_WORK+4                      ;Set up pointer to LSW of quotient register
           MVI	B,003H                   ;Set precision counter
           CALL	ROTL                    ;Rotate carry bit into quotient by using special entry to
           MVI	L,OFS_FPOP                   ;ROTATL subroutine. Now set up pointer to dividend
           MVI	B,003H                   ;LSW and set precision counter
           CALL	ROTATL                  ;Rotate the current dividend to the left
           MVI	L,OFS_BITS_COUNTER                   ;Set pointer to bit counter storage location
           MOV	C,M                      ;Fetch the value of the bit counter
           DCR	C                        ;Decrement the value by one
           MOV	M,C                      ;Restore the new counter value to storage
           JNZ	DIVIDE                   ;If bit counter is not zero, continue division process
           CALL	SETSUB                  ;After 23 (decimal) bits, do subtraction once more for
           JM	DVEXIT                    ;Possible rounding. Jump ahead if no rounding required.
           MVI	L,OFS_FP_WORK+4                   ;If rounding required set pointer to LSW of quotient
           MOV	A,M                      ;Fetch LSW of quotient to accumulator
           ADI	001H                     ;Add one to 23rd bit of quotient
           MOV	M,A                      ;Restore updated LSW of quotient
           MVI	A,000H                   ;Clear accumulator without disturbing carry bit
           INR	L                        ;Advance pointer to next significant byte of quotient
           ADC	M                        ;Propagate any carry as part of rounding process
           MOV	M,A                      ;Restore the updated byte of quotient
           MVI	A,000H                   ;Clear ACC again without disturbing carry bit
           INR	L                        ;Advance pointer to MSW of quotient
           ADC	M                        ;Propagate any carry to finish rounding process
           MOV	M,A                      ;Restore the updated byte of quotient
           JP	DVEXIT                    ;If most significant bit of quotient is zero, go finish up
           MVI	B,003H                   ;If not, set precision counter
           CALL	ROTATR                  ;And rotate quotient to the right to clear the sign bit
           MVI	L,OFS_FPACC_EXP                   ;Set pointer to FPACC Exponent
           MOV	B,M                      ;Fetch FPACC exponent
           INR	B                        ;Increment the value to compensate for the rotate right
           MOV	M,B                      ;Restore the updated exponent value
DVEXIT:	MVI	L,OFS_FP_WORK_63                      ;Set up pointers
           MVI	E,OFS_FPACC_LSW_M1                   ;To transfer the quotient into the FPACC
           MVI	B,004H                   ;Set precision counter
                                  ;THIS IS A CORRECTION FOUND IN THE NOTES
           JMP	EXMLDV                   ;And exit through FPMULT routine at EXMLDV

                                  ;Subroutine to subtract divisor from dividend. Used by
                                  ;main DIVIDE subroutine.

SETSUB:	MVI	E,OFS_FPOP_EXT_59                      ;Set pointer to LSW of working area
           MOV	D,H                      ;On same page as FPACC
           MVI	L,OFS_FPACC                   ;Set pointer to LSW of FPACC (divisor)
           MVI	B,003H                   ;Set precision counter
           CALL	MOVEIT                  ;Perform transfer
           MVI	E,OFS_FPOP_EXT_59                   ;Reset pointer to LSW of working area (now divisor)
           MVI	L,OFS_FPOP                   ;Reset pointer to LSW of FPOP (dividend)
           MVI	B,003H                   ;Set precision counter
           CALL	SUBBER                  ;Subtract divisor from dividend
           MOV	A,M                      ;Get MSW of the result of the subtraction operations
           ANA	A                        ;Exercise CPU flags
           RET                          ;Return to caller with status
ADDER:	ANA	A                            ;Initialize the carry bit to zero upon entry
ADDMOR:	MOV	A,M                         ;Fetch byte from register group A
           CALL	SWITCH                  ;Switch memory pointer to register group B
           ADC	M                        ;Add byte from A to byte from B with carry
           MOV	M,A                      ;Leave result in register group B
           DCR	B                        ;Decrement number of bytes (precision) counter
           RZ                           ;Return to caller when all bytes in group processed
           INR	L                        ;Else advance pointer for register group B
           CALL	SWITCH                  ;Switch memory pointer back to register group A
           INR	L                        ;Advance the pointer for register group A
           JMP	ADDMOR                   ;Continue the multi-byte addition operation

                                  ;N'th precision two's complement (negate)
                                  ;subroutine. Performs a two's complement on the multi-byte
                                  ;registers tarting at the address pointed
                                  ; to by H & L (least significant byte) upon entry.

COMPLM:	MOV	A,M                         ;Fetch the least significant byte of the number to ACC
           XRI	0FFH                     ;Exclusive OR to complement the byte
           ADI	001H                     ;Add one to form two's complement of byte
MORCOM:	MOV	M,A                         ;Restore the negated byte to memory
           RAR                          ;Save the carry bit
           MOV	D,A                      ;In CPU register D
           DCR	B                        ;Decrement number of bytes (precision) counter
           RZ                           ;Return to caller when all bytes in number processed
           INR	L                        ;Else advance the pointer
           MOV	A,M                      ;Fetch the next byte of the number to ACC
           XRI	0FFH                     ;Exclusive OR to complement the byte
           MOV	E,A                      ;Save complemented value in register E temporarily
           MOV	A,D                      ;Restore previous carry status to ACC
           RAL                          ;And rotate it out to the carry bit
           MVI	A,000H                   ;Clear ACC without disturbing carry status
           ADC	E                        ;Add in any carry to complemented value
           JMP	MORCOM                   ;Continue the two's complement procedure as req'd

                                  ;N'th precision rotate left subroutine. Rotates a multi-
                                  ;byte number left starting at the address initially
                                  ;specified by the contents of CPU registers H & L upon
                                  ;subroutine entry (LSW). First entry point will clear
                                  ;the carry bit before beginning rotate operations. Second
                                  ;entry point does not clear the carry bit.

ROTATL:	ANA	A                           ;Clear the carry bit at this entry point
ROTL:	MOV	A,M                           ;Fetch a byte from memory
           RAL                          ;Rotate it left (bring carry into LSB, push MSB to carry)
           MOV	M,A                      ;Restore rotated word to memory
           DCR	B                        ;Decrement precision counter
           RZ                           ;Exit to caller when finished
           INR	L                        ;Else advance pointer to next byte
           JMP	ROTL                     ;Continue rotate left operations


                                  ;N'th precision rotate
                                  ;right subroutine. Opposite of
                                  ;above subroutine.

ROTATR:	ANA	A                           ;Clear the carry bit at this entry point
ROTR:	MOV	A,M                           ;Fetch a byte from memory
           RAR                          ;Rotate it right (carry into MSB, LSB to carry)
           MOV	M,A                      ;Restore rotated word to memory
           DCR	B                        ;Decrement precision counter
           RZ                           ;Exit to caller when finished
           DCR	L                        ;Else decrement pointer to next byte
           JMP	ROTR                     ;Continue rotate right operations

                                  ;N'th precision subtraction subroutine.
                                  ;Number starting at location pointed to by D & E (least
                                  ;significant byte) is subtracted from number starting at
                                  ;address specified by contents of H & L.

SUBBER:	ANA	A                           ;Initialize the carry bit to zero upon entry
SUBTRA:	MOV	A,M                         ;Fetch byte from register group A
           CALL	SWITCH                  ;Switch memory pointer to register group B
           SBB	M                        ;Subtract byte from group B ftom that in group A
           MOV	M,A                      ;Leave result in register group B
           DCR	B                        ;Decrement number of bytes (precision) counter
           RZ                           ;Return to caller when all bytes in group processed
           INR	L                        ;Else advance pointer for register group B
           CALL	SWITCH                  ;Switch memory pointer back to register group A
           INR	L                        ;Advance the pointer for register group A
           JMP	SUBTRA                   ;Continue the multi-byte subtraction operation

                                  ;The next subroutine will transfer the four byte
                                  ;register string (generally a number in floating point
                                  ;format) from the starting address pointed to by CPU
                                  ;registers H & L when the subroutine is entered to
                                  ;the FPACC (floating point accumulator registers).

FLOAD:	MVI	D,HIGH OLDPG1                ;** Set page address of FPACC
           MVI	E,OFS_FPACC                   ;Set address of least signficant byte of FPACC
           MVI	B,004H                   ;Set precision counter to four bytes (mantissa bytes
           JMP	MOVEIT                   ;Plus Exponent) and exit via the transfer routine

                                  ;The next several subroutines are used to perform
                                  ;floating pojnt register loading and transfer operations.

FSTORE:	MOV	E,L                         ;Transfer contents of register L to E
           MOV	D,H                      ;Transfer contents of register H to D
           MVI	L,OFS_FPACC                   ;Set L to least significant byte of FPACC mantissa
           MVI	H,HIGH OLDPG1            ;** Set page to FPACC storage area
           JMP	SETIT                    ;Go transfer FPACC contents to area pointed to by D&E
OPLOAD:	MVI	D,HIGH OLDPG1               ;** Set page to FPOP storage area
           MVI	E,OFS_FPOP                   ;Set pointer to least significant byte of FPOP
SETIT:	MVI	B,004H                       ;Set precision counter. Transfer from H & L area to
           JMP	MOVEIT                   ;Locations pointed to by D & E

                                  ;The next subroutine perforins a double transfer opera-
                                  ;tion. It first transfers the contents of the FPACC into
                                  ;the FPOP. It then transfers new data (as pointed to by
                                  ;H & L upon entry to the subroutine) into the FPACC.

FACXOP:	CALL	SAVEHL                     ;Save contents of H & L upon entry to subroutine
           MVI	L,OFS_FPACC                   ;Set pointer to FPACC LSW
           MVI	H,HIGH OLDPG1            ;** Set pointer to page of FPACC
           CALL	OPLOAD                  ;Transfer FPACC to FPOP
           CALL	RESTHL                  ;Recover original subroutine entry values for H & L
           JMP	FLOAD                    ;Transfer registers pointed to by H & L into the FPACC

                                  ;Subroutine to save the contents of CPU registers D, E, H
                                  ;and L in a temporary storage area in memory.

SAVEHL:	MOV	A,H                         ;Transfer value in H to ACC
           MOV	B,L                      ;And value in L to B
           MVI	L,OFS_EVAL_CURRENT                   ;Now set L to start of tempomry storage locations
           MVI	H,HIGH OLDPG1            ;** And set H to storage area page
           MOV	M,A                      ;Save A (entry value of H) in memory
           INR	L                        ;Advance pointer
           MOV	M,B                      ;Save B (entry value of L) in memory
           INR	L                        ;Advance pointer
           MOV	M,D                      ;Save D in memory
           INR	L                        ;Advance pointer
           MOV	M,E                      ;Save E in memory
           MOV	H,A                      ;Restore entry value of H
           MOV	L,B                      ;Restore entry value of L
           RET                          ;Exit to calling routine

                                  ;Subroutine to restore the contents of CPU registers D,
                                  ;E, H and L from temporary storage in memory.

RESTHL:	MVI	L,OFS_EVAL_CURRENT                      ;Set L to start of temporary storage locations
           MVI	H,HIGH OLDPG1            ;** Set H to storage area page
           MOV	A,M                      ;Fetch stored value for li iii ACC
           INR	L                        ;Advance pointer
           MOV	B,M                      ;Fetch stored value for L into B
           INR	L                        ;Advance pointer
           MOV	D,M                      ;Fetch stored value for T.)
           INR	L                        ;Advance pointer
           MOV	E,M                      ;Fetch stored value for
           MOV	H,A                      ;Restore  saved value for H
           MOV	L,B                      ;Restore saved value for L
           MOV	A,M                      ;Leave stored value for E in ACC
           RET                          ;Exit to calling routine

                                  ;Subroutine to exchange the contents of H & L with
                                  ;D & E.

SWITCH:	MOV	C,H                         ;Transfer register H to C temporarily
           MOV	H,D                      ;Place value of D into H
           MOV	D,C                      ;Now put former H from C into D
           MOV	C,L                      ;Transfer register L to C temporarily
           MOV	L,E                      ;Place value of E into L
           MOV	E,C                      ;Now put former L from C into E
           RET                          ;Exit to calling routine
GETINP:	MVI	H,HIGH OLDPG1               ;** Set H to page of GETINP character counter
           MVI	L,OFS_GETINP_CNT                   ;Set L to address of GETINP character counter
           MOV	C,M                      ;Load counter value into CPU register C
           INR	C                        ;Exercise the counter in order
           DCR	C                        ;To set CPU flags. If counter is non-zero, then indexing
           JNZ	NOT0                     ;Register (GETINP counter) is all set so jump ahead.
           MOV	L,E                      ;But, if counter zero, then starting to process a new
           MOV	H,D                      ;Character string. Transfer char string buffer pointer into
           MOV	C,M                      ;H & L and fetch the string's character count value (cc)
           INR	C                        ;Increment the (cc) by one to take account of (cc) byte
           CALL	INDEXC                  ;Add contents of regis C to H & L to point to end of the
           MVI	M,000H                   ;Character string in buffer and place a zero byte marker
NOT0:	MVI	L,OFS_GETINP_CNT                        ;Set L back to address of GETINP counter which is used
           MVI	H,HIGH OLDPG1            ;** As an indexing value. Set H to correct page.
           MOV	C,M                      ;Fetch the value of GETINP counter into register C
           INR	C                        ;Increment the value in C
           MOV	M,C                      ;Restore the updated value for future use
           MOV	L,E                      ;Bring the base address of the character string buffer into
           MOV	H,D                      ;CPU registers H & L
           CALL	INDEXC                  ;Add contents of register C to form indexed address of
           MOV	A,M                      ;Next character to be fetched as input. Fetch the next
           ANA	A                        ;Character. Exercise the CPU flags.
           MVI	H,HIGH OLDPG1            ;** Restore page pointer to floating point working area
           RNZ                          ;If character is non-zero, not end of string, exit to calle
           MVI	L,OFS_GETINP_CNT                   ;If zero character, must reset GETINP counter for next
           MVI	M,000H                   ;String. Reset pointer and clear GETINP counter to zero
           RET                          ;Then exit to calling routine

                                  ;Following subroutine causes register C to be used as an
                                  ;indexing register. Value in C is added to address in H
                                  ;and L to form new address.

INDEXC:	MOV	A,L                         ;Place value from register L into accumulator
           ADD	C                        ;Add quantity in register C
           MOV	L,A                      ;Restore updated value back to L
           RNC                          ;Exit to caller if no carry from addition
           INR	H                        ;But, if have carry then must increment register H
           RET                          ;Before returning to calling routine

                                  ;Main Decimal INPUT subroutine to convert strings of
                                  ;ASCII characters representing decimal fixed or floating
                                  ;point numbers to binary floating point numbers.

DINPUT:	MOV	E,L                         ;Save entry value of register L in E. (Pointer to buffer
           MOV	D,H                      ;Containing ASCII character string.) Do same for H to D.
           MVI	H,HIGH OLDPG1            ;** Set H to page of floating point working registers
           MVI	L,OFS_FP_WORK_68                   ;Set L to start of decirnal-to-binary working area
           XRA	A                        ;Clear the accumulator
           MVI	B,008H                   ;Set up a loop counter
CLRNX2:	MOV	M,A                         ;Deposit zero in working area to initialize
           INR	L                        ;Advance the memory pointer
           DCR	B                        ;Decrement the loop counter
           JNZ	CLRNX2                   ;Clear working area until loop counter is zero
           MVI	L,OFS_SIGN_IND2                   ;Set pointer to floating point temporary registers and
           MVI	B,004H                   ;Indicators working area. Set up a loop counter.
CLRNX3:	MOV	M,A                         ;Deposit zero in working area to initialize
           INR	L                        ;Advance the memory pointer
           DCR	B                        ;Decrement the loop counter
           JNZ	CLRNX3                   ;Clear working area until loop counter is zero
           CALL	GETINP                  ;Fetch a character from the ASCII chax string buffer
           CPI	0ABH                     ;(Typically the SYMBOL/TOKEN buffer). See if it is
           JZ	NINPUT                    ;Code for + sign. Jump ahead if code for + sign.
           CPI	0ADH                     ;See if code for minus (-) sign.
           JNZ	NOTPLM                   ;Jump ahead if not code for minus sign. If code for
           MVI	L,OFS_SIGN_IND2                   ;Minus sign, set pointer to MINUS flag storage location.
           MOV	M,A                      ;Set the MINUS flag to indicate a minus number
NINPUT:	CALL	GETINP                     ;Fetch another character from the ASCII char string
NOTPLM:	CPI	0AEH                        ;See if character represents a period (decimal point) in
           JZ	PERIOD                    ;Input string. Jump ahead if yes.
           CPI	0C5H                     ;If not period, see if code for E as in Exponent
           JZ	FNDEXP                    ;Jump ahead if yes.
           CPI	0A0H                     ;Else see if code for space.
           JZ	NINPUT                    ;Ignore space character, go fetch another character.
           ANA	A                        ;If none of the above see if zero byte
           JZ	ENDINP                    ;Indicating end of input char string. If yes, jumn ahead.
           CPI	0B0H                     ;If not end of string, check to see
           JM	NUMERR                    ;If character represents
           CPI	0BAH                     ;A valid decimal number (0 to 9)
           JP	NUMERR                    ;Display error message if not a valid digit at this point!
           MVI	L,OFS_FP_WORK_6E                   ;For valid digit, set pointer to MSW of temporary
           MOV	C,A                      ;Decimal to binary holding registers. Save character in C.
           MVI	A,0F8H                   ;Form mask for sizing in accumulator. Now see if
           ANA	M                        ;Holding register has enough room for the conversion of
           JNZ	NINPUT                   ;Another digit. Ignore the input if no more room.
           MVI	L,OFS_INP_DIG_CNT                   ;If have room in register then set pointer to input digit
           MOV	B,M                      ;Counter location. Fetch the present value.
           INR	B                        ;Increment it to account for incoming digit.
           MOV	M,B                      ;Restore updated count to storage location.
           CALL	DECBIN                  ;Call the DECimal to BINary conversion routine to add
           JMP	NINPUT                   ;In the new digit in holding registers. Continue inputting.
PERIOD:	MOV	B,A                         ;Save character code in register B
           MVI	L,OFS_TEMP_STORE                   ;Set pointer to PERIOD indicator storage location
           MOV	A,M                      ;Fetch value in PERIOD indicator
           ANA	A                        ;Exercise CPU flags
           JNZ	NUMERR                   ;If already have a period then display error message
           MVI	L,OFS_INP_DIG_CNT                   ;If not, change pointer to digit counter storage location
           MOV	M,A                      ;Clear the digit counter back to zero
           INR	L                        ;Advance pointer to PERIOD indicator
           MOV	M,B                      ;Set the PERIOD indicator
           JMP	NINPUT                   ;Continue processing the input character string
FNDEXP:	CALL	GETINP                     ;Get next character in Exponent
           CPI	0ABH                     ;See if it is code for + sign
           JZ	EXPINP                    ;Jump ahead if yes.
           CPI	0ADH                     ;If not + sign, see if minus sign
           JNZ	NOEXPS                   ;If not minus sign then jump ahead
           MVI	L,OFS_SIGN_IND2+1                   ;For minus sign, set pointer to EXP SIGN indicator
           MOV	M,A                      ;Set the EXP SIGN indicator for a minus exponent
EXPINP:	CALL	GETINP                     ;Fetch the next character in the decimal exponent
NOEXPS:	ANA	A                           ;Exercise the CPU flags
           JZ	ENDINP                    ;If character inputted was zero, then end of input string
           CPI	0B0H                     ;If not end of string, check to see
           JM	NUMERR                    ;If character represents
           CPI	0BAH                     ;A valid decimal number (0 to 9)
           JP	NUMERR                    ;Display error message if not a valid digit at this point!
           ANI	00FH                     ;Else trim the ASCII code to BCD
           MOV	B,A                      ;And save in register B
           MVI	L,OFS_FP_WORK_6F                   ;Set pointer to input exponent storage location
           MVI	A,003H                   ;Set accumulator equal to three
           CMP	M                        ;See if any previous digit in exponent greater than three
           JM	NUMERR                    ;Display error message if yes
           MOV	C,M                      ;Else save any previous value in register C
           MOV	A,M                      ;And also place any previous value in accumulator
           ANA	A                        ;Clear the carry bit with this instruction
           RAL                          ;Single precision multiply by ten algorithm
           RAL                          ;Two rotate lefts equals times four
           ADD	C                        ;Adding in the digit makes total times five
           RAL                          ;Rotating left again equals times ten
           ADD	B                        ;now add in digit just inputted
           MOV	M,A                      ;Restore the value to exponent storage location
           JMP	EXPINP                   ;Go get any additional exponent int)ut
ENDINP:	MVI	L,OFS_SIGN_IND2                      ;Set pointer to mantissa SIGN indicator
           MOV	A,M                      ;Fetch the SIGN indicator to the acclimulator
           ANA	A                        ;Exercise the CPU flags
           JZ	FININP                    ;If SIGN indicator is zero, go finish up as nr is positive
           MVI	L,OFS_FP_WORK_6C                   ;But, if indicator is non-zero, number is negative
           MVI	B,003H                   ;Set pntr to LSW of storage registers, set precision entr
           CALL	COMPLM                  ;Negate the triple-precision number in holding registers
FININP:	MVI	L,OFS_FP_WORK_6B                      ;Set pointer to input storage LS~V minus one
           XRA	A                        ;Clear the accumulator
           MOV	M,A                      ;Clear the LSW minus one location
           MOV	D,H                      ;Set register D to floating point working page
           MVI	E,OFS_FPACC_LSW_M1                   ;Set E to address of FPACC LSW minus one
           MVI	B,004H                   ;Set precision counter
           CALL	MOVEIT                  ;Move number from input register to FPACC
           CALL	FPFLT                   ;Now convert the binary fixed point to floating point
           MVI	L,OFS_SIGN_IND2+1                   ;Set pointer to Exponent SIGN indicator location
           MOV	A,M                      ;Fetch the value of the EXP SIGN indicator
           ANA	A                        ;Exercise the CPU flags
           MVI	L,OFS_FP_WORK_6F                   ;Reset pointer to input exponent storage location
           JZ	POSEXP                    ;If EXP SIGN indicator zero, exponent is positive
           MOV	A,M                      ;Else, exponent is negative so must negate
           XRI	0FFH                     ;The value in the input exponent storage location
           ADI	001H                     ;By performing this two's complement
           MOV	M,A                      ;Restore the negated value to exponent storage location
POSEXP:	MVI	L,OFS_TEMP_STORE                      ;Set pointer to PERIOD indicator storage location
           MOV	A,M                      ;Fetch the contents of the PERIOD indicator
           ANA	A                        ;Exercise the CPU flags
           JZ	EXPOK                     ;If PERIOD indicator clear, no decimal point involved
           MVI	L,OFS_INP_DIG_CNT                   ;If have a decimal point, set pointer to digit counter
           XRA	A                        ;Storage location. Clear the accumulator.
           SUB	M                        ;And get a negated value of the digit counter in ACC
EXPOK:	MVI	L,OFS_FP_WORK_6F                       ;Change pointer to input exponent storage location
           ADD	M                        ;Add this value to negated digit counter value
           MOV	M,A                      ;Restore new value to storage location
           JM	MINEXP                    ;If new value is minus, skip over next subroutine
           RZ                           ;If new value is zero, no further processing required

                                  ;Following subroutine will multiply the floating point
                                  ;binary number stored in FPACC by ten tirnes the
                                  ;value stored in the deciinal exponent storage location.

FPX10:	MVI	L,OFS_OP_STKPTR                       ;Set pointer to registers containing floating point
           MVI	H,HIGH OLDPG1            ;** Binary representation of 10 (decimal).
           CALL	FACXOP                  ;Transfer FPACC to FPOP and 10 (dec) to FPACC
           CALL	FPMULT                  ;Multiply FPOP (formerly FPACC) by 10 (decimal)
           MVI	L,OFS_FP_WORK_6F                   ;Set pointer to decimal exponent storage location
           MOV	C,M                      ;Fetch the exponent value
           DCR	C                        ;Decrement
           MOV	M,C                      ;Restore to storage
           JNZ	FPX10                    ;If exponent value is not zero, continue multiplication
           RET                          ;When exponent is zero can exit. Conversion completed.

                                  ;Following subroutine will multiply the floating point
                                  ;binary number stored in PPACC by 0.1 times the value
                                  ;(negative) stored in the decimal exponent storage location

MINEXP:
FPD10:	MVI	L,OFS_FP_CONST_0P1                       ;Set pointer to registers containing floating point
           MVI	H,HIGH OLDPG1            ;** Binary representation of 0.1 (decimal).
           CALL	FACXOP                  ;Transfer FPACC to FPOP and 0.1 (dec) to FPACC
           CALL	FPMULT                  ;Multitply FPOP (formerly FPACC) by 0.1 (decimal)
           MVI	L,OFS_FP_WORK_6F                   ;Set pointer to decimal exponent storage location
           MOV	B,M                      ;Fetch the exponent value
           INR	B                        ;Increment
           MOV	M,B                      ;Restore to storage
           JNZ	FPD10                    ;If exponent value is not zero, continue multiplication
           RET                          ;When exponent is zero can exit. Conversion completed.

                                  ;Following subroutine is used
                                  ;to convert decimal charac-
                                  ;ters to binary fixed point forinat
                                  ;in a triple-precision format.

DECBIN:	CALL	SAVEHL                     ;Save entry value of D, E, H and L in memory
           MVI	L,OFS_FP_WORK_6B                   ;Set pointer to temporary storage location
           MOV	A,C                      ;Restore character inputted to accumulator
           ANI	00FH                     ;Trim ASCII code to BCD
           MOV	M,A                      ;Store temporarily
           MVI	E,OFS_FP_WORK_68                   ;Set pointer to working area LSW of multi-byte register
           MVI	L,OFS_FP_WORK_6C                   ;Set another pointer to LSW of conversion register
           MOV	D,H                      ;Make sure D set to page of working area
           MVI	B,003H                   ;Set precision counter
           CALL	MOVEIT                  ;Move original value of conversion register to working
           MVI	L,OFS_FP_WORK_6C                   ;Register. Reset pointer to LSW of conversion register.
           MVI	B,003H                   ;Set precision counter
           CALL	ROTATL                  ;Rotate register left, (Multiplies value by two.)
           MVI	L,OFS_FP_WORK_6C                   ;Reset pointer to LSW.
           MVI	B,003H                   ;Set precision counter
           CALL	ROTATL                  ;Multiply by two again (total now times four).
           MVI	E,OFS_FP_WORK_6C                   ;Set pointer to LSW of conversion register.
           MVI	L,OFS_FP_WORK_68                   ;Set pointer to LSW of working register (original value).
           MVI	B,003H                   ;Set precision counter.
           CALL	ADDER                   ;Add original value to rotated value (now times five).
           MVI	L,OFS_FP_WORK_6C                   ;Reset pointer to LSW
           MVI	B,003H                   ;Set precision counter
           CALL	ROTATL                  ;Multiply by two once more (total now times ten).
           MVI	L,OFS_FP_WORK_6A                   ;Set pointer to clear working register locatiotis
           XRA	A                        ;Clear the accumulator
           MOV	M,A                      ;Clear MSW of working register
           DCR	L                        ;Decrement pointer
           MOV	M,A                      ;Clear next byte
           MVI	L,OFS_FP_WORK_6B                   ;Set pointer to current digit storage location
           MOV	A,M                      ;Fetch the current digit
           MVI	L,OFS_FP_WORK_68                   ;Change pointer to LSW of working register
           MOV	M,A                      ;Deposit the current digit in LSW of working register
           MVI	E,OFS_FP_WORK_6C                   ;Set pointer to conversion register LSW
           MVI	B,003H                   ;Set precision counter
           CALL	ADDER                   ;Add current digit to conversion register to complete
           JMP	RESTHL                   ;Conversion. Exit to caller by restoring CPU registers.
FPOUT:	MVI	H,HIGH OLDPG1                ;** Set H to working area for floating point routines
           MVI	L,OFS_FP_WORK_6F                   ;Set pointer to decimal exponent storage location
           MVI	M,000H                   ;Initialize storage location to zero
           MVI	L,OFS_FPACC_MSW                   ;Change pointer to FPACC (number to be outputted)
           MOV	A,M                      ;And fetch MSW of FPACC
           ANA	A                        ;Test the contents of MSW of FPACC
           JM	OUTNEG                    ;If most significant bit of MSW is a one, have a minus nr.
           MVI	A,0A0H                   ;Else number is positive, set ASCII code for space for a
           JMP	AHEAD1                   ;Positive number and go display a space
OUTNEG:	MVI	L,OFS_FPACC                      ;If number in FPACC is negative must negate in order
           MVI	B,003H                   ;To display. Set pntr to LSW of FPACC & set prec. cntr.
           CALL	COMPLM                  ;Negate the number in the FPACC to make it positive
           MVI	A,0ADH                   ;But load ACC with ASCII code for minus sign
AHEAD1:	CALL	ECHO                       ;Call user display driver to output space or minus sign
           MVI	L,OFS_FP_MODE_IND                   ;Set pointer to FIXED/FLOAT indicator
           MOV	A,M                      ;Fetch value of FIXED/FLOAT indicator
           ANA	A                        ;Test contents of indicator. If contents are zero, calling
           JZ	OUTFLT                    ;Routine has directed floating point output format.
           MVI	L,OFS_FPACC_EXP                   ;If indicator non-zero, fixed point fonnat requested if
           MVI	A,017H                   ;Possible. Point to FPACC Exponent. Put 23 decimal in
           MOV	B,M                      ;Accumulator. Fetch FPACC Exponent into register B
           INR	B                        ;And exercise the register to test its
           DCR	B                        ;Original contents. If FPACC Exponent is negative in
           JM	OUTFLT                    ;Value then go to floating point output forrnat. If value
           SUB	B                        ;Is positive, subtract value from 23 (decimal). If result
           JM	OUTFLT                    ;Negative, number is too big to use fixed format.
           JMP	OUTFIX                   ;Else, can use fixed format so skip next routine
OUTFLT:	MVI	L,OFS_FP_MODE_IND                      ;Set pointer to FIXED/FLOAT indicator.
           MVI	M,000H                   ;Clear indicator to indicate floating point output format
           MVI	A,0B0H                   ;Load ASCII code for '0' into accumulator
           CALL	ECHO                    ;Call user display driver to output '0' as first character
           MVI	A,0AEH                   ;Number string. Now load ASCII code for decimal point.
           CALL	ECHO                    ;Call user display driver to output '.'as second character.
OUTFIX:	MVI	L,OFS_FPACC_EXP                      ;Set pointer to FPACC Exponent
           MVI	A,0FFH                   ;Load accumulator with minus one
           ADD	M                        ;Add value in FPACC Exponent
           MOV	M,A                      ;Restore compensated exponent value

                                  ;Next portion of routine establishes the value for the
                                  ;decimal exponent that will be outputted by processing
                                  ;the binary exponent value in the FPACC.

DECEXT:	JP	DECEXD                       ;If compensated exponent value is zero or positive
           MVI	A,004H                   ;Then go multiply FPACC by 0.1 (decimal). Else,
           ADD	M                        ;Add four to the exponent value.
           JP	DECOUT                    ;If exponent now zero or positive, ready to output
           MVI	L,OFS_OP_STKPTR                   ;If exponent negative, multiply FPACC by 10 (decimal)
           MVI	H,HIGH OLDPG1            ;** Set pointer to registers holding 10 (dec) in binary
           CALL	FACXOP                  ;Floating point format. Set up for multiplication.
           CALL	FPMULT                  ;Perform the multiplication. Answer in FPACC.
           MVI	L,OFS_FP_WORK_6F                   ;Set pointer to decimal exponent storage location.
           MOV	C,M                      ;Each time the FPACC is multiplied by ten, need to
           DCR	C                        ;Decrement the value in the decinial exponent storage
           MOV	M,C                      ;Location. (This establishes decimal exponent value!)
DECREP:	MVI	L,OFS_FPACC_EXP                      ;Reset pointer to FPACC Exponent
           MOV	A,M                      ;Fetch value in exponent
           ANA	A                        ;Test value
           JMP	DECEXT                   ;Repeat process as required
DECEXD:	MVI	L,OFS_FP_CONST_0P1                      ;If exponent is positive, multiply FPACC by 0.1
           MVI	H,HIGH OLDPG1            ;** Set pointer to registers holding 0.1 dec in binary
           CALL	FACXOP                  ;Floating point format. Set up for multipli(-ation.
           CALL	FPMULT                  ;Perform the multiplication. Answer in FPACC.
           MVI	L,OFS_FP_WORK_6F                   ;Set pointer to decimal exponent storage location.
           MOV	B,M                      ;Each time the FPACC is multiplied by one tenth, need
           INR	B                        ;To increment the value in the decimal exponent storage
           MOV	M,B                      ;Location. (This establishes decimal exponent value!)
           JMP	DECREP                   ;Repeat process as required

                                  ;The next section outputs the mantissa
                                  ;(or fixed point number) by converting the value remaining
                                  ;in the FPACC (after the decimal exponent equivalent has
                                  ;been extracted from the original value if required by the
                                  ;previous routines) to a string of decirnal digits.
DECOUT:	MVI	E,074H                      ;Set pointer to LSW of output working register
           MOV	D,H                      ;Set D to same page value as H
           MVI	L,OFS_FPACC                   ;Set pointer to LSW of FPACC
           MVI	B,003H                   ;Set precision counter
           CALL	MOVEIT                  ;Move value in FPACC to output working register
           MVI	L,OFS_FP_WORK_77                   ;Set pointer to MSW plus one of output working register
           MVI	M,000H                   ;Clear that location to 0
           MVI	L,OFS_FP_WORK_74                   ;Set pointer to LSW of output working register
           MVI	B,003H                   ;Set precision counter
           CALL	ROTATL                  ;Rotate register left once to compensate for sign bit
           CALL	OUTX10                  ;Multiply output register by 10, overflow into N4SW+ 1
COMPEN:	MVI	L,OFS_FPACC_EXP                      ;Set pointer back to FPACC Exponent
           MOV	B,M                      ;Compensate for any remainder in the binary exponent
           INR	B                        ;By performing a rotate right on the output working
           MOV	M,B                      ;Register until the binary exponent becomes zero
           JZ	OUTDIG                    ;Go output decimal digits when this loop is finished
           MVI	L,OFS_FP_WORK_77                   ;Binary exponent compensating loop. Setpointe'r to
           MVI	B,004H                   ;Working register MSW+L. Set precision counter.
           CALL	ROTATR                  ;Rotate working register to the right.
           JMP	COMPEN                   ;Repeat loop as required.
OUTDIG:	MVI	L,OFS_OUT_DIG_CNT                      ;Set pointer to output digit counter storage location
           MVI	M,007H                   ;Initialize to value of seven
           MVI	L,OFS_FP_WORK_77                   ;Change pointer to output working register MSW+L
           MOV	A,M                      ;Fetch MSW+L byte containing BCD of digit to be
           ANA	A                        ;Displayed. Test the contents of this byte.
           JZ	ZERODG                    ;If zero jump to ZERODG routine.
OUTDGS:	MVI	L,OFS_FP_WORK_77                      ;Reset pointer to working register MSW+L
           MOV	A,M                      ;Fetch BCD of digit to be outputted
           ANA	A                        ;Exercise CPU flags
           JNZ	OUTDGX                   ;If not zero, go display the digit
           MVI	L,OFS_FP_MODE_IND                   ;If zero, change pointer to FIXED/FLOAT indicator
           MOV	A,M                      ;Fetch the indicator into the accumulator
           ANA	A                        ;Test value of indicator
           JZ	OUTZER                    ;If in floating point mode, go display the digit
           MVI	L,OFS_FP_WORK_6F                   ;Else change pointer to decimal exponent storage
           MOV	C,M                      ;Location, which, for fixed point, will have a positive
           DCR	C                        ;Value for all digits before the decimal point. Decrement
           INR	C                        ;And increment to exercise flags. See if count is positive.
           JP	OUTZER                    ;If positive, must display any zero digit.
           MVI	L,OFS_FP_WORK_76                   ;If not, change pointer to MSW of working register
           MOV	A,M                      ;And test to see if any significant digits coming up
           ANI	0E0H                     ;By forming a mask and testing for presence of bits
           JNZ	OUTZER                   ;If more significant digits coming up soon, display the
           RET                          ;Zero digit. Else, exit to calling routine. Finished.
OUTZER:	XRA	A                           ;Clear the accumulator to restore zero digit value
OUTDGX:	ADI	0B0H                        ;Add 260 (octal) to BCD code in ACC to form ASCII
           CALL	ECHO                    ;Code and call the user's display driver subroutine
DECRDG:	MVI	L,OFS_FP_MODE_IND                      ;Set pointer to FIXED/FLOAT indicator storage
           MOV	A,M                      ;Fetch the indicator to the accumulator
           ANA	A                        ;Exercise the CPU flags
           JNZ	CKDECP                   ;If indicator non-zero, doing fixed point output
           MVI	L,OFS_OUT_DIG_CNT                   ;Else, get output digit counter
           MOV	C,M
           DCR	C                        ;Decrement the digit counter & restore to storage
           MOV	M,C
           JZ	EXPOUT                    ;When digit counter is zero, go take care of exponent
PUSHIT:	CALL	OUTX10                     ;Else push next BCD digit out of working register
           JMP	OUTDGS                   ;And continue the outputting process
CKDECP:	MVI	L,OFS_FP_WORK_6F                      ;For fixed point output, decimal exponent serves as
           MOV	C,M                      ;Counter for number of digits before decimal point
           DCR	C                        ;Fetch the counter and decrement it to account for
           MOV	M,C                      ;Current digit being processed. Restore to storage.
           JNZ	NODECP                   ;If count does not go to zero, jump ahead.
           MVI	A,0AEH                   ;When count reaches zero, load ASCII code for period
           CALL	ECHO                    ;And call user's display driver to display decimal point
NODECP:	MVI	L,OFS_OUT_DIG_CNT                      ;Set pointer to output digit counter storage location
           MOV	C,M                      ;Fetch the digit counter
           DCR	C                        ;Decrement the value
           MOV	M,C                      ;Restore to storage
           RZ                           ;If counter reaches zero, exit to caller. Finished.
           JMP	PUSHIT                   ;Else continue to output the number.
ZERODG:	MVI	L,OFS_FP_WORK_6F                      ;If first digit of floating point number is a zero, set
           MOV	C,M                      ;Pointer to decimal exponent storage location.
           DCR	C                        ;Decrement the value to compensate for skipping
           MOV	M,C                      ;Display of first digit. Restore to storage.
           MVI	L,OFS_FP_WORK_76                   ;Change pointer to MSW of output working register
           MOV	A,M                      ;Fetch MSW of output working register
           ANA	A                        ;Test the contents
           JNZ	DECRDG                   ;If non-zero, continue outputting
           DCR	L                        ;Else decrement pointer to next byte in working register
           MOV	A,M                      ;Fetch its contents
           ANA	A                        ;Test
           JNZ	DECRDG                   ;If non-zero, continue outputting
           DCR	L                        ;Else decrement pointer to LSW of working register
           MOV	A,M                      ;Fetch its contents
           ANA	A                        ;Test
           JNZ	DECRDG                   ;If non-zero, continue outputting
           MVI	L,OFS_FP_WORK_6F                   ;If decimal mantissa is zero, set pointer to decirnal
           MOV	M,A                      ;Exponent storage and clear it
           JMP	DECRDG                   ;Finish outputting

                                  ;Following routine multiplies the binary number in the
                                  ;output working register by ten to push the most signifi-
                                  ;cant digit out to the MSW+L byte.

OUTX10:	MVI	L,OFS_FP_WORK_77                      ;Set pointer to work ing register M SW+ 1
           MVI	M,000H                   ;Clear it in preparation for receiving next digit pushed
           MVI	L,OFS_FP_WORK_74                   ;Into it. Change pointer to working register LSW.
           MOV	D,H                      ;Set up register D to same page as H.
           MVI	E,070H                   ;Set second pointer to LSW of second working register
           MVI	B,004H                   ;Set precision counter
           CALL	MOVEIT                  ;Move first working register into second
           MVI	L,OFS_FP_WORK_74                   ;Reset pointer to LSW of first working register
           MVI	B,004H                   ;Set precision counter
           CALL	ROTATL                  ;Rotate contents of first working register left (X 2)
           MVI	L,OFS_FP_WORK_74                   ;Reset pointer to LSW
           MVI	B,004H                   ;Reset precision counter
           CALL	ROTATL                  ;Rotate contents left again (X 4)
           MVI	L,OFS_FP_WORK_70                   ;Set pointer to LSW of original value in 2'nd register
           MVI	E,074H                   ;Set pointer to LSW of rotated value
           MVI	B,004H                   ;Set precision counter
           CALL	ADDER                   ;Add rotated value to original value (X 5)
           MVI	L,OFS_FP_WORK_74                   ;Reset pointer to LSW of first working register
           MVI	B,004H                   ;Set precision counter
           CALL	ROTATL                  ;Rotate contents left again (X 10)
           RET                          ;Exit to calling routine

                                  ;The final group of routines in the floating point output
                                  ;section take care of outputting the decimal exponent
                                  ;portion of floating point numbers.

EXPOUT:	MVI	L,OFS_FP_WORK_6F                      ;Set pointer to decimal exponent storage location
           MOV	A,M                      ;Fetch value to the accumulator
           ANA	A                        ;Test the value
           RZ                           ;If zero, then no exponent portion. Exit to caller.
           MVI	A,0C5H                   ;Else, load ACC with ASCII code for letter E.
           CALL	ECHO                    ;Display E for Exponent via user's display driver rtn
           MOV	A,M                      ;Get decimal exponent value back into ACC
           ANA	A                        ;Test again
           JM	EXOUTN                    ;If value is negative, skip ahead
           MVI	A,0ABH                   ;If positive, load ASCII code for + sign
           JMP	AHEAD2                   ;Jump to display the + sign
EXOUTN:	XRI	0FFH                        ;When decimal exponent is negative, must negate
           ADI	001H                     ;Value for display purposes. Perform two's complement
           MOV	M,A                      ;And restore the negated value to storage location
           MVI	A,0ADH                   ;Load ASCII code for minus sign
AHEAD2:	CALL	ECHO                       ;Display the ASCII character in ACC
           MVI	B,000H                   ;Clear register B
           MOV	A,M                      ;Fetch the decimal exponent value back into ACC
SUB12:	SUI	00AH                         ;Subtract 10 (decimal) from value in ACC
           JM	TOMUCH                    ;Break out of loop when accumulator goes negative
           MOV	M,A                      ;Else restore value to storage location
           INR	B                        ;Increment register B as a counter
           JMP	SUB12                    ;Repeat loop to form tens value of decimal exponent
TOMUCH:	MVI	A,0B0H                      ;Load base ASCII value for digit into the accumulator
           ADD	B                        ;Add to the count in B to forin tens digit of decimal
           CALL	ECHO                    ;Exponent. Display via user's driver subroutine
           MOV	A,M                      ;Fetch remainder of decimal exponent value
           ADI	0B0H                     ;Add in ASCII base value to form final digit
           CALL	ECHO                    ;Display second digit of decirnal exponent
           RET                          ;Finished outputting. Return to caller.
;;; The above RETURN SHOULD BE AT 25 367

;;; NOW OPEN AREA UP TO 26 000 CAN BE USED FOR PATCHING...

	ORG	01600H
	DB	000H                                ; CC FOR INPUT LINE BUFFER
	DS	79                                  ; THE INPUT LINE BUFFER
	DB	000H,000H,000H,000H                 ; THESE ARE SYMBOL BUFFER STORAGE
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H                 ; SHOULD BE 26-120 TO 26 143
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H                 ; THESE LOCATIONS ARE AUXILIARY SYMBOL BUFFER
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H                 ; SHOULD BE 26 144 TO 26 175
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H
	DB	000H                                ; TEMP SCAN STORAGE REGISTER
	DB	000H                                ; TAB FLAG
	DB	000H                                ; EVAL CURRENT TEMP REG.
	DB	000H                                ; SYNTAX LINE NUMBER
	DB	000H                                ; SCAN TEMPORARY REGISTER
	DB	000H                                ; STATEMENT TOKEN
	DB	000H,000H                           ; TEMPORARY WORKING REGISTERS
	DB	000H,000H                           ; ARRAY POINTERS
;;; NOW WE SHOULD BE UP TO 26 210
	DB	000H                                ; OPERATOR STACK POINTER
	DS	15                                  ; OPERATOR STACK
	DB	000H                                ; FUN/ARRAY STACK POINTER
	DS	7                                   ; FUNCTION/ARRAY STACK
;;; THE LAST BYTE SHOULD HAVE BEEN 26 237


	;; HEIRARCHY TABLE (FOR OUT OF STACK OPS)
	;; USED BY PARSER ROUTINE.
;;; This SHOULD START AT 26 240
	DB	000H                                ; EOS
	DB	003H                                ; PLUS SIGN
	DB	003H                                ; MINUS SIGN
	DB	004H                                ; MULTIPLICATION SIGN
	DB	004H                                ; DIVISION SIGN
	DB	005H                                ; EXPONENT SIGN
	DB	006H                                ; LEFT PARENTHESIS
	DB	001H                                ; RIGHT PARENTHESIS
	DB	002H                                ; NOT ASSIGNED
	DB	002H                                ; LESS THAN SIGN
	DB	002H                                ; Equal sign
	DB	002H                                ; GREATER THAN SIGN
	DB	002H                                ; LESS THAN OR EQUAL COMBO
	DB	002H                                ; EQUAL OR GREATER THAN
	DB	002H                                ; LESS THAN OR GREATER THAN

	;; HEIRARCHY TABLE (FOR INTO STACK OPS)
	;; USED BY PARSER ROUTINE.
;;; This SHOULD START AT 26 257
	DB	000H                                ; EOS
	DB	003H                                ; PLUS SIGN
	DB	003H                                ; MINUS SIGN
	DB	004H                                ; MULTIPLICATION SIGN
	DB	004H                                ; DIVISION SIGN
	DB	005H                                ; EXPONENTIATION SIGN
	DB	001H                                ; LEFT PARENTHESIS
	DB	001H                                ; RIGHT PARENTHESIS
	DB	002H                                ; NOT ASSIGNED
	DB	002H                                ; LESS THAN SIGN
	DB	002H                                ; EQUAL SIGN
	DB	002H                                ; GREATER THAN SIGN
	DB	002H                                ; LESS THAN OR EQUAL SIGN
	DB	002H                                ; EQUAL TO OR GREATER THAN
	DB	002H                                ; LESS THAN OR GREATER THAN

	DB	000H                                ; EVAL START POINTER
	DB	000H                                ; EVAL FINISH POINTER

	;; FUNCTION NAMES TABLE
;;; This SHOULD START AT 26 300
	DB	003H
	DB	"INT"
	DB	003H
	DB	"SGN"
	DB	003H
	DB	"ABS"
	DB	003H
	DB	"SQR"
	DB	003H
	DB	"TAB"
	DB	003H
	DB	"RND"
	DB	003H
	DB	"CHR"
	DB	003H
	DB	"UDF"

	DB	000H,000H,000H,000H                 ; LINE NUMBER BUFFER STORAGE
	DB	000H,000H,000H,000H                 ; (SHOULD BE 340-347)
	DB	000H,000H,000H,000H                 ; AUX LINE NUMBER BUFFER
	DB	000H,000H,000H,000H                 ; (SHOULD BE 350-357)
;;; The following data is a change in page 3 of Scelbal update issue 4
;;; which apparently makes the "INSERT" command work correctly, the
;;; first time (later SCR commands load 33 into this spot) 
	DB	01BH                                ; USER PGM LINE PTR (PG)
	DB	000H                                ; USER PGM LINE PTR (LOW)
	DB	000H                                ; AUX PGM LINE PTR (PG)
	DB	000H                                ; AUX PGM LINE PTR (LOW)
	DB	000H                                ; END OF USER PGM BUFFER PTR (PG)
	DB	000H                                ; END OF USER PGM BUFFER PTR (LOW)
	DB	000H                                ; PARENTHESIS COUNTER (366)
	DB	000H                                ; QUOTE INDICATOR
	DB	000H                                ; TABLE COUNTER (370)
;;; locations 371-377 NOT ASSIGNED

	ORG	01700H
	DB	003H
	DB	"REM"
	DB	002H
	DB	"IF"
	DB	003H
	DB	"LET"
	DB	004H
	DB	"GOTO"
	DB	005H
	DB	"PRINT"
	DB	005H
	DB	"INPUT"
	DB	003H
	DB	"FOR"
	DB	004H
	DB	"NEXT"
	DB	005H
	DB	"GOSUB"
	DB	006H
	DB	"RETURN"
	DB	003H
	DB	"DIM"
	DB	003H
	DB	"END"
	DB	000H                                ; END OF TABLE, SHOULD BE 072

	DB	000H                                ; GOSUB STACK POINTER
	DS	1                                   ; NOT ASSIGNED;
	DB	000H                                ; NUMBER OF ARRAYS COUNTER
	DB	000H                                ; ARRAY POINTER
	DB	000H                                ; VARIABLES COUNTER SHOULD BE 077
	DB	000H,000H,000H,000H                 ; USED AS THE GOSUB STACK 100-117
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H                 ; USED AS ARRAY VARIABLES TABLE
	DB	000H,000H,000H,000H                 ; SHOULD BE 120-137
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H

	DB	000H,000H,000H,000H                 ; USED FOR FOR/NEXT STACK STORAGE
	DB	000H,000H,000H,000H                 ; SHOULD BE 140 TO 177
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H                                ; FOR/NEXT STACK POINTER
	DB	000H                                ; ARRAY/VARIABLE FLAG
	DB	000H                                ; STOSYM COUNTER
	DB	000H                                ; FUN/ARRAY STACK POINTER (203
	DB	000H                                ; ARRAY VALUES POINTER
	DS	3                                   ; NOT USED (SHOULD BE 205-207)
	DB	000H                                ; USED AS VARIABLES SYMBOL TABLE
	DS	119                                 ; (SHOULD BE 211-377 RESERVED)
;;; The above should cover 211 to 377
	;; THERE ARE NOW ADDRESSES AT START OF PAGE 30, NOT ASSIGNED;


;;; The following is PATCH NR.1
	ORG	01800H
PATCH1:	MVI	L,OFS_SYMBOL_BUF+3
	MVI	M,000H
	MVI	L,OFS_FPOP_EXT+3
	MVI	M,000H
	RET

	
	
	ORG	0180BH
	
NEXT:	MVI	L,OFS_FP_WORK+4                        ;Load L with start of AUX SYMBOL BUFFER
           MVI	H,HIGH OLDPG26           ;** Set H to page of AUX SYMBOL BUFFER
           MVI	M,000H                   ;Initialize AUX SYMBOL BUFFER by clearing first byte
           MVI	L,OFS_SCAN_PTR                   ;Change L to address of SCAN pointer
           MOV	B,M                      ;Fetch pointer value to CPU register B
           INR	B                        ;Add one to the current pointer value
           MVI	L,OFS_SYNTAX_PTR                   ;Load L with address of NEXT pointer storage location
           MOV	M,B                      ;Place the updated SCAN pointer as the NEXT pointer
NEXT1:	MVI	L,OFS_SYNTAX_PTR                       ;Reset L to address of NEXT pointer storage location
           CALL	GETCHR                  ;Fetch the character pointed to by the NEXT pointer
           JZ	NEXT2                     ;If the character is a space, ignore it
           MVI	L,OFS_FP_WORK+4                   ;Else, load L with start of AUX SYMBOL BUFFER
           CALL	CONCT1                  ;Concatenate the character onto the AUX SYMBOL BF
NEXT2:	MVI	L,OFS_SYNTAX_PTR                       ;Reset L to address of NEXT pointer storage location
           CALL	LOOP                    ;Advance the NEXT pointer and see if end of line
           JNZ	NEXT1                    ;Fetch next character in line if not end of line
           MVI	L,OFS_FP_WORK+4                   ;When reach end of line, should have variable name
           MOV	A,M                      ;In the AUX SYMBOL BUFFER. Fetch the (cc) for
           CPI	001H                     ;The buffer and see if variable name is just one letter
           JNZ	NEXT3                    ;If more than one proceed directly to look for name
           MVI	L,OFS_FP_WORK_66                   ;In FOR/NEXT STACK. If have just a one letter name
           MVI	M,000H                   ;Then set second character in buffer to zero
NEXT3:	MVI	L,OFS_TEMP_085                       ;Load L with address of FOR/NEXT STACK pointer
           MVI	H,HIGH OLDPG27           ;** Set H to page of FOR/NEXT STACK pointer
           MOV	A,M                      ;Fetch the FOR/NEXT STACK pointer value to ACC
           RLC                          ;Rotate value left to multiply by two. Then rotate it
           RLC                          ;Left again to multiply by four. Add base address plus
           ADI	05EH                     ;Two to form pointer to variable name in top of stack
           MVI	H,HIGH OLDPG27           ;** Set H to page of FOR/NEXT STACK
           MOV	L,A                      ;Move pointer value from ACC to CPU register L
           MVI	D,HIGH OLDPG26           ;** Set register D to page of AUX SYMBOL BUFFER
           MVI	E,065H                   ;Set register E to first character in the buffer
           MVI	B,002H                   ;Set B to serve as a character counter
           CALL	STRCPC                  ;See if variable name in the NEXT statement same as
           JZ	NEXT4                     ;That stored in the top of the FOR/NEXT STACK
FORNXT:	MVI	A,0C6H                      ;Load ACC with ASCII code for letter F
           MVI	C,0CEH                   ;Load register C with ASCII code for letter N
           JMP	ERROR                    ;Display For/Next (FN) error message if required
NEXT4:	MVI	L,OFS_TEMP_F0                       ;Load L with address of user program line pointer
           MVI	H,HIGH OLDPG26           ;** Load H with page of user pgm line pntr storage loc.
           MOV	D,M                      ;Fetch the page portion of the line pointer into D
           INR	L                        ;Advance the memory pointer
           MOV	E,M                      ;Fetch the low portion of the line pointer into E
           INR	L                        ;Advance pntr to AUXILIARY LINE POINTER storage
           MOV	M,D                      ;Location and store value of line pointer there too (page)
           INR	L                        ;Advance pointer to second byte of AUXILIARY line
           MOV	M,E                      ;Pointer and store value of line pointer (low portion)
           MVI	L,OFS_TEMP_085                   ;Load L with address of FOR/NEXT STACK pointer
           MVI	H,HIGH OLDPG27           ;** Set H to page of FOR/NEXT STACK pointer
           MOV	A,M                      ;Fetch the FOR/NEXT STACK pointer value to ACC
           RLC                          ;Rotate value left to multiply by two. Then rotate it
           RLC                          ;Left again to multiply by four. Add base address to
           ADI	05CH                     ;Form pointer to top of FOR/NEXT STACK and place
           MOV	L,A                      ;The pointer value into CPU register L. Fetch the page
           MOV	D,M                      ;Address of the associated FOR statement line pointer
           INR	L                        ;Into register D. Advance the pointer and fetch the low
           MOV	E,M                      ;Address value into register E. Prepare to change user
           MVI	L,OFS_TEMP_F0                   ;Program line pointer to the FOR statement line by
           MVI	H,HIGH OLDPG26           ;** Setting H & L to the user pgrn line pntr storage loc.
           MOV	M,D                      ;Place the page value in the pointer storage location
           INR	L                        ;Advance the memory pointer
           MOV	M,E                      ;Place the low value in the pointer storage location
           MOV	H,D                      ;Now set up H and L to point to the start of the
           MOV	L,E                      ;Associated FOR statement line in the user pgm buffer
           MVI	D,HIGH OLDPG26           ;** Change D to point to the line input buffer
           MVI	E,OFS_LINE_INP_BUF                   ;And set L to the gtart of the line input buffer
           CALL	MOVEC                   ;Move the associated FOR statement line into the input
           MVI	L,OFS_KW_TO                   ;Line buffer. Set L to point to start of TO string which is
           MVI	H,HIGH OLDPG1            ;** Stored in a text strings storage area on this page
           CALL	INSTR                   ;Search the statement line for the occurrence of TO
           MOV	A,E                      ;Register E will be zero if TO not found. Move E to ACC
           ANA	A                        ;To make a test. If TO found then proceed to set up for
           JZ	FORNXT                    ;Evaluation. If TO not found, then have error condition.
           ADI	002H                     ;Advance the pointer over the characters in TO string
           MVI	L,OFS_EVAL_PTR                   ;Change L to point to EVAL pointer storage location
           MVI	H,HIGH OLDPG26           ;** Set H to page of EVAL pointer. Set up the starting
           MOV	M,A                      ;Position for the EVAL subroutine (after TO string)
           MVI	L,OFS_KW_STEP                   ;Set L to point to start of STEP string which is stored
           MVI	H,HIGH OLDPG1            ;** In text stxings storage area on this page. Search the
           CALL	INSTR                   ;Statement line for the occurrence of STEP
           MOV	A,E                      ;Register E will be zero if STEP not found. Move E to
           ANA	A                        ;The accumulator to make a test. If STEP found must
           JNZ	NEXT5                    ;Evaluate expression after STEP to get STEP SIZE.
           MVI	L,OFS_FP_CONST_1                   ;Else, have an IMPLIED STEP SIZE of 1.0. Set pointer
           MVI	H,HIGH OLDPG1            ;** To start of storage area for 1.0 in floating point
           CALL	FLOAD                   ;Format and call subroutine to load FPACC with 1.0
           MVI	L,OFS_FN_STEP                   ;Set L to start of FOR/NEXT STEP SIZE storage loc.
           CALL	FSTORE                  ;Store the value 1.0 in the F/N STEP SIZE registers
           MVI	L,OFS_LINE_INP_BUF                   ;Change L to the start of the input line buffer
           MVI	H,HIGH OLDPG26           ;** Set H to the page of the input line buffer
           MOV	B,M                      ;Fetch the (cc) into CPU register B (length of FOR line)
           MVI	L,OFS_EVAL_FINISH                   ;Change L to EVAL FINISH pointer stomge location
           MOV	M,B                      ;Set the EVAL FINISH pointer to the end of the line
           CALL	EVAL                    ;Evaluate the LIMIT expression to obtain FOR LIMIT
           MVI	L,OFS_FN_LIMIT                   ;Load L with address of start of F/N LIMIT registers
           MVI	H,HIGH OLDPG1            ;** Load H with page of FOR/NEXT LIMIT registers
           CALL	FSTORE                  ;MGA 3/31/12 no lab here Store the FOR/NEXT LIMIT value
           JMP	NEXT6                    ;Since have IMPLIED STEP jump ahead
NEXT5:	DCR	E                            ;MGA 3/21/12 lab here When have STEP directive, subtract one from pointer
           MVI	L,OFS_EVAL_FINISH                   ;To get to character before S in STEP. Save this value in
           MVI	H,HIGH OLDPG26           ;** The EVAL FINISH pointer stomge location to serve
           MOV	M,E                      ;As evaluation end location when obtaining TO Iiinit
           CALL	EVAL                    ;Evaluate the LIMIT expression to obtain FOR LIMIT
           MVI	L,OFS_FN_LIMIT                   ;Load L with address of start of FIN LIMIT registers
           MVI	H,HIGH OLDPG1            ;** Load H with page of FORINEXT LIMIT registers
           CALL	FSTORE                  ;Store the FOR/NEXT LIMIT value
           MVI	L,OFS_EVAL_FINISH                   ;Reset L to EVAL FINISH pointer storage location
           MVI	H,HIGH OLDPG26           ;** Set H to page of EVAL FINISH pointer storage loc.
           MOV	A,M                      ;Fetch the pointer value (character before S in STEP)
           ADI	005H                     ;Add five to change pointer to character after P in STEP
           DCR	L                        ;Decrement L to point to EVAL (start) pointer
           MOV	M,A                      ;Set up the starting position for the EVAL subroutine
           MVI	L,OFS_LINE_INP_BUF                   ; Load L with starting address of the line input buffer
           MOV	B,M                      ;Fetch the (cc) for the line input buffer (line length)
           MVI	L,OFS_EVAL_FINISH                   ;Change L to the EVAL FINISH storage location
           MOV	M,B                      ;Set the EVAL FINISH pointer
           CALL	EVAL                    ;Evaluate the STEP SIZE expression
           MVI	L,OFS_FN_STEP                   ;Load L with address of start of F/N STEP registers
           MVI	H,HIGH OLDPG1            ;** Set H to page of FIN STEP registers
           CALL	FSTORE                  ;Store the FOR/NEXT STEP SIZE value
NEXT6:	MVI	L,OFS_FP_WORK+4                       ;Load L with address of AUX SYMBOL BUFFER
           MVI	H,HIGH OLDPG26           ;** Set H to page of the AUX SYMBOL BUFFER
           MVI	M,000H                   ;Initialize AUX SUMBOL BUFFER with a zero byte
           MVI	L,OFS_SCRATCH_PAD1+4                   ;Set L to start of FOR string which is stored in the
           MVI	H,HIGH OLDPG27           ;** KEYWORD look-up table on this page
           CALL	INSTR                   ;Search the statement line for the FOR directive
           MOV	A,E                      ;Register E will be zero if FOR not found. Move E to
           ANA	A                        ;ACC and -make test to see if FOR directive located
           MVI	L,OFS_SCAN_PTR                   ;Load L with address of SCAN pointer
           MVI	H,HIGH OLDPG26           ;** Load H with page of SCAN pointer
           MOV	M,A                      ;Set up pointer to occurrence of FOR directive in line
           JZ	FORNXT                    ;If FOR not found, have an error condition
           ADI	003H                     ;If have FOR, add three to advance pointer over FOR
           MVI	L,OFS_TOKEN_STORE                   ;Set L to point to F/N pointer storage location
           MOV	M,A                      ;Set F/N pointer to character after FOR directive
NEXT7:	MVI	L,OFS_TOKEN_STORE                       ;Set L to point to FIN pointer storage location
           CALL	GETCHR                  ;Fetch a character from position pointed to by FIN pntr
           JZ	NEXT8                     ;If character is a space, ignore it
           CPI	0BDH                     ;Else, test to see if character is "=" sign
           JZ	NEXT9                     ;If yes, have picked up variable name, jump ahead
           MVI	L,OFS_FP_WORK+4                   ;If not, set L to the start of the AUX SYMBOL BUFFER
           CALL	CONCT1                  ;And store the character in the AUX SYMBOL BUFFER
NEXT8:	MVI	L,OFS_TOKEN_STORE                       ;Load L with address of the F/N pointer
           CALL	LOOP                    ;Increment the pointer and see if end of the line
           JNZ	NEXT7                    ;If not, continue fetching characters
           JMP	FORNXT                   ;If end of line before "=" sign then have error condx
NEXT9:	MVI	L,OFS_SCAN_PTR                       ;Load L with address of SCAN pointer
           MVI	H,HIGH OLDPG26           ;** Load H with page of SCAN pointer
           MOV	A,M                      ;Fetch pointer value to ACC (points to start of FOR
           ADI	003H                     ;Directive) and add three to move pointer over FOR
           MVI	L,OFS_EVAL_PTR                   ;Directive. Change L to EVAL pointer storage location
           MOV	M,A                      ;Set EVAL pointer to character after FOR in line
           MVI	L,OFS_TOKEN_STORE                   ;Load L with address of FIN pointer storage location
           MOV	B,M                      ;Fetch pointer to register B (points to "=" sign) and
           DCR	B                        ;Decrement the pointer (to character before "=" sign)
           MVI	L,OFS_EVAL_FINISH                   ;Load L with address of EVAL FINISH pointer
           MOV	M,B                      ;Set EVAL FINISH pointer
           CALL	EVAL                    ;Call subroutine to obtain current value of the variable
           MVI	L,OFS_FN_STEP                   ;Load L with address of start of F/N STEP registers
           MVI	H,HIGH OLDPG1            ;** Set H to page of F/N STEP registers
           CALL	FACXOP                  ;Call subroutine to set up FP registers for addition
           CALL	FPADD                   ;Add FIN STEP size to current VARIABLE value
           MVI	L,OFS_FN_TEMP                   ;Load L with address of FIN TEMP storage registers
           MVI	H,HIGH OLDPG1            ;**Set H to page of FIN TEMP storage registers
           CALL	FSTORE                  ;Save the result of the addition in F/N TEMP registers
           MVI	L,OFS_FN_LIMIT                   ;Load L with starting address of F/N LIMIT registers
           CALL	FACXOP                  ;Call subroutine to set up FP registers for subtraction
           CALL	FPSUB                   ;Subtract F/N LIMIT value from VARIABLE value
           MVI	L,OFS_FN_STEP_C6                   ;Set pointer to MSW of F/N STEP registers
           MOV	A,M                      ;Fetch this value into the ACC
           ANA	A                        ;Test to see if STEP value might be zero
           MVI	L,OFS_FPACC_MSW                   ;Load L with address of MSW of FPACC
           MOV	A,M                      ;Fetch this value into the ACC
           JZ	FORNXT                    ;If STEP size was zero, then endless loop, an error condx
           JM	NEXT11                    ;If STEP size less than zero make alternate test on limit
           ANA	A                        ;Test the contents of the MSW of the FPACC
           JM	NEXT12                    ;Continue FORINEXT loop if current variable value is
           JZ	NEXT12                    ;Less than or equal to the F/N LIMIT value
NEXT10:	MVI	L,OFS_TEMP_F3                      ;If out of LIMIT range, load L with address of the AUX
           MVI	H,HIGH OLDPG26           ;** PGM LINE pointer. (Contains pointer to the NEXT
           MOV	E,M                      ;Statement line that initiated this routine.) Fetch the
           DCR	L                        ;Low part of the address into E, decrement the memory
           MOV	D,M                      ;And get the page part of the address into CPU register
           DCR	L                        ;Decrement memory pointer to the low portion of the
           MOV	M,E                      ;User pgm buffer line pointer (regular pointer) and set it
           DCR	L                        ;With the value from the AUX line pntr, decrement the
           MOV	M,D                      ;Pointer and do the same for the page portion
           MVI	L,OFS_TEMP_085                   ;Set L to address of FOR/NEXT STACK pointer
           MVI	H,HIGH OLDPG27           ;** Set H to page of FOR/NEXT STACK pointer
           MOV	B,M                      ;Fetch and decrement the
           DCR	B                        ;FOR/NEXT STACK pointer value
           MOV	M,B                      ;To perform effective popping operation
           JMP	NXTLIN                   ;Statement line after NEXT statement is done next
NEXT11:	ANA	A                           ;When F/N STEP is negative, reverse test so that if the
           JP	NEXT12                    ;Variable value is greater than or equal to the F/N LIMIT
           JMP	NEXT10                   ;The FOR/NEXT loop continues. Else it is finished.
NEXT12:	MVI	L,OFS_FN_TEMP                      ;Load L with address of FIN TEMP storage registers
           MVI	H,HIGH OLDPG1            ;** Set H to FIN TEMP storage registers page
           CALL	FLOAD                   ;Transfer the updated variable value to the FPACC
           CALL	RESTSY                  ;Restore the variable name and value
           CALL	STOSYM                  ;In the VARIABLES table. Exit routine so that
           JMP	NXTLIN                   ;Statement line after FOR statement is done next

;;; The label BACKSP SHOULD BE AT 31 217

BACKSP:	MVI	A,08DH                      ;Load ASCII code for carriage-return into the ACC
           CALL	ECHO                    ;Display the carriage-return
           CALL	ECHO                    ;Repeat to provide extra time if TTY
           MVI	L,OFS_COL_COUNTER                   ;Load L with address of COLUMN COUNTER
           MVI	H,HIGH OLDPG1            ;** Set H to page of COLUMN COUNTER
           MVI	M,001H                   ;Set COLUMN COUNTER to first column
           MVI	L,OFS_FPACC                   ;Set L to address containing desired TAB position
           MOV	A,M                      ;Fetch the desired TAB position value
           ANA	A                        ;Test to see if it is
           RM                           ;Negative or zero
           RZ                           ;In which case return to caller
           JMP	TAB1                     ;Else, proceed to perform the TAB operation.

	
;;; The label FOR5 SHOULD START AT 31 246
	
FOR5:	MVI	L,OFS_TEMP_085                        ;Load L with address of the FOR/NEXT STACK pointer
           MVI	H,HIGH OLDPG27           ;** Load H with page of the FOR/NEXT STACK pntr
           MOV	A,M                      ;Fetch the stack pointer to the ACC.
           RLC                          ;Rotate it left to multiply by two, then rotate it again to
           RLC                          ;Multiply by four. Add this value to the base address
           ADI	05EH                     ;Plus two of the base address to point to the next part of
           MOV	E,A                      ;The FOR/NEXT STACK. Place this value in register E.
           MOV	D,H                      ;Set D to the FORINEXT STACK area page.
           MVI	L,OFS_FP_WORK_65                   ;Load L with the address of the first character in the
           MVI	H,HIGH OLDPG26           ;** AUX SYMBOL BUFFER and set up H to this page.
           MVI	B,002H                   ;Set up register B as a number of bytes to move counter.
           CALL	MOVEIT                  ;Move the variable name into the FOR/NEXT STACK.
           CALL	STOSYM                  ;Store initial variable value in the VARIABLES TABLE.
           JMP	NXTLIN                   ;Continue with next line in user program buffer.


;;; The label PARSEP SHOULD START AT 31 300
PARSEP:	MVI	L,OFS_PARSER_TOKEN                      ;Load L with PARSER TOKEN storage location. Set
           MVI	M,000H                   ;The value indicating end of expression. Call the
           CALL	PARSER                  ;PARSER subroutine for final time for the expression.
           MVI	L,OFS_ARITH_STKPTR                   ;Change L to point to the ARITH STACK pointer.
           MVI	H,HIGH OLDPG1            ;** Set H to the page of the ARITH STACK pointer.
           MOV	A,M                      ;Fetch the ARITH STACK pointer value.
           CPI	098H                     ;Should indicate only one value (answer) in stack.
           RZ                           ;Exit with answer in FPACC if ARITH STACK is O.K.
           JMP	SYNERR                   ;Else have a syntax error!
	
	
;;; THERE IS SOME BLANK ADDRESSES HERE 317-NEXT PAGE
	

	ORG	01A00H
SQRX:	MVI	L,OFS_FP_TEMP                        ;Load L with address of FP TEMP registers
           MVI	H,HIGH OLDPG1            ;** Set H to page of FP TEMP. Move contents of FPACC
           CALL	FSTORE                  ;[Argument of SQR(X)] into FP TEMP for storage.
           MVI	L,OFS_FPACC_MSW                   ;Load L with MSW of FPACC
           MOV	A,M                      ;Fetch the MSW into the accumulator
           ANA	A                        ;Check the sign of the number in the FPACC
           JM	SQRERR                    ;If number negative, cannot take square root
           JZ	CFALSE                    ;If number is zero, return with zero value in FPACC
           MVI	L,OFS_FP_TEMP_0F                   ;Load L with address of FP TEMP Exponent register
           MOV	A,M                      ;Fetch the Exponent value into the ACC
           ANA	A                        ;Check sign of the Fxponent
           JM	NEGEXP                    ;If Exponent less than zero, process negative Exponent
           RAR                          ;If Exponent positive, rotate right to divide by two
           MOV	B,A                      ;And save the result in CPU register B
           MVI	A,000H                   ;Clear the accumulator without disturbing Carry bit
           RAL                          ;Rotate Carry bit into the ACC to save remainder
           MOV	M,A                      ;Store the remainder back in FP TEMP Exponent reg.
           JMP	SQREXP                   ;Jump to continue processing
NEGEXP:	MOV	B,A                         ;For negative Exponent, form two Is complement by
           XRA	A                        ;Placing the positive value in CPU register B, clearing
           SUB	B                        ;The accumulator, and then subtracting B from the ACC
           ANA	A                        ;Clear the Carry bit after the complementing operation
           RAR                          ;Rotate the value right to divide by two
           MOV	B,A                      ;Save the result in CPU register B
           MVI	A,000H                   ;Clear the accumulator without disturbing Carry bit
           ADC	A                        ;Add Carry bit to the accumulator as remainder
           MOV	M,A                      ;Store the remainder back in FP TEMP Exponent reg
           JZ	NOREMD                    ;If remainder was zero skip ahead. If not, increment the
           INR	B                        ;Result of the divide by two ops to compen for negative
NOREMD:	XRA	A                           ;Clear the accumulator
           SUB	B                        ;Subtract the quotient of the divide by two op to
           MOV	B,A                      ;Form two's complement and save the result in register B
SQREXP:	MVI	L,OFS_EXP_COUNTER                      ;Load L with address of TEMP register
           MOV	M,B                      ;Store Fxponent quotient from above ops in TEMP
           MVI	L,OFS_FP_CONST_1                   ;Load L with address of FP registers containing +1.0
           MVI	E,01CH                   ;Load E with address of SQR APPROX working registers
           MOV	D,H                      ;Set D to same page as H
           MVI	B,004H                   ;Set up register B as a number of bytes to move counter
           CALL	MOVEIT                  ;Transfer value +1.0 into SQR APPROX registers
           CALL	CFALSE                  ;Now clear the FPACC registers
           MVI	L,OFS_COL_024                   ;Load L with address of LAST SQR APPROX temp regs.
           CALL	FSTORE                  ;Initialize the LAST SQR APPROX regs to value of zero
SQRLOP:	MVI	L,OFS_SCRATCH_PAD1+4                      ;Load L with address of SQR APPROX working registers
           CALL	FLOAD                   ;Transfer SQR APPROX into the FPACC
           MVI	L,OFS_FP_TEMP                   ;Load L with address of SQR ARG storage registers
           CALL	OPLOAD                  ;Transfer SQR ARG into the FPOP
           CALL	FPDIV                   ;Divde SQR ARG by SQR APPROX (Fon-n X/A)
           MVI	L,OFS_SCRATCH_PAD1+4                   ;Load L with address of SQR APPROX registers
           CALL	OPLOAD                  ;Transfer SQR APPROX into the FPOP
           CALL	FPADD                   ;Add to form value (X/A + A)
           MVI	L,OFS_FPACC_EXP                   ;Load L with address of FPACC Exponent register
           MOV	B,M                      ;Fetch Exponent value into CPU register B
           DCR	B                        ;Subtract one to effectively divide FPACC by two
           MOV	M,B                      ;Restore to memory. (Now have ((X/A + A) /2)
           MVI	L,OFS_SCRATCH_PAD1+4                   ;Load L with address of SQR APPROX registers
           CALL	FSTORE                  ;Store contents of FPACC as new SQR APPROX
           MVI	L,OFS_COL_024                   ;Load L with address of LAST SQR APPROX registers
           CALL	OPLOAD                  ;Transfer LAST SQR APPROX into the FPOP
           CALL	FPSUB                   ;Subtract (LAST SQR APPROX - SQR APPROX)
           MVI	L,OFS_FPACC_EXP                   ;Load L with address of FPACC Exponent
           MOV	A,M                      ;Fetch the Exponent into the accumulator
           CPI	0F7H                     ;See if difference less than 2 to the minus ninth
;;; The below is changed for PATCH 2
;;; following is the original code
;;;           JTS SQRCNV             ;If so, approximation has converged
;;; Now is the new line
	   JMP	PATCH2
;;;;           DCL
;;;;           LAM
;;;;           NDA
;;;;           JTZ SQRCNV             ;THIS IS PATCH #2
SQR1:	MVI	L,OFS_SCRATCH_PAD1+4                        ;Else, load L with address of SQR APPROX
           MOV	D,H                      ;Set D to same page as H
           MVI	E,024H                   ;And E with address of LAST SQR APPROX
           MVI	B,004H                   ;Set up register B as a number of bytes to move counter
           CALL	MOVEIT                  ;Transfer SQR APPROX into LAST SQR APPROX
           JMP	SQRLOP                   ;Continue ops until approximation converges
SQRCNV:	MVI	L,OFS_EXP_COUNTER                      ;Load L with address of TEMP register. Fetch the
           MOV	A,M                      ;Exponenent quotient store there into accumulator.
           MVI	L,OFS_SCRATCH_1F                   ;Change L to point to SQR APPROX exponent.
           ADD	M                        ;Add SQR APPROX exponent to quotient value.
           MOV	M,A                      ;Store sum back in SQR APPROX Exponent register.
           MVI	L,OFS_SCRATCH_PAD1+4                   ;Load L with address of SQR APPROX. Transfer the
           JMP	FLOAD                    ;SQR APPROX into FPACC as answer and exit.
SQRERR:	MVI	A,0D3H                      ;Load ASCII code for letter S into the accumulator.
           MVI	C,0D1H                   ;Load ASCII code for letter Q into CPU register C.
           JMP	ERROR                    ;Display the SQuare root (SQ) error message.
;;; above instruction starts at 223
;;; some blank addresses available here.
	ORG	01AA0H
RNDX:	MVI	L,OFS_SCRATCH_PAD2                        ;Load L with address of SEED storage registers
           MVI	H,HIGH OLDPG1            ;** Set H to page for floating point working registers
           CALL	FLOAD                   ;Transfer SEED into the FPACC
           MVI	L,OFS_RND_CONST1                   ;Load L with address of random constant A
           CALL	OPLOAD                  ;Transfer random constant A into the FPOP
           CALL	FPMULT                  ;Multiply to form (SEED * A)
           MVI	L,OFS_RND_CONST2                   ;Load L with address of random constant C
           CALL	OPLOAD                  ;Transfer random constant C into the FPOP
           CALL	FPADD                   ;Add to fom (SEED * A) + C
           MVI	L,OFS_SCRATCH_PAD2                   ;Load L with address of SEED storage registers
           CALL	FSTORE                  ;Store I (SEED * A) + C] in former SEED registers
           MVI	L,OFS_FPACC_EXP                   ;Load L with address of FPACC Exponent register
           MOV	A,M                      ;Fetch Exponent value into the accumulator
           SUI	010H                     ;Subtract 16 (decimal) to effectively divide by 65,536
           MOV	M,A                      ;Now FPACC = [((SEED * A) + C)/65,536]
           CALL	FPFIX                   ;Convert floating to fixed point to obtain integer part
           MVI	L,OFS_SYMBOL_BUF+3                   ;Load L with address of FPACC Extension register
           MVI	M,000H                   ;Clear the FPACC Extension register
           MVI	L,OFS_FPACC_EXP                   ;Load L with address of FPACC Exponent
           MVI	M,000H                   ;Clear the FPACC Exponent register
           CALL	FPFLT                   ;Fetch INT(((SEED * A) + C)/65,536) into the FPACC
           MVI	L,OFS_FPACC_EXP                   ;Load L with address of FPACC Exponent
           MOV	A,M                      ;Fetch FPACC Exponent into the accumulator
           ADI	010H                     ;Add 16 (decimal) to effectively multiply by 65,536
           MOV	M,A                      ;(65,536 * INT[ ((SEED * A) + C)/65,5361) in FPACC
           MVI	L,OFS_SCRATCH_PAD2                   ;Load L with address of [(SEED * A) + C]
           CALL	OPLOAD                  ;Transfer it into FPOP. Subtract FPACC to form
           CALL	FPSUB                   ;[(SEED * A) + C] MOD 65,536
           MVI	L,OFS_SCRATCH_PAD2                   ;Load L with address of former SEED registers
           CALL	FSTORE                  ;Store SEED MOD 65,536 in place of [(SEED * A) + Cl
           MVI	L,OFS_FPACC_EXP                   ;Load L with address of FPACC Exponent
           MOV	A,M                      ;Fetch FPACC Exponent into the ACC and subtract
           SUI	010H                     ;16 (decimal) to form (SEED MOD 65,536)/65,536
           MOV	M,A                      ;So that random number in FPACC is between
           RET                          ;0.0 and +1.0 and exit to calling routine
;;; THE ABOVE RETURN SHOULD BE 32 351
	

;;; NOTE OPEN ADDRESSES TO END OF PAGE 32

;;; following is PATCH 2
	ORG	01AF4H
PATCH2:	JM	SQRCNV
	DCR	L
	MOV	A,M
	ANA	A
	JZ	SQRCNV
	JMP	SQR1
;;; The above jump should start at 32 375
	

	;; PAGES 33 TO REMAINDER OF MEMORY
	;; OR START OF OPTIONAL ARRAY HANDLING
	;; ROUTINES USED AS USER PROGRAM BUFFER



	;; OPTIONAL ARRAY ROUTINES ASSEMBLED FOR OPERATION
	;; IN THE UPPER 3 PAGES OF A 12K SYSTEM ARE LISTED HERE.

	ORG	02D00H
	
PRIGH1:	MVI	L,OFS_FPACC_MSW                      ;Load L with address of the MSW in the FPACC
           MVI	H,HIGH OLDPG1            ;** Set H to page of FPACC
           MOV	A,M                      ;Fetch MSW of FPACC into the ACC.
           ANA	A                        ;Test to see if value in FPACC is positive.
           JM	OUTRNG                    ;If not, go display error message.
           CALL	FPFIX                   ;If O.K. then convert floating point to fixed point
           MVI	L,OFS_FPACC                   ;Load L with address of LSAL of converted value
           MOV	A,M                      ;Fetch the LSW of the value into the ACC
           SUI	001H                     ;Subtract one from the value to establish proper
           RLC                          ;Origin for future ops. Now rotate the value twice
           RLC                          ;To effectively multiply by four. Save the
           MOV	C,A                      ;Calculated result in CPU register C
           MVI	L,OFS_TOKEN_STORE                   ;Load L with address of F/A STACK TEMP
           MVI	H,HIGH OLDPG27           ;** Load H with page of F/A STACK TEMP
           MOV	A,M                      ;Fetch the value into the accumulator
           XRI	0FFH                     ;Complement the value
           RLC                          ;Rotate the value twice to multiply by four (the number
           RLC                          ;Of bytes per entry in the ARRAY VARIABLES table).
           ADI	050H                     ;Add the starting address of the ARRAY VARIABLES
           MVI	H,HIGH OLDPG27           ;** TABLE to forin pointer. Set page address in H.
           MOV	L,A                      ;Point to the name in the ARRAY VARIABLES
           INR	L                        ;Increment the pointer value twice to move over the
           INR	L                        ;Name in the table and point to starting address for the
           MOV	A,M                      ;Array values in the ARRAY VALUES table. Fetch this
           ADD	C                        ;Address to the ACC. Now add in the figure calculated
           MOV	L,A                      ;To reach desired subscripted data storage location. Set
           MVI	H,HIGH OLDPG57           ;tt The pointer to that location. Load the floating point
           JMP	FLOAD                    ;Value stored there into the FPACC and exit to caller.
	
	
;;; The label FUNAR2 SHOULD START AT 55-054
FUNAR2:	MVI	L,OFS_SCAN_PTR                      ;Load L with address of TEMP COUNTER
           MVI	H,HIGH OLDPG27           ;** Load H with page of counter
           MOV	B,M                      ;Fetch the counter value
           INR	B                        ;Increment the value
           MOV	M,B                      ;Restore the value to memory
           MVI	C,002H                   ;Initialize register C to a value of two for future ops
           MVI	L,OFS_ARRAY_VAR                   ;Load L with address of start of ARRAY VARIABLES
           MVI	H,HIGH OLDPG27           ;** TABLE (less four). Set H to page of the table.
           CALL	TABADR                  ;Calculate address of start of next narne in table.
           MVI	D,HIGH OLDPG26           ;** Load D with page of the SYMBOL BUFFER
           MVI	E,OFS_SYMBOL_BUF                   ;Set E to starting address of the SYMBOL BUFFER
           CALL	STRCP                   ;Compare name in ARRAY VARIABLES table to the
           JZ	FUNAR3                    ;Contents of the SYMBOL BUFFER. If match, go set up
           MVI	L,OFS_SCAN_PTR                   ;Array token value. Else, reset L to address of TEMP
           MVI	H,HIGH OLDPG27           ;** COUNTER. Set H to page of TEMP COUNTER.
           MOV	A,M                      ;Fetch the counter value into the accumulator.
           MVI	L,OFS_SYMVAR_CNT-2                   ;Change L to number of arrays storage location.
           CMP	M                        ;Compare number of entries checked against number
           JNZ	FUNAR2                   ;Possible. Keep searching table if not finished.
           JMP	FAERR                    ;If finished and no match than have F/A error condx.
FUNAR3:	MVI	L,OFS_SCAN_PTR                      ;Load L with address of TEMP COUNTER
           MVI	H,HIGH OLDPG27           ;** Load H with page of counter.
           XRA	A                        ;Clear the accumulator. Subtract the value in the TEMP
           SBB	M                        ;COUNTER from zero to obtain two's complement.
           MOV	M,A                      ;Place this back in counter location as ARRAY TOKEN
           JMP	FUNAR4                   ;VALUE (negative). Go place the value on F/A STACK.
	

;;; The label OUTRNG STARTS AT 55 136
OUTRNG:	MVI	A,0CFH                      ;Load the ASCII code for letter 0 into the accumulator
           MVI	C,0D2H                   ;Load the ASCII code for letter R into register C
           JMP	ERROR                    ;Go display Out of Range (OR) error message.
	


	
ARRAY:	CALL	RESTSY                      ;Transfer contents of AUX SYMBOL BUFFER into the
           JMP	ARRAY2                   ;SYMBOL BUFFER. (Entry when have actual LET)
ARRAY1:	MVI	L,OFS_SCAN_PTR                      ;Load L with address of SCAN pointer
           JMP	ARRAY3                   ;Proceed to process. (Entry point for IMPLIED LET)
ARRAY2:	MVI	L,OFS_TOKEN_STORE                      ;Load L with address of LET pointer
ARRAY3:	MVI	H,HIGH OLDPG26              ;** Set H to pointer page
           MOV	B,M                      ;Fetch pointer to location where "(" found in statement
           INR	B                        ;Line. Increment it to point to next character in the line.
           MVI	L,OFS_EVAL_PTR                   ;Load L with address of EVAL pointer and load it with
           MOV	M,B                      ;The starting address for the EVAL routine
           MVI	L,OFS_ARRAY_SETUP                   ;Change L to address of ARRAY SETUP pointer
           MOV	M,B                      ;And also store address in that location
ARRAY4:	MVI	L,OFS_ARRAY_SETUP                      ;Load L with address of ARRAY SETUP pointer
           CALL	GETCHR                  ;Fetch character pointed to by ARRAY SETUP pntr
           CPI	0A9H                     ;See if character is ")" ? If so, then have located
           JZ	ARRAY5                    ;End of the subscript. If not, reset
           MVI	L,OFS_ARRAY_SETUP                   ;to the ARRAY SETUP pointer. Increment the
           CALL	LOOP                    ;Pointer and test for the end of the statement line.
           JNZ	ARRAY4                   ;If not end of line, continue looking for right paren.
           MVI	A,0C1H                   ;If reach end of line before right parenthesis than load
           MVI	C,0C6H                   ;ASCII code for letters A and F and display message
           JMP	ERROR                    ;Indicating Array Forrnat (AF) error condition
ARRAY5:	MVI	L,OFS_ARRAY_SETUP                      ;Load L with address of ARRAY SETUP pointer
           MOV	B,M                      ;Fetch pointer (pointing to ")"sign) into register B
           DCR	B                        ;Decrement it to move back to end of subscript number
           MVI	L,OFS_EVAL_FINISH                   ;Load L with address of EVAL FINISH pointer location
           MOV	M,B                      ;Place the pointer value in the EVAL FINISH pointer
           MVI	L,OFS_LOOP_COUNTER                   ;Load L with address of LOOP COUNTER
           MVI	M,000H                   ;Initialize LOOP COUNTER to value of zero
ARRAY6:	MVI	L,OFS_LOOP_COUNTER                      ;Load L with address of LOOP COUNTER
           MVI	H,HIGH OLDPG26           ;** Load H with page of LOOP COUNTER
           MOV	B,M                      ;Fetch the counter value
           INR	B                        ;Increment it
           MOV	M,B                      ;Restore the counter value to memory
           MVI	C,002H                   ;Set up counter in register C for future ops
           MVI	L,OFS_ARRAY_VAR                   ;Load L with address of start of ARRAY VARIABLES
           MVI	H,HIGH OLDPG27           ;** Table less four). Set H to page of the table.
           CALL	TABADR                  ;Calculate the address of next entry in the table
           MVI	E,OFS_SYMBOL_BUF                   ;Load register E with starting address of SYMBOL BUFF
           MVI	D,HIGH OLDPG26           ;** Set D to page of SYMBOL BUFFER
           CALL	STRCP                   ;Compare entry in table against contents of SYMBOL BF
           JZ	ARRAY7                    ;If match, have found array naine in the table.
           MVI	L,OFS_LOOP_COUNTER                   ;Else, set L to address of the LOOP COUNTER
           MVI	H,HIGH OLDPG26           ;** Set H to page of the LOOP COUNTER
           MOV	A,M                      ;Fetch the counter value to the ACC
           MVI	L,OFS_SYMVAR_CNT-2                   ;Change L to the counter containing number of arrays
           MVI	H,HIGH OLDPG27           ;** Set H to the proper page
           CMP	M                        ;Compare number of arrays to count in LOOP CNTR
           JNZ	ARRAY6                   ;If more entries in the table, continue looking for match
           JMP	FAERR                    ;If no matching name in table then have an error condx.
ARRAY7:	CALL	EVAL                       ;Call subroutine to evaluate subscript expression
           CALL	FPFIX                   ;Convert the subscript value obtained to fixed forrnat
           MVI	L,OFS_LOOP_COUNTER                   ;Load L with address of LOOP COUNTER
           MVI	H,HIGH OLDPG26           ;** Set H to page of the LOOP COUNTER
           MOV	B,M                      ;Fetch the value in the LOOP COUNTER into the ACC
           MVI	C,002H                   ;Set up counter in register C future ops
           MVI	L,OFS_ARRAY_VAR                   ;Load L with address of ARRAY VARIABLES
           MVI	H,HIGH OLDPG27           ;** Table less four). Set H to page of the table.
           CALL	TABADR                  ;Calculate the address of entry in the table
           INR	L                        ;Advance the ARRAY VARIABLES table pointer twice
           INR	L                        ;To advance pointer over array name.
           MOV	C,M                      ;Fetch array base address in ARRAY VALUES table
           MVI	L,OFS_FPACC                   ;Load L with address of subscript value
           MVI	H,HIGH OLDPG1            ;** Set H to page of subscript value
           MOV	A,M                      ;Fetch the subscript value into the accumulator
           SUI	001H                     ;Subtract one from subscript value to allow for zero
           RLC                          ;Origin. Now multiply by four
           RLC                          ;Using rotates (number of bytes required for each entry
           ADD	C                        ;In the ARRAY VALUES table). Add in base address to
           MVI	L,OFS_TEMP_ARRAY                   ;The calculated value to form final address in the
           MVI	H,HIGH OLDPG27           ;** ARRAY VALUES table. Now set H & L to TEMP
           MOV	M,A                      ;ARRAY ELEMENT storage location & store the addr.
           MVI	L,OFS_SYNTAX_PTR                   ;Change L to point to ARRAY FLAG
           MVI	M,0FFH                   ;Set the ARRAY FLAG for future use
           RET                          ;Exit to calling routine

	
;;; The label DIM SHOULD START AT 55 365
DIM:	CALL	CLESYM                        ;Initialize the SYMBOL BUFFER to cleared condition
           MVI	L,OFS_SCAN_PTR                   ;Load L with address of SCAN pointer
           MOV	B,M                      ;Fetch SCAN pointer value into register B
           INR	B                        ;Add one to the SCAN pointer value
           MVI	L,OFS_TOKEN_STORE                   ;Change L to DIM pointer (formerly TOKEN) storage
           MOV	M,B                      ;Store the updated SCAN pointer as the DIM pointer
DIM1:	MVI	L,OFS_TOKEN_STORE                        ;Load L with the address of DIM pointer storage location
           CALL	GETCHR                  ;Fetch a character from the line input buffer
           JZ	DIM2                      ;If character fetched is a space, ignore it
           CPI	0A8H                     ;Else see if character is "(" left parenthesis
           JZ	DIM3                      ;If so, should have ARRAY VARIABLE naine in buffer
           CALL	CONCTS                  ;If not, append the character to the SYMBOL BUFFER
DIM2:	MVI	L,OFS_TOKEN_STORE                        ;Load L with the address of DIM pointer stomge location
           CALL	LOOP                    ;Increment the pointer and see if end of line
           JNZ	DIM1                     ;If not end of line, fetch next character
           JMP	DIMERR                   ;Else have a DIMension error condition
DIM3:	MVI	L,OFS_ARRAY_SETUP                        ;Load L with address of ARRAY pointer storage loc
           MVI	M,000H                   ;Initialize ARRAY pointer to starting value of zero
DIM4:	MVI	L,OFS_ARRAY_SETUP                        ;Load L with address of ARRAY pointer storage loc
           MVI	H,HIGH OLDPG26           ;** Set H to page of ARRAY pointer storage location
           MOV	A,M                      ;Fetch value in ARRAY pointer to ACC (effectively
           RLC                          ;Represents number of arrays defined in pgm). Rotate
           RLC                          ;Left twice to multiply by four (niunber of bytes per
           ADI	04CH                     ;entry in ARRAY VARIABLES table). Add to base
           MVI	H,HIGH OLDPG27           ;** Address to form pointer to ARRAY VARIA.BLES
           MOV	L,A                      ;Table and set up H & L as the memory pointer.
           MVI	E,OFS_SYMBOL_BUF                   ;Load E with starting address of the SYMBOL BUFFER
           MVI	D,HIGH OLDPG26           ;** Load D with the page address of the SYMBOL BUFF
           CALL	STRCP                   ;Compare contents of SYMBOL BF to entry in ARRAY
           JZ	DIM9                      ;VARIABLES table. If same, have duplicate array name.
           MVI	L,OFS_ARRAY_SETUP                   ;Else, load L with address of ARRAY pointer storage
           MVI	H,HIGH OLDPG26           ;** Load H with page of ARRAY pointer storage
           MOV	B,M                      ;Fetch the ARRAY pointer value to register B
           INR	B                        ;Increment the value
           MOV	M,B                      ;Restore it to ARRAY pointer storage location
           MVI	L,OFS_SYMVAR_CNT-2                   ;Change L to number of arrays storage location
           MVI	H,HIGH OLDPG27           ;** Set H to page of the number of arrays stomge loc
           MOV	A,M                      ;Fetch the number of arrays value to the ACC
           DCR	B                        ;Restore B to previous count
           CMP	B                        ;Compare number of arrays tested against nr defined
           JNZ	DIM4                     ;If not equal, continue searching ARRAY VARIABLES
           MVI	L,OFS_SYMVAR_CNT-2                   ;Table. When table searched with no match, then must
           MVI	H,HIGH OLDPG27           ;** Append naine to table. First set pointer to number
           MOV	B,M                      ;Of arrays storage location. Fetch that value and
           INR	B                        ;Add one to account for new name being added.
           MOV	M,B                      ;Restore the updated value back to memory.
           MVI	L,OFS_ARRAY_TEMP                   ;Change pointer to ARRAY TEMP pointer storage
           MOV	M,B                      ;Store pointer to current array in ARRAY TEMP too.
           MVI	L,OFS_ARRAY_SETUP                   ;Load L with address of ARRAY pointer stomge loc.
           MVI	H,HIGH OLDPG26           ;** Set H to page of ARRAY pointer storage location
           MOV	M,B                      ;And update it also for new array being added.
           MOV	A,M                      ;Fetch the current ARRAY pointer value to the ACC
           RLC                          ;Multiply it times four by performing two rotate left
           RLC                          ;Operations and add it to base value to form address in
           ADI	04CH                     ;The ARRAY VARIABLES table. Place the low part
           MOV	E,A                      ;Of this calculated address value into register E.
           MVI	D,HIGH OLDPG27           ;** Set register D to the page of the table.
           MVI	L,OFS_SYMBOL_BUF                   ;Load L with the start of the SYMBOL BUFFER
           MVI	H,HIGH OLDPG26           ;** Load H with the page of the SYMBOL BUFFER
           CALL	MOVEC                   ;Move the array name from the SYMBOL BUFFER to
           CALL	CLESYM                  ;The ARRAY VARIABLES table. Then clear the
           MVI	L,OFS_TOKEN_STORE                   ;SYMBOL BUFFER. Reset L to the DIM pointer storage
           MVI	H,HIGH OLDPG26           ;** Location. Set H to the DIM pointer page.
           MOV	B,M                      ;Fetch the pointer value (points to "(" part of DIM
           INR	B                        ;Statement). Increment the pointer to next character in
           MVI	L,OFS_TEMP_ARRAY                   ;The line input buffer. Cbange L to DIMEN pointer.
           MOV	M,B                      ;Store the updated DIM pointer in DIMEN storage loc.
DIM5:	MVI	L,OFS_TEMP_ARRAY                        ;Set L to DIMEN pointer storage location
           CALL	GETCHR                  ;Fetch character in line input buffer
           JZ	DIM6                      ;Ignore character for space
           CPI	0A9H                     ;If not space, see if character is right parenthesis
           JZ	DIM7                      ;If yes, process DIMension size (array length)
           CPI	0B0H                     ;If not, see if character is a valid decimal number
           JM	DIMERR                    ;If not valid number, have DIMension error condition
           CPI	0BAH                     ;Continue testing for valid decitnal number
           JP	DIMERR                    ;If not valid number, then DIMension error condition
           CALL	CONCTS                  ;If valid decirnal number, append digit to SYMBOL BF
DIM6:	MVI	L,OFS_TEMP_ARRAY                        ;Set L to DIMEN pointer storage location
           CALL	LOOP                    ;Advance the pointer value and check for end of the line
           JNZ	DIM5                     ;If not end of line, continue fetching DIMension size
           JMP	DIMERR                   ;If end of line before right parenthesis, have error condx.
DIM7:	MVI	L,OFS_SYMBOL_BUF                        ;Load L with address of start of SYMBOL BUFFER
           MVI	H,HIGH OLDPG26           ;** Load H with page of SYMBOL BUFFER. (Now
           CALL	DINPUT                  ;Contains DIMension size.) Convert buffer to floating
           CALL	FPFIX                   ;Point number and then reformat to fixed point.
           MVI	L,OFS_FPACC                   ;Load L with address of LSW of fixed point number
           MOV	A,M                      ; And fetch the low order byte of the nr into the ACC
           RLC                          ;Rotate it left two tirnes to multiply it by four (the
           RLC                          ;Number of bytes required to store a floating point nr).
           MOV	C,A                      ;Store this value in CPU register C temporarily
           MVI	L,OFS_ARRAY_TEMP                   ;Set L to ARRAY TEMP storage location.
           MVI	H,HIGH OLDPG27           ;** Set H to ARRAY TEMP pointer page.
           MOV	A,M                      ;Fetch the value in ARRAY TEMP (points to ARRAY
           SUI	001H                     ;VARIABLES table). Subtract one from the pointer
           RLC                          ;Value and multiply the result by four using rotate left
           RLC                          ;Instructions. Add this value to a base address
           ADI	052H                     ;(Augmented by two) to point to ARRAY VALUES
           MOV	L,A                      ;Pointer storage location in the ARRAY VARIABLES
           MVI	H,HIGH OLDPG27           ;Table and set the pointer up in registers H & L.
           MOV	B,M                      ;Fetch the starting address in the ARRAY VALUES
           ADI	004H                     ;Table for the previous array into register B. Now add
           MOV	L,A                      ;Four to the ARRAY VARIABLES table pointer to
           MOV	A,B                      ;Point to curront ARRAY VALUES starting address.
           ADD	C                        ;Add the previous array starting address plus number of
           MOV	M,A                      ;Bytes required and store as starting loc for next array
DIM8:	MVI	L,OFS_TEMP_ARRAY                        ;Set L to address of DIMEN pointer storage location
           MVI	H,HIGH OLDPG26           ;** Set H to page of DIMEN pointer
           MOV	B,M                      ;Fetch pointer value (points to ") " in line)
           MVI	L,OFS_TOKEN_STORE                   ;Change L to DIM pointer storage location
           MOV	M,B                      ;Store former DIMEN value back in DIM pointer
DIM9:	MVI	L,OFS_TOKEN_STORE                        ;Load L with address of DIM pointer storage location
           CALL	GETCHR                  ;Fetch a character from the line input buffer
           CPI	0ACH                     ;See if character is a comma (,) sign
           JZ	DIM10                     ;If yes, have another array being defined on the line
           MVI	L,OFS_TOKEN_STORE                   ;If not, reset L to the DIM pointer
           CALL	LOOP                    ;Increment the pointer and see if end of the line
           JNZ	DIM9                     ;If not end of the line, keep looking for a comma
           JMP	NXTLIN                   ;Else exit the DIM statement routine to continue pgm
DIM10:	MVI	L,OFS_TOKEN_STORE                       ;Set L to DIM pointer storage location
           MOV	B,M                      ;Fetch pointer value (points to comma sign just found)
           MVI	L,OFS_SCAN_PTR                   ;Load L with address of SCAN pointer storage location
           MOV	M,B                      ;Place DIM pointer into the-SCAN pointer
           JMP	DIM                      ;Continue processing DIM statement line for next array
DIMERR:	MVI	A,0C4H                      ;On error condition, load ASCII code for letter D in ACC
           MVI	C,0C5H                   ;And ASCII code for letter E in CPU register C
           JMP	ERROR                    ;Go display the Dirnension Error (DE) message.

	




