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

#include <memory/host.h>
#include <memory/paddr.h>
#include <device/mmio.h>
#include <isa.h>

#if   defined(CONFIG_TARGET_SHARE)
mem_t *mem_arr = NULL;
uint32_t total_mem = 0;
#elif defined(CONFIG_TARGET_NATIVE_ELF)
#if   defined(CONFIG_PMEM_MALLOC)
static uint8_t *pmem = NULL;
#else // CONFIG_PMEM_GARRAY
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};
#endif
#endif

#ifdef CONFIG_TARGET_SHARE
uint8_t* guest_to_host(paddr_t paddr) { 
	assert(mem_arr);
	for (int i = 0; i < total_mem; ++i) {
		if (paddr >= mem_arr[i].start && paddr < mem_arr[i].start + mem_arr[i].size)
			return mem_arr[i].mem + paddr - mem_arr[i].start;
	}
	assert(0);
}

paddr_t host_to_guest(uint8_t *haddr) { 
	assert(mem_arr);
	for (int i = 0; i < total_mem; ++i) {
		if (haddr >= mem_arr[i].mem && haddr < mem_arr[i].mem + mem_arr[i].size)
			return haddr - mem_arr[i].mem + mem_arr[i].start;
	}
	assert(0);
}
#elif defined(CONFIG_TARGET_NATIVE_ELF)
uint8_t* guest_to_host(paddr_t paddr) { 
	return pmem + paddr - CONFIG_MBASE; 
}

paddr_t host_to_guest(uint8_t *haddr) { 
	return haddr - pmem + CONFIG_MBASE; 
}
#endif

void mtrace_write(paddr_t addr, int len, word_t data);
void mtrace_read(paddr_t addr, int len);

static word_t pmem_read(paddr_t addr, int len) {
  word_t ret = host_read(guest_to_host(addr), len);
  return ret;
}

static void pmem_write(paddr_t addr, int len, word_t data) {
  host_write(guest_to_host(addr), len, data);
}

static void out_of_bound(paddr_t addr) {
  panic("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
      addr, PMEM_LEFT, PMEM_RIGHT, cpu.pc);
}

#ifdef CONFIG_TARGET_SHARE
void init_mem(mem_t *_mem_arr, uint32_t _total_mem) {
	assert(_mem_arr);
	mem_arr = _mem_arr;
	total_mem = _total_mem;
	for (int i = 0; i < total_mem; ++i) {
		mem_arr[i].mem = malloc(mem_arr[i].size);
		assert(mem_arr[i].mem);
		Log("%s memory area [" FMT_PADDR ", " FMT_PADDR ")", 
				mem_arr[i].name, mem_arr[i].start, mem_arr[i].start + mem_arr[i].size);
	}
}
#elif defined(CONFIG_TARGET_NATIVE_ELF)
void init_mem() {
#if   defined(CONFIG_PMEM_MALLOC)
  pmem = malloc(CONFIG_MSIZE);
  assert(pmem);
#endif
  IFDEF(CONFIG_MEM_RANDOM, memset(pmem, rand(), CONFIG_MSIZE));
  Log("physical memory area [" FMT_PADDR ", " FMT_PADDR "]", PMEM_LEFT, PMEM_RIGHT);
}
#endif

word_t paddr_read(paddr_t addr, int len) {
	IFDEF(CONFIG_MTRACE, mtrace_read(addr, len));
#ifdef CONFIG_CTRACE
	if (addr >= 0x10000000 && addr < 0x10001000) return 0x3;
	if (addr >= 0x02000000 && addr < 0x02010000) return 0x0;
#endif
  if (likely(in_pmem(addr))) return pmem_read(addr, len);
  IFDEF(CONFIG_DEVICE, return mmio_read(addr, len));
  out_of_bound(addr);
  return 0;
}

void paddr_write(paddr_t addr, int len, word_t data) {
	IFDEF(CONFIG_MTRACE, mtrace_write(addr, len, data));
#ifdef CONFIG_CTRACE
	if (addr >= 0x10000000 && addr < 0x10001000) return;
#endif
  if (likely(in_pmem(addr))) { pmem_write(addr, len, data); return; }
  IFDEF(CONFIG_DEVICE, mmio_write(addr, len, data); return);
  out_of_bound(addr);
}
