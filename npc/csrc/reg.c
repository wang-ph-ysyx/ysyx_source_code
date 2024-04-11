#include <Vtop___024root.h>
#include <stdio.h>
#include <Vtop.h>
#include "verilated.h"
#include <stdint.h>

extern Vtop* top;

const char *regs[] = {
	"$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
	"s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
	"a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7", 
	"s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

void reg_display() {
	printf("pc\t%#x\t%d\n", top->pc, top->pc);
	for (int i = 0; i < 32; ++i) {
		printf("%s\t%#x\t%d\n", regs[i], top->rootp->top__DOT__my_reg__DOT__rf[i], top->rootp->top__DOT__my_reg__DOT__rf[i]);
	}
}
