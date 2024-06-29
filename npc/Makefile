TOPNAME = ysyxSoCFull

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc -O3 --x-assign \
										fast --x-initial fast --noassert --autoflush \
										--timescale "1ns/1ns" --no-timing

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
IMG ?= 
BIN = $(BUILD_DIR)/$(TOPNAME)
CXX_INC_PATH = $(abspath ./include)
VER_INC_PATH = $(abspath ../ysyxSoC/perip/uart16550/rtl) $(abspath ../ysyxSoC/perip/spi/rtl)

default: $(BIN)

$(shell mkdir -p $(BUILD_DIR))

VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
VSRCS += $(shell find $(abspath ../ysyxSoC/perip) -name "*.v")
VSRCS += $(abspath ../ysyxSoC/build/ysyxSoCFull.v)
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")

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
#NPC_FLAGS += -b

$(BIN): $(VSRCS) $(CSRCS) 
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
