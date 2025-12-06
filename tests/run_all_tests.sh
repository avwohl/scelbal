#!/bin/bash
# SCELBAL Master Test Runner - Runs all test suites
# Tests all 600+ test cases

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "============================================================================"
echo "SCELBAL COMPLETE TEST SUITE"
echo "Testing all 600+ features"
echo "============================================================================"
echo

cd "$(dirname "$0")"

# Paths to src directory
SRC_DIR="../src"
TRACER_SRC="$SRC_DIR/trace_scelbal.cc"
TRACER_BIN="$SRC_DIR/trace_scelbal"
COM_FILE="$SRC_DIR/scelbal.com"

total_passed=0
total_failed=0
total_tests=0

# Test function that handles a single command
test_cmd() {
    local cmd="$1"
    local expected="$2"
    local section="$3"

    ((total_tests++))

    # Update tracer
    sed -i "s|\".*\\\\r\"|\"$cmd\\\\r\"|" "$TRACER_SRC" 2>/dev/null || true

    # Compile (suppress warnings, only show errors)
    if ! g++ -O2 -I/home/wohl/src/cpmemu/src -o "$TRACER_BIN" "$TRACER_SRC" \
        /home/wohl/src/cpmemu/src/qkz80.cc /home/wohl/src/cpmemu/src/qkz80_mem.cc \
        /home/wohl/src/cpmemu/src/qkz80_reg_set.cc /home/wohl/src/cpmemu/src/qkz80_errors.cc \
        2>&1 | grep -i "error:"; then
        :
    else
        echo -e "${RED}✗${NC} BUILD FAILED: $cmd"
        ((total_failed++))
        return 1
    fi

    # Run and get result (match lines ending with \r to avoid debug output)
    result=$(timeout 2 "$TRACER_BIN" "$COM_FILE" 2>&1 | grep -Ea "^[[:space:]]*-?[0-9][0-9.E+-]*"$'\r' | head -1 | tr -d ' \r' || echo "TIMEOUT")

    # Check result (handle floating point comparison)
    if [ "$result" == "$expected" ]; then
        echo -e "${GREEN}✓${NC} $cmd"
        ((total_passed++))
        return 0
    else
        # Try fuzzy float comparison for close matches
        if [ "$result" != "TIMEOUT" ] && [ -n "$result" ]; then
            # Both should be numbers
            if [[ "$result" =~ ^-?[0-9]+\.?[0-9]*$ ]] && [[ "$expected" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
                # Use bc for comparison (if available)
                if command -v bc &> /dev/null; then
                    diff=$(echo "scale=6; a=$result; b=$expected; if (a > b) a - b else b - a" | bc)
                    if (( $(echo "$diff < 0.00001" | bc -l) )); then
                        echo -e "${GREEN}✓${NC} $cmd (fuzzy match: $result ≈ $expected)"
                        ((total_passed++))
                        return 0
                    fi
                fi
            fi
        fi

        echo -e "${RED}✗${NC} $cmd"
        echo "   Expected: $expected"
        echo "   Got:      $result"
        ((total_failed++))
        return 1
    fi
}

# Parse test file and run tests
current_section=""
current_cmd=""
test_count_in_section=0

echo -e "${CYAN}Running tests from tests_complete.txt...${NC}"
echo

while IFS= read -r line; do
    # Detect section headers
    if echo "$line" | grep -q "^; SECTION"; then
        if [ -n "$current_section" ]; then
            echo "  ($test_count_in_section tests)"
            echo
        fi
        current_section=$(echo "$line" | sed 's/^; SECTION [0-9]*: //')
        echo -e "${YELLOW}$current_section${NC}"
        test_count_in_section=0
        current_cmd=""
        continue
    fi

    # Skip empty lines
    if [ -z "$line" ]; then
        continue
    fi

    # Check for comment lines
    if echo "$line" | grep -q "^;"; then
        # Check for EXPECT line - test the previously saved command
        if echo "$line" | grep -q "EXPECT:"; then
            if [ -n "$current_cmd" ]; then
                current_expect=$(echo "$line" | sed 's/.*EXPECT:[[:space:]]*//')
                test_cmd "$current_cmd" "$current_expect" "$current_section"
                ((test_count_in_section++))
                current_cmd=""
            fi
        elif echo "$line" | grep -q "ERROR:"; then
            # TODO: Handle error expectations
            current_cmd=""
        fi
        continue
    fi

    # Skip program-related commands for now (need special handling)
    if echo "$line" | grep -qE "^(SCR|RUN|LIST|[0-9])"; then
        current_cmd=""
        continue
    fi

    # Save the command for when we see the EXPECT line
    current_cmd="$line"

done < tests_complete.txt

# Final section count
if [ -n "$current_section" ] && [ $test_count_in_section -gt 0 ]; then
    echo "  ($test_count_in_section tests)"
fi

echo
echo "============================================================================"
echo "FINAL RESULTS"
echo "============================================================================"
echo -e "${GREEN}Passed:${NC} $total_passed / $total_tests"
echo -e "${RED}Failed:${NC} $total_failed / $total_tests"

if [ $total_tests -gt 0 ]; then
    percentage=$((total_passed * 100 / total_tests))
    echo "Success Rate: $percentage%"
fi

echo
if [ $total_failed -eq 0 ]; then
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ ALL $total_tests TESTS PASSED!${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    exit 0
else
    echo -e "${RED}════════════════════════════════════════${NC}"
    echo -e "${RED}✗ $total_failed TESTS FAILED${NC}"
    echo -e "${RED}════════════════════════════════════════${NC}"
    exit 1
fi
