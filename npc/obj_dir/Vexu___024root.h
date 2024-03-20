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
    CData/*0:0*/ __VactContinue;
    VL_IN(inst,31,0);
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<0> __VactTriggered;
    VlTriggerVec<0> __VnbaTriggered;

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
