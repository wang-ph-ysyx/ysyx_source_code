#include <NDL.h>
#include <SDL.h>
#include <stdlib.h>

static void (*callback)(void *userdata, uint8_t *stream, int len);
static int audio_pause = 1;
static uint32_t time_interval = 0;
static int samples = 0;       // sample frame count (for timing)
static int buffer_bytes = 0;  // buffer size in bytes
static int audio_format = 0;  // AUDIO_U8 or AUDIO_S16

int SDL_OpenAudio(SDL_AudioSpec *desired, SDL_AudioSpec *obtained) {
	if (obtained) {
		obtained->freq = desired->freq;
		obtained->format = desired->format;
		obtained->samples = desired->samples;
		obtained->channels = desired->channels;
		obtained->size = desired->size;
		obtained->callback = desired->callback;
		obtained->userdata = desired->userdata;
	}
	samples = desired->samples;
	time_interval = samples * 1000 / desired->freq;
	audio_format = desired->format;

	int sample_bytes = (desired->format == AUDIO_S16) ? 2 : 1;
	buffer_bytes = samples * desired->channels * sample_bytes;

	NDL_OpenAudio(desired->freq, desired->channels, desired->samples);
	callback = desired->callback;
  return 0;
}

void SDL_CloseAudio() {
	NDL_CloseAudio();
}

void SDL_PauseAudio(int pause_on) {
	audio_pause = pause_on;
}

void SDL_MixAudio(uint8_t *dst, uint8_t *src, uint32_t len, int volume) {
	if (volume == 0) return;

	if (audio_format == AUDIO_S16) {
		// 16-bit signed mixing
		int16_t *dst16 = (int16_t *)dst;
		int16_t *src16 = (int16_t *)src;
		uint32_t samples = len / 2;
		for (uint32_t i = 0; i < samples; i++) {
			int32_t sample = (int32_t)dst16[i] + ((int32_t)src16[i] * volume) / SDL_MIX_MAXVOLUME;
			if (sample > 32767) sample = 32767;
			else if (sample < -32768) sample = -32768;
			dst16[i] = (int16_t)sample;
		}
	} else {
		// 8-bit unsigned mixing
		for (uint32_t i = 0; i < len; i++) {
			int32_t sum = (int32_t)dst[i] + ((int32_t)src[i] * volume) / SDL_MIX_MAXVOLUME;
			if (sum > SDL_MIX_MAXVOLUME) sum = SDL_MIX_MAXVOLUME;
			else if (sum < 0) sum = 0;
			dst[i] = (uint8_t)sum;
		}
	}
}

SDL_AudioSpec *SDL_LoadWAV(const char *file, SDL_AudioSpec *spec, uint8_t **audio_buf, uint32_t *audio_len) {
	FILE *fp = fopen(file, "r");

	uint32_t freq;
	fseek(fp, 24, SEEK_SET);
	fread(&freq, 4, 1, fp);
	spec->freq = freq;

	uint16_t sample_bit;
	fseek(fp, 34, SEEK_SET);
	fread(&sample_bit, 2, 1, fp);
	spec->format = (sample_bit == 16) ? AUDIO_S16 : AUDIO_U8;

	uint16_t channels;
	fseek(fp, 22, SEEK_SET);
	fread(&channels, 2, 1, fp);
	spec->channels = channels;

	spec->samples = 4096;

	uint32_t data_size;
	fseek(fp, 40, SEEK_SET);
	fread(&data_size, 4, 1, fp);
	*audio_len = data_size;

	uint8_t *buf = malloc(data_size);
	fseek(fp, 44, SEEK_SET);
	fread(buf, 1, data_size, fp);
	*audio_buf = buf;

  return spec;
}

void SDL_FreeWAV(uint8_t *audio_buf) {
	free(audio_buf);
}

void SDL_LockAudio() {
}

void SDL_UnlockAudio() {
}

void CallBackHelper() {
	static int called = 0;
	if (time_interval == 0 || audio_pause || called) return;
	called = 1;

	static uint32_t start = 0;
	uint32_t now = SDL_GetTicks();
	if (start == 0) start = now;
	// Fill as many audio buffers as the device can accept
	while (now - start > time_interval && NDL_QueryAudio() >= buffer_bytes) {
		start += time_interval;

		uint8_t *stream = malloc(buffer_bytes);
		callback(NULL, stream, buffer_bytes);
		NDL_PlayAudio(stream, buffer_bytes);
		free(stream);
	}

	called = 0;
}
