#!/usr/bin/env python3
"""
SCELBAL Test Runner
Runs comprehensive tests from tests_all.txt
"""

import subprocess
import re
import sys
from pathlib import Path
from typing import List, Tuple, Optional

# ANSI color codes
GREEN = '\033[0;32m'
RED = '\033[0;31m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'  # No Color

class Test:
    def __init__(self, command: str, expects: List[str], error: Optional[str] = None):
        self.command = command
        self.expects = expects
        self.error = error

    def __repr__(self):
        return f"Test({self.command!r}, expects={self.expects}, error={self.error})"

def parse_test_file(filename: str) -> List[Test]:
    """Parse the test file and extract test cases"""
    tests = []
    current_command = None
    current_expects = []
    current_error = None

    with open(filename, 'r') as f:
        for line in f:
            line = line.rstrip()

            # Skip empty lines and pure comments
            if not line or line.startswith(';'):
                continue

            # Check for EXPECT comment
            if line.startswith('; EXPECT:'):
                expected = line.split(':', 1)[1].strip()
                current_expects.append(expected)

            # Check for ERROR comment
            elif line.startswith('; ERROR:'):
                current_error = line.split(':', 1)[1].strip()

            # Otherwise it's a command
            else:
                # Save previous test if any
                if current_command is not None:
                    tests.append(Test(current_command, current_expects, current_error))

                # Start new test
                current_command = line
                current_expects = []
                current_error = None

    # Don't forget the last test
    if current_command is not None:
        tests.append(Test(current_command, current_expects, current_error))

    return tests

def run_scelbal_command(command: str, tracer_path: str, com_path: str) -> Tuple[str, str, int]:
    """Run a single SCELBAL command using the tracer"""
    # Update the tracer source with new command
    with open(tracer_path + '.cc', 'r') as f:
        tracer_src = f.read()

    # Replace the input buffer line
    pattern = r'"[^"]*\\r"'
    replacement = f'"{command}\\r"'
    new_src = re.sub(pattern, replacement, tracer_src)

    with open(tracer_path + '.cc', 'w') as f:
        f.write(new_src)

    # Compile the tracer
    compile_cmd = [
        'g++', '-O2', '-I/home/wohl/src/cpmemu/src',
        '-o', tracer_path,
        tracer_path + '.cc',
        '/home/wohl/src/cpmemu/src/qkz80.cc',
        '/home/wohl/src/cpmemu/src/qkz80_mem.cc',
        '/home/wohl/src/cpmemu/src/qkz80_reg_set.cc',
        '/home/wohl/src/cpmemu/src/qkz80_errors.cc'
    ]

    result = subprocess.run(compile_cmd, capture_output=True, text=True)
    if result.returncode != 0:
        return "", result.stderr, result.returncode

    # Run the tracer
    result = subprocess.run([tracer_path, com_path], capture_output=True, text=True, timeout=5)
    return result.stdout, result.stderr, result.returncode

def extract_output(stdout: str, stderr: str) -> List[str]:
    """Extract numeric/text outputs from SCELBAL output"""
    outputs = []

    # Look for numeric outputs (lines that start with optional whitespace then a digit or minus)
    for line in stdout.split('\n'):
        line = line.strip()
        # Match floating point numbers (including negative)
        if re.match(r'^-?\d+\.?\d*$', line) or re.match(r'^-?\d*\.\d+$', line):
            outputs.append(line)
        # Match error codes (two letters)
        elif re.match(r'^[A-Z]{2}$', line):
            outputs.append(line)
        # Match LIST output (line numbers)
        elif re.match(r'^\d+\s+', line):
            outputs.append(line)

    return outputs

def compare_values(expected: str, actual: str, tolerance: float = 1e-5) -> bool:
    """Compare two values with tolerance for floating point"""
    # If both are error codes (letters)
    if expected.isalpha() and actual.isalpha():
        return expected == actual

    # Try numeric comparison with tolerance
    try:
        exp_val = float(expected)
        act_val = float(actual)
        return abs(exp_val - act_val) < tolerance
    except ValueError:
        # String comparison
        return expected == actual

def run_test(test: Test, tracer_path: str, com_path: str) -> bool:
    """Run a single test and return True if it passes"""
    try:
        stdout, stderr, returncode = run_scelbal_command(test.command, tracer_path, com_path)

        # Extract outputs
        outputs = extract_output(stdout, stderr)

        # Check for expected error
        if test.error:
            if test.error in outputs or test.error in stdout:
                return True
            else:
                print(f"{RED}✗{NC} {test.command}")
                print(f"  Expected error: {test.error}")
                print(f"  Got: {outputs}")
                return False

        # Check expected outputs
        if len(outputs) < len(test.expects):
            print(f"{RED}✗{NC} {test.command}")
            print(f"  Expected {len(test.expects)} outputs, got {len(outputs)}")
            print(f"  Expected: {test.expects}")
            print(f"  Got: {outputs}")
            return False

        # Compare each expected output
        for i, expected in enumerate(test.expects):
            if i >= len(outputs):
                print(f"{RED}✗{NC} {test.command}")
                print(f"  Missing output #{i+1}: {expected}")
                return False

            if not compare_values(expected, outputs[i]):
                print(f"{RED}✗{NC} {test.command}")
                print(f"  Output #{i+1} mismatch:")
                print(f"    Expected: {expected}")
                print(f"    Got: {outputs[i]}")
                return False

        # All checks passed
        print(f"{GREEN}✓{NC} {test.command[:60]}")
        return True

    except subprocess.TimeoutExpired:
        print(f"{RED}✗{NC} {test.command} (TIMEOUT)")
        return False
    except Exception as e:
        print(f"{RED}✗{NC} {test.command} (ERROR: {e})")
        return False

def main():
    script_dir = Path(__file__).parent
    test_file = script_dir / 'tests_all.txt'
    tracer_path = str(script_dir / 'trace_scelbal')
    com_path = str(script_dir / 'scelbal.com')

    print("=" * 60)
    print("SCELBAL Comprehensive Test Suite")
    print("=" * 60)
    print()

    # Parse tests
    print(f"Loading tests from {test_file}...")
    tests = parse_test_file(str(test_file))
    print(f"Found {len(tests)} tests")
    print()

    # Run tests
    passed = 0
    failed = 0

    current_section = ""
    for test in tests:
        # Detect section changes (commands that start programs)
        if test.command.startswith("SCR"):
            print()
            current_section = "Program Tests"

        # Run the test
        if run_test(test, tracer_path, com_path):
            passed += 1
        else:
            failed += 1

    # Summary
    print()
    print("=" * 60)
    print("Test Results")
    print("=" * 60)
    print(f"{GREEN}Passed: {passed}{NC}")
    print(f"{RED}Failed: {failed}{NC}")

    total = passed + failed
    if total > 0:
        percentage = (passed * 100) // total
        print(f"Success Rate: {percentage}%")

    if failed == 0:
        print(f"{GREEN}All tests passed!{NC}")
        return 0
    else:
        print(f"{RED}Some tests failed{NC}")
        return 1

if __name__ == '__main__':
    sys.exit(main())
