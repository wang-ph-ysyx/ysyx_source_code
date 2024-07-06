.section entry, "ax"
.global _start
.global _read_csr_mvendorid
.global _read_csr_marchid
.type _start, @function

_start:
	mv s0, zero
	li sp, 0x0f001ff8
	jal _trm_init

_read_csr_mvendorid:
	csrr a0, mvendorid
	ret

_read_csr_marchid:
	csrr a0, marchid
	ret
