#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
	va_list ap;
	char out[256] = {'\0'};

	va_start(ap, fmt);
	int count = vsprintf(out, fmt, ap);
	va_end(ap);

	for (int i = 0; out[i] != '\0'; ++i) {
		putch(out[i]);
	}
	return count;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
	char *start = out;
	for (int i = 0; fmt[i] != '\0'; ++i) {
		if (fmt[i] == '%') {
			++i;
			switch (fmt[i]) {
				case 'd':
				case 'p':
					int data = va_arg(ap, int);
					int len = 0;
					char str1[11] = {'\0'};
					if (data < 0) {
						*out = '-';
						++out;
						data = -data;
					}
					while (data) {
						str1[len] = data % 10 + '0';
						data /= 10;
						++len;
					}
					--len;
					for (; len >= 0; --len, ++out) {
						*out = str1[len];
					}
				break;
				case 's':
					char *str2 = va_arg(ap, char*);
					for (; *str2 != '\0'; ++str2, ++out) {
						*out = *str2;
					}
				break;
				case 'c':
					char ch = va_arg(ap, int);
					*out = ch;
					++out;
				break;
			}
		}
		else {
			*out = fmt[i];
			++out;
		}
	}
	*out = '\0';
	return out - start;
}

int sprintf(char *out, const char *fmt, ...) {
	va_list ap;

	va_start(ap, fmt);
	int count = vsprintf(out, fmt, ap);
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
