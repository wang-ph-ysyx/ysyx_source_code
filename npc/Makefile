all:wave.vcd
	@echo "Write this Makefile by your self."

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "Write this Makefile by your self."

wave.vcd:csrc/sim_main.cpp vsrc/top.v
	verilator --cc --exe --build -j 0 -Wall csrc/sim_main.cpp vsrc/top.v --trace
	
.PHONY: clean

clean:
	rm wave.vcd

include ../Makefile
