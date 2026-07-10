#ifndef __PROC_H__
#define __PROC_H__

#include <common.h>
#include <memory.h>

#define STACK_SIZE (8 * PGSIZE)
#define MAX_PAGE_RECORDS 65536

typedef struct {
  void *va;
  void *pa;
} PageRecord;

typedef union PCB {
  uint8_t stack[STACK_SIZE] PG_ALIGN;
  struct {
    Context *cp;
    AddrSpace as;
    // we do not free memory, so use `max_brk' to determine when to call _map()
    uintptr_t max_brk;
    // Pointer allocated separately to avoid growing the union into stack space.
    PageRecord *page_records;
    int nr_page_records;
    int max_page_records;
  };
} PCB;

void switch_boot_pcb();
extern PCB *current;

#endif
