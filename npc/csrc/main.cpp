#include <common.h>

extern TOP_NAME *top;
extern VerilatedFstC *tfp;
extern VerilatedContext *contextp;
extern int return_value;

int start = 0;
void nvboard_bind_all_pins(TOP_NAME* top);

void init_monitor(int argc, char **argv);
void sdb_mainloop();
void reset(int cycle);

int main(int argc, char **argv) {
	Verilated::commandArgs(argc, argv);
	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new TOP_NAME{contextp};
#ifdef WAVE_TRACE
	tfp = new VerilatedFstC;
	contextp->traceEverOn(true);
	top->trace(tfp, 0);
	tfp->open("wave.fst");
#endif
	nvboard_bind_all_pins(top);
	nvboard_init();

	reset(10);

	init_monitor(argc, argv);

	start = 1;

	sdb_mainloop();

	delete top;
	delete contextp;
	tfp->close();

	return return_value;
}
