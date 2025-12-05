/*
 * SCELBAL tracer - traces memory writes to FPACC to debug the PRINT 1 bug
 *
 * Build: g++ -O2 -I/home/wohl/src/cpmemu/src -o trace_scelbal trace_scelbal.cc \
 *        /home/wohl/src/cpmemu/src/qkz80.cc /home/wohl/src/cpmemu/src/qkz80_mem.cc \
 *        /home/wohl/src/cpmemu/src/qkz80_reg_set.cc /home/wohl/src/cpmemu/src/qkz80_errors.cc
 */

#include "qkz80.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>
#include <map>
#include <string>
#include <fstream>
#include <sstream>

// SCELBAL memory addresses (PRN addresses + 0x100 for CP/M relocation)
// PRN shows code at 0x0000 but COM loads at 0x0100
#define RELOC_OFFSET 0x0100
#define ARITH_STKPTR (0x006F + RELOC_OFFSET)  // Not in symbol file, from PRN

#define FPACC_LSW_M1 (0x001E + RELOC_OFFSET)
#define FPACC_LSW    (0x001F + RELOC_OFFSET)
#define FPACC_NSW    (0x0020 + RELOC_OFFSET)
#define FPACC_MSW    (0x0021 + RELOC_OFFSET)
#define FPACC_EXP    (0x0022 + RELOC_OFFSET)

// Key routine addresses (PRN addresses + 0x100)
#define PFPOUT       (0x0C0D + RELOC_OFFSET)  // Updated
#define FPFLT        (0x0F73 + RELOC_OFFSET)
#define FININP       (0x1360 + RELOC_OFFSET)
#define DINPUT       (0x12A4 + RELOC_OFFSET)
#define NOEXPO       (0x047B + RELOC_OFFSET)
#define ACCSET       (0x0FC5 + RELOC_OFFSET)
#define ACNONZ       (0x0FB1 + RELOC_OFFSET)
#define FPOUT        (0x1430 + RELOC_OFFSET)  // Symbol: 0x1530
#define DECOUT       (0x14AF + RELOC_OFFSET)  // Symbol: 0x15AF
#define DECEXT       (0x147D + RELOC_OFFSET)  // Symbol: 0x157D
#define OUTFIX       (0x1476 + RELOC_OFFSET)  // Symbol: 0x1576
#define FPMULT       (0x1092 + RELOC_OFFSET)  // Symbol: 0x1192
#define FPDIV        (0x1156 + RELOC_OFFSET)  // Symbol: 0x1256
#define DVEXIT       (0x11D0 + RELOC_OFFSET)  // Symbol: 0x12D0
#define DECEXD       (0x149D + RELOC_OFFSET)  // Symbol: 0x159D
#define DECREP       (0x1495 + RELOC_OFFSET)  // Symbol: 0x1595

// FPOP addresses (updated after fixing FPOP_EXT_59 size)
#define FPOP_EXT_59  (0x0026 + RELOC_OFFSET)  // Working area for division (3 bytes)
#define FPOP_LSW     (0x0029 + RELOC_OFFSET)  // Was 0x27, now 0x29
#define FPOP_NSW     (0x002A + RELOC_OFFSET)  // Was 0x28, now 0x2A
#define FPOP_MSW     (0x002B + RELOC_OFFSET)  // Was 0x29, now 0x2B
#define FPOP_EXP     (0x002C + RELOC_OFFSET)  // Was 0x2A, now 0x2C
#define FP_TEMP      (0x002B + RELOC_OFFSET)
#define ADOPPP_ADDR  (0x1136 + RELOC_OFFSET)

// Partial product work area (from PRN: FP_WORK_61=0x0031)
#define FP_WORK_61   (0x0031 + RELOC_OFFSET)
#define FP_WORK_66   (0x0036 + RELOC_OFFSET)
#define EXMLDV_ADDR  (0x10E1 + RELOC_OFFSET)  // Symbol: 0x11E1

// Tracing memory class
class TracingMem : public qkz80_cpu_mem {
public:
    bool trace_fpacc;
    bool trace_all_mem;
    qkz80_uint16 last_pc;
    std::map<qkz80_uint16, const char*> labels;

    TracingMem() : trace_fpacc(false), trace_all_mem(false), last_pc(0) {
        // Add known labels
        labels[PFPOUT] = "PFPOUT";
        labels[FPFLT] = "FPFLT";
        labels[FININP] = "FININP";
        labels[DINPUT] = "DINPUT";
        labels[ACCSET] = "ACCSET";
        labels[ACNONZ] = "ACNONZ";
        labels[FPOUT] = "FPOUT";
        labels[DECOUT] = "DECOUT";
        labels[DECEXT] = "DECEXT";
        labels[OUTFIX] = "OUTFIX";
        labels[FPMULT] = "FPMULT";
        labels[EXMLDV_ADDR] = "EXMLDV";
        labels[DECEXD] = "DECEXD";
        labels[DECREP] = "DECREP";
        labels[ADOPPP_ADDR] = "ADOPPP";
        labels[FPACC_LSW_M1] = "FPACC_LSW_M1";
        labels[FPACC_LSW] = "FPACC_LSW";
        labels[FPACC_NSW] = "FPACC_NSW";
        labels[FPACC_MSW] = "FPACC_MSW";
        labels[FPACC_EXP] = "FPACC_EXP";
    }

    void set_last_pc(qkz80_uint16 pc) { last_pc = pc; }

    virtual void store_mem(qkz80_uint16 addr, qkz80_uint8 abyte) override {
        // Trace writes to FPACC region
        if (trace_fpacc && addr >= FPACC_LSW_M1 && addr <= FPACC_EXP) {
            const char* name = "???";
            if (labels.count(addr)) name = labels[addr];
            printf("  [PC=%04X] WRITE %s (%04X) = %02X\n", last_pc, name, addr, abyte);
        }
        qkz80_cpu_mem::store_mem(addr, abyte);
    }

    void dump_fpacc() {
        printf("  FPACC: LSW_M1=%02X LSW=%02X NSW=%02X MSW=%02X EXP=%02X\n",
               fetch_mem(FPACC_LSW_M1), fetch_mem(FPACC_LSW),
               fetch_mem(FPACC_NSW), fetch_mem(FPACC_MSW), fetch_mem(FPACC_EXP));
    }
    void dump_fpop() {
        // Use dynamic symbol lookup - addresses changed after NOEXPO fix
        extern qkz80_uint16 sym(const char*);
        printf("  FPOP: LSW=%02X NSW=%02X MSW=%02X EXP=%02X\n",
               fetch_mem(sym("FPOP_LSW")), fetch_mem(sym("FPOP_NSW")),
               fetch_mem(sym("FPOP_MSW")), fetch_mem(sym("FPOP_EXP")));
    }
    void dump_fpop_ext() {
        printf("  FPOP_EXT6: %02X %02X %02X %02X %02X %02X (59,LSW,NSW,MSW,EXP,TMP)\n",
               fetch_mem(FPOP_EXT_59), fetch_mem(FPOP_LSW), fetch_mem(FPOP_NSW),
               fetch_mem(FPOP_MSW), fetch_mem(FPOP_EXP), fetch_mem(FP_TEMP));
    }
};

