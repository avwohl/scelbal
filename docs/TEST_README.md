# SCELBAL Test Suite

Comprehensive testing for the SCELBAL BASIC interpreter.

## Quick Start

Run the quick test suite (tests core functionality, ~45 tests):
```bash
cd /home/wohl/src/scelbal/src
./quick_test.sh
```

## Test Files

### Test Data Files

1. **`tests_all.txt`** - Comprehensive test suite covering ALL SCELBAL features
   - 400+ test cases
   - Format: Command followed by `; EXPECT: <value>` comments
   - Covers:
     - Basic arithmetic (+, -, *, /)
     - Exponentiation (^)
     - Parentheses (all nesting levels)
     - Negative numbers
     - Decimal numbers
     - Scientific notation (1.5E2)
     - Variables (LET, implied LET)
     - Built-in functions (INT, ABS, SGN, SQR, RND)
     - Comparison operators (<, >, =, <=, >=, <>)
     - Complex expressions
     - Programs with line numbers
     - GOTO, IF/THEN, FOR/NEXT, GOSUB/RETURN
     - Arrays (DIM, subscripts)
     - REM statements
     - LIST, RUN, SCR commands
     - Error conditions

2. **`test_suite.txt`** - Interactive test file with comments
   - Can be used with: `cpmemu scelbal.cfg < test_suite.txt`
   - Includes expected results in comments

3. **`test_clean.txt`** - Streamlined version without comments
   - 42 immediate-mode tests
   - No program tests

4. **`test_print.txt`** - Focused on PRINT/parentheses bugs
   - 6 specific test cases

### Test Runner Scripts

1. **`quick_test.sh`** ⭐ **RECOMMENDED**
   - Fast test of core functionality
   - ~45 essential tests
   - Tests all the major bug fixes
   - Run time: ~2-3 minutes
   - Usage: `./quick_test.sh`

2. **`test_print.sh`** - Original parentheses test script
   - 9 tests focused on parentheses handling
   - Usage: `./test_print.sh`

3. **`run_tests_fast.sh`** - Batch test runner
   - Runs all non-program tests from tests_all.txt
   - Skips program/multi-line tests
   - Usage: `./run_tests_fast.sh`

4. **`run_tests.py`** - Python test runner (advanced)
   - Full-featured test runner
   - Can handle multi-line outputs
   - Error detection
   - Usage: `./run_tests.py`

5. **`run_test_suite.sh`** - Original comprehensive runner
   - Rebuilds tracer for each test (slow)
   - Usage: `./run_test_suite.sh`

## Test Coverage

### ✅ Currently Tested

- **Arithmetic**: +, -, *, /, precedence
- **Parentheses**: All nesting levels, complex expressions
- **Functions**: INT, ABS, SGN, SQR
- **Comparisons**: <, >, =, <=, >=, <>
- **Negative numbers**: Unary minus, negation
- **Decimals**: Floating point operations
- **Variables**: Assignment, expressions
- **Complex expressions**: Mixed operators and precedence

### ⚠️ Partially Tested

- **Programs**: Basic programs work, complex programs need more testing
- **Loops**: FOR/NEXT basic tests exist
- **Arrays**: DIM and subscript tests exist
- **Control flow**: GOTO, IF/THEN, GOSUB/RETURN tests exist

### ❌ Not Yet Tested

- **Exponentiation**: ^ operator (tests defined but not run)
- **Scientific notation**: 1.5E2 format
- **RND function**: Random numbers
- **TAB, CHR functions**: Output formatting
- **String input**: INPUT A$
- **Error recovery**: Division by zero, stack overflow
- **Edge cases**: Very large/small numbers, overflow
- **STEP in FOR loops**: Negative and fractional steps
- **Nested loops**: Deep nesting
- **Nested GOSUB**: Multiple levels
- **UDF function**: User-defined functions

## Test Results

After running `quick_test.sh`, you should see:

```
========================================
SCELBAL Quick Test Suite
========================================

Testing: Basic Arithmetic
✓ PRINT 5
✓ PRINT 2+3
✓ PRINT 2*3
...

Testing: Parentheses (The Main Fix)
✓ PRINT (5)
✓ PRINT((5))
✓ PRINT (2)*(3)
✓ PRINT (2+3)*4
...

========================================
Results
========================================
Passed: 45 / 45
Failed: 0 / 45
Success Rate: 100%

✓ All tests passed!
```

## Adding New Tests

To add tests to `tests_all.txt`:

```text
; Comment describing test
COMMAND
; EXPECT: expected_output
; EXPECT: second_line_output (for multi-line)
; ERROR: XX (for error tests - two letter error code)
```

Example:
```text
; Test multiplication
PRINT 2*3
; EXPECT: 6.0

; Test division by zero
PRINT 1/0
; ERROR: OV
```

## Testing Specific Features

### Test Parentheses Only
```bash
./test_print.sh
```

### Test Arithmetic and Expressions
```bash
grep -A1 "PRINT.*[+\-*/]" tests_all.txt | grep -v "^;" > /tmp/arith_tests.txt
```

### Test Functions Only
```bash
grep -A1 "PRINT.*INT\|ABS\|SGN\|SQR" tests_all.txt > /tmp/func_tests.txt
```

## CI/CD Integration

For continuous integration, use:
```bash
./quick_test.sh && echo "SCELBAL tests passed" || exit 1
```

## Debugging Test Failures

If a test fails:

1. **Run the single test manually:**
   ```bash
   echo "PRINT (2)*(3)" > /tmp/test.txt
   # Then inspect output
   ```

2. **Check the tracer output:**
   ```bash
   ./trace_scelbal scelbal.com 2>&1 | less
   ```

3. **Enable detailed tracing:**
   Edit `trace_scelbal.cc` and enable more printf statements

4. **Check for recent code changes:**
   ```bash
   git diff scelbal.mac
   ```

## Known Issues

1. **Slow test execution**: Each test requires recompiling the tracer
   - Solution: Use `quick_test.sh` for fast feedback
   - Future: Modify tracer to accept stdin

2. **Program tests not automated**: Multi-line programs need special handling
   - Solution: Programs in tests_all.txt defined but need runner support

3. **Timeout on infinite loops**: Some bugs cause hangs
   - Solution: Tests use `timeout 2` to prevent hanging

## Test Maintenance

- **After fixing bugs**: Add regression test to tests_all.txt
- **Before commits**: Run `./quick_test.sh`
- **Weekly**: Run full test suite (when implemented)
- **Release**: Run all tests and verify 100% pass rate

## Architecture

```
tests_all.txt           # Master test database (400+ tests)
     ↓
quick_test.sh          # Fast runner (45 tests, recommended)
     ↓
trace_scelbal.cc       # Tracer (modified for each test)
     ↓
scelbal.com            # SCELBAL interpreter
     ↓
Test output            # Parsed and compared
```

## Future Improvements

1. **Batch testing**: Modify tracer to accept multiple commands
2. **Interactive testing**: Use expect/pexpect for program tests
3. **Performance tests**: Measure execution time
4. **Coverage analysis**: Track which code paths are tested
5. **Fuzzing**: Random input generation
6. **Comparative testing**: Compare with original 8008 SCELBAL

---

**Last Updated**: 2025-12-05
**Test Suite Version**: 1.0
**SCELBAL Version**: 8080 port with FA stack fixes
