#include <stdint.h>
#include <stdlib.h>
#include <assert.h>

void __libc_init_array();
int main(int argc, char *argv[], char *envp[]);
extern char **environ;

void call_main(uintptr_t *args) {
	int argc = *(int *)args;
	args = (uintptr_t *)((int *)args + 1);
	char **argv = (char **)args;
	char *empty[] = {NULL };
  environ = empty;
	__libc_init_array();
  exit(main(argc, argv, empty));
  assert(0);
}
