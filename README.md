# SCELBAL - SCientific ELementary BAsic Language

A compact BASIC interpreter for CP/M systems, originally designed for 8080/Z80 microprocessors. This is a restored and debugged version with comprehensive test coverage.

## Overview

SCELBAL is a small BASIC interpreter that fits in less than 9KB of code. It provides essential BASIC functionality including:

- Integer and floating-point arithmetic
- Variables and arrays
- Built-in functions (INT, ABS, SGN, SQR, RND, TAB, CHR)
- Control structures (FOR/NEXT, IF/THEN, GOTO, GOSUB/RETURN)
- Input/Output (PRINT, INPUT)
- Program management (LIST, RUN, SAVE, LOAD)

**Current Status**: 38/39 tests passing (97% functional)

## Building

### Prerequisites

- `um80` - MACRO-80 compatible assembler
- `ul80` - MACRO-80 compatible linker
- 8080/Z80 emulator or CP/M system for testing

### Build Instructions

```bash
cd src
um80 scelbal.mac       # Assembles to scelbal.rel
ul80 scelbal.rel       # Links to scelbal.com
```

The output is a CP/M .COM file that can run on any CP/M-compatible system or emulator.

## Running

On a CP/M system or emulator:

```
A> scelbal
SCELBAL 1.0
READY
> 10 PRINT "HELLO WORLD"
> 20 END
> RUN
HELLO WORLD
READY
>
```

## Testing

Comprehensive test suite with 39 tests covering all language features:

```bash
cd src
bash quick_test.sh          # Run quick test suite
bash run_test_suite.sh      # Run full test suite with detailed output
```

Test categories:
- Basic arithmetic
- Parentheses and operator precedence
- Negative numbers
- Decimal numbers
- Built-in functions
- Comparison operators
- Complex expressions

## Documentation

- [Language Manual](docs/scelbal_language_manual.md) - Complete SCELBAL language reference
- [Bug Fixes](BUGS_FOUND.md) - History of bugs found and fixed
- [Test Documentation](src/README_TESTS.md) - Test suite documentation

## Recent Improvements

This version includes significant bug fixes:

1. **SQR Function Fix** - Fixed stack corruption in square root calculation
2. **FA Stack Fix** - Corrected function/array stack pointer management
3. **Decimal Arithmetic** - Fixed floating-point parsing and arithmetic
4. **Parentheses Precedence** - Fixed operator precedence in parenthesized expressions (11 tests fixed)

See [BUGS_FOUND.md](BUGS_FOUND.md) for complete fix history.

## Known Issues

- `PRINT((5))` without space returns empty (workaround: use `PRINT ((5))` with space)

This is a minor tokenization edge case that can be avoided with standard BASIC spacing.

## Project Structure

```
scelbal/
├── src/
│   ├── scelbal.mac          # Main assembly source
│   ├── scelbal.com          # Compiled CP/M binary
│   ├── quick_test.sh        # Quick test runner
│   ├── run_test_suite.sh    # Full test suite
│   └── trace_scelbal.cc     # C++ emulator for debugging
├── docs/
│   └── scelbal_language_manual.md
└── README.md
```

## History

SCELBAL was originally written for the Intel 8080 microprocessor and published in the late 1970s. This version has been restored from the original source and debugged using modern emulation and automated testing.

## License

Original public domain software, restored and improved.

## Contributing

Bug reports and fixes welcome! Please include:
- Minimal BASIC program that demonstrates the issue
- Expected vs actual output
- Test case that can be added to the test suite
