#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>
#include <Vtop.h>
#include <Vtop___024root.h>
#include <memory.h>
#include <assert.h>
#include <config.h>

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };
extern Vtop* top;
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
  ref_difftest_memcpy(MEM_BASE, guest2host(MEM_BASE), img_size, DIFFTEST_TO_REF);
  ref_difftest_regcpy(&top->rootp->top__DOT__my_reg__DOT__rf[0], &top->pc, DIFFTEST_TO_REF);
}

static void checkregs(uint32_t *ref, uint32_t ref_pc, uint32_t pc) {
	for (int i = 0; i < 32; ++i) {
		if (ref[i] != top->rootp->top__DOT__my_reg__DOT__rf[i])
			trigger_difftest = 1;
		if (pc != ref_pc) trigger_difftest = 1;
	}
}

void difftest_step() {
	uint32_t ref_r[32];
	uint32_t ref_pc;

	static bool skip = false;
	static bool ret = false;
	if (skip) {
		ref_difftest_regcpy(&top->rootp->top__DOT__my_reg__DOT__rf[0], &top->pc, DIFFTEST_TO_REF);
		skip = false;
		ret = true;
	}
	if (is_skip_ref) {
		is_skip_ref = false;
		skip = true;
	}
	if (ret) {
		ret = false;
		return;
	}

  ref_difftest_exec(1);
  ref_difftest_regcpy(ref_r, &ref_pc, DIFFTEST_TO_DUT);

  checkregs(ref_r, ref_pc, top->pc);
}
#else
void init_difftest(char *ref_so_file, long img_size, int port) { }
#endif
