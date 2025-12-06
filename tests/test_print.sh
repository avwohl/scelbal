#!/bin/bash
# Test script for PRINT expressions

cd "$(dirname "$0")"

# Paths to src directory
SRC_DIR="../src"
TRACER_SRC="$SRC_DIR/trace_scelbal.cc"
TRACER_BIN="$SRC_DIR/trace_scelbal"
COM_FILE="$SRC_DIR/scelbal.com"

test_expr() {
    expr="$1"
    expected="$2"

    # Update input in tracer
    sed -i "s|\"PRINT.*\\\r\"|\"$expr\\\r\"|" "$TRACER_SRC"

    # Rebuild
    g++ -O2 -I/home/wohl/src/cpmemu/src -o "$TRACER_BIN" "$TRACER_SRC" \
        /home/wohl/src/cpmemu/src/qkz80.cc /home/wohl/src/cpmemu/src/qkz80_mem.cc \
        /home/wohl/src/cpmemu/src/qkz80_reg_set.cc /home/wohl/src/cpmemu/src/qkz80_errors.cc 2>&1 > /dev/null

    # Run and get output
    result=$("$TRACER_BIN" "$COM_FILE" 2>&1 | grep -a "^[[:space:]]*[0-9]" | head -1 | tr -d ' ')

    if [ "$result" == "$expected" ]; then
        echo "✓ $expr = $result"
    else
        echo "✗ $expr = $result (expected $expected)"
    fi
}

echo "Testing PRINT expressions:"
test_expr "PRINT 5" "5.0"
test_expr "PRINT (5)" "5.0"
test_expr "PRINT((5))" "5.0"
test_expr "PRINT 2*3" "6.0"
test_expr "PRINT (2)*(3)" "6.0"
test_expr "PRINT (2+3)*4" "20.0"
test_expr "PRINT 2*(3+4)" "14.0"
test_expr "PRINT 2+3*4" "14.0"
test_expr "PRINT (2+3)*(4+5)" "45.0"
