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

VL_ATTR_COLD void Vexu___024root___eval_initial__TOP(Vexu___024root* vlSelf);

VL_ATTR_COLD void Vexu___024root___eval_initial(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___eval_initial\n"); );
    // Body
    Vexu___024root___eval_initial__TOP(vlSelf);
    vlSelf->__Vtrigrprev__TOP__clk = vlSelf->clk;
}

VL_ATTR_COLD void Vexu___024root___eval_initial__TOP(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___eval_initial__TOP\n"); );
    // Body
    vlSelf->top__DOT__my_idu__DOT__choose_imm__DOT__key_list[0U] = 1U;
    vlSelf->top__DOT__my_exu__DOT__calculate_val__DOT__key_list[0U] = 0x13U;
    vlSelf->top__DOT__my_idu__DOT__choose_type__DOT__key_list[0U] = 0x13U;
    vlSelf->top__DOT__my_idu__DOT__choose_type__DOT__data_list[0U] = 1U;
    vlSelf->top__DOT__choose_reg_wen__DOT__key_list[0U] = 1U;
    vlSelf->top__DOT__choose_reg_wen__DOT__data_list[0U] = 1U;
    vlSelf->top__DOT__my_reg__DOT__rf[0U] = 0U;
}

VL_ATTR_COLD void Vexu___024root___eval_final(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___eval_final\n"); );
}

