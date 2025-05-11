#include <am.h>
#include <jyd.h>
#include <klib.h>

static AddrSpace kas = {};
static void* (*pgalloc_usr)(int) = NULL;
static void (*pgfree_usr)(void*) = NULL;
static int vme_enable = 0;

static Area segments[] = {      // Kernel memory mappings
  NPC_PADDR_SPACE
};

#define USER_SPACE RANGE(0x40000000, 0x80000000)

static inline void set_satp(void *pdir) {
  uintptr_t mode = 1ul << (__riscv_xlen - 1);
  asm volatile("csrw satp, %0" : : "r"(mode | ((uintptr_t)pdir >> 12)));
}

static inline uintptr_t get_satp() {
  uintptr_t satp;
  asm volatile("csrr %0, satp" : "=r"(satp));
  return satp << 12;
}

bool vme_init(void* (*pgalloc_f)(int), void (*pgfree_f)(void*)) {
  pgalloc_usr = pgalloc_f;
  pgfree_usr = pgfree_f;

  kas.ptr = pgalloc_f(PGSIZE);

  int i;
  for (i = 0; i < LENGTH(segments); i ++) {
    void *va = segments[i].start;
    for (; va < segments[i].end; va += PGSIZE) {
      map(&kas, va, va, 0);
    }
  }

  set_satp(kas.ptr);
  vme_enable = 1;

  return true;
}

void protect(AddrSpace *as) {
  PTE *updir = (PTE*)(pgalloc_usr(PGSIZE));
  as->ptr = updir;
  as->area = USER_SPACE;
  as->pgsize = PGSIZE;
  // map kernel space
  memcpy(updir, kas.ptr, PGSIZE);
}

void unprotect(AddrSpace *as) {
}

void __am_get_cur_as(Context *c) {
  c->pdir = (vme_enable ? (void *)get_satp() : NULL);
}

void __am_switch(Context *c) {
  if (vme_enable && c->pdir != NULL) {
    set_satp(c->pdir);
  }
}

void map(AddrSpace *as, void *va, void *pa, int prot) {
	uintptr_t vpn1 = (uintptr_t)va >> 22;
	uintptr_t vpn0 = ((uintptr_t)va >> 12) & ((1 << 10) - 1);
	uint32_t *pte = (uint32_t *)(as->ptr + 4 * vpn1);
	if ((*pte & 1) == 0) {
		void *ptr1 = pgalloc_usr(PGSIZE);
		*pte = (uint32_t)ptr1 >> 2 | 1;
	}
	void *ppn = (void *)((*pte >> 10) << 12);
	uint32_t *pte_leaf = (uint32_t *)(ppn + 4 * vpn0);
	*pte_leaf = (uint32_t)pa >> 2 | 1;
}

void *maped(AddrSpace *as, void *va) {
	uintptr_t vpn1 = (uintptr_t)va >> 22;
	uintptr_t vpn0 = ((uintptr_t)va >> 12) & ((1 << 10) - 1);
	uint32_t *pte = (uint32_t *)(as->ptr + 4 * vpn1);
	if ((*pte & 1) == 0) return NULL;
	void *ppn = (void *)((*pte >> 10) << 12);
	uint32_t *pte_leaf = (uint32_t *)(ppn + 4 * vpn0);
	if ((*pte_leaf & 1) == 0) return NULL;
	return (void *)((*pte_leaf >> 10) << 12);
}

Context *ucontext(AddrSpace *as, Area kstack, void *entry) {
	Context *cp = (Context *)(kstack.end - sizeof(Context));
	cp->mepc = (uintptr_t)entry;
	cp->pdir = as->ptr;
	cp->mstatus = 1 << 7;
	cp->np = 1;
	return cp;
}