// Symbol table loader
std::map<std::string, qkz80_uint16> symbol_table;

bool load_symbols(const char* sym_file) {
    std::ifstream file(sym_file);
    if (!file.is_open()) {
        fprintf(stderr, "Cannot open symbol file: %s\n", sym_file);
        return false;
    }

    std::string line;
    int count = 0;
    while (std::getline(file, line)) {
        std::istringstream iss(line);
        std::string addr_str, symbol;
        if (iss >> addr_str >> symbol) {
            unsigned int addr;
            if (sscanf(addr_str.c_str(), "%x", &addr) == 1) {
                // Don't add offset - emulator PC is already relative to 0
                symbol_table[symbol] = addr;
                count++;
            }
        }
    }

    printf("Loaded %d symbols from %s\n", count, sym_file);
    printf("  SCAN5=%04X, SCAN6=%04X, SCAN7=%04X\n",
           symbol_table["SCAN5"], symbol_table["SCAN6"], symbol_table["SCAN7"]);
    printf("  FUNARR=%04X, FAERR=%04X, PRIGHT=%04X\n",
           symbol_table["FUNARR"], symbol_table["FAERR"], symbol_table["PRIGHT"]);
    return count > 0;
}

qkz80_uint16 sym(const char* name) {
    auto it = symbol_table.find(name);
    if (it != symbol_table.end()) {
        return it->second;
    }
    fprintf(stderr, "Warning: Symbol '%s' not found\n", name);
    return 0;
}

// Variable-related addresses from the freshly assembled symbol table
// NOTE: Symbol addresses already include the 0x100 CP/M offset
#define SYMBOL_BUF   0x1720
#define SYMBOL_CHAR1 0x1721
#define AUX_SYMBOL_BUF 0x1730
#define SYMVAR_CNT   0x180A
#define VARIABLES_TBL 0x1855  // VARIABLE from sym
#define LOOKUP       (0x0594 + RELOC_OFFSET)
#define LOOKU1       (0x05A8 + RELOC_OFFSET)
#define LOOKU2       (0x05BF + RELOC_OFFSET)
#define LOOKU4       (0x05F4 + RELOC_OFFSET)
#define STOSYM       (0x08AE + RELOC_OFFSET)
#define GETCHR       (0x02F2 + RELOC_OFFSET)
#define CONCT1       (0x031F + RELOC_OFFSET)
#define CONCTN       (0x0312 + RELOC_OFFSET)
#define CONCTS       (0x031C + RELOC_OFFSET)
#define SYNTAX_PTR   0x174D  // SYNTAX_P from sym
#define LET_ENTRY    (0x0D5B + RELOC_OFFSET)  // LET from sym
#define LET0         (0x0D4D + RELOC_OFFSET)  // LET0 from sym
#define LET1         (0x0D62 + RELOC_OFFSET)
#define LET2         (0x0D6B + RELOC_OFFSET)
#define LET3         (0x0D8C + RELOC_OFFSET)
#define LET5         (0x0DA2 + RELOC_OFFSET)
#define SAVESY       (0x091B + RELOC_OFFSET)
#define RESTSY       (0x0924 + RELOC_OFFSET)
#define STOSY1       (0x08C2 + RELOC_OFFSET)
#define STOSY5       (0x0912 + RELOC_OFFSET)
#define ARRAY_FLAG   0x184D  // ARRAY_FL from sym

// FA stack related addresses (sym file addresses + RELOC_OFFSET)
#define FAERR        (0x080A + RELOC_OFFSET)
#define FA_STACK     (0x186A + RELOC_OFFSET)
#define FA_STKPTR    (0x177B + RELOC_OFFSET)
#define FUNAR2       (0x1FF3 + RELOC_OFFSET)
#define FUNAR4       (0x0815 + RELOC_OFFSET)
#define FUNARR       (0x07D9 + RELOC_OFFSET)
#define NUM_DIM_ARRAYS (0x1823 + RELOC_OFFSET)
#define PRIGHT       (0x079A + RELOC_OFFSET)
#define SCAN6        (0x0471 + RELOC_OFFSET)
#define SCAN7        (0x047C + RELOC_OFFSET)

// Simple console I/O simulation
static char input_buffer[2048] =
    // Test various PRINT expressions
    "PRINT (2*(3+4))\r"
    ;
static int input_pos = 0;
static bool got_ready = false;
static int ready_count = 0;
static char output_buffer[4096];
static int output_pos = 0;

