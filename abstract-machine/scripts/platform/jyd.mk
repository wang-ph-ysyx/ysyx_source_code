AM_SRCS := riscv/jyd/start.S \
           riscv/jyd/trm.c \
           riscv/jyd/ioe/ioe.c \
           riscv/jyd/ioe/gpio.c \
           riscv/jyd/cte.c \
           riscv/jyd/trap.S \
           riscv/jyd/vme.c \
           platform/dummy/mpe.c

CFLAGS    += -fdata-sections -ffunction-sections
LDFLAGS   += -T $(AM_HOME)/scripts/jyd_linker.ld \
						 --defsym=_irom_start=0x0000 --defsym=_dram_start=0x4000
LDFLAGS   += --gc-sections -e _start
CFLAGS += -DMAINARGS=\"$(mainargs)\"
CFLAGS += -I$(AM_HOME)/am/src/riscv/jyd/include
.PHONY: $(AM_HOME)/am/src/riscv/jyd/trm.c

image: $(IMAGE).elf
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin
