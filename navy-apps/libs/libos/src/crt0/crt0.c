#include <stdint.h>
#include <stdlib.h>
#include <assert.h>

int main(int argc, char *argv[], char *envp[]);
extern char **environ;
void call_main(uintptr_t *args) {
	argc = *(int *)args;
	args = (uintptr_t *)((int *)args + 1);
	argv = (char **)args;
	args = (uintptr_t)((char **)args + argc + 1);
	envp = (char **)envp;
  environ = envp;
  exit(main(0, empty, empty));
  assert(0);
}
