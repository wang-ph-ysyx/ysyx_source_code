include $(AM_HOME)/scripts/isa/riscv.mk
include $(AM_HOME)/scripts/platform/jyd.mk
COMMON_CFLAGS += -march=rv32i_zicsr -mabi=ilp32e  # overwrite
LDFLAGS       += -melf32lriscv                    # overwrite
