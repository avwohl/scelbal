# SCELBAL Bug Fixing Session Summary
## Date: 2025-12-05

### Starting State
- Previous session had fixed RUN command and FA stack issues
- But SQR function fix was accidentally reverted
- Test infrastructure existed but needed grep pattern fixes

### Accomplishments

#### 1. Reapplied SQR Function Fix
**File**: scelbal.mac line 3799
**Bug**: SQR was using wrong memory address for exponent calculation
- Was using: `SCRATCH_1F` (0x004E)
- Fixed to: `FPACC_SAVE+3` (0x004D)
**Impact**: All SQR tests now pass
- SQR(4) = 2.0 ✓
- SQR(9) = 3.0 ✓
- SQR(16) = 4.0 ✓

#### 2. Fixed Test Infrastructure
**Files**: quick_test.sh, run_all_tests.sh
**Changes**:
- Fixed grep pattern to handle binary output: Added `-a` flag and filtered by "Final output:" section
- Updated zero expectations (0.0 → 0) to match SCELBAL output
- Fixed decimal expectation for 0.5 (accepts 0.5000000)

#### 3. Verified All Previous FA Stack Fixes
- PRIGHT using TEMP_STORE instead of TOKEN_STORE
- Single parentheses working correctly
- Function calls working (INT, SGN, SQR)

### Test Results: 20/39 Passing (51%)

#### ✅ Working Features
- Basic arithmetic: `+`, `-`, `*`, `/`
- Operator precedence: `2+3*4` = 14.0
- Negative numbers: `-5`, `3-7` = -4.0
- Single parentheses: `(5)`, `(2+3)`
- Comparisons: `5>3`, `3<5`, `5=5`
- Functions: INT, SGN, SQR
- Complex expressions: `2*3+4*5` = 26.0

#### 🐛 Remaining Critical Bugs

**1. Double/Nested Parentheses** (FA Error)
- `PRINT((5))` → FA error
- `PRINT (2+3)*4` → I( error
- `PRINT 10/(2+3)` → empty
- **Root Cause**: FA_STKPTR tracking issue
  - FA stack increments for '(' but doesn't decrement correctly for ')'
  - Ends at 1 instead of 0 for `((5))`

**2. Decimal Multiplication Bug** (÷10 Error)
- `PRINT 1.5*2` = 0.3 (should be 3.0)
- `PRINT 2*1.5` = 3.0 ✓ (works when decimal is second)
- `PRINT 1.5+2` = 1.7 (should be 3.5)
- **Pattern**: Only fails when decimal is first operand
- **Investigation**:
  - DINPUT parsing looks correct
  - PERIOD handler properly resets digit counter
  - Exponent adjustment formula correct
  - Issue may be in operator evaluation or stack handling

**3. Functions with Complex Arguments**
- `PRINT INT(2+3)` → empty
- `PRINT SQR((16))` → empty
- `PRINT ABS((-5))` → empty
- **Root Cause**: Related to FA stack bug #1

### Investigation Notes

#### Floating Point Format
SCELBAL uses 4-byte BCD floating point:
- LSW_M1: Extension byte (LSW - 1)
- LSW: Least significant word
- NSW: Next significant word
- MSW: Most significant word (BCD digits)
- EXP: Exponent

Examples:
- 2.0 = MSW=0x40 NSW=0x00 LSW=0x00 EXP=0x02
- 1.5 = MSW=0x60 NSW=0x00 LSW=0x01 EXP=0x01

#### DINPUT Decimal Handling
The PERIOD handler (line 2891-2900):
1. Clears digit counter when '.' encountered
2. Counts only digits after decimal point
3. At EXPOK: negates count and adjusts exponent
4. Calls FPX10 to multiply by 10^exp or MINEXP to divide

This logic appears correct but decimal bug persists.

### Code Changes Summary
**Committed**:
- scelbal.mac: SQR fix (SCRATCH_1F → FPACC_SAVE+3)
- scelbal.mac: PRIGHT fix (TOKEN_STORE → TEMP_STORE)

**Uncommitted** (test files):
- quick_test.sh: grep pattern fixes
- BUG_STATUS.md: comprehensive bug tracking
- SESSION_SUMMARY.md: this document

### Commits Made
1. `c89117e` - "Fix SQR function and FA stack bugs"
   - Fixed SQR exponent address
   - Fixed PRIGHT temp storage
   - Test results: 20/39 passing

### Next Steps
1. **Fix FA Stack Underflow** - Add bounds checking in SCAN7
2. **Debug Decimal Bug** - Trace complete flow from parse to multiply
3. **Add FA Stack Validation** - Prevent negative FA_STKPTR
4. **Test Parentheses Depth** - Verify nested parens work after FA fix

### Performance Metrics
- **Test Pass Rate**: 51% (20/39)
- **Up from**: Initially broken (needed to reapply fixes)
- **Functions Verified**: 6/9 function tests passing
- **Arithmetic Tests**: 5/5 basic tests passing
- **Parentheses**: 1/6 tests passing (only simple cases)

### Key Files
- **Source**: src/scelbal.mac (8080 assembly)
- **Binary**: src/scelbal.com (CP/M executable)
- **Tests**: src/quick_test.sh (39 tests)
- **Symbols**: src/scelbal.sym (symbol table)
- **Tracer**: src/trace_scelbal.cc (debug tool)
