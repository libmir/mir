module mir.internal.math;

version(LDC)
{
    pragma(LDC_no_moduleinfo);
}


import ldc.intrinsics;

alias sqrt = llvm_sqrt;

alias sin = llvm_sin;

alias cos = llvm_cos;

alias powi = llvm_powi;

alias pow = llvm_powi;

alias pow = llvm_pow;

alias exp = llvm_exp;

alias log = llvm_log;

alias fabs = llvm_fabs;

alias floor = llvm_floor;

alias exp2 = llvm_exp2;

alias log10 = llvm_log10;

alias log2 = llvm_log2;

alias ceil = llvm_ceil;

alias trunc = llvm_trunc;

alias rint = llvm_rint;

alias nearbyint = llvm_nearbyint;

alias copysign = llvm_copysign;

alias round = llvm_round;

alias fmuladd = llvm_fmuladd;

alias fmin = llvm_minnum;

alias fmax = llvm_maxnum;
