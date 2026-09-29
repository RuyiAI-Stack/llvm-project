//===- IntrinsicsRISCVBOSCExt.td ------------------------------------------===//
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//===----------------------------------------------------------------------===//
//
// This file defines the intrinsics for the BOSC AME extension.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AME (RISC-V Matrix Extension) Intrinsics
//===----------------------------------------------------------------------===//

// Matrix configuration intrinsics (with immediate)
let TargetPrefix = "riscv" in {
  // Configuration Register Instructions
  // msettype - Set the mtype CSR based on register value
  def int_riscv_bosc_msettype : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                                [IntrNoMem, IntrHasSideEffects]>;

  // msettilem - Set tile M dimension from register value
  def int_riscv_bosc_msettilem : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                                 [IntrNoMem, IntrHasSideEffects]>;

  // msettilen - Set tile N dimension from register value
  def int_riscv_bosc_msettilen : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                                 [IntrNoMem, IntrHasSideEffects]>;

  // msettilek - Set tile K dimension from register value
  def int_riscv_bosc_msettilek : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                                 [IntrNoMem, IntrHasSideEffects]>;

  def int_riscv_bosc_msettsp : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                                [IntrNoMem, IntrHasSideEffects]>;

  def int_riscv_bosc_msetdsp : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                                [IntrNoMem, IntrHasSideEffects]>;

  def int_riscv_bosc_msetpadval : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                                [IntrNoMem, IntrHasSideEffects]>;                                              

  def int_riscv_bosc_msetint8 : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                                [IntrNoMem, IntrHasSideEffects]>;

  def int_riscv_bosc_msetint16 : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                                [IntrNoMem, IntrHasSideEffects]>;

  def int_riscv_bosc_msetint32 : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                                [IntrNoMem, IntrHasSideEffects]>;

  def int_riscv_bosc_msetint64 : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                                [IntrNoMem, IntrHasSideEffects]>;

  def int_riscv_bosc_msetfp16 : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                                [IntrNoMem, IntrHasSideEffects]>;

  def int_riscv_bosc_msetfp32 : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                                [IntrNoMem, IntrHasSideEffects]>;

  def int_riscv_bosc_msetfp64 : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                                [IntrNoMem, IntrHasSideEffects]>;

  // msettypei - Set the mtype CSR based on immediate
  def int_riscv_bosc_msettypei : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                             [IntrNoMem, IntrHasSideEffects,
                                              ImmArg<ArgIndex<0>>]>;

  def int_riscv_bosc_msettypehi : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                             [IntrNoMem, IntrHasSideEffects,
                                              ImmArg<ArgIndex<0>>]>;

  // msettilemi - Set tile M dimension with immediate
  def int_riscv_bosc_msettilemi : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                             [IntrNoMem, IntrHasSideEffects,
                                              ImmArg<ArgIndex<0>>]>;

  // msettileni - Set tile N dimension with immediate
  def int_riscv_bosc_msettileni : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                             [IntrNoMem, IntrHasSideEffects,
                                              ImmArg<ArgIndex<0>>]>;

  // msettileki - Set tile K dimension with immediate
  def int_riscv_bosc_msettileki : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                             [IntrNoMem, IntrHasSideEffects,
                                             ImmArg<ArgIndex<0>>]>;

  def int_riscv_bosc_msettspi : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                             [IntrNoMem, IntrHasSideEffects,
                                             ImmArg<ArgIndex<0>>]>;

  def int_riscv_bosc_msetdspi : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                             [IntrNoMem, IntrHasSideEffects,
                                             ImmArg<ArgIndex<0>>]>;
                                    
  def int_riscv_bosc_msetsew : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                             [IntrNoMem, IntrHasSideEffects,
                                             ImmArg<ArgIndex<0>>]>;

  def int_riscv_bosc_msetba : Intrinsic<[llvm_anyint_ty], [LLVMMatchType<0>],
                                             [IntrNoMem, IntrHasSideEffects,
                                             ImmArg<ArgIndex<0>>]>;
}

//===----------------------------------------------------------------------===//
// BOSC AME Load/Store Intrinsic Base Classes
//===----------------------------------------------------------------------===//
// Base class for all Matrix Load Intrinsics
// Signature: void (index: i64, base_ptr: ptr, stride: i64)
class BOSC_AME_Load_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [llvm_ptr_ty, llvm_anyint_ty],
                [NoCapture<ArgIndex<0>>, IntrReadMem]>, RISCVVIntrinsic;

class BOSC_AME_Load_Vector_Intr
    : Intrinsic<[llvm_anyvector_ty],
                [llvm_ptr_ty, llvm_anyint_ty],
                [NoCapture<ArgIndex<0>>, IntrReadMem]>, RISCVVIntrinsic;

// Base class for all Matrix Store Intrinsics
// Signature: void (index: i64, base_ptr: ptr, stride: i64)
class BOSC_AME_Store_Intr
    : Intrinsic<[],
                [llvm_anymatrix_ty, llvm_ptr_ty, llvm_anyint_ty],
                [NoCapture<ArgIndex<1>>, IntrWriteMem]>, RISCVVIntrinsic;

class BOSC_AME_Store_Vector_Intr
    : Intrinsic<[],
                [llvm_anyvector_ty, llvm_ptr_ty, llvm_anyint_ty],
                [NoCapture<ArgIndex<1>>, IntrWriteMem]>, RISCVVIntrinsic;

