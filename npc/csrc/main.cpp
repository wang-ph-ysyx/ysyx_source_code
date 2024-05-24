#include <Vysyx_23060236.h>
#include "verilated.h"

extern Vysyx_23060236* top;

void init_monitor(int argc, char **argv);
void sdb_mainloop();
void reset();

int main(int argc, char **argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new Vysyx_23060236{contextp};

	reset();

	init_monitor(argc, argv);

	sdb_mainloop();

	delete top;
	delete contextp;
	return 0;
}
