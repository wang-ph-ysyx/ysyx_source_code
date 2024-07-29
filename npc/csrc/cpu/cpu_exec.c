#include <VysyxSoCFull___024root.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <VysyxSoCFull.h>
#include "verilated.h"
#include <memory.h>
#include <config.h>
#include <nvboard.h>
#include "verilated_vcd_c.h"

VysyxSoCFull *top = NULL;
VerilatedVcdC *tfp = NULL;
VerilatedContext *contextp = NULL;
int trigger_difftest = 0;

//performance register
static long total_inst = 0;
static long total_cycle = 0;
static long total_lsu_getdata = 0;
static long total_lsu_writedata = 0;
static long total_ifu_getinst = 0;
static long total_lsu_readingcycle = 0;
static long total_lsu_writingcycle = 0;
static long total_ifu_readingcycle = 0;
static long hit_icache = 0;
static long miss_icache = 0;
static long tmt = 0;
static int lsu_awaddr = 0;

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };
void difftest_step();
void difftest_skip_ref();
extern void (*ref_difftest_regcpy)(void *dut, uint32_t *pc, bool direction);
void reg_display();
void nvboard_update();

void print_statistic() {
	printf("\ntotal_cycle: %ld\ntotal_inst: %ld\n", total_cycle, total_inst);
	printf("IPC: %f\n", (double)total_inst / total_cycle);
	printf("\nperformance counter:\n");
	printf("total_ifu_getinst: %ld\n", total_ifu_getinst);
	printf("total_ifu_readingcycle: %ld\n", total_ifu_readingcycle);
	printf("average ifu reading delay: %f\n", (double)total_ifu_readingcycle / total_ifu_getinst);
	printf("total_lsu_getdata: %ld\n", total_lsu_getdata);
	printf("total_lsu_readingcycle: %ld\n", total_lsu_readingcycle);
	printf("average lsu reading delay: %f\n", (double)total_lsu_readingcycle / total_lsu_getdata);
	printf("total_lsu_writedata: %ld\n", total_lsu_writedata);
	printf("total_lsu_writingcycle: %ld\n", total_lsu_writingcycle);
	printf("average lsu writing delay: %f\n", (double)total_lsu_writingcycle / total_lsu_writedata);
	printf("hit_icache: %ld\nmiss_icache: %ld\n", hit_icache, miss_icache);
	printf("hit rate: %f\n", (double)hit_icache / (hit_icache + miss_icache));
	printf("TMT: %ld\n", tmt);
	printf("\n");
}

extern "C" void add_total_inst() { ++total_inst; }
extern "C" void add_total_cycle() { ++total_cycle; }
extern "C" void add_lsu_getdata() { ++total_lsu_getdata; }
extern "C" void add_lsu_writedata() { ++total_lsu_writedata; }
extern "C" void add_ifu_getinst() { ++total_ifu_getinst; }
extern "C" void add_lsu_readingcycle() { ++total_lsu_readingcycle; }
extern "C" void add_lsu_writingcycle() { ++total_lsu_writingcycle; }
extern "C" void add_ifu_readingcycle() { ++total_ifu_readingcycle; }
extern "C" void add_hit_icache() { ++hit_icache; }
extern "C" void add_miss_icache() { ++miss_icache; }
extern "C" void add_tmt() { ++tmt; }
extern "C" void record_lsu_awaddr(int awaddr) { lsu_awaddr = awaddr; }

static void one_cycle() {
	top->clock = 0; top->eval(); 
#ifdef WAVE_TRACE
	tfp->dump(contextp->time()); contextp->timeInc(1);
#endif
	top->clock = 1; top->eval(); 
#ifdef WAVE_TRACE
	tfp->dump(contextp->time()); contextp->timeInc(1);
#endif
}

void cpu_exec(unsigned long n) {
	if (top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__inst == 0x100073 || trigger_difftest) {
		printf("the program is ended.\n");
		return;
	}

	uint32_t pc = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc;
	uint32_t inst = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__inst;
	for (; n > 0; --n) {
		pc = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc;
		inst = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__inst;
		nvboard_update();
		one_cycle();
#ifdef DIFFTEST
		static int difftest = 0;
		bool in_uart = (lsu_awaddr >= UART_BASE) && (lsu_awaddr < UART_BASE + UART_SIZE);
		bool in_clint = (lsu_awaddr >= CLINT_BASE) && (lsu_awaddr < CLINT_BASE + CLINT_SIZE);
		if ((((inst & 0x7f) == 0x23) || ((inst & 0x7f) == 0x03)) && (in_uart || in_clint)) {
			difftest_skip_ref();
		}
		if (difftest)
			difftest_step();
		difftest = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__wb_valid;
#endif
		if (inst == 0x100073 || trigger_difftest) break;
	}

	if (trigger_difftest) {
		reg_display();
		printf("\33[1;31mdifftest ABORT\33[1;0m at pc = %#x\n", pc);
		return;
	}
	if (!(top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__inst == 0x100073)) return;
	if (top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__my_reg__DOT__rf[10])
		printf("\33[1;31mHIT BAD TRAP\33[1;0m ");
	else printf("\33[1;32mHIT GOOD TRAP\33[1;0m ");
	printf("at pc = %#x\n", top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc);
	print_statistic();
}

void reset() {
	top->reset = 1;
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	one_cycle();
	top->reset = 0;
}