//===----------------------------------------------------------------------===//
// Load/Store Intrinsic Instantiations
//===----------------------------------------------------------------------===//
let TargetPrefix = "riscv" in {
  //----------------------------------------------------------------------
  // 1. Matrix Load Intrinsics
  //----------------------------------------------------------------------
  // Matrix A (TileReg)
  def int_riscv_bosc_mlae8_m   : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlae16_m  : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlae32_m  : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlae64_m  : BOSC_AME_Load_Intr;

  def int_riscv_bosc_mlate8_m  : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlate16_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlate32_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlate64_m : BOSC_AME_Load_Intr;

  def int_riscv_bosc_mltre8_m  : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mltre16_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mltre32_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mltre64_m : BOSC_AME_Load_Intr;

  // Matrix B (TileReg)
  def int_riscv_bosc_mlbe8_m   : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlbe16_m  : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlbe32_m  : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlbe64_m  : BOSC_AME_Load_Intr;

  def int_riscv_bosc_mlbte8_m  : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlbte16_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlbte32_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlbte64_m : BOSC_AME_Load_Intr;

  // Matrix C (AccReg)
  def int_riscv_bosc_mlce8_m   : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlce16_m  : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlce32_m  : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlce64_m  : BOSC_AME_Load_Intr;

  def int_riscv_bosc_mlcte8_m  : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlcte16_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlcte32_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlcte64_m : BOSC_AME_Load_Intr;

  def int_riscv_bosc_mlacce8_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlacce16_m: BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlacce32_m: BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlacce64_m: BOSC_AME_Load_Intr;

  // Vector Load Intrinsics
  def int_riscv_bosc_mlae8_v   : BOSC_AME_Load_Vector_Intr;
  def int_riscv_bosc_mlae16_v  : BOSC_AME_Load_Vector_Intr;
  def int_riscv_bosc_mlae32_v  : BOSC_AME_Load_Vector_Intr;
  def int_riscv_bosc_mlae64_v  : BOSC_AME_Load_Vector_Intr;
  def int_riscv_bosc_mlbe8_v   : BOSC_AME_Load_Vector_Intr;
  def int_riscv_bosc_mlbe16_v  : BOSC_AME_Load_Vector_Intr;
  def int_riscv_bosc_mlbe32_v  : BOSC_AME_Load_Vector_Intr;
  def int_riscv_bosc_mlbe64_v  : BOSC_AME_Load_Vector_Intr;
  def int_riscv_bosc_mlce8_v   : BOSC_AME_Load_Vector_Intr;
  def int_riscv_bosc_mlce16_v  : BOSC_AME_Load_Vector_Intr;
  def int_riscv_bosc_mlce32_v  : BOSC_AME_Load_Vector_Intr;
  def int_riscv_bosc_mlce64_v  : BOSC_AME_Load_Vector_Intr;
  
  // Unfold Load Intrinsics
  def int_riscv_bosc_mlufae8_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlufae16_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlufae32_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlufae64_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlufbe8_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlufbe16_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlufbe32_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlufbe64_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlufce8_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlufce16_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlufce32_m : BOSC_AME_Load_Intr;
  def int_riscv_bosc_mlufce64_m : BOSC_AME_Load_Intr;

  //----------------------------------------------------------------------
  // 2. Matrix Store Intrinsics
  //----------------------------------------------------------------------
  // Matrix A (TileReg)
  def int_riscv_bosc_msae8_m   : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msae16_m  : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msae32_m  : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msae64_m  : BOSC_AME_Store_Intr;

  def int_riscv_bosc_msate8_m  : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msate16_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msate32_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msate64_m : BOSC_AME_Store_Intr;

  def int_riscv_bosc_mstre8_m  : BOSC_AME_Store_Intr;
  def int_riscv_bosc_mstre16_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_mstre32_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_mstre64_m : BOSC_AME_Store_Intr;

  // Matrix B (TileReg)
  def int_riscv_bosc_msbe8_m   : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msbe16_m  : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msbe32_m  : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msbe64_m  : BOSC_AME_Store_Intr;

  def int_riscv_bosc_msbte8_m  : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msbte16_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msbte32_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msbte64_m : BOSC_AME_Store_Intr;

  // Matrix C (AccReg)
  def int_riscv_bosc_msce8_m   : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msce16_m  : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msce32_m  : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msce64_m  : BOSC_AME_Store_Intr;

  def int_riscv_bosc_mscte8_m  : BOSC_AME_Store_Intr;
  def int_riscv_bosc_mscte16_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_mscte32_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_mscte64_m : BOSC_AME_Store_Intr;

  def int_riscv_bosc_msacce8_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msacce16_m: BOSC_AME_Store_Intr;
  def int_riscv_bosc_msacce32_m: BOSC_AME_Store_Intr;
  def int_riscv_bosc_msacce64_m: BOSC_AME_Store_Intr;

  // Vector Store Intrinsics
  def int_riscv_bosc_msae8_v  : BOSC_AME_Store_Vector_Intr;
  def int_riscv_bosc_msae16_v : BOSC_AME_Store_Vector_Intr;
  //def int_riscv_bosc_msae32_v : BOSC_AME_Store_Vector_Intr;
  def int_riscv_bosc_msae64_v : BOSC_AME_Store_Vector_Intr;
  def int_riscv_bosc_msbe8_v  : BOSC_AME_Store_Vector_Intr;
  def int_riscv_bosc_msbe16_v : BOSC_AME_Store_Vector_Intr;
  //def int_riscv_bosc_msbe32_v : BOSC_AME_Store_Vector_Intr;
  def int_riscv_bosc_msbe64_v : BOSC_AME_Store_Vector_Intr;
  def int_riscv_bosc_msce8_v  : BOSC_AME_Store_Vector_Intr;
  def int_riscv_bosc_msce16_v : BOSC_AME_Store_Vector_Intr;
  //def int_riscv_bosc_msce32_v : BOSC_AME_Store_Vector_Intr;
  def int_riscv_bosc_msce64_v : BOSC_AME_Store_Vector_Intr;

  // Fold Store Intrinsics
  def int_riscv_bosc_msfdae8_m  : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msfdae16_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msfdae32_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msfdae64_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msfdbe8_m  : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msfdbe16_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msfdbe32_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msfdbe64_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msfdce8_m  : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msfdce16_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msfdce32_m : BOSC_AME_Store_Intr;
  def int_riscv_bosc_msfdce64_m : BOSC_AME_Store_Intr;
}

