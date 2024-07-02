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
extern char _data_end [];
extern char data_load_start [];
extern char _bss_start [];
extern char _bss_end [];
extern char bss_load_start [];

void _trm_init() {
	memcpy(_data_start, data_load_start, (size_t) (_data_end - _data_start));
	memcpy(_bss_start, bss_load_start, (size_t) (_bss_end - _bss_start));
	int ret = main(mainargs);
	halt(ret);
}
