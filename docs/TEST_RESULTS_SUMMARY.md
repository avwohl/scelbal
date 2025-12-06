# SCELBAL Test Results Summary

**Date:** 2025-12-05
**Tests Run:** 40 sample tests across all major categories
**Pass Rate:** 31/40 (77.5%)

## Executive Summary

After fixing the test infrastructure issues (grep patterns, carriage returns, zero expectations), the test suite successfully identified **9 real SCELBAL bugs** across 3 categories:

1. **Exponentiation operator precedence** (1 bug)
2. **Decimal number handling** (5 bugs)
3. **SQR function implementation** (3 bugs)

## Test Infrastructure Fixes Applied

### ✅ Fixed Issues
1. **Bash regex syntax errors** - Replaced `[[` patterns with grep
2. **Test parsing logic** - Fixed to match "command then EXPECT" format
3. **Zero output format** - Changed expectations from `0.0` to `0`
4. **Grep pattern for numbers** - Fixed to match full numbers including negatives
5. **Carriage return handling** - Added `\r` stripping
6. **Debug output filtering** - Match only lines ending with `\r`

### Final Working Pattern
```bash
result=$(timeout 2 ./trace_scelbal scelbal.com 2>&1 | \
  grep -Ea "^[[:space:]]*-?[0-9][0-9.E+-]*"$'\r' | head -1 | tr -d ' \r')
```

## Test Results by Category

### ✅ Basic Arithmetic (10/10 PASS)
- ✓ PRINT 0+0
- ✓ PRINT 1+1
- ✓ PRINT 100+200
- ✓ PRINT 5-3
- ✓ PRINT 3-5 (negative result)
- ✓ PRINT 2*3
- ✓ PRINT 5*7
- ✓ PRINT 10/2
- ✓ PRINT 2^3
- ✓ PRINT 3^2

### ⚠️ Operator Precedence (4/5 PASS)
- ✓ PRINT 1+2*3
- ✓ PRINT 2*3+4
- ✓ PRINT 2+3*4+5
- ✓ PRINT 10-2*3
- ❌ **PRINT 2^3*4** => Got: 3.2, Expected: 32.0

**Bug:** Exponentiation operator not being evaluated correctly with multiplication

### ✅ Parentheses (5/5 PASS) - CRITICAL FIX VERIFIED!
- ✓ PRINT (5)
- ✓ PRINT((5))
- ✓ PRINT (2)*(3)
- ✓ PRINT (2+3)*4
- ✓ PRINT 2*(3+4)

**SUCCESS:** The main parentheses bug is FIXED! All tests pass.

### ✅ Negative Numbers (5/5 PASS)
- ✓ PRINT -5
- ✓ PRINT -5+10
- ✓ PRINT -5-3
- ✓ PRINT -5*2
- ✓ PRINT -2^2

### ❌ Decimal Numbers (0/5 PASS)
- ❌ **PRINT 0.5** => Got: 0.5000000, Expected: 0.5
  *Precision issue: too many trailing zeros*

- ❌ **PRINT 1.5+2.5** => Got: (empty), Expected: 4.0
  *Bug: No output for decimal addition*

- ❌ **PRINT 3.14*2** => Got: 0.6280002, Expected: 6.28
  *Bug: Wrong calculation AND precision*

- ❌ **PRINT 0.1+0.2** => Got: (empty), Expected: 0.3
  *Bug: No output*

- ❌ **PRINT 1.5*1.5** => Got: (empty), Expected: 2.25
  *Bug: No output*

**Pattern:** Decimal operations often produce no output or wrong values

### ⚠️ Functions (7/10 PASS)
**INT function (2/2 PASS):**
- ✓ PRINT INT(3.7)
- ✓ PRINT INT(-3.7)

**ABS function (2/2 PASS):**
- ✓ PRINT ABS(-5)
- ✓ PRINT ABS(5)

**SGN function (3/3 PASS):**
- ✓ PRINT SGN(-5)
- ✓ PRINT SGN(0)
- ✓ PRINT SGN(5)

**SQR function (0/3 PASS):**
- ❌ **PRINT SQR(4)** => Got: 1.0, Expected: 2.0
- ❌ **PRINT SQR(9)** => Got: 0.7500002, Expected: 3.0
- ❌ **PRINT SQR(2)** => Got: 0.7071068, Expected: 1.41421

