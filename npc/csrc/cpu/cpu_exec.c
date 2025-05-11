#include <stdio.h>
#include <stdint.h>
#include <Vtop.h>
#include "verilated.h"
#include <memory.h>
#include <config.h>

Vtop *top = NULL;
int trigger_difftest = 0;

void difftest_step();
void reg_display();

static void one_cycle() {
	top->clk = 0; top->eval();
	top->clk = 1; top->eval();
}

void cpu_exec(unsigned n) {
	if (top->finished || trigger_difftest) {
		printf("the program is ended.\n");
		return;
	}

	uint32_t pc = top->pc;
	for (; n > 0; --n) {
		pc = top->pc;
		one_cycle();
#ifdef DIFFTEST
		if (top->ifu_valid)
			difftest_step();
#endif
		if (top->finished || trigger_difftest) break;
	}

	if (trigger_difftest) {
		reg_display();
		printf("\33[1;31mdifftest ABORT\33[1;0m at pc = %#x\n", pc);
		return;
	}
	if (!top->finished) return;
	if (top->halt_ret)
		printf("\33[1;31mHIT BAD TRAP\33[1;0m ");
	else printf("\33[1;32mHIT GOOD TRAP\33[1;0m ");
	printf("at pc = %#x\n", top->pc);
}

void reset() {
	top->reset = 1;
	one_cycle();
	one_cycle();
	top->reset = 0;
}