int main(int argc, char** argv) {
    // Load symbol table first
    if (!load_symbols("/home/wohl/src/scelbal/src/scelbal.sym")) {
        fprintf(stderr, "Failed to load symbol table\n");
        return 1;
    }

    TracingMem mem;
    qkz80 cpu(&mem);
    cpu.set_cpu_mode(qkz80::MODE_8080);

    // Load SCELBAL
    FILE* fp = fopen("/home/wohl/src/scelbal/src/scelbal.com", "rb");
    if (!fp) {
        fprintf(stderr, "Cannot open scelbal.com\n");
        return 1;
    }

    // Load at 0x0100
    char* memory = mem.get_mem();
    fread(memory + 0x0100, 1, 0x7000, fp);
    fclose(fp);

    // Set up CP/M environment
    memory[0x0000] = 0xC3;  // JMP to BIOS warm boot (we'll intercept)
    memory[0x0001] = 0x00;
    memory[0x0002] = 0xF0;

    memory[0x0005] = 0xC9;  // RET for BDOS (we'll intercept)

    // Start execution at 0x0100
    cpu.regs.PC.set_pair16(0x0100);
    cpu.regs.SP.set_pair16(0xF000);

    printf("Starting SCELBAL trace...\n");
    printf("Input will be: %s\n", input_buffer);

    long long instr_count = 0;
    bool trace_active = false;

    while (instr_count < 500000000LL) {
        qkz80_uint16 pc = cpu.regs.PC.get_pair16();
        mem.set_last_pc(pc);

        // Check for BDOS call (address 0x0005)
        if (pc == 0x0005) {
            qkz80_uint8 func = cpu.regs.BC.get_low();  // C register
            qkz80_uint16 de = cpu.regs.DE.get_pair16();

            if (func == 1) {
                // Console input
                char ch = input_buffer[input_pos];
                if (ch == '\0') {
                    // No more input - we're done
                    printf("\n=== END OF INPUT (pos=%d) ===\n", input_pos);
                    printf("Input buffer was: '%s'\n", input_buffer);
                    break;
                }
                // Debug: show each character being read
                static int char_count = 0;
                char_count++;
                if (char_count <= 50 || ch == '\r') {
                    printf("[IN#%d]: '%c' (0x%02X)\n", char_count, (ch >= 32 && ch < 127) ? ch : '.', (unsigned char)ch);
                }
                if (ch == '\r') ch = '\r';
                cpu.regs.AF.set_high(ch);  // A register
                input_pos++;
            } else if (func == 2) {
                // Console output
                char ch = cpu.regs.DE.get_low();  // E register
                output_buffer[output_pos++] = ch;
                output_buffer[output_pos] = '\0';
                putchar(ch);
                fflush(stdout);

                // Check for "READY" prompt
                if (output_pos >= 5 && strcmp(output_buffer + output_pos - 5, "READY") == 0) {
                    ready_count++;
                    if (ready_count == 1) {
                        // printf("\n>>> First READY seen, enabling FPACC trace\n");
                        // mem.trace_fpacc = true;  // Disable verbose tracing for test suite
                    }
                }
            } else if (func == 9) {
                // Print string
                qkz80_uint16 addr = de;
                while (memory[addr] != '$') {
                    putchar(memory[addr]);
                    output_buffer[output_pos++] = memory[addr];
                    addr++;
                }
                output_buffer[output_pos] = '\0';
            } else if (func == 0) {
                // Exit
                printf("\n=== PROGRAM EXIT ===\n");
                break;
            }

            // Return from BDOS
            cpu.regs.PC.set_pair16(cpu.pop_word());
            continue;
        }

        // Trace SYMBOL_BUF clearing
        if (pc == sym("CLESYM")) {
            qkz80_uint16 symbol_buf_addr = sym("SYMBOL_B");
            qkz80_uint8 cc = mem.fetch_mem(symbol_buf_addr);
            printf("\n>>> CLESYM: Clearing SYMBOL_BUF (was cc=%02X)\n", cc);
        }

        // Trace FA stack operations
        // Trace the MVI M,70H instruction that should init ARITH_STKPTR
        if (pc == 0x0312 + RELOC_OFFSET) {
            qkz80_uint16 arith_stkptr_addr = ARITH_STKPTR;
            qkz80_uint8 hl_low = cpu.regs.HL.get_low();
            qkz80_uint8 hl_high = cpu.regs.HL.get_high();
            printf("\n>>> At 0x0312 (MVI M,70H): HL=%02X%02X, ARITH_STKPTR before=%02X\n",
                   hl_high, hl_low, mem.fetch_mem(arith_stkptr_addr));
        }
        if (pc == 0x0314 + RELOC_OFFSET) {
            qkz80_uint16 arith_stkptr_addr = ARITH_STKPTR;
            printf(">>> After MVI: ARITH_STKPTR=%02X\n", mem.fetch_mem(arith_stkptr_addr));
        }
        if (pc == sym("EVAL")) {
            qkz80_uint16 fa_stkptr_addr = sym("FA_STKPT");
            qkz80_uint16 symbol_buf_addr = sym("SYMBOL_B");
            qkz80_uint16 eval_ptr_addr = sym("EVAL_PTR");
            qkz80_uint16 eval_finish_addr = sym("EVAL_FIN");
            qkz80_uint16 scan_ptr_addr = sym("SCAN_PTR");
            qkz80_uint16 line_inp_buf = sym("LINE_INP");
            qkz80_uint16 arith_stkptr_addr = ARITH_STKPTR;
            printf("\n>>> EVAL entry\n");
            printf("  FA_STKPTR=%02X, SYMBOL_BUF (cc=%02X)\n",
                   mem.fetch_mem(fa_stkptr_addr),
                   mem.fetch_mem(symbol_buf_addr));
            printf("  EVAL_PTR=%02X, EVAL_FINISH=%02X, SCAN_PTR=%02X\n",
                   mem.fetch_mem(eval_ptr_addr),
                   mem.fetch_mem(eval_finish_addr),
                   mem.fetch_mem(scan_ptr_addr));
            printf("  ARITH_STKPTR (before init)=%02X\n", mem.fetch_mem(arith_stkptr_addr));
            // Dump LINE_INP_BUF
            printf("  LINE_INP_BUF: ");
            qkz80_uint8 buf_len = mem.fetch_mem(line_inp_buf);
            for (int i = 1; i <= buf_len && i <= 20; i++) {
                qkz80_uint8 ch = mem.fetch_mem(line_inp_buf + i);
                printf("%02X ", ch);
            }
            printf("\n");
        }
        if (pc == sym("SCAN1")) {
            qkz80_uint16 arith_stkptr_addr = ARITH_STKPTR;
            static bool first_scan1 = true;
            if (first_scan1) {
                first_scan1 = false;
                printf("\n>>> After EVAL init: ARITH_STKPTR=%02X\n", mem.fetch_mem(arith_stkptr_addr));
            }
        }
        if (pc == sym("PRINT1")) {
            qkz80_uint16 scan_ptr_addr = sym("SCAN_PTR");
            qkz80_uint16 token_store_addr = sym("TOKEN_ST");
            qkz80_uint16 line_inp_buf = sym("LINE_INP");
            printf("\n>>> PRINT1: Starting to process PRINT field\n");
            printf("  SCAN_PTR=%02X, TOKEN_STORE=%02X, LINE_BUF[cc]=%02X\n",
                   mem.fetch_mem(scan_ptr_addr),
                   mem.fetch_mem(token_store_addr),
                   mem.fetch_mem(line_inp_buf));
        }
        if (pc == sym("PRINT3")) {
            qkz80_uint16 scan_ptr_addr = sym("SCAN_PTR");
            printf("\n>>> PRINT3: Setting up EVAL pointers\n");
            printf("  SCAN_PTR=%02X\n", mem.fetch_mem(scan_ptr_addr));
        }
        if (pc == sym("PRINT6")) {
            qkz80_uint16 token_store_addr = sym("TOKEN_ST");
            qkz80_uint16 scan_ptr_addr = sym("SCAN_PTR");
            printf("\n>>> PRINT6: After output, preparing to check for more fields\n");
            printf("  TOKEN_STORE=%02X, SCAN_PTR=%02X\n",
                   mem.fetch_mem(token_store_addr),
                   mem.fetch_mem(scan_ptr_addr));
        }
        if (pc == sym("PFPOUT")) {
            qkz80_uint16 token_store_addr = sym("TOKEN_ST");
            qkz80_uint16 scan_ptr_addr = sym("SCAN_PTR");
            printf("\n>>> PFPOUT: Entering output routine\n");
            printf("  TOKEN_STORE=%02X, SCAN_PTR=%02X (before output)\n",
                   mem.fetch_mem(token_store_addr),
                   mem.fetch_mem(scan_ptr_addr));
        }
        if (pc == sym("PCOMMA")) {
            qkz80_uint16 token_store_addr = sym("TOKEN_ST");
            printf("\n>>> PCOMMA: Handling comma spacing\n");
            printf("  TOKEN_STORE=%02X\n", mem.fetch_mem(token_store_addr));
        }
        if (pc == sym("SCAN10")) {
            qkz80_uint16 eval_current_addr = sym("EVAL_CUR");
            qkz80_uint8 old_pos = mem.fetch_mem(eval_current_addr);
            printf("\n>>> SCAN10: Incrementing position %02X→%02X\n", old_pos, old_pos + 1);
        }
        if (pc == sym("GETCHR")) {
            qkz80_uint16 eval_current_addr = sym("EVAL_CUR");
            qkz80_uint16 line_inp_buf = sym("LINE_INP");
            qkz80_uint8 current_pos = mem.fetch_mem(eval_current_addr);
            qkz80_uint8 ch = mem.fetch_mem(line_inp_buf + current_pos);
            qkz80_uint8 hl_low = cpu.regs.HL.get_low();
            printf("\n>>> GETCHR: pos=%02X, HL_low=%02X, LINE_INP_BUF[%02X]=%02X\n",
                   current_pos, hl_low, current_pos, ch);
        }
        if (pc == sym("SCAN1")) {
            qkz80_uint16 eval_current_addr = sym("EVAL_CUR");
            qkz80_uint16 line_inp_buf = sym("LINE_INP");
            qkz80_uint8 current_pos = mem.fetch_mem(eval_current_addr);
            qkz80_uint8 ch = mem.fetch_mem(line_inp_buf + current_pos);
            qkz80_uint8 char_in_a = cpu.regs.AF.get_high();
            printf(">>> SCAN1: position %02X, char '%c' (0x%02X), A=%02X\n",
                   current_pos, (ch >= 0x20 && ch < 0x7F) ? ch : '.', ch, char_in_a);
        }
        if (pc == sym("SCAN6")) {
            qkz80_uint16 fa_stkptr_addr = sym("FA_STKPT");
            qkz80_uint16 symbol_buf_addr = sym("SYMBOL_B");
            qkz80_uint16 eval_current_addr = sym("EVAL_CUR");
            qkz80_uint16 op_stkptr_addr = sym("OP_STKPT");
            qkz80_uint8 fa_ptr = mem.fetch_mem(fa_stkptr_addr);
            qkz80_uint8 op_ptr = mem.fetch_mem(op_stkptr_addr);
            qkz80_uint8 sb_cc = mem.fetch_mem(symbol_buf_addr);
            qkz80_uint8 char_in_a = cpu.regs.AF.get_high();
            printf("\n>>> SCAN6: '(' encountered at pos %02X, A=%02X\n",
                   mem.fetch_mem(eval_current_addr), char_in_a);
            printf("  FA_STKPTR=%02X→%02X, OP_STKPTR=%02X, SYMBOL_BUF (cc=%02X)\n",
                   fa_ptr, fa_ptr + 1, op_ptr, sb_cc);
        }
        if (pc == sym("SCAN7")) {
            qkz80_uint16 fa_stkptr_addr = sym("FA_STKPT");
            qkz80_uint16 symbol_buf_addr = sym("SYMBOL_B");
            qkz80_uint16 eval_current_addr = sym("EVAL_CUR");
            qkz80_uint16 op_stkptr_addr = sym("OP_STKPT");
            qkz80_uint8 fa_ptr = mem.fetch_mem(fa_stkptr_addr);
            qkz80_uint8 op_ptr = mem.fetch_mem(op_stkptr_addr);
            qkz80_uint8 sb_cc = mem.fetch_mem(symbol_buf_addr);
            qkz80_uint8 char_in_a = cpu.regs.AF.get_high();
            printf("\n>>> SCAN7: ')' encountered at pos %02X, A=%02X\n",
                   mem.fetch_mem(eval_current_addr), char_in_a);
            printf("  FA_STKPTR=%02X→%02X, OP_STKPTR=%02X, SYMBOL_BUF (cc=%02X)\n",
                   fa_ptr, fa_ptr - 1, op_ptr, sb_cc);
        }
        if (pc == sym("PARSER")) {
            qkz80_uint16 parser_token_addr = sym("PARSER_T");
            qkz80_uint16 op_stkptr_addr = sym("OP_STKPT");
            qkz80_uint16 op_stack_addr = sym("OP_STACK");
            qkz80_uint16 symbol_buf_addr = sym("SYMBOL_B");
            qkz80_uint8 token = mem.fetch_mem(parser_token_addr);
            qkz80_uint8 op_ptr = mem.fetch_mem(op_stkptr_addr);
            qkz80_uint8 sb_cc = mem.fetch_mem(symbol_buf_addr);
            printf("\n>>> PARSER: Processing token=%d, OP_STKPTR=%02X, SYMBOL_BUF[cc=%02X",
                   token, op_ptr, sb_cc);
            if (sb_cc > 0) {
                printf(",ch1=%02X", mem.fetch_mem(symbol_buf_addr + 1));
            }
            printf("]\n");
            printf("  OP_STACK[0]=%02X, OP_STACK[%d]=%02X\n",
                   mem.fetch_mem(op_stack_addr),
                   op_ptr, mem.fetch_mem(op_stack_addr + op_ptr));
        }
        if (pc == sym("PARSE2")) {
            qkz80_uint16 op_stkptr_addr = sym("OP_STKPT");
            qkz80_uint8 op_ptr = mem.fetch_mem(op_stkptr_addr);
            printf("\n>>> PARSE2: Looking for '(' on stack, OP_STKPTR=%02X\n", op_ptr);
        }
        if (pc == sym("PARNER")) {
            printf("\n>>> PARNER: Imbalanced parenthesis error!\n");
        }
        if (pc == sym("SYNTX6A")) {
            qkz80_uint16 scan_ptr_addr = sym("SCAN_PTR");
            qkz80_uint8 scan_ptr = mem.fetch_mem(scan_ptr_addr);
            printf("\n>>> SYNTX6A entry: SCAN_PTR=%02X\n", scan_ptr);
        }
        if (pc == sym("LOOP")) {
            qkz80_uint16 scan_ptr_addr = sym("SCAN_PTR");
            qkz80_uint8 scan_ptr_before = mem.fetch_mem(scan_ptr_addr);
            // LOOP will increment, so check after
            // We'll trace this in the next instruction after LOOP returns
        }
        if (pc == sym("SYNTX6")) {
            qkz80_uint16 scan_ptr_addr = sym("SCAN_PTR");
            qkz80_uint8 scan_ptr = mem.fetch_mem(scan_ptr_addr);
            printf("\n>>> SYNTX6 (after SYNTX6A): SCAN_PTR=%02X\n", scan_ptr);
        }
        if (pc == sym("CLESYM")) {
            qkz80_uint16 symbol_buf_addr = sym("SYMBOL_B");
            qkz80_uint8 cc = mem.fetch_mem(symbol_buf_addr);
            if (cc > 0) {
                printf("\n>>> CLESYM: Clearing SYMBOL_BUF (was cc=%02X): ", cc);
                for (int i = 1; i <= cc && i <= 10; i++) {
                    qkz80_uint8 ch = mem.fetch_mem(symbol_buf_addr + i);
                    printf("%c", (ch >= 0xC1 && ch <= 0xDA) ? (ch - 0x80) : '?');
                }
                printf("\n");
            }
        }
        if (pc == sym("CONCTS")) {
            qkz80_uint16 symbol_buf_addr = sym("SYMBOL_B");
            qkz80_uint16 scan_ptr_addr = sym("SCAN_PTR");
            qkz80_uint8 cc = mem.fetch_mem(symbol_buf_addr);
            qkz80_uint8 char_in_a = cpu.regs.AF.get_high();
            qkz80_uint8 scan_ptr = mem.fetch_mem(scan_ptr_addr);
            printf("\n>>> CONCTS: Adding char '%c' (0x%02X) to SYMBOL_BUF (cc=%02X→%02X), SCAN_PTR=%02X\n",
                   (char_in_a >= 0xC1 && char_in_a <= 0xDA) ? (char_in_a - 0x80) : '?',
                   char_in_a, cc, cc + 1, scan_ptr);
        }
        if (pc == sym("FPOPER")) {
            qkz80_uint16 arith_stkptr_addr = ARITH_STKPTR;
            qkz80_uint16 fpacc_msw_addr = sym("FPACC_MS");
            qkz80_uint8 arith_ptr = mem.fetch_mem(arith_stkptr_addr);
            qkz80_uint8 op_token = cpu.regs.AF.get_high();
            printf("\n>>> FPOPER: token=%02X, ARITH_STKPTR=%02X, FPACC_MSW=%02X\n",
                   op_token, arith_ptr, mem.fetch_mem(fpacc_msw_addr));
        }
        if (pc == sym("FUNARR")) {
            qkz80_uint16 symbol_buf_addr = sym("SYMBOL_B");
            qkz80_uint16 num_dim_addr = sym("NUM_DIM_");
            qkz80_uint8 cc = mem.fetch_mem(symbol_buf_addr);
            printf("\n>>> FUNARR entry\n");
            printf("  SYMBOL_BUF (cc=%02X): ", cc);
            for (int i = 1; i <= cc && i <= 10; i++) {
                qkz80_uint8 ch = mem.fetch_mem(symbol_buf_addr + i);
                printf("%c", (ch >= 0xC1 && ch <= 0xDA) ? (ch - 0x80) : '?');
            }
            printf("\n");
            printf("  NUM_DIM_ARRAYS=%02X\n", mem.fetch_mem(num_dim_addr));
        }
        if (pc == sym("FUNAR2")) {
            qkz80_uint16 num_dim_addr = sym("NUM_DIM_");
            printf("\n>>> FUNAR2 entry (array search)\n");
            printf("  NUM_DIM_ARRAYS=%02X\n", mem.fetch_mem(num_dim_addr));
        }
        if (pc == sym("FUNAR4")) {
            qkz80_uint16 fa_stkptr_addr = sym("FA_STKPT");
            printf("\n>>> FUNAR4: Storing token on FA_STACK\n");
            printf("  FA_STKPTR=%02X\n", mem.fetch_mem(fa_stkptr_addr));
        }
        if (pc == sym("PRIGHT")) {
            qkz80_uint16 fa_stkptr_addr = sym("FA_STKPT");
            qkz80_uint16 fa_stack_addr = sym("FA_STACK");
            qkz80_uint16 eval_current_addr = sym("EVAL_CUR");
            qkz80_uint16 eval_finish_addr = sym("EVAL_FIN");
            qkz80_uint8 stack_ptr = mem.fetch_mem(fa_stkptr_addr);
            qkz80_uint8 eval_current = mem.fetch_mem(eval_current_addr);
            qkz80_uint8 eval_finish = mem.fetch_mem(eval_finish_addr);
            printf("\n>>> PRIGHT: Processing ')'\n");
            printf("  FA_STKPTR=%02X, FA_STACK[%02X]=%02X\n",
                   stack_ptr, stack_ptr,
                   mem.fetch_mem(fa_stack_addr + stack_ptr - 1));
            printf("  EVAL_CURRENT=%02X, EVAL_FINISH=%02X\n", eval_current, eval_finish);
        }
        if (pc == sym("ARRAY")) {
            qkz80_uint16 symbol_buf_addr = sym("SYMBOL_B");
            qkz80_uint8 cc = mem.fetch_mem(symbol_buf_addr);
            printf("\n>>> ARRAY: Entered array subscript handler\n");
            printf("  SYMBOL_BUF (cc=%02X): ", cc);
            for (int i = 1; i <= cc && i <= 10; i++) {
                qkz80_uint8 ch = mem.fetch_mem(symbol_buf_addr + i);
                printf("%c", (ch >= 0xC1 && ch <= 0xDA) ? (ch - 0x80) : '?');
            }
            printf("\n");
        }
        if (pc == sym("ARRAY6")) {
            qkz80_uint16 loop_ctr_addr = sym("LOOP_CNT");
            qkz80_uint16 num_dim_addr = sym("NUM_DIM_");
            printf("\n>>> ARRAY6: Looping to find array\n");
            printf("  LOOP_COUNTER=%02X, NUM_DIM_ARRAYS=%02X\n",
                   mem.fetch_mem(loop_ctr_addr),
                   mem.fetch_mem(num_dim_addr));
        }
        if (pc == sym("FAERR")) {
            qkz80_uint16 fa_stkptr_addr = sym("FA_STKPT");
            qkz80_uint16 symbol_buf_addr = sym("SYMBOL_B");
            qkz80_uint8 cc = mem.fetch_mem(symbol_buf_addr);
            printf("\n>>> FAERR: FA Error!\n");
            printf("  FA_STKPTR=%02X, SYMBOL_BUF (cc=%02X): ", mem.fetch_mem(fa_stkptr_addr), cc);
            for (int i = 1; i <= cc && i <= 10; i++) {
                qkz80_uint8 ch = mem.fetch_mem(symbol_buf_addr + i);
                printf("%c", (ch >= 0xC1 && ch <= 0xDA) ? (ch - 0x80) : '?');
            }
            printf("\n");
        }

        // Trace variable operations
        if (pc == SAVESY) {
            printf("\n>>> SAVESY: SYMBOL_BUF -> AUX_SYMBOL_BUF\n");
            printf("  SYMBOL_BUF (cc=%02X): '%c%c'\n", mem.fetch_mem(SYMBOL_BUF),
                   mem.fetch_mem(SYMBOL_CHAR1), mem.fetch_mem(SYMBOL_CHAR1+1));
        }
        if (pc == RESTSY) {
            printf("\n>>> RESTSY: AUX_SYMBOL_BUF -> SYMBOL_BUF\n");
            printf("  AUX_SYMBOL_BUF (cc=%02X): '%c%c'\n", mem.fetch_mem(AUX_SYMBOL_BUF),
                   mem.fetch_mem(AUX_SYMBOL_BUF+1), mem.fetch_mem(AUX_SYMBOL_BUF+2));
        }
        if (pc == LET0) {
            printf("\n>>> LET0: IMPLIED LET entry\n");
            printf("  SYMBOL_BUF (cc=%02X): '%c%c'\n", mem.fetch_mem(SYMBOL_BUF),
                   mem.fetch_mem(SYMBOL_CHAR1), mem.fetch_mem(SYMBOL_CHAR1+1));
        }
        if (pc == LET_ENTRY) {
            printf("\n>>> LET: Explicit LET entry\n");
        }
        if (pc == LET3) {
            printf("\n>>> LET3: Adding char to AUX_SYMBOL_BUF, A='%c' (%02X)\n",
                   cpu.regs.AF.get_high(), cpu.regs.AF.get_high());
        }
        if (pc == CONCT1) {
            printf("\n>>> CONCT1: Concatenating to buffer, A='%c' HL=%04X\n",
                   cpu.regs.AF.get_high(), cpu.regs.HL.get_pair16());
        }
        if (pc == LET5) {
            printf("\n>>> LET5: Processing expression after =\n");
        }
        if (pc == STOSYM) {
            printf("\n>>> STOSYM: Storing value in VARIABLES_TBL\n");
            printf("  SYMBOL_BUF @ %04X: ", SYMBOL_BUF);
            for (int i = 0; i < 8; i++) printf("%02X ", mem.fetch_mem(SYMBOL_BUF + i));
            printf("\n  As chars: '");
            for (int i = 0; i < 8; i++) {
                char c = mem.fetch_mem(SYMBOL_BUF + i);
                printf("%c", (c >= 32 && c < 127) ? c : '.');
            }
            printf("'\n");
            printf("  ARRAY FLAG @ %04X = %02X (non-zero means array!)\n",
                   ARRAY_FLAG, mem.fetch_mem(ARRAY_FLAG));
            mem.dump_fpacc();
            printf("  SYMVAR_CNT @ %04X = %02X\n", SYMVAR_CNT, mem.fetch_mem(SYMVAR_CNT));
        }
        if (pc == STOSY1) {
            printf("\n>>> STOSY1: Normal variable storage path\n");
        }
        if (pc == STOSY5) {
            printf("\n>>> STOSY5: Found var or added new, storing value\n");
            printf("  Before SWITCH: DE=%04X HL=%04X\n", cpu.regs.DE.get_pair16(), cpu.regs.HL.get_pair16());
            printf("  VARIABLES_TBL before store:\n");
            for (int i = 0; i < 3; i++) {
                int addr = VARIABLES_TBL + i * 6;
                printf("   Entry %d @ %04X: name=%02X%02X val=%02X %02X %02X %02X\n", i, addr,
                       mem.fetch_mem(addr), mem.fetch_mem(addr+1),
                       mem.fetch_mem(addr+2), mem.fetch_mem(addr+3),
                       mem.fetch_mem(addr+4), mem.fetch_mem(addr+5));
            }
        }
        if (pc == sym("NOEXPO")) {
            qkz80_uint16 symbol_buf_addr = sym("SYMBOL_B");
            qkz80_uint16 arith_stkptr_addr = ARITH_STKPTR;
            qkz80_uint16 fpacc_msw_addr = sym("FPACC_MS");
            qkz80_uint8 cc = mem.fetch_mem(symbol_buf_addr);
            qkz80_uint8 arith_ptr_before = mem.fetch_mem(arith_stkptr_addr);
            printf("\n>>> NOEXPO entry: SYMBOL_BUF (cc=%02X, ch1=%02X)\n",
                   cc, mem.fetch_mem(symbol_buf_addr + 1));
            printf("  ARITH_STKPTR (before)=%02X, FPACC before FSTORE=", arith_ptr_before);
            mem.dump_fpacc();
        }
        // Trace FSTORE - what value is being pushed to arithmetic stack
        if (pc == sym("FSTORE")) {
            qkz80_uint16 hl = cpu.regs.HL.get_pair16();
            printf("\n>>> FSTORE: Storing FPACC to stack at HL=%04X, FPACC=", hl);
            mem.dump_fpacc();
        }
        // Trace DINPUT - what number is being parsed into FPACC
        if (pc == sym("DINPUT")) {
            qkz80_uint16 symbol_buf_addr = sym("SYMBOL_B");
            printf("\n>>> DINPUT: Converting SYMBOL_BUF to FPACC, buf='%c%c', FPACC before=",
                   mem.fetch_mem(symbol_buf_addr + 1), mem.fetch_mem(symbol_buf_addr + 2));
            mem.dump_fpacc();
        }
        // Trace DINPUT exit
        static qkz80_uint16 dinput_ret_addr = 0;
        if (pc == sym("DINPUT")) {
            dinput_ret_addr = mem.fetch_mem(cpu.regs.SP.get_pair16()) |
                             (mem.fetch_mem(cpu.regs.SP.get_pair16() + 1) << 8);
        }
        if (dinput_ret_addr != 0 && pc == dinput_ret_addr) {
            printf(">>> DINPUT exit: FPACC after parse=");
            mem.dump_fpacc();
            dinput_ret_addr = 0;
        }
        // Trace OPLOAD - what value is being loaded from arithmetic stack to FPOP
        if (pc == sym("OPLOAD")) {
            qkz80_uint16 hl = cpu.regs.HL.get_pair16();
            printf("\n>>> OPLOAD: Loading from stack at HL=%04X to FPOP\n", hl);
            printf("  Stack contents: %02X %02X %02X %02X\n",
                   mem.fetch_mem(hl), mem.fetch_mem(hl+1),
                   mem.fetch_mem(hl+2), mem.fetch_mem(hl+3));
        }
        // Trace FPOPER entry
        if (pc == sym("FPOPER")) {
            qkz80_uint16 arith_stkptr_addr = ARITH_STKPTR;
            qkz80_uint8 arith_ptr = mem.fetch_mem(arith_stkptr_addr);
            printf("\n>>> FPOPER: ARITH_STKPTR=%02X, FPACC=", arith_ptr);
            mem.dump_fpacc();
        }
        if (pc == sym("PARSE")) {
            // Check ARITH_STKPTR after NOEXPO completes (when it jumps to PARSE)
            qkz80_uint16 arith_stkptr_addr = ARITH_STKPTR;
            static int parse_count = 0;
            static qkz80_uint8 last_arith_ptr = 0;
            qkz80_uint8 arith_ptr = mem.fetch_mem(arith_stkptr_addr);
            if (arith_ptr != last_arith_ptr && arith_ptr != 0) {
                printf("  >>> At PARSE: ARITH_STKPTR changed from %02X to %02X\n",
                       last_arith_ptr, arith_ptr);
                last_arith_ptr = arith_ptr;
            }
            if (parse_count < 3) {
                parse_count++;
                if (arith_ptr != 0) {  // Only print if non-zero (after NOEXPO runs)
                    printf("  >>> At PARSE #%d: ARITH_STKPTR=%02X\n", parse_count, arith_ptr);
                }
            }
        }
        if (pc == sym("PARNUM")) {
            qkz80_uint16 symbol_buf_addr = sym("SYMBOL_B");
            qkz80_uint8 cc = mem.fetch_mem(symbol_buf_addr);
            printf("\n>>> PARNUM: Parsing number, SYMBOL_BUF cc=%02X, ch1=%02X\n",
                   cc, mem.fetch_mem(symbol_buf_addr + 1));
        }
        if (pc == LOOKUP) {
            printf("\n>>> LOOKUP: Looking up variable\n");
            printf("  SYMBOL_BUF (cc=%02X): '%c%c'\n", mem.fetch_mem(SYMBOL_BUF),
                   mem.fetch_mem(SYMBOL_CHAR1), mem.fetch_mem(SYMBOL_CHAR1+1));
            printf("  SYMVAR_CNT = %02X\n", mem.fetch_mem(SYMVAR_CNT));
            printf("  First var in table: '%c%c' value=%02X %02X %02X %02X\n",
                   mem.fetch_mem(VARIABLES_TBL), mem.fetch_mem(VARIABLES_TBL+1),
                   mem.fetch_mem(VARIABLES_TBL+2), mem.fetch_mem(VARIABLES_TBL+3),
                   mem.fetch_mem(VARIABLES_TBL+4), mem.fetch_mem(VARIABLES_TBL+5));
        }
        if (pc == LOOKU4) {
            printf("\n>>> LOOKU4: Variable found/added at DE\n");
            printf("  DE=%04X\n", cpu.regs.DE.get_pair16());
            mem.dump_fpacc();
        }
        if (pc == PFPOUT) {
            printf("\n>>> PFPOUT: About to print FPACC\n");
            mem.dump_fpacc();
        }
        if (pc == FPOUT) {
            printf("\n>>> FPOUT: Output conversion entry, FPACC:\n");
            mem.dump_fpacc();
        }
        static int fpmult_count = 0;
        if (pc == sym("FPMULT")) {
            fpmult_count++;
            if (fpmult_count <= 10) {
                printf("\n>>> FPMULT[%d]: FPACC=", fpmult_count);
                mem.dump_fpacc();
                printf("  FPOP=");
                mem.dump_fpop();
            }
        }
        if (pc == EXMLDV_ADDR) {
            printf("\n>>> FPMULT result (at EXMLDV): FP_WORK_61=");
            printf("%02X %02X %02X %02X %02X %02X\n",
                   mem.fetch_mem(FP_WORK_61), mem.fetch_mem(FP_WORK_61+1),
                   mem.fetch_mem(FP_WORK_61+2), mem.fetch_mem(FP_WORK_61+3),
                   mem.fetch_mem(FP_WORK_61+4), mem.fetch_mem(FP_WORK_61+5));
        }
        static int decrep_count = 0;
        if (pc == DECREP) {
            decrep_count++;
            if (decrep_count <= 10) {
                printf("\n>>> DECREP[%d]: After mult, FPACC=", decrep_count);
                mem.dump_fpacc();
            }
        }
// RUN command tracing
// NOTE: Symbol file addresses already include 0x100 offset, so DON'T add RELOC_OFFSET
#define RUN_ENTRY    0x0B7B  // From sym file
#define SAMLIN       0x0BA8  // From sym file
#define NXTLIN       0x0B8B  // From sym file
#define USER_PGM_PTR 0x17BC
#define USER_PROG_BUF 0x1BA5
#define NOLIST       0x0960  // From sym file (was 0960 NOLIST)
#define LINE_INP_BUF 0x16D0
#define EXEC         0x092F  // From sym file
#define EXEC1        0x0935  // From sym file
#define STRCP        0x032D  // From sym file (already +0x100)
#define NOTEND       0x0A34  // From sym file
#define CONTIN       0x0A89  // From sym file
#define LINENUM_BUF  0x17AC  // From sym file (LINENUM_)
#define NOSAME       0x0A57  // From sym file - insert point found
#define END_PGM_PTR  0x17C0  // From sym file (END_PGM_)

#define DIVIDE_ADDR (0x117A + RELOC_OFFSET)  // 0x127A (after FPOP_EXT_59 fix)
        if (pc == FPDIV) {
            printf("\n>>> FPDIV: Division entry\n");
            printf("  FPACC (divisor):\n");
            mem.dump_fpacc();
            printf("  FPOP (dividend):\n");
            mem.dump_fpop();
        }
        static int divide_iter = 0;
        if (pc == DIVIDE_ADDR) {
            divide_iter++;
            if (divide_iter <= 5)
                printf("\n>>> DIVIDE[%02d]: divisor=%02X%02X%02X  dividend=%02X%02X%02X  workarea=%02X%02X%02X\n",
                       divide_iter,
                       mem.fetch_mem(FPACC_MSW), mem.fetch_mem(FPACC_NSW), mem.fetch_mem(FPACC_LSW),
                       mem.fetch_mem(FPOP_MSW), mem.fetch_mem(FPOP_NSW), mem.fetch_mem(FPOP_LSW),
                       mem.fetch_mem(FPOP_EXT_59+2), mem.fetch_mem(FPOP_EXT_59+1), mem.fetch_mem(FPOP_EXT_59));
        }
// Trace after SETSUB to see result of subtraction
#define AFTER_SETSUB (0x117B + RELOC_OFFSET)  // After CALL SETSUB at DIVIDE
        static int setsub_count = 0;
        if (pc == AFTER_SETSUB) {
            setsub_count++;
            if (setsub_count <= 5)
                printf("  After SETSUB[%d]: workarea(result)=%02X%02X%02X MSW=%02X (sign=%s)\n",
                       setsub_count,
                       mem.fetch_mem(FPOP_EXT_59+2), mem.fetch_mem(FPOP_EXT_59+1), mem.fetch_mem(FPOP_EXT_59),
                       mem.fetch_mem(FPOP_EXT_59+2),
                       (mem.fetch_mem(FPOP_EXT_59+2) & 0x80) ? "NEG" : "POS");
        }
        if (pc == DVEXIT) {
            printf("\n>>> DVEXIT: Division result in AUX_SYMBOL_BUF\n");
            printf("  Quotient (LSW NSW MSW): %02X %02X %02X\n",
                   mem.fetch_mem(AUX_SYMBOL_BUF), mem.fetch_mem(AUX_SYMBOL_BUF+1), mem.fetch_mem(AUX_SYMBOL_BUF+2));
        }
// Trace quotient after each ROTL
#define QUOROT_AFTER (0x119A + RELOC_OFFSET)  // After CALL ROTL returns (0x129A)
        static int quorot_count = 0;
        if (pc == QUOROT_AFTER) {
            quorot_count++;
            if (quorot_count <= 30) {  // Only show first 30
                printf("  QUOROT[%02d]: Quotient=%02X %02X %02X\n", quorot_count,
                       mem.fetch_mem(AUX_SYMBOL_BUF), mem.fetch_mem(AUX_SYMBOL_BUF+1), mem.fetch_mem(AUX_SYMBOL_BUF+2));
            }
        }
// After MOVEIT - trace result in FPACC
#define DVEXIT_AFTER (0x11DB + RELOC_OFFSET)  // After CALL MOVEIT
        if (pc == DVEXIT_AFTER) {
            printf(">>> After DVEXIT MOVEIT (0x%04X), FPACC (LSW NSW MSW EXP): %02X %02X %02X %02X\n", pc,
                   mem.fetch_mem(FPACC_LSW), mem.fetch_mem(FPACC_NSW), mem.fetch_mem(FPACC_MSW), mem.fetch_mem(FPACC_EXP));
            printf("    Source AUX_SYMBOL_BUF: %02X %02X %02X\n",
                   mem.fetch_mem(AUX_SYMBOL_BUF), mem.fetch_mem(AUX_SYMBOL_BUF+1), mem.fetch_mem(AUX_SYMBOL_BUF+2));
        }

        // RUN command tracing
        static int exec1_count = 0;
        // Check if we ever hit EXEC1 area
        // Symbol addresses already have +0x100, so EXEC1=0x0935 is the actual address
        if (pc >= 0x0930 && pc <= 0x0940) {
            printf("[PC=%04X near EXEC1=%04X]\n", pc, EXEC1);
        }
        if (pc == EXEC1) {
            exec1_count++;
            printf("\n>>> EXEC1[%d]: About to read input line\n", exec1_count);
        }
        static int strcp_count = 0;
        if (pc == STRCP) {
            strcp_count++;
            // HL points to string 1, DE points to string 2
            qkz80_uint16 hl = cpu.regs.HL.get_pair16();
            qkz80_uint16 de = cpu.regs.DE.get_pair16();
            if (strcp_count <= 20) {
                printf("\n>>> STRCP[%d]: HL=%04X DE=%04X\n", strcp_count, hl, de);
                printf("  HL string: cc=%02X '", mem.fetch_mem(hl));
                for (int i = 1; i <= 6 && i <= mem.fetch_mem(hl); i++) {
                    char c = mem.fetch_mem(hl + i) & 0x7F;
                    printf("%c", (c >= 32 && c < 127) ? c : '?');
                }
                printf("'\n");
                printf("  DE string: cc=%02X '", mem.fetch_mem(de));
                for (int i = 1; i <= 6 && i <= mem.fetch_mem(de); i++) {
                    char c = mem.fetch_mem(de + i) & 0x7F;
                    printf("%c", (c >= 32 && c < 127) ? c : '?');
                }
                printf("'\n");
            }
        }
        static int notend_count = 0;
        if (pc == NOTEND) {
            notend_count++;
            if (notend_count <= 5) {
                printf("\n>>> NOTEND[%d]: Comparing line numbers\n", notend_count);
                // AUX_LINENUM is at 0x17B4 based on symbol AUX_LINE
                qkz80_uint16 aux_linenum_addr = 0x17B4;
                printf("  AUX_LINENUM @ %04X: ", aux_linenum_addr);
                for (int i = 0; i < 4; i++) printf("%02X ", mem.fetch_mem(aux_linenum_addr + i));
                printf(" (current in buffer)\n");
                printf("  LINENUM_BUF @ %04X: ", LINENUM_BUF);
                for (int i = 0; i < 4; i++) printf("%02X ", mem.fetch_mem(LINENUM_BUF + i));
                printf(" (new line)\n");
            }
        }
        if (pc == CONTIN) {
            printf("\n>>> CONTIN: New line < current, keep searching\n");
        }
        static int nosame_count = 0;
        if (pc == NOSAME) {
            nosame_count++;
            printf("\n>>> NOSAME[%d]: Insert point found\n", nosame_count);
            qkz80_uint16 user_ptr = mem.fetch_mem(USER_PGM_PTR) | (mem.fetch_mem(USER_PGM_PTR+1) << 8);
            qkz80_uint16 end_ptr = mem.fetch_mem(END_PGM_PTR) | (mem.fetch_mem(END_PGM_PTR+1) << 8);
            printf("  USER_PGM_PTR = %04X, END_PGM_PTR = %04X\n", user_ptr, end_ptr);
            printf("  LINE_INP_BUF cc = %02X\n", mem.fetch_mem(LINE_INP_BUF));
            printf("  USER_PROG_BUF first 24 bytes:\n  ");
            for (int i = 0; i < 24; i++) printf("%02X ", mem.fetch_mem(USER_PROG_BUF + i));
            printf("\n");
        }
        if (pc == NOLIST) {
            printf("\n>>> NOLIST: Checking for RUN command\n");
            printf("  LINE_INP_BUF @ %04X hex: ", LINE_INP_BUF);
            for (int i = 0; i < 10; i++) {
                printf("%02X ", mem.fetch_mem(LINE_INP_BUF + i));
            }
            printf("\n  As text: '");
            for (int i = 0; i < 10; i++) {
                char c = mem.fetch_mem(LINE_INP_BUF + i);
                printf("%c", (c >= 32 && c < 127) ? c : '?');
            }
            printf("'\n");
        }
        if (pc == RUN_ENTRY) {
            printf("\n>>> RUN: Entering RUN command\n");
            printf("  USER_PGM_PTR before init: %02X %02X\n",
                   mem.fetch_mem(USER_PGM_PTR), mem.fetch_mem(USER_PGM_PTR+1));
            printf("  USER_PROG_BUF first 16 bytes:\n  ");
            for (int i = 0; i < 16; i++) printf("%02X ", mem.fetch_mem(USER_PROG_BUF + i));
            printf("\n");
        }
        if (pc == SAMLIN) {
            printf("\n>>> SAMLIN: About to execute line\n");
            qkz80_uint16 ptr = mem.fetch_mem(USER_PGM_PTR) | (mem.fetch_mem(USER_PGM_PTR+1) << 8);
            printf("  USER_PGM_PTR = %04X, first 8 bytes at ptr:\n  ", ptr);
            for (int i = 0; i < 8; i++) printf("%02X ", mem.fetch_mem(ptr + i));
            printf("\n");
        }
        static int nxtlin_count = 0;
        if (pc == NXTLIN) {
            nxtlin_count++;
            if (nxtlin_count <= 5) {
                printf("\n>>> NXTLIN[%d]: Advancing to next line\n", nxtlin_count);
            }
        }

        // Halt instruction
        if (memory[pc] == 0x76) {
            printf("\n=== HALT at 0x%04X ===\n", pc);
            break;
        }

        cpu.execute();
        instr_count++;
    }

    printf("\n\nTotal instructions: %lld\n", instr_count);
    printf("Final output: %s\n", output_buffer);

    return 0;
}
