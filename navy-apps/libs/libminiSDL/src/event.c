#include <NDL.h>
#include <SDL.h>
#include <string.h>

#define keyname(k) #k,
#define keysnap(k) [SDLK_##k] = 0,
#define EVENT_QUEUE 64

void CallBackHelper();       //audio callback helper function
void CallBackHelper_timer(); //timer callback helper function

int poll_event(SDL_Event *event);

SDL_Event event_queue[EVENT_QUEUE];
static int head = 0;
static int tail = 0;

static uint8_t keysnap[] = {
	[SDLK_NONE] = 0,
	_KEYS(keysnap)
};

static const char *keyname[] = {
  "NONE",
  _KEYS(keyname)
};

int SDL_PushEvent(SDL_Event *ev) {
	CallBackHelper();
	CallBackHelper_timer();
	SDL_Event key_event;
	while (poll_event(&key_event) == 1) {
		if ((tail + 1) % EVENT_QUEUE == head) return -1;
		event_queue[tail] = key_event;
		tail = (tail + 1) % EVENT_QUEUE;
	}
	if ((tail + 1) % EVENT_QUEUE == head) return -1;
	event_queue[tail] = *ev;
	tail = (tail + 1) % EVENT_QUEUE;
  return 0;
}

int SDL_PollEvent(SDL_Event *event) {
	CallBackHelper();
	CallBackHelper_timer();
	if (head != tail) {
		*event = event_queue[head];
		head = (head + 1) % EVENT_QUEUE;
		return 1;
	}
	return poll_event(event);
}

int SDL_WaitEvent(SDL_Event *event) {
	CallBackHelper();
	CallBackHelper_timer();
	if (head != tail) {
		*event = event_queue[head];
		head = (head + 1) % EVENT_QUEUE;
		return 1;
	}
	while (poll_event(event) == 0);
	return 1;
}

int SDL_PeepEvents(SDL_Event *ev, int numevents, int action, uint32_t mask) {
	CallBackHelper();
	CallBackHelper_timer();
	SDL_Event key_event;
	while (poll_event(&key_event) == 1) {
		if ((tail + 1) % EVENT_QUEUE == head) return -1;
		event_queue[tail] = key_event;
		tail = (tail + 1) % EVENT_QUEUE;
	}
	for (int i = head; i != tail; i = (i + 1) % EVENT_QUEUE) {
		if (SDL_EVENTMASK(event_queue[i].type) & mask) {
			*ev = event_queue[i];
			tail = (tail + EVENT_QUEUE - 1) % EVENT_QUEUE;
			for (int j = i; j != tail; j = (j + 1) % EVENT_QUEUE) 
				event_queue[j] = event_queue[(j + 1) % EVENT_QUEUE];
			return 1;
		}
	}
  return 0;
}

uint8_t* SDL_GetKeyState(int *numkeys) {
	CallBackHelper();
	CallBackHelper_timer();
  return keysnap;
}

int poll_event(SDL_Event *event) {
	char buf[32];
	if (NDL_PollEvent(buf, sizeof(buf)) == 0) return 0;
	if (event == NULL) return 1;

	if (buf[1] == 'u') event->type = SDL_KEYUP;
	else if (buf[1] == 'd') event->type = SDL_KEYDOWN;

	for (int i = 1; i < sizeof(keyname) / sizeof(char *); ++i) {
		if (strcmp(buf + 3, keyname[i]) == 0) {
			event->key.keysym.sym = i;
			if (event->type == SDL_KEYUP)
				keysnap[i] = 0;
			else if (event->type == SDL_KEYDOWN)
				keysnap[i] = 1;
			return 1;
		}
	}
  return 1;
}
