#include <sys/time.h>
#include <stdio.h>

#define HALF_SECOND 500000
#define SECOND (2 * HALF_SECOND)

int main() {
	struct timeval tv;
	struct timezone tz;

	gettimeofday(&tv, &tz);
	printf("%ld, %ld, %d, %d\n", tv.tv_sec, tv.tv_usec, tz.tz_minuteswest, tz.tz_dsttime);

	int half_sec = 1;
	time_t start = tv.tv_sec;
	suseconds_t ustart = tv.tv_usec;
	suseconds_t interval = 0;
  while (1) {
		while(interval / HALF_SECOND < half_sec) {
			gettimeofday(&tv, &tz);
			interval = (tv.tv_sec - start) * SECOND + tv.tv_usec - ustart;
		}
		printf("%d half_sec\n", half_sec ++);
	}
	return 0;
}