VL_ATTR_COLD void Vexu___024root___eval_triggers__stl(Vexu___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void Vexu___024root___dump_triggers__stl(Vexu___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD void Vexu___024root___eval_stl(Vexu___024root* vlSelf);

VL_ATTR_COLD void Vexu___024root___eval_settle(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___eval_settle\n"); );
    // Init
    CData/*0:0*/ __VstlContinue;
    // Body
    vlSelf->__VstlIterCount = 0U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        __VstlContinue = 0U;
        Vexu___024root___eval_triggers__stl(vlSelf);
        if (vlSelf->__VstlTriggered.any()) {
            __VstlContinue = 1U;
            if (VL_UNLIKELY((0x64U < vlSelf->__VstlIterCount))) {
#ifdef VL_DEBUG
                Vexu___024root___dump_triggers__stl(vlSelf);
#endif
                VL_FATAL_MT("vsrc/top.v", 1, "", "Settle region did not converge.");
            }
            vlSelf->__VstlIterCount = ((IData)(1U) 
                                       + vlSelf->__VstlIterCount);
            Vexu___024root___eval_stl(vlSelf);
        }
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vexu___024root___dump_triggers__stl(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VstlTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if (vlSelf->__VstlTriggered.at(0U)) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vexu___024root___stl_sequent__TOP__0(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___stl_sequent__TOP__0\n"); );
    // Init
    CData/*2:0*/ top__DOT__Type;
    top__DOT__Type = 0;
    CData/*2:0*/ top__DOT__my_idu__DOT__choose_type__DOT__lut_out;
    top__DOT__my_idu__DOT__choose_type__DOT__lut_out = 0;
    IData/*31:0*/ top__DOT__my_idu__DOT__choose_imm__DOT__lut_out;
    top__DOT__my_idu__DOT__choose_imm__DOT__lut_out = 0;
    IData/*31:0*/ top__DOT__my_exu__DOT__calculate_val__DOT__lut_out;
    top__DOT__my_exu__DOT__calculate_val__DOT__lut_out = 0;
    CData/*0:0*/ top__DOT__choose_reg_wen__DOT__lut_out;
    top__DOT__choose_reg_wen__DOT__lut_out = 0;
    CData/*0:0*/ top__DOT__choose_reg_wen__DOT__hit;
    top__DOT__choose_reg_wen__DOT__hit = 0;
    // Body
    vlSelf->top__DOT__next_pc = ((IData)(4U) + vlSelf->pc);
    vlSelf->src1 = vlSelf->top__DOT__my_reg__DOT__rf
        [(0x1fU & (vlSelf->inst >> 0xfU))];
    vlSelf->top__DOT__my_idu__DOT__choose_imm__DOT__data_list[0U] 
        = (vlSelf->inst >> 0x14U);
    top__DOT__my_idu__DOT__choose_type__DOT__lut_out 
        = ((- (IData)(((0x7fU & vlSelf->inst) == vlSelf->top__DOT__my_idu__DOT__choose_type__DOT__key_list
                       [0U]))) & vlSelf->top__DOT__my_idu__DOT__choose_type__DOT__data_list
           [0U]);
    top__DOT__Type = top__DOT__my_idu__DOT__choose_type__DOT__lut_out;
    top__DOT__choose_reg_wen__DOT__lut_out = (((IData)(top__DOT__Type) 
                                               == vlSelf->top__DOT__choose_reg_wen__DOT__key_list
                                               [0U]) 
                                              & vlSelf->top__DOT__choose_reg_wen__DOT__data_list
                                              [0U]);
    top__DOT__choose_reg_wen__DOT__hit = ((IData)(top__DOT__Type) 
                                          == vlSelf->top__DOT__choose_reg_wen__DOT__key_list
                                          [0U]);
    vlSelf->top__DOT__reg_wen = ((IData)(top__DOT__choose_reg_wen__DOT__hit) 
                                 & (IData)(top__DOT__choose_reg_wen__DOT__lut_out));
    top__DOT__my_idu__DOT__choose_imm__DOT__lut_out 
        = ((- (IData)(((IData)(top__DOT__Type) == vlSelf->top__DOT__my_idu__DOT__choose_imm__DOT__key_list
                       [0U]))) & vlSelf->top__DOT__my_idu__DOT__choose_imm__DOT__data_list
           [0U]);
    vlSelf->imm = top__DOT__my_idu__DOT__choose_imm__DOT__lut_out;
    vlSelf->top__DOT__my_exu__DOT__calculate_val__DOT__data_list[0U] 
        = (vlSelf->imm + vlSelf->src1);
    top__DOT__my_exu__DOT__calculate_val__DOT__lut_out 
        = ((- (IData)(((0x7fU & vlSelf->inst) == vlSelf->top__DOT__my_exu__DOT__calculate_val__DOT__key_list
                       [0U]))) & vlSelf->top__DOT__my_exu__DOT__calculate_val__DOT__data_list
           [0U]);
    vlSelf->val = top__DOT__my_exu__DOT__calculate_val__DOT__lut_out;
}

VL_ATTR_COLD void Vexu___024root___eval_stl(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___eval_stl\n"); );
    // Body
    if (vlSelf->__VstlTriggered.at(0U)) {
        Vexu___024root___stl_sequent__TOP__0(vlSelf);
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vexu___024root___dump_triggers__ico(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___dump_triggers__ico\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VicoTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if (vlSelf->__VicoTriggered.at(0U)) {
        VL_DBG_MSGF("         'ico' region trigger index 0 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vexu___024root___dump_triggers__act(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VactTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if (vlSelf->__VactTriggered.at(0U)) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge clk)\n");
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
    if (vlSelf->__VnbaTriggered.at(0U)) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge clk)\n");
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
    vlSelf->pc = VL_RAND_RESET_I(32);
    vlSelf->imm = VL_RAND_RESET_I(32);
    vlSelf->src1 = VL_RAND_RESET_I(32);
    vlSelf->val = VL_RAND_RESET_I(32);
    vlSelf->top__DOT__next_pc = VL_RAND_RESET_I(32);
    vlSelf->top__DOT__reg_wen = VL_RAND_RESET_I(1);
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->top__DOT__my_idu__DOT__choose_type__DOT__key_list[__Vi0] = VL_RAND_RESET_I(7);
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->top__DOT__my_idu__DOT__choose_type__DOT__data_list[__Vi0] = VL_RAND_RESET_I(3);
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->top__DOT__my_idu__DOT__choose_imm__DOT__key_list[__Vi0] = VL_RAND_RESET_I(3);
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->top__DOT__my_idu__DOT__choose_imm__DOT__data_list[__Vi0] = VL_RAND_RESET_I(32);
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->top__DOT__my_exu__DOT__calculate_val__DOT__key_list[__Vi0] = VL_RAND_RESET_I(7);
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->top__DOT__my_exu__DOT__calculate_val__DOT__data_list[__Vi0] = VL_RAND_RESET_I(32);
    }
    for (int __Vi0 = 0; __Vi0 < 32; ++__Vi0) {
        vlSelf->top__DOT__my_reg__DOT__rf[__Vi0] = VL_RAND_RESET_I(32);
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->top__DOT__choose_reg_wen__DOT__key_list[__Vi0] = VL_RAND_RESET_I(3);
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->top__DOT__choose_reg_wen__DOT__data_list[__Vi0] = VL_RAND_RESET_I(1);
    }
    vlSelf->__Vtrigrprev__TOP__clk = VL_RAND_RESET_I(1);
}
