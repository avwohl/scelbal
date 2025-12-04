# SCELBAL Language Reference Manual

## Overview

SCELBAL (SCientific ELementary BAsic Language) is a floating-point BASIC interpreter developed by Mark G. Arnold and Nat Wadsworth for the Intel 8008 microprocessor in 1974-1975. It was published by Scelbi Computer Consulting, Inc.

This manual documents the SCELBAL language syntax and semantics as implemented in the original interpreter, suitable for implementing a compiler or new interpreter.

## Program Structure

A SCELBAL program consists of numbered lines. Each line has the format:

```
<line-number> <statement>
```

- **Line numbers**: Integer values used for program ordering and as targets for GOTO/GOSUB
- **Statements**: One statement per line (no multi-statement lines)
- **Maximum line length**: 79 characters (plus character count byte)

## Data Types

### Floating Point Numbers

SCELBAL uses a 4-byte floating point format:
- 3 bytes mantissa (24 bits of precision, ~7 decimal digits)
- 1 byte exponent (signed, base 2)

**Numeric Literals:**
- Integer: `123`, `-45`
- Decimal: `3.14159`, `-0.001`
- Scientific notation: `1.5E10`, `2.7E-5`

**Range:** Approximately ±1.7E38 with 7 significant digits

### Strings

SCELBAL has limited string support:
- Single character input via `INPUT A$` (character stored as ASCII value)
- Single character output via `CHR(n)` function
- Quoted strings in PRINT statements: `PRINT "HELLO"`

## Variables

### Simple Variables

- Names: 1-2 characters
- First character: A-Z (letter)
- Optional second character: A-Z or 0-9

**Examples:** `A`, `X`, `X1`, `AB`, `Z9`

**Storage:** Up to ~19 simple variables (limited by variable table size)

### Array Variables

- Declared with DIM statement
- One-dimensional arrays only
- Zero-based indexing
- Same naming rules as simple variables

**Example:** `DIM A(10)` creates array A with elements A(0) through A(10)

## Statements

### REM - Remark

```
<line-number> REM <any text>
```

Comment line; ignored during execution.

**Example:**
```
100 REM THIS IS A COMMENT
```

### LET - Assignment

```
<line-number> LET <variable> = <expression>
<line-number> <variable> = <expression>
```

The keyword LET is optional (implied LET).

**Examples:**
```
100 LET X = 5
110 Y = X + 1
120 A(I) = X * 2
```

### PRINT - Output

```
<line-number> PRINT <print-list>
```

**Print list elements:**
- Expressions (numeric values)
- Quoted strings: `"text"`
- TAB function: `TAB(n)` moves to column n
- CHR function: `CHR(n)` outputs character with ASCII code n

**Separators:**
- Semicolon (`;`): No spacing between items
- Comma (`,`): Tab to next zone (implementation-defined)
- No separator at end: Outputs CR/LF
- Semicolon at end: Suppresses CR/LF

**Examples:**
```
100 PRINT "X = "; X
110 PRINT A, B, C
120 PRINT TAB(10); "COLUMN 10"
130 PRINT CHR(65)
140 PRINT X;
```

### INPUT - Input

```
<line-number> INPUT <variable-list>
```

Prompts user with `?` and reads numeric value(s).

**String input:** Append `$` to variable name to input single character as ASCII value.

**Examples:**
```
100 INPUT X
110 INPUT A, B, C
120 INPUT A$
```

### GOTO - Unconditional Branch

```
<line-number> GOTO <line-number>
```

Transfers execution to specified line.

**Example:**
```
100 GOTO 500
```

### IF...THEN - Conditional Branch

```
<line-number> IF <condition> THEN <line-number>
```

Evaluates condition; if true (non-zero), branches to specified line.

**Relational operators:**
- `<` less than
- `>` greater than
- `=` equal to
- `<=` less than or equal
- `>=` greater than or equal
- `<>` not equal

**Examples:**
```
100 IF X > 10 THEN 200
110 IF A = B THEN 300
120 IF X <> 0 THEN 150
```

### FOR...NEXT - Counted Loop

```
<line-number> FOR <variable> = <start> TO <limit>
<line-number> FOR <variable> = <start> TO <limit> STEP <increment>
...
<line-number> NEXT <variable>
```

Loop from start value to limit value. Default STEP is 1.

**Examples:**
```
100 FOR I = 1 TO 10
110 PRINT I
120 NEXT I

200 FOR X = 10 TO 0 STEP -1
210 PRINT X
220 NEXT X
```

**Notes:**
- Loop variable must match in FOR and NEXT
- Nested loops supported (limited by FOR/NEXT stack, ~8 levels)
- STEP can be positive or negative

