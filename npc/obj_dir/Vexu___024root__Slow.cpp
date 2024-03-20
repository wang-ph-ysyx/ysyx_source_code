// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vexu.h for the primary calling header

#include "verilated.h"

#include "Vexu__Syms.h"
#include "Vexu___024root.h"

void Vexu___024root___ctor_var_reset(Vexu___024root* vlSelf);

Vexu___024root::Vexu___024root(Vexu__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vexu___024root___ctor_var_reset(this);
}

void Vexu___024root::__Vconfigure(bool first) {
    if (false && first) {}  // Prevent unused
}

Vexu___024root::~Vexu___024root() {
}
