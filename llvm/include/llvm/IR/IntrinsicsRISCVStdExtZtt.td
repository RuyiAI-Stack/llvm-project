//===- IntrinsicsRISCVZTTExt.td ------------------------------------------===//
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
// This file defines the intrinsics for Ztt (RISC-V AME Matrix Extension)
// extension.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Datatype management intrinsics
//===----------------------------------------------------------------------===//
// Base class for "get datatype" instrinsics: reads the dtype of an M/Acc
// register into a GPR value.
// Signature: i32 (dtype_reg_index: i32)
class ZTT_DataType_Get_Intr
    : Intrinsic<[llvm_i64_ty], [llvm_i64_ty],
                [IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>]>;

// Base class for "set datatype" instrinsics: writes a GPR value into the dtype
// of an M/Acc register and zeroes that M/Acc register's contents.
// Signature: void (dtype_reg_index: i32, dtype_value: i32)
class ZTT_DataType_Set_Intr
    : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty],
                [IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>]>;

let TargetPrefix = "riscv" in {
  // agettyp - get the dtype of an Acc register
  def int_riscv_ztt_agettyp : ZTT_DataType_Get_Intr;

  // asettyp - set the dtype of an Acc register; zeroes the Acc register
  def int_riscv_ztt_asettyp : ZTT_DataType_Set_Intr;

  // mgettyp - get the dtype of a M (matrix) register
  def int_riscv_ztt_mgettyp : ZTT_DataType_Get_Intr;

  // sgettyp - set the dtype of a M (matrix) register; zeroes the M register
  def int_riscv_ztt_msettyp : ZTT_DataType_Set_Intr;
}

//===----------------------------------------------------------------------===//
// Elementwise arithmetic intrinsics
//===----------------------------------------------------------------------===//
// Base class for matrix-matrix elementwise arithmetic intrinsics
// Signature: void (md_reg_index: i32, ms1_reg_index: i32, ms2_reg_index: i32)
class ZTT_Elementwise_Arithmetic_Intr
    : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [
      IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>, ImmArg<ArgIndex<1>>,
      ImmArg<ArgIndex<2>>
    ]>;

// Base class for matrix-scalar elementwise arithmetic intrinsics
// Signature: void (md_reg_index: i32, scalar: i32, ms2_reg_index: i32)
class ZTT_Elementwise_Arithmetic_Scalar_Intr
    : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty],
                [IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>, ImmArg<ArgIndex<2>>]>;

