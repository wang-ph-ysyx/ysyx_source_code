#include <VysyxSoCFull___024root.h>
#include <stdio.h>
#include <VysyxSoCFull.h>
#include "verilated.h"
#include <stdint.h>

extern VysyxSoCFull* top;

const char *regs[] = {
	"$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
	"s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
};

void reg_display() {
	uint32_t pc = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__ifu_pc;
	printf("pc\t%#x\t%d\n", pc, pc);
	for (int i = 1; i < 16; ++i) {
		uint32_t reg_val = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__my_reg__DOT__rf[i-1];
		printf("%s\t%#x\t%d\n", regs[i], reg_val, reg_val);
	}
}
