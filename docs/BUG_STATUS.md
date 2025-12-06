# SCELBAL Bug Status - 2025-12-05

## Current Test Results: 20/39 Passing (51%)

### ✅ Fixed Bugs
1. **SQR Function** - Was using wrong memory address (SCRATCH_1F instead of FPACC_SAVE+3)
   - All SQR tests now pass: SQR(4)=2.0, SQR(9)=3.0, SQR(16)=4.0

2. **FA Stack Corruption** - PRIGHT was using TOKEN_STORE instead of TEMP_STORE
   - Single parentheses now work: `PRINT (5)` = 5.0

3. **RUN Command** - Fixed branch logic (from previous session)

4. **INSERT Routine** - Fixed register corruption (from previous session)

### ✅ Working Features
- Basic arithmetic: `+`, `-`, `*`, `/`
- Operator precedence: `2+3*4` = 14.0
- Negative numbers: `-5`, `3-7`
- Comparisons: `5>3`, `3<5`, `5=5`
- Single parentheses: `(5)`, `(2+3)`
- Functions: INT, SGN, SQR
- Complex expressions: `2*3+4*5` = 26.0

### 🐛 Remaining Bugs

#### Critical (Tests Completely Failing)
1. **Double Parentheses** - `PRINT((5))` returns "FA" error
   - FA_STKPTR ends at 1 instead of 0
   - Suggests unmatched parenthesis tracking

2. **Parentheses with Operations** - `PRINT (2+3)*4` returns "I(" error
   - Similar FA stack issue

3. **Functions with Complex Args** - `PRINT INT(2+3)` returns empty
   - Likely related to FA stack

4. **Nested Function Parens** - `PRINT SQR((16))` returns empty
   - FA stack depth issue

#### High Priority (Wrong Values)
5. **Decimal Multiplication Bug** - `PRINT 1.5*2` = 0.3 instead of 3.0
   - Division by 10 error pattern
   - Works correctly when decimal is second operand: `2*1.5` = 3.0

6. **Decimal Addition Bug** - `PRINT 1.5+2` = 1.7 instead of 3.5
   - Related to decimal handling when first operand

#### Medium Priority (Formatting)
7. **Decimal Display** - `PRINT 0.5` shows `0.5000000` instead of `0.5`
   - Extra trailing zeros

8. **Zero Comparison** - Tests expect `0.0` but SCELBAL outputs `0`
   - Need to update test expectations

## Investigation Notes

### FA Stack Issue
The FA (Function/Array) stack tracks parentheses depth. Current code:
- SCAN6: Increments FA_STKPTR for '('
- SCAN7: Decrements FA_STKPTR for ')'
- PRIGHT: Reads FA_STACK[FA_STKPTR] to check for function/array

Problem: FA_STKPTR ends at 1 for `((5))`, suggesting one ')' isn't decrementing it properly.

### Decimal Bug Pattern
- `1.5*2` = 0.3 (÷10)
- `2*1.5` = 3.0 ✓
- `1.5+2` = 1.7 (wrong calculation)
- `PRINT 1.5` = 1.5 ✓

Suggests the decimal value is corrupted when it's the first operand before an operator.

## Next Steps
1. Fix FA stack underflow/overflow checks in SCAN7
2. Investigate decimal parsing/storage in DINPUT
3. Check NOEXPO routine for stack corruption
4. Add FA_STKPTR bounds checking
