#include <NDL.h>
#include <SDL.h>
#include <string.h>

#define keyname(k) #k,

static const char *keyname[] = {
  "NONE",
  _KEYS(keyname)
};

int SDL_PushEvent(SDL_Event *ev) {
  return 0;
}

int SDL_PollEvent(SDL_Event *ev) {
  return 0;
}

int SDL_WaitEvent(SDL_Event *event) {
	if (event == NULL) return 1;
	char buf[32];
	while (NDL_PollEvent(buf, sizeof(buf)) == 0); 
	if (buf[1] == 'u') event->type = SDL_KEYUP;
	else if (buf[1] == 'd') event->type = SDL_KEYDOWN;
	for (int i = 1; i < sizeof(keyname) / sizeof(char *); ++i) {
		if (strcmp(buf + 3, keyname[i]) == 0) {
			event->key.keysym.sym = i;
			return 1;
		}
	}
  return 1;
}

int SDL_PeepEvents(SDL_Event *ev, int numevents, int action, uint32_t mask) {
  return 0;
}

uint8_t* SDL_GetKeyState(int *numkeys) {
  return NULL;
}
