/*
	HEADER:		CUG267;
	TITLE:		8085 Cross-Assembler (Portable);
	FILENAME:	A85UTIL.C;
	VERSION:	0.1;
	DATE:		08/27/1988;
	SEE-ALSO:	A85.H;
	AUTHORS:	William C. Colley III;
*/

/*
		      8085 Cross-Assembler in Portable C

		Copyright (c) 1985,1987 William C. Colley, III

Revision History:

Ver	Date		Description

0.0	AUG 1987	A85: Derived from version 3.4 of my portable 6800/6801
			cross-assembler.  WCC3.

0.1	AUG 1988	A85: Fixed a bug in the command line parser that puts it
			into a VERY long loop if the user types a command line
			like "A85 FILE.ASM -L".  WCC3 per Alex Cameron.


	DEC 2013	A85: changes by Herb Johnson HRJ to compile under lcc-32 for MS-DOS.
			borrowed greatly from A68util.c
			fixes as late as April 2010. Also see "a18octal.txt" to
			change listing from hexidecimal values to octal.
	  		Fixes for Turbo C HRJ include line[] changed to lline[]

	JAN 2014	HRJ changed from A85 to A08 for 8008 assembly
	            1) changed bccsearc() to simple linear search
				2) add DATA pseudoop, like DB
	May 2014	HRJ split octal address in listings

	Oct 2019	HRJ ORs broken, were copies of ANDs - Craig Andrews found

     Mar 2020	HRJ 8008 1972 mnemonics -> 8080 op codes
     Apr 2024	HRJ 8080 INP is DB not D8





This module contains the following utility packages:

	1)  symbol table building and searching

	2)  opcode and operator table searching

	3)  listing file output

	4)  hex file output

	5)  error flagging
*/

/*  Get global goodies:  */

#include "a8_80.h"
#include <string.h> /* HRJ */
#include <ctype.h>
// #include <malloc.h> /* for lcc-32 HRJ */
/* #include <alloc.h> for Turbo C HRJ */
#include <stdlib.h>

/*  Make sure that MSDOS compilers using the large memory model know	*/
/*  that calloc() returns pointer to char as an MSDOS far pointer is	*/
/*  NOT compatible with the int type as is usually the case.		*/

/* char *calloc(); HRJ */

/*HRJ local declarations */

static OPCODE *bccsearch(OPCODE *, OPCODE *, char *);
static void list_sym(SYMBOL *);
static void record(unsigned);
static void putb(unsigned);
static int ustrcmp(char *, char*);
static void check_page(void);
void warning(char *);
void fatal_error(char *);


/*  Get access to global mailboxes defined in A85.C:			*/

extern char errcode, lline[], title[];
extern int eject, listhex;
extern unsigned address, bytes, errors, listleft, obj[], pagelen, split_val;

/*  The symbol table is a binary tree of variable-length blocks drawn	*/
/*  from the heap with the calloc() function.  The root pointer lives	*/
/*  here:								*/

static SYMBOL *sroot = NULL;

/*  Add new symbol to symbol table.  Returns pointer to symbol even if	*/
/*  the symbol already exists.  If there's not enough memory to store	*/
/*  the new symbol, a fatal error occurs.				*/

SYMBOL *new_symbol(char *nam)

{
    SCRATCH int i;
    SCRATCH SYMBOL **p, *q;
    void fatal_error(char *);

    /* printf("new_symbol>>%s<<\n",nam);  HRJ diagnostic*/

    for (p = &sroot; (q = *p) && (i = strcmp(nam,q -> sname)); )
	p = i < 0 ? &(q -> left) : &(q -> right);
    if (!q) {
	if (!(*p = q = (SYMBOL *)calloc(1,sizeof(SYMBOL) + strlen(nam))))
	    fatal_error(SYMBOLS);
	strcpy(q -> sname,nam);
    }
    return q;
}

/*  Look up symbol in symbol table.  Returns pointer to symbol or NULL	*/
/*  if symbol not found.						*/

SYMBOL *find_symbol(char *nam)

{
    SCRATCH int i;
    SCRATCH SYMBOL *p;

    for (p = sroot; p && (i = strcmp(nam,p -> sname));
	p = i < 0 ? p -> left : p -> right);
    return p;
}

