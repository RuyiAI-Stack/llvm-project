//===- IntrinsicsRISCVXTExt.td -------------------------------------------===//
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//===----------------------------------------------------------------------===//
//
// This file defines the intrinsics for the XuanTie AME extension.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Matrix Configuration Intrinsics
//===----------------------------------------------------------------------===//

let TargetPrefix = "riscv" in {
  def int_riscv_th_mcfg : Intrinsic<[], [llvm_anyint_ty],
                                    [IntrNoMem, IntrHasSideEffects]>;
  def int_riscv_th_mcfgm : Intrinsic<[], [llvm_anyint_ty],
                                     [IntrNoMem, IntrHasSideEffects]>;
  def int_riscv_th_mcfgn : Intrinsic<[], [llvm_anyint_ty],
                                     [IntrNoMem, IntrHasSideEffects]>;
  def int_riscv_th_mcfgk : Intrinsic<[], [llvm_anyint_ty],
                                     [IntrNoMem, IntrHasSideEffects]>;

  def int_riscv_th_mcfgmi : Intrinsic<[], [llvm_anyint_ty],
                                      [IntrNoMem, IntrHasSideEffects,
                                       ImmArg<ArgIndex<0>>]>;
  def int_riscv_th_mcfgni : Intrinsic<[], [llvm_anyint_ty],
                                      [IntrNoMem, IntrHasSideEffects,
                                       ImmArg<ArgIndex<0>>]>;
  def int_riscv_th_mcfgki : Intrinsic<[], [llvm_anyint_ty],
                                      [IntrNoMem, IntrHasSideEffects,
                                       ImmArg<ArgIndex<0>>]>;
}

//===----------------------------------------------------------------------===//
// XuanTie AME Matrix Intrinsic Base Classes
//===----------------------------------------------------------------------===//

// A MatrixReg holds an implementation-defined matrix tile. Matrix register
// operands are represented as SSA matrix values, rather than m0-m7 indices.
class XTAME_MatrixZero_Intr
    : Intrinsic<[llvm_anymatrix_ty], [], [IntrNoMem]>, RISCVVIntrinsic;

class XTAME_Load_Intr
    : Intrinsic<[llvm_anymatrix_ty], [llvm_anyint_ty, llvm_ptr_ty],
                [NoCapture<ArgIndex<1>>, IntrReadMem]>, RISCVVIntrinsic;

class XTAME_Store_Intr
    : Intrinsic<[], [llvm_anymatrix_ty, llvm_anyint_ty, llvm_ptr_ty],
                [NoCapture<ArgIndex<2>>, IntrWriteMem]>, RISCVVIntrinsic;

class XTAME_MatrixUnary_Intr
    : Intrinsic<[llvm_anymatrix_ty], [LLVMMatchType<0>],
                [IntrNoMem]>, RISCVVIntrinsic;

class XTAME_MatrixScalar_Intr
    : Intrinsic<[llvm_anymatrix_ty], [llvm_anyint_ty],
                [IntrNoMem]>, RISCVVIntrinsic;

class XTAME_MatrixScalarIndexed_Intr
    : Intrinsic<[llvm_anymatrix_ty], [llvm_anyint_ty, llvm_anyint_ty],
                [IntrNoMem]>, RISCVVIntrinsic;

class XTAME_ScalarMatrixIndexed_Intr
    : Intrinsic<[llvm_anyint_ty], [llvm_anymatrix_ty, llvm_anyint_ty],
                [IntrNoMem]>, RISCVVIntrinsic;

class XTAME_MatrixBroadcast_Intr
    : Intrinsic<[llvm_anymatrix_ty], [LLVMMatchType<0>, llvm_anyint_ty],
                [IntrNoMem, ImmArg<ArgIndex<1>>]>, RISCVVIntrinsic;

class XTAME_MatrixBinary_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [LLVMMatchType<0>, LLVMMatchType<0>],
                [IntrNoMem]>, RISCVVIntrinsic;

class XTAME_MMA_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [LLVMMatchType<0>, LLVMMatchType<0>, LLVMMatchType<0>],
                [IntrNoMem]>, RISCVVIntrinsic;

// The accumulator/result matrix is wider than the two multiplicand matrices.
class XTAME_WidenMMA_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [LLVMMatchType<0>, llvm_anymatrix_ty, LLVMMatchType<1>],
                [IntrNoMem]>, RISCVVIntrinsic;

//===----------------------------------------------------------------------===//
// MISC Intrinsics
//===----------------------------------------------------------------------===//

let TargetPrefix = "riscv" in {
  // mzero{,2r,4r,8r} define zero-valued MatrixReg tiles.
  def int_riscv_th_mzero : XTAME_MatrixZero_Intr;
  def int_riscv_th_mzero2r : XTAME_MatrixZero_Intr;
  def int_riscv_th_mzero4r : XTAME_MatrixZero_Intr;
  def int_riscv_th_mzero8r : XTAME_MatrixZero_Intr;

  // Matrix-to-matrix move.
  def int_riscv_th_mmov_mm : XTAME_MatrixUnary_Intr;

  // Scalar-to-matrix duplicate.
  def int_riscv_th_mdupb_m_x : XTAME_MatrixScalar_Intr;
  def int_riscv_th_mduph_m_x : XTAME_MatrixScalar_Intr;
  def int_riscv_th_mdupw_m_x : XTAME_MatrixScalar_Intr;
  def int_riscv_th_mdupd_m_x : XTAME_MatrixScalar_Intr;

  // Scalar-to-matrix element move.
  def int_riscv_th_mmovb_m_x : XTAME_MatrixScalarIndexed_Intr;
  def int_riscv_th_mmovh_m_x : XTAME_MatrixScalarIndexed_Intr;
  def int_riscv_th_mmovw_m_x : XTAME_MatrixScalarIndexed_Intr;
  def int_riscv_th_mmovd_m_x : XTAME_MatrixScalarIndexed_Intr;

  // Matrix-to-scalar element move.
  def int_riscv_th_mmovb_x_m : XTAME_ScalarMatrixIndexed_Intr;
  def int_riscv_th_mmovh_x_m : XTAME_ScalarMatrixIndexed_Intr;
  def int_riscv_th_mmovw_x_m : XTAME_ScalarMatrixIndexed_Intr;
  def int_riscv_th_mmovd_x_m : XTAME_ScalarMatrixIndexed_Intr;

  // Matrix row and column broadcasts.
  def int_riscv_th_mmov_mv_i : XTAME_MatrixBroadcast_Intr;
  def int_riscv_th_mcmovb_mv_i : XTAME_MatrixBroadcast_Intr;
  def int_riscv_th_mcmovh_mv_i : XTAME_MatrixBroadcast_Intr;
  def int_riscv_th_mcmovw_mv_i : XTAME_MatrixBroadcast_Intr;
  def int_riscv_th_mcmovd_mv_i : XTAME_MatrixBroadcast_Intr;

  // Matrix pack.
  def int_riscv_th_mpack_mm : XTAME_MatrixBinary_Intr;
  def int_riscv_th_mpackhl_mm : XTAME_MatrixBinary_Intr;
  def int_riscv_th_mpackhh_mm : XTAME_MatrixBinary_Intr;
}

//===----------------------------------------------------------------------===//
// Load/Store Intrinsics
//===----------------------------------------------------------------------===//

let TargetPrefix = "riscv" in {
  // Load matrix tiles. The operands are stride (rs2) and base address (rs1).
  def int_riscv_th_mlde8 : XTAME_Load_Intr;
  def int_riscv_th_mlde16 : XTAME_Load_Intr;
  def int_riscv_th_mlde32 : XTAME_Load_Intr;
  def int_riscv_th_mlde64 : XTAME_Load_Intr;
  def int_riscv_th_mldte8 : XTAME_Load_Intr;
  def int_riscv_th_mldte16 : XTAME_Load_Intr;
  def int_riscv_th_mldte32 : XTAME_Load_Intr;
  def int_riscv_th_mldte64 : XTAME_Load_Intr;
  def int_riscv_th_mslde8 : XTAME_Load_Intr;
  def int_riscv_th_mslde16 : XTAME_Load_Intr;
  def int_riscv_th_mslde32 : XTAME_Load_Intr;
  def int_riscv_th_mslde64 : XTAME_Load_Intr;
  def int_riscv_th_msldte8 : XTAME_Load_Intr;
  def int_riscv_th_msldte16 : XTAME_Load_Intr;
  def int_riscv_th_msldte32 : XTAME_Load_Intr;
  def int_riscv_th_msldte64 : XTAME_Load_Intr;

  // Prefetch does not access a MatrixReg.
  def int_riscv_th_mplde8 : Intrinsic<[], [llvm_anyint_ty, llvm_ptr_ty],
                                      [NoCapture<ArgIndex<1>>, IntrReadMem,
                                       IntrHasSideEffects]>;
  def int_riscv_th_mplde16 : Intrinsic<[], [llvm_anyint_ty, llvm_ptr_ty],
                                       [NoCapture<ArgIndex<1>>, IntrReadMem,
                                        IntrHasSideEffects]>;
  def int_riscv_th_mplde32 : Intrinsic<[], [llvm_anyint_ty, llvm_ptr_ty],
                                       [NoCapture<ArgIndex<1>>, IntrReadMem,
                                        IntrHasSideEffects]>;
  def int_riscv_th_mplde64 : Intrinsic<[], [llvm_anyint_ty, llvm_ptr_ty],
                                       [NoCapture<ArgIndex<1>>, IntrReadMem,
                                        IntrHasSideEffects]>;
  def int_riscv_th_mpldte8 : Intrinsic<[], [llvm_anyint_ty, llvm_ptr_ty],
                                       [NoCapture<ArgIndex<1>>, IntrReadMem,
                                        IntrHasSideEffects]>;
  def int_riscv_th_mpldte16 : Intrinsic<[], [llvm_anyint_ty, llvm_ptr_ty],
                                        [NoCapture<ArgIndex<1>>, IntrReadMem,
                                         IntrHasSideEffects]>;
  def int_riscv_th_mpldte32 : Intrinsic<[], [llvm_anyint_ty, llvm_ptr_ty],
                                        [NoCapture<ArgIndex<1>>, IntrReadMem,
                                         IntrHasSideEffects]>;
  def int_riscv_th_mpldte64 : Intrinsic<[], [llvm_anyint_ty, llvm_ptr_ty],
                                        [NoCapture<ArgIndex<1>>, IntrReadMem,
                                         IntrHasSideEffects]>;

  // Store matrix tiles. The operands are matrix data (ms3), stride, and base.
  def int_riscv_th_mste8 : XTAME_Store_Intr;
  def int_riscv_th_mste16 : XTAME_Store_Intr;
  def int_riscv_th_mste32 : XTAME_Store_Intr;
  def int_riscv_th_mste64 : XTAME_Store_Intr;
  def int_riscv_th_mstte8 : XTAME_Store_Intr;
  def int_riscv_th_mstte16 : XTAME_Store_Intr;
  def int_riscv_th_mstte32 : XTAME_Store_Intr;
  def int_riscv_th_mstte64 : XTAME_Store_Intr;
  def int_riscv_th_msste8 : XTAME_Store_Intr;
  def int_riscv_th_msste16 : XTAME_Store_Intr;
  def int_riscv_th_msste32 : XTAME_Store_Intr;
  def int_riscv_th_msste64 : XTAME_Store_Intr;
  def int_riscv_th_msstte8 : XTAME_Store_Intr;
  def int_riscv_th_msstte16 : XTAME_Store_Intr;
  def int_riscv_th_msstte32 : XTAME_Store_Intr;
  def int_riscv_th_msstte64 : XTAME_Store_Intr;
}

//===----------------------------------------------------------------------===//
// Matrix Multiply-Accumulate Intrinsics
//===----------------------------------------------------------------------===//

let TargetPrefix = "riscv" in {
  // Integer 8-bit multiplicands with 32-bit accumulators.
  def int_riscv_th_mmacc_w_b : XTAME_WidenMMA_Intr;
  def int_riscv_th_mmaccu_w_b : XTAME_WidenMMA_Intr;
  def int_riscv_th_mmaccus_w_b : XTAME_WidenMMA_Intr;
  def int_riscv_th_mmaccsu_w_b : XTAME_WidenMMA_Intr;

  // Non-widening floating-point matrix multiply-accumulate.
  def int_riscv_th_mfmacc_h_m : XTAME_MMA_Intr;
  def int_riscv_th_mfmacc_bf16_m : XTAME_MMA_Intr;
  def int_riscv_th_mfmacc_s_m : XTAME_MMA_Intr;
  def int_riscv_th_mfmacc_d_m : XTAME_MMA_Intr;

  // Widening floating-point matrix multiply-accumulate.
  def int_riscv_th_mfmacc_h_e4m3_m : XTAME_WidenMMA_Intr;
  def int_riscv_th_mfmacc_h_e5m2_m : XTAME_WidenMMA_Intr;
  def int_riscv_th_mfmacc_bf16_e4m3_m : XTAME_WidenMMA_Intr;
  def int_riscv_th_mfmacc_bf16_e5m2_m : XTAME_WidenMMA_Intr;
  def int_riscv_th_mfmacc_s_h_m : XTAME_WidenMMA_Intr;
  def int_riscv_th_mfmacc_s_bf16_m : XTAME_WidenMMA_Intr;
  def int_riscv_th_mfmacc_d_s_m : XTAME_WidenMMA_Intr;
  def int_riscv_th_mfmacc_s_e4m3_m : XTAME_WidenMMA_Intr;
  def int_riscv_th_mfmacc_s_e5m2_m : XTAME_WidenMMA_Intr;
}
