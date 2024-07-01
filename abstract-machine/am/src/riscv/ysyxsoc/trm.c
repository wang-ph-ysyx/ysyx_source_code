#include <am.h>
#include <klib-macros.h>

#define SERIAL_PORT 0x10000000
static inline void outb(uintptr_t addr, uint8_t data) { *(volatile uint8_t *)addr = data; }

int main(const char *args);

Area heap = RANGE(0x0f000007, 0x0f001000);
#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

void putch(char ch) {
	outb(SERIAL_PORT, ch);
}

void halt(int code) {
	asm volatile ("mv a0,%0; ebreak" : :"r"(code));

	while(1);
}

void _trm_init() {
	int ret = main(mainargs);
	halt(ret);
}
