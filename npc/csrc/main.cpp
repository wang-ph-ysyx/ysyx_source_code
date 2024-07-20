#include <VysyxSoCFull.h>
#include "verilated.h"
#include <nvboard.h>
#include "verilated_vcd_c.h"
#include <config.h>

extern VysyxSoCFull *top;
extern VerilatedVcdC *tfp;
extern VerilatedContext *contextp;

void nvboard_bind_all_pins(VysyxSoCFull* top);

void init_monitor(int argc, char **argv);
void sdb_mainloop();
void reset();

int main(int argc, char **argv) {
	Verilated::commandArgs(argc, argv);
	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new VysyxSoCFull{contextp};
#ifdef WAVE_TRACE
	tfp = new VerilatedVcdC;
	contextp->traceEverOn(true);
	top->trace(tfp, 0);
	tfp->open("wave.vcd");
#endif
	nvboard_bind_all_pins(top);
	nvboard_init();

	reset();

	init_monitor(argc, argv);

	sdb_mainloop();

	delete top;
	delete contextp;
	return 0;
}