//===----------------------------------------------------------------------===//
// Data Move / Broadcast / Transpose Intrinsic Base Classes
//===----------------------------------------------------------------------===//

// 1. Matrix to Matrix (2 Immediates: md, ms1) -> No return
class BOSC_AME_Move_T_T_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [LLVMMatchType<0>],
                [IntrNoMem]>, RISCVVIntrinsic;

// 2. Matrix to Matrix with GPR Index (2 Immediates: md, ms1; 1 GPR: rs2) -> No return
class BOSC_AME_Move_A_T_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [llvm_anymatrix_ty, llvm_anyint_ty],
                [IntrNoMem]>, RISCVVIntrinsic;

// 3. Matrix to Matrix with Immediate Index (3 Immediates: md, ms1, imm) -> No return
class BOSC_AME_MoveImm_A_T_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [llvm_anymatrix_ty, llvm_anyint_ty],
                [IntrNoMem, ImmArg<ArgIndex<1>>]>, RISCVVIntrinsic;

// 4. Matrix to Scalar Move (1 Immediate: ms1; 1 GPR: rs2) -> Returns GPR (i64)
class BOSC_AME_Move_X_T_Intr
    : Intrinsic<[llvm_anyint_ty],
                [llvm_anymatrix_ty, llvm_anyint_ty],
                [IntrNoMem]>, RISCVVIntrinsic;

class BOSC_AME_Move_F_T_Intr
    : Intrinsic<[llvm_anyfloat_ty],
                [llvm_anymatrix_ty, llvm_anyint_ty],
                [IntrNoMem]>, RISCVVIntrinsic;

// 5. Scalar to Matrix Move (1 Immediate: md; 2 GPRs: rs1, rs2) -> No return
class BOSC_AME_Move_T_X_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [LLVMMatchType<0>, llvm_anyint_ty, llvm_anyint_ty],
                [IntrNoMem]>, RISCVVIntrinsic;

class BOSC_AME_Move_T_F_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [LLVMMatchType<0>, llvm_anyfloat_ty, llvm_anyint_ty],
                [IntrNoMem]>, RISCVVIntrinsic;

class BOSC_AME_Move_V_M_Intr
    : Intrinsic<[llvm_anyvector_ty],
                [llvm_anymatrix_ty, llvm_anyint_ty],
                [IntrNoMem]>, RISCVVIntrinsic;

class BOSC_AME_Move_M_V_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [llvm_anyvector_ty, llvm_anyint_ty],
                [IntrNoMem]>, RISCVVIntrinsic;