let TargetPrefix = "riscv" in {
  // mabs.ew - md[i] = |ms1[i]|
  // Signature: void (md_reg_index: i32, ms1_reg_index: i32)
  def int_riscv_ztt_mabs_ew : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [
    IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>, ImmArg<ArgIndex<1>>
  ]>;

  // mabsdiff.ew - md[i] = |ms1[i] - ms2[i]|
  def int_riscv_ztt_mabsdiff_ew : ZTT_Elementwise_Arithmetic_Intr;

  // mabsdiff.ew.x - md[i] = |scalar - ms2[i]|
  def int_riscv_ztt_mabsdiff_ew_x : ZTT_Elementwise_Arithmetic_Scalar_Intr;

  // madd.ew - md[i] = ms1[i] + ms2[i]
  def int_riscv_ztt_madd_ew : ZTT_Elementwise_Arithmetic_Intr;

  // madd.ew.x - md[i] = scalar + ms2[i]
  def int_riscv_ztt_madd_ew_x : ZTT_Elementwise_Arithmetic_Scalar_Intr;

  // msub.ew - md[i] = ms2[i] - ms1[i]
  def int_riscv_ztt_msub_ew : ZTT_Elementwise_Arithmetic_Intr;

  // msub.ew.x - md[i] = scalar - ms2[i]
  def int_riscv_ztt_msub_ew_x : ZTT_Elementwise_Arithmetic_Scalar_Intr;

  // mhdiff.ew - md[i] = (ms2[i] - ms1[i]) * 0.5
  def int_riscv_ztt_mhdiff_ew : ZTT_Elementwise_Arithmetic_Intr;

  // mhdiff.ew.x - md[i] = (scalar - ms2[i]) * 0.5
  def int_riscv_ztt_mhdiff_ew_x : ZTT_Elementwise_Arithmetic_Scalar_Intr;

  // mmax.ew - md[i] = max(ms1[i], ms2[i])
  def int_riscv_ztt_mmax_ew : ZTT_Elementwise_Arithmetic_Intr;

  // mmax.ew.x - md[i] = max(scalar, ms2[i])
  def int_riscv_ztt_mmax_ew_x : ZTT_Elementwise_Arithmetic_Scalar_Intr;

  // mmean.ew - md[i] = (ms1[i] + ms2[i]) * 0.5
  def int_riscv_ztt_mmean_ew : ZTT_Elementwise_Arithmetic_Intr;

  // mmean.ew.x - md[i] = (scalar + ms2[i]) * 0.5
  def int_riscv_ztt_mmean_ew_x : ZTT_Elementwise_Arithmetic_Scalar_Intr;

  // mmin.ew - md[i] = min(ms1[i], ms2[i])
  def int_riscv_ztt_mmin_ew : ZTT_Elementwise_Arithmetic_Intr;

  // mmin.ew.x - md[i] = min(scalar, ms2[i])
  def int_riscv_ztt_mmin_ew_x : ZTT_Elementwise_Arithmetic_Scalar_Intr;

  // mmul.ew - md[i] = ms1[i] * ms2[i]
  def int_riscv_ztt_mmul_ew : ZTT_Elementwise_Arithmetic_Intr;

  // mmul.ew.x - md[i] = scalar * ms2[i]
  def int_riscv_ztt_mmul_ew_x : ZTT_Elementwise_Arithmetic_Scalar_Intr;

  // mmulacc.ew - md[i] = md[i] + ms1[i] * ms2[i]
  def int_riscv_ztt_mmulacc_ew : ZTT_Elementwise_Arithmetic_Intr;

  // mmulacc.ew.x - md[i] = md[i] + scalar * ms2[i]
  def int_riscv_ztt_mmulacc_ew_x : ZTT_Elementwise_Arithmetic_Scalar_Intr;

  // mmulaccneg.ew - md[i] = md[i] - ms1[i] * ms2[i]
  def int_riscv_ztt_mmulaccneg_ew : ZTT_Elementwise_Arithmetic_Intr;

  // mmulaccneg.ew.x - md[i] = md[i] - scalar * ms2[i]
  def int_riscv_ztt_mmulaccneg_ew_x : ZTT_Elementwise_Arithmetic_Scalar_Intr;

  // mmuladd.ew - md[i] = ms1[i] + ms2[i] * md[i]
  def int_riscv_ztt_mmuladd_ew : ZTT_Elementwise_Arithmetic_Intr;

  // mmuladd.ew.x - md[i] = scalar + ms2[i] * md[i]
  def int_riscv_ztt_mmuladd_ew_x : ZTT_Elementwise_Arithmetic_Scalar_Intr;

  // mmulneg.ew - md[i] = -(ms1[i] * ms2[i])
  def int_riscv_ztt_mmulneg_ew : ZTT_Elementwise_Arithmetic_Intr;

  // mmulneg.ew.x - md[i] = -(scalar * ms2[i])
  def int_riscv_ztt_mmulneg_ew_x : ZTT_Elementwise_Arithmetic_Scalar_Intr;

  // mmulsub.ew - md[i] = ms1[i] - ms2[i] * md[i]
  def int_riscv_ztt_mmulsub_ew : ZTT_Elementwise_Arithmetic_Intr;

  // mmulsub.ew.x - md[i] = scalar - ms2[i] * md[i]
  def int_riscv_ztt_mmulsub_ew_x : ZTT_Elementwise_Arithmetic_Scalar_Intr;
}

//===----------------------------------------------------------------------===//
// Bitwise intrinsics
//===----------------------------------------------------------------------===//
// Base class for matrix-matrix bitwise ops.
// Signature: void (md_reg_index: i32, ms1_reg_index: i32, ms2_reg_index: i32)
class ZTT_Bitwise_Intr
    : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [
      IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>, ImmArg<ArgIndex<1>>,
      ImmArg<ArgIndex<2>>
    ]>;

