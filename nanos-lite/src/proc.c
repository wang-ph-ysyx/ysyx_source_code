#include <proc.h>

#define MAX_NR_PROC 4

static PCB pcb[MAX_NR_PROC] __attribute__((used)) = {};
static PCB pcb_boot = {};
PCB *current = NULL;

int fg_pcb = 1;

void context_uload(PCB *_pcb, const char *filename, char *const argv[], char *const envp[]);
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
	char *argv0[] = {"/bin/hello", NULL}, *envp0[] = {NULL};
	context_uload(&pcb[0], "/bin/hello", argv0, envp0);
/*
	char *argv1[] = {"/bin/bird", NULL}, *envp1[] = {NULL};
	context_uload(&pcb[1], "/bin/bird", argv1, envp1);

	char *argv2[] = {"/bin/pal", "--skip", NULL}, *envp2[] = {NULL};
	context_uload(&pcb[2], "/bin/pal", argv2, envp2);

	char *argv3[] = {"/bin/nslider", NULL}, *envp3[] = {NULL};
	context_uload(&pcb[3], "/bin/nslider", argv3, envp3);
*/
  switch_boot_pcb();

  Log("Initializing processes...");

	//naive_uload(NULL, "/bin/menu");
  // load program here

}

Context* schedule(Context *prev) {
	current->cp = prev;
	current = &pcb[0];
/*
	static int count = 0;
	if (current != &pcb[fg_pcb]) {
		current = &pcb[fg_pcb];
	}
	else {
		if (count == 100) {
			current = &pcb[0];
			count = 0;
		}
		++count;
	}
*/
  return current->cp;
}
