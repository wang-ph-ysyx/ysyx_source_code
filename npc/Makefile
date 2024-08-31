TOPNAME = ysyxSoCFull
NXDC_FILES = constr/top.nxdc
INC_PATH ?= 

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc -O3 --x-assign \
										fast --x-initial fast --noassert --autoflush \
										--timescale "1ns/1ns" --no-timing --trace

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
IMG ?= 
BIN = $(BUILD_DIR)/$(TOPNAME)
CXX_INC_PATH = $(abspath ./include) $(INC_PATH)
VER_INC_PATH = $(abspath ../ysyxSoC/perip/uart16550/rtl) $(abspath ../ysyxSoC/perip/spi/rtl)

default: $(BIN)

$(shell mkdir -p $(BUILD_DIR))

SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
VSRCS += $(shell find $(abspath ../ysyxSoC/perip) -name "*.v")
VSRCS += $(abspath ../ysyxSoC/build/ysyxSoCFull.v)
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
CSRCS += $(SRC_AUTO_BIND)

include $(NVBOARD_HOME)/scripts/nvboard.mk

CXX_INCFLAGS = $(addprefix -I, $(CXX_INC_PATH))
VER_INCFLAGS = $(addprefix -I, $(VER_INC_PATH))
CXXFLAGS += $(CXX_INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""
VERILATOR_CFLAGS += $(VER_INCFLAGS)
DIFF_SO = $(NEMU_HOME)/build/riscv32-nemu-interpreter-so
LDFLAGS += -lreadline
ifneq ($(IMG),)
  NPC_FLAGS += -g $(IMG)
endif
ifneq ($(DIFF_SO),)
  NPC_FLAGS += -d $(DIFF_SO)
endif
# 批处理
NPC_FLAGS += -b

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN)) 

all: default

sim: $(BIN)
	@$(BIN) $(NPC_FLAGS)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!

.PHONY: clean all default sim

clean:
	rm -rf $(BUILD_DIR)

include ../Makefile

count:
	find ./csrc ./vsrc -name *.[chv] | xargs cat | wc -l

countNoblank:
	find ./csrc ./vsrc -name *.[cvh] | xargs grep -v '^$$' | wc -l

perf:
	make -C ../am-kernels/benchmarks/microbench ARCH=riscv32e-ysyxsoc run mainargs=train

CHECK_VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CHECKFLAGS = --lint-only -Wall

check:
	$(VERILATOR) $(CHECKFLAGS) $(CHECK_VSRCS)
