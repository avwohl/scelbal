# Parentheses Bug Investigation

## Status: In Progress

**Test Results**: 27/39 passing (69%)

## Problem Description

12 tests are failing, all related to expressions with operators inside parentheses:

### Failing Test Patterns
- Double parentheses: `PRINT((5))` - returns empty
- Operators inside parentheses: `PRINT (2+3)*4` - returns empty
- Complex expressions: `PRINT (2+3)*(4+5)` - returns empty
- Functions with expressions: `PRINT INT(2+3)` - returns empty
- Functions with negative args: `PRINT ABS(-5)` - returns empty
- Division with parentheses: `PRINT 10/(2+3)` - returns empty

### Working Cases
- Simple parentheses: `PRINT (5)` - works (returns 5.0)
- Simple multiplication: `PRINT (2)*(3)` - works (returns 6.0)
- Expressions without parentheses: `PRINT 2+3*4` - works (returns 14.0)

## Code Locations

### Key Routines (scelbal.mac)

1. **SCAN6** (line 686):
   - Detects '(' (0xA8)
   - Increments FA_STKPTR
   - Calls FUNARR (checks for functions/arrays)
   - Sets PARSER_TOKEN = 006H
   - Calls PARSER

2. **SCAN7** (line 704):
   - Detects ')' (0xA9)
   - Sets PARSER_TOKEN = 007H
   - Calls PARSER
   - Calls PRIGHT
   - Decrements FA_STKPTR

3. **PARSER** (line 897):
   - Uses hierarchy tables to decide operator precedence
   - HIER_IN_TBL: incoming operator hierarchy
   - HIER_OUT_TBL: stack operator hierarchy

4. **PRIGHT** (line 1081):
   - Processes right parenthesis
   - Fetches FA_STACK top value
   - If zero: simple grouping
   - If positive (1-8): execute function
   - If negative: array subscript

5. **FUNARR** (line 1111):
   - Called by SCAN6 when '(' detected
   - Checks if SYMBOL_BUF contains function name
   - If empty: simple grouping parenthesis
   - If function found: stores token in FA_STACK

### Hierarchy Tables (scelbal.mac:3318-3348)

**Current Configuration**:
```
HIER_OUT_TBL:
  006H → 006H  ; LEFT PARENTHESIS (out)
  007H → 001H  ; RIGHT PARENTHESIS (out)

HIER_IN_TBL:
  006H → 007H  ; LEFT PARENTHESIS (in) - CHANGED from 001H
  007H → 001H  ; RIGHT PARENTHESIS (in)
```

**Previous Commit** (d39529b):
- Changed HIER_IN[(] from 001H to 007H to fix double parentheses
- This partially worked but created new issues

## Trace Analysis

### Test Case: `PRINT (2*(3+4))`

Key observations from trace_scelbal.cc output:

1. **Both SCAN6 calls show position 00**:
   ```
   >>> SCAN6: '(' encountered at pos 00, A=A8
   >>> SCAN6: '(' encountered at pos 00, A=B2
   ```
   - Position counter not advancing properly
   - Second call shows A=B2 ('2') not A=A8 ('(')

2. **PARSER called with token=0**:
   ```
   >>> PARSER: Processing token=0, OP_STKPTR=06, SYMBOL_BUF[cc=00]
   ```
   - PARSER_TOKEN should be 006H or 007H, not 0
   - Suggests PARSER_TOKEN is not being set or is corrupted

3. **Final result is empty**:
   - No FPACC values computed
   - Expression evaluation stops prematurely

## Root Cause Hypotheses

### Hypothesis 1: PARSER_TOKEN Corruption
- PARSER_TOKEN is stored at memory location (needs verification)
- May be getting cleared or overwritten during FUNARR call
- SCAN6 sets it to 006H before calling PARSER
- Trace shows it as 0 when PARSER executes

### Hypothesis 2: Evaluation Position Tracking
- EVAL_CURRENT pointer not advancing correctly
- All SCAN events show "pos 00"
- May be stuck in loop or position reset incorrectly

### Hypothesis 3: Hierarchy Table Interaction
- HIER_IN[(] = 007H may conflict with other operators
- Value 007H is same as ')' token
- May cause parser to incorrectly handle precedence

## Investigation Attempts

### Attempt 1: Match HIER_IN and HIER_OUT
- Set both to 007H for '('
- Result: 23/39 passing (no improvement)

### Attempt 2: Set HIER_IN[(] to 002H
- Result: 22/39 passing (worse)

### Conclusion
Hierarchy table adjustments alone cannot solve this issue. The problem appears to be in:
1. How PARSER_TOKEN is set and preserved
2. How EVAL_CURRENT position is tracked
3. Interaction between SCAN6, FUNARR, PARSER, and PRIGHT

## Next Steps

1. **Assembly-level debugging**:
   - Add more detailed trace points for PARSER_TOKEN
   - Track EVAL_CURRENT at each step
   - Monitor FA_STACK and OP_STACK states

2. **Compare with known working version**:
   - Check if original SCELBAL source has this issue
   - Look for differences in SCAN6/SCAN7/PARSER implementation

3. **Investigate FUNARR**:
   - Check if CLESYM (called at end) corrupts PARSER_TOKEN
   - Verify FA_STACK manipulation doesn't affect token storage

4. **Test simpler cases**:
   - `PRINT ((5))` - double parentheses only
   - `PRINT (5+1)` - single operator inside parentheses
   - Build up complexity to isolate exact failure point

## Memory Locations to Monitor

- PARSER_TOKEN: Token storage for current operator
- EVAL_CURRENT: Current position in expression
- EVAL_FINISH: End position of expression
- FA_STKPTR: Function/Array stack pointer
- OP_STKPTR: Operator stack pointer
- SYMBOL_BUF: Symbol buffer (may affect PARSER_TOKEN)
- TEMP_STORE: Temporary storage (aliased with EXP_TEMP)

## Test Results History

- Baseline (commit c89117e): 23/39 (59%)
- After decimal fix: 25/39 (64%)
- After test expectations fix: 27/39 (69%)
- **Current**: 27/39 (69%)

### Remaining 12 Failures
All involve expressions with operators inside parentheses or function calls.
