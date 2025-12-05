#!/bin/bash
# Verify test suite setup

echo "SCELBAL Test Suite Verification"
echo "================================"
echo

errors=0

check_file() {
    if [ -f "$1" ]; then
        echo "✓ $1"
    else
        echo "✗ $1 - NOT FOUND"
        ((errors++))
    fi
}

check_executable() {
    if [ -x "$1" ]; then
        echo "✓ $1 (executable)"
    else
        echo "✗ $1 - NOT EXECUTABLE"
        ((errors++))
    fi
}

echo "Test Data Files:"
check_file "tests_all.txt"
check_file "test_suite.txt"
check_file "test_clean.txt"
check_file "test_print.txt"
echo

echo "Test Runners:"
check_executable "quick_test.sh"
check_executable "test_print.sh"
check_executable "run_tests_fast.sh"
check_executable "run_tests.py"
check_executable "run_test_suite.sh"
echo

echo "SCELBAL Files:"
check_file "scelbal.com"
check_file "scelbal.mac"
check_file "scelbal.sym"
check_file "trace_scelbal.cc"
echo

echo "Documentation:"
check_file "TEST_README.md"
echo

# Count tests
echo "Statistics:"
if [ -f "tests_all.txt" ]; then
    test_count=$(grep -c "^PRINT\|^LET\|^DIM\|^FOR\|^SCR\|^RUN\|^LIST" tests_all.txt)
    expect_count=$(grep -c "EXPECT:" tests_all.txt)
    echo "  Commands in tests_all.txt: $test_count"
    echo "  Expected outputs: $expect_count"
fi

if [ -f "tests_complete.txt" ]; then
    complete_count=$(grep -c "^PRINT\|^LET\|^DIM\|^FOR\|^SCR\|^RUN\|^LIST\|^A=" tests_complete.txt)
    complete_expect=$(grep -c "EXPECT:" tests_complete.txt)
    echo "  Commands in tests_complete.txt: $complete_count"
    echo "  Expected outputs: $complete_expect"
    echo "  Test sections: 46"
fi
echo

if [ $errors -eq 0 ]; then
    echo "✓ All files present and ready"
    echo
    echo "Quick Start:"
    echo "  ./quick_test.sh      # Run fast test suite (45 tests, ~3 min)"
    echo "  ./test_print.sh      # Run parentheses tests (9 tests, ~1 min)"
    echo "  ./run_all_tests.sh   # Run COMPLETE test suite (600+ tests, ~60 min)"
    echo
    echo "Documentation:"
    echo "  TEST_README.md               # Getting started guide"
    echo "  COMPLETE_TEST_COVERAGE.md    # Full coverage analysis"
    echo "  TESTING_SUMMARY.md           # Overview and examples"
    exit 0
else
    echo "✗ $errors file(s) missing or not executable"
    exit 1
fi
