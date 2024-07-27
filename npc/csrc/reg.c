#include <VysyxSoCFull___024root.h>
#include <stdio.h>
#include <VysyxSoCFull.h>
#include "verilated.h"
#include <stdint.h>

extern VysyxSoCFull* top;

const char *regs[] = {
	"$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
	"s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
	"a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7", 
	"s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

void reg_display() {
	uint32_t pc = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc;
	printf("pc\t%#x\t%d\n", pc, pc);
	for (int i = 0; i < 32; ++i) {
		uint32_t reg_val = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__my_reg__DOT__rf[i];
		printf("%s\t%#x\t%d\n", regs[i], reg_val, reg_val);
	}
	printf("lsu_rdata\t%#x\n", top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__lsu_rdata);
	printf("ifu_rdata\t%#lx\n", top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__ifu_rdata);
	printf("wb_valid\t%#x\n", top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__wb_valid);
	printf("lsu_rvalid\t%#x\n", top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__lsu_rvalid);
	printf("idu_valid\t%#x\n", top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__idu_valid);
	printf("ifu_arvalid\t%#x\n", top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__ifu_arvalid);
	printf("ifu_reading\t%#x\n", top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__my_xbar__DOT__ifu_reading);
	printf("ifu_rvalid\t%#x\n", top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__ifu_rvalid);
	printf("dnpc\t%#x\n", top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__dnpc);
	printf("inst\t0x%08x\n", top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__inst);
}