/*  Opcode table search routine.  This routine pats down the opcode	*/
/*  table for a given opcode and returns either a pointer to it or	*/
/*  NULL if the opcode doesn't exist.					*/
/*  HRJ table search assumes alpha order on name string field!! */

OPCODE *find_code(char *nam)

{
    /* OPCODE *bsearch(); */

    static OPCODE opctbl[] = {


	{ PSEUDO + ISIF,		ELSE,		"ELSE"	}, // no change HRJ
	{ PSEUDO + ISIF,		ENDIF,	"ENDIF"	},
	{ PSEUDO + ISIF,		IF,		"IF"	},
	{ PSEUDO,			DB,		"DB"	},
	{ PSEUDO,			DB,		"DATA"	},
	{ PSEUDO,			DS,		"DS"	},
	{ PSEUDO,			DW,		"DW"	},
	{ PSEUDO,			END,		"END"	},
	{ PSEUDO,			EQU,		"EQU"	},
	{ PSEUDO,			INCL,		"INCL"	},
	{ PSEUDO,			ORG,		"ORG"	},
	{ PSEUDO,			PAGE,		"PAGE"	},
	{ PSEUDO,			SET,		"SET"	},
	{ PSEUDO,			TITLE,	"TITLE"	},
	{ PSEUDO,           SPLIT,  "SPLIT" },  //HRJ for split octal

	//HRJ replaced with 8080 opcodes Mar 2020

	{ DATA_8 + 2,			0xC6,	"ADI"	}, //HRJ
	{ DATA_8 + 2,			0xCE,	"ACI"	},
	{ DATA_8 + 2,			0xD6,	"SUI"	},
	{ DATA_8 + 2,			0xDE,	"SBI"	},
	{ DATA_8 + 2,			0xE6,	"NDI"	},
	{ DATA_8 + 2,			0xEE,	"XRI"	},
	{ DATA_8 + 2,			0xF6,	"ORI"	},
	{ DATA_8 + 2,			0xFE,	"CPI"	},

	{ DATA_8 + 2,			0x3E,	"LAI"	}, //HRJ load 8bit
	{ DATA_8 + 2,			0x06,	"LBI"	},
	{ DATA_8 + 2,			0x0E,	"LCI"	},
	{ DATA_8 + 2,			0x16,	"LDI"	},
	{ DATA_8 + 2,			0x1E,	"LEI"	},
	{ DATA_8 + 2,			0x26,	"LHI"	},
	{ DATA_8 + 2,			0x2E,	"LLI"	},
	{ DATA_8 + 2,			0x36,	"LMI"	},

                                          //HRJ load 16bit for SP
	{ DAD_REG + (DATA_16 << 4) + 3,		0x01,	"LXI"	},


	{ DATA_16 + 3,			0xC3,	"JMP"	}, //HRJ jump

	{ DATA_16 + 3,			0xD2,	"JFC"	},//HRJ cond jumps
	{ DATA_16 + 3,			0xC2,	"JFZ"	},
	{ DATA_16 + 3,			0xF2,	"JFS"	},
	{ DATA_16 + 3,			0xE2,	"JFP"	},
	{ DATA_16 + 3,			0xDA,	"JC"	},
	{ DATA_16 + 3,			0xCA,	"JZ"	},
	{ DATA_16 + 3,			0xFA,	"JS"	},
	{ DATA_16 + 3,			0xEA,	"JP"	},
	{ DATA_16 + 3,			0xDA,	"JTC"	}, //alternatives
	{ DATA_16 + 3,			0xCA,	"JTZ"	},
	{ DATA_16 + 3,			0xFA,	"JTS"	},
	{ DATA_16 + 3,			0xEA,	"JTP"	},

	{ DATA_16 + 3,			0xCD,	"CAL"	}, //HRJ call

	{ DATA_16 + 3,			0xD4,	"CFC"	},//HRJ cond calls
	{ DATA_16 + 3,			0xC4,	"CFZ"	},
	{ DATA_16 + 3,			0xF4,	"CFS"	},
	{ DATA_16 + 3,			0xE4,	"CFP"	},
	{ DATA_16 + 3,			0xDC,	"CC"	},
	{ DATA_16 + 3,			0xCC,	"CZ"	},
	{ DATA_16 + 3,			0xFC,	"CS"	},
	{ DATA_16 + 3,			0xEC,	"CP"	},
	{ DATA_16 + 3,			0xDC,	"CTC"	}, //alternatives
	{ DATA_16 + 3,			0xCC,	"CTZ"	},
	{ DATA_16 + 3,			0xFC,	"CTS"	},
	{ DATA_16 + 3,			0xEC,	"CTP"	},

	{ NONE + 1,				0x07,	"RLC"	}, //HRJ rotates
	{ NONE + 1,				0x0F,	"RRC"	},
	{ NONE + 1,				0x17,	"RAL"	},
	{ NONE + 1,				0x1F,	"RAR"	},

	{ NONE + 1,				0xC9,	"RET"	}, //HRJ returns
	{ NONE + 1,				0xC0,	"RFZ"	},
	{ NONE + 1,				0xC8,	"RZ"	},
	{ NONE + 1,				0xD0,	"RFC"	},
	{ NONE + 1,				0xD8,	"RC"	},
	{ NONE + 1,				0xE0,	"RFP"	},
	{ NONE + 1,				0xE8,	"RP"	},
	{ NONE + 1,				0xF0,	"RFS"	},
	{ NONE + 1,				0xF8,	"RS"	},
	{ NONE + 1,				0xC8,	"RTZ"	}, //HRJ alternates
	{ NONE + 1,				0xD8,	"RTC"	},
	{ NONE + 1,				0xE8,	"RTP"	},
	{ NONE + 1,				0xF8,	"RTS"	},

	// HRJ INA DCA are not accepted 00, 10 are Intel "halts"
	{ NONE + 1,				0x04,	"INB"	}, //HRJ incr and decr
	{ NONE + 1,				0x05,	"DCB"	},
	{ NONE + 1,				0x0C,	"INC"	},
	{ NONE + 1,				0x0D,	"DCC"	},
	{ NONE + 1,				0x14,	"IND"	},
	{ NONE + 1,				0x15,	"DCD"	},
	{ NONE + 1,				0x1C,	"INE"	},
	{ NONE + 1,				0x1D,	"DCE"	},
	{ NONE + 1,				0x24,	"INH"	},
	{ NONE + 1,				0x25,	"DCH"	},
	{ NONE + 1,				0x2C,	"INL"	},
	{ NONE + 1,				0x2D,	"DCL"	},
	//HRJ INM DCM not defined, no INA DCA

	{ NONE + 1,				0x87,	"ADA"	}, //HRJ ADD
	{ NONE + 1,				0x80,	"ADB"	},
	{ NONE + 1,				0x81,	"ADC"	},
	{ NONE + 1,				0x82,	"ADD"	},
	{ NONE + 1,				0x83,	"ADE"	},
	{ NONE + 1,				0x84,	"ADH"	},
	{ NONE + 1,				0x85,	"ADL"	},
	{ NONE + 1,				0x86,	"ADM"	},
	{ NONE + 1,				0x8F,	"ACA"	}, //ADD w carry
	{ NONE + 1,				0x88,	"ACB"	},
	{ NONE + 1,				0x89,	"ACC"	},
	{ NONE + 1,				0x8A,	"ACD"	},
	{ NONE + 1,				0x8B,	"ACE"	},
	{ NONE + 1,				0x8C,	"ACH"	},
	{ NONE + 1,				0x8D,	"ACL"	},
	{ NONE + 1,				0x8E,	"ACM"	},

	{ NONE + 1,				0x97,	"SUA"	}, //HRJ SUB
	{ NONE + 1,				0x90,	"SUB"	},
	{ NONE + 1,				0x91,	"SUC"	},
	{ NONE + 1,				0x92,	"SUD"	},
	{ NONE + 1,				0x93,	"SUE"	},
	{ NONE + 1,				0x94,	"SUH"	},
	{ NONE + 1,				0x95,	"SUL"	},
	{ NONE + 1,				0x96,	"SUM"	},
	{ NONE + 1,				0x9F,	"SBA"	}, // SUB w borrow
	{ NONE + 1,				0x98,	"SBB"	},
	{ NONE + 1,				0x99,	"SBC"	},
	{ NONE + 1,				0x9A,	"SBD"	},
	{ NONE + 1,				0x9B,	"SBE"	},
	{ NONE + 1,				0x9C,	"SBH"	},
	{ NONE + 1,				0x9D,	"SBL"	},
	{ NONE + 1,				0x9E,	"SBM"	},

	{ NONE + 1,				0xA7,	"NDA"	}, //HRJ AND
	{ NONE + 1,				0xA0,	"NDB"	},
	{ NONE + 1,				0xA1,	"NDC"	},
	{ NONE + 1,				0xA2,	"NDD"	},
	{ NONE + 1,				0xA3,	"NDE"	},
	{ NONE + 1,				0xA4,	"NDH"	},
	{ NONE + 1,				0xA5,	"NDL"	},
	{ NONE + 1,				0xA6,	"NDM"	},
	{ NONE + 1,				0xAF,	"XRA"	}, // XOR
	{ NONE + 1,				0xA8,	"XRB"	},
	{ NONE + 1,				0xA9,	"XRC"	},
	{ NONE + 1,				0xAA,	"XRD"	},
	{ NONE + 1,				0xAB,	"XRE"	},
	{ NONE + 1,				0xAC,	"XRH"	},
	{ NONE + 1,				0xAD,	"XRL"	},
	{ NONE + 1,				0xAE,	"XRM"	},

	{ NONE + 1,				0xB7,	"ORA"	}, //HRJ OR
	{ NONE + 1,				0xB0,	"ORB"	},
	{ NONE + 1,				0xB1,	"ORC"	},
	{ NONE + 1,				0xB2,	"ORD"	},
	{ NONE + 1,				0xB3,	"ORE"	},
	{ NONE + 1,				0xB4,	"ORH"	},
	{ NONE + 1,				0xB5,	"ORL"	},
	{ NONE + 1,				0xB6,	"ORM"	},
	{ NONE + 1,				0xBF,	"CPA"	}, // COMPARE
	{ NONE + 1,				0xB8,	"CPB"	},
	{ NONE + 1,				0xB9,	"CPC"	},
	{ NONE + 1,				0xBA,	"CPD"	},
	{ NONE + 1,				0xBB,	"CPE"	},
	{ NONE + 1,				0xBC,	"CPH"	},
	{ NONE + 1,				0xBD,	"CPL"	},
	{ NONE + 1,				0xBE,	"CPM"	},

	{ NONE + 1,				0x00,	"NOP"	}, //HRJ move registers
	{ NONE + 1,				0x00,	"LAA"	}, //HRJ equivalent to NOP
	{ NONE + 1,				0x78,	"LAB"	},
	{ NONE + 1,				0x79,	"LAC"	},
	{ NONE + 1,				0x7A,	"LAD"	},
	{ NONE + 1,				0x7B,	"LAE"	},
	{ NONE + 1,				0x7C,	"LAH"	},
	{ NONE + 1,				0x7D,	"LAL"	},
	{ NONE + 1,				0x7E,	"LAM"	},
	{ NONE + 1,				0x47,	"LBA"	},
	{ NONE + 1,				0x40,	"LBB"	},
	{ NONE + 1,				0x41,	"LBC"	},
	{ NONE + 1,				0x42,	"LBD"	},
	{ NONE + 1,				0x43,	"LBE"	},
	{ NONE + 1,				0x44,	"LBH"	},
	{ NONE + 1,				0x45,	"LBL"	},
	{ NONE + 1,				0x46,	"LBM"	},

	{ NONE + 1,				0x4F,	"LCA"	}, //HRJ move registers
	{ NONE + 1,				0x48,	"LCB"	},
	{ NONE + 1,				0x49,	"LCC"	},
	{ NONE + 1,				0x4A,	"LCD"	},
	{ NONE + 1,				0x4B,	"LCE"	},
	{ NONE + 1,				0x4C,	"LCH"	},
	{ NONE + 1,				0x4D,	"LCL"	},
	{ NONE + 1,				0x4E,	"LCM"	},
	{ NONE + 1,				0x57,	"LDA"	},
	{ NONE + 1,				0x50,	"LDB"	},
	{ NONE + 1,				0x51,	"LDC"	},
	{ NONE + 1,				0x52,	"LDD"	},
	{ NONE + 1,				0x53,	"LDE"	},
	{ NONE + 1,				0x54,	"LDH"	},
	{ NONE + 1,				0x55,	"LDL"	},
	{ NONE + 1,				0x56,	"LDM"	},

	{ NONE + 1,				0x5F,	"LEA"	}, //HRJ move registers
	{ NONE + 1,				0x58,	"LEB"	},
	{ NONE + 1,				0x59,	"LEC"	},
	{ NONE + 1,				0x5A,	"LED"	},
	{ NONE + 1,				0x5B,	"LEE"	},
	{ NONE + 1,				0x5C,	"LEH"	},
	{ NONE + 1,				0x5D,	"LEL"	},
	{ NONE + 1,				0x5E,	"LEM"	},
	{ NONE + 1,				0x67,	"LHA"	},
	{ NONE + 1,				0x60,	"LHB"	},
	{ NONE + 1,				0x61,	"LHC"	},
	{ NONE + 1,				0x62,	"LHD"	},
	{ NONE + 1,				0x63,	"LHE"	},
	{ NONE + 1,				0x64,	"LHH"	},
	{ NONE + 1,				0x65,	"LHL"	},
	{ NONE + 1,				0x66,	"LHM"	},

	{ NONE + 1,				0x6F,	"LLA"	}, //HRJ move registers
	{ NONE + 1,				0x68,	"LLB"	},
	{ NONE + 1,				0x69,	"LLC"	},
	{ NONE + 1,				0x6A,	"LLD"	},
	{ NONE + 1,				0x6B,	"LLE"	},
	{ NONE + 1,				0x6C,	"LLH"	},
	{ NONE + 1,				0x6D,	"LLL"	},
	{ NONE + 1,				0x6E,	"LLM"	},
	{ NONE + 1,				0x77,	"LMA"	},
	{ NONE + 1,				0x70,	"LMB"	},
	{ NONE + 1,				0x71,	"LMC"	},
	{ NONE + 1,				0x72,	"LMD"	},
	{ NONE + 1,				0x73,	"LME"	},
	{ NONE + 1,				0x74,	"LMH"	},
	{ NONE + 1,				0x75,	"LML"	},
	{ NONE + 1,				0x76,	"HLT"	}, // LMM is halt

	{ PORT + 2,				0xD3,	"OUT"	}, // *** HRJ in 8008 one byte
	{ PORT + 2,				0xDB,	"INP"	}, // *** in 8080 two bytes



	{ RST_NUM + 1,			0xc7,	"RST"	} //  HRJ 11xxx111 in 8080
    };

    return bccsearch(opctbl,opctbl + (sizeof(opctbl) / sizeof(OPCODE)),nam);
}

