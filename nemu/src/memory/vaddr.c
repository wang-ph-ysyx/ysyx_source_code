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

#include <isa.h>
#include <memory/paddr.h>

paddr_t vaddr2paddr(vaddr_t addr, int len) {
	paddr_t pg_addr = isa_mmu_translate(addr, len, 0);
	if (pg_addr == MEM_RET_FAIL) 
		assert(0);
	pg_addr = pg_addr & ~((1 << 12) - 1);
	paddr_t paddr = pg_addr + (addr & ((1 << 12) - 1));
	assert(paddr == addr);
	return paddr;
}

word_t vaddr_ifetch(vaddr_t addr, int len) {
	if (isa_mmu_check(addr, len, 0) == MMU_DIRECT)
		return paddr_read(addr, len);
	paddr_t paddr = vaddr2paddr(addr, len);
	return paddr_read(paddr, len);
}

word_t vaddr_read(vaddr_t addr, int len) {
	if (isa_mmu_check(addr, len, 0) == MMU_DIRECT)
		return paddr_read(addr, len);
	paddr_t paddr = vaddr2paddr(addr, len);
	return paddr_read(paddr, len);
}

void vaddr_write(vaddr_t addr, int len, word_t data) {
	if (isa_mmu_check(addr, len, 0) == MMU_DIRECT) {
		paddr_write(addr, len, data);
		return;
	}
	paddr_t paddr = vaddr2paddr(addr, len);
	paddr_write(paddr, len, data);
}
