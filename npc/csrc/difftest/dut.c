#include <dlfcn.h>
#include <stdint.h>
#include <Vtop.h>
#include <Vtop___024root.h>
#include <memory.h>
#include <assert.h>

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };
extern Vtop* top;
extern int trigger_difftest;

void (*ref_difftest_memcpy)(uint32_t addr, void *buf, size_t n, bool direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, bool direction) = NULL;
void (*ref_difftest_exec)(uint64_t n) = NULL;

#ifdef DIFFTEST

void init_difftest(char *ref_so_file, long img_size, int port) {
  assert(ref_so_file != NULL);

  void *handle;
  handle = dlopen(ref_so_file, RTLD_LAZY);
  assert(handle);

  ref_difftest_memcpy = dlsym(handle, "difftest_memcpy");
  assert(ref_difftest_memcpy);

  ref_difftest_regcpy = dlsym(handle, "difftest_regcpy");
  assert(ref_difftest_regcpy);

  ref_difftest_exec = dlsym(handle, "difftest_exec");
  assert(ref_difftest_exec);

  ref_difftest_raise_intr = dlsym(handle, "difftest_raise_intr");
  assert(ref_difftest_raise_intr);

  void (*ref_difftest_init)(int) = dlsym(handle, "difftest_init");
  assert(ref_difftest_init);

  ref_difftest_init(port);
  ref_difftest_memcpy(MEM_BASE, guest2host(MEM_BASE), img_size, DIFFTEST_TO_REF);
  ref_difftest_regcpy(top->rootp->top__DOT__my_reg__DOT__rf, DIFFTEST_TO_REF);
}

static void checkregs(CPU_state *ref, vaddr_t pc) {
	if (pc != top->pc) trigger_difftest = 1;
	for (int i = 0; i < 32; ++i) {
		if (ref[i] != top->rootp->top__DOT__my_reg__DOT__rf[i])
			trigger_difftest = 1;
	}
}

void difftest_step(uint32_t pc) {
	int32_t ref_r[32];

  ref_difftest_exec(1);
  ref_difftest_regcpy(ref_r, DIFFTEST_TO_DUT);

  checkregs(ref_r, pc);
}
#else
void init_difftest(char *ref_so_file, long img_size, int port) { }
#endif
