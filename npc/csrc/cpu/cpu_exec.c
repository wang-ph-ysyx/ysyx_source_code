#include <VysyxSoCFull___024root.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <VysyxSoCFull.h>
#include "verilated.h"
#include <memory.h>
#include <config.h>
#include <nvboard.h>

VysyxSoCFull *top = NULL;
int trigger_difftest = 0;

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };
void difftest_step();
void difftest_skip_ref();
extern void (*ref_difftest_regcpy)(void *dut, uint32_t *pc, bool direction);
void reg_display();
void nvboard_update();

static void one_cycle() {
	top->clock = 0; top->eval();
	top->clock = 1; top->eval();
}

void cpu_exec(unsigned n) {
	if (top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__inst == 0x100073 || trigger_difftest) {
		printf("the program is ended.\n");
		return;
	}

	uint32_t pc = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc;
	uint32_t inst = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__inst;
	for (; n > 0; --n) {
		pc = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc;
		inst = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__inst;
		nvboard_update();
		one_cycle();
#ifdef DIFFTEST
		static int difftest = 0;
		uint32_t addr = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__lsu_awaddr;
		bool in_uart = (addr >= UART_BASE) && (addr < UART_BASE + UART_SIZE);
		bool in_clint = (addr >= CLINT_BASE) && (addr < CLINT_BASE + CLINT_SIZE);
		if ((((inst & 0x7f) == 0x23) || ((inst & 0x7f) == 0x03)) && (in_uart || in_clint)) {
			difftest_skip_ref();
		}
		if (difftest)
			difftest_step();
		difftest = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__wb_valid;
#endif
		if (inst == 0x100073 || trigger_difftest) break;
		if (pc == 0xa00002c8) break;
	}

	if (trigger_difftest) {
		reg_display();
		printf("\33[1;31mdifftest ABORT\33[1;0m at pc = %#x\n", pc);
		return;
	}
	if (!(top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__inst == 0x100073)) return;
	if (top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__my_reg__DOT__rf[10])
		printf("\33[1;31mHIT BAD TRAP\33[1;0m ");
	else printf("\33[1;32mHIT GOOD TRAP\33[1;0m ");
	printf("at pc = %#x\n", top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc);
}

void reset() {
	top->reset = 1;
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	top->reset = 0;
}