//===----------------------------------------------------------------------===//
// Intrinsic Instantiations
//===----------------------------------------------------------------------===//
let TargetPrefix = "riscv" in {
  //----------------------------------------------------------------------
  // 1. Matrix-Matrix Move
  //----------------------------------------------------------------------
  def int_riscv_bosc_mmve8_t_t  : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mmve16_t_t : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mmve32_t_t : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mmve64_t_t : BOSC_AME_Move_T_T_Intr;

  def int_riscv_bosc_mmve8_a_a  : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mmve16_a_a : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mmve32_a_a : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mmve64_a_a : BOSC_AME_Move_T_T_Intr;
  //----------------------------------------------------------------------
  // 2. Matrix-Matrix Move (with GPR Index)
  //----------------------------------------------------------------------
  def int_riscv_bosc_mmve8_a_t  : BOSC_AME_Move_A_T_Intr;
  def int_riscv_bosc_mmve16_a_t : BOSC_AME_Move_A_T_Intr;
  def int_riscv_bosc_mmve32_a_t : BOSC_AME_Move_A_T_Intr;
  def int_riscv_bosc_mmve64_a_t : BOSC_AME_Move_A_T_Intr;

  def int_riscv_bosc_mmve8_t_a  : BOSC_AME_Move_A_T_Intr;
  def int_riscv_bosc_mmve16_t_a : BOSC_AME_Move_A_T_Intr;
  def int_riscv_bosc_mmve32_t_a : BOSC_AME_Move_A_T_Intr;
  def int_riscv_bosc_mmve64_t_a : BOSC_AME_Move_A_T_Intr;
  //----------------------------------------------------------------------
  // 3. Matrix-Matrix Move (with Immediate Index)
  //----------------------------------------------------------------------
  def int_riscv_bosc_mmvie8_a_t  : BOSC_AME_MoveImm_A_T_Intr;
  def int_riscv_bosc_mmvie16_a_t : BOSC_AME_MoveImm_A_T_Intr;
  def int_riscv_bosc_mmvie32_a_t : BOSC_AME_MoveImm_A_T_Intr;
  def int_riscv_bosc_mmvie64_a_t : BOSC_AME_MoveImm_A_T_Intr;

  def int_riscv_bosc_mmvie8_t_a  : BOSC_AME_MoveImm_A_T_Intr;
  def int_riscv_bosc_mmvie16_t_a : BOSC_AME_MoveImm_A_T_Intr;
  def int_riscv_bosc_mmvie32_t_a : BOSC_AME_MoveImm_A_T_Intr;
  def int_riscv_bosc_mmvie64_t_a : BOSC_AME_MoveImm_A_T_Intr;
  //----------------------------------------------------------------------
  // 4. Matrix to Scalar Move (Returns GPR)
  //----------------------------------------------------------------------
  def int_riscv_bosc_mmve8_x_t  : BOSC_AME_Move_X_T_Intr;
  def int_riscv_bosc_mmve16_x_t : BOSC_AME_Move_X_T_Intr;
  def int_riscv_bosc_mmve32_x_t : BOSC_AME_Move_X_T_Intr;
  def int_riscv_bosc_mmve64_x_t : BOSC_AME_Move_X_T_Intr;

  def int_riscv_bosc_mmve8_x_a  : BOSC_AME_Move_X_T_Intr;
  def int_riscv_bosc_mmve16_x_a : BOSC_AME_Move_X_T_Intr;
  def int_riscv_bosc_mmve32_x_a : BOSC_AME_Move_X_T_Intr;
  def int_riscv_bosc_mmve64_x_a : BOSC_AME_Move_X_T_Intr;

  def int_riscv_bosc_mfmve8_f_t  : BOSC_AME_Move_F_T_Intr;
  def int_riscv_bosc_mfmve16_f_t : BOSC_AME_Move_F_T_Intr;
  def int_riscv_bosc_mfmve32_f_t : BOSC_AME_Move_F_T_Intr;
  def int_riscv_bosc_mfmve64_f_t : BOSC_AME_Move_F_T_Intr;

  def int_riscv_bosc_mfmve8_f_a  : BOSC_AME_Move_F_T_Intr;
  def int_riscv_bosc_mfmve16_f_a : BOSC_AME_Move_F_T_Intr;
  def int_riscv_bosc_mfmve32_f_a : BOSC_AME_Move_F_T_Intr;
  def int_riscv_bosc_mfmve64_f_a : BOSC_AME_Move_F_T_Intr;
  //----------------------------------------------------------------------
  // 5. Scalar GPR to Matrix Move
  //----------------------------------------------------------------------
  def int_riscv_bosc_mmve8_t_x  : BOSC_AME_Move_T_X_Intr;
  def int_riscv_bosc_mmve16_t_x : BOSC_AME_Move_T_X_Intr;
  def int_riscv_bosc_mmve32_t_x : BOSC_AME_Move_T_X_Intr;
  def int_riscv_bosc_mmve64_t_x : BOSC_AME_Move_T_X_Intr;

  def int_riscv_bosc_mmve8_a_x  : BOSC_AME_Move_T_X_Intr;
  def int_riscv_bosc_mmve16_a_x : BOSC_AME_Move_T_X_Intr;
  def int_riscv_bosc_mmve32_a_x : BOSC_AME_Move_T_X_Intr;
  def int_riscv_bosc_mmve64_a_x : BOSC_AME_Move_T_X_Intr;

  def int_riscv_bosc_mfmve8_t_f  : BOSC_AME_Move_T_F_Intr;
  def int_riscv_bosc_mfmve16_t_f : BOSC_AME_Move_T_F_Intr;
  def int_riscv_bosc_mfmve32_t_f : BOSC_AME_Move_T_F_Intr;
  def int_riscv_bosc_mfmve64_t_f : BOSC_AME_Move_T_F_Intr;

  def int_riscv_bosc_mfmve8_a_f  : BOSC_AME_Move_T_F_Intr;
  def int_riscv_bosc_mfmve16_a_f : BOSC_AME_Move_T_F_Intr;
  def int_riscv_bosc_mfmve32_a_f : BOSC_AME_Move_T_F_Intr;
  def int_riscv_bosc_mfmve64_a_f : BOSC_AME_Move_T_F_Intr;
  //----------------------------------------------------------------------
  // 6. Broadcast Intrinsics
  //----------------------------------------------------------------------
  def int_riscv_bosc_mbcar_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbcbr_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbccr_m : BOSC_AME_Move_T_T_Intr;

  def int_riscv_bosc_mbcace8_m  : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbcace16_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbcace32_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbcace64_m : BOSC_AME_Move_T_T_Intr;

  def int_riscv_bosc_mbcbce8_m  : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbcbce16_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbcbce32_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbcbce64_m : BOSC_AME_Move_T_T_Intr;

  def int_riscv_bosc_mbccce8_m  : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbccce16_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbccce32_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbccce64_m : BOSC_AME_Move_T_T_Intr;

  def int_riscv_bosc_mbcaee8_m  : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbcaee16_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbcaee32_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbcaee64_m : BOSC_AME_Move_T_T_Intr;

  def int_riscv_bosc_mbcbee8_m  : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbcbee16_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbcbee32_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbcbee64_m : BOSC_AME_Move_T_T_Intr;

  def int_riscv_bosc_mbccee8_m  : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbccee16_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbccee32_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mbccee64_m : BOSC_AME_Move_T_T_Intr;
  //----------------------------------------------------------------------
  // 7. Transpose Intrinsics
  //----------------------------------------------------------------------
  def int_riscv_bosc_mtae8_m  : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mtae16_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mtae32_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mtae64_m : BOSC_AME_Move_T_T_Intr;

  def int_riscv_bosc_mtbe8_m  : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mtbe16_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mtbe32_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mtbe64_m : BOSC_AME_Move_T_T_Intr;

  def int_riscv_bosc_mtce8_m  : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mtce16_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mtce32_m : BOSC_AME_Move_T_T_Intr;
  def int_riscv_bosc_mtce64_m : BOSC_AME_Move_T_T_Intr;

  // For data moving between vector and matrix(row)
  def int_riscv_bosc_mmvare8_v_m  : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvare16_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvare32_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvare64_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvbre8_v_m  : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvbre16_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvbre32_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvbre64_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvcre8_v_m  : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvcre16_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvcre32_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvcre64_v_m : BOSC_AME_Move_V_M_Intr;

  // For data moving between vector and matrix(column)
  def int_riscv_bosc_mmvace8_v_m  : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvace16_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvace32_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvace64_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvbce8_v_m  : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvbce16_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvbce32_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvbce64_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvcce8_v_m  : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvcce16_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvcce32_v_m : BOSC_AME_Move_V_M_Intr;
  def int_riscv_bosc_mmvcce64_v_m : BOSC_AME_Move_V_M_Intr;

  // For data moving between matrix(row) and vector
  def int_riscv_bosc_mmvare8_m_v  : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvare16_m_v : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvare32_m_v : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvare64_m_v : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvbre8_m_v  : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvbre16_m_v : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvbre32_m_v : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvbre64_m_v : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvcre8_m_v  : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvcre16_m_v : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvcre32_m_v : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvcre64_m_v : BOSC_AME_Move_M_V_Intr;
  
  // For data moving between matrix(column) and vector
  def int_riscv_bosc_mmvace8_m_v  : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvace16_m_v : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvace32_m_v : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvace64_m_v : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvbce8_m_v  : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvbce16_m_v : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvbce32_m_v : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvbce64_m_v : BOSC_AME_Move_M_V_Intr; 
  def int_riscv_bosc_mmvcce8_m_v  : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvcce16_m_v : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvcce32_m_v : BOSC_AME_Move_M_V_Intr;
  def int_riscv_bosc_mmvcce64_m_v : BOSC_AME_Move_M_V_Intr; 
}

