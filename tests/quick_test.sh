#!/bin/bash
# Quick SCELBAL Test - Tests core functionality
# Runs key tests to verify the fixes work

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "SCELBAL Quick Test Suite"
echo "========================================"
echo

cd "$(dirname "$0")"

# Paths to src directory
SRC_DIR="../src"
TRACER_SRC="$SRC_DIR/trace_scelbal.cc"
TRACER_BIN="$SRC_DIR/trace_scelbal"
COM_FILE="$SRC_DIR/scelbal.com"

# Test counter
passed=0
failed=0
tests=0

test_cmd() {
    local cmd="$1"
    local expected="$2"
    ((tests++))

    # Update tracer
    sed -i "s|\".*\\\\r\"|\"$cmd\\\\r\"|" "$TRACER_SRC" 2>/dev/null || true

    # Compile (suppress warnings)
    if ! g++ -O2 -I/home/wohl/src/cpmemu/src -o "$TRACER_BIN" "$TRACER_SRC" \
        /home/wohl/src/cpmemu/src/qkz80.cc /home/wohl/src/cpmemu/src/qkz80_mem.cc \
        /home/wohl/src/cpmemu/src/qkz80_reg_set.cc /home/wohl/src/cpmemu/src/qkz80_errors.cc 2>&1 | grep -i "error:"; then
        :
    else
        echo -e "${RED}✗ Build failed: $cmd${NC}"
        ((failed++))
        return 1
    fi

    # Run and get result from Final output section
    result=$(timeout 2 "$TRACER_BIN" "$COM_FILE" 2>&1 | grep -a -A 10 "Final output:" | grep -ao "\-\?[0-9][0-9.E+-]*" | head -1 || echo "TIMEOUT")

    # Check result
    if [ "$result" == "$expected" ]; then
        echo -e "${GREEN}✓${NC} $cmd"
        ((passed++))
        return 0
    else
        echo -e "${RED}✗${NC} $cmd (got: $result, expected: $expected)"
        ((failed++))
        return 1
    fi
}

echo -e "${YELLOW}Testing: Basic Arithmetic${NC}"
test_cmd "PRINT 5" "5.0"
test_cmd "PRINT 2+3" "5.0"
test_cmd "PRINT 2*3" "6.0"
test_cmd "PRINT 10/2" "5.0"
test_cmd "PRINT 10-3" "7.0"
echo

echo -e "${YELLOW}Testing: Parentheses (The Main Fix)${NC}"
test_cmd "PRINT (5)" "5.0"
test_cmd "PRINT((5))" "5.0"
test_cmd "PRINT (2)*(3)" "6.0"
test_cmd "PRINT (2+3)*4" "20.0"
test_cmd "PRINT 2*(3+4)" "14.0"
test_cmd "PRINT (2+3)*(4+5)" "45.0"
echo

echo -e "${YELLOW}Testing: Operator Precedence${NC}"
test_cmd "PRINT 2+3*4" "14.0"
test_cmd "PRINT (2+3)*4" "20.0"
test_cmd "PRINT 1+2*3" "7.0"
echo

echo -e "${YELLOW}Testing: Negative Numbers${NC}"
test_cmd "PRINT -5" "-5.0"
test_cmd "PRINT 3-7" "-4.0"
test_cmd "PRINT -2*3" "-6.0"
echo

echo -e "${YELLOW}Testing: Decimal Numbers${NC}"
test_cmd "PRINT 0.5" "0.5000000"
test_cmd "PRINT 1.5*2" "3.0"
test_cmd "PRINT 7/3" "2.333333"
echo

echo -e "${YELLOW}Testing: Functions${NC}"
test_cmd "PRINT INT(3.7)" "3.0"
test_cmd "PRINT ABS(-5)" "5.0"
test_cmd "PRINT SGN(-5)" "-1.0"
test_cmd "PRINT SGN(5)" "1.0"
test_cmd "PRINT SQR(4)" "2.0"
test_cmd "PRINT SQR(9)" "3.0"
echo

echo -e "${YELLOW}Testing: Functions with Parentheses${NC}"
test_cmd "PRINT INT((5))" "5.0"
test_cmd "PRINT ABS((-5))" "5.0"
test_cmd "PRINT SQR((16))" "4.0"
test_cmd "PRINT INT(2+3)" "5.0"
echo

echo -e "${YELLOW}Testing: Comparisons${NC}"
test_cmd "PRINT 5>3" "1.0"
test_cmd "PRINT 3>5" "0"
test_cmd "PRINT 5=5" "1.0"
test_cmd "PRINT 5<3" "0"
test_cmd "PRINT 3<5" "1.0"
echo

echo -e "${YELLOW}Testing: Complex Expressions${NC}"
test_cmd "PRINT 2*3+4*5" "26.0"
test_cmd "PRINT 10/(2+3)" "2.0"
test_cmd "PRINT ((2+3))" "5.0"
test_cmd "PRINT (2*(3+4))" "14.0"
echo

echo "========================================"
echo "Results"
echo "========================================"
echo -e "${GREEN}Passed: $passed / $tests${NC}"
echo -e "${RED}Failed: $failed / $tests${NC}"

if [ $tests -gt 0 ]; then
    percentage=$((passed * 100 / tests))
    echo "Success Rate: $percentage%"
fi

if [ $failed -eq 0 ]; then
    echo
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
