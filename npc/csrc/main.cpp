#include <Vtop.h>
#include "verilated.h"
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <memory.h>

void init_monitor(int argc, char **argv);

void one_cycle(Vtop* top) {
	top->clk = 0; top->eval();
	top->clk = 1; top->eval();
}

int main(int argc, char **argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vtop* top = new Vtop{contextp};

	init_monitor(argc, argv);

	top->reset = 1;
	one_cycle(top);
	top->reset = 0;
	while(!top->finished) {
		top->inst = pmem_read(top->pc);
		one_cycle(top);
	}
	if (top->halt_ret)
		printf("\33[1;31mHIT BAD TRAP\33[1;0m\n");
	else printf("\33[1;32mHIT GOOD TREP\33[1;0m\n");
	delete top;
	delete contextp;
	return 0;
}
