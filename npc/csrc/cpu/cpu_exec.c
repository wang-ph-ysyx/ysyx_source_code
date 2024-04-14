#include <stdio.h>
#include <stdint.h>
#include <Vtop.h>
#include "verilated.h"
#include <memory.h>
#include <config.h>

Vtop *top = NULL;
int trigger_difftest = 0;

void difftest_step(uint32_t pc);

void one_cycle() {
	top->inst = pmem_read(top->pc);
	top->clk = 0; top->eval();
	top->clk = 1; top->eval();
}

void cpu_exec(unsigned n) {
	if (top->finished || trigger_difftest) {
		printf("the program is ended.\n");
		return;
	}

	for (; n > 0; --n) {
		one_cycle();
#ifdef DIFFTEST
		difftest_step(top->pc);
#endif
		if (top->finished || trigger_difftest) break;
	}

	if (!top->finished && !trigger_difftest) return;
	if (top->halt_ret)
		printf("\33[1;31mHIT BAD TRAP\33[1;0m ");
	else printf("\33[1;32mHIT GOOD TRAP\33[1;0m ");
	printf("at pc = %#x\n", top->pc);
}

void reset() {
	top->reset = 1;
	top->clk = 0; top->eval();
	top->clk = 1; top->eval();
	top->reset = 0;
}
