#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  panic("Not implemented");
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {
  int i = 0, count = 0;
	va_list ap;

	va_start(ap, fmt);
	for (; fmt[i] != '\0'; ++i) {
		if (fmt[i] == '%') {
			++i;
			if (fmt[i] == 'd') {
				int data = va_arg(ap, int);
				int len = 0;
				char str[11] = {'\0'};
				while (data) {
					str[len] = data % 10 + '0';
					data /= 10;
					++len;
				}
				for (; len >= 0; --len, ++count) {
					out[count] = str[len];
				}
			}
			else if (fmt[i] == 's') {
				char *str = va_arg(ap, char*);
				for (; *str != '\0'; ++str, ++count) {
					out[count] = *str;
				}
			}
		}
		else {
			out[count] = fmt[i];
			++count;
		}
	}
	va_end(ap);

	return count;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
