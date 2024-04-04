#include <am.h>
#include <nemu.h>

#define AUDIO_FREQ_ADDR      (AUDIO_ADDR + 0x00)
#define AUDIO_CHANNELS_ADDR  (AUDIO_ADDR + 0x04)
#define AUDIO_SAMPLES_ADDR   (AUDIO_ADDR + 0x08)
#define AUDIO_SBUF_SIZE_ADDR (AUDIO_ADDR + 0x0c)
#define AUDIO_INIT_ADDR      (AUDIO_ADDR + 0x10)
#define AUDIO_COUNT_ADDR     (AUDIO_ADDR + 0x14)

void __am_audio_init() {
}

void __am_audio_config(AM_AUDIO_CONFIG_T *cfg) {
  cfg->present = true;
	cfg->bufsize = inl(AUDIO_SBUF_SIZE_ADDR);
}

void __am_audio_ctrl(AM_AUDIO_CTRL_T *ctrl) {
	outl(AUDIO_FREQ_ADDR, ctrl->freq);
	outl(AUDIO_CHANNELS_ADDR, ctrl->channels);
	outl(AUDIO_SAMPLES_ADDR, ctrl->samples);
	outl(AUDIO_INIT_ADDR, 1);
}

void __am_audio_status(AM_AUDIO_STATUS_T *stat) {
  stat->count = inl(AUDIO_COUNT_ADDR);
}

void __am_audio_play(AM_AUDIO_PLAY_T *ctl) {
	int bufsize = inl(AUDIO_SBUF_SIZE_ADDR);

	//wait until the space is big enough
	while (ctl->buf.end - ctl->buf.start > bufsize - inl(AUDIO_COUNT_ADDR));

	uint8_t *fb = (uint8_t *)(uintptr_t)AUDIO_SBUF_ADDR;
	static int i = 0;
	uint8_t *st = (uint8_t *)ctl->buf.start, *ed = (uint8_t *)ctl->buf.end;
	for (uint8_t *start = st; start < ed; ++start, i = (i + 1) % bufsize) {
		fb[i] = *start;
	}
	int count = inl(AUDIO_COUNT_ADDR);
	outl(AUDIO_COUNT_ADDR, count + ed - st);
}