/*  Operator table search routine.  This routine pats down the		*/
/*  operator table for a given operator and returns either a pointer	*/
/*  to it or NULL if the opcode doesn't exist.				*/

OPCODE *find_operator(char *nam)

{
    /* OPCODE *bsearch(); */

    static OPCODE oprtbl[] = {
	{ BCDEHLMA + REG,				A,	"A"	},
	{ BINARY + LOG1  + OPR,				AND,	"AND"	},
	{ BCDEHLMA + BDHPSW + BDHSP + BD + REG,		B,	"B"	},
	{ BCDEHLMA + REG,				C,	"C"	},
	{ BCDEHLMA + BDHPSW + BDHSP + BD + REG,		D,	"D"	},
	{ BCDEHLMA + REG,				E,	"E"	},
	{ BINARY + RELAT + OPR,				'=',	"EQ"	},
	{ BINARY + RELAT + OPR,				GE,	"GE"	},
	{ BINARY + RELAT + OPR,				'>',	"GT"	},
	{ BCDEHLMA + BDHPSW + BDHSP + REG,		H,	"H"	},
	{ UNARY  + UOP3  + OPR,				HIGH,	"HIGH"	},
	{ BCDEHLMA + REG,				L,	"L"	},
	{ BINARY + RELAT + OPR,				LE,	"LE"	},
	{ UNARY  + UOP3  + OPR,				LOW,	"LOW"	},
	{ BINARY + RELAT + OPR,				'<',	"LT"	},
	{ BCDEHLMA + REG,				M,	"M"	},
	{ BINARY + MULT  + OPR,				MOD,	"MOD"	},
	{ BINARY + RELAT + OPR,				NE,	"NE"	},
	{ UNARY  + UOP2  + OPR,				NOT,	"NOT"	},
	{ BINARY + LOG2  + OPR,				OR,	"OR"	},
	{ BDHPSW + REG,					PSW,	"PSW"	},
	{ BINARY + MULT  + OPR,				SHL,	"SHL"	},
	{ BINARY + MULT  + OPR,				SHR,	"SHR"	},
	{ BDHSP + REG,					SP,	"SP"	},
	{ BINARY + LOG2  + OPR,				XOR,	"XOR"	}
    };

    return bccsearch(oprtbl,oprtbl + (sizeof(oprtbl) / sizeof(OPCODE)),nam);
}

