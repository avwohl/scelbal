# SCELBAL Bug Investigation Summary
## Session: 2025-12-05

### Progress Made
- **Test Results**: 24/39 passing (61%), up from 20/39 (51%)
- **Fixed**: Basic double parentheses `((5))` with hierarchy table change
- **Side Effect**: Broke function calls with expressions `INT(2+3)`

### Key Bugs Identified

#### 1. Double Parentheses / Function Calls (CRITICAL - Tradeoff)
**Current State**: `HIER_IN[(]=007H`
- ✅ Fixes: `PRINT ((5))` = 5.0
- ✅ Fixes: `PRINT INT((5))` = 5.0  
- ❌ Breaks: `PRINT INT(2+3)` → "I(" error
- ❌ Breaks: `PRINT ((2+3))` → "I(" error
- ❌ Breaks: `PRINT (2*(3+4))` → "I(" error

**Root Cause**: Hierarchy table doesn't distinguish between:
- Grouping parentheses: `((5))`  
- Function call parentheses: `INT(2+3)`

**Proper Fix Needed**: Check FA_STACK in PARSE1 to differentiate:
- If FA_STACK[FA_STKPTR] == 0: grouping paren (allow execution block)
- If FA_STACK[FA_STKPTR] != 0: function paren (don't execute)

#### 2. Decimal Arithmetic Bug (CRITICAL)
**Pattern**: Division by 10 error when decimal is first operand
- `PRINT 1.5*2` = 0.3000001 (should be 3.0)
- `PRINT 2*1.5` = 3.0 ✓ (works when decimal is second)
- `PRINT 1.5+2` = likely also wrong

**Root Cause**: Unknown - requires deep investigation of:
- DINPUT routine (decimal parsing)
- PERIOD handler (decimal point processing)
- NOEXPO routine (stack handling for numbers)
- Floating point storage/retrieval

#### 3. Formatting Issues (MINOR)
- Comparisons return `0` instead of `0.0` 
- Just needs test expectation updates

### Recommendations for Next Session

1. **Revert HIER_IN[(] to 001H** (original value)
2. **Implement FA_STACK check in PARSE1**:
   ```assembly
   PARSE1: ... (fetch operator from stack)
           CPI 006H          ; Check if '('
           JNZ PARS1B        ; If not, proceed normally
           ; Check FA_STACK to see if this is a function call
           LDA FA_STKPTR
           MOV C,A
           LXI H,FA_STACK-1
           MVI B,000H
           DAD B
           MOV A,M           ; Get FA_STACK entry
           ANA A             ; Test if zero (grouping)
           JNZ PARS1B        ; If function, proceed to execute
           ; If grouping paren, push current operator
           ...
   ```
3. **Investigate decimal bug** with detailed tracing of DINPUT/PERIOD
4. **Update test expectations** for 0 vs 0.0

### Files Modified
- `scelbal.mac:3340` - HIER_IN[(] changed from 001H to 007H

### Test Coverage
Current: 24/39 (61%)
Target: 30+ (77%+) with proper fixes
