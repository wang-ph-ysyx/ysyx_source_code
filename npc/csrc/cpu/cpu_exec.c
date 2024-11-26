#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "verilated.h"
#include <memory.h>
#include <config.h>
#include <nvboard.h>
#include "verilated_vcd_c.h"

#if defined(__PLATFORM_ysyxsoc_)
#include <VysyxSoCFull___024root.h>
#include <VysyxSoCFull.h>
#define signal(s) ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__##s
#elif defined(__PLATFORM_npc_)
#include <Vnpc___024root.h>
#include <Vnpc.h>
#define signal(s) npc__DOT__cpu__DOT__##s
#endif

#define TOTAL_COUNTER(_) \
	_(total_cycle) _(total_inst)
#define PERFORMANCE_COUNTER(_) \
 	_(ifu_getinst) _(ifu_readingcycle) \
	_(lsu_getdata) _(lsu_readingcycle) _(lsu_writedata) _(lsu_writingcycle)
#define CACHE_PERFORMANCE(_) \
	_(hit_icache) _(miss_icache) _(tmt)
#define PIPELINE_PERFORMANCE(_) \
	_(raw_conflict_cycle) _(raw_conflict) \
	_(jump_wrong_cycle) _(jump_wrong)
#define MULDIV_PERFORMANCE(_) \
	_(div_cycle) _(mul_cycle)
#define TLB_PERFORMANCE(_) \
	_(hit_tlb) _(miss_tlb)

#define DECLARE_COUNTER(counter) \
	static long counter = 0; \
	extern "C" void add_##counter() { ++counter; }

#define PRINT_COUNTER(counter) \
	printf("counter: %ld\n", counter); \

TOP_NAME *top = NULL;
VerilatedVcdC *tfp = NULL;
VerilatedContext *contextp = NULL;
int trigger_difftest = 0;
extern int wave_trace;

static int lsu_awaddr = 0;
static int inst_ebreak = 0;

TOTAL_COUNTER(DECLARE_COUNTER)
PERFORMANCE_COUNTER(DECLARE_COUNTER)
CACHE_PERFORMANCE(DECLARE_COUNTER)
PIPELINE_PERFORMANCE(DECLARE_COUNTER)
MULDIV_PERFORMANCE(DECLARE_COUNTER)
TLB_PERFORMANCE(DECLARE_COUNTER)

extern "C" void record_lsu_awaddr(int awaddr) { lsu_awaddr = awaddr; }
extern "C" void program_end() { inst_ebreak = 1; }

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };
void difftest_step();
void difftest_skip_ref();
extern void (*ref_difftest_regcpy)(void *dut, uint32_t *pc, bool direction);
void reg_display();
void nvboard_update();
void print_difftest_reg();

void print_statistic() {
	printf("\ntotal counter\n");
	TOTAL_COUNTER(PRINT_COUNTER)
	printf("IPC: %f\n", (double)total_inst / total_cycle);

	printf("\nperformance counter:\n");
	PERFORMANCE_COUNTER(PRINT_COUNTER)
	printf("average ifu reading delay: %f\n", (double)ifu_readingcycle / ifu_getinst);
	printf("average lsu reading delay: %f\n", (double)lsu_readingcycle / lsu_getdata);
	printf("average lsu writing delay: %f\n", (double)lsu_writingcycle / lsu_writedata);

	printf("\ncache performance:\n");
	CACHE_PERFORMANCE(PRINT_COUNTER)
	printf("hit rate: %f\n", (double)hit_icache / (hit_icache + miss_icache));
	printf("average miss time: %f\n", (double)tmt / miss_icache);

	printf("\npipeline performance:\n");
	PIPELINE_PERFORMANCE(PRINT_COUNTER)
	printf("average raw conflict penalty: %f\n", (double)raw_conflict_cycle / raw_conflict);
	printf("average jump wrong penalty: %f\n", (double)jump_wrong_cycle / jump_wrong);

	printf("\nmul/div performance:\n");
	MULDIV_PERFORMANCE(PRINT_COUNTER)

	printf("\ntlb performance:\n");
	TLB_PERFORMANCE(PRINT_COUNTER)
	printf("tlb hit rate: %f\n", (double)hit_tlb / (hit_tlb + miss_tlb));

	printf("\n");
}

static void one_cycle() {
	top->clock = 0; top->eval(); 
#ifdef WAVE_TRACE
	if (wave_trace) { tfp->dump(contextp->time()); contextp->timeInc(1); }
#endif
	top->clock = 1; top->eval(); 
#ifdef WAVE_TRACE
	if (wave_trace) { tfp->dump(contextp->time()); contextp->timeInc(1); }
#endif
}

void reset() {
	top->reset = 1;
	for (int i = 0; i < 10; ++i)
		one_cycle();
	top->reset = 0;
}

void cpu_exec(unsigned long n) {
	if (inst_ebreak || trigger_difftest) {
		printf("the program is ended.\n");
		return;
	}

	uint32_t pc = top->rootp->signal(ifu_pc);
	uint32_t inst = top->rootp->signal(inst);
	for (; n > 0; --n) {
		pc = top->rootp->signal(ifu_pc);
		inst = top->rootp->signal(inst);
		nvboard_update();
		one_cycle();
#ifdef DIFFTEST
		static int difftest = 0;
		bool in_uart = (lsu_awaddr >= UART_BASE) && (lsu_awaddr < UART_BASE + UART_SIZE);
		bool in_clint = (lsu_awaddr >= CLINT_BASE) && (lsu_awaddr < CLINT_BASE + CLINT_SIZE);
		if (in_uart || in_clint) difftest_skip_ref();
		if (difftest) {
			difftest_step();
		}
		difftest = top->rootp->signal(wb_valid);
#endif
		if (inst_ebreak || trigger_difftest) break;
	}

	if (trigger_difftest) {
		reg_display();
		printf("\33[1;31mdifftest ABORT\33[1;0m at pc = %#x\n", pc);
		return;
	}
	if (!inst_ebreak) return;
	if (top->rootp->signal(my_reg__DOT__rf[9]))
		printf("\33[1;31mHIT BAD TRAP\33[1;0m ");
	else printf("\33[1;32mHIT GOOD TRAP\33[1;0m ");
	printf("at pc = %#x\n", top->rootp->signal(ifu_pc));
#ifdef PRINT_PERF
	print_statistic();
#endif
}
