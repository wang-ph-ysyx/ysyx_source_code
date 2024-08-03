#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>
#include <VysyxSoCFull.h>
#include <VysyxSoCFull___024root.h>
#include <memory.h>
#include <assert.h>
#include <config.h>

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };
extern VysyxSoCFull* top;
extern int trigger_difftest;

void (*ref_difftest_memcpy)(uint32_t addr, void *buf, size_t n, bool direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, uint32_t *pc, bool direction) = NULL;
void (*ref_difftest_exec)(uint64_t n) = NULL;

#ifdef DIFFTEST

static bool is_skip_ref = false;

void difftest_skip_ref() {
	is_skip_ref = true;
}

void init_difftest(char *ref_so_file, long img_size, int port) {
  assert(ref_so_file != NULL);

  void *handle;
  handle = dlopen(ref_so_file, RTLD_LAZY);
  assert(handle);

  ref_difftest_memcpy = (void (*)(uint32_t, void *, size_t, bool))dlsym(handle, "difftest_memcpy");
  assert(ref_difftest_memcpy);

  ref_difftest_regcpy = (void (*)(void *, uint32_t *, bool))dlsym(handle, "difftest_regcpy");
  assert(ref_difftest_regcpy);

  ref_difftest_exec = (void (*)(uint64_t n))dlsym(handle, "difftest_exec");
  assert(ref_difftest_exec);

  void (*ref_difftest_init)(int) = (void (*)(int))dlsym(handle, "difftest_init");
  assert(ref_difftest_init);

  ref_difftest_init(port);
  ref_difftest_memcpy(FLASH_BASE, guest2host_flash(0), img_size, DIFFTEST_TO_REF);
  ref_difftest_regcpy(&top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__my_reg__DOT__rf[0], &top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__ifu_pc, DIFFTEST_TO_REF);
}

static void checkregs(uint32_t *ref, uint32_t ref_pc, uint32_t pc) {
	for (int i = 0; i < 16; ++i) {
		if (ref[i] != top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__my_reg__DOT__rf[i])
			trigger_difftest = 1;
	}
	if (pc != ref_pc) trigger_difftest = 1;
	if (trigger_difftest) {
		printf("nemu reference\n");
		printf("pc\t%#x\n", ref_pc);
		for (int i = 0; i < 16; ++i) {
			printf("x%d\t%#x\n", i, ref[i]);
		}
	}
}

void difftest_step() {
	uint32_t ref_r[16];
	uint32_t ref_pc;

	if (is_skip_ref) {
		ref_difftest_regcpy(&top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__my_reg__DOT__rf[0], &top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__ifu_pc, DIFFTEST_TO_REF);
		is_skip_ref = false;
		return;
	}

  ref_difftest_exec(1);
  ref_difftest_regcpy(ref_r, &ref_pc, DIFFTEST_TO_DUT);

  checkregs(ref_r, ref_pc, top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__ifu_pc);
}
#else
void init_difftest(char *ref_so_file, long img_size, int port) { }
#endif
