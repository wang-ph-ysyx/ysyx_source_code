#include <VysyxSoCFull.h>
#include "verilated.h"
#include <nvboard.h>

extern VysyxSoCFull* top;

void nvboard_bind_all_pins(VysyxSoCFull* top);

void init_monitor(int argc, char **argv);
void sdb_mainloop();
void reset();

int main(int argc, char **argv) {
	Verilated::commandArgs(argc, argv);
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new VysyxSoCFull{contextp};

	nvboard_bind_all_pins(top);
	nvboard_init();

	reset();

	init_monitor(argc, argv);

	sdb_mainloop();

	delete top;
	delete contextp;
	return 0;
}
