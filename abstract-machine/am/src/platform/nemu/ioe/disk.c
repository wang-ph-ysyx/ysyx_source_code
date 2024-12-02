#include <am.h>
#include <nemu.h>

#define DISK_BLKSZ_ADDR     (DISK_ADDR + 0x0)
#define DISK_BLKCNT_ADDR    (DISK_ADDR + 0x4)
#define DISK_IO_BUF_ADDR    (DISK_ADDR + 0x8)
#define DISK_IO_BLKNO_ADDR  (DISK_ADDR + 0xc)
#define DISK_IO_BLKCNT_ADDR (DISK_ADDR + 0x10)
#define DISK_IO_WRITE_ADDR  (DISK_ADDR + 0x14)
#define DISK_IO_CMD_ADDR    (DISK_ADDR + 0x18)

void __am_disk_config(AM_DISK_CONFIG_T *cfg) {
  cfg->present = true;
	cfg->blksz   = inl(DISK_BLKSZ_ADDR);
	cfg->blkcnt  = inl(DISK_BLKCNT_ADDR);
}

void __am_disk_status(AM_DISK_STATUS_T *stat) {
	stat->ready = 1;
}

void __am_disk_blkio(AM_DISK_BLKIO_T *io) {
	outl(DISK_IO_BUF_ADDR,    io->buf);
	outl(DISK_IO_BLKNO_ADDR,  io->blkno);
	outl(DISK_IO_BLKCNT_ADDR, io->blkcnt);
	outl(DISK_IO_WRITE_ADDR,  io->write);
	outl(DISK_IO_CMD_ADDR,    1);
}
