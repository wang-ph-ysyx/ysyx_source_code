#include <proc.h>
#include <elf.h>

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

size_t ramdisk_read(void *buf, size_t offset, size_t len);

static uintptr_t loader(PCB *pcb, const char *filename) {
  Elf_Ehdr ehdr;
	ramdisk_read(&ehdr, 0, sizeof(Elf_Ehdr));

	assert(ehdr.e_machine == EXPECT_TYPE);
	assert(*(uint32_t *)ehdr.e_ident == 0x464c457f);

	Elf_Phdr phdr[ehdr.e_phnum];
	ramdisk_read(&phdr, ehdr.e_phoff, ehdr.e_phnum * sizeof(Elf_Phdr));

	for (int i = 0; i < ehdr.e_phnum; ++i) {
		if (phdr[i].p_type == PT_LOAD) {
			void *buf = (void *)phdr[i].p_vaddr;
			ramdisk_read(buf, phdr[i].p_offset, phdr[i].p_filesz);
			memset(buf + phdr[i].p_filesz, 0, phdr[i].p_memsz - phdr[i].p_filesz);
		}
	}
  return ehdr.e_entry;
}

void naive_uload(PCB *pcb, const char *filename) {
  uintptr_t entry = loader(pcb, filename);
  Log("Jump to entry = %p", (void *)entry);
  ((void(*)())entry) ();
}

