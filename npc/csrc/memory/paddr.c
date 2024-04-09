#include <stdint.h>
#include <memory.h>

static uint8_t memory[MEM_SIZE];

uint8_t *guest2host(uint32_t paddr) {return memory + paddr - MEM_BASE;}
uint32_t host2guest(uint8_t *haddr) {return haddr - memory + MEM_BASE;}

void pmem_write(uint32_t paddr, uint32_t data) {
	uint8_t *haddr = guest2host(paddr);
	*(uint32_t *)haddr = data;
}

uint32_t pmem_read(uint32_t paddr) {
	uint8_t *haddr = guest2host(paddr);
	return *(uint32_t *)haddr;
}

void init_memory() {
	pmem_write(0x80000000, 0x00100093);
	pmem_write(0x8000000c, 0x00310113);
	pmem_write(0x80000014, 0x00100073);
}
