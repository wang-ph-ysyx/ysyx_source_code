ENTRY(_start)
PHDRS { text PT_LOAD; data PT_LOAD; }

SECTIONS {
  /* _irom_start and _dram_start and _heap_start are defined in LDFLAGS */
  . = _irom_start;
  .text : {
    *(entry)
    *(.text*)
  } : text
  etext = .;
  _etext = .;

	. = _dram_start;
  .rodata : {
    *(.rodata*)
  }  
  .data : {
		_data_start = .;
    *(.data)
  } : data
  edata = .;
  _data = .;
  .bss : {
		_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } 
  _stack_top = ALIGN(0x1000);
  . = _stack_top + 0x8000;
  _stack_pointer = .;
  end = .;
  _end = .;

  _heap_start = 0x8000;
}
