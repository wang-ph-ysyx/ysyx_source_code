#include <common.h>

#if defined(MULTIPROGRAM) && !defined(TIME_SHARING)
# define MULTIPROGRAM_YIELD() yield()
#else
# define MULTIPROGRAM_YIELD()
#endif

#define NAME(key) \
  [AM_KEY_##key] = #key,

static const char *keyname[256] __attribute__((used)) = {
  [AM_KEY_NONE] = "NONE",
  AM_KEYS(NAME)
};

size_t serial_write(const void *buf, size_t offset, size_t len) {
	for (int i = 0; i < len; ++i) {
		putch(*((uint8_t *)buf + i));
	}
  return len;
}

size_t events_read(void *buf, size_t offset, size_t len) {
	AM_INPUT_KEYBRD_T input = io_read(AM_INPUT_KEYBRD);
	int keycode = input.keycode;
	bool keydown = input.keydown;
	char *_buf = (char *)buf;
	const char kd[] = "kd ", ku[] = "ku ";
	if (keycode == 0)
		return 0;
	if (keydown) 
		strncpy(_buf, kd, len);
	else 
		strncpy(_buf, ku, len);
	_buf += 3;
	if (len > 3) 
	  strncpy(_buf, keyname[keycode], len - 3);
	size_t len_total = 3 + strlen(keyname[keycode]);
	if (len > len_total) len = len_total;
	return len;
}

size_t dispinfo_read(void *buf, size_t offset, size_t len) {
	AM_GPU_CONFIG_T gpu = io_read(AM_GPU_CONFIG);
	int width = gpu.width;
	int height = gpu.height;
	int len_total = snprintf((char *)buf, len, "WIDTH:%d\nHEIGHT:%d\n", width, height);
  return len_total;
}

size_t fb_write(const void *buf, size_t offset, size_t len) {
	AM_GPU_CONFIG_T gpu = io_read(AM_GPU_CONFIG);
	int width = gpu.width;
	int x = offset / 4 % width;
	int y = offset / 4 / width;
	for (int i = 0; i < len / 4; ++i) {
		io_write(AM_GPU_FBDRAW, x, y, buf +  i, 1, 1, 1);
		offset += 4;
		x = offset / 4 % width;
		y = offset / 4 / width;
	}
	return len;
}

void init_device() {
  Log("Initializing devices...");
  ioe_init();
}
