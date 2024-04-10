#include <Vtop___024root.h>
#include <Vtop.h>
#include "verilated.h"
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <memory.h>

Vtop* top = NULL;

void init_monitor(int argc, char **argv);
void sdb_mainloop();

void one_cycle() {
	top->inst = pmem_read(top->pc);
	top->clk = 0; top->eval();
	top->clk = 1; top->eval();
	printf("%d\n", top->rootp->top__DOT__my_reg__DOT__rf[1]);
}

void cpu_exec(unsigned n) {
	if (top->finished) {
		printf("the program is ended.\n");
		return;
	}

	for (; n > 0; --n) {
		one_cycle();
		if (top->finished) break;
	}

	if (!top->finished) return;
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

int main(int argc, char **argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new Vtop{contextp};

	reset();


	init_monitor(argc, argv);

	sdb_mainloop();

	delete top;
	delete contextp;
	return 0;
}
