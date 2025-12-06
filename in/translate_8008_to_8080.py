#!/usr/bin/env python3
"""
Translate Intel 8008 assembly source to 8080 mnemonics.

This translator converts 8008 mnemonics used in SCELBAL to standard 8080
mnemonics that can be assembled with um80 or other 8080 assemblers.

Key differences between 8008 and 8080:
- Register numbering is different (A=0 in 8008, A=7 in 8080)
- Mnemonics differ (e.g., LAB -> MOV A,B, CAL -> CALL)
- 8008 uses Lxy for moves, 8080 uses MOV x,y
- Conditional jumps/calls/returns have different naming
- 8008 uses PPP#OOO octal address notation (page#offset)
- 8008 uses \\HB\\ and \\LB\\ for high/low byte extraction

Reference: in/a08_80/08_80_table.txt
"""

import re
import sys
import argparse


def octal_addr_to_hex(page_octal, offset_octal):
    """
    Convert 8008 page#offset octal address to 16-bit hex address.
    8008 has 14-bit address: 6-bit page (0-63) and 8-bit offset (0-255).
    Linear address = page * 256 + offset
    """
    page = int(page_octal, 8)
    offset = int(offset_octal, 8)
    linear = page * 256 + offset
    return f'0{linear:04X}H'


def convert_address_notation(text):
    """
    Convert 8008 octal address notation to hex.
    PPP#OOO -> 0xxxxH (hex)
    """
    # Pattern for page#offset notation
    pattern = r'\b([0-7]+)#([0-7]+)\b'

    def replace_addr(match):
        page = match.group(1)
        offset = match.group(2)
        return octal_addr_to_hex(page, offset)

    return re.sub(pattern, replace_addr, text)


def convert_hb_lb_notation(text):
    r"""
    Convert \HB\ and \LB\ notation to HIGH and LOW.
    \HB\symbol -> HIGH symbol
    \LB\symbol -> LOW symbol
    """
    text = re.sub(r'\\HB\\', 'HIGH ', text)
    text = re.sub(r'\\LB\\', 'LOW ', text)
    return text


def convert_octal_numbers(text):
    """
    Convert standalone octal numbers (used in DATA/DB statements) to hex.
    Only convert 3-digit octal numbers that aren't part of addresses.
    """
    # This is tricky - we need to identify octal constants
    # The source uses plain octal like 000, 100, 377
    # For now, leave as-is and handle in context
    return text


def is_octal_number(s):
    """Check if string is a pure octal number (only digits 0-7)."""
    return bool(re.match(r'^[0-7]+$', s))


def octal_to_hex(s):
    """Convert an octal number string to hex format."""
    try:
        val = int(s, 8)
        if val <= 255:
            return f'0{val:02X}H'
        else:
            return f'0{val:04X}H'
    except ValueError:
        return s


def convert_data_values(operand):
    """
    Convert DATA/DB operand values from octal to hex.
    Handles: numbers, strings, and comma-separated lists.
    Also fixes unterminated strings.
    """
    if not operand:
        return operand

    # Handle string literals - check for unterminated strings
    if operand.startswith('"'):
        # Count quotes - if odd number, string is unterminated
        quote_count = operand.count('"')
        if quote_count % 2 == 1:
            # Unterminated string - add closing quote
            operand = operand + '"'
        return operand
    if operand.startswith("'"):
        quote_count = operand.count("'")
        if quote_count % 2 == 1:
            operand = operand + "'"
        return operand

    # Split by comma, but be careful with strings
    parts = []
    current = ''
    in_string = False
    string_char = None

    for char in operand:
        if char in '"\'':
            if not in_string:
                in_string = True
                string_char = char
            elif char == string_char:
                in_string = False
            current += char
        elif char == ',' and not in_string:
            parts.append(current.strip())
            current = ''
        else:
            current += char

    if current:
        parts.append(current.strip())

    # Convert each part
    converted = []
    for part in parts:
        part = part.strip()
        if not part:
            converted.append(part)
            continue

        # String literal
        if part.startswith('"') or part.startswith("'"):
            converted.append(part)
            continue

        # Pure octal number (all digits 0-7)
        if is_octal_number(part):
            converted.append(octal_to_hex(part))
        else:
            # Expression or other - keep as-is
            converted.append(part)

    return ','.join(converted)


