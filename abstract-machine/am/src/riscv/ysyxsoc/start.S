.section entry, "ax"
.global _start
.type _start, @function

_start:
	mv s0, zero
	li sp, 0x1000001c
	jal _trm_init
