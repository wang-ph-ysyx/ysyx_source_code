#include <am.h>
#include <ysyxsoc.h>

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
	int scan_code = inb(KEYBOARD_ADDR);
	if (scan_code == 0xf0) {
		kbd->keydown = 0;
		kbd->keycode = inb(KEYBOARD_ADDR);
	}
	else {
		kbd->keydown = 1;
		kbd->keycode = scan_code;
	}
}
