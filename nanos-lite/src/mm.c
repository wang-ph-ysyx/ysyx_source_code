#include <memory.h>
#include <proc.h>
#include <sys/mman.h>

static void *pf = NULL;

void* new_page(size_t nr_page) {
	void *ret = pf;
	pf += nr_page * PGSIZE;
  return ret;
}

static void ensure_page_records(PCB *pcb) {
  if (pcb->page_records == NULL) {
    size_t bytes = MAX_PAGE_RECORDS * sizeof(PageRecord);
    size_t nr_pages = (bytes + PGSIZE - 1) / PGSIZE;
    pcb->page_records = (PageRecord *)new_page(nr_pages);
    pcb->max_page_records = MAX_PAGE_RECORDS;
  }
}

void record_page_map(PCB *pcb, void *va, void *pa) {
  ensure_page_records(pcb);
  for (int i = 0; i < pcb->nr_page_records; i++) {
    if (pcb->page_records[i].va == va) {
      pcb->page_records[i].pa = pa;  // update existing mapping
      return;
    }
  }
  assert(pcb->nr_page_records < pcb->max_page_records);
  pcb->page_records[pcb->nr_page_records].va = va;
  pcb->page_records[pcb->nr_page_records].pa = pa;
  pcb->nr_page_records++;
}

void *lookup_page_map(PCB *pcb, void *va) {
  if (pcb->page_records == NULL) return NULL;
  for (int i = 0; i < pcb->nr_page_records; i++) {
    if (pcb->page_records[i].va == va) return pcb->page_records[i].pa;
  }
  return NULL;
}

void clear_page_map(PCB *pcb) {
  ensure_page_records(pcb);
  pcb->nr_page_records = 0;
}

#ifdef HAS_VME
static void* pg_alloc(int n) {
	void *ret = new_page(n / PGSIZE);
	memset(ret, 0, n);
  return ret;
}
#endif

void free_page(void *p) {
  panic("not implement yet");
}

/* The brk() system call handler. */
int mm_brk(uintptr_t brk) {
	if (current->max_brk == 0) {
		current->max_brk = brk;
		void *va = (void *)ROUNDDOWN(brk, PGSIZE);
		void *pa = lookup_page_map(current, va);
		if (pa == NULL) {
			pa = new_page(1);
			map(&current->as, va, pa, PROT_WRITE | PROT_READ | PROT_EXEC);
			record_page_map(current, va, pa);
		}
	}
	for (void *va = (void*)ROUNDDOWN(current->max_brk, PGSIZE); (uintptr_t)va < ROUNDDOWN(brk, PGSIZE); va += PGSIZE) {
		void *pa = new_page(1);
		map(&current->as, va + PGSIZE, pa, PROT_WRITE | PROT_READ | PROT_EXEC);
		record_page_map(current, va + PGSIZE, pa);
	}
	if (current->max_brk < brk)
		current->max_brk = brk;
  return 0;
}

void init_mm() {
  pf = (void *)ROUNDUP(heap.start, PGSIZE);
  Log("free physical pages starting from %p", pf);

#ifdef HAS_VME
  vme_init(pg_alloc, free_page);
#endif
}
