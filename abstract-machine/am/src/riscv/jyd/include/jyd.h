#ifndef NPC_H__
#define NPC_H__

#include <klib-macros.h>

#include "riscv/riscv.h"

# define DEVICE_BASE 0xa0000000

#define MMIO_BASE 0xa0000000

#define GPIO_SW_ADDR  0xf000
#define GPIO_KEY_ADDR 0xf010
#define GPIO_SEG_ADDR 0xf020
#define GPIO_LED_ADDR 0xf040

extern char _pmem_start;
#define PMEM_SIZE (128 * 1024 * 1024)
#define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)
#define NPC_PADDR_SPACE \
  RANGE(&_pmem_start, PMEM_END)

typedef uintptr_t PTE;

#define PGSIZE    4096

#endif
