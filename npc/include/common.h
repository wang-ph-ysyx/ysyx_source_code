#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#include <memory.h>
#include <config.h>
#include <nvboard.h>
#include "verilated.h"
#include "verilated_fst_c.h"

#if defined(__PLATFORM_ysyxsoc_)
#include <VysyxSoCFull___024root.h>
#include <VysyxSoCFull.h>
#define signal(s) top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__##s
#elif defined(__PLATFORM_npc_)
#include <Vnpc___024root.h>
#include <Vnpc.h>
#define signal(s) top->rootp->npc__DOT__cpu__DOT__##s
#endif
#define reg(s) signal(my_reg__DOT__rf[s])

#if defined(__ISA_riscv32_)
#define TOTAL_REGS 32
#elif defined(__ISA_riscv32e_)
#define TOTAL_REGS 16
#endif
