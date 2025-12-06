# FA Stack Bug Investigation - SOLVED

## Summary

Fixed critical infinite loop bug in FUNAR2 and identified root cause of FA errors in PRINT statements with parentheses.

# FA Stack Bug Investigation - Key Findings

## FIXED: FUNAR2 Infinite Loop (CRITICAL)
**Location:** `src/scelbal.mac:3904-3923`

**Problem:** When `NUM_DIM_ARRAYS=0`, FUNAR2 enters infinite loop because counter starts at 1 and never equals 0.

**Fix Applied:**
```assembly
FUNAR2:	LXI H,NUM_DIM_ARRAYS            ;First check if any arrays are defined
	MOV A,M                         ;Fetch number of arrays
	ANA A                           ;Test if zero
	JZ FAERR                        ;If no arrays defined, it's an FA error
	; ... rest of loop
```

## VERIFIED: FA_STACK Addressing
All references to FA_STACK now correctly use `FA_STACK-1` as base with 1-based indexing:
- SCAN6 (line 695): `LXI H,FA_STACK-1`
- PRIGHT (line 1084): `LXI H,FA_STACK-1`
- FUNAR4 (line 1145): `LXI H,FA_STACK-1`

## Current Issue: FA Error After Successful Evaluation

**Symptoms:**
- `PRINT 5` → "5.0" ✓
- `PRINT (5)` → "5.0FA" ✗
- `PRINT((5))` → "FA" ✗
- `PRINT INT(5)` → "5.0FA" ✗

**Execution Flow Confirmed:**
1. '(' character (0xA8) IS being detected at SCAN6 (PC=0x0471)
2. ')' character (0xA9) IS being detected at SCAN7 (PC=0x0493)
3. Both parentheses are being processed correctly

## ROOT CAUSE IDENTIFIED: "PRINT" Keyword in SYMBOL_BUF

**Traced execution shows:**
```
>>> FUNARR entry
  SYMBOL_BUF (cc=05): PRINT
  NUM_DIM_ARRAYS=00

>>> FAERR: FA Error!
```

**Problem Flow:**
1. `PRINT (5)` is parsed and executed correctly
2. Value "5.0" is printed successfully
3. During output processing, SCAN6 encounters '(' again
4. SYMBOL_BUF contains "PRINT" (5 characters)
5. FUNARR is called to check if "PRINT" is a function/array
6. FUNAR1 searches all 8 functions - no match
7. FUNAR2 is called to search arrays
8. NUM_DIM_ARRAYS=00, so FUNAR2 immediately jumps to FAERR (with our fix)
9. "FA" error message is displayed

**Why This Happens:**
The output formatting or statement re-processing code rescans the input line containing "PRINT(", triggering the function/array lookup logic.

## DEEPER ROOT CAUSE: PRINT Statement Pointer Bug

**Traced pointer values show the real problem:**

First EVAL call (CORRECT):
```
EVAL_PTR=07, EVAL_FINISH=09, SCAN_PTR=06
```
- Position 7 = '(' in "PRINT (5)"
- Correctly evaluates expression

Second EVAL call (BUG):
```
EVAL_PTR=01, EVAL_FINISH=09, SCAN_PTR=00
```
- Position 1 = 'P' in "PRINT"!
- Rescans the entire "PRINT (" from beginning
- SYMBOL_BUF accumulates "PRINT" character by character
- When '(' is encountered with "PRINT" in buffer → FUNARR → FAERR

**The Bug Location:**
`PRINT` statement handler (scelbal.mac:1730-1766) has incorrect pointer management when checking for additional fields. After successfully evaluating and printing one field, it loops back to PRINT1 but the EVAL_PTR gets set to position 1 instead of advancing past the completed expression.

**Specific Problem:**
Line 1730-1734 sets `EVAL_PTR = SCAN_PTR + 1`, but SCAN_PTR (line 1762) is set from TOKEN_STORE which points to the field terminator. When looping back through PRINT1→PRINT2→PRINT3, these pointers become corrupted, causing rescan from the beginning.

**Possible Solutions:**
1. **Fix PRINT pointer logic**: Ensure SCAN_PTR is correctly positioned after completing each field
2. **Add keyword check in FUNARR**: Before searching functions/arrays, check if SYMBOL_BUF contains a statement keyword (PRINT, LET, IF, etc.) and return early
3. **Verify field termination**: Ensure the loop-back logic at line 1766 correctly detects end of PRINT fields

**Impact of FUNAR2 Fix:**
- ✅ Prevents infinite loop when NUM_DIM_ARRAYS=0
- ✅ Properly errors out instead of hanging
- ⚠️  Exposes this underlying PRINT statement pointer bug
