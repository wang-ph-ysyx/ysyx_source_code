// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vexu.h for the primary calling header

#ifndef VERILATED_VEXU___024ROOT_H_
#define VERILATED_VEXU___024ROOT_H_  // guard

#include "verilated.h"

class Vexu__Syms;

class Vexu___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(reset,0,0);
    CData/*0:0*/ top__DOT__reg_wen;
    CData/*0:0*/ __Vtrigrprev__TOP__clk;
    CData/*0:0*/ __VactContinue;
    VL_IN(inst,31,0);
    VL_OUT(pc,31,0);
    VL_OUT(imm,31,0);
    VL_OUT(src1,31,0);
    VL_OUT(val,31,0);
    IData/*31:0*/ top__DOT__next_pc;
    IData/*31:0*/ __VstlIterCount;
    IData/*31:0*/ __VicoIterCount;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<CData/*6:0*/, 1> top__DOT__my_idu__DOT__choose_type__DOT__key_list;
    VlUnpacked<CData/*2:0*/, 1> top__DOT__my_idu__DOT__choose_type__DOT__data_list;
    VlUnpacked<CData/*2:0*/, 1> top__DOT__my_idu__DOT__choose_imm__DOT__key_list;
    VlUnpacked<IData/*31:0*/, 1> top__DOT__my_idu__DOT__choose_imm__DOT__data_list;
    VlUnpacked<CData/*6:0*/, 1> top__DOT__my_exu__DOT__calculate_val__DOT__key_list;
    VlUnpacked<IData/*31:0*/, 1> top__DOT__my_exu__DOT__calculate_val__DOT__data_list;
    VlUnpacked<IData/*31:0*/, 32> top__DOT__my_reg__DOT__rf;
    VlUnpacked<CData/*2:0*/, 1> top__DOT__choose_reg_wen__DOT__key_list;
    VlUnpacked<CData/*0:0*/, 1> top__DOT__choose_reg_wen__DOT__data_list;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<1> __VactTriggered;
    VlTriggerVec<1> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vexu__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vexu___024root(Vexu__Syms* symsp, const char* v__name);
    ~Vexu___024root();
    VL_UNCOPYABLE(Vexu___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);


#endif  // guard
