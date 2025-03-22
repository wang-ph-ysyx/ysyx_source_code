#ifndef __MEMORY_H__
#define __MEMORY_H__

#include <stdint.h>

#define TOTAL_MEM   5
#define MEM_BASE    0x80000000
#define MEM_SIZE    0x08000000
#define MROM_BASE   0x20000000
#define MROM_SIZE   0x1000
#define SRAM_BASE   0x0f000000
#define SRAM_SIZE   0x2000
#define FLASH_BASE  0x30000000
#define FLASH_SIZE  0x10000000
#define SDRAM_BASE  0xa0000000
#define SDRAM_SIZE  0x02000000

#ifdef __PLATFORM_ysyxsoc_
#define UART_BASE   0x10000000
#define UART_SIZE   0x00001000
#define CLINT_BASE  0x02000000
#define CLINT_SIZE  0x00010000
#elif defined(__PLATFORM_npc_)
#define UART_BASE   0xa0000048
#define UART_SIZE   0x00000008
#define CLINT_BASE  0xa00003f8
#define CLINT_SIZE  0x00000001
#endif

typedef struct {
	uint32_t start;
	uint8_t *mem;
	uint32_t size;
	char *name;
} mem_t;//与difftest一致
extern mem_t mem_arr[TOTAL_MEM];
extern uint32_t total_mem;

extern "C" void pmem_write(int waddr, int wdata, char wmask);
extern "C" int pmem_read(int raddr);
extern "C" void flash_read(int32_t addr, int32_t *data);
extern "C" void mrom_read(int32_t addr, int32_t *data);
void init_memory();
uint8_t *guest2host(uint32_t paddr);
uint32_t host2guest(uint8_t *haddr);
uint8_t *guest2host_mrom(uint32_t paddr);
uint32_t host2guest_mrom(uint8_t *haddr);
uint8_t *guest2host_flash(uint32_t paddr);
uint32_t host2guest_flash(uint8_t *haddr);

#endif