// Base class for matrix-scalar bitwise ops.
// Signature: void (md_reg_index: i32, scalar: i32, ms2_reg_index: i32)
class ZTT_Bitwise_Scalar_Intr
    : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty],
                [IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>, ImmArg<ArgIndex<2>>]>;

let TargetPrefix = "riscv" in {
  // mand.ew - md[i] = ms1[i] & ms2[i]
  def int_riscv_ztt_mand_ew : ZTT_Bitwise_Intr;

  // mand.ew.x - md[i] = scalar & ms2[i]
  def int_riscv_ztt_mand_ew_x : ZTT_Bitwise_Scalar_Intr;

  // mandnot.ew - md[i] = ms1[i] & ~ms2[i]
  def int_riscv_ztt_mandnot_ew : ZTT_Bitwise_Intr;

  // mandnot.ew.x - md[i] = scalar & ~ms2[i]
  def int_riscv_ztt_mandnot_ew_x : ZTT_Bitwise_Scalar_Intr;

  // mor.ew - md[i] = ms1[i] | ms2[i]
  def int_riscv_ztt_mor_ew : ZTT_Bitwise_Intr;

  // mor.ew.x - md[i] = scalar | ms2[i]
  def int_riscv_ztt_mor_ew_x : ZTT_Bitwise_Scalar_Intr;

  // mornot.ew - md[i] = ms1[i] | ~ms2[i]
  def int_riscv_ztt_mornot_ew : ZTT_Bitwise_Intr;

  // mornot.ew.x - md[i] = scalar | ~ms2[i]
  def int_riscv_ztt_mornot_ew_x : ZTT_Bitwise_Scalar_Intr;

  // mxor.ew - md[i] = ms1[i] ^ ms2[i]
  def int_riscv_ztt_mxor_ew : ZTT_Bitwise_Intr;

  // mxor.ew.x - md[i] = scalar ^ ms2[i]
  def int_riscv_ztt_mxor_ew_x : ZTT_Bitwise_Scalar_Intr;
}

//===----------------------------------------------------------------------===//
// Scalar broadcast intrinsic
//===----------------------------------------------------------------------===//
let TargetPrefix = "riscv" in {
  // mbcast.x - broadcast a GPR value to every element of a matrix register
  // (md). Signature: void (md_reg_index: i32, scalar: i32)
  def int_riscv_ztt_mbcast_x
      : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty],
                  [IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>]>;
}

//===----------------------------------------------------------------------===//
// Compare and predication intrinsics
//===----------------------------------------------------------------------===//
// Base class for matrix-matrix compare/predicate ops.
// Signature: void (md_reg_index: i32, pred_or_src0_reg_index: i32,
// src1_reg_index: i32)
class ZTT_Comp_Pred_Intr
    : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [
      IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>, ImmArg<ArgIndex<1>>,
      ImmArg<ArgIndex<2>>
    ]>;

// Base class for matrix-scalar compare ops.
// Signature: void (md_reg_index: i32, scalar: i32, src1_reg_index: i32)
class ZTT_Comp_Pred_Scalar_Intr
    : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty],
                [IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>, ImmArg<ArgIndex<2>>]>;

let TargetPrefix = "riscv" in {
  // mcmovge.ew - md[i] = src1[i] if pred[i] >= 0, else md[i] unchanged.
  def int_riscv_ztt_mcmovge_ew : ZTT_Comp_Pred_Intr;

  // mcmovlt.ew - md[i] = src1[i] if pred[i] < 0, else md[i] unchanged.
  def int_riscv_ztt_mcmovlt_ew : ZTT_Comp_Pred_Intr;

  // mcmpge.ew - md[i] = (src0[i] >= src1[i]) ? -1 : 0.
  def int_riscv_ztt_mcmpge_ew : ZTT_Comp_Pred_Intr;

  // mcmpge.ew.x - md[i] = (scalar >= src1[i]) ? -1 : 0.
  def int_riscv_ztt_mcmpge_ew_x : ZTT_Comp_Pred_Scalar_Intr;

  // mcmplt.ew - md[i] = (src0[i] < src1[i]) ? -1 : 0.
  def int_riscv_ztt_mcmplt_ew : ZTT_Comp_Pred_Intr;

  // mcmplt.ew.x - md[i] = (scalar < src1[i]) ? -1 : 0.
  def int_riscv_ztt_mcmplt_ew_x : ZTT_Comp_Pred_Scalar_Intr;

  // mselge.ew - md[i] = src1[i] if pred[i] >= 0, else md[i] = 0
  def int_riscv_ztt_mselge_ew : ZTT_Comp_Pred_Intr;

  // msellt.ew - md[i] = src1[i] if pred[i] < 0, else md[i] = 0
  def int_riscv_ztt_msellt_ew : ZTT_Comp_Pred_Intr;
}

