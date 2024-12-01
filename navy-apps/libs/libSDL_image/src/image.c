#define SDL_malloc  malloc
#define SDL_free    free
#define SDL_realloc realloc

#define SDL_STBIMAGE_IMPLEMENTATION
#include "SDL_stbimage.h"

SDL_Surface* IMG_Load_RW(SDL_RWops *src, int freesrc) {
  assert(src->type == RW_TYPE_MEM);
  assert(freesrc == 0);

	long size = SDL_RWsize(src);
	void *buf = SDL_malloc(size);
	SDL_RWseek(src, 0, RW_SEEK_SET);
	SDL_RWread(src, buf, size, 1);
	
	SDL_Surface *ret = STBIMG_LoadFromMemory(buf, size);

	SDL_free(buf);

  return ret;
}

SDL_Surface* IMG_Load(const char *filename) {
	assert(filename);

	FILE *fp = fopen(filename, "r");
	assert(fp);

	fseek(fp, 0, SEEK_END);
	long size = ftell(fp);

	fseek(fp, 0, SEEK_SET);
	void *buf = SDL_malloc(size);
	fread(buf, size, 1, fp);

	SDL_Surface *ret = STBIMG_LoadFromMemory(buf, size);

	fclose(fp);
	SDL_free(buf);

  return ret;
}

int IMG_isPNG(SDL_RWops *src) {
	SDL_RWseek(src, 0, RW_SEEK_SET);
	char *buf = SDL_malloc(8*sizeof(char));
	SDL_RWread(src, buf, sizeof(char), 8);
	
	const char magic[8] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};
	int ret = 1;
	for (int i = 0; i < 8; ++i) {
		if (magic[i] != buf[i]) {
			ret = 0;
			break;
		}
	}

	SDL_free(buf);
  return ret;
}

SDL_Surface* IMG_LoadJPG_RW(SDL_RWops *src) {
  return IMG_Load_RW(src, 0);
}

char *IMG_GetError() {
  return "Navy does not support IMG_GetError()";
}
