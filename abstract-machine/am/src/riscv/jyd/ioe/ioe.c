#include <am.h>
#include <klib-macros.h>

void __am_timer_init();

void __am_gpio_sw(AM_GPIO_SW_T *sw); 
void __am_gpio_key(AM_GPIO_KEY_T *key); 
void __am_gpio_seg(AM_GPIO_SEG_T *seg); 
void __am_gpio_led(AM_GPIO_LED_T *led); 

//static void __am_timer_config(AM_TIMER_CONFIG_T *cfg) { 
//	cfg->present = false; cfg->has_rtc = false; 
//}
//static void __am_uart_config(AM_UART_CONFIG_T *cfg)   { cfg->present = false; }
//static void __am_input_config(AM_INPUT_CONFIG_T *cfg) { cfg->present = false; }
//static void __am_gpu_config(AM_GPU_CONFIG_T *cfg)     { cfg->present = false; }
//static void __am_audio_config(AM_AUDIO_CONFIG_T *cfg) { cfg->present = false; }
//static void __am_disk_config(AM_DISK_CONFIG_T *cfg)   { cfg->present = false; }
//static void __am_net_config(AM_NET_CONFIG_T *cfg)     { cfg->present = false; }
static void __am_gpio_config(AM_GPIO_CONFIG_T *cfg)   { cfg->present = true;  }

typedef void (*handler_t)(void *buf);
static void *lut[128] = {
//[AM_TIMER_CONFIG] = __am_timer_config,
//[AM_UART_CONFIG ] = __am_uart_config,
//[AM_INPUT_CONFIG] = __am_input_config,
//[AM_GPU_CONFIG  ] = __am_gpu_config,
//[AM_AUDIO_CONFIG] = __am_audio_config,
//[AM_DISK_CONFIG ] = __am_disk_config,
//[AM_NET_CONFIG  ] = __am_net_config,
	[AM_GPIO_CONFIG ] = __am_gpio_config,
	[AM_GPIO_SW     ] = __am_gpio_sw,
	[AM_GPIO_KEY    ] = __am_gpio_key,
	[AM_GPIO_SEG    ] = __am_gpio_seg,
	[AM_GPIO_LED    ] = __am_gpio_led,
};

static void fail(void *buf) { panic("access nonexist register"); }

bool ioe_init() {
  for (int i = 0; i < LENGTH(lut); i++)
    if (!lut[i]) lut[i] = fail;
  __am_timer_init();
  return true;
}

void ioe_read (int reg, void *buf) { ((handler_t)lut[reg])(buf); }
void ioe_write(int reg, void *buf) { ((handler_t)lut[reg])(buf); }