def convert_immediate_value(operand):
    """
    Convert an immediate value operand from octal to hex if applicable.
    Handles single values that may be octal.
    """
    if not operand:
        return operand

    operand = operand.strip()

    # If it looks like a pure octal number, convert it
    if is_octal_number(operand):
        return octal_to_hex(operand)

    # Otherwise keep as-is (could be a symbol, expression, etc.)
    return operand

# 8008 to 8080 mnemonic mappings

# Simple 1:1 instruction replacements (no register operands)
SIMPLE_OPCODES = {
    # CPU control
    'HLT': 'HLT',
    'NOP': 'NOP',

    # Rotates
    'RLC': 'RLC',
    'RRC': 'RRC',
    'RAL': 'RAL',
    'RAR': 'RAR',

    # Unconditional return
    'RET': 'RET',

    # Conditional returns (8008 -> 8080)
    'RFC': 'RNC',   # Return if carry = 0
    'RFZ': 'RNZ',   # Return if result <> 0 (not zero)
    'RFS': 'RP',    # Return if sign = 0 (positive)
    'RFP': 'RPO',   # Return if parity = odd
    'RTC': 'RC',    # Return if carry = 1
    'RTZ': 'RZ',    # Return if result = 0
    'RTS': 'RM',    # Return if sign = 1 (negative)
    'RTP': 'RPE',   # Return if parity = even
    # Alternate forms (without T)
    'RC': 'RC',
    'RZ': 'RZ',
    'RS': 'RM',
    'RP': 'RPE',
}

# Jump instructions (8008 -> 8080, all take 16-bit address)
JUMP_OPCODES = {
    'JMP': 'JMP',
    'JFC': 'JNC',   # Jump if carry = 0
    'JFZ': 'JNZ',   # Jump if result <> 0
    'JFS': 'JP',    # Jump if sign = 0 (positive)
    'JFP': 'JPO',   # Jump if parity = odd
    'JTC': 'JC',    # Jump if carry = 1
    'JTZ': 'JZ',    # Jump if result = 0
    'JTS': 'JM',    # Jump if sign = 1 (negative)
    'JTP': 'JPE',   # Jump if parity = even
    # Alternate forms (without T)
    'JC': 'JC',
    'JZ': 'JZ',
    'JS': 'JM',
    'JP': 'JPE',
}

# Call instructions (8008 -> 8080, all take 16-bit address)
CALL_OPCODES = {
    'CAL': 'CALL',
    'CFC': 'CNC',   # Call if carry = 0
    'CFZ': 'CNZ',   # Call if result <> 0
    'CFS': 'CP',    # Call if sign = 0 (positive)
    'CFP': 'CPO',   # Call if parity = odd
    'CTC': 'CC',    # Call if carry = 1
    'CTZ': 'CZ',    # Call if result = 0
    'CTS': 'CM',    # Call if sign = 1 (negative)
    'CTP': 'CPE',   # Call if parity = even
    # Alternate forms (without T)
    'CC': 'CC',
    'CZ': 'CZ',
    'CS': 'CM',
    'CP': 'CPE',
}

# Immediate instructions (8008 -> 8080, take 8-bit immediate)
IMMEDIATE_OPCODES = {
    'ADI': 'ADI',
    'ACI': 'ACI',
    'SUI': 'SUI',
    'SBI': 'SBI',
    'NDI': 'ANI',   # AND immediate
    'XRI': 'XRI',
    'ORI': 'ORI',
    'CPI': 'CPI',
}

# Load immediate to register: LxI -> MVI x,
LOAD_IMM_OPCODES = {
    'LAI': ('MVI', 'A'),
    'LBI': ('MVI', 'B'),
    'LCI': ('MVI', 'C'),
    'LDI': ('MVI', 'D'),
    'LEI': ('MVI', 'E'),
    'LHI': ('MVI', 'H'),
    'LLI': ('MVI', 'L'),
    'LMI': ('MVI', 'M'),
}