//===----------------------------------------------------------------------===//
// Permutation intrinsics
//===----------------------------------------------------------------------===//
// Base class for 2-operand permutation intrinsics.
// Signature: void (md_reg_index: i32, ms1_reg_index: i32)
class ZTT_Perm2_Intr : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [
  IntrHasSideEffects,
  IntrNoMem,
  ImmArg<ArgIndex<0>>,
  ImmArg<ArgIndex<1>>,
]>;

// Base class for 3-operand permutation intrinsics.
// Signature: void (md_reg_index: i32, ms1_reg_index: i32, ms2_reg_index: i32)
class ZTT_Perm3_Intr : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [
  IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>, ImmArg<ArgIndex<1>>,
  ImmArg<ArgIndex<2>>
]>;

let TargetPrefix = "riscv" in {
  // Note: N = sqrt(ZTT_NELEM)

  // mcolunzip.ew - elementwise column un-zip (de-interleave).
  // Given 0 <= i < N and 0 <= j < N/2
  // md[i, j] = ms1[i, 2j]
  // md[i, j + N/2] = ms1[i, 2j + 1]
  def int_riscv_ztt_mcolunzip_ew : ZTT_Perm2_Intr;

  // mcolzip.ew - elementwise column zip (interleave).
  // Given 0 <= i < N and 0 <= j < N/2
  // md[i, 2j] = ms1[i, j]
  // md[i, 2j + 1] = ms1[i, j + N/2]
  def int_riscv_ztt_mcolzip_ew : ZTT_Perm2_Intr;

  // mgather.ew - elementwise gather
  // Given 0 <= i < N and 0 <= j < N
  // md[i, j] = ms1[i, ms2[i, j]]
  def int_riscv_ztt_mgather_ew : ZTT_Perm3_Intr;

  // mrowunzip.ew - row un-zip (de-interleave rows)
  // Given 0 <= k < N, 0 <= j < N and that ms1 is treated as a conceptual 2N-row
  // matrix stored across (ms1, ms+1).
  // md[k, j] = ms1[2k, j]
  // md+1[k, j] = ms1[2k+1, j]
  def int_riscv_ztt_mrowunzip_ew : ZTT_Perm2_Intr;

  // mrowzip.ew - row zip (interleave rows from 2 inputs)
  // Given 0 <= k < 2N-1, 0 <= j < N and that md is treated as a conceptual
  // 2N-row matrix stord across (md, md+1). md[2k, j] = ms1[k, j] md[2k+1, j] =
  // ms2[k, j]
  def int_riscv_ztt_mrowzip_ew : ZTT_Perm3_Intr;

  // mscatadd.col - elementwise column scatter-add
  // Given i <= 0 < N, 0 <= j < N
  // md[ms2[i, j], j] += ms1[i, j]
  def int_riscv_ztt_mscatadd_col : ZTT_Perm3_Intr;

  // mscatadd.row - elementwise scatter-add
  // Given i <= 0 < N, 0 <= j < N
  // md[i, ms2[i, j]] += ms1[i, j]
  def int_riscv_ztt_mscatadd_row : ZTT_Perm3_Intr;

  // mscatmax.col - elementwise column scatter-max
  // Given i <= 0 < N, 0 <= j < N
  // md[ms2[i, j], j] = max(md[ms2[i, j], j], ms1[i, j])
  def int_riscv_ztt_mscatmax_col : ZTT_Perm3_Intr;

  // mscatmax.row - elementwise scatter-max
  // Given i <= 0 < N, 0 <= j < N
  // md[i, ms2[i, j]] = max(md[i, ms2[i, j]], ms1[i, j])
  def int_riscv_ztt_mscatmax_row : ZTT_Perm3_Intr;

  // mshift.ew - elementwise row shift by constant offset
  // Given i <= 0 < N, 0 <= j < N
  // md[i, j] = md[i, j + imm] if 0 <= j + imm < N else md[i, j] = 0
  def int_riscv_ztt_mshift_ew : ZTT_Perm3_Intr;
}

