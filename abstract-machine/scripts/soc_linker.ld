ENTRY(_start)

MEMORY {
	mrom  : ORIGIN = 0x20000000, LENGTH = 4K
	flash : ORIGIN = 0x30000000, LENGTH = 128M
	sram  : ORIGIN = 0x0f000000, LENGTH = 8K
	psram : ORIGIN = 0x80000000, LENGTH = 4M
}

SECTIONS {
	. = ORIGIN(flash);
  .text : {
    *(entry)
		_text_start = .;
    *(.text*)
  } > flash 
  .rodata : {
    *(.rodata*)
  } > flash 

	. = ORIGIN(psram);
  .data : {
		_data_start = .;
    *(.data)
  } > psram AT> flash 
	data_load_start = LOADADDR(.data);
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