# Register-to-register moves: Lxy -> MOV x,y
# 8008: Lds where d=dest, s=source
# 8080: MOV d,s
MOVE_OPCODES = {}
REGS = ['A', 'B', 'C', 'D', 'E', 'H', 'L', 'M']
for dest in REGS:
    for src in REGS:
        if dest == 'M' and src == 'M':
            # LMM is HLT in 8008
            continue
        mnem_8008 = f'L{dest}{src}'
        MOVE_OPCODES[mnem_8008] = ('MOV', dest, src)

# Arithmetic instructions with register operand
# 8008: ADx, ACx, SUx, SBx, NDx, XRx, ORx, CPx
# 8080: ADD x, ADC x, SUB x, SBB x, ANA x, XRA x, ORA x, CMP x
ARITH_OPCODES = {}
for reg in REGS:
    # ADD
    ARITH_OPCODES[f'AD{reg}'] = ('ADD', reg)
    # ADC (add with carry)
    ARITH_OPCODES[f'AC{reg}'] = ('ADC', reg)
    # SUB
    ARITH_OPCODES[f'SU{reg}'] = ('SUB', reg)
    # SBB (subtract with borrow)
    ARITH_OPCODES[f'SB{reg}'] = ('SBB', reg)
    # AND
    ARITH_OPCODES[f'ND{reg}'] = ('ANA', reg)
    # XOR
    ARITH_OPCODES[f'XR{reg}'] = ('XRA', reg)
    # OR
    ARITH_OPCODES[f'OR{reg}'] = ('ORA', reg)
    # CMP
    ARITH_OPCODES[f'CP{reg}'] = ('CMP', reg)

# Increment/Decrement (8008 has no INA/DCA, A is register 0 which is halt pattern)
# 8008: INx, DCx  -> 8080: INR x, DCR x
INC_DEC_OPCODES = {}
for reg in ['B', 'C', 'D', 'E', 'H', 'L', 'M']:  # No A
    INC_DEC_OPCODES[f'IN{reg}'] = ('INR', reg)
    INC_DEC_OPCODES[f'DC{reg}'] = ('DCR', reg)

# I/O instructions
# 8008: INP port (1 byte), OUT port (1 byte)
# 8080: IN port (2 bytes), OUT port (2 bytes)
IO_OPCODES = {
    'INP': 'IN',
    'OUT': 'OUT',
}

# RST instruction (same in both)
# RST n -> RST n

# Pseudo-ops that may need adjustment
PSEUDO_OPS = {'ORG', 'EQU', 'DATA', 'DB', 'DS', 'DW', 'END', 'IF', 'ELSE', 'ENDIF', 'SET', 'TITLE', 'PAGE', 'INCL'}


