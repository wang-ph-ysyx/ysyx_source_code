ENTRY(_start)

MEMORY {
	mrom  : ORIGIN = 0x20000000, LENGTH = 4K
	flash : ORIGIN = 0x30000000, LENGTH = 128M
	sram  : ORIGIN = 0x0f000000, LENGTH = 8K
	psram : ORIGIN = 0x80000000, LENGTH = 4M
}

SECTIONS {
	. = ORIGIN(flash);
	.entry : {
		*(entry)
	} > flash

	. = ORIGIN(psram);
  .text : {
		_text_start = .;
    *(.text*)
  } > psram AT> flash 
	text_load_start = LOADADDR(.text);
  .rodata : {
    *(.rodata*)
  } > psram AT> flash 
  .data : {
		_data_start = .;
    *(.data)
  } > psram AT> flash 
  .bss : {
		_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > psram 
  end = .;
  _end = .;
  _heap_start = ALIGN(0x1000);
}
