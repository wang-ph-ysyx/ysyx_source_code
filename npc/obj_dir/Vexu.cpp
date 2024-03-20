// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vexu.h"
#include "Vexu__Syms.h"

//============================================================
// Constructors

Vexu::Vexu(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vexu__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , reset{vlSymsp->TOP.reset}
    , inst{vlSymsp->TOP.inst}
    , pc{vlSymsp->TOP.pc}
    , imm{vlSymsp->TOP.imm}
    , src1{vlSymsp->TOP.src1}
    , val{vlSymsp->TOP.val}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vexu::Vexu(const char* _vcname__)
    : Vexu(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vexu::~Vexu() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vexu___024root___eval_debug_assertions(Vexu___024root* vlSelf);
#endif  // VL_DEBUG
void Vexu___024root___eval_static(Vexu___024root* vlSelf);
void Vexu___024root___eval_initial(Vexu___024root* vlSelf);
void Vexu___024root___eval_settle(Vexu___024root* vlSelf);
void Vexu___024root___eval(Vexu___024root* vlSelf);

void Vexu::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vexu::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vexu___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vexu___024root___eval_static(&(vlSymsp->TOP));
        Vexu___024root___eval_initial(&(vlSymsp->TOP));
        Vexu___024root___eval_settle(&(vlSymsp->TOP));
    }
    // MTask 0 start
    VL_DEBUG_IF(VL_DBG_MSGF("MTask0 starting\n"););
    Verilated::mtaskId(0);
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vexu___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfThreadMTask(vlSymsp->__Vm_evalMsgQp);
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vexu::eventsPending() { return false; }

uint64_t Vexu::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vexu::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vexu___024root___eval_final(Vexu___024root* vlSelf);

VL_ATTR_COLD void Vexu::final() {
    Vexu___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vexu::hierName() const { return vlSymsp->name(); }
const char* Vexu::modelName() const { return "Vexu"; }
unsigned Vexu::threads() const { return 1; }