// static OPCODE *bccsearch(OPCODE *lo, OPCODE *hi, char *nam)
//
// {
//    SCRATCH int i;
//    SCRATCH OPCODE *chk;
//
//    for (;;) {
//	chk = lo + (hi - lo) / 2;
//	if (!(i = ustrcmp(chk -> oname,nam))) return chk;
//	if (chk == lo) return NULL;
//	if (i < 0) lo = chk;
//	else hi = chk;
//    }
// }

static OPCODE *bccsearch(OPCODE *lo, OPCODE *hi, char *nam)
//HRJ simple search to avoid sorting op code table.

{
	SCRATCH int i;
	SCRATCH OPCODE *chk;

	for (chk = lo; chk < hi; chk++) {
	   if (!(i = ustrcmp(chk -> oname,nam))) return chk;
	}
	return NULL;
}

static int ustrcmp(char *s, char *t)

{
    SCRATCH int i;

    while (!(i = toupper(*s++) - toupper(*t)) && *t++);
    return i;
}

/*  Buffer storage for line listing routine.  This allows the listing	*/
/*  output routines to do all operations without the main routine	*/
/*  having to fool with it.						*/

static FILE *list = NULL;

/*  Listing file open routine.  If a listing file is already open, a	*/
/*  warning occurs.  If the listing file doesn't open correctly, a	*/
/*  fatal error occurs.  If no listing file is open, all calls to	*/
/*  lputs() and lclose() have no effect.				*/

