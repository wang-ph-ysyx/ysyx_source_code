#include <VysyxSoCFull___024root.h>
#include <stdio.h>
#include <stdint.h>
#include <VysyxSoCFull.h>
#include "verilated.h"
#include <memory.h>
#include <config.h>

VysyxSoCFull *top = NULL;
int trigger_difftest = 0;

void difftest_step();
void reg_display();

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
	for (; n > 0; --n) {
		pc = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc;
		one_cycle();
#ifdef DIFFTEST
		static int difftest = 0;
		if (difftest)
			difftest_step();
		difftest = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__wb_valid;
#endif
		if (top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__inst == 0x100073 || trigger_difftest) break;
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
	top->reset = 0;
}
