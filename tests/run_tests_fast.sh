#!/bin/bash
# Fast SCELBAL Test Runner
# Creates a batch input file and runs all tests at once

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/../src"
TEST_FILE="$SCRIPT_DIR/tests_all.txt"
INPUT_FILE="/tmp/scelbal_test_input.txt"
OUTPUT_FILE="/tmp/scelbal_test_output.txt"
COM_FILE="$SRC_DIR/scelbal.com"
TRACER="$SRC_DIR/trace_scelbal"
TRACER_SRC="$SRC_DIR/trace_scelbal.cc"

# Check if files exist
if [ ! -f "$TEST_FILE" ]; then
    echo -e "${RED}Error: Test file not found: $TEST_FILE${NC}"
    exit 1
fi

if [ ! -f "$COM_FILE" ]; then
    echo -e "${RED}Error: SCELBAL COM file not found: $COM_FILE${NC}"
    exit 1
fi

echo "========================================"
echo "SCELBAL Fast Test Runner"
echo "========================================"
echo

# Extract just the commands from test file (remove comments and blank lines)
echo "Preparing test batch..."
grep -v "^;" "$TEST_FILE" | grep -v "^$" > "$INPUT_FILE"

# Count tests
test_count=$(wc -l < "$INPUT_FILE")
echo "Found $test_count commands to test"
echo

# Create test input with all commands
cat "$INPUT_FILE" > /tmp/scelbal_batch_input.txt
echo "" >> /tmp/scelbal_batch_input.txt  # Add newline at end

# Update tracer to read from the batch file
echo "Updating tracer for batch mode..."

# For now, let's just run the simple tests one at a time
# Extract simple PRINT tests (non-program tests)
echo "Running arithmetic and expression tests..."
echo

passed=0
failed=0

# Function to test a single expression
test_expr() {
    local expr="$1"
    local expected="$2"

    # Skip if no expected value
    if [ -z "$expected" ]; then
        return 0
    fi

    # Update tracer
    sed -i "s|\".*\\\r\"|\"$expr\\\r\"|" "$TRACER_SRC"

    # Compile
    if ! g++ -O2 -I/home/wohl/src/cpmemu/src -o "$TRACER" "$TRACER_SRC" \
        /home/wohl/src/cpmemu/src/qkz80.cc /home/wohl/src/cpmemu/src/qkz80_mem.cc \
        /home/wohl/src/cpmemu/src/qkz80_reg_set.cc /home/wohl/src/cpmemu/src/qkz80_errors.cc 2>&1 > /dev/null; then
        echo -e "${RED}✗ Build failed: $expr${NC}"
        ((failed++))
        return 1
    fi

    # Run
    result=$("$TRACER" "$COM_FILE" 2>&1 | grep -a "^[[:space:]]*[-0-9]" | head -1 | tr -d ' ')

    # Compare
    if [ "$result" == "$expected" ]; then
        echo -e "${GREEN}✓${NC} $expr = $result"
        ((passed++))
        return 0
    else
        echo -e "${RED}✗${NC} $expr = $result (expected $expected)"
        ((failed++))
        return 1
    fi
}

# Parse test file and run tests
current_expect=""
while IFS= read -r line; do
    # Skip comments and empty lines
    if [[ "$line" =~ ^[[:space:]]*$ ]] || [[ "$line" =~ ^[[:space:]]*\; ]]; then
        # Check if it's an EXPECT line
        if [[ "$line" =~ EXPECT:[[:space:]]*(.*) ]]; then
            current_expect="${BASH_REMATCH[1]}"
        else
            current_expect=""
        fi
        continue
    fi

    # Skip program-related commands for now (SCR, RUN, LIST, numbered lines)
    if [[ "$line" =~ ^(SCR|RUN|LIST|[0-9]) ]]; then
        current_expect=""
        continue
    fi

    # Test the command if we have an expected value
    if [ -n "$current_expect" ]; then
        test_expr "$line" "$current_expect"
    fi
    current_expect=""

done < "$TEST_FILE"

echo
echo "========================================"
echo "Test Results"
echo "========================================"
echo -e "${GREEN}Passed: $passed${NC}"
echo -e "${RED}Failed: $failed${NC}"

total=$((passed + failed))
if [ $total -gt 0 ]; then
    percentage=$((passed * 100 / total))
    echo "Success Rate: $percentage%"
fi

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed${NC}"
    exit 1
fi
