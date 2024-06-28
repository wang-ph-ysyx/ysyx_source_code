.section entry, "ax"
.global _start
.type _start, @function

_start:
	mv s0, zero
	li sp, 0xff001fff
	jal _trm_init