//===----------------------------------------------------------------------===//
// Element-Wise Intrinsic Base Classes
//===----------------------------------------------------------------------===//
// Base class for 3-operand element-wise intrinsics (md, ms1, ms2)
class BOSC_AME_EleWise3_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [LLVMMatchType<0>, LLVMMatchType<0>],
                [IntrNoMem]>, RISCVVIntrinsic;

class BOSC_AME_WidenEleWise3_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [llvm_anymatrix_ty, LLVMMatchType<1>],
                [IntrNoMem]>, RISCVVIntrinsic;

// Base class for 2-operand element-wise intrinsics (md, ms1)
class BOSC_AME_EleWise2_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [LLVMMatchType<0>],
                [IntrNoMem]>, RISCVVIntrinsic;

//===----------------------------------------------------------------------===//
// Element-Wise Intrinsic Instantiations
//===----------------------------------------------------------------------===//
let TargetPrefix = "riscv" in {
  //===--------------------------------------------------------------------===//
  // 1. ADD / SUB - No Widen
  //===--------------------------------------------------------------------===//
  def int_riscv_bosc_maddu_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_maddu_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_maddu_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_maddu_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_maddu_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_maddu_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_msaddu_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_msaddu_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msaddu_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msaddu_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msaddu_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msaddu_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_madd_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_madd_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_madd_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_madd_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_madd_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_madd_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_msadd_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_msadd_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msadd_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msadd_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msadd_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msadd_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_mfadd_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mfadd_cf_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfadd_hf_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfadd_f_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfadd_d_mm  : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_msubu_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_msubu_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msubu_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msubu_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msubu_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msubu_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_mssubu_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mssubu_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mssubu_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mssubu_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mssubu_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mssubu_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_msub_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_msub_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msub_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msub_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msub_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msub_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_mssub_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mssub_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mssub_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mssub_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mssub_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mssub_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_mfsub_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mfsub_cf_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfsub_hf_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfsub_f_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfsub_d_mm  : BOSC_AME_EleWise3_Intr;
  //===--------------------------------------------------------------------===//
  // 2. ADD / SUB - Double Widen
  //===--------------------------------------------------------------------===//
  def int_riscv_bosc_mwaddu_mm    : BOSC_AME_WidenEleWise3_Intr;
  //def int_riscv_bosc_mwaddu_hb_mm : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwaddu_b_mm  : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwaddu_h_mm  : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwaddu_w_mm  : BOSC_AME_WidenEleWise3_Intr;

  def int_riscv_bosc_mwadd_mm    : BOSC_AME_WidenEleWise3_Intr;
  //def int_riscv_bosc_mwadd_hb_mm : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwadd_b_mm  : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwadd_h_mm  : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwadd_w_mm  : BOSC_AME_WidenEleWise3_Intr;

  def int_riscv_bosc_mfwadd_mm    : BOSC_AME_WidenEleWise3_Intr;
  //def int_riscv_bosc_mfwadd_cf_mm : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mfwadd_hf_mm : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mfwadd_f_mm  : BOSC_AME_WidenEleWise3_Intr;

  def int_riscv_bosc_mwsubu_mm    : BOSC_AME_WidenEleWise3_Intr;
  //def int_riscv_bosc_mwsubu_hb_mm : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwsubu_b_mm  : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwsubu_h_mm  : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwsubu_w_mm  : BOSC_AME_WidenEleWise3_Intr;

  def int_riscv_bosc_mwsub_mm    : BOSC_AME_WidenEleWise3_Intr;
  //def int_riscv_bosc_mwsub_hb_mm : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwsub_b_mm  : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwsub_h_mm  : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwsub_w_mm  : BOSC_AME_WidenEleWise3_Intr;

  def int_riscv_bosc_mfwsub_mm    : BOSC_AME_WidenEleWise3_Intr;
  //def int_riscv_bosc_mfwsub_cf_mm : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mfwsub_hf_mm : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mfwsub_f_mm  : BOSC_AME_WidenEleWise3_Intr;
  //===--------------------------------------------------------------------===//
  // 3. MIN / MAX - No Widen
  //===--------------------------------------------------------------------===//
  def int_riscv_bosc_mminu_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mminu_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mminu_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mminu_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mminu_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mminu_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_mmaxu_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mmaxu_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmaxu_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmaxu_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmaxu_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmaxu_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_mmin_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mmin_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmin_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmin_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmin_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmin_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_mmax_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mmax_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmax_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmax_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmax_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmax_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_mfmin_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mfmin_cf_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfmin_hf_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfmin_f_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfmin_d_mm  : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_mfmax_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mfmax_cf_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfmax_hf_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfmax_f_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfmax_d_mm  : BOSC_AME_EleWise3_Intr;
  //===--------------------------------------------------------------------===//
  // 4. MUL / MULH / DIV - No Widen
  //===--------------------------------------------------------------------===//
  def int_riscv_bosc_msmulu_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_msmulu_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msmulu_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msmulu_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msmulu_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msmulu_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_mmul_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mmul_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmul_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmul_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmul_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmul_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_msmul_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_msmul_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msmul_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msmul_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msmul_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msmul_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_mfmul_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mfmul_cf_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfmul_hf_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfmul_f_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfmul_d_mm  : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_mmulhu_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mmulhu_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmulhu_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmulhu_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmulhu_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmulhu_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_mmulh_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mmulh_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmulh_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmulh_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmulh_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmulh_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_mmulhsu_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mmulhsu_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmulhsu_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmulhsu_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmulhsu_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mmulhsu_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_msmulsu_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_msmulsu_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msmulsu_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msmulsu_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msmulsu_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msmulsu_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_mfdiv_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_mfdiv_cf_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfdiv_hf_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfdiv_f_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mfdiv_d_mm  : BOSC_AME_EleWise3_Intr;
  //===--------------------------------------------------------------------===//
  // 5. MUL - Double Widen
  //===--------------------------------------------------------------------===//
  def int_riscv_bosc_mwmulu_mm    : BOSC_AME_WidenEleWise3_Intr;
  //def int_riscv_bosc_mwmulu_hb_mm : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwmulu_b_mm  : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwmulu_h_mm  : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwmulu_w_mm  : BOSC_AME_WidenEleWise3_Intr;

  def int_riscv_bosc_mwmul_mm    : BOSC_AME_WidenEleWise3_Intr;
  //def int_riscv_bosc_mwmul_hb_mm : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwmul_b_mm  : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwmul_h_mm  : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwmul_w_mm  : BOSC_AME_WidenEleWise3_Intr;

  def int_riscv_bosc_mwmulsu_mm    : BOSC_AME_WidenEleWise3_Intr;
  //def int_riscv_bosc_mwmulsu_hb_mm : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwmulsu_b_mm  : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwmulsu_h_mm  : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mwmulsu_w_mm  : BOSC_AME_WidenEleWise3_Intr;

  def int_riscv_bosc_mfwmul_mm    : BOSC_AME_WidenEleWise3_Intr;
  //def int_riscv_bosc_mfwmul_cf_mm : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mfwmul_hf_mm : BOSC_AME_WidenEleWise3_Intr;
  def int_riscv_bosc_mfwmul_f_mm  : BOSC_AME_WidenEleWise3_Intr;
  //===--------------------------------------------------------------------===//
  // 6. LOGIC & SHIFT - No Widen
  //===--------------------------------------------------------------------===//
  def int_riscv_bosc_mand_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mor_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_mxor_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_msll_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_msll_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msll_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msll_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msll_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msll_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_msrl_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_msrl_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msrl_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msrl_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msrl_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msrl_dw_mm : BOSC_AME_EleWise3_Intr;

  def int_riscv_bosc_msra_mm    : BOSC_AME_EleWise3_Intr;
  //def int_riscv_bosc_msra_hb_mm : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msra_b_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msra_h_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msra_w_mm  : BOSC_AME_EleWise3_Intr;
  def int_riscv_bosc_msra_dw_mm : BOSC_AME_EleWise3_Intr;
  //===--------------------------------------------------------------------===//
  // 7. SQRT - No Widen (Unary, 2-Operand)
  // NOTE: Uses EleWise2_Intr
  //===--------------------------------------------------------------------===//
  def int_riscv_bosc_mfsqrt_m    : BOSC_AME_EleWise2_Intr;
  //def int_riscv_bosc_mfsqrt_cf_m : BOSC_AME_EleWise2_Intr;
  def int_riscv_bosc_mfsqrt_hf_m : BOSC_AME_EleWise2_Intr;
  def int_riscv_bosc_mfsqrt_f_m  : BOSC_AME_EleWise2_Intr;
  def int_riscv_bosc_mfsqrt_d_m  : BOSC_AME_EleWise2_Intr;
}

