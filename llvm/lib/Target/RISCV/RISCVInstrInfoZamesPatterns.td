//===-- RISCVInstrInfoZamesPatterns.td - ZAMES/ZMASYNC pseudos -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// ZAMES/ZMASYNC codegen-only pseudos and SelectionDAG patterns.
//
// Ordinary load/store, mzero and mmacc go through a two-level pseudo:
//   intrinsic -> PSEUDO_ZAMES_*_PRE -> (pre-RA: materialize cfg payload GPR)
//   -> PSEUDO_ZAMES_* with cfg operands -> RA -> (post-RA: emit msetcfg by
//   final TR/ACC encoding) -> real ZAMES instruction.
//
// msettile*, msetcfg/mgetcfg, minit, *.whole and the four ZMASYNC
// instructions are selected directly to real instructions.
//
// mmacc operand reorder: LLVM IR operands are A, B, C (the intrinsic
// overload suffix lists the C, A, B *type* sequence, not the operand order);
// the typed pseudo and real instruction use the machine order C, B, A.
//
//===----------------------------------------------------------------------===//

// Defensive second-layer immediate constraints. The ImmArg/Range intrinsic
// attributes reject out-of-range constants in the IR verifier; these leaves
// additionally prevent ISel from silently truncating an out-of-range target
// constant into the 10-bit tile field or the 3-bit config selector when the
// verifier is disabled or a transform built an illegal DAG.
def zames_tuimm10 : TImmLeaf<XLenVT, [{ return isUInt<10>(Imm); }]>;
def zames_tuimm3  : TImmLeaf<XLenVT, [{ return isUInt<3>(Imm); }]>;

