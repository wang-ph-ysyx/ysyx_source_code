#include <am.h>
#include <jyd.h>

void __am_gpio_sw(AM_GPIO_SW_T* sw) {
	sw->data[0] = inl(GPIO_SW_ADDR);
	sw->data[1] = inl(GPIO_SW_ADDR + 4);
}

void __am_gpio_key(AM_GPIO_KEY_T* key) {
	key->data = inb(GPIO_KEY_ADDR);
}

void __am_gpio_seg(AM_GPIO_SEG_T* seg) {
	for (int i = 0; i < 8; ++i) {
		outb(GPIO_SEG_ADDR + (i << 2), seg->data[i]);
	}
}

void __am_gpio_led(AM_GPIO_LED_T* led) {
	outl(GPIO_LED_ADDR, led->data);
}
