.section entry, "ax"
.global _start
.global _read_csr_mvendorid
.global _read_csr_marchid
.type _start, @function
.type _read_csr_mvendorid, @function
.type _read_csr_marchid, @function

_start:
	mv s0, zero
	li sp, 0x0f002000
	jal _boot_loader

_boot_loader:
	la t0, text_load_start
	la t1, _text_start
	la t2, _bss_start
_mem_copy:
	lbu a1, 0(t0)
	sb a1, 0(t1)
	addi t0, t0, 1
	addi t1, t1, 1
	bne t1, t2, _mem_copy
	la a2, _trm_init
	jalr x0, 0(a2)

_read_csr_mvendorid:
	csrr a0, mvendorid
	ret

_read_csr_marchid:
	csrr a0, marchid
	ret
