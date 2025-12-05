; SCELBAL STRINGS SUPPLEMENT (8008)
; Extracted from SCELBAL Strings Supplement.pdf
; Copyright 1977 Scelbi Computer Consulting, Inc.
; Author: Mark Arnold
;
; Note: This is the assembled 8008 code extracted from
; the side-by-side 8008/8080 listing in the supplement.
;

EVAL:
	JMP EVALPC		; 03224: 104370051
EVALQ:
	LAA		; 03227: 300
	JMP SFAPCH		; 04021: 104015054
	JFZ SCANCP		; 04066: 110005 052
	RET		; 04140: 007
	RET		; 04203: 007
	LAA		; 04210: 300
	LAA		; 04211: 300
	LAA		; 04212: 300
	RET		; 04246: 007
	RET		; 04255: 007
	RET		; 04264: 007
	RET		; 04273: 007
	JMP STORP		; 10055: 104070052
STORP1:
	LAA		; 10060: 300
	JMP SCRPCH		; 11066: 104 265 053
	CAL INSTRP		; 13021: 106 347 053
	JMP PPRINT		; 14040: 104 124 053
	JMP PRINT4		; 14061: 104075014
	JTZ PPRIN7		; 14085: 150137053
PRINT5:
	JTZ POUTSF		; 14114: 152157053
	LAA		; 14206: 300
	LAA		; 14207: 300
	LAA		; 14210: 300
	LAA		; 14215: 300
	LAA		; 14216: 300
	LLI 203		; 14220: 066203
	JTZ PPRINT		; 14230: 150 124053
	LAA		; 14233: 300
	LAA		; 14234: 300
	LAA		; 14235: 300
	LLI203		; 14236: 066203
	CAL PINPUT		; 16365: 106315053
	JTZ INPUTS		; 17114: 150325 053
	LLI 375		; 17117: 066375
	LAM		; 17121: 307
	NDA		; 17122: 240
	JFZ INPUTS		; 17123: 110 325 053
	LMI 000		; 17126: 076000
	JMP INPUTN		; 17130: 104140017
	003/LEN		; 45360: 003
	314		; 45361: 314
	305		; 45362: 305
	003/ASC		; 45364: 003
	301		; 45365: 301
	323		; 45366: 323
	303		; 45367: 303
	003/VAL		; 45370: 003
	326		; 45371: 326
	301		; 45372: 301
	314		; 45373: 314
	003/CHR		; 45374: 003
	303		; 45375: 303
	310		; 45376: 310
	322		; 45377: 322
SEVAL:
	LLI017		; 46000: 066017  Load L with address of NOCONCAT flag
	LHI045		; 46002: 056045  $$ Load H with string page
	LMI 000		; 46004: 076000  Reset NOCANCAT flag
	INL		; 46006: 060     Register L points to STRACC (CC)
	LMI 000		; 46007: 076000  Clear STRACC
	LLI002		; 46011: 066002  Load L with address of SUBSTR pointer
	LMI 001		; 46013: 076001  Put 1 in SUBSTR pointer
	INL		; 46015: 060     Point to SUBSTR length
	LMI377		; 46016: 076377  Put -1 in SUBSTR length (whole string)
	INL		; 46020: 060     Point to string FUNCTION TOKEN
	LMI000		; 46021: 076000  Initialize to zero
	CAL CLESYM		; 46023: 106255002  Clear the symbol table
	LLI 375		; 46026: 066375  Load L with address of SMODE
	LMI 001		; 46030: 076001  Set SMODE to string
	LLI276		; 46032: 066276  Load L with address of EVAL start
	LBM		; 46034: 317     Load start and stop into B and C
	INL		; 46035: 060
	LCM		; 46036: 327
	LLI 376		; 46037: 066376  Load L with address of TEMP SEVAL start
	LMB		; 46041: 371     And stop pointers and put old eval pointers
	INL		; 46042: 060     There from B and C
	LMC		; 46043: 372
	LLI371		; 46044: 066 371  Load L with address of SEVAL SCAN pointer
	LMB		; 46046: 371     Put start of EVAL pointer in SEVAL SCAN pointer
