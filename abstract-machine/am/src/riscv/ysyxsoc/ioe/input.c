#include <am.h>
#include <ysyxsoc.h>

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  kbd->keydown = 0;
  kbd->keycode = inb(KEYBOARD_ADDR);
}
