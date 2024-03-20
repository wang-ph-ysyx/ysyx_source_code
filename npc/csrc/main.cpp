#include <Vtop.h>
#include "verilated.h"

unsigned memory[10000];

void pmem_write(unsigned addr, unsigned data) {
	int index = (addr - 0x80000000)/4;
	memory[index] = data;
}

unsigned pmem_read(unsigned addr) {
	int index = (addr - 0x80000000)/4;
	return memory[index];
}

void one_cycle(Vtop* top) {
	top->clk = 0; top->eval();
	top->clk = 1; top->eval();
}

int finish = 0;

void ebreak() {
	finish = 1;
}

int main(int argc, char **argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vtop* top = new Vtop{contextp};
	pmem_write(0x80000000, 0x00100093);
	pmem_write(0x80000004, 0x00108113);
	pmem_write(0x80000008, 0x00210093);
	pmem_write(0x8000000c, 0x00310113);
	pmem_write(0x80000010, 0x00408093);
	top->reset = 1;
	one_cycle(top);
	top->reset = 0;
	int i = 0;
	while(!finish) {
		top->inst = pmem_read(top->pc);
		one_cycle(top);
		++i;
		if (i > 4) break;
	}
	delete top;
	delete contextp;
	return 0;
}
