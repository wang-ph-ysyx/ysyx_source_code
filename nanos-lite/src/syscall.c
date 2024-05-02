#include <common.h>
#include "syscall.h"
#include <stdio.h>

void do_syscall(Context *c) {
  uintptr_t a[4];
  a[0] = c->GPR1;
	a[1] = c->GPR2;
	a[2] = c->GPR3;
	a[3] = c->GPR4;

	printf("cause: %d, args: %d %d %d\n", a[0], a[1], a[2], a[3]);

  switch (a[0]) {
		case 0: halt(a[1]);
		case 1: yield(); c->GPRx = 0; break;
    default: panic("Unhandled syscall ID = %d", a[0]);
  }
}