//===----------------------------------------------------------------------===//
// Register move / data conversion intrinsics
//===----------------------------------------------------------------------===//
// Base class for packing / unpacking intrinsics.
// Signature: void (md_reg_index: i32, ms1_reg_index: i32, scalar: i32)
class ZTT_PackUnpack_Intr
    : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [
      IntrHasSideEffects,
      IntrNoMem,
      ImmArg<ArgIndex<0>>,
      ImmArg<ArgIndex<1>>,
    ]>;

let TargetPrefix = "riscv" in {
  // mconv.ew - convert between packed and non-packed dtype (Md[ms1] vs
  // Md[md]); exactly one side must be packed, else amestatus.UN.
  // NOTE: pseudocode in spec assumes non-packed side is unit-sized (1
  // reg/square); unclear if "wide" non-packed dtypes (>1 reg/square) are valid
  // operands here.
  def int_riscv_ztt_mconv_ew : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [
    IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>, ImmArg<ArgIndex<1>>
  ]>;

  // mpack.ew.x - pack the square from the ms1 register (unpacked,
  // single-square) into the packed md (matrix) register's sub-square slot
  // selected by scalar index
  // NOTE: pseudocode in spec assumes non-packed side is unit-sized (1
  // reg/square); unclear if "wide" non-packed dtypes (>1 reg/square) are valid
  // operands here.
  def int_riscv_ztt_mpack_ew_x : ZTT_PackUnpack_Intr;

  // munpack.ew.x - extracts a square (selected by scalar index) from the ms1
  // register (packed) into the unpacked md (matrix) register
  // NOTE: pseudocode in spec assumes non-packed side is unit-sized (1
  // reg/square); unclear if "wide" non-packed dtypes (>1 reg/square) are valid
  // operands here.
  def int_riscv_ztt_munpack_ew_x : ZTT_PackUnpack_Intr;
}

//===----------------------------------------------------------------------===//
// Log2 and Exp2 intrinsics
//===----------------------------------------------------------------------===//
// Base class for 2-operand elementwise matrix-matrix log2/exp2 intrinsics.
// Signature: void (md_reg_index: i32, ms1_reg_index: i32)
class ZTT_Log2Exp2_2_Intr : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [
  IntrHasSideEffects,
  IntrNoMem,
  ImmArg<ArgIndex<0>>,
  ImmArg<ArgIndex<1>>,
]>;

// Base class for 3-operand elementwise matrix-matrix log2/exp2 intrinsics.
// Signature: void (md_reg_index: i32, ms1_reg_index: i32, ms2_reg_index: i32)
class ZTT_Log2Exp2_3_Intr
    : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [
      IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>, ImmArg<ArgIndex<1>>,
      ImmArg<ArgIndex<2>>
    ]>;

// Base class for elementwise matrix-scalar log2/exp2 intrinsics.
// Signature: void (md_reg_index: i32, scalar: i32, ms2_reg_index: i32)
class ZTT_Log2Exp2_Scalar_Intr
    : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty],
                [IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>, ImmArg<ArgIndex<2>>]>;

