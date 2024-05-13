#include <proc.h>

#define MAX_NR_PROC 4

static PCB pcb[MAX_NR_PROC] __attribute__((used)) = {};
static PCB pcb_boot = {};
PCB *current = NULL;

void naive_uload(PCB *pcb, const char *filename);

void switch_boot_pcb() {
  current = &pcb_boot;
}

void hello_fun(void *arg) {
  int j = 1;
  while (1) {
    Log("Hello World from Nanos-lite with arg '%p' for the %dth time!", (uintptr_t)arg, j);
    j ++;
    yield();
  }
}

void context_kload(PCB *_pcb, void (*entry)(void *), void *arg) {
	_pcb->cp = kcontext((Area) {_pcb->stack, _pcb->stack + STACK_SIZE}, hello_fun, arg);
}

void init_proc() {
	context_kload(&pcb[0], hello_fun, (void *)11L);
	context_kload(&pcb[1], hello_fun, (void *)22L);
  switch_boot_pcb();

  Log("Initializing processes...");

	naive_uload(NULL, "/bin/menu");
  // load program here

}

Context* schedule(Context *prev) {
	current->cp = prev;
	current = (current == &pcb[0] ? &pcb[1] : &pcb[0]);
  return current->cp;
}
