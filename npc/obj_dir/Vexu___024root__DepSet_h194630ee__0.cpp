// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vexu.h for the primary calling header

#include "verilated.h"

#include "Vexu__Syms.h"
#include "Vexu___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vexu___024root___dump_triggers__act(Vexu___024root* vlSelf);
#endif  // VL_DEBUG

void Vexu___024root___eval_triggers__act(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___eval_triggers__act\n"); );
    // Body
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vexu___024root___dump_triggers__act(vlSelf);
    }
#endif
}
