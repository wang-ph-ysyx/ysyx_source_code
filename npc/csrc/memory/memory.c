#include <memory.h>
#include <stdio.h>

static uint8_t memory[MEM_SIZE];

uint8_t *guest2host(uint32_t paddr) {return memory + paddr - MEM_BASE;}
uint32_t host2guest(uint8_t *haddr) {return haddr - memory + MEM_BASE;}

extern "C" void pmem_write(int waddr, int wdata, char wmask) {
	uint8_t *haddr = guest2host(waddr & ~0x3u);
	if (wmask & 0x1) haddr[0] = wdata & 0xff;
	if (wmask & 0x2) haddr[1] = (wdata >> 8) & 0xff;
	if (wmask & 0x4) haddr[2] = (wdata >> 16) & 0xff;
	if (wmask & 0x8) haddr[3] = (wdata >> 24) & 0xff;
}

extern "C" int pmem_read(int raddr) {
	uint8_t *haddr = guest2host(raddr & ~0x3u);
	printf("%x\t%#x\n", *(int *)haddr, raddr);
	return *(int *)haddr;
}

void init_memory() {
	pmem_write(0x80000000, 0x00100093, 0xf);
	pmem_write(0x80000004, 0x00100093, 0xf);
	pmem_write(0x80000008, 0x00100093, 0xf);
	pmem_write(0x8000000c, 0x00310113, 0xf);
	pmem_write(0x80000014, 0x00100073, 0xf);
}
