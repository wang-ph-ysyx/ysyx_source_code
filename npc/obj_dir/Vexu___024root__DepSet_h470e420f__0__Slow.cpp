// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vexu.h for the primary calling header

#include "verilated.h"

#include "Vexu___024root.h"

VL_ATTR_COLD void Vexu___024root___eval_static(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___eval_static\n"); );
}

VL_ATTR_COLD void Vexu___024root___eval_initial(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___eval_initial\n"); );
}

VL_ATTR_COLD void Vexu___024root___eval_final(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___eval_final\n"); );
}

VL_ATTR_COLD void Vexu___024root___eval_settle(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___eval_settle\n"); );
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vexu___024root___dump_triggers__act(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VactTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vexu___024root___dump_triggers__nba(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___dump_triggers__nba\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VnbaTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vexu___024root___ctor_var_reset(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->clk = VL_RAND_RESET_I(1);
    vlSelf->reset = VL_RAND_RESET_I(1);
    vlSelf->inst = VL_RAND_RESET_I(32);
}
