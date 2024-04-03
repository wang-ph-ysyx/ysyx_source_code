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
	for (int i = ctl->x; i < ctl->h; ++i) {
		for (int j = ctl->y; j < ctl->w; ++j) {
			outl(FB_ADDR + (i*400 + j)*4, *((uint32_t *)ctl->pixels + ((i-ctl->x)*ctl->w + (j-ctl->y))));
		}
	}	
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
