#ifndef __MEMORY_H__
#define __MEMORY_H__

#define MEM_BASE 0x80000000
#define MEM_SIZE 0x8000000

void pmem_write(uint32_t addr, uint32_t data);
uint32_t pmem_read(uint32_t addr);
void init_memory();
uint8_t *guest2host(uint32_t paddr);
uint32_t host2guest(uint8_t *haddr);

#endif
