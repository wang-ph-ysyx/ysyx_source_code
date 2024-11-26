#ifndef __COMMON_H__
#define __COMMON_H__

/* Uncomment these macros to enable corresponding functionality. */
#define HAS_CTE
#define HAS_VME
#define MULTIPROGRAM

#ifdef __PLATFORM_NEMU
#define TIME_SHARING
#endif

#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <debug.h>

#endif