//===----------------------------------------------------------------------===//
// Matrix Multiply-Accumulate (MMA) Intrinsic Base Class
//===----------------------------------------------------------------------===//
// Base class for all 3-operand Matrix Multiply-Accumulate intrinsics
class BOSC_AME_MMA_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [LLVMMatchType<0>, LLVMMatchType<0>, LLVMMatchType<0>],
                [IntrNoMem]>, RISCVVIntrinsic;

class BOSC_AME_WidenMMA_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [LLVMMatchType<0>, llvm_anymatrix_ty, LLVMMatchType<1>],
                [IntrNoMem]>, RISCVVIntrinsic;

//===----------------------------------------------------------------------===//
// MMA Intrinsic Instantiations
//===----------------------------------------------------------------------===//
let TargetPrefix = "riscv" in {
  //===--------------------------------------------------------------------===//
  // 1. No-widen matrix multiply-accumulate
  //===--------------------------------------------------------------------===//
  // int
  def int_riscv_bosc_mma_mm    : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mma_h_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mma_w_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mma_dw_mm : BOSC_AME_MMA_Intr;

  // int, saturated
  def int_riscv_bosc_msma_mm    : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msma_h_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msma_w_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msma_dw_mm : BOSC_AME_MMA_Intr;

  // uint
  def int_riscv_bosc_mmau_mm    : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mmau_h_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mmau_w_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mmau_dw_mm : BOSC_AME_MMA_Intr;

  // uint, saturated
  def int_riscv_bosc_msmau_mm    : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msmau_h_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msmau_w_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msmau_dw_mm : BOSC_AME_MMA_Intr;

  // float point
  def int_riscv_bosc_mfma_mm    : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mfma_hf_mm : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mfma_f_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mfma_d_mm  : BOSC_AME_MMA_Intr;

  // left(a) or right(b) matrix is sparsing
  def int_riscv_bosc_mmau_spa_mm    : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mmau_spa_h_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mmau_spa_w_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mmau_spa_dw_mm : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mmau_spb_mm    : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mmau_spb_h_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mmau_spb_w_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mmau_spb_dw_mm : BOSC_AME_MMA_Intr;
  
  def int_riscv_bosc_msmau_spa_mm    : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msmau_spa_h_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msmau_spa_w_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msmau_spa_dw_mm : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msmau_spb_mm    : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msmau_spb_h_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msmau_spb_w_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msmau_spb_dw_mm : BOSC_AME_MMA_Intr;

  def int_riscv_bosc_mma_spa_mm    : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mma_spa_h_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mma_spa_w_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mma_spa_dw_mm : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mma_spb_mm    : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mma_spb_h_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mma_spb_w_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mma_spb_dw_mm : BOSC_AME_MMA_Intr;

  def int_riscv_bosc_msma_spa_mm    : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msma_spa_h_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msma_spa_w_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msma_spa_dw_mm : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msma_spb_mm    : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msma_spb_h_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msma_spb_w_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_msma_spb_dw_mm : BOSC_AME_MMA_Intr;
  
  def int_riscv_bosc_mfma_spa_mm    : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mfma_spa_hf_mm : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mfma_spa_f_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mfma_spa_d_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mfma_spb_mm    : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mfma_spb_hf_mm : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mfma_spb_f_mm  : BOSC_AME_MMA_Intr;
  def int_riscv_bosc_mfma_spb_d_mm  : BOSC_AME_MMA_Intr;

  //===--------------------------------------------------------------------===//
  // 2. Double-widen matrix multiply-accumulate
  //===--------------------------------------------------------------------===//
  // uint
  def int_riscv_bosc_mwmau_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mwmau_h_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mwmau_w_mm : BOSC_AME_WidenMMA_Intr;

  // uint, saturated
  def int_riscv_bosc_mswmau_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mswmau_h_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mswmau_w_mm : BOSC_AME_WidenMMA_Intr;

  // int
  def int_riscv_bosc_mwma_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mwma_h_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mwma_w_mm : BOSC_AME_WidenMMA_Intr;

  // int, saturated
  def int_riscv_bosc_mswma_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mswma_h_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mswma_w_mm : BOSC_AME_WidenMMA_Intr;

  // float point
  def int_riscv_bosc_mfwma_mm    : BOSC_AME_WidenMMA_Intr;
  //def int_riscv_bosc_mfwma_cf_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mfwma_hf_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mfwma_f_mm  : BOSC_AME_WidenMMA_Intr;

  // left(a) or right(b) matrix is sparsing (double)
  def int_riscv_bosc_mwmau_spa_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mwmau_spa_h_mm  : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mwmau_spa_w_mm  : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mwmau_spb_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mwmau_spb_h_mm  : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mwmau_spb_w_mm  : BOSC_AME_WidenMMA_Intr;

  def int_riscv_bosc_mswmau_spa_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mswmau_spa_h_mm  : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mswmau_spa_w_mm  : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mswmau_spb_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mswmau_spb_h_mm  : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mswmau_spb_w_mm  : BOSC_AME_WidenMMA_Intr;

  def int_riscv_bosc_mwma_spa_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mwma_spa_h_mm  : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mwma_spa_w_mm  : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mwma_spb_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mwma_spb_h_mm  : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mwma_spb_w_mm  : BOSC_AME_WidenMMA_Intr;

  def int_riscv_bosc_mswma_spa_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mswma_spa_h_mm  : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mswma_spa_w_mm  : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mswma_spb_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mswma_spb_h_mm  : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mswma_spb_w_mm  : BOSC_AME_WidenMMA_Intr;

  def int_riscv_bosc_mfwma_spa_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mfwma_spa_hf_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mfwma_spa_f_mm  : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mfwma_spb_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mfwma_spb_hf_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mfwma_spb_f_mm  : BOSC_AME_WidenMMA_Intr;

  //===--------------------------------------------------------------------===//
  // 3. Quad-widen matrix multiply-accumulate
  //===--------------------------------------------------------------------===//
  // uint
  def int_riscv_bosc_mqmau_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mqmau_b_mm : BOSC_AME_WidenMMA_Intr;

  // uint, saturated
  def int_riscv_bosc_msqmau_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_msqmau_b_mm : BOSC_AME_WidenMMA_Intr;

  // int
  def int_riscv_bosc_mqma_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mqma_b_mm : BOSC_AME_WidenMMA_Intr;

  // int, saturated
  def int_riscv_bosc_msqma_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_msqma_b_mm : BOSC_AME_WidenMMA_Intr;

  // float point
  def int_riscv_bosc_mfqma_mm    : BOSC_AME_WidenMMA_Intr;
  //def int_riscv_bosc_mfqma_cf_mm : BOSC_AME_WidenMMA_Intr;

  // left(a) or right(b) matrix is sparsing (Quad)
  def int_riscv_bosc_mqmau_spa_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mqmau_spa_b_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mqmau_spb_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mqmau_spb_b_mm : BOSC_AME_WidenMMA_Intr;

  def int_riscv_bosc_msqmau_spa_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_msqmau_spa_b_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_msqmau_spb_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_msqmau_spb_b_mm : BOSC_AME_WidenMMA_Intr;

  def int_riscv_bosc_mqma_spa_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mqma_spa_b_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mqma_spb_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mqma_spb_b_mm : BOSC_AME_WidenMMA_Intr;

  def int_riscv_bosc_msqma_spa_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_msqma_spa_b_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_msqma_spb_mm   : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_msqma_spb_b_mm : BOSC_AME_WidenMMA_Intr;

  def int_riscv_bosc_mfqma_spa_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mfqma_spa_cf_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mfqma_spb_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_mfqma_spb_cf_mm : BOSC_AME_WidenMMA_Intr;

  //===--------------------------------------------------------------------===//
  // 4. Oct-widen matrix multiply-accumulate
  //===--------------------------------------------------------------------===//
  // uint
  def int_riscv_bosc_momau_mm    : BOSC_AME_WidenMMA_Intr;
  //def int_riscv_bosc_momau_hb_mm : BOSC_AME_WidenMMA_Intr;

  // uint, saturated
  def int_riscv_bosc_msomau_mm    : BOSC_AME_WidenMMA_Intr;
  //def int_riscv_bosc_msomau_hb_mm : BOSC_AME_WidenMMA_Intr;

  // int
  def int_riscv_bosc_moma_mm    : BOSC_AME_WidenMMA_Intr;
  //def int_riscv_bosc_moma_hb_mm : BOSC_AME_WidenMMA_Intr;

  // int, saturated
  def int_riscv_bosc_msoma_mm    : BOSC_AME_WidenMMA_Intr;
  //def int_riscv_bosc_msoma_hb_mm : BOSC_AME_WidenMMA_Intr;

  // left(a) or right(b) matrix is sparsing (Oct)
  def int_riscv_bosc_momau_spa_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_momau_spa_hb_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_momau_spb_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_momau_spb_hb_mm : BOSC_AME_WidenMMA_Intr;

  def int_riscv_bosc_msomau_spa_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_msomau_spa_hb_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_msomau_spb_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_msomau_spb_hb_mm : BOSC_AME_WidenMMA_Intr;

  def int_riscv_bosc_moma_spa_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_moma_spa_hb_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_moma_spb_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_moma_spb_hb_mm : BOSC_AME_WidenMMA_Intr;

  def int_riscv_bosc_msoma_spa_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_msoma_spa_hb_mm : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_msoma_spb_mm    : BOSC_AME_WidenMMA_Intr;
  def int_riscv_bosc_msoma_spb_hb_mm : BOSC_AME_WidenMMA_Intr;
}

//===----------------------------------------------------------------------===//
// Type Convert Intrinsic Base Class
//===----------------------------------------------------------------------===//
class BOSC_AME_MCVT_Intr
    : Intrinsic<[llvm_anymatrix_ty],
                [llvm_anymatrix_ty],
                [IntrNoMem]>, RISCVVIntrinsic;

let TargetPrefix = "riscv" in {
  def int_riscv_bosc_mcvt_x_xu_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mcvt_hb_uhb_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mcvt_b_ub_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mcvt_h_uh_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mcvt_w_uw_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mcvt_dw_udw_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mcvt_xu_x_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mcvt_uhb_hb_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mcvt_ub_b_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mcvt_uh_h_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mcvt_uw_w_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mcvt_udw_dw_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvtu_xw_x_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvtu_xq_x_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvtu_xo_x_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvtu_b_hb_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvtu_h_hb_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvtu_w_hb_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvtu_h_b_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvtu_w_b_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvtu_w_h_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvtu_dw_w_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvt_xw_x_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvt_xq_x_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvt_xo_x_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvt_b_hb_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvt_h_hb_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvt_w_hb_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvt_h_b_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvt_w_b_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvt_w_h_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mwcvt_dw_w_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvtu_x_xw_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvtu_x_xq_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvtu_x_xo_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvtu_hb_b_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvtu_hb_h_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvtu_hb_w_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvtu_b_h_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvtu_b_w_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvtu_h_w_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvtu_w_dw_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvt_x_xw_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvt_x_xq_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvt_x_xo_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvt_hb_b_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvt_hb_h_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvt_hb_w_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvt_b_h_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvt_b_w_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvt_h_w_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mncvt_w_dw_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvt_bf_hf_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvt_hf_bf_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_fw_f_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_hf_cf_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_f_hf_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_d_f_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_f_fw_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_cf_hf_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_hf_f_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_f_d_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvtu_f_x_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvtu_hf_h_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvtu_f_w_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvtu_d_dw_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvt_f_x_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvt_hf_h_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvt_f_w_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvt_d_dw_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvtu_fw_x_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvtu_hf_b_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvtu_f_h_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvtu_d_w_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_fw_x_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_hf_b_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_f_h_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_d_w_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvtu_f_xw_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvtu_hf_w_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvtu_f_dw_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_f_xw_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_hf_w_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_f_dw_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvtu_x_f_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvtu_h_hf_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvtu_w_f_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvtu_dw_d_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvt_x_f_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvt_h_hf_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvt_w_f_m    : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfcvt_dw_d_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvtu_xw_f_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvtu_w_hf_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvtu_dw_f_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_xw_f_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_w_hf_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_dw_f_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvtu_x_fw_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvtu_b_hf_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvtu_h_f_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvtu_w_d_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_x_fw_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_b_hf_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_h_f_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_w_d_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvtu_fq_x_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvtu_hf_hb_m: BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvtu_f_b_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_fq_x_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_hf_hb_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_f_b_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvtu_fo_x_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvtu_f_hb_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_fo_x_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfwcvt_f_hb_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvtu_x_fq_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvtu_hb_hf_m: BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvtu_b_f_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_x_fq_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_hb_hf_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_b_f_m   : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvtu_x_fo_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvtu_hb_f_m : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_x_fo_m  : BOSC_AME_MCVT_Intr;
  def int_riscv_bosc_mfncvt_hb_f_m  : BOSC_AME_MCVT_Intr;
}
