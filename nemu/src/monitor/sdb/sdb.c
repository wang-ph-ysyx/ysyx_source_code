/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>
#include <cpu/cpu.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "sdb.h"

static int is_batch_mode = false;

void init_regex();
void init_wp_pool();
uint8_t* guest_to_host(paddr_t paddr);

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(nemu) ");

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args) {
  cpu_exec(-1);
  return 0;
}


static int cmd_q(char *args) {
	nemu_state.state = NEMU_QUIT;
  return -1;
}

static int cmd_help(char *args);

static int cmd_si(char *args) {
	int steps = 1;
	if (args != NULL) 
		sscanf(args, "%d", &steps);
	cpu_exec(steps);
	return 0;
}

void display_wp();

static int cmd_info(char *args) {
	char ch = 'r';
	if (args != NULL)
		ch = *args;
	if (ch == 'r') 
		isa_reg_display();
	else if (ch == 'w') {
		display_wp();
	}
	else printf("Usage: info r, info w");
	return 0;
}

static int cmd_x(char *args) {
	int num = 1;
	uint8_t* haddr = NULL;
	paddr_t paddr = 0;
	if (args == NULL) return 0;
	sscanf(args, "%d %x", &num, &paddr);
	haddr = guest_to_host(paddr);
	uint32_t* addr = (uint32_t*)haddr;
	for (; num > 0; --num) {
		printf("%0#8x:  %08x\n", paddr, *addr);
		addr += 1;
		paddr += 4;
	}
	return 0;
}

static int cmd_p(char *args) {
	bool success = true;
	word_t res = expr(args, &success);
	if (!success) printf("bad expression\n");
	else printf("val:  %u   %#x\n", res, res);

	return 0;
}

void watch_wp(char *expr, word_t res);
	
static int cmd_w(char *args) {
	bool success = true;
	word_t res = expr(args, &success);
	if (!success) printf("bad expresion\n");
	else watch_wp(args, res);

	return 0;
}

void delete_wp(int NO);

static int cmd_d(char *args) {
	int num = 0;
	if (args == NULL) printf("Usage: d [Number]");
	sscanf(args, "%d", &num);
	delete_wp(num);

	return 0;
}

static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "help", "Display information about all supported commands", cmd_help },
  { "c", "Continue the execution of the program", cmd_c },
  { "q", "Exit NEMU", cmd_q },
	{ "si", "execute the program for several steps", cmd_si },
	{ "info", "print the status of the program", cmd_info },
	{ "x", "scan the memory", cmd_x},
	{ "p", "calculate the value", cmd_p},
	{ "w", "set watchpoint", cmd_w},
	{ "d", "delete watchpoint", cmd_d},
	
  /* TODO: Add more commands */

};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i ++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else {
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}

void sdb_set_batch_mode() {
  is_batch_mode = true;
}

void sdb_mainloop() {
  if (is_batch_mode) {
    cmd_c(NULL);
    return;
  }

  for (char *str; (str = rl_gets()) != NULL; ) {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) { continue; }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) { return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}
