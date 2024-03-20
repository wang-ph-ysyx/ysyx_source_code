// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vexu.h for the primary calling header

#include "verilated.h"

#include "Vexu___024root.h"

VL_INLINE_OPT void Vexu___024root___ico_sequent__TOP__0(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___ico_sequent__TOP__0\n"); );
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

void Vexu___024root___eval_ico(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___eval_ico\n"); );
    // Body
    if (vlSelf->__VicoTriggered.at(0U)) {
        Vexu___024root___ico_sequent__TOP__0(vlSelf);
    }
}

void Vexu___024root___eval_act(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___eval_act\n"); );
}

VL_INLINE_OPT void Vexu___024root___nba_sequent__TOP__0(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___nba_sequent__TOP__0\n"); );
    // Init
    CData/*4:0*/ __Vdlyvdim0__top__DOT__my_reg__DOT__rf__v0;
    __Vdlyvdim0__top__DOT__my_reg__DOT__rf__v0 = 0;
    IData/*31:0*/ __Vdlyvval__top__DOT__my_reg__DOT__rf__v0;
    __Vdlyvval__top__DOT__my_reg__DOT__rf__v0 = 0;
    CData/*0:0*/ __Vdlyvset__top__DOT__my_reg__DOT__rf__v0;
    __Vdlyvset__top__DOT__my_reg__DOT__rf__v0 = 0;
    // Body
    __Vdlyvset__top__DOT__my_reg__DOT__rf__v0 = 0U;
    if (vlSelf->top__DOT__reg_wen) {
        __Vdlyvval__top__DOT__my_reg__DOT__rf__v0 = vlSelf->val;
        __Vdlyvset__top__DOT__my_reg__DOT__rf__v0 = 1U;
        __Vdlyvdim0__top__DOT__my_reg__DOT__rf__v0 
            = (0x1fU & (vlSelf->inst >> 7U));
    }
    vlSelf->pc = ((IData)(vlSelf->reset) ? 0x80000000U
                   : vlSelf->top__DOT__next_pc);
    if (__Vdlyvset__top__DOT__my_reg__DOT__rf__v0) {
        vlSelf->top__DOT__my_reg__DOT__rf[__Vdlyvdim0__top__DOT__my_reg__DOT__rf__v0] 
            = __Vdlyvval__top__DOT__my_reg__DOT__rf__v0;
    }
    vlSelf->src1 = vlSelf->top__DOT__my_reg__DOT__rf
        [(0x1fU & (vlSelf->inst >> 0xfU))];
    vlSelf->top__DOT__next_pc = ((IData)(4U) + vlSelf->pc);
}

VL_INLINE_OPT void Vexu___024root___nba_sequent__TOP__1(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___nba_sequent__TOP__1\n"); );
    // Init
    IData/*31:0*/ top__DOT__my_exu__DOT__calculate_val__DOT__lut_out;
    top__DOT__my_exu__DOT__calculate_val__DOT__lut_out = 0;
    // Body
    vlSelf->top__DOT__my_exu__DOT__calculate_val__DOT__data_list[0U] 
        = (vlSelf->imm + vlSelf->src1);
    top__DOT__my_exu__DOT__calculate_val__DOT__lut_out 
        = ((- (IData)(((0x7fU & vlSelf->inst) == vlSelf->top__DOT__my_exu__DOT__calculate_val__DOT__key_list
                       [0U]))) & vlSelf->top__DOT__my_exu__DOT__calculate_val__DOT__data_list
           [0U]);
    vlSelf->val = top__DOT__my_exu__DOT__calculate_val__DOT__lut_out;
}

void Vexu___024root___eval_nba(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___eval_nba\n"); );
    // Body
    if (vlSelf->__VnbaTriggered.at(0U)) {
        Vexu___024root___nba_sequent__TOP__0(vlSelf);
        Vexu___024root___nba_sequent__TOP__1(vlSelf);
    }
}

void Vexu___024root___eval_triggers__ico(Vexu___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void Vexu___024root___dump_triggers__ico(Vexu___024root* vlSelf);
#endif  // VL_DEBUG
void Vexu___024root___eval_triggers__act(Vexu___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void Vexu___024root___dump_triggers__act(Vexu___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vexu___024root___dump_triggers__nba(Vexu___024root* vlSelf);
#endif  // VL_DEBUG

void Vexu___024root___eval(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___eval\n"); );
    // Init
    CData/*0:0*/ __VicoContinue;
    VlTriggerVec<1> __VpreTriggered;
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    vlSelf->__VicoIterCount = 0U;
    __VicoContinue = 1U;
    while (__VicoContinue) {
        __VicoContinue = 0U;
        Vexu___024root___eval_triggers__ico(vlSelf);
        if (vlSelf->__VicoTriggered.any()) {
            __VicoContinue = 1U;
            if (VL_UNLIKELY((0x64U < vlSelf->__VicoIterCount))) {
#ifdef VL_DEBUG
                Vexu___024root___dump_triggers__ico(vlSelf);
#endif
                VL_FATAL_MT("vsrc/top.v", 1, "", "Input combinational region did not converge.");
            }
            vlSelf->__VicoIterCount = ((IData)(1U) 
                                       + vlSelf->__VicoIterCount);
            Vexu___024root___eval_ico(vlSelf);
        }
    }
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        __VnbaContinue = 0U;
        vlSelf->__VnbaTriggered.clear();
        vlSelf->__VactIterCount = 0U;
        vlSelf->__VactContinue = 1U;
        while (vlSelf->__VactContinue) {
            vlSelf->__VactContinue = 0U;
            Vexu___024root___eval_triggers__act(vlSelf);
            if (vlSelf->__VactTriggered.any()) {
                vlSelf->__VactContinue = 1U;
                if (VL_UNLIKELY((0x64U < vlSelf->__VactIterCount))) {
#ifdef VL_DEBUG
                    Vexu___024root___dump_triggers__act(vlSelf);
#endif
                    VL_FATAL_MT("vsrc/top.v", 1, "", "Active region did not converge.");
                }
                vlSelf->__VactIterCount = ((IData)(1U) 
                                           + vlSelf->__VactIterCount);
                __VpreTriggered.andNot(vlSelf->__VactTriggered, vlSelf->__VnbaTriggered);
                vlSelf->__VnbaTriggered.set(vlSelf->__VactTriggered);
                Vexu___024root___eval_act(vlSelf);
            }
        }
        if (vlSelf->__VnbaTriggered.any()) {
            __VnbaContinue = 1U;
            if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
                Vexu___024root___dump_triggers__nba(vlSelf);
#endif
                VL_FATAL_MT("vsrc/top.v", 1, "", "NBA region did not converge.");
            }
            __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
            Vexu___024root___eval_nba(vlSelf);
        }
    }
}

#ifdef VL_DEBUG
void Vexu___024root___eval_debug_assertions(Vexu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vexu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexu___024root___eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((vlSelf->clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((vlSelf->reset & 0xfeU))) {
        Verilated::overWidthError("reset");}
}
#endif  // VL_DEBUG
