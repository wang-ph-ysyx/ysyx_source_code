ENTRY(_start)
PHDRS { text PT_LOAD; data PT_LOAD; }

MEMORY {
	flash : ORIGIN = 0x30000000, LENGTH = 128M
	sram  : ORIGIN = 0x0f000000, LENGTH = 8K
}

SECTIONS {
  /* _pmem_start and _entry_offset are defined in LDFLAGS */
  /*. = _pmem_start + _entry_offset;*/
	. = ORIGIN(flash);
  .text : {
    *(entry)
    *(.text*)
  } > flash : text
  etext = .;
  _etext = .;
  .rodata : {
    *(.rodata*)
  } > flash 

	. = ORIGIN(sram);
  .data : {
		_data_start = .;
    *(.data)
  } > sram AT> flash : data
	data_load_start = LOADADDR(.data);
  edata = .;
  _data = .;
  .bss : {
		_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > sram 
  /*_stack_top = ALIGN(0x1000);
  . = _stack_top + 0x8000;
  _stack_pointer = .;
  end = .;
  _end = .;
  _heap_start = ALIGN(0x1000);*/
}