let TargetPrefix = "riscv" in {
  // mexp2.ew - md[i] = 2^ms1[i]
  def int_riscv_ztt_mexp2_ew : ZTT_Log2Exp2_2_Intr;

  // mldexp.ew - md[i] = ms1[i] * 2^ms1[i]
  def int_riscv_ztt_mldexp_ew : ZTT_Log2Exp2_3_Intr;

  // mldexp.ew.x - md[i] = ms2[i] * 2^scalar
  def int_riscv_ztt_mldexp_ew_x : ZTT_Log2Exp2_Scalar_Intr;

  // mldexpacc.ew - md[i] = md[i] + ms1[i] * 2^ms1[i]
  def int_riscv_ztt_mldexpacc_ew : ZTT_Log2Exp2_3_Intr;

  // mldexpacc.ew.x - md[i] = md[i] + ms2[i] * 2^scalar
  def int_riscv_ztt_mldexpacc_ew_x : ZTT_Log2Exp2_Scalar_Intr;

  // mlog2.ew - md[i] = log2(ms1[i])
  def int_riscv_ztt_mlog2_ew : ZTT_Log2Exp2_2_Intr;

  // mlog2sub.ew - md[i] = log2(|ms1[i]|) - ms2[i]
  def int_riscv_ztt_mlog2sub_ew : ZTT_Log2Exp2_3_Intr;

  // mlog2sub.ew.x - md[i] = log2(|ms2[i]|) - scalar
  def int_riscv_ztt_mlog2sub_ew_x : ZTT_Log2Exp2_Scalar_Intr;

  // mrdexp.ew - md[i] = ms1[i] * 2^(-ms2[i])
  def int_riscv_ztt_mrdexp_ew : ZTT_Log2Exp2_3_Intr;

  // mrdexpacc.ew - md[i] = md[i] + ms1[i] * 2^(-ms2[i])
  def int_riscv_ztt_mrdexpacc_ew : ZTT_Log2Exp2_3_Intr;

  // msublog2.ew - md[i] = ms2[i] - log2(|ms1[i]|)
  def int_riscv_ztt_msublog2_ew : ZTT_Log2Exp2_3_Intr;

  // msublog2.ew.x - md[i] = scalar - log2(|ms2[i]|)
  def int_riscv_ztt_msublog2_ew_x : ZTT_Log2Exp2_Scalar_Intr;
}

//===----------------------------------------------------------------------===//
// Load/store (memory) intrinsics
//===----------------------------------------------------------------------===//
// Base class for square loads: loads ZTT_NELEM elements from memory at addr
// into the matrix register group (md).
// Signature: void (md_reg_index: i32, addr: i32)
class ZTT_Load_Intr
    : Intrinsic<[], [llvm_i64_ty, llvm_ptr_ty],
                [IntrReadMem, IntrHasSideEffects, ImmArg<ArgIndex<0>>]>;

// Base class for square stores: stores ZTT_NELEM elements from the matrix
// register group (md) into memory at addr.
// Signature: void (md_reg_index: i32, addr: i32)
class ZTT_Store_Intr
    : Intrinsic<[], [llvm_i64_ty, llvm_ptr_ty],
                [IntrWriteMem, IntrHasSideEffects, ImmArg<ArgIndex<0>>]>;

let TargetPrefix = "riscv" in {
  // mls - load using the implementation-defined layout (must match a pripr mss
  // to memory).
  def int_riscv_ztt_mls : ZTT_Load_Intr;

  // mls.cm / mls.rm - load with an explicit column-major / row-major layout.
  def int_riscv_ztt_mls_cm : ZTT_Load_Intr;
  def int_riscv_ztt_mls_rm : ZTT_Load_Intr;

  // mss - store using the implementation-defined layout.
  def int_riscv_ztt_mss : ZTT_Store_Intr;

  // mss.cm / mss.rm - store with an explicit column-major / row-major layout.
  def int_riscv_ztt_mss_cm : ZTT_Store_Intr;
  def int_riscv_ztt_mss_rm : ZTT_Store_Intr;
}

//===----------------------------------------------------------------------===//
// State management intrinsics
//===----------------------------------------------------------------------===//
// Base class for register-to-register move intrinsics: both operands are M/Acc
// registers Signature: void (dest_reg_index: i32, src_reg_index: i32)
class ZTT_Move_Intr
    : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty],
                [IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>, ImmArg<ArgIndex<1>>]>;

let TargetPrefix = "riscv" in {
  // mmov.a.m - copy an Acc register to an M register group; dtypes must
  // match, else amestatus.UN is set and dest is left untouched
  def int_riscv_ztt_mmov_a_m : ZTT_Move_Intr;

  // mmov.m.m - copy one M register to another; dtypes must
  // match, else amestatus.UN is set and dest is left untouched
  def int_riscv_ztt_mmov_m_m : ZTT_Move_Intr;

  // mzero.2d - zero every element of an Acc register.
  // Signature: void (acc_reg_index: i32)
  def int_riscv_ztt_mzero_2d
      : Intrinsic<[], [llvm_i64_ty], [IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>]>;
}

