// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VEXU__SYMS_H_
#define VERILATED_VEXU__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vexu.h"

// INCLUDE MODULE CLASSES
#include "Vexu___024root.h"

// SYMS CLASS (contains all model state)
class Vexu__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vexu* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vexu___024root                 TOP;

    // CONSTRUCTORS
    Vexu__Syms(VerilatedContext* contextp, const char* namep, Vexu* modelp);
    ~Vexu__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

#endif  // guard
