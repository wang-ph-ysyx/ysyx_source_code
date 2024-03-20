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

int main(int argc, char **argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vtop* top = new Vtop{contextp};
	pmem_write(0x80000000, 0x00000093);
	pmem_write(0x80000004, 0x00108093);
	pmem_write(0x80000008, 0x00108093);
	top->reset = 1;
	one_cycle(top);
	top->reset = 0;
	int i = 0;
	while(!contextp->gotFinish()) {
		top->inst = pmem_read(top->pc);
		one_cycle(top);
		printf("src1:%d, R[rd]:%d, imm:%d\n", top->src1, top->val, top->imm);
		++i;
		if (i > 2) break;
	}
	delete top;
	delete contextp;
	return 0;
}
