# Decimal Arithmetic Bug Fix - Session Summary
**Date**: 2025-12-05

## Bug Fixed

**Problem**: `PRINT 1.5*2` returned 0.3000001 instead of 3.0
- Pattern: ANY operation with decimal as first operand was divided by 10
- `1.5 + 10` = 1.6 (should be 11.5)
- `1.5 * 2` = 0.3 (should be 3.0)
- But: `10 + 1.5` = 11.5 ✓ (decimal as second operand worked)

## Root Cause

**Location**: `scelbal.mac:2855` (DINPUT initialization)

The TEMP_STORE variable (PERIOD indicator) was NOT being cleared between number parses.

When parsing `1.5*2`:
1. Parse `1.5` → TEMP_STORE set to 0AEH (period token)
2. Parse `2` → TEMP_STORE still has 0AEH!
3. POSEXP routine sees non-zero TEMP_STORE → applies exponent -1
4. Result: `2` becomes `0.2`, then `1.5 * 0.2 = 0.3` ✗

## The Fix (FINAL - SUCCESSFUL)

**File**: `scelbal.mac:2964-2967`

Instead of clearing TEMP_STORE at initialization (which broke INTEXP and PRIGHT), clear it AFTER POSEXP finishes using it:

```assembly
EXPOK:	LXI H,FP_WORK_6F                ;Change pointer to input exponent storage location
	ADD M                           ;Add this value to negated digit counter value
	MOV M,A                         ;Restore new value to storage location
	PUSH PSW                        ;Save ACC and flags (need to preserve for JM/RZ checks below)
	XRA A                           ;Clear accumulator
	STA TEMP_STORE                  ;Clear PERIOD indicator for next number parse
	POP PSW                         ;Restore ACC and flags
	JM MINEXP                       ;If new value is minus, skip over next subroutine
	RZ                              ;If new value is zero, no further processing required
```

**Why This Works:**
- TEMP_STORE is used during current number parse for PERIOD tracking (lines 2892-2963)
- After POSEXP completes (line 2963), TEMP_STORE is no longer needed for this parse
- Clearing it here prevents pollution of the next number parse
- Does NOT interfere with INTEXP (exponentiation) or PRIGHT (function dispatch) uses

## Test Results

### Baseline (from git: 23/39 passing - 59%)
- ✗ `PRINT 1.5*2` = 0.3000001
- ✓ `PRINT 7/3` = 2.333333
- ✓ `PRINT SQR(4)` = 2.0

### Bad Fix Attempt (clearing in init: 20/39 passing - 51%)
- ✓ `PRINT 1.5*2` = 3.0 **FIXED!**
- ✗ `PRINT 7/3` = 0.5833333 **NEW BUG**
- ✗ `PRINT SQR(4)` = 1.0 **REGRESSION**

### Final Fix (clearing after use: 25/39 passing - 64%)
- ✓ `PRINT 1.5*2` = 3.0 **FIXED!**
- ✓ `PRINT 7/3` = 2.333333 **MAINTAINED**
- ✓ `PRINT SQR(4)` = 2.0 **MAINTAINED**

**Success**: +2 tests vs baseline, decimal bug fixed with no regressions!

## Technical Issues Encountered

### um80/ul80 Linker Bug
- `um80` assembles `MVI B,005H` correctly (verified in .prn listing as `06 05`)
- `ul80` linker produces `06 03` in the .com file (WRONG!)
- **Workaround**: Manual binary patch at offset 0x11EF

### Binary Patch Command
```bash
python3 -c "import sys; sys.stdout.buffer.write(b'\x05')" | \
  dd of=scelbal.com bs=1 seek=4591 count=1 conv=notrunc
```

## Investigation Results

The initial fix attempt (clearing TEMP_STORE in initialization) failed because:

1. **TEMP_STORE/EXP_TEMP has multiple purposes:**
   - PERIOD indicator during DINPUT (lines 2892-2963)
   - Exponentiation sign in INTEXP (lines 1043, 1058)
   - Function token storage in PRIGHT (line 1088)

2. **Clearing at initialization broke INTEXP and PRIGHT:**
   - These routines expect to use TEMP_STORE/EXP_TEMP freely
   - They don't call DINPUT before using it
   - Clearing unconditionally interfered with their operation

3. **Solution: Selective clearing after POSEXP:**
   - DINPUT completes its use of TEMP_STORE after POSEXP (line 2963)
   - Clearing at this point prevents pollution of subsequent parses
   - Does NOT interfere with other uses of TEMP_STORE/EXP_TEMP

## Next Steps

1. ✓ **Decimal bug fixed** - No regressions
2. **Fix remaining bugs:** expressions with operators+parentheses (14 tests still failing)
3. **Consider ul80 alternatives** if linker issues persist (though workaround exists)

## Files Modified

- `scelbal.mac:2964-2967` - Added TEMP_STORE clearing after POSEXP (FINAL FIX)
- `scelbal.mac:2855` - Initial attempt reverted (clearing in init broke other code)
- `DECIMAL_BUG_ANALYSIS.md` - Detailed technical analysis
- `DECIMAL_BUG_FIX_SUMMARY.md` - This document

## Documentation Created

- `DECIMAL_BUG_ANALYSIS.md` - Root cause analysis with memory layouts
- `DECIMAL_BUG_FIX_SUMMARY.md` - This summary