### GOSUB - Subroutine Call

```
<line-number> GOSUB <line-number>
```

Calls subroutine at specified line. Return address saved on stack.

**Example:**
```
100 GOSUB 500
...
500 REM SUBROUTINE
510 PRINT "IN SUBROUTINE"
520 RETURN
```

### RETURN - Subroutine Return

```
<line-number> RETURN
```

Returns from subroutine to statement after calling GOSUB.

**Error:** RT error if RETURN without matching GOSUB.

### DIM - Dimension Array

```
<line-number> DIM <array>(<size>)
```

Declares one-dimensional array with specified size.

**Example:**
```
100 DIM A(20)
110 DIM X(100)
```

**Notes:**
- Arrays are zero-based: DIM A(10) creates A(0) through A(10)
- Must DIM arrays before use
- Limited number of arrays (defined by ARRAY VARIABLES table size)

### END - End Program

```
<line-number> END
```

Terminates program execution and returns to command mode.

## Expressions

### Operators

**Arithmetic operators (in precedence order, highest first):**
1. `^` or `**` - Exponentiation
2. `*` - Multiplication
3. `/` - Division
4. `+` - Addition
5. `-` - Subtraction (also unary minus)

**Relational operators (lowest precedence):**
- `<`, `>`, `=`, `<=`, `>=`, `<>`
- Return 1 for true, 0 for false

**Parentheses:** Override normal precedence

**Examples:**
```
X = A + B * C       REM B*C computed first
X = (A + B) * C     REM A+B computed first
X = 2 ^ 3           REM Result is 8
X = -A + B          REM Unary minus
```

### Built-in Functions

| Function | Description |
|----------|-------------|
| `INT(x)` | Integer part (truncates toward negative infinity) |
| `SGN(x)` | Sign: -1, 0, or +1 |
| `ABS(x)` | Absolute value |
| `SQR(x)` | Square root |
| `RND(x)` | Random number (0 < result < 1) |
| `TAB(x)` | Move to column x in PRINT statement |
| `CHR(x)` | Output character with ASCII code x |
| `UDF(x)` | User-defined function (machine language) |

**Examples:**
```
100 X = INT(3.7)      REM X = 3
110 Y = INT(-3.7)     REM Y = -4
120 S = SGN(-5)       REM S = -1
130 A = ABS(-42)      REM A = 42
140 R = SQR(16)       REM R = 4
150 N = RND(0)        REM Random number
160 PRINT CHR(65)     REM Prints "A"
```

**Note:** SCELBAL does not include SIN, COS, TAN, ATN, EXP, or LOG functions in the base implementation. The function table has entries for these but they may not be implemented.

## Immediate Commands

These commands are entered without line numbers and execute immediately:

### RUN

Executes the program from the lowest line number.

### LIST

Lists the entire program to the output device.

### SCR (Scratch)

Clears the program from memory and resets all variables.

### SAVE

Saves program to external storage (implementation-dependent).

### LOAD

Loads program from external storage (implementation-dependent).

## Error Messages

SCELBAL displays two-letter error codes:

| Code | Meaning |
|------|---------|
| FE | FOR Error - malformed FOR statement |
| GS | GOSUB Error - GOSUB stack overflow |
| RT | RETURN Error - RETURN without GOSUB |
| DM | DIMension Error - malformed DIM or duplicate array |
| SN | Syntax Error |
| OV | Overflow Error |
| (others) | Various error conditions |

Error display format: `<error-code> AT LINE <line-number>`

## Memory Organization

**User Program Buffer:**
- Lines stored with character count prefix
- Sequential storage in memory
- INSERT operation adds/replaces lines
- DELETE operation removes lines (enter line number with no statement)

**Variable Storage:**
- Simple variables: 4 bytes each (floating point)
- Array values: 4 bytes per element
- Symbol table: 2 bytes per variable name

## Limitations

- Maximum 79 characters per line
- 1-2 character variable names only
- One-dimensional arrays only
- Single statement per line
- Limited nesting depth for FOR/NEXT (~8 levels)
- Limited GOSUB depth (~4 levels)
- Limited number of variables (~19)
- Limited number of arrays (~8)
- No string variables (only single character I/O)
- No logical operators (AND, OR, NOT)

## Sample Programs

### Simple Loop
```
10 REM COUNT TO 10
20 FOR I = 1 TO 10
30 PRINT I
40 NEXT I
50 END
```

### Factorial
```
10 REM FACTORIAL CALCULATOR
20 INPUT N
30 F = 1
40 FOR I = 1 TO N
50 F = F * I
60 NEXT I
70 PRINT "FACTORIAL = "; F
80 END
```

