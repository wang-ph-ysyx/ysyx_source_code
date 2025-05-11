#include <am.h>
#include <npc.h>

void __am_uart_config(AM_UART_CONFIG_T *cfg) {
	cfg->present = true;
}

void __am_uart_rx(AM_UART_RX_T *rx) {
	rx->data = inb(SERIAL_PORT);
}