def translate_line(line):
    """Translate a single line of 8008 assembly to 8080."""

    # Preserve empty lines
    if not line.strip():
        return line

    # Check for comment-only lines
    stripped = line.lstrip()
    if stripped.startswith(';'):
        return line

    # First, convert address notation and HB/LB throughout the line
    line = convert_address_notation(line)
    line = convert_hb_lb_notation(line)

    # Split into parts, preserving structure
    # Format: [label:] [opcode [operand]] [;comment]

    # Find comment position
    comment_pos = line.find(';')
    if comment_pos >= 0:
        code_part = line[:comment_pos]
        comment_part = line[comment_pos:]
    else:
        code_part = line
        comment_part = ''

    # If no code, return as-is
    if not code_part.strip():
        return line

    # Parse the code part
    # Handle labels (end with :)
    label = ''
    rest = code_part

    # Check for label at start
    match = re.match(r'^(\s*)([A-Za-z_][A-Za-z0-9_]*)\s*:', code_part)
    if match:
        leading_space = match.group(1)
        label = match.group(2) + ':'
        rest = code_part[match.end():]
    else:
        # Preserve leading whitespace
        match = re.match(r'^(\s*)', code_part)
        leading_space = match.group(1) if match else ''
        rest = code_part[len(leading_space):]

    # Parse opcode and operand from rest
    rest = rest.strip()
    if not rest:
        # Label only
        return line

    # Split into opcode and operand
    parts = rest.split(None, 1)
    opcode = parts[0].upper()
    operand = parts[1] if len(parts) > 1 else ''

    # Now translate based on opcode type
    new_opcode = opcode
    new_operand = operand

    # Check simple opcodes
    if opcode in SIMPLE_OPCODES:
        new_opcode = SIMPLE_OPCODES[opcode]

    # Check jump opcodes
    elif opcode in JUMP_OPCODES:
        new_opcode = JUMP_OPCODES[opcode]

    # Check call opcodes
    elif opcode in CALL_OPCODES:
        new_opcode = CALL_OPCODES[opcode]

    # Check immediate opcodes
    elif opcode in IMMEDIATE_OPCODES:
        new_opcode = IMMEDIATE_OPCODES[opcode]
        new_operand = convert_immediate_value(operand)

    # Check load immediate opcodes
    elif opcode in LOAD_IMM_OPCODES:
        mvi, reg = LOAD_IMM_OPCODES[opcode]
        new_opcode = mvi
        converted_val = convert_immediate_value(operand)
        new_operand = f'{reg},{converted_val}' if operand else reg

    # Check move opcodes
    elif opcode in MOVE_OPCODES:
        mov, dest, src = MOVE_OPCODES[opcode]
        new_opcode = mov
        new_operand = f'{dest},{src}'

    # Check arithmetic opcodes
    elif opcode in ARITH_OPCODES:
        op, reg = ARITH_OPCODES[opcode]
        new_opcode = op
        new_operand = reg

    # Check increment/decrement
    elif opcode in INC_DEC_OPCODES:
        op, reg = INC_DEC_OPCODES[opcode]
        new_opcode = op
        new_operand = reg

    # Check I/O opcodes
    elif opcode in IO_OPCODES:
        new_opcode = IO_OPCODES[opcode]

    # RST - same syntax
    elif opcode == 'RST':
        pass  # Keep as-is

    # LXI - for stack pointer
    elif opcode == 'LXI':
        pass  # Keep as-is, um80 should understand

    # Pseudo-ops - keep as-is but may need adjustment
    elif opcode in PSEUDO_OPS:
        # DATA -> DB for um80 compatibility
        # But DATA *n means reserve n bytes (DS n)
        if opcode == 'DATA':
            if operand.startswith('*'):
                new_opcode = 'DS'
                new_operand = operand[1:]  # Remove the *
            else:
                new_opcode = 'DB'
                # Convert octal data values to hex
                new_operand = convert_data_values(operand)
        elif opcode == 'EQU':
            # Convert octal value if present
            new_operand = convert_immediate_value(operand)
        elif opcode == 'DS':
            # DS value might be octal
            new_operand = convert_immediate_value(operand)

    # Unknown opcode - keep as-is
    else:
        pass

    # Reconstruct line
    if label:
        result = f'{leading_space}{label}'
        if new_opcode != opcode or new_operand != operand:
            # Add translated instruction
            if new_operand:
                result += f'\t{new_opcode}\t{new_operand}'
            else:
                result += f'\t{new_opcode}'
        else:
            # Keep original formatting
            if operand:
                result += f'\t{opcode}\t{operand}'
            elif rest:
                result += f'\t{opcode}'
    else:
        if new_operand:
            result = f'{leading_space}{new_opcode}\t{new_operand}'
        else:
            result = f'{leading_space}{new_opcode}'

    # Add comment back
    if comment_part:
        # Try to align comment
        result = result.rstrip()
        if len(result) < 40:
            result += ' ' * (40 - len(result))
        else:
            result += '\t'
        result += comment_part

    return result


def translate_file(input_path, output_path=None):
    """Translate an entire 8008 assembly file to 8080."""

    with open(input_path, 'r', encoding='utf-8', errors='replace') as f:
        lines = f.readlines()

    translated = []
    for line in lines:
        # Remove trailing newline, translate, add back
        line_stripped = line.rstrip('\n\r')
        translated_line = translate_line(line_stripped)
        translated.append(translated_line)

    output = '\n'.join(translated)

    if output_path:
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(output)
            f.write('\n')
    else:
        print(output)

    return translated


def main():
    parser = argparse.ArgumentParser(
        description='Translate Intel 8008 assembly to 8080 mnemonics'
    )
    parser.add_argument('input', help='Input 8008 assembly file')
    parser.add_argument('-o', '--output', help='Output 8080 assembly file')

    args = parser.parse_args()

    translate_file(args.input, args.output)


if __name__ == '__main__':
    main()
