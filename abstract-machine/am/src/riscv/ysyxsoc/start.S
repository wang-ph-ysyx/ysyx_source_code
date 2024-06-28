.section entry, "ax"
.global _start
.type _start, @function

_start:
	mv s0, zero
	li sp, 0x10000022
	jal _trm_init