void lopen(char *nam)

{

    if (list) warning(TWOLST);
    else if (!(list = fopen(nam,"w"))) fatal_error(LSTOPEN);
    return;
}

/*  Listing file line output routine.  This routine processes the	*/
/*  source line saved by popc() and the output of the line assembler in	*/
/*  buffer obj into a line of the listing.  If the disk fills up, a	*/
/*  fatal error occurs.							*/

/* HRJ change to OCTAL listing from hex */

void lputs(void)
{
    SCRATCH int i, j;
    SCRATCH unsigned *o;
    void fatal_error(char *);
	int address_hi, address_lo;

    if (list) {
	i = bytes;  o = obj;
	do {
	    fprintf(list,"%c  ",errcode);
	    if (listhex) {
		// fprintf(list,"%06o  ",address); non split octal
		address_hi = address / 256; address_lo = address - (address_hi * 256);
		fprintf(list,"%03o %03o  ",address_hi, address_lo);// split octal address
		for (j = 4; j; --j) {
		    // if (i) { --i;  ++address;  fprintf(list," %03o",*o++); }
			if (i) { --i;  ++address;  fprintf(list," %02x",*o++); }
		    else fprintf(list,"    ");
		}
	    }
	    else fprintf(list,"%24s","");
	    fprintf(list,"   %s",lline);  strcpy(lline,"\n");
	    check_page();
	    if (ferror(list)) fatal_error(DSKFULL);
	} while (listhex && i);
    }
    return;
}

