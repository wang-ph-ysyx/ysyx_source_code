#include <common.h>

extern TOP_NAME* top;

const char *regs[] = {
	"$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
	"s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

void reg_display() {
	uint32_t pc = signal(ifu_pc);
	printf("pc\t%#x\t%d\n", pc, pc);
	for (int i = 1; i < TOTAL_REGS; ++i) {
		uint32_t reg_val = reg(i-1);
		printf("%2d:%s\t%#x\t%d\n", i, regs[i], reg_val, reg_val);
	}
}
