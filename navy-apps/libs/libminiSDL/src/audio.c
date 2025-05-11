#include <NDL.h>
#include <SDL.h>
#include <stdlib.h>

static void (*callback)(void *userdata, uint8_t *stream, int len);
static int audio_pause = 1;
static uint32_t time_interval = 0;
static int samples = 0;

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
	for (uint32_t i = 0; i < len; ++i) {
		uint16_t sum = (uint16_t)dst[i] + (uint16_t)src[i] * (volume / SDL_MIX_MAXVOLUME);
		if (sum > SDL_MIX_MAXVOLUME) sum = SDL_MIX_MAXVOLUME;
		dst[i] = (uint8_t)sum;
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
	if (now - start > time_interval && NDL_QueryAudio() > samples) {
		start += time_interval;
		uint8_t *stream = malloc(samples);
		callback(NULL, stream, samples);
		NDL_PlayAudio(stream, samples);
		free(stream);
	}

	called = 0;
}
