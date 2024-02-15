all:csrc/sim_main.cpp vsrc/top.v
	verilator --cc --exe --build -j 0 -Wall csrc/sim_main.cpp vsrc/top.v --trace
	@echo "Write this Makefile by your self."

sim:all
	obj_dir/Vtop
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "Write this Makefile by your self."

.PHONY: clean

clean:
	rm -r obj_dir
	rm wave.vcd

include ../Makefile
