ENTRY(_start)

MEMORY {
	mrom  : ORIGIN = 0x20000000, LENGTH = 4K
	flash : ORIGIN = 0x30000000, LENGTH = 128M
	sram  : ORIGIN = 0x0f000000, LENGTH = 8K
	psram : ORIGIN = 0x80000000, LENGTH = 4M
	sdram : ORIGIN = 0xa0000000, LENGTH = 32M
}

SECTIONS {
	. = ORIGIN(flash);
	.entry : {
		*(entry)
	} > flash

	. = ORIGIN(sdram);
  .text : {
		_text_start = .;
    *(.text*)
  } > sdram AT> flash 
	text_load_start = LOADADDR(.text);
  .rodata : {
    *(.rodata*)
  } > sdram AT> flash 

  .data : {
		. = ALIGN(0x4);
		_data_start = .;
    *(.data)
  } > sdram AT> flash 
	data_load_start = LOADADDR(.data);
  .bss : {
		. = ALIGN(0x4);
		_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > sdram 
  end = .;
  _end = .;
  _heap_start = ALIGN(0x1000);
}
