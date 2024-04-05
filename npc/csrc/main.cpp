#include <Vtop.h>
#include "verilated.h"
#include <stdint.h>

#define MEM_BASE 0x80000000

uint8_t memory[10000];

void pmem_write(uint32_t addr, uint32_t data) {
	uint32_t index = addr - MEM_BASE;
	*(uint32_t *)(memory + index) = data;
}

unsigned pmem_read(uint32_t addr) {
	uint32_t index = addr - MEM_BASE;
	return *(uint32_t *)(memory + index);
}

void one_cycle(Vtop* top) {
	top->clk = 0; top->eval();
	top->clk = 1; top->eval();
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
	pmem_write(0x80000014, 0x00100073);
	top->reset = 1;
	one_cycle(top);
	top->reset = 0;
	while(!top->finished) {
		top->inst = pmem_read(top->pc);
		one_cycle(top);
	}
	delete top;
	delete contextp;
	return 0;
}
