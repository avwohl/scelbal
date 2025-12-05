# Decimal Arithmetic Bug Analysis
**Date**: 2025-12-05
**Bug**: `PRINT 1.5*2` = 0.3000001 instead of 3.0

## Root Cause Found

**Location**: `scelbal.mac:2855` (DINPUT initialization, CLRNX3 loop)

**The Bug**: TEMP_STORE (the PERIOD indicator) is NOT cleared between number parses.

### Memory Layout
```
SIGN_IND2    (offset 0)  - Sign indicator
FPFLT_FLAG   (offset 1)  - FPFLT vs FPNORM flag
EXP_SIGNS    (offset 2)  - Exponent sign
INP_DIG_CNT  (offset 3)  - Input digit counter
TEMP_STORE   (offset 4)  - PERIOD indicator ⚠️ NOT CLEARED
```

### Current Code (lines 2854-2859)
```assembly
LXI H,SIGN_IND2                 ;Set pointer to SIGN_IND2
MVI B,004H                      ;Clear 4 bytes (was 003H in current .com)
CLRNX3:	MOV M,A                 ;Clear byte
INX H                           ;Next byte
DCR B                           ;Decrement counter
JNZ CLRNX3                      ;Loop until done
```

**Problem**: Clears only SIGN_IND2, FPFLT_FLAG, EXP_SIGNS, INP_DIG_CNT (4 bytes).
TEMP_STORE (offset 4) is NOT cleared!

### How the Bug Manifests

For expression `1.5*2`:

1. **Parse `1.5`**:
   - TEMP_STORE set to 0AEH (period token)
   - Number parsed correctly as 1.5

2. **Parse `2`**:
   - DINPUT clears SIGN_IND2 through INP_DIG_CNT
   - ⚠️ TEMP_STORE still contains 0AEH from previous parse!
   - At POSEXP (line 2954), code checks TEMP_STORE
   - Finds it non-zero → incorrectly applies exponent adjustment of -1
   - Result: `2` becomes `0.2`

3. **Multiply**: `1.5 * 0.2 = 0.3` ✗

### Test Results Showing Pattern
- `PRINT 1.5` = 1.5 ✓ (first number parsed correctly)
- `PRINT 1.5*2` = 0.3000001 ✗ (second number divided by 10)
- `PRINT 2*1.5` = 3.0 ✓ (decimal as second operand works)
- `PRINT 1.5+10` = 1.6 ✗ (should be 11.5, off by factor of 10)
- `PRINT 10+1.5` = 11.5 ✓ (decimal as second operand works)

**Pattern**: ANY operation where decimal is FIRST operand fails. Second operand is incorrectly divided by 10.

## The Fix

**Change line 2855 from**:
```assembly
MVI B,004H                      ;Clear 4 bytes
```

**To**:
```assembly
MVI B,005H                      ;Clear 5 bytes (including TEMP_STORE)
```

This ensures TEMP_STORE is cleared along with the other temporary variables.

### Binary Patch
- **Address**: 0x12EE (in assembled code)
- **File offset**: 0x11EF in scelbal.com
- **Change**: Byte at offset 0x11EF from `04` to `05`

## Important Notes

1. **Current scelbal.com has `MVI B,003H`** (clears only 3 bytes), which is even worse than the original 8080 version's `004H`.

2. **The binary needs to be rebuilt** from scelbal.mac after applying the fix. The current .com file is out of sync with recent source changes.

3. **Testing with `MVI B,005H`** initially showed new failures in SQR and division, but this was because the .com binary was already broken and missing recent fixes.

## References
- Original 8080 version: `scelbal8080.asm` has `MVI B,004H`
- PERIOD handler: `scelbal.mac:2891-2900`
- POSEXP exponent adjustment: `scelbal.mac:2954-2963`
- DINPUT initialization: `scelbal.mac:2845-2859`
