#!/bin/bash
# Comprehensive SCELBAL Test Suite Runner
# Tests all language features from test_suite.txt

set -e

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass_count=0
fail_count=0
skip_count=0

test_expr() {
    local expr="$1"
    local expected="$2"
    local category="$3"

    # Update input in tracer
    sed -i "s|\".*\\\r\"|\"$expr\\\r\"|" trace_scelbal.cc

    # Rebuild quietly
    if ! g++ -O2 -I/home/wohl/src/cpmemu/src -o trace_scelbal trace_scelbal.cc \
        /home/wohl/src/cpmemu/src/qkz80.cc /home/wohl/src/cpmemu/src/qkz80_mem.cc \
        /home/wohl/src/cpmemu/src/qkz80_reg_set.cc /home/wohl/src/cpmemu/src/qkz80_errors.cc 2>&1 > /dev/null; then
        echo -e "${RED}✗ Build failed for: $expr${NC}"
        return 1
    fi

    # Run and get output
    result=$(./trace_scelbal scelbal.com 2>&1 | grep -a "^[[:space:]]*[-0-9]" | head -1 | tr -d ' ')

    if [ "$result" == "$expected" ]; then
        echo -e "${GREEN}✓${NC} [$category] $expr = $result"
        ((pass_count++))
        return 0
    else
        echo -e "${RED}✗${NC} [$category] $expr = $result (expected $expected)"
        ((fail_count++))
        return 1
    fi
}

echo "========================================"
echo "SCELBAL Comprehensive Test Suite"
echo "========================================"
echo

# ========== BASIC ARITHMETIC ==========
echo -e "${YELLOW}Testing: Basic Arithmetic${NC}"
test_expr "PRINT 4" "4.0" "ARITH"
test_expr "PRINT 8/2" "4.0" "ARITH"
test_expr "PRINT 6/2" "3.0" "ARITH"
test_expr "PRINT 10/5" "2.0" "ARITH"
test_expr "PRINT 2*3" "6.0" "ARITH"
test_expr "PRINT 5+7" "12.0" "ARITH"
test_expr "PRINT 10-3" "7.0" "ARITH"
test_expr "PRINT 1+2*3" "7.0" "ARITH"  # Precedence test
echo

# ========== PARENTHESES ==========
echo -e "${YELLOW}Testing: Parentheses${NC}"
test_expr "PRINT (5)" "5.0" "PAREN"
test_expr "PRINT((5))" "5.0" "PAREN"
test_expr "PRINT (2)*(3)" "6.0" "PAREN"
test_expr "PRINT (2+3)*4" "20.0" "PAREN"
test_expr "PRINT 2*(3+4)" "14.0" "PAREN"
test_expr "PRINT (2+3)*(4+5)" "45.0" "PAREN"
echo

# ========== NEGATIVE NUMBERS ==========
echo -e "${YELLOW}Testing: Negative Numbers${NC}"
test_expr "PRINT -5" "-5.0" "NEG"
test_expr "PRINT 3-7" "-4.0" "NEG"
test_expr "PRINT -2*3" "-6.0" "NEG"
test_expr "PRINT (-2)*3" "-6.0" "NEG"
echo

# ========== DECIMAL NUMBERS ==========
echo -e "${YELLOW}Testing: Decimal Numbers${NC}"
test_expr "PRINT 3.14159" "3.14159" "DEC"
test_expr "PRINT 0.5" "0.5" "DEC"
test_expr "PRINT 1.5*2" "3.0" "DEC"
echo

# ========== BUILT-IN FUNCTIONS ==========
echo -e "${YELLOW}Testing: Built-in Functions${NC}"
test_expr "PRINT INT(3.7)" "3.0" "FUNC"
test_expr "PRINT INT(-3.7)" "-4.0" "FUNC"
test_expr "PRINT ABS(-5)" "5.0" "FUNC"
test_expr "PRINT ABS(5)" "5.0" "FUNC"
test_expr "PRINT SGN(-5)" "-1.0" "FUNC"
test_expr "PRINT SGN(5)" "1.0" "FUNC"
test_expr "PRINT SGN(0)" "0.0" "FUNC"
test_expr "PRINT SQR(4)" "2.0" "FUNC"
test_expr "PRINT SQR(9)" "3.0" "FUNC"
test_expr "PRINT SQR(16)" "4.0" "FUNC"
echo

# ========== FUNCTIONS WITH PARENTHESES ==========
echo -e "${YELLOW}Testing: Functions with Parentheses${NC}"
test_expr "PRINT INT((5))" "5.0" "FUNC+PAREN"
test_expr "PRINT ABS((-5))" "5.0" "FUNC+PAREN"
test_expr "PRINT SQR((4))" "2.0" "FUNC+PAREN"
test_expr "PRINT INT(2+3)" "5.0" "FUNC+EXPR"
test_expr "PRINT ABS(-2-3)" "5.0" "FUNC+EXPR"
echo

# ========== COMPARISON OPERATORS ==========
echo -e "${YELLOW}Testing: Comparison Operators${NC}"
test_expr "PRINT 5>3" "1.0" "CMP"
test_expr "PRINT 3>5" "0.0" "CMP"
test_expr "PRINT 5=5" "1.0" "CMP"
test_expr "PRINT 5=3" "0.0" "CMP"
test_expr "PRINT 3<5" "1.0" "CMP"
test_expr "PRINT 5<3" "0.0" "CMP"
echo

# ========== COMPLEX EXPRESSIONS ==========
echo -e "${YELLOW}Testing: Complex Expressions${NC}"
test_expr "PRINT 2+3*4" "14.0" "COMPLEX"
test_expr "PRINT (2+3)*4" "20.0" "COMPLEX"
test_expr "PRINT 10/2+3" "8.0" "COMPLEX"
test_expr "PRINT 10/(2+3)" "2.0" "COMPLEX"
test_expr "PRINT 2*3+4*5" "26.0" "COMPLEX"
test_expr "PRINT (2+3)*(4+5)" "45.0" "COMPLEX"
echo

echo "========================================"
echo "Test Results"
echo "========================================"
echo -e "${GREEN}Passed: $pass_count${NC}"
echo -e "${RED}Failed: $fail_count${NC}"

total=$((pass_count + fail_count))
if [ $total -gt 0 ]; then
    percentage=$((pass_count * 100 / total))
    echo "Success Rate: $percentage%"
fi

if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed${NC}"
    exit 1
fi