/*  Listing file close routine.  The symbol table is appended to the	*/
/*  listing in alphabetic order by symbol name, and the listing file is	*/
/*  closed.  If the disk fills up, a fatal error occurs.		*/

static int col = 0;

void lerror(void)
{
	 if (errors && list) fprintf(list, "%d Error(s)\n",errors); //hrj
}

void lclose(void)
{

    if (list) {
	if (sroot) {
	    list_sym(sroot);
	    if (col) fprintf(list,"\n");
	}
	fprintf(list,"\f");
	if (ferror(list) || fclose(list) == EOF) fatal_error(DSKFULL);
    }
    return;
}

static void list_sym(SYMBOL *sp)
{
	int valu_lo, valu_hi;

 	if (sp) {
	list_sym(sp -> left);
	// fprintf(list,"%04x  %-10s",sp -> valu,sp -> sname);
	valu_hi = sp -> valu / 256; valu_lo = sp -> valu - (valu_hi * 256);
	fprintf(list,"%03o %03o  %-10s",valu_hi, valu_lo, sp -> sname);  //HRJ octal
	if (col = ++col % SYMCOLS) fprintf(list,"    ");
	else {
	    fprintf(list,"\n");
	    if (sp -> right) check_page();
	}
	list_sym(sp -> right);
    }
    return;
}

