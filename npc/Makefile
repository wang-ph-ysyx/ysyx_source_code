TOPNAME = top
INC_PATH ?=

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc -O3 --x-assign \
										fast --x-initial fast --noassert

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
IMG ?= 
BIN = $(BUILD_DIR)/$(TOPNAME)
INC_PATH += $(abspath ./include)

default: $(BIN)

$(shell mkdir -p $(BUILD_DIR))

VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")

INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""
DIFF_SO = $(NEMU_HOME)/build/riscv32-nemu-interpreter-so
LDFLAGS += -lreadline
NPC_FLAGS += -g $(IMG) -d $(DIFF_SO)
# 批处理
NPC_FLAGS += -b

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
