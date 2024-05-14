#include <stdint.h>
#include <stdlib.h>
#include <assert.h>

int main(int argc, char *argv[], char *envp[]);
extern char **environ;
void call_main(uintptr_t *args) {
	int argc = *(int *)args;
	args = (uintptr_t *)((int *)args + 1);
	char **argv = (char **)args;
	args = (uintptr_t *)((char **)args + argc + 1);
	char **envp = (char **)args;
  environ = envp;
  exit(main(argc, argv, envp));
  assert(0);
}
