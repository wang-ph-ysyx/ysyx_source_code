#include <am.h>
#include <klib-macros.h>
#include <klib.h>

#define SERIAL_PORT 0x10000000
static inline void outb(uintptr_t addr, uint8_t data) { *(volatile uint8_t *)addr = data; }

int main(const char *args);

Area heap = RANGE(0x0f000000, 0x0f001000);
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

extern char _data_start [];
extern char data_load_start [];
extern char _bss_start [];

void _trm_init() {
	//outb(SERIAL_PORT + 3, 0x80);
	outb(SERIAL_PORT + 8, 1);
	memcpy(_data_start, data_load_start, (size_t) (_bss_start - _data_start));
	int ret = main(mainargs);
	halt(ret);
}
