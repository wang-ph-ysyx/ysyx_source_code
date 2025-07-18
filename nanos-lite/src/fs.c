#include <fs.h>

typedef size_t (*ReadFn) (void *buf, size_t offset, size_t len);
typedef size_t (*WriteFn) (const void *buf, size_t offset, size_t len);

typedef struct {
  char *name;
  size_t size;
  size_t disk_offset;
  ReadFn read;
  WriteFn write;
	size_t open_offset;
} Finfo;

enum {FD_STDIN, FD_STDOUT, FD_STDERR, FD_FB};

size_t invalid_read(void *buf, size_t offset, size_t len) {
  panic("should not reach here");
  return 0;
}

size_t invalid_write(const void *buf, size_t offset, size_t len) {
  panic("should not reach here");
  return 0;
}

size_t ramdisk_read(void *buf, size_t offset, size_t len);
size_t ramdisk_write(const void *buf, size_t offset, size_t len);
size_t serial_write(const void *buf, size_t offset, size_t len);
size_t events_read(void *buf, size_t offset, size_t len);
size_t dispinfo_read(void *buf, size_t offset, size_t len);
size_t fb_write(const void *buf, size_t offset, size_t len);
size_t sb_write(const void *buf, size_t offset, size_t len);
size_t sbctl_read(void *buf, size_t offset, size_t len);
size_t sbctl_write(const void *buf, size_t offset, size_t len);

/* This is the information about all files in disk. */
static Finfo file_table[] __attribute__((used)) = {
  [FD_STDIN]  = {"stdin", 0, 0, invalid_read, invalid_write, 0},
  [FD_STDOUT] = {"stdout", 0, 0, invalid_read, serial_write, 0},
  [FD_STDERR] = {"stderr", 0, 0, invalid_read, serial_write, 0},
	{"/dev/events", 0, 0, events_read, invalid_write, 0},
	{"/proc/dispinfo", 0, 0, dispinfo_read, invalid_write, 0},
	{"/dev/fb", 0, 0, invalid_read, fb_write, 0},
	{"/dev/sb", 0, 0, invalid_read, sb_write, 0},
	{"/dev/sbctl", 0, 0, sbctl_read, sbctl_write, 0},
#include "files.h"
};

void init_fs() {
	AM_GPU_CONFIG_T gpu = io_read(AM_GPU_CONFIG);
	file_table[5].size = gpu.width * gpu.height * 4;
  // TODO: initialize the size of /dev/fb
}

int fs_open(const char *pathname, int flags, int mode) {
	for (int i = 0; i < sizeof(file_table) / sizeof(Finfo); ++i) {
		if (strcmp(file_table[i].name, pathname) == 0) {
			file_table[i].open_offset = 0;
			if (file_table[i].read == NULL) file_table[i].read = ramdisk_read;
			if (file_table[i].write == NULL) file_table[i].write = ramdisk_write;
			return i;
		}
	}
	return -1;
}

size_t fs_read(int fd, void *buf, size_t len) {
	size_t read_len = len;
	if (fd > 7 && read_len + file_table[fd].open_offset > file_table[fd].size)
		read_len = file_table[fd].size - file_table[fd].open_offset;
	read_len = file_table[fd].read(buf, file_table[fd].disk_offset + file_table[fd].open_offset, read_len);
	file_table[fd].open_offset += read_len;
	return read_len;
}

size_t fs_write(int fd, const void *buf, size_t len) {
	size_t write_len = len;
	if (fd > 7 && write_len + file_table[fd].open_offset > file_table[fd].size)
		write_len = file_table[fd].size - file_table[fd].open_offset;
	write_len = file_table[fd].write(buf, file_table[fd].disk_offset + file_table[fd].open_offset, write_len);
	file_table[fd].open_offset += write_len;
	return write_len;
}

size_t fs_lseek(int fd, size_t offset, int whence) {
	assert(fd > 4);
	switch (whence) {
		case SEEK_SET: file_table[fd].open_offset = offset;   break;
		case SEEK_CUR: file_table[fd].open_offset += offset;  break;
		case SEEK_END: file_table[fd].open_offset = offset + file_table[fd].size; break;
		default: panic("Unknown whence");
	}
	assert(file_table[fd].open_offset <= file_table[fd].size);
	return file_table[fd].open_offset;
}

int fs_close(int fd) {
	return 0;
}