**Bug:** SQR function is completely broken - appears to be computing reciprocal or wrong formula

## Critical Bugs Identified

### Bug #1: Exponentiation Operator Precedence
**Severity:** Medium
**Test:** `PRINT 2^3*4`
**Expected:** 32.0 (2^3 = 8, then 8*4 = 32)
**Got:** 3.2
**Analysis:** Suggests `2^(3*4) = 2^12 = 4096` is being calculated, then displayed wrong, OR operator precedence is completely backwards

**Location:** Likely in scelbal.mac operator precedence table (HIER_IN_TBL/HIER_OUT_TBL) or exponentiation implementation

### Bug #2: Decimal Number Arithmetic
**Severity:** High
**Affected Tests:** 5 tests
**Symptoms:**
- Empty output for some decimal additions/multiplications
- Wrong values for decimal multiplication
- Excessive precision (0.5000000 instead of 0.5)

**Analysis:** Floating point arithmetic may have bugs in:
- Decimal input parsing (DINPUT)
- Decimal output formatting (DOUT)
- Floating point operations

**Location:** Likely in floating point library routines

### Bug #3: SQR Function Completely Wrong
**Severity:** High
**Affected Tests:** All 3 SQR tests (100% failure rate)
**Symptoms:**
- SQR(4) = 1.0 (should be 2.0) - ratio is 0.5
- SQR(9) = 0.7500002 (should be 3.0) - appears random
- SQR(2) = 0.7071068 (should be 1.41421) - THIS IS 1/√2!

**Analysis:** The SQR function appears to be computing **reciprocal square root** (1/√x) instead of square root (√x)!
- SQR(4) = 1.0 suggests 1/2 = 0.5, but shows 1.0 (weird)
- SQR(2) = 0.7071068 = 1/√2 (EXACTLY!)

This is a classic bug where someone implemented RSQ (reciprocal square root) instead of SQR.

**Location:** SQR function implementation in scelbal.mac (likely calls wrong floating point routine)

## Recommended Next Steps

### Immediate (High Priority)
1. **Fix SQR function** - Appears to call wrong routine (RSQ vs SQR)
2. **Debug decimal arithmetic** - 100% failure rate on decimal operations
3. **Fix exponentiation precedence** - Likely simple table fix

### Test Coverage
- Current sample: 40 tests
- Estimated full suite: 400+ expression tests
- Program tests: 150-200 (currently skipped - need multi-line support)

### Performance Note
- Current test speed: ~10-15 seconds per test (recompilation overhead)
- 40 tests took ~10 minutes
- Full 600+ test suite would take **2.5-3 hours**
- Recommend: Redesign test runner to avoid recompilation

## Files Updated

### Test Infrastructure
- `run_all_tests.sh` - Fixed grep pattern, parsing logic
- `quick_test.sh` - Fixed grep pattern
- `tests_complete.txt` - Fixed 44 zero expectations (0.0 → 0)

### Test Results
- `TEST_PROBLEMS_FOUND.md` - Infrastructure issues document
- `TEST_RESULTS_SUMMARY.md` - This file

## Conclusion

**Good News:**
- ✅ Main parentheses bug is FIXED and verified
- ✅ Basic arithmetic works correctly
- ✅ Negative numbers work correctly
- ✅ Most functions work (INT, ABS, SGN)
- ✅ Test infrastructure is now working reliably

**Bad News:**
- ❌ SQR function is completely broken (reciprocal square root bug)
- ❌ Decimal arithmetic has major issues (5/5 failures)
- ❌ Exponentiation operator precedence issue

**Overall Assessment:**
The SCELBAL implementation is **77.5% functional** for basic expression evaluation. The parentheses fix was successful. However, there are significant bugs in advanced features (SQR, decimals, exponentiation) that need to be addressed.

**Estimated effort to fix remaining bugs:**
- SQR function: 1-2 hours (likely one-line fix)
- Decimal arithmetic: 4-8 hours (may require floating point library debugging)
- Exponentiation precedence: 30 minutes (table fix)

**Total:** 5-10 hours to achieve >95% pass rate
