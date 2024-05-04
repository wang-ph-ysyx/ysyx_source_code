#include <proc.h>
#include <elf.h>

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
			void *buf = (void *)phdr[i].p_vaddr;
			fs_lseek(fd, phdr[i].p_offset, SEEK_SET);
			fs_read(fd, buf, phdr[i].p_filesz);
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

