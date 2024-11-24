AM_SRCS := riscv/npc/start.S \
           riscv/npc/trm.c \
           riscv/npc/ioe/timer.c \
           riscv/npc/ioe/input.c \
           riscv/npc/ioe/gpu.c \
           riscv/npc/ioe/uart.c \
           riscv/npc/ioe/ioe.c \
           riscv/npc/cte.c \
           riscv/npc/trap.S \
           riscv/npc/vme.c \
           platform/dummy/mpe.c

CFLAGS    += -fdata-sections -ffunction-sections
LDFLAGS   += -T $(AM_HOME)/scripts/linker.ld \
						 --defsym=_pmem_start=0x80000000 --defsym=_entry_offset=0x0
LDFLAGS   += --gc-sections -e _start
CFLAGS += -DMAINARGS=\"$(mainargs)\"
CFLAGS += -I$(AM_HOME)/am/src/riscv/npc/include
.PHONY: $(AM_HOME)/am/src/riscv/npc/trm.c

# 批处理
ifeq ($(DEBUG),0)
NPC_FLAGS += -b
endif

image: $(IMAGE).elf
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin

run: image
	$(MAKE) -C $(NPC_HOME) sim IMG=$(IMAGE).bin ARGS="$(NPC_FLAGS)" ISA=$(ISA) PLATFORM=$(PLATFORM)