//===----------------------------------------------------------------------===//
// Matrix multiply intrinsics
//===----------------------------------------------------------------------===//
// Base class for matrix multiply intrinsics
// Signature: void (acc_reg_index: i32, ms1_reg_index: i32, ms2_reg_index: i32)
class ZTT_MatMul_Intr : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [
  IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>, ImmArg<ArgIndex<1>>,
  ImmArg<ArgIndex<2>>
]>;

let TargetPrefix = "riscv" in {
  // mmul.2d - acc[i, j] = sum over k of (ms1[i, k] * ms2[k, j]
  def int_riscv_ztt_mmul_2d : ZTT_MatMul_Intr;

  // mmulneg.2d - acc[i, j] = -(sum over k of (ms1[i, k] * ms2[k, j])
  def int_riscv_ztt_mmulneg_2d : ZTT_MatMul_Intr;

  // mmulacc.2d - acc[i, j] += sum over k of (ms1[i, k] * ms2[k, j]
  def int_riscv_ztt_mmulacc_2d : ZTT_MatMul_Intr;

  // mmulaccneg.2d - acc[i, j] -= sum over k of (ms1[i, k] * ms2[k, j]
  def int_riscv_ztt_mmulaccneg_2d : ZTT_MatMul_Intr;

  // mmulat.2d - acc[i, j] = sum over k of (ms1[k, i] * ms2[k, j]
  def int_riscv_ztt_mmulat_2d : ZTT_MatMul_Intr;

  // mmulatacc.2d - acc[i, j] += sum over k of (ms1[k, i] * ms2[k, j]
  def int_riscv_ztt_mmulatacc_2d : ZTT_MatMul_Intr;

  // mmulbt.2d - acc[i, j] = sum over k of (ms1[i, k] * ms2[j, k]
  def int_riscv_ztt_mmulbt_2d : ZTT_MatMul_Intr;

  // mmulbtacc.2d - acc[i, j] += sum over k of (ms1[i, k] * ms2[j, k]
  def int_riscv_ztt_mmulbtacc_2d : ZTT_MatMul_Intr;
}

//===----------------------------------------------------------------------===//
// Reduction intrinsics
//===----------------------------------------------------------------------===//
// Base class for reduction intrinsics.
// Signature: void (md_reg_index: i32, ms1_reg_index: i32)
class ZTT_Reduction_Intr
    : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty],
                [IntrHasSideEffects, IntrNoMem, ImmArg<ArgIndex<0>>, ImmArg<ArgIndex<1>>]>;

let TargetPrefix = "riscv" in {
  // mprefixadd.col - md[i, j] = sum over k <= i of ms1[k, j]
  def int_riscv_ztt_mprefixadd_col : ZTT_Reduction_Intr;

  // mprefixadd.row - md[i, j] = sum over k <= j of ms1[i, k]
  def int_riscv_ztt_mprefixadd_row : ZTT_Reduction_Intr;

  // mprefixmax.col - md[i, j] = max over k <= i of ms1[k, j]
  def int_riscv_ztt_mprefixmax_col : ZTT_Reduction_Intr;

  // mprefixmax.row - md[i, j] = max over k <= j of ms1[i, k]
  def int_riscv_ztt_mprefixmax_row : ZTT_Reduction_Intr;

  // mreduceadd.col - md[i, j] = sum over k of ms1[k, j]
  def int_riscv_ztt_mreduceadd_col : ZTT_Reduction_Intr;

  // mreduceadd.row - md[i, j] = sum over k of ms1[i, k]
  def int_riscv_ztt_mreduceadd_row : ZTT_Reduction_Intr;

  // mreducemax.col - md[i, j] = max over k of ms1[k, j]
  def int_riscv_ztt_mreducemax_col : ZTT_Reduction_Intr;

  // mreducemax.row - md[i, j] = max over k of ms1[i, k]
  def int_riscv_ztt_mreducemax_row : ZTT_Reduction_Intr;
}
