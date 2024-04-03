#include <am.h>
#include <nemu.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
	uint32_t data = inl(VGACTL_ADDR);
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = data >> 16, .height = data & ((1 << 16) - 1),
    .vmemsz = 0
  };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  if (ctl->sync) {
    outl(SYNC_ADDR, 1);
  }
	uint32_t *pixels = (uint32_t *)ctl->pixels;
	uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
	for (int i = ctl->y; i < ctl->h; ++i) {
		for (int j = ctl->x; j < ctl->w; ++j) {
			fb[i*400+j] = pixels[(i-ctl->y)*ctl->w + (j-ctl->x)];
		}
	}	
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
