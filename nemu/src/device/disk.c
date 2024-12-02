/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <device/map.h>
#include <memory/paddr.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#define BLKSZ 512
#define DISKPATH_SZ 64

static uint32_t *disk_base = NULL;
static FILE *fp = NULL;
char diskpath[DISKPATH_SZ];

enum {
	reg_blksz,
	reg_blkcnt,
	reg_io_buf,
	reg_io_blkno,
	reg_io_blkcnt,
	reg_io_write,
	reg_io_cmd,
	nr_reg
};

static void disk_io_handler(uint32_t offset, int len, bool is_write) {
	if (is_write && offset == reg_io_cmd * 4 && disk_base[reg_io_cmd] == 1) {
		void *host_addr = guest_to_host(disk_base[reg_io_buf]);
		int count = disk_base[reg_io_blkcnt];
		if (disk_base[reg_io_write]) {
			fseek(fp, BLKSZ * disk_base[reg_io_blkno], SEEK_SET);
			int ret = fwrite(host_addr, BLKSZ, count, fp);
			assert(ret == count);
		}
		else {
			fseek(fp, BLKSZ * disk_base[reg_io_blkno], SEEK_SET);
			int ret = fread(host_addr, BLKSZ, count, fp);
			assert(ret == count);
		}

		disk_base[reg_io_cmd] = 0;
	}
}

void init_disk() {
	uint32_t space_size = sizeof(uint32_t) * nr_reg;
	disk_base = (uint32_t *)new_space(space_size);
	disk_base[reg_blksz] = BLKSZ;

	snprintf(diskpath, DISKPATH_SZ, "%s/%s", getenv("NAVY_HOME"), "build/ramdisk.img");
	fp = fopen(diskpath, "r+");
	assert(fp);
	fseek(fp, 0, SEEK_END);
	disk_base[reg_blkcnt] = (ftell(fp) + BLKSZ - 1) / BLKSZ;
	rewind(fp);

	add_mmio_map("disk", CONFIG_DISK_CTL_MMIO, disk_base, space_size, disk_io_handler);
}