SEVAL1:
	LLI371		; 46047: 066371  Load L with address of SEVAL SCAN pointer
	LHI026		; 46051: 056026  ** Load H with pointer page
	CAL GETCHR		; 46053: 106240002  Get character pointed to by SEVAL pointer
	JTZ FSEVAL		; 46056: 150047050  Ignore space
	CPI247		; 46061: 074247  Is character a single quote (') ?
	JTZ SEVAL2		; 46063: 150073 046  If so, have text literal
	CPI 242		; 46066: 074242  Is character a double quote (") ?
	JFZ SEVAL5		; 46070: 110 162 046  If not, test for other characters
SEVAL2:
	LLI367		; 46073: 066367  Load L with address of quote type
	LMA		; 46075: 370  Store opening quote there
	LLI371		; 46076: 066371  Load L with address of SEVAL pointer
	LBM		; 46100: 317  Add 1 to SEVAL pointer
	INB		; 46101: 010
	INL		; 46102: 060  Load L with address of text pointer
	LMB		; 46103: 371  Store SEVAL POINTER +1 there
SEVAL3:
	LLI372		; 46104: 066 372  Load L with address of LITERAL pointer
	CAL GETCHR		; 46106: 106240002  Get character pointed to by LITERAL pointer
	LLI367		; 46111: 066367  Load L with address of quote type
	CPM		; 46113: 277  Is character the closing quote?
	JTZ SEVAL4		; 46114: 150143046  If so, finish up
	LLI020		; 46117: 066020  Load L with address of STRACC
	CAL CONCT1		; 46123: 106314002  Concatenate character onto STRACC
	LLI372		; 46126: 066 372  Load L with address of LITERAL pointer
	CAL SELOOP		; 46132: 106 243050  Loop until end of SEVAL
	JFZ SEVAL3		; 46135: 110104046  Done yet?
	JMP IQERR		; 46140: 104060052  If no closing quote, error
SEVAL4:
	LLI372		; 46143: 066372  Load L with address of LITERAL pointer
	LBM		; 46145: 317  Load LITERAL pointer into B
	LLI 371		; 46146: 066 371  Put LITERAL pointer in SEVAL pointer
	LMB		; 46150: 371
	LLI017		; 46151: 066 017  Load L with address of NOCANCAT flag
	LMI 001		; 46155: 076001  Set NOCANCAT flag to prevent concat
	JMP FSEVAL		; 46157: 104047050  Continue with string eval
SEVAL5:
	CPI244		; 46162: 074244  Is character a $ ?
	JFZ SEVAL6		; 46164: 110331 046  If not, keep testing
	LEI 374		; 46167: 046374  Load E with address of CHR string
	LLI120		; 46173: 066 120  Load L with address of SYMBOL
	CAL STRCP		; 46175: 106332002  Test if symbol = CHR
	JTZ CHR		; 46200: 150 236 046  If it does, have CHR function
	LAM		; 46207: 307  Get SYMBOL (CC)
	CPI001		; 46210: 074001  Is (CC) = 1?
	JFZ STERR		; 46212: 110051 052  If not, can't be legal string
	INL		; 46215: 060  L points to first character of symbol
	LAM		; 46216: 307  Get string name
	LLI 000		; 46217: 066000  Load L with address of SVAR name
	LMA		; 46223: 370  Put string name in SVAR name
	INL		; 46224: 060  Point to SVAR SUBSCRIPT
	LMI001		; 46225: 076001  Put 1 in SVAR SUBSCRIPT
	CAL CLESYM		; 46227: 106255002  Clear the symbol
	JMP FSEVAL		; 46232: 104047050  Continue with string eval
CHR:
	LBM		; 46237: 317  Add 1 to SEVAL pointer
	INB		; 46240: 010
	LMB		; 46241: 371
	LLB		; 46242: 361  Load L with SEVAL pointer
	LAM		; 46243: 307  Get character pointed to by SEVAL pointer
	CPI250		; 46244: 074250  Is character a parenthesis "("?
	JFZ CHR		; 46246: 110235046  If not, keep looking
	LLI276		; 46251: 066 276  Load L with address of start of EVAL pointer
	INB		; 46253: 010  Add one to skip over "("
	LMB		; 46254: 371  Start numeric evaluation just beyond "("
	LDB		; 46255: 331  Put pointer to beyond "(" in D
	LLI377		; 46256: 066377  Load L with address of end of SEVAL pointer
	LEM		; 46260: 347  Load E with end of SEVAL pointer
	CAL PARNB		; 46261: 106 325 051  Find balancing parenthesis between D and E
	LLI277		; 46264: 066277  Load L with address of end of EVAL pointer
	DCB		; 46266: 011  Subtract 1 from pointer to balance parenthesis
	LMB		; 46267: 371  Put pointer just before to balance parenthesis end pntr
	CAL EVALS		; 46270: 106376051  Evaluate numeric expression between parenthesis
	CAL FPFIX		; 46273: 106000020  Convert the FP ACC to fixed point
	LLI124		; 46276: 066124  Load L with address of FPACC LSW
	LAM		; 46300: 307  Get fixed byte
	LLI 020		; 46301: 066020  Load L with address of STRACC
	INB		; 46322: 010
	LLI371		; 46323: 066371  Load L with address of SEVAL pointer
	LMB		; 46325: 371  Store 1 + end of EVAL pointer there
SEVAL6:
	CPI250		; 46331: 074250		Is character a "(" ?
	LLI371		; 46336: 066 371	Load L with address of SEVAL pointer
	LDM		; 46340: 337		Load D with pointer to "("
	LLI377		; 46342: 066 377	Load L with address of end of SEVAL pointer
	LEM		; 46344: 347		Load E with end of SEVAL pointer
	CAL PARNB		; 46345: 106325051	Balance parenthesis
	LMB		; 46352: 371		Store pointer to balancing parenthesis there
	LBM		; 46354: 317		Add 1 to SEVAL pointer
	LLB		; 46356: 361		Point to SEVAL pointer +1 after "("
	LAM		; 46357: 307		Get character just after "("
	CPI272		; 46360: 074272		Test if it is a colon ":"
	JFZ SEVA16		; 46362: 110373 046	If not colon, keep looking
	LLI373		; 46365: 066373		Load L with address of COLON pointer
	LMB		; 46367: 371		Store pointer to ":" in COLON pointer
	JMP SEVA10		; 46370: 104 124047	Continue to test for substring
SEVA16:
	LLI373		; 46373: 066373		Load L with address of COLON pointer
	LMB		; 46375: 371		Store pointer to just after "(" in COLON pointer
SEVAL7:
	CAL GETCHR		; 47000: 106240002	Get character pointed to by COLON pointer
	CPI272		; 47003: 074272		Is character a colon ":" ?
	JFZ SEVAL8		; 47005: 110047047	If not, keep looking
	LLI371		; 47010: 066371		Load L with address of SEVAL pointer
	LBM		; 47012: 317		Add 1 to SEVAL pointer
	INB		; 47013: 010
	LLI276		; 47014: 066276		Load L with address of start of EVAL pointer
	LMB		; 47016: 371		Store SEVAL pointer in start of EVAL pointer
	LLI373		; 47017: 066373		Load L with address of COLON pointer
	LBM		; 47021: 317		Subtract 1 from COLON pointer
	DCB		; 47022: 011
	LMB		; 47025: 371		Load L with address of end of EVAL pointer
	CAL EVALS		; 47026: 106376051	Evaluate expression between "(" and ":"
	CAL FPFIX		; 47031: 106000020	Fix floating point value of expression
	LLI124		; 47034: 066124		Load L with address of LSW of FPACC
	LAM		; 47036: 307		Get fixed byte
	LMA		; 47037: 370		Store subscript in SVAR
	JMP SEVA10		; 47044: 104124047	Continue subscripted substringing
SEVAL8:
	LLI373		; 47047: 066373		Load L with address of COLON pointer
	CAL S2LOOP		; 47051: 106254050	Loop until before "("
	JFZ SEVAL7		; 47054: 110 376046	Continue if not done
SEVAL9:
	LLI 371		; 47057: 066 371	Load L with address of SEVAL pointer
	LBM		; 47061: 317		Add 1 to SEVAL pointer
	INB		; 47062: 010
	LCM		; 47064: 327		Pointer to balance PARENTHESIS pointer
	DCC		; 47065: 021		Subtract 1 from PARENTHESIS pointer
	LLI276		; 47066: 066276		Load L with address of start of EVAL pointer
	LMB		; 47070: 371		Start EVAL after "("
	INL		; 47071: 060		Finish EVAL pointer
	LMC		; 47072: 372		Finish EVAL before ")"
	CAL FPFIX		; 47076: 106000020	Convert subscript to fixed byte
	LLI124		; 47101: 066124		Load L with address of fixed byte
	LAM		; 47103: 307		Get it
	LLI 001		; 47104: 066001		Load L with address of SVAR SUBSCRIPT
	LMA		; 47110: 370		Put subscript there
	LLI 372		; 47111: 066 372	Load L with address of BAL PARN pntr
	LBM		; 47115: 317		Get pointer to BAL PARN
	LLI371		; 47116: 066371		Load L with address of SEVAL pointer
	LMB		; 47120: 371		Put BAL PARN pointer there to skip over subscript
	JMP FSEVAL		; 47121: 104047050	Continue with string evaluation
SEVA10:
	LLI 373		; 47124: 066373		Load L with address of COLON pointer
	LBM		; 47130: 317		Add 1 to COLON pointer
	INB		; 47131: 010
	INL		; 47132: 060		SEMICOLON pointer
	LMB		; 47133: 371		Start looking for ";" after ":"
SEVA11:
	LLI374		; 47134: 066374		Load L with address of SEMICOLON pointer
	CAL GETCHR		; 47136: 106240002	Get character pointed to by SEMICOLON pointer
	CPI273		; 47141: 074273		Is character a semicolon ";" ?
	JFZ SEVA12		; 47143: 110251047	If not, keep looking
	LLI373		; 47146: 066373		Load L with address of COLON pointer
	LBM		; 47150: 317		Add 1 to COLON pointer
	INB		; 47151: 010
	INL		; 47152: 060		Point to SEMICOLON pointer
	LCM		; 47153: 327		Subtract 1 from SEMICOLON pointer
	DCC		; 47154: 021
	LLI276		; 47155: 066 276	Load L address at start of EVAL pointer
	LMB		; 47157: 371		Start EVAL after ":"
	INL		; 47160: 060		End of EVAL pointer
	LMC		; 47161: 372		End EVAL before ";"
	CAL EVALS		; 47162: 106376051	Evaluate SUBSTR pointer between ":" and ";"
	CAL FPFIX		; 47165: 106 000020	Convert it to fixed
	LLI124		; 47170: 066 124	Load L address of fixed byte
	LAM		; 47172: 307		Get it
	LLI002		; 47173: 066002		Load L with address of SUBSTR pointer
	LMA		; 47177: 370		Put SUBSTR pointer there
	LLI374		; 47200: 066 374	Load L with address of SEMICOLON pointer
	LBM		; 47204: 317		Add 1 to SEMICOLON pointer
	INB		; 47205: 010
	LLI372		; 47206: 066372		Load L address to BAL PARN pointer
	LCM		; 47210: 327		Subtract 1 from BAL PARN pointer
	DCC		; 47211: 021
	LLI 276		; 47212: 066276		Load L with start of EVAL pointer
	LMB		; 47214: 371		Start EVAL just after ";"
	INL		; 47215: 060		Finish EVAL pointer
	LMC		; 47216: 372		Finish EVAL before ")"
	CAL EVALS		; 47217: 106376051	Evaluate substring length
	CAL FPFIX		; 47222: 106000020	Convert it to fixed byte
	LLI124		; 47225: 066124		Load L with address of FIXED byte
	LAM		; 47227: 307		Get it
	LLI 003		; 47230: 066003		Load L with address of SUBSTR length
	LMA		; 47234: 370		Put SUBSTR length there
	LLI372		; 47235: 066372		Load L with address of BAL PARN pointer
	LBM		; 47241: 317		Get BAL PARN pointer
	DCL		; 47242: 061		SEVAL pointer
	LMB		; 47243: 371		Put BAL PARN pointer there to skip over (..)
	JMP FSEVAL		; 47244: 104047050	Continue to evaluate string expression
SEVA12:
	CAL S2LOOP		; 47251: 106 254050	Loop until just before ")"
	JFZ SEVA11		; 47254: 110134047	If not done, continue
	LLI373		; 47257: 066373		Load L with address of COLON pointer
	LBM		; 47261: 317		Add 1 to COLON pointer
	INB		; 47262: 010
	DCL		; 47263: 061		BAL PARN pointer
	LCM		; 47264: 327		Subtract 1 from BAL PARN pointer
	DCC		; 47265: 021
	LLI276		; 47266: 066276		Load L with start of EVAL pointer
	LMB		; 47270: 371		Start EVAL after ":"
	INL		; 47271: 060		Finish EVAL pointer
	LMC		; 47272: 372		Finish EVAL before ")"
	CAL EVALS		; 47273: 106376051	Evaluate between ":" and ")"
	CAL FPFIX		; 47276: 106000020	Fix SUBSTR pointer to byte
	LAM		; 47303: 307		Get it
	LLI002		; 47304: 066002		Load L with address of SUBSTR pointer
	LMA		; 47310: 370		Put SUBSTR pointer there
	INL		; 47311: 060		SUBSTR length
	LMI377		; 47312: 076377		Put -1 in SUBSTR length for whole string
	LLI 372		; 47314: 066 372	Load L with address of BAL PARN pointer
	LBM		; 47320: 317		Get BAL PARN pointer
	DCL		; 47321: 061		SEVAL pointer
	LMB		; 47322: 371		Put BAL PARN pointer in SEVAL pointer, skip (..)
	JMP FSEVAL		; 47323: 104 047 050	Continue with string evaluation
SEVA13:
	CPI 253		; 47326: 074 253	Is character a "+" (concatenate operation)?
	JFZ SEVA14		; 47330: 110351047	If not, keep looking
	LLI017		; 47333: 066017		Load L with address of NOCANCAT flag
	LHI045		; 47335: 070045		$$ Load H with STRING page
	LAM		; 47337: 307		Get NOCONCAT flag
	LMI000		; 47340: 076000		Reset NOCONCAT flag
	NDA		; 47342: 240		Is NOCONCAT flag set?
	JTZ CONCAT		; 47343: 152350050	If not, concatenate latest string
	JMP FSEVAL		; 47346: 104047050	Continue with string evaluation
SEVA14:
	LLI371		; 47351: 066371		Load L with address of SEVAL pointer
	LBM		; 47353: 317		Get SEVAL pointer
	LLI200		; 47354: 066200		Load L with address of EVAL pointer
	LMB		; 47356: 371		Put SEVAL pointer there
	CAL LTEQGT		; 47357: 106042052	Test for comparison operations
	LLI176		; 47362: 066 176	Load L with address of PARSE pointer
	LBM		; 47364: 317		Get token to tell if found comparison operation
	INB		; 47365: 010		Exercise B to see if found operation
	DCB		; 47366: 011
	JTZ SEVA15		; 47367: 150044050	If no operation found, concatenate scan character
	LAB		; 47372: 301		Get TOKEN into A
	SUI 010		; 47373: 024010		Subtract 8 from TOKEN
	LLI004		; 47375: 066004		Load L with address of STRING TOKEN
	LHI045		; 47377: 070045		$$ Load H with STRING page
	LMA		; 50001: 370		Put STRING TOKEN there
	LLI017		; 50002: 066 017	Load L with address of NOCANCAT flag
	LAM		; 50004: 307		Get NOCANCAT flag
	LMI 000		; 50005: 076000		Reset NOCANCAT flag
	NDA		; 50007: 240		Test NOCANCAT flag
	JTZ CONCAT		; 50010: 152350050	If not set, concatenate last string on STRACC
	LHI045		; 50013: 070045		$$ Load H with STRING page
	LLI020		; 50015: 066020		Load L with address of STRACC
	LDH		; 50017: 335		Load H with STRING page
	LEI 140		; 50020: 046140		Load L with address of string compare string
	CAL MOVEC		; 50022: 106046012	Save STRACC for later comparison
	LLI020		; 50025: 066020		Load L with address of STRACC
	LMI 000		; 50027: 076000		Clear the STRACC
	LLI200		; 50031: 066200		Load L with address of EVAL pointer
	LHI026		; 50033: 070026		** Load H with pointer page
	LBM		; 50035: 317		Get EVAL pointer
	LLI 371		; 50036: 066 371	Load L with address of SEVAL pointer
	LMB		; 50040: 371		Put EVAL pointer there
	JMP FSEVAL		; 50041: 104047050	Continue with string evaluation
SEVA15:
	CAL CONCTS		; 50044: 106310002	Concatenate character onto symbol
FSEVAL:
	LLI371		; 50047: 066371		Load L with address of SEVAL pointer
	LHI026		; 50051: 070026		** Load H with pointer page
	CAL SELOOP		; 50053: 106243050	Loop until end of string expression
	JFZ SEVAL1		; 50056: 110047046	If not done, continue
	LLI017		; 50061: 066017		Load L with address of NOCANCAT flag
	LHI045		; 50063: 070045		$$ Load H with STRING page
	LAM		; 50065: 307		Get NOCANCAT flag
	NDA		; 50066: 240		Test NOCANCAT flag
	JTZ CONCAT		; 50067: 152350050	If not set, concatenate last string
	LLI 376		; 50072: 066376		Load L with address of TEMP SEVAL start pointers
	LHI026		; 50074: 070026		** Load H with pointer page
	LBM		; 50076: 317		Get start of EVAL pointer
	INL		; 50077: 060		End of SEVAL pointer
	LCM		; 50100: 327		Get end of SEVAL pointer
	LLI276		; 50101: 066276		Load L with address of start of EVAL pointer
	LMB		; 50103: 371		Restore start and end of EVAL pointers
	INL		; 50104: 060
	LMC		; 50105: 372
	LLI004		; 50106: 066004		Load L with address of STRING TOKEN
	LHI045		; 50110: 070045		$$ Load H with STRING page
	LAM		; 50112: 307		Get STRING TOKEN
	NDA		; 50113: 240		Is STRING TOKEN 0?
	RTZ		; 50114: 053		Return if it is
	LLI375		; 50115: 066375		Load L with address of SMODE
	LHI026		; 50117: 070026		** Load H with pointer page
	LMI 000		; 50121: 076000		Set SMODE back to numeric
	LLI140		; 50123: 066140		Load L with address of string comparison string
	LHI045		; 50125: 070045		$$ Load H with STRING page
	LDH		; 50127: 335		Load D with STRING page
	LEI 020		; 50130: 046020		Load E with address of STRACC
	CPI001		; 50132: 074001		Is STRING TOKEN for LT?
	JFZ STC1		; 50134: 110 147 050	If not, try something else
	CAL SSTRCP		; 50137: 106267050	Compare string comparison string with STRACC
	LHI001		; 50142: 070001		** Load H with floating point page
	JMP LT1		; 50144: 104 130 006	Go to special less than entry point for test
STC1:
	CPI002		; 50147: 074002		Other token matching routines similar to above
	JFZ STC2		; 50151: 110 164050
	CAL SSTRCP		; 50154: 106267050
	LHI001		; 50157: 070001
	JMP EQ1		; 50161: 104 145 006
STC2:
	CPI003		; 50164: 074003
	JFZ STC3		; 50166: 110 201 050
	CAL SSTRCP		; 50171: 106267050
	LHI001		; 50174: 070001
	JMP GT1		; 50176: 104 162006
STC3:
	CPI004		; 50201: 074004
	JFZ STC4		; 50203: 110 216 050
	CAL SSTRCP		; 50206: 106267 050
	LHI001		; 50211: 070001
	JMP LE1		; 50213: 104 202006
STC4:
	CPI005		; 50216: 074005
	JFZ STC5		; 50220: 110 233050
	CAL SSTRCP		; 50223: 106267050
	LHI001		; 50226: 070001
	JMP GE1		; 50230: 104 222006
STC5:
	CAL SSTRCP		; 50233: 106267050
	LHI001		; 50236: 070001
	JMP NE1		; 50240: 104237006
SELOOP:
	LBM		; 50243: 317		Add 1 to pointer, test against
	INB		; 50244: 010
	LMB		; 50245: 371
	DCB		; 50246: 011
	LLI377		; 50247: 066377		End of SEVAL pointer
	LAM		; 50251: 307
	CPB		; 50252: 271
	RET		; 50253: 007
S2LOOP:
	LBM		; 50254: 317		Add 1 to pointer, test against
	INB		; 50255: 010
	LMB		; 50256: 371
	DCB		; 50257: 011
	LLI372		; 50260: 066372		BAL PARN pointer-1
	LAM		; 50262: 307
	SUI 001		; 50263: 024001
	CPB		; 50265: 271
	RET		; 50266: 007
SSTRCP:
	CAL SAVEHL		; 50267: 106317022	Save H, L, and D, E
	LAM		; 50272: 307		Get (CC) of first string
	CAL SWITCH		; 50273: 106356 022	Point to other string
	LBM		; 50276: 317		Get (CC) for second string
	CAL SWITCH		; 50277: 106356022	Point to first string
	CPB		; 50302: 271		Compare lengths
	JTZ SSTRZ		; 50303: 150 343050	If equal, test for 0
	JFS SSTRCL		; 50306: 120312050	Second is shortest
	LBA		; 50311: 310		First is shorter
SSTRCL:
	CAL ADV		; 50312: 106377002	Next character
	LAM		; 50315: 307		Get it
	CAL SWITCH		; 50316: 106356022	Second string
	CAL ADV		; 50321: 106377002	Next character
SSTRCE:
	CPM		; 50324: 277		Compare characters
	RFZ		; 50325: 013		Return if less than or greater than
	DCB		; 50326: 011		Decrement (CC)
	JFZ SSTRCL		; 50327: 110312050	Continue if not 0
	CAL RESTHL		; 50332: 106337 022	Originate strings
	LAM		; 50335: 307		First (CC)
	CAL SWITCH		; 50336: 106356022	Second string
	CPM		; 50341: 277		Compare lengths
	RET		; 50342: 007
SSTRZ:
	NDA		; 50343: 240		Is length = 0?
	RTZ		; 50344: 053		Return if it is
	JMP SSTRCL		; 50345: 104312050	Otherwise, as normal
CONCAT:
	LHI045		; 50350: 070045		$$ Load H with STRING page
	LLI002		; 50352: 066002		Load L with address of SUBSTR pointer
	LAM		; 50354: 307		Get SUBSTR pointer
	NDA		; 50355: 240		Is SUBSTR pointer = 0?
	JFZ CONCTO		; 50356: 110363050	If not, continue
	LMI001		; 50361: 076001		Replace 0 with 1
CONCTO:
	LLI003		; 50363: 066003		Load L with address of SUBSTR length
	LAM		; 50365: 307		Get SUBSTR length
	NDA		; 50366: 240		Is SUBSTR length = 0?
	JTZ CONSA1		; 50367: 150111051	If so, don't concatenate
	CAL CLESYM		; 50372: 106255002	Clear symbol
	CAL SLOOK		; 50375: 106 123 051	Lookup SVAR in STRTAB
	LLI005		; 51000: 066005		Load L with address of SPNTR
	LHI045		; 51002: 070045		$$ Load H with STRING page
	LDM		; 51004: 337		Load SPNTR in D and E
	INL		; 51005: 060
	LEM		; 51006: 347
	LHD		; 51007: 353		Put SPNTR in H and L
	LLE		; 51010: 364		To point to (CC) of string
	LBM		; 51011: 317		Get original length of string from (CC)
	LHI045		; 51012: 070045		$$ Load H with STRING page
	LLI003		; 51014: 066003		Load L with address of SUBSTR length
	LAM		; 51016: 307		Get SUBSTR length
	CPI377		; 51017: 074377		Is SUBSTR length = -1?
	JFZ CONCA1		; 51021: 110035051	If not, have move length
	LLI002		; 51024: 066002		Load L with address of SUBSTR pointer
	LAB		; 51026: 301		Get string length in accumulator
	SUM		; 51027: 227		Subtract SUBSTR pointer from string length
	LBA		; 51030: 310		Put difference in B
	INB		; 51031: 010		Subtract 1 to form move string length
	JMP CONSAC		; 51032: 104040051	Continue to concatenate string onto STRACC
CONCA1:
	LLI003		; 51035: 066003		Load L with address of SUBSTR length
	LBM		; 51037: 317		The SUBSTR length is move string length
CONSAC:
	LLI020		; 51040: 066020		Load L with address of STRACC
	LHI045		; 51042: 070045		$$ Load H with STRING page
	LAM		; 51044: 307		Get (CC) of STRACC
	ADB		; 51045: 201		Add move string length to it
	CPI 121		; 51046: 074121		Compare new length with 81 decimal
	JFS BIGERR		; 51050: 120 222002	If new length greater than 80, BG error
	LCA		; 51053: 320		Save new length in C
	LAM		; 51054: 307		Get old length in A
	LMC		; 51055: 372		Put new length back in STRACC (CC)
	ADI 021		; 51056: 004021		Add address to STRACC+1 to get new address
	LCA		; 51060: 320		Store address for move in C temporarily
	LLI005		; 51061: 066005		Load L with address of SPNTR
	LDM		; 51063: 337		Get high part of SPNTR in D
	INL		; 51064: 060		Low part of SPNTR
	LAM		; 51065: 307		Get low part of SPNTR in A
	LLI002		; 51066: 066002		Load L with address of SUBSTR pointer
	ADM		; 51070: 207		Add SUBSTR length to SPNTR low byte
	LEA		; 51071: 340		Save sum in E
	LAD		; 51072: 303		Get high part SPNTR in A
	ACI 000		; 51073: 014000		Add carry to high SPNTR
	LDA		; 51075: 330		Save it in D
	LHD		; 51076: 353		Put sum in H and L to point to character string
	LLE		; 51077: 364		First character after string (CC)
	LDI045		; 51100: 036045		$$ Load D with STRING page
	LEC		; 51102: 342		Put address of end of STRACC in E
	INB		; 51103: 010		Exercise B, test to see if zero
	DCB		; 51104: 011
	LAA		; 51105: 300
	CFZ MOVEPG		; 51106: 112050012	If len grtr or less than 0, concat SUBSTR onto STRACC
CONSA1:
	LLI002		; 51111: 066002		Load L with address of SUBSTR pointer
	LHI045		; 51113: 070045		$$ Load H with STRING page
	LMI001		; 51115: 076001		Re-initialize SUBSTR pointer to 1, next string
	INL		; 51117: 060		SUBSTR length
	LMI377		; 51120: 076377		Re-initialize SUBSTR length to -1, hold next string
	RET		; 51122: 007		Return to caller
SLOOK:
	LLI013		; 51123: 066013		Load L with address of NUMSTR
	LHI045		; 51125: 070045		$$ Load H with STRING page
	LCM		; 51127: 327		Put NUMSTR in C
	LLI260		; 51130: 066 260	Load L with address of pointer to STRTAB
	LDM		; 51132: 337		Load D page of STRTAB
	LEI 000		; 51133: 046000		Load E with address of start of STRTAB
	INC		; 51135: 020		Exercise C to test if zero
	DCC		; 51136: 021
	JTZ SLOOK3		; 51137: 150220051	If equal, no strings exist, create new
SLOOK1:
	LLE		; 51142: 364		Put pointer to STRTAB in H and L
	LHD		; 51143: 353
	LAM		; 51144: 307		Get string name in STRTAB
	LLI 000		; 51145: 066000		Load L with address of SVAR name
	LHI045		; 51147: 070045		$$ Load H with STRING page
	CPM		; 51151: 277		Compare SVAR name to STRTAB
	JFZ SLOOK2		; 51152: 110210051	If not equal, keep looking for SVAR
	LLE		; 51155: 364		Put pointer in H and L
	LHD		; 51156: 353
	INL		; 51157: 060		Point to STRTAB subscript
	LAM		; 51160: 307		Get STRTAB subscript
	LLI001		; 51161: 066001		Load L with address of SVAR subscript
	LHI045		; 51163: 070045		$$ Load H with STRING page
	CPM		; 51165: 277		Compare STRTAB subscript with SVAR subscript
	JFZ SLOOK2		; 51166: 110210051	If not equal, keep looking
	LLE		; 51171: 364		Put pointer in H and L
	LHD		; 51172: 353
	INL		; 51173: 060		Add two to L to point to high part of pointer
	INL		; 51174: 060
	LDM		; 51175: 337		$$ Load H with STRING page
	LEM		; 51177: 347		Store new end of string back
	LLI005		; 51200: 066005
	LHI045		; 51202: 070045
	LMD		; 51204: 373
	INL		; 51205: 060
	LME		; 51206: 374
	RET		; 51207: 007		Return to caller
SLOOK2:
	LAE		; 51210: 304
	ADI 004		; 51211: 004004
	LEA		; 51213: 340
	DCC		; 51214: 021
	JFZ SLOOK1		; 51215: 110142051
SLOOK3:
	LLI013		; 51220: 066013		Load L with address of NUMSTR
	LHI045		; 51222: 070045		$$ Load H with STRING page
	LBM		; 51224: 317		Increment NUMSTR
	INB		; 51225: 010
	LMB		; 51226: 371
	CPI 101		; 51230: 074101		Greater than 64 (decimal)?
	JFS BIGERR		; 51232: 120222002
	LLI 000		; 51235: 066000		Load L with address of SVAR name
	LAM		; 51237: 307		Put name and subscript in string table
	LLE		; 51241: 364
	LHD		; 51240: 353
	LMA		; 51242: 370
	LLI001		; 51243: 066001
	LHI045		; 51245: 070045
	LAM		; 51247: 307
	LHD		; 51250: 353
	LLE		; 51251: 364
	INL		; 51252: 060
	LMA		; 51253: 370
	LLI015		; 51254: 066015		Put END OF STR pointer in string table
	LHI045		; 51256: 070045
	LBM		; 51260: 317
	INL		; 51261: 060
	LCM		; 51262: 327
	LLI005		; 51263: 066005
	LMB		; 51265: 371
	INL		; 51266: 060
	LMC		; 51267: 372
	LHD		; 51270: 353
	LLF.		; 51271: 364
	INL		; 51272: 060
	INL		; 51273: 060
	LMB		; 51274: 371
	INL		; 51275: 060
	LAC		; 51277: 302
	LCA		; 51302: 320
	ACI 000		; 51304: 014000
	LLI015		; 51307: 066015
	LMB		; 51313: 371
	INL		; 51314: 060
	LMC		; 51315: 372
	LHB		; 51316: 351		Put new ENDSTR in H and L
	LLC		; 51317: 362
	LMI000		; 51320: 076000		Put 0 at location pointed to by end of string
	LCI000		; 51322: 026000		0 in C indicates new string
	RET		; 51324: 007		Return to caller
PARNB:
	LCI001		; 51325: 026001		Initialize C to first PARENTHESIS
	LHI026		; 51327: 070026		** Load H with pointer page
	LLD		; 51331: 363		Put start location in L
	INE		; 51332: 040		Add 1 to finish location
PARNB1:
	LAM		; 51333: 307		Get character
	CPI250		; 51334: 074250		Is it "(" ?
	JFZ PARNB2		; 51336: 110345051	If not, keep looking
	INC		; 51341: 020		Increase PAREN counter
	JMP PARNB3		; 51342: 104353051	Continue
PARNB2:
	CPI251		; 51345: 074251		Is character ")" ?
	JFZ PARNB3		; 51347: 110353051	If not, keep looking
	DCC		; 51352: 021		Decrement PAREN counter
PARNB3:
	INC		; 51353: 020		Exercise C to test if 0
	DCC		; 51354: 021
	LBL		; 51355: 316		Put pointer in B
	RTZ		; 51356: 053		Return if parentheses balanced
	INL		; 51357: 060		Point to next character
	LAL		; 51360: 306		Get new pointer
	CPE		; 51361: 274		Test if limit
	JFZ PARNB1		; 51362: 110333051	If not, keep trying
	JMP PARNER		; 51365: 104104006	If no balance, ")(" error
EVALPC:
	LLI375		; 51370: 066375		Load L with address of SMODE
	LHI026		; 51372: 070026		** Load H with pointer page
	LMI 000		; 51374: 076000		Initialize SMODE to numeric
EVALS:
	LLI227		; 51376: 066227		Load L with address of ARTH SP
	LHI001		; 52000: 070001		** Load H with FP page
	JMP EVALQ		; 52002: 104227003	Continue evaluation
SCANCP:
	CPI 244		; 52005: 074244		Is character "$"?
	JTZ SEVAL		; 52007: 150000046	If so, evaluate string
	CPI247		; 52012: 074247		Is character "'"?
	JTZ SEVAL		; 52014: 150 000 046	If so, evaluate string
	CPI242		; 52017: 074 242	Is character '"'?
	JTZ SEVAL		; 52021: 150000046	If so, evaluate string
	CAL LTEQGT		; 52024: 106042052	Test for <, =, > etc.
	LLI 176		; 52027: 066 176	Load L with address of PARSE pointer
	LHI026		; 52029: 070026		** Load H with pointer page
	LBM		; 52031: 317		Get token
	INB		; 52032: 010		Exercise B to see if found operation
	DCB		; 52033: 011
	JFZ SCANFN		; 52034: 110351 003	If no operation found, continue scanning
	JMP SCAN16		; 52037: 104276004	Process as normal
LTEQGT:
	LLI176		; 52042: 066 176	Load L with address of PARSE pointer
	LHI026		; 52044: 070026		** Load H with pointer page
	LMI 000		; 52046: 076000		Clear token
	JMP SCAN9		; 52051: 104100004	Continue with EVAL except test for equality
STERR:
	LAI323		; 52054: 006323		"ST" error code
	LCI324		; 52056: 026 324
	JMP ERROR		; 52060: 104226002
IQERR:
	LAI311		; 52063: 006311		"IQ" error code
	LCI321		; 52065: 026321
	JMP ERROR		; 52067: 104226002
STORP:
	LLI375		; 52070: 066375		Load L with address of SMODE
	LHI026		; 52072: 070026		** Load H with pointer page
	LAM		; 52074: 307		Get SMODE flag into accumulator
	NDA		; 52075: 240		Test SMODE flag
	LLI201		; 52076: 066201		Load L with address of ARRAY flag
	LHI027		; 52100: 070027		** Load H with page of ARRAY flag
	JTZ STORP1		; 52102: 150060010	If SMODE flag is numeric, regular store
SSTOR:
	LAM		; 52105: 307		Get ARRAY flag into accumulator
	LMI 000		; 52106: 076 000	Reset ARRAY flag
	NDA		; 52110: 240		Test ARRAY flag
	JFZ SSTOR1		; 52111: 110150052	If ARRAY flag set, already have TSVAR
	LLI120		; 52114: 066 120	Load L with address of SYMBOL
	LHI026		; 52116: 070026		** Load H with pointer page
	LAM		; 52120: 307		Get length of SYMBOL
	CPI002		; 52121: 074 002	Is length 2 for letter-$ combination?
	JFZ STERR		; 52123: 110 051 052	If not, have string error
	ADL		; 52126: 206		Add address to point to last character
	LLA		; 52127: 360		Point to last character in SYMBOL
	LAM		; 52130: 307		Get last character of SYMBOL into accumulator
	CPI 244		; 52131: 074244		Is last character a dollar sign ($)?
	JFZ STERR		; 52133: 110051 052	If not, STring ERRor
	DCL		; 52136: 061		Point to string name in SYMBOL
	LAM		; 52137: 307		Get string name
	LLI261		; 52140: 066261		Load L with address of TSVAR name
	LHI045		; 52142: 070045		$$ Load H with STRING page
	LMA		; 52144: 370		Put string name in TSVAR name
	INL		; 52145: 060		Point to TSVAR subscript
	LMI001		; 52146: 076001		Put 1 in TSVAR subscript
SSTOR1:
	LLI261		; 52150: 066261		Load L with address of TSVAR name
	LHI045		; 52152: 070045		$$ Load H with STRING page
	LDM		; 52154: 337		Load TSVAR name and subscript in D and E
	INL		; 52155: 060
	LEM		; 52156: 347
	LLI 000		; 52157: 066000		Load L with address of SVAR name
	LMD		; 52161: 373		Store TSVAR in SVAR
	INL		; 52162: 060
	LME		; 52163: 374
	CAL SLOOK		; 52164: 106 123051	Look up string to be stored
	LAC		; 52167: 302		Get accumulator into C to tell if string is new
	NDA		; 52170: 240		Test if C was 0, meaning string is new
	JFZ SSTOR8		; 52171: 110 214 052	If string is not new, continue below
	LLI 016		; 52174: 066016		Load L with address of low part of ENDSTR
	LHI045		; 52176: 070045		$$ Load H with STRING page
	LAM		; 52200: 307		Get low part of ENDSTR in accumulator
	SUI 001		; 52201: 024001		Subtract 1 from low part of ENDSTR
	LMA		; 52203: 370		Restore to ENDSTR
	DCL		; 52204: 061		Point to high part of ENDSTR
	LAM		; 52205: 307		Get high part of ENDSTR in accumulator
	SBI 000		; 52206: 034000		Subtract carry from high part of ENDSTR
	LMA		; 52210: 370		Restore in ENDSTR
	JMP SSTOR3		; 52211: 104035053	Avoid modifying pointers since new string
SSTOR8:
	LLI005		; 52214: 066005
	LDM		; 52220: 337
	INL		; 52221: 060
	LEM		; 52222: 347
	LHD		; 52223: 353
	LLE		; 52224: 364
	LCM		; 52225: 327
	LLI007		; 52226: 066007
	LMC		; 52232: 372
	INC		; 52233: 020
	LLI016		; 52234: 066016
	LAM		; 52236: 307
	SUC		; 52237: 222
	LMA		; 52240: 370
	LAM		; 52242: 307
	SBI 000		; 52243: 034000
	LMA		; 52245: 370
SSTOR2:
	LAE		; 52246: 304
	ADC		; 52247: 202
	LLA		; 52250: 360
	LAD		; 52251: 303
	ACI 000		; 52252: 014000
	LHA		; 52254: 350
	LLE		; 52256: 364
	LHD		; 52257: 353
	LMB		; 52260: 371
	LLI015		; 52261: 066015
	LAD		; 52265: 303
	CPM		; 52266: 277
	JFZ SSTOR9		; 52267: 110300052
	INL		; 52272: 060
	LAE		; 52273: 304
	CPM		; 52274: 277
	JTZ SSTORO		; 52275: 150 306052
SSTOR9:
	CAL ADVDE		; 52300: 106064013
	JMP SSTOR2		; 52303: 104246052
SSTORO:
	LLI005		; 52306: 066005
	LDM		; 52312: 337
	INL		; 52313: 060
	LEM		; 52314: 347
	LLI013		; 52315: 066013
	LBM		; 52317: 317
	LLI260		; 52320: 066 260
	LHM		; 52322: 357
	LLI002		; 52323: 066002
SSTOR4:
	LAM		; 52325: 307
	CPD		; 52326: 273
	JTZ SSTOR5		; 52327: 150340052
	JTS SSTOR7		; 52332: 160025053
	JMP SSTOR6		; 52335: 104 014 053
SSTOR5:
	INL		; 52340: 060
	LAM		; 52341: 307
	DCL		; 52342: 061
	CPE		; 52343: 274
	JTC SSTOR7		; 52344: 140025053
	JFZ SSTOR6		; 52347: 110014053
	LAL		; 52352: 306
	LLI263		; 52353: 066263
	LMB		; 52357: 371
	INL		; 52360: 060
	LLI015		; 52362: 066 015
	LBM		; 52364: 317
	INL		; 52365: 060
	LCM		; 52366: 327
	LLI260		; 52367: 066260
	LHM		; 52371: 357
	LLA		; 52372: 360
	LMB		; 52373: 371
	INL		; 52374: 060
	LMC		; 52375: 372
	LLI263		; 52376: 066263
	LBM		; 53002: 317
	INL		; 53003: 060
	LCM		; 53004: 327
	LLI260		; 53005: 066260
	LHM		; 53007: 357
	LLA		; 53010: 360
	JMP SSTOR7		; 53011: 104025053
SSTOR6:
	INL		; 53014: 060
	LAM		; 53015: 307
	SUC		; 53016: 222
	LMA		; 53017: 370
	DCL		; 53020: 061
	LAM		; 53021: 307
	SBI 000		; 53022: 034000
	LMA		; 53024: 370
SSTOR7:
	LAL		; 53025: 306
	ADI 004		; 53026: 004004
	LLA		; 53030: 360
	DCB		; 53031: 011
	JFZ SSTOR4		; 53032: 110325052
SSTOR3:
	LLI015		; 53035: 066015
	LDM		; 53041: 337
	INL		; 53042: 060
	LEM		; 53043: 347
	LLI020		; 53044: 066 020
	LAM		; 53046: 307
	ADI 001		; 53047: 004001
	ADE		; 53051: 204
	LEA		; 53052: 340
	LAD		; 53053: 303
	ACI 000		; 53054: 014000
	LDA		; 53056: 330
	LLI015		; 53064: 066015
	LDM		; 53065: 337
	LMA		; 53067: 370
	INL		; 53070: 060
	LAM		; 53071: 307
	LME		; 53072: 374
	LEA		; 53073: 340
	LLI020		; 53074: 066020
	CAL MOVEC		; 53076: 106046012
	LLI015		; 53101: 066015
	LDM		; 53105: 337
	INL		; 53106: 060
	LEM		; 53107: 347
	LHD		; 53110: 353
	LLE		; 53111: 364
	LMI 000		; 53112: 076000
	LLI375		; 53114: 066 375
	LMI 000		; 53120: 076000
	RET		; 53122: 007
PPRINT:
	LLI203		; 53124: 066 203	Load L with address of PRINT pointer
	LHI026		; 53124: 070026		** Load H with pointer page
	CAL LOOP		; 53126: 106003003	Loop until end of statement
	JFZ PRINT2		; 53131: 110002014	If not done, go back
	JMP PRINT3		; 53134: 104 043 014	Continue as normal with PRINT
PPRIN7:
	LLI203		; 53137: 066203		Load L with address of PRINT pointer
	LDM		; 53141: 337		Get PRINT pointer in D
	IND		; 53142: 030		Add 1 to skip over parentheses
	LLI 000		; 53143: 066000		Load L with address of (CC)
	LEM		; 53145: 347		Look for parentheses to end of statement
	CAL PARNB		; 53146: 106325051	Find balancing parentheses to skip unwanted
	LLI203		; 53151: 066203		Load L with address of PRINT pointer
	LMB		; 53153: 371		Put pointer to balance parentheses there
	JMP PPRINT		; 53154: 104124053	Continue to loop as normal
POUTSF:
	LLI375		; 53157: 066375		Load L with address of SMODE
	LHI026		; 53161: 070026		** Load H with pointer page
	LAM		; 53163: 307		Get SMODE flag into accumulator
	NDA		; 53164: 240		Test if SMODE is numeric (0)
	JTZ PFPOUT		; 53165: 150314014	If so, print FP number as normal
	LLI020		; 53170: 066020		Load L with address of STRACC
	LHI045		; 53172: 070045		$$ Load H with STRING page
	JMP TEXTC		; 53174: 104121003	Print STRING ACC and return
ARRAYP:
	LLI120		; 53177: 066120		Load L with address of SYMBOL
	LHI026		; 53177: 070026		** Load H with pointer page
	LAM		; 53201: 307		Get (CC) of SYMBOL into accumulator
	ADL		; 53202: 206		Add L to (CC) to get last character
	LLA		; 53203: 360		Put sum in L to point to last character
	LAM		; 53204: 307		Get last character of SYMBOL
	CPI244		; 53205: 074 244	Is last character dollar sign ($)?
	JTZ SARRAY		; 53207: 150221053	If so, have string array
	LLI207		; 53212: 066207		Load L with address of ARRAY LOOP counter
	LMI 000		; 53214: 076000		Initialize loop counter to 0
	JMP ARRAY6		; 53216: 104240055	Continue with numeric array as normal
SARRAY:
	DCL		; 53221: 061		Get first character of SYMBOL
	LAM		; 53222: 307		Get string name into ACC
	LLI261		; 53223: 066 261	Load L with address of TSVAR name
	LHI045		; 53225: 070045		$$ Load H with STRING page
	LMA		; 53227: 370		Put name of string in TSVAR name
	CAL EVAL		; 53230: 106224003	Evaluate subscript expression
	CAL FPFIX		; 53233: 106000020	Convert value to fixed point
	LLI 124		; 53236: 066124		Load L with address of FP ACC LSW
	LHI001		; 53240: 070001		** Load H with address of FP page
	LAM		; 53242: 307		Get subscript into ACC
	LLI262		; 53243: 066262		Load L with address of TSVAR subscript
	LHI045		; 53245: 070045		$$ Load H with STRING page
	LMA		; 53247: 370		Put subscript in TSVAR subscript
	LLI375		; 53250: 066375		Load L with address of SMODE
	LHI026		; 53252: 070026		** Load H with pointer page
	LMI001		; 53254: 076001		Set SMODE flag to indicate string array
	LHI027		; 53256: 070027		** Load H with address of pointer page
	LLI201		; 53260: 066 201	Load L with address of ARRAY FLAG
	LMI001		; 53262: 076001		Set ARRAY FLAG to indicate string array
	RET		; 53264: 007		Return to caller
SCRPCH:
	LLI260		; 53265: 066260		Load L with address of pointer to STRTAB
	LHI045		; 53267: 070045		$$ Load H with STRING page
	LBM		; 53271: 317		Get pointer to STRTAB in B
	INB		; 53272: 010		Increment to point to string storage area
	LLI 013		; 53273: 066013		Load L with address of NUMSTR
	LMI 000		; 53275: 076000		Initialize to 0 to clear strings
	LLI015		; 53277: 066015		Load L with address of ENDSTR pointer
	LMB		; 53301: 371		Initialize ENDSTR to beginning of string area
	INL		; 53302: 060		Starts at location 0
	LMI 000		; 53303: 076000		Point to beginning of string area
	LHB		; 53305: 351		Starts at location 0
	LLI 000		; 53306: 066000
	LMI 000		; 53310: 076000		Initialize to 0 for new string
	JMP EXEC		; 53312: 104266010	Print READY, etc.
PINPUT:
	CAL CLESYM		; 53315: 106255002	Clear symbol
	LLI375		; 53317: 066375		Load L with address of SMODE flag
	LHI026		; 53321: 070026		** Load H with pointer page
	LMI 000		; 53322: 076000		Set it to numeric mode
	RET		; 53324: 007		Return from this patch
INPUTS:
	LLI 375		; 53325: 066375		Load L with address of SMODE flag
	LHI026		; 53327: 070026		** Load H with pointer page
	LMI001		; 53331: 076001		Set mode to string
	LAI 277		; 53333: 006277		"?" character
	CAL ECHO		; 53335: 106 202 003	Echo prompt
	LLI020		; 53340: 066020		Load L with address of STRACC
	LHI045		; 53342: 070045		$$ Load H with STRING page
	JMP STRIN		; 53344: 104014003	Input string
INSTRP:
	CAL SAVEHL		; 53347: 106317022	Save H and L
	CAL SWITCH		; 53352: 106 356 022	Switch to other string
	LAM		; 53355: 307		Get character
	CPI247		; 53356: 074247		Is it single quote?
	JTZ INSTRQ		; 53360: 150370053	If so, process string input
	CPI242		; 53363: 074242		Is it double quote?
	JFZ SWITCH		; 53365: 110356022	If not, switch back
INSTRQ:
	INL		; 53370: 060		Next character
	CPM		; 53371: 277		Compare with quote
	JTZ SWITCH		; 53372: 150356022	If match, switch back (end of string)
	LBH		; 53375: 315		Save H in B
	LCL		; 53376: 326		Save L in C
	LLI 000		; 53377: 066000		Load L with address of (CC)
	LHI026		; 54001: 070026		** Load H with pointer page
	LAM		; 54003: 307		Get (CC)
	CPE		; 54004: 274		Compare with end pointer
	LHB		; 54005: 351		Restore H
	LLC		; 54006: 362		Restore L
	JTZ IQERR		; 54007: 150060052	If at end, IQ error
	JMP INSTRQ		; 54012: 104370053	Continue processing string
SFAPCH:
	LLI012		; 54015: 066012		Load L with address of STring FUNction TOKEN
	LHI045		; 54017: 070045		$$ Load H with STRING page
	LMI001		; 54021: 076001		Initialize STring FUNction TOKEN to 1
	LLI360		; 54023: 066 360	Load L w/ address of 1st string function name
SFAPC1:
	LDI026		; 54025: 036026		** Load D with pointer page
	LEI 120		; 54027: 046120		Load L with address of SYMBOL
	CAL STRCP		; 54031: 106 332002	Compare SYMBOL with string functions
	JTZ SFAPC3		; 54034: 150077 054	If have match, process string function
	LLE		; 54037: 364		Restore H and L to point to string function names
	LHD		; 54040: 353
SFAPC2:
	INL		; 54041: 060		Skip over last byte
	LAM		; 54042: 307		Get next character in string function name table
	NDI 300		; 54043: 044 300	Is it a character (parity marking)?
	JFZ SFAPC2		; 54045: 110041054	Yes, go back and try again
	LDH		; 54050: 335		Save pointer to new string function in D and E
	LEL		; 54051: 346
	LLI012		; 54052: 066012		Load L with address of string function token
	LHI045		; 54054: 070045		$$ Load H with STRING page
	LBM		; 54056: 317		Get token
	INB		; 54057: 010		Increment token
	LMB		; 54060: 371		Store updated token
	LLE		; 54062: 364		Restore L
	LAB		; 54063: 301		Get token into A
	CPI004		; 54064: 074004		Is token 4 (exhausted string functions)?
	JFZ SFAPC1		; 54066: 11 0025054	If not, try next string function
	CAL FUNARR		; 54071: 106 100 007	Handle as numeric function/array
SFAPC3:
	LLI276		; 54077: 066 276	Load L with address of start of EVAL pointer
	LHI026		; 54101: 070026		** Load H with pointer page
	LBM		; 54103: 317		Save start of EVAL pointer
	INL		; 54104: 060		End of EVAL pointer
	LCM		; 54105: 327		Save end of EVAL pointer
	LLI010		; 54106: 066010		Load L with address of temp storage
	LHI045		; 54110: 070045		$$ Load H with STRING page
	LMB		; 54112: 371		Store start pointer
	INL		; 54113: 060
	LMC		; 54114: 372		Store end pointer
	LLI200		; 54115: 066200		Load L with address of EVAL pointer
	LHI026		; 54117: 070026		** Load H with pointer page
	LBM		; 54121: 317		Get EVAL pointer
	INB		; 54122: 010		Increment to skip "("
	LLI276		; 54123: 066276		Load L with address of start of EVAL pointer
	LMB		; 54125: 371		Store updated pointer
	INL		; 54126: 060		End of EVAL pointer
	LEM		; 54130: 347		Get end pointer
	CAL PARNB		; 54131: 106325051	Find balancing parenthesis
	LLI277		; 54134: 066277		Load L with address of end of EVAL pointer
	DCB		; 54136: 011		Decrement to exclude ")"
	LMB		; 54137: 371		Store updated end pointer
	CAL EVAL		; 54140: 106 224 003	Evaluate expression in parenthesis
	LLI375		; 54143: 066 375	Load L with address of SMODE
	LHI026		; 54145: 070026		** Load H with pointer page
	LAM		; 54147: 307		Get SMODE
	NDA		; 54150: 240		Was result string?
	JTZ STERR		; 54151: 150051052	If numeric, ST error (expected string)
	LLI010		; 54154: 066 010	Load L with address of temp storage
	LHI045		; 54156: 070045		$$ Load H with STRING page
	LDM		; 54160: 337		Restore start of EVAL pointer
	INL		; 54161: 060
	LEM		; 54162: 347		Restore end of EVAL pointer
	LLI277		; 54163: 066277		Load L with address of end of EVAL pointer
	LHI026		; 54165: 070026		** Load H with pointer page
	LBM		; 54167: 317		Get end pointer
	INB		; 54170: 010		Increment past ")"
	LLI200		; 54171: 066200		Load L with address of EVAL pointer
	LMB		; 54173: 371		Restore EVAL pointer past ")"
	LLI276		; 54174: 066 276	Load L with address of start of EVAL pointer
	LMD		; 54176: 373		Restore start and end of EVAL pointers
	INL		; 54177: 060
	LME		; 54200: 374
	LLI012		; 54201: 066012		Load L with address of string function token
	LHI045		; 54203: 070045		$$ Load H with STRING page
	LAM		; 54205: 307		Get string function token
	CPI003		; 54206: 074003		Is it VAL function (token=3)?
	JFZ SFAPC7		; 54210: 110223054	If not, handle LEN or ASC
	LLI020		; 54213: 066020		Load L with address of STRACC
	CAL DINPUT		; 54215: 106044023	Convert STRACC to FP by calling DINPUT
	JMP SFAPC8		; 54220: 104262054	Continue to cleanup
SFAPC7:
	LLI012		; 54226: 066 012	Load L with address of string function token
	LHI045		; 54230: 070045		$$ Load H with STRING page
	LAM		; 54232: 307		Get string function token
	CPI 001		; 54233: 074001		Is it LEN function (token=1)?
	LLI020		; 54235: 066020		Load L with address of STRACC
	LHI045		; 54237: 070045		$$ Load H with STRING page
	JFZ SFAPC4		; 54241: 110250054	If not LEN, must be ASC
	LBM		; 54244: 317		Get (CC) length of string
	JMP SFAPC5		; 54245: 104252054	Convert to FP
SFAPC4:
	INL		; 54250: 060		Point to first character for ASC
SFAPC5:
	LBM		; 54251: 317		Get byte (length for LEN, char for ASC)
	LLI124		; 54252: 066124		Load L with address of FP ACC LSW
	LHI001		; 54254: 070001		** Load H with FP page
	LMB		; 54256: 371		Store byte as fixed point
	CAL FPFLT		; 54257: 106064020	Convert fixed to floating point
SFAPC8:
	LLI375		; 54262: 066375		Load L with address of SMODE
	LHI026		; 54264: 070026		** Load H with pointer page
	LMI 000		; 54266: 076000		Set SMODE back to numeric
	LLI227		; 54270: 066227		Load L with address of ARTH SP
	LHI001		; 54272: 070001		** Load H with FP page
	LMI230		; 54274: 076230		Reset arithmetic stack pointer
	JMP SCAN10		; 54276: 104301004	Continue scanning

; === END ===