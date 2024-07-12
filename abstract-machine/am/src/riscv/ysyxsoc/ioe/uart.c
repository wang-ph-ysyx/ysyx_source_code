#include <am.h>
#include <ysyxsoc.h>

void __am_uart_config(AM_UART_CONFIG_T *cfg) {
	cfg->present = true;
}

void __am_uart_rx(AM_UART_RX_T *rx) {
	if ((inl(SERIAL_PORT + 12) & 0x1f000) == 0) rx->data = 0xff;
	else rx->data = inb(SERIAL_PORT);
}
