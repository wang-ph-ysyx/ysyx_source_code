#ifndef __MEMORY_H__
#define __MEMORY_H__

#include <common.h>

#ifndef PGSIZE
#define PGSIZE 4096
#endif

#define PG_ALIGN __attribute((aligned(PGSIZE)))

typedef union PCB PCB;

void* new_page(size_t);

void  record_page_map(PCB *pcb, void *va, void *pa);
void *lookup_page_map(PCB *pcb, void *va);
void  clear_page_map(PCB *pcb);

#endif
