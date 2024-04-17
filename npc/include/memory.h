#ifndef __MEMORY_H__
#define __MEMORY_H__

#include <stdint.h>

#define MEM_BASE 0x80000000
#define MEM_SIZE 0x8000000

extern "C" void pmem_write(int waddr, int wdata, char wmask);
extern "C" int pmem_read(int raddr);
void init_memory();
uint8_t *guest2host(uint32_t paddr);
uint32_t host2guest(uint8_t *haddr);

#endif
