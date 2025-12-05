# SCELBAL FA Stack Bugs - Complete Analysis

## Executive Summary

Investigation of FA errors in `PRINT (5)` revealed **four bugs** in SCELBAL:

1. **FUNAR2 Infinite Loop** (FIXED ✅)
2. **ARRAY6 Infinite Loop** (FIXED ✅)
3. **PRIGHT TOKEN_STORE Corruption** (FIXED ✅)
4. **SYNTAX Keyword Detection** (FIXED ✅)
5. **Nested Parenthesis I( Error** (IN PROGRESS ⚠️)

---

## Bug #1: FUNAR2 Infinite Loop (FIXED) ✅

### Location
`src/scelbal.mac:3904-3907`

### Fix Applied
```assembly
FUNAR2:	LXI H,NUM_DIM_ARRAYS     ; Check array count first
	MOV A,M
	ANA A
	JZ FAERR                 ; If 0 arrays, error immediately
	; ... rest of loop
```

---

## Bug #2: ARRAY6 Infinite Loop (FIXED) ✅

### Location
`src/scelbal.mac:3966-3969`

### Fix Applied
```assembly
ARRAY6:	LXI H,NUM_DIM_ARRAYS            ;First check if any arrays defined
	MOV A,M                         ;Fetch number of arrays
	ANA A                           ;Test if zero
	JZ FAERR                        ;If no arrays, error immediately
	; ... rest of loop
```

---

## Bug #3: PRIGHT TOKEN_STORE Corruption (FIXED) ✅

### Location
`src/scelbal.mac:1088`

### Fix Applied
```assembly
PRIGHT:	; ... FA_STACK processing ...
	LXI H,TEMP_STORE                ;Use TEMP_STORE instead of TOKEN_STORE!
	MOV M,A                         ;Store value in temp loc
```

---

## Bug #4: SYNTAX Keyword Detection Before '(' (FIXED) ✅

### Location
`src/scelbal.mac:375-419`

### Symptom
```
PRINT((5)) → "FA"  # Before fix: treated "PRINT" as array name
PRINT((5)) → "I("  # After fix: recognized as keyword, different error
```

### Root Cause
When SYNTAX encountered `WORD(`, it immediately assumed it was an array assignment (like `A(5)=10`) without checking if WORD was a keyword.

For `PRINT((5))`:
1. Scanned 'P', 'R', 'I', 'N', 'T' into SYMBOL_BUF
2. Hit '(' at position 5
3. Jumped to SYNTX8, set TOKEN=0x0E (array implied LET)
4. Never checked if "PRINT" was a keyword
5. DIRECT called ARRAY1 → ARRAY6 → FAERR

### Fix Applied
```assembly
; Line 376: When '(' encountered, check for keyword first
	CPI 0A8H                        ;Else, compare character with left parenthesis " ( "
	JZ SYNTX6                       ;If '(', check if word before it is keyword
```

```assembly
; Lines 409-419: After keyword search fails, check if it's an array
	CPI 00DH                        ;See if have tested all entries in the keyword table.
	JNZ SYNTX5                      ;If not, continue checking the keyword table.
	;; Not a keyword - check if current char is '(' for array assignment
	LXI H,SCAN_PTR                  ;Get current scan position
	CALL GETCHR                     ;Fetch the character
	CPI 0A8H                        ;Is it '(' ?
	JNZ SYNTX9                      ;If not '(', it's a syntax error
	LXI H,TOKEN_STORE               ;If '(', set TOKEN for array implied LET
	MVI M,00EH                      ;TOKEN = 0x0E
	RET                             ;Return with array assignment token
SYNTX9:	LXI H,TOKEN_STORE               ;Not keyword, not array - error
	MVI M,0FFH                      ;Set TOKEN=0xFF as error indicator
	RET                             ;Exit to calling routine.
```

### Impact
- ✅ "PRINT" now correctly recognized as keyword
- ✅ `A(5)=10` still works (array assignment)
- ✅ `PRINT (5)` works
- ✅ `PRINT INT(5)` works
- ⚠️  `PRINT((5))` now shows "I(" instead of "FA"

---

## Bug #5: Nested Parenthesis I( Error (IN PROGRESS) ⚠️

### Symptom
```
PRINT (5)       → "5.0"    ✓ Works
PRINT INT(5)    → "5.0"    ✓ Works
PRINT((5))      → "I("     ✗ Imbalanced Parenthesis error
PRINT 2*(3+4)   → "I("     ✗ Nested parens in expression fail
PRINT (2)*(3)   → "3.0"    ✗ Wrong result (should be 6.0)
```

### Investigation Status
- SYNTAX fix resolved the FA error
- Now getting I( (Imbalanced Parenthesis) error
- Appears to affect any nested or multiple parentheses in expressions
- Single-level parentheses work correctly

### Next Steps
1. Trace parenthesis counting in EVAL/SCAN routines
2. Verify FA_STKPTR increment/decrement logic
3. Check if PRIGHT is being called correctly for each ')'

---

## Testing Results

| Test Case | Before All Fixes | After All Fixes | Status |
|-----------|------------------|-----------------|--------|
| PRINT 5 | ✓ Works | ✓ Works | ✅ |
| PRINT (5) | ✗ "5.0FA" | ✓ "5.0" | ✅ |
| PRINT INT(5) | ✗ "5.0FA" | ✓ "5.0" | ✅ |
| PRINT 2+3 | ? | ✓ "5.0" | ✅ |
| PRINT((5)) | ✗ Infinite BG | ✗ "I(" | ⚠️ |
| PRINT 2*(3+4) | ? | ✗ "I(" | ⚠️ |
| PRINT (2)*(3) | ? | ✗ "3.0" (wrong) | ⚠️ |

---

## Status

- [x] Bug #1 (FUNAR2) - **FIXED**
- [x] Bug #2 (ARRAY6) - **FIXED**
- [x] Bug #3 (PRIGHT) - **FIXED**
- [x] Bug #4 (SYNTAX keyword) - **FIXED**
- [ ] Bug #5 (Nested parens) - **IN PROGRESS**

## Files Modified

1. **`src/scelbal.mac`** - Applied four fixes:
   - Line 1088: PRIGHT fix (use TEMP_STORE)
   - Line 376: SYNTAX '(' detection (jump to SYNTX6)
   - Lines 409-419: SYNTAX keyword vs array logic
   - Line 3904-3907: FUNAR2 fix (early NUM_DIM_ARRAYS check)
   - Line 3966-3969: ARRAY6 fix (early NUM_DIM_ARRAYS check)

2. **`src/trace_scelbal.cc`** - Symbol loader and comprehensive tracing

3. **`BUGS_FOUND.md`** - This document

Built successfully: `scelbal.com` with all fixes
Tracer built: `trace_scelbal` with symbol loading