### Quadratic Formula
```
10 REM QUADRATIC FORMULA
20 PRINT "ENTER A, B, C"
30 INPUT A, B, C
40 D = B*B - 4*A*C
50 IF D < 0 THEN 100
60 X1 = (-B + SQR(D)) / (2*A)
70 X2 = (-B - SQR(D)) / (2*A)
80 PRINT "X1 = "; X1
90 PRINT "X2 = "; X2
95 END
100 PRINT "NO REAL ROOTS"
110 END
```

### Array Example
```
10 REM ARRAY SUM
20 DIM A(10)
30 FOR I = 0 TO 10
40 A(I) = I * 2
50 NEXT I
60 S = 0
70 FOR I = 0 TO 10
80 S = S + A(I)
90 NEXT I
100 PRINT "SUM = "; S
110 END
```

## Grammar (BNF)

```
<program>     ::= <line>*
<line>        ::= <line-number> <statement>
<line-number> ::= <digit>+

<statement>   ::= <rem-stmt>
               | <let-stmt>
               | <print-stmt>
               | <input-stmt>
               | <goto-stmt>
               | <if-stmt>
               | <for-stmt>
               | <next-stmt>
               | <gosub-stmt>
               | <return-stmt>
               | <dim-stmt>
               | <end-stmt>

<rem-stmt>    ::= REM <any-text>
<let-stmt>    ::= [LET] <variable> = <expression>
<print-stmt>  ::= PRINT [<print-list>]
<input-stmt>  ::= INPUT <var-list>
<goto-stmt>   ::= GOTO <line-number>
<if-stmt>     ::= IF <condition> THEN <line-number>
<for-stmt>    ::= FOR <simple-var> = <expr> TO <expr> [STEP <expr>]
<next-stmt>   ::= NEXT <simple-var>
<gosub-stmt>  ::= GOSUB <line-number>
<return-stmt> ::= RETURN
<dim-stmt>    ::= DIM <simple-var> ( <integer> )
<end-stmt>    ::= END

<print-list>  ::= <print-item> [<separator> <print-item>]*
<print-item>  ::= <expression> | <string> | TAB(<expr>) | CHR(<expr>)
<separator>   ::= , | ;
<string>      ::= " <characters> "

<var-list>    ::= <variable> [, <variable>]*
<variable>    ::= <simple-var> | <array-ref>
<simple-var>  ::= <letter> [<letter> | <digit>]
<array-ref>   ::= <simple-var> ( <expression> )

<condition>   ::= <expression> <relop> <expression>
<relop>       ::= < | > | = | <= | >= | <>

<expression>  ::= <term> [(+ | -) <term>]*
<term>        ::= <power> [(* | /) <power>]*
<power>       ::= <factor> [^ <factor>]
<factor>      ::= <number>
               | <variable>
               | ( <expression> )
               | <function> ( <expression> )
               | - <factor>

<function>    ::= INT | SGN | ABS | SQR | RND | TAB | CHR | UDF

<number>      ::= [<sign>] <digit>+ [. <digit>*] [E [<sign>] <digit>+]
<sign>        ::= + | -
<letter>      ::= A | B | ... | Z
<digit>       ::= 0 | 1 | ... | 9
```

## Token Values

The SCELBAL parser assigns these internal token values to statements:

| Token | Statement |
|-------|-----------|
| 01H | REM |
| 02H | IF |
| 03H | LET |
| 04H | GOTO |
| 05H | PRINT |
| 06H | INPUT |
| 07H | FOR |
| 08H | NEXT |
| 09H | GOSUB |
| 0AH | RETURN |
| 0BH | DIM |
| 0CH | END |
| 0DH | Implied LET (assignment without keyword) |
| 0EH | Implied Array LET |

## Function Token Values

| Token | Function |
|-------|----------|
| 01H | INT |
| 02H | SGN |
| 03H | ABS |
| 04H | SQR |
| 05H | TAB |
| 06H | RND |
| 07H | CHR |
| 08H | UDF |

## Operator Hierarchy Values

Used by expression parser for precedence:

| Value | Operators |
|-------|-----------|
| 6 | ( left parenthesis (into stack) |
| 5 | ^ exponentiation |
| 4 | * / multiplication, division |
| 3 | + - addition, subtraction |
| 2 | < = > <= >= <> relational |
| 1 | ) right parenthesis |
| 0 | end of expression |

---

*Based on analysis of SCELBAL source code, Copyright 1975 Scelbi Computer Consulting, Inc.*
*Documented for educational and historical purposes.*
