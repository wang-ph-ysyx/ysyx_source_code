#include <memory.h>
#include <stdio.h>
#include <time.h>
#include <config.h>
#include <assert.h>

#define SERIAL    0xa00003f8
#define RTC       0xa0000048

static uint8_t memory[MEM_SIZE];
static uint8_t flash[FLASH_SIZE];

uint8_t *guest2host(uint32_t paddr) {return memory + paddr - MEM_BASE;}
uint32_t host2guest(uint8_t *haddr) {return haddr - memory + MEM_BASE;}
uint8_t *guest2host_mrom(uint32_t paddr) {return memory + paddr - MROM_BASE;}
uint32_t host2guest_mrom(uint8_t *haddr) {return haddr - memory + MROM_BASE;}
uint8_t *guest2host_flash(uint32_t paddr) {return flash + paddr - FLASH_BASE;}
uint32_t host2guest_flash(uint8_t *haddr) {return haddr - flash + FLASH_BASE;}
void difftest_skip_ref();
void reg_display();

extern "C" void flash_read(int32_t addr, int32_t *data) {
	uint8_t *haddr = guest2host_flash(addr);
	*data = *(int32_t *)haddr;
}
extern "C" void mrom_read(int32_t addr, int32_t *data) {
	uint8_t *haddr = guest2host_mrom(addr);
	*data = *(int32_t *)haddr;
}

extern "C" void pmem_write(int waddr, int wdata, char wmask) {
	uint8_t *haddr = guest2host(waddr/* & ~0x3u*/);
	if (wmask & 0x1) haddr[0] = wdata & 0xff;
	if (wmask & 0x2) haddr[1] = (wdata >> 8) & 0xff;
	if (wmask & 0x4) haddr[2] = (wdata >> 16) & 0xff;
	if (wmask & 0x8) haddr[3] = (wdata >> 24) & 0xff;
}

extern "C" int pmem_read(int raddr) {
	if (raddr == RTC || raddr == RTC + 4) {
		static clock_t start_time;
		static int time_start = 0;
		if (!time_start) {
			start_time = clock();
			time_start = 1;
		}
		clock_t time = clock();
		long total = time - start_time;
#ifdef DIFFTEST
		difftest_skip_ref();
#endif
		if (raddr == RTC + 4) return (int)(total >> 32);
		else return (int) total;
	}
	uint8_t *haddr = guest2host(raddr/* & ~0x3u*/);
	if (!(haddr >= memory && haddr <= memory + MEM_SIZE)) {
		printf("\nread out of bound\n\n");
		reg_display();
	}
	return *(int *)haddr;
}

void init_memory() {
	*(uint32_t *)(memory + 0x0)  = 0x100007b7;
	*(uint32_t *)(memory + 0x4)  = 0x04100713;
	*(uint32_t *)(memory + 0x8)  = 0x00e78023;
	*(uint32_t *)(memory + 0xc)  = 0x00a00713;
	*(uint32_t *)(memory + 0x10) = 0x00e78023;
	*(uint32_t *)(memory + 0x14) = 0x0000006f;
	for (int i = 0; i < 1000; ++i) {
		flash[i] = (uint8_t)(i & 0xff);
	}
}
