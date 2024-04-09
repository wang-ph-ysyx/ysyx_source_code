#include <Vtop.h>
#include "verilated.h"
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <memory.h>

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
	int ret = fread(guest2host(MEM_BASE), size, 1, fp);
	assert(ret == 1);

	fclose(fp);
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
		printf("\33[1;31mHIT BAD TRAP\33[1;0m\n");
	else printf("\33[1;32mHIT GOOD TREP\33[1;0m\n");
	delete top;
	delete contextp;
	return 0;
}