static void check_page(void)
{
    if (pagelen && !--listleft) eject = TRUE;
    if (eject) {
	eject = FALSE;  listleft = pagelen;  fprintf(list,"\f");
	if (title[0]) { listleft -= 2;  fprintf(list,"%s\n\n",title); }
    }
    return;
}

/*  Buffer storage for hex output file.  This allows the hex file	*/
/*  output routines to do all of the required buffering and record	*/
/*  forming without the	main routine having to fool with it.		*/

static FILE *hex = NULL;
static unsigned cnt = 0;
static unsigned addr = 0;
static unsigned sum = 0;
static unsigned buf[HEXSIZE];

/*  Hex file open routine.  If a hex file is already open, a warning	*/
/*  occurs.  If the hex file doesn't open correctly, a fatal error	*/
/*  occurs.  If no hex file is open, all calls to hputc(), hseek(), and	*/
/*  hclose() have no effect.						*/

void hopen(char *nam)

{

    if (hex) warning(TWOHEX);
    else if (!(hex = fopen(nam,"w"))) fatal_error(HEXOPEN);
    return;
}

/*  Hex file write routine.  The data byte is appended to the current	*/
/*  record.  If the record fills up, it gets written to disk.  If the	*/
/*  disk fills up, a fatal error occurs.				*/

void hputc(unsigned c) // from hputc() HRJ

{

    if (hex) {
	buf[cnt++] = c;
	if (cnt == HEXSIZE) record(0);
    }
    return;
}

/*  Hex file address set routine.  The specified address becomes the	*/
/*  load address of the next record.  If a record is currently open,	*/
/*  it gets written to disk.  If the disk fills up, a fatal error	*/
/*  occurs.								*/

void hseek(unsigned a)

{

    if (hex) {
	if (cnt) record(0);
	addr = a;
    }
    return;
}

/*  Hex file close routine.  Any open record is written to disk, the	*/
/*  EOF record is added, and file is closed.  If the disk fills up, a	*/
/*  fatal error occurs.							*/

void hclose(void)
{

    if (hex) {
	   if (cnt) record(0);
	   record(1);
	   if (fclose(hex) == EOF) fatal_error(DSKFULL);
    }
    return;
}

static void record(unsigned typ)

{
    SCRATCH unsigned i;

	putc(':',hex);  putb(cnt);  putb(high(addr));
    putb(low(addr));  putb(typ);
    for (i = 0; i < cnt; ++i) putb(buf[i]);
    putb(low(0-sum));  putc('\n',hex); /* was (-sum) HRJ*/

    addr += cnt;  cnt = 0;

    if (ferror(hex)) fatal_error(DSKFULL);
    return;
}

static void putb(unsigned b)

{
    static char digit[] = "0123456789ABCDEF";

    putc(digit[b >> 4],hex);  putc(digit[b & 0x0f],hex);
    sum += b;  return;
}

/*  Error handler routine.  If the current error code is non-blank,	*/
/*  the error code is filled in and the	number of lines with errors	*/
/*  is adjusted.							*/

void error(char code)

{
    if (errcode == ' ') { errcode = code;  ++errors; }
    return;
}

/*  Fatal error handler routine.  A message gets printed on the stderr	*/
/*  device, and the program bombs.					*/

void fatal_error(char *msg)

{
    printf("Fatal Error -- %s\n",msg);
    exit(-1);
}

/*  Non-fatal error handler routine.  A message gets printed on the	*/
/*  stderr device, and the routine returns.				*/

void warning(char *msg)

{
    printf("Warning -- %s\n",msg);
    return;
}

