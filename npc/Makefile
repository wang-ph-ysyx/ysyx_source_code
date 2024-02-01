all:obj_dir wave
	@echo "Write this Makefile by your self."

sim:obj_dir
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "Write this Makefile by your self."

obj_dir:csrc/sim_main.cpp vsrc/top.v
	verilator --cc --exe --build -j 0 -Wall csrc/sim_main.cpp vsrc/top.v --trace

wave:
	obj_dir/Vtop
	
.PHONY: clean

clean:
	rm -r obj_dir
	rm wave.vcd

include ../Makefile
