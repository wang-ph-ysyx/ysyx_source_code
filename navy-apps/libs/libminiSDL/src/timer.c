#include <NDL.h>
#include <SDL.h>
#include <sdl-timer.h>
#include <stdio.h>

#define TOTAL_TIMER 16
void CallBackHelper();      //audio callback helper function
void CallBackHelper_timer(); //timer callback helper function

typedef struct {
	SDL_NewTimerCallback callback;
	uint32_t interval;
	void *param;
	int used;
	uint32_t lasttime;
} my_timer_t;

my_timer_t timer_arr[TOTAL_TIMER];

SDL_TimerID SDL_AddTimer(uint32_t interval, SDL_NewTimerCallback callback, void *param) {
	int i;
	for (i = 0; i < TOTAL_TIMER; ++i) {
		if (timer_arr[i].used == 0) 
			break;
	}
	if (i == TOTAL_TIMER)
		return NULL;
	timer_arr[i].callback = callback;
	timer_arr[i].interval = interval;
	timer_arr[i].param = param;
	timer_arr[i].used = 1;
	timer_arr[i].lasttime = NDL_GetTicks();
	return &timer_arr[i];
}

int SDL_RemoveTimer(SDL_TimerID id) {
	if (id == NULL) return 0;
	my_timer_t *timer = (my_timer_t *)id;
	timer->used = 0;
  return 0;
}

uint32_t SDL_GetTicks() {
	CallBackHelper();
	CallBackHelper_timer();
  return NDL_GetTicks();
}

void SDL_Delay(uint32_t ms) {
	CallBackHelper();
	CallBackHelper_timer();
	uint32_t start = NDL_GetTicks();
	while (NDL_GetTicks() - start < ms);
}

void CallBackHelper_timer() {
	static int called = 0;
	if (called) return;
	called = 1;

	uint32_t now = SDL_GetTicks();
	for (int i = 0; i < TOTAL_TIMER; ++i) {
		if (timer_arr[i].used && now - timer_arr[i].lasttime >= timer_arr[i].interval) {
			timer_arr[i].interval = timer_arr[i].callback(timer_arr[i].interval, timer_arr[i].param);
			timer_arr[i].lasttime = now;
		}
	}

	called = 0;
}
