#include <memory.h>
#include <stdio.h>
#include <time.h>

#define SERIAL 0xa00003f8
#define RTC    0xa0000048

static clock_t start_time;
static int time_start = 0;

static uint8_t memory[MEM_SIZE];

uint8_t *guest2host(uint32_t paddr) {return memory + paddr - MEM_BASE;}
uint32_t host2guest(uint8_t *haddr) {return haddr - memory + MEM_BASE;}

extern "C" void pmem_write(int waddr, int wdata, char wmask) {
	if (waddr == SERIAL) {
		if (!(wmask & 0x1)) wdata = wdata & ~0xff;
		if (!(wmask & 0x2)) wdata = wdata & ~0xff00;
		if (!(wmask & 0x4)) wdata = wdata & ~0xff0000;
		if (!(wmask & 0x8)) wdata = wdata & ~0xff000000;
		putc(wdata, stderr);
		return;
	}
	uint8_t *haddr = guest2host(waddr/* & ~0x3u*/);
	if (wmask & 0x1) haddr[0] = wdata & 0xff;
	if (wmask & 0x2) haddr[1] = (wdata >> 8) & 0xff;
	if (wmask & 0x4) haddr[2] = (wdata >> 16) & 0xff;
	if (wmask & 0x8) haddr[3] = (wdata >> 24) & 0xff;
}

extern "C" int pmem_read(int raddr) {
	if (raddr == RTC || raddr == RTC + 4) {
		if (!time_start) {
			start_time = clock();
			time_start = 1;
		}
		clock_t time = clock();
		long total = time - start_time;
		if (raddr == RTC + 4) return (int)(total >> 32);
		else return (int) total;
	}
	uint8_t *haddr = guest2host(raddr/* & ~0x3u*/);
	return *(int *)haddr;
}

void init_memory() {
	pmem_write(0x80000000, 0x00100093, 0xf);
	pmem_write(0x80000004, 0x00100093, 0xf);
	pmem_write(0x80000008, 0x00100093, 0xf);
	pmem_write(0x8000000c, 0x00310113, 0xf);
	pmem_write(0x80000014, 0x00100073, 0xf);
}
