#include <proc.h>
#include <elf.h>
#include <memory.h>
#include <sys/mman.h>
#include <fs.h>

#ifdef __LP64__
# define Elf_Ehdr Elf64_Ehdr
# define Elf_Phdr Elf64_Phdr
#else
# define Elf_Ehdr Elf32_Ehdr
# define Elf_Phdr Elf32_Phdr
#endif

#if defined(__ISA_AM_NATIVE__)
# define EXPECT_TYPE EM_X86_64
#elif defined(__ISA_X86__)
# define EXPECT_TYPE EM_X86_64
#elif defined(__ISA_RISCV32__)
# define EXPECT_TYPE EM_RISCV
#else
# error Unsupported ISA
#endif

int fs_open(const char *pathname, int flags, int mode);
size_t fs_read(int fd, void *buf, size_t len);
size_t fs_write(int fd, const void *buf, size_t len);
size_t fs_lseek(int fd, size_t offset, int whence);
int fs_close(int fd);

static uintptr_t loader(PCB *pcb, const char *filename) {
	int fd = fs_open(filename, 0, 0);

	fs_lseek(fd, 0, SEEK_SET);
  Elf_Ehdr ehdr;
	fs_read(fd, &ehdr, sizeof(Elf_Ehdr));

	assert(*(uint32_t *)ehdr.e_ident == 0x464c457f);
	assert(ehdr.e_machine == EXPECT_TYPE);

	fs_lseek(fd, ehdr.e_phoff, SEEK_SET);
	Elf_Phdr phdr[ehdr.e_phnum];
	fs_read(fd, &phdr, ehdr.e_phnum * sizeof(Elf_Phdr));

	for (int i = 0; i < ehdr.e_phnum; ++i) {
		if (phdr[i].p_type == PT_LOAD) {
			void *va = (void *)phdr[i].p_vaddr;
			void *va_start = (void *)ROUNDDOWN(va, PGSIZE);
			void *va_file_end = va + phdr[i].p_filesz;
			void *va_end = va + phdr[i].p_memsz;
			fs_lseek(fd, phdr[i].p_offset, SEEK_SET);

			// ===== Phase 1: load file data [va, va_file_end) =====
			void *pa = lookup_page_map(pcb, va_start);
			if (pa == NULL) {
				pa = new_page(1);
				map(&pcb->as, va_start, pa, PROT_EXEC | PROT_READ | PROT_WRITE);
				record_page_map(pcb, va_start, pa);
			}
			// first page: file data starts at offset (va - va_start)
			size_t first_file_len = (va_file_end < va_start + PGSIZE)
				? (va_file_end - va)
				: (PGSIZE - (va - va_start));
			fs_read(fd, pa + (va - va_start), first_file_len);

			// middle pages: entirely filled with file data
			void *va_cur;
			for (va_cur = va_start + PGSIZE;
			     va_cur + PGSIZE <= va_file_end;
			     va_cur += PGSIZE) {
				pa = new_page(1);
				map(&pcb->as, va_cur, pa, PROT_EXEC | PROT_READ | PROT_WRITE);
				record_page_map(pcb, va_cur, pa);
				fs_read(fd, pa, PGSIZE);
			}
			// last page with file data (partial)
			if (va_cur < va_file_end) {
				pa = lookup_page_map(pcb, va_cur);
				if (pa == NULL) {
					pa = new_page(1);
					map(&pcb->as, va_cur, pa, PROT_EXEC | PROT_READ | PROT_WRITE);
					record_page_map(pcb, va_cur, pa);
				}
				fs_read(fd, pa, va_file_end - va_cur);
			}

			// ===== Phase 2: zero BSS [va_file_end, va_end) =====
			if (va_file_end < va_end) {
				// page that contains va_file_end (may already have file data)
				void *bss_page = (void *)ROUNDDOWN(va_file_end, PGSIZE);
				pa = lookup_page_map(pcb, bss_page);
				if (pa == NULL) {
					pa = new_page(1);
					map(&pcb->as, bss_page, pa, PROT_EXEC | PROT_READ | PROT_WRITE);
					record_page_map(pcb, bss_page, pa);
				}
				size_t bss_offset = (uintptr_t)va_file_end - (uintptr_t)bss_page;
				size_t bss_len = ((uintptr_t)va_end < (uintptr_t)bss_page + PGSIZE)
					? ((uintptr_t)va_end - (uintptr_t)va_file_end)
					: (PGSIZE - bss_offset);
				memset(pa + bss_offset, 0, bss_len);

				// middle BSS pages (entire page is BSS)
				for (va_cur = (void *)ROUNDUP(va_file_end, PGSIZE);
				     va_cur + PGSIZE <= va_end;
				     va_cur += PGSIZE) {
					pa = new_page(1);
					map(&pcb->as, va_cur, pa, PROT_EXEC | PROT_READ | PROT_WRITE);
					record_page_map(pcb, va_cur, pa);
					memset(pa, 0, PGSIZE);
				}

				// last BSS page (partial)
				if (va_cur < va_end) {
					pa = lookup_page_map(pcb, va_cur);
					if (pa == NULL) {
						pa = new_page(1);
						map(&pcb->as, va_cur, pa, PROT_EXEC | PROT_READ | PROT_WRITE);
						record_page_map(pcb, va_cur, pa);
					}
					memset(pa, 0, va_end - va_cur);
				}
			}
		}
	}
  return ehdr.e_entry;
}

void naive_uload(PCB *pcb, const char *filename) {
  uintptr_t entry = loader(pcb, filename);
  Log("Jump to entry = %p", (void *)entry);
  ((void(*)())entry) ();
}

void context_uload(PCB *pcb, const char *filename, char *const argv[], char *const envp[]) {
	protect(&pcb->as);
	clear_page_map(pcb);
	uintptr_t entry = loader(pcb, filename);
	pcb->cp = ucontext(&pcb->as, (Area) {pcb->stack, pcb->stack + STACK_SIZE}, (void *)entry);
	void *va_end = pcb->as.area.end;
	void *va = va_end - STACK_SIZE;
	void *stack_start = new_page(8);
	void *pa = stack_start;
	for (; va < va_end; va += PGSIZE, pa += PGSIZE) {
		map(&pcb->as, va, pa, PROT_EXEC | PROT_READ | PROT_WRITE);
		record_page_map(pcb, va, pa);
	}
	char *stack = (char *)stack_start + STACK_SIZE;
	char *strptr = stack;
	int argc = 0;
	for (; argv != NULL && argv[argc] != NULL; ++argc) {
		stack -= strlen(argv[argc]) + 1;
		strcpy(stack, argv[argc]);
	}
	stack = (char *)((uintptr_t)stack & ~0x3);
	stack -= (argc + 1) * 8;
	for (int i = 0; i < argc; ++i) {
		strptr -= strlen(argv[i]) + 1;
		*((char **)stack + i) = strptr;
	}
	*((char **)stack + argc) = NULL;
	stack -= sizeof(argc);
	*(int *)stack = argc;
	pcb->cp->GPRx = (uintptr_t)stack;
}
