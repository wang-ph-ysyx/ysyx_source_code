.section entry, "ax"
.global _start
.type _start, @function

_start:
	mv s0, zero
	li sp, 0x0f002000

_fbootloader:
	la t0, sbtl_load_start
	la t1, _sbtl_start
	la t2, _sbtl_end
  _sbtl_copy:
	lw a1, 0(t0)
	sw a1, 0(t1)
	addi t0, t0, 4
	addi t1, t1, 4
	blt t1, t2, _sbtl_copy

.section sbtl, "ax"
.global _sboot_loader

_sboot_loader:
	la t0, text_load_start
	la t1, _text_start
	la t2, _data_start
  _text_copy:
	lw a1, 0(t0)
	sw a1, 0(t1)
	addi t0, t0, 4
	addi t1, t1, 4
	blt t1, t2, _text_copy

	la t0, data_load_start
	la t1, _data_start
	la t2, _bss_start
  _data_copy:
	lbu a1, 0(t0)
	sb a1, 0(t1)
	addi t0, t0, 1
	addi t1, t1, 1
	blt t1, t2, _data_copy

	la t0, _bss_start
	la t1, _end
	li t2, 0
	_bss_clear:
	sb t2, 0(t0)
	addi t0, t0, 1
	blt t0, t1, _bss_clear

	la a2, _trm_init
	jalr x0, 0(a2)

.section .text, "ax"
.global _read_csr_mvendorid
.global _read_csr_marchid
.type _read_csr_mvendorid, @function
.type _read_csr_marchid, @function

_read_csr_mvendorid:
	csrr a0, mvendorid
	ret

_read_csr_marchid:
	csrr a0, marchid
	ret
