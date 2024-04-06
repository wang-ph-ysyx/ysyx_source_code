#include <Vtop.h>
#include "verilated.h"
#include <stdint.h>
#include <stdio.h>
#include <assert.h>

#define MEM_BASE 0x80000000
#define MEM_SIZE 0x8000000

static uint8_t memory[MEM_SIZE];

void pmem_write(uint32_t addr, uint32_t data) {
	uint32_t index = addr - MEM_BASE;
	*(uint32_t *)(memory + index) = data;
}

unsigned pmem_read(uint32_t addr) {
	uint32_t index = addr - MEM_BASE;
	return *(uint32_t *)(memory + index);
}

void load_img(char *img_file) {
	if (img_file == NULL) {
		printf("No image is given. Use the default build-in image.\n");
		return;
	}

	FILE *fp = fopen(img_file, "rb");
	assert(fp);

	fseek(fp, 0, SEEK_END);
	long size = ftell(fp);

	fseek(fp, 0, SEEK_SET);
	int ret = fread(memory, size, 1, fp);
	assert(ret == 1);

	fclose(fp);
}

void init_memory() {
	pmem_write(0x80000000, 0x00100093);
	pmem_write(0x80000004, 0x00108113);
	pmem_write(0x80000008, 0x00210093);
	pmem_write(0x8000000c, 0x00310113);
	pmem_write(0x80000010, 0x00408093);
	pmem_write(0x80000014, 0x00100073);
	pmem_write(0x80000100, 0x00100073);
}

void one_cycle(Vtop* top) {
	top->clk = 0; top->eval();
	top->clk = 1; top->eval();
}

int main(int argc, char **argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vtop* top = new Vtop{contextp};

	init_memory();
	char *img_file = argc > 0 ? argv[1] : NULL;
	load_img(img_file);

	top->reset = 1;
	one_cycle(top);
	top->reset = 0;
	while(!top->finished) {
		top->inst = pmem_read(top->pc);
		one_cycle(top);
	}
	if (top->halt_ret)
		printf("\33[1;41mHIT BAD TRAP\n");
	else printf("\33[1;42mHIT GOOD TREP\n");
	delete top;
	delete contextp;
	return 0;
}