let Predicates = [HasStdExtZames, IsRV64], hasSideEffects = 1, mayLoad = 1,
    mayStore = 0, isCodeGenOnly = 1 in {
  def PSEUDO_ZAMES_MLA_A_I8_PRE
      : Pseudo<(outs ZamesTileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_ZAMES_MLB_B_I8_PRE
      : Pseudo<(outs ZamesTileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_ZAMES_MLBT_B_I8_PRE
      : Pseudo<(outs ZamesTileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_ZAMES_MLAT_A_I8_PRE
      : Pseudo<(outs ZamesTileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_ZAMES_MLC_C_I32_PRE
      : Pseudo<(outs ZamesAccReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_ZAMES_MLCT_C_I32_PRE
      : Pseudo<(outs ZamesAccReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }

  def PSEUDO_ZAMES_MLA_A_I8
      : Pseudo<(outs ZamesTileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
    let Size = 8;
  }
  def PSEUDO_ZAMES_MLB_B_I8
      : Pseudo<(outs ZamesTileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
    let Size = 8;
  }
  def PSEUDO_ZAMES_MLBT_B_I8
      : Pseudo<(outs ZamesTileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
    let Size = 8;
  }
  def PSEUDO_ZAMES_MLAT_A_I8
      : Pseudo<(outs ZamesTileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
    let Size = 8;
  }
  def PSEUDO_ZAMES_MLC_C_I32
      : Pseudo<(outs ZamesAccReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
    let Size = 8;
  }
  def PSEUDO_ZAMES_MLCT_C_I32
      : Pseudo<(outs ZamesAccReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
    let Size = 8;
  }
}

let Predicates = [HasStdExtZames, IsRV64], hasSideEffects = 1, mayLoad = 0,
    mayStore = 0, isCodeGenOnly = 1 in {
  def PSEUDO_ZAMES_MZERO_C_I32_PRE : Pseudo<(outs ZamesAccReg:$md), (ins), []> {
    let Size = 12;
  }
  def PSEUDO_ZAMES_MMACC_I8_I32_PRE
      : Pseudo<(outs ZamesAccReg:$md_wb),
               (ins ZamesAccReg:$md, ZamesTileReg:$ms2, ZamesTileReg:$ms1), []> {
    let Constraints = "$md_wb = $md";
    let Size = 28;
  }

  def PSEUDO_ZAMES_MZERO_C_I32
      : Pseudo<(outs ZamesAccReg:$md), (ins GPR:$cfg), []> {
    let Size = 8;
  }
  def PSEUDO_ZAMES_MMACC_I8_I32
      : Pseudo<(outs ZamesAccReg:$md_wb),
               (ins ZamesAccReg:$md, ZamesTileReg:$ms2, ZamesTileReg:$ms1, GPR:$cfg_c,
                    GPR:$cfg_b, GPR:$cfg_a), []> {
    let Constraints = "$md_wb = $md";
    let Size = 16;
  }
}

let Predicates = [HasStdExtZames, IsRV64], hasSideEffects = 1, mayLoad = 0,
    mayStore = 1, isCodeGenOnly = 1 in {
  def PSEUDO_ZAMES_MSC_C_I32_PRE
      : Pseudo<(outs),
               (ins ZamesAccReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_ZAMES_MSA_A_I8_PRE
      : Pseudo<(outs),
               (ins ZamesTileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_ZAMES_MSAT_A_I8_PRE
      : Pseudo<(outs),
               (ins ZamesTileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_ZAMES_MSB_B_I8_PRE
      : Pseudo<(outs),
               (ins ZamesTileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_ZAMES_MSBT_B_I8_PRE
      : Pseudo<(outs),
               (ins ZamesTileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_ZAMES_MSCT_C_I32_PRE
      : Pseudo<(outs),
               (ins ZamesAccReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }

  def PSEUDO_ZAMES_MSC_C_I32
      : Pseudo<(outs),
               (ins ZamesAccReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg),
               []> {
    let Size = 8;
  }
  def PSEUDO_ZAMES_MSA_A_I8
      : Pseudo<(outs),
               (ins ZamesTileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg),
               []> {
    let Size = 8;
  }
  def PSEUDO_ZAMES_MSAT_A_I8
      : Pseudo<(outs),
               (ins ZamesTileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg),
               []> {
    let Size = 8;
  }
  def PSEUDO_ZAMES_MSB_B_I8
      : Pseudo<(outs),
               (ins ZamesTileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg),
               []> {
    let Size = 8;
  }
  def PSEUDO_ZAMES_MSBT_B_I8
      : Pseudo<(outs),
               (ins ZamesTileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg),
               []> {
    let Size = 8;
  }
  def PSEUDO_ZAMES_MSCT_C_I32
      : Pseudo<(outs),
               (ins ZamesAccReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg),
               []> {
    let Size = 8;
  }
}

class PatZAMESSetTileReg<SDPatternOperator OpNode, Instruction Inst>
    : Pat<(OpNode (XLenVT GPR:$rs1)), (Inst GPR:$rs1)>;

// Shared shells for the typed ZAMES pseudo instructions. Concrete defs carry
// the PSEUDO_ZAMES_<OP>_<ROLE>_<TYPE> names so every instance stays
// reachable from the pre-RA and late C++ expansion switches.
class ZAMESLdPseudoPRE<RegisterClass RC>
    : Pseudo<(outs RC:$md), (ins GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
  let Size = 12;
}
class ZAMESLdPseudoCFG<RegisterClass RC>
    : Pseudo<(outs RC:$md),
             (ins GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
  let Size = 8;
}
class ZAMESStPseudoPRE<RegisterClass RC>
    : Pseudo<(outs), (ins RC:$md, GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
  let Size = 12;
}
class ZAMESStPseudoCFG<RegisterClass RC>
    : Pseudo<(outs),
             (ins RC:$md, GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
  let Size = 8;
}
class ZAMESMZeroPseudoPRE<RegisterClass RC>
    : Pseudo<(outs RC:$md), (ins), []> {
  let Size = 12;
}
class ZAMESMZeroPseudoCFG<RegisterClass RC>
    : Pseudo<(outs RC:$md), (ins GPR:$cfg), []> {
  let Size = 8;
}
class ZAMESMMAccPseudoPRE
    : Pseudo<(outs ZamesAccReg:$md_wb),
             (ins ZamesAccReg:$md, ZamesTileReg:$ms2, ZamesTileReg:$ms1), []> {
  let Constraints = "$md_wb = $md";
  let Size = 28;
}
class ZAMESMMAccPseudoCFG
    : Pseudo<(outs ZamesAccReg:$md_wb),
             (ins ZamesAccReg:$md, ZamesTileReg:$ms2, ZamesTileReg:$ms1, GPR:$cfg_c,
                  GPR:$cfg_b, GPR:$cfg_a), []> {
  let Constraints = "$md_wb = $md";
  let Size = 16;
}

// Typed load pseudo instances: A/B tiles use every supported input element;
// C accumulators use fp32.
let Predicates = [HasStdExtZames, IsRV64], hasSideEffects = 0, mayLoad = 1, mayStore = 0,
    isCodeGenOnly = 1 in {
  def PSEUDO_ZAMES_MLA_A_FP8E4_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLA_A_FP8E4 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLA_A_FP8E5_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLA_A_FP8E5 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLA_A_F16_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLA_A_F16 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLA_A_BF16_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLA_A_BF16 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLAT_A_FP8E4_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLAT_A_FP8E4 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLAT_A_FP8E5_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLAT_A_FP8E5 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLAT_A_F16_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLAT_A_F16 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLAT_A_BF16_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLAT_A_BF16 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLB_B_FP8E4_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLB_B_FP8E4 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLB_B_FP8E5_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLB_B_FP8E5 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLB_B_F16_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLB_B_F16 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLB_B_BF16_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLB_B_BF16 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLBT_B_FP8E4_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLBT_B_FP8E4 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLBT_B_FP8E5_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLBT_B_FP8E5 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLBT_B_F16_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLBT_B_F16 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLBT_B_BF16_PRE : ZAMESLdPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MLBT_B_BF16 : ZAMESLdPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MLC_C_F32_PRE : ZAMESLdPseudoPRE<ZamesAccReg>;
  def PSEUDO_ZAMES_MLC_C_F32 : ZAMESLdPseudoCFG<ZamesAccReg>;
  def PSEUDO_ZAMES_MLCT_C_F32_PRE : ZAMESLdPseudoPRE<ZamesAccReg>;
  def PSEUDO_ZAMES_MLCT_C_F32 : ZAMESLdPseudoCFG<ZamesAccReg>;
}

let Predicates = [HasStdExtZames, IsRV64], hasSideEffects = 0, mayLoad = 0, mayStore = 1,
    isCodeGenOnly = 1 in {
  def PSEUDO_ZAMES_MSA_A_FP8E4_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSA_A_FP8E4 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSA_A_FP8E5_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSA_A_FP8E5 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSA_A_F16_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSA_A_F16 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSA_A_BF16_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSA_A_BF16 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSAT_A_FP8E4_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSAT_A_FP8E4 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSAT_A_FP8E5_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSAT_A_FP8E5 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSAT_A_F16_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSAT_A_F16 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSAT_A_BF16_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSAT_A_BF16 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSB_B_FP8E4_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSB_B_FP8E4 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSB_B_FP8E5_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSB_B_FP8E5 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSB_B_F16_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSB_B_F16 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSB_B_BF16_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSB_B_BF16 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSBT_B_FP8E4_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSBT_B_FP8E4 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSBT_B_FP8E5_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSBT_B_FP8E5 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSBT_B_F16_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSBT_B_F16 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSBT_B_BF16_PRE : ZAMESStPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MSBT_B_BF16 : ZAMESStPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MSC_C_F32_PRE : ZAMESStPseudoPRE<ZamesAccReg>;
  def PSEUDO_ZAMES_MSC_C_F32 : ZAMESStPseudoCFG<ZamesAccReg>;
  def PSEUDO_ZAMES_MSCT_C_F32_PRE : ZAMESStPseudoPRE<ZamesAccReg>;
  def PSEUDO_ZAMES_MSCT_C_F32 : ZAMESStPseudoCFG<ZamesAccReg>;
}

// Typed mzero pseudo instances preserve the input/output register partition.
let Predicates = [HasStdExtZames, IsRV64], hasSideEffects = 0, mayLoad = 0, mayStore = 0,
    isCodeGenOnly = 1 in {
  def PSEUDO_ZAMES_MZERO_T_I8_PRE : ZAMESMZeroPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MZERO_T_I8 : ZAMESMZeroPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MZERO_T_FP8E4_PRE : ZAMESMZeroPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MZERO_T_FP8E4 : ZAMESMZeroPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MZERO_T_FP8E5_PRE : ZAMESMZeroPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MZERO_T_FP8E5 : ZAMESMZeroPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MZERO_T_F16_PRE : ZAMESMZeroPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MZERO_T_F16 : ZAMESMZeroPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MZERO_T_BF16_PRE : ZAMESMZeroPseudoPRE<ZamesTileReg>;
  def PSEUDO_ZAMES_MZERO_T_BF16 : ZAMESMZeroPseudoCFG<ZamesTileReg>;
  def PSEUDO_ZAMES_MZERO_C_F32_PRE : ZAMESMZeroPseudoPRE<ZamesAccReg>;
  def PSEUDO_ZAMES_MZERO_C_F32 : ZAMESMZeroPseudoCFG<ZamesAccReg>;
}

// Typed mmacc pseudo instances for the six supported combinations.
let Predicates = [HasStdExtZames, IsRV64], hasSideEffects = 0, mayLoad = 0, mayStore = 0,
    isCodeGenOnly = 1 in {
  def PSEUDO_ZAMES_MMACC_I8_F32_PRE : ZAMESMMAccPseudoPRE;
  def PSEUDO_ZAMES_MMACC_I8_F32 : ZAMESMMAccPseudoCFG;
  def PSEUDO_ZAMES_MMACC_FP8E4_F32_PRE : ZAMESMMAccPseudoPRE;
  def PSEUDO_ZAMES_MMACC_FP8E4_F32 : ZAMESMMAccPseudoCFG;
  def PSEUDO_ZAMES_MMACC_FP8E5_F32_PRE : ZAMESMMAccPseudoPRE;
  def PSEUDO_ZAMES_MMACC_FP8E5_F32 : ZAMESMMAccPseudoCFG;
  def PSEUDO_ZAMES_MMACC_F16_F32_PRE : ZAMESMMAccPseudoPRE;
  def PSEUDO_ZAMES_MMACC_F16_F32 : ZAMESMMAccPseudoCFG;
  def PSEUDO_ZAMES_MMACC_BF16_F32_PRE : ZAMESMMAccPseudoPRE;
  def PSEUDO_ZAMES_MMACC_BF16_F32 : ZAMESMMAccPseudoCFG;
}

class PatZAMESLoad<SDPatternOperator OpNode, Instruction Inst, ValueType RetTy>
    : Pat<(RetTy (OpNode GPRMemZeroOffset:$rs1, GPR:$rs2)),
          (Inst GPRMemZeroOffset:$rs1, GPR:$rs2)>;

class PatZAMESStore<SDPatternOperator OpNode, Instruction Inst,
                    RegisterClass Reg, ValueType RegTy>
    : Pat<(OpNode (RegTy Reg:$md), GPRMemZeroOffset:$rs1, GPR:$rs2),
          (Inst (RegTy Reg:$md), GPRMemZeroOffset:$rs1, GPR:$rs2)>;

class PatZAMESWholeLoad<SDPatternOperator OpNode, Instruction Inst,
                        ValueType RetTy>
    : Pat<(RetTy (OpNode GPRMemZeroOffset:$rs1)),
          (Inst GPRMemZeroOffset:$rs1)>;

class PatZAMESWholeStore<SDPatternOperator OpNode, Instruction Inst,
                         RegisterClass Reg, ValueType RegTy>
    : Pat<(OpNode (RegTy Reg:$md), GPRMemZeroOffset:$rs1),
          (Inst (RegTy Reg:$md), GPRMemZeroOffset:$rs1)>;

let Predicates = [HasStdExtZames, IsRV64] in {
  def : Pat<(int_riscv_zames_msettilemi zames_tuimm10:$imm),
            (ZAMES_MSETTILEMI timm:$imm)>;
  def : Pat<(int_riscv_zames_msettileni zames_tuimm10:$imm),
            (ZAMES_MSETTILENI timm:$imm)>;
  def : Pat<(int_riscv_zames_msettileki zames_tuimm10:$imm),
            (ZAMES_MSETTILEKI timm:$imm)>;

  def : PatZAMESSetTileReg<int_riscv_zames_msettilem,
                           ZAMES_MSETTILEM>;
  def : PatZAMESSetTileReg<int_riscv_zames_msettilen,
                           ZAMES_MSETTILEN>;
  def : PatZAMESSetTileReg<int_riscv_zames_msettilek,
                           ZAMES_MSETTILEK>;

  def : Pat<(int_riscv_zames_msetcfg zames_tuimm3:$cfg, (XLenVT GPR:$rs1)),
            (ZAMES_MSETCFG timm:$cfg, GPR:$rs1)>;

  def : Pat<(int_riscv_zames_minit), (ZAMES_MINIT)>;
  def : Pat<(XLenVT (int_riscv_zames_mgetcfg zames_tuimm3:$cfg)),
            (ZAMES_MGETCFG timm:$cfg)>;

  def : Pat<(mi32_t (int_riscv_zames_mzero)),
            (PSEUDO_ZAMES_MZERO_C_I32_PRE)>;

  def : PatZAMESLoad<int_riscv_zames_mla, PSEUDO_ZAMES_MLA_A_I8_PRE, mi8_t>;
  def : PatZAMESLoad<int_riscv_zames_mlb, PSEUDO_ZAMES_MLB_B_I8_PRE, mi8_t>;
  def : PatZAMESLoad<int_riscv_zames_mlbt, PSEUDO_ZAMES_MLBT_B_I8_PRE, mi8_t>;
  def : PatZAMESLoad<int_riscv_zames_mlat, PSEUDO_ZAMES_MLAT_A_I8_PRE, mi8_t>;
  def : PatZAMESLoad<int_riscv_zames_mlc, PSEUDO_ZAMES_MLC_C_I32_PRE, mi32_t>;
  def : PatZAMESLoad<int_riscv_zames_mlct, PSEUDO_ZAMES_MLCT_C_I32_PRE, mi32_t>;

  def : PatZAMESWholeLoad<int_riscv_zames_mla_whole, ZAMES_MLA_WHOLE, mi8_t>;
  def : PatZAMESWholeLoad<int_riscv_zames_mlb_whole, ZAMES_MLB_WHOLE, mi8_t>;
  def : PatZAMESWholeLoad<int_riscv_zames_mlc_whole, ZAMES_MLC_WHOLE, mi32_t>;

  def : PatZAMESWholeStore<int_riscv_zames_msa_whole, ZAMES_MSA_WHOLE,
                           ZamesTileReg, mi8_t>;
  def : PatZAMESWholeStore<int_riscv_zames_msb_whole, ZAMES_MSB_WHOLE,
                           ZamesTileReg, mi8_t>;
  def : PatZAMESWholeStore<int_riscv_zames_msc_whole, ZAMES_MSC_WHOLE,
                           ZamesAccReg, mi32_t>;

  def : Pat<(mi32_t (int_riscv_zames_mmacc (mi8_t ZamesTileReg:$rs1),
                                           (mi8_t ZamesTileReg:$rs2),
                                           (mi32_t ZamesAccReg:$rs3))),
            (PSEUDO_ZAMES_MMACC_I8_I32_PRE (mi32_t ZamesAccReg:$rs3),
                                           (mi8_t ZamesTileReg:$rs2),
                                           (mi8_t ZamesTileReg:$rs1))>;

  def : PatZAMESLoad<int_riscv_zames_mla, PSEUDO_ZAMES_MLA_A_FP8E4_PRE,
                     mf8e4_t>;
  def : PatZAMESLoad<int_riscv_zames_mla, PSEUDO_ZAMES_MLA_A_FP8E5_PRE,
                     mf8e5_t>;
  def : PatZAMESLoad<int_riscv_zames_mla, PSEUDO_ZAMES_MLA_A_F16_PRE, mf16_t>;
  def : PatZAMESLoad<int_riscv_zames_mla, PSEUDO_ZAMES_MLA_A_BF16_PRE,
                     mbf16_t>;
  def : PatZAMESLoad<int_riscv_zames_mlat, PSEUDO_ZAMES_MLAT_A_FP8E4_PRE,
                     mf8e4_t>;
  def : PatZAMESLoad<int_riscv_zames_mlat, PSEUDO_ZAMES_MLAT_A_FP8E5_PRE,
                     mf8e5_t>;
  def : PatZAMESLoad<int_riscv_zames_mlat, PSEUDO_ZAMES_MLAT_A_F16_PRE,
                     mf16_t>;
  def : PatZAMESLoad<int_riscv_zames_mlat, PSEUDO_ZAMES_MLAT_A_BF16_PRE,
                     mbf16_t>;
  def : PatZAMESLoad<int_riscv_zames_mlb, PSEUDO_ZAMES_MLB_B_FP8E4_PRE,
                     mf8e4_t>;
  def : PatZAMESLoad<int_riscv_zames_mlb, PSEUDO_ZAMES_MLB_B_FP8E5_PRE,
                     mf8e5_t>;
  def : PatZAMESLoad<int_riscv_zames_mlb, PSEUDO_ZAMES_MLB_B_F16_PRE, mf16_t>;
  def : PatZAMESLoad<int_riscv_zames_mlb, PSEUDO_ZAMES_MLB_B_BF16_PRE,
                     mbf16_t>;
  def : PatZAMESLoad<int_riscv_zames_mlbt, PSEUDO_ZAMES_MLBT_B_FP8E4_PRE,
                     mf8e4_t>;
  def : PatZAMESLoad<int_riscv_zames_mlbt, PSEUDO_ZAMES_MLBT_B_FP8E5_PRE,
                     mf8e5_t>;
  def : PatZAMESLoad<int_riscv_zames_mlbt, PSEUDO_ZAMES_MLBT_B_F16_PRE,
                     mf16_t>;
  def : PatZAMESLoad<int_riscv_zames_mlbt, PSEUDO_ZAMES_MLBT_B_BF16_PRE,
                     mbf16_t>;
  def : PatZAMESLoad<int_riscv_zames_mlc, PSEUDO_ZAMES_MLC_C_F32_PRE, mf32_t>;
  def : PatZAMESLoad<int_riscv_zames_mlct, PSEUDO_ZAMES_MLCT_C_F32_PRE,
                     mf32_t>;

  def : PatZAMESStore<int_riscv_zames_msa, PSEUDO_ZAMES_MSA_A_FP8E4_PRE,
                      ZamesTileReg, mf8e4_t>;
  def : PatZAMESStore<int_riscv_zames_msa, PSEUDO_ZAMES_MSA_A_FP8E5_PRE,
                      ZamesTileReg, mf8e5_t>;
  def : PatZAMESStore<int_riscv_zames_msa, PSEUDO_ZAMES_MSA_A_F16_PRE,
                      ZamesTileReg, mf16_t>;
  def : PatZAMESStore<int_riscv_zames_msa, PSEUDO_ZAMES_MSA_A_BF16_PRE,
                      ZamesTileReg, mbf16_t>;
  def : PatZAMESStore<int_riscv_zames_msat, PSEUDO_ZAMES_MSAT_A_FP8E4_PRE,
                      ZamesTileReg, mf8e4_t>;
  def : PatZAMESStore<int_riscv_zames_msat, PSEUDO_ZAMES_MSAT_A_FP8E5_PRE,
                      ZamesTileReg, mf8e5_t>;
  def : PatZAMESStore<int_riscv_zames_msat, PSEUDO_ZAMES_MSAT_A_F16_PRE,
                      ZamesTileReg, mf16_t>;
  def : PatZAMESStore<int_riscv_zames_msat, PSEUDO_ZAMES_MSAT_A_BF16_PRE,
                      ZamesTileReg, mbf16_t>;
  def : PatZAMESStore<int_riscv_zames_msb, PSEUDO_ZAMES_MSB_B_FP8E4_PRE,
                      ZamesTileReg, mf8e4_t>;
  def : PatZAMESStore<int_riscv_zames_msb, PSEUDO_ZAMES_MSB_B_FP8E5_PRE,
                      ZamesTileReg, mf8e5_t>;
  def : PatZAMESStore<int_riscv_zames_msb, PSEUDO_ZAMES_MSB_B_F16_PRE,
                      ZamesTileReg, mf16_t>;
  def : PatZAMESStore<int_riscv_zames_msb, PSEUDO_ZAMES_MSB_B_BF16_PRE,
                      ZamesTileReg, mbf16_t>;
  def : PatZAMESStore<int_riscv_zames_msbt, PSEUDO_ZAMES_MSBT_B_FP8E4_PRE,
                      ZamesTileReg, mf8e4_t>;
  def : PatZAMESStore<int_riscv_zames_msbt, PSEUDO_ZAMES_MSBT_B_FP8E5_PRE,
                      ZamesTileReg, mf8e5_t>;
  def : PatZAMESStore<int_riscv_zames_msbt, PSEUDO_ZAMES_MSBT_B_F16_PRE,
                      ZamesTileReg, mf16_t>;
  def : PatZAMESStore<int_riscv_zames_msbt, PSEUDO_ZAMES_MSBT_B_BF16_PRE,
                      ZamesTileReg, mbf16_t>;
  def : PatZAMESStore<int_riscv_zames_msc, PSEUDO_ZAMES_MSC_C_F32_PRE, ZamesAccReg,
                      mf32_t>;
  def : PatZAMESStore<int_riscv_zames_msct, PSEUDO_ZAMES_MSCT_C_F32_PRE,
                      ZamesAccReg, mf32_t>;

  def : PatZAMESWholeLoad<int_riscv_zames_mla_whole, ZAMES_MLA_WHOLE,
                          mf8e4_t>;
  def : PatZAMESWholeLoad<int_riscv_zames_mla_whole, ZAMES_MLA_WHOLE,
                          mf8e5_t>;
  def : PatZAMESWholeLoad<int_riscv_zames_mla_whole, ZAMES_MLA_WHOLE,
                          mf16_t>;
  def : PatZAMESWholeLoad<int_riscv_zames_mla_whole, ZAMES_MLA_WHOLE,
                          mbf16_t>;
  def : PatZAMESWholeLoad<int_riscv_zames_mlb_whole, ZAMES_MLB_WHOLE,
                          mf8e4_t>;
  def : PatZAMESWholeLoad<int_riscv_zames_mlb_whole, ZAMES_MLB_WHOLE,
                          mf8e5_t>;
  def : PatZAMESWholeLoad<int_riscv_zames_mlb_whole, ZAMES_MLB_WHOLE,
                          mf16_t>;
  def : PatZAMESWholeLoad<int_riscv_zames_mlb_whole, ZAMES_MLB_WHOLE,
                          mbf16_t>;
  def : PatZAMESWholeLoad<int_riscv_zames_mlc_whole, ZAMES_MLC_WHOLE, mf32_t>;
  def : PatZAMESWholeStore<int_riscv_zames_msa_whole, ZAMES_MSA_WHOLE,
                           ZamesTileReg, mf8e4_t>;
  def : PatZAMESWholeStore<int_riscv_zames_msa_whole, ZAMES_MSA_WHOLE,
                           ZamesTileReg, mf8e5_t>;
  def : PatZAMESWholeStore<int_riscv_zames_msa_whole, ZAMES_MSA_WHOLE,
                           ZamesTileReg, mf16_t>;
  def : PatZAMESWholeStore<int_riscv_zames_msa_whole, ZAMES_MSA_WHOLE,
                           ZamesTileReg, mbf16_t>;
  def : PatZAMESWholeStore<int_riscv_zames_msb_whole, ZAMES_MSB_WHOLE,
                           ZamesTileReg, mf8e4_t>;
  def : PatZAMESWholeStore<int_riscv_zames_msb_whole, ZAMES_MSB_WHOLE,
                           ZamesTileReg, mf8e5_t>;
  def : PatZAMESWholeStore<int_riscv_zames_msb_whole, ZAMES_MSB_WHOLE,
                           ZamesTileReg, mf16_t>;
  def : PatZAMESWholeStore<int_riscv_zames_msb_whole, ZAMES_MSB_WHOLE,
                           ZamesTileReg, mbf16_t>;
  def : PatZAMESWholeStore<int_riscv_zames_msc_whole, ZAMES_MSC_WHOLE,
                           ZamesAccReg, mf32_t>;

  def : Pat<(mi8_t (int_riscv_zames_mzero)), (PSEUDO_ZAMES_MZERO_T_I8_PRE)>;
  def : Pat<(mf8e4_t (int_riscv_zames_mzero)),
            (PSEUDO_ZAMES_MZERO_T_FP8E4_PRE)>;
  def : Pat<(mf8e5_t (int_riscv_zames_mzero)),
            (PSEUDO_ZAMES_MZERO_T_FP8E5_PRE)>;
  def : Pat<(mf16_t (int_riscv_zames_mzero)), (PSEUDO_ZAMES_MZERO_T_F16_PRE)>;
  def : Pat<(mbf16_t (int_riscv_zames_mzero)),
            (PSEUDO_ZAMES_MZERO_T_BF16_PRE)>;
  def : Pat<(mf32_t (int_riscv_zames_mzero)), (PSEUDO_ZAMES_MZERO_C_F32_PRE)>;

  def : Pat<(mf32_t (int_riscv_zames_mmacc (mi8_t ZamesTileReg:$rs1),
                                            (mi8_t ZamesTileReg:$rs2),
                                            (mf32_t ZamesAccReg:$rs3))),
            (PSEUDO_ZAMES_MMACC_I8_F32_PRE (mf32_t ZamesAccReg:$rs3),
                                           (mi8_t ZamesTileReg:$rs2),
                                           (mi8_t ZamesTileReg:$rs1))>;
  def : Pat<(mf32_t (int_riscv_zames_mmacc (mf8e4_t ZamesTileReg:$rs1),
                                            (mf8e4_t ZamesTileReg:$rs2),
                                            (mf32_t ZamesAccReg:$rs3))),
            (PSEUDO_ZAMES_MMACC_FP8E4_F32_PRE (mf32_t ZamesAccReg:$rs3),
                                              (mf8e4_t ZamesTileReg:$rs2),
                                              (mf8e4_t ZamesTileReg:$rs1))>;
  def : Pat<(mf32_t (int_riscv_zames_mmacc (mf8e5_t ZamesTileReg:$rs1),
                                            (mf8e5_t ZamesTileReg:$rs2),
                                            (mf32_t ZamesAccReg:$rs3))),
            (PSEUDO_ZAMES_MMACC_FP8E5_F32_PRE (mf32_t ZamesAccReg:$rs3),
                                              (mf8e5_t ZamesTileReg:$rs2),
                                              (mf8e5_t ZamesTileReg:$rs1))>;
  def : Pat<(mf32_t (int_riscv_zames_mmacc (mf16_t ZamesTileReg:$rs1),
                                            (mf16_t ZamesTileReg:$rs2),
                                            (mf32_t ZamesAccReg:$rs3))),
            (PSEUDO_ZAMES_MMACC_F16_F32_PRE (mf32_t ZamesAccReg:$rs3),
                                            (mf16_t ZamesTileReg:$rs2),
                                            (mf16_t ZamesTileReg:$rs1))>;
  def : Pat<(mf32_t (int_riscv_zames_mmacc (mbf16_t ZamesTileReg:$rs1),
                                            (mbf16_t ZamesTileReg:$rs2),
                                            (mf32_t ZamesAccReg:$rs3))),
            (PSEUDO_ZAMES_MMACC_BF16_F32_PRE (mf32_t ZamesAccReg:$rs3),
                                             (mbf16_t ZamesTileReg:$rs2),
                                             (mbf16_t ZamesTileReg:$rs1))>;

  def : PatZAMESStore<int_riscv_zames_msc, PSEUDO_ZAMES_MSC_C_I32_PRE, ZamesAccReg,
                      mi32_t>;
  def : PatZAMESStore<int_riscv_zames_msa, PSEUDO_ZAMES_MSA_A_I8_PRE, ZamesTileReg,
                      mi8_t>;
  def : PatZAMESStore<int_riscv_zames_msat, PSEUDO_ZAMES_MSAT_A_I8_PRE,
                      ZamesTileReg, mi8_t>;
  def : PatZAMESStore<int_riscv_zames_msb, PSEUDO_ZAMES_MSB_B_I8_PRE, ZamesTileReg,
                      mi8_t>;
  def : PatZAMESStore<int_riscv_zames_msbt, PSEUDO_ZAMES_MSBT_B_I8_PRE,
                      ZamesTileReg, mi8_t>;
  def : PatZAMESStore<int_riscv_zames_msct, PSEUDO_ZAMES_MSCT_C_I32_PRE,
                      ZamesAccReg, mi32_t>;
}

let Predicates = [HasStdExtZmasync, IsRV64] in {
  def : Pat<(msync_t (int_riscv_zmasync_msyncregreset)),
            (ZMASYNC_MSYNCREGRESET)>;
  def : Pat<(msync_t (int_riscv_zmasync_mrelease (msync_t SyncR:$sync))),
            (ZMASYNC_MRELEASE (msync_t SyncR:$sync))>;
  def : Pat<(int_riscv_zmasync_macquire (msync_t SyncR:$sync),
                                         (XLenVT GPR:$rs1)),
            (ZMASYNC_MACQUIRE (msync_t SyncR:$sync), (XLenVT GPR:$rs1))>;
  def : Pat<(int_riscv_zmasync_mfence), (ZMASYNC_MFENCE)>;
}

