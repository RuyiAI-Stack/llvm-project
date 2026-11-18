//===-- XSAI Zames patterns --------------------------------*- tablegen -*-===//
// RISCVInstrInfoXSAIZamesPatterns.td
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
//   intrinsic -> PSEUDO_XSAI_ZAMES_*_PRE -> (pre-RA: materialize cfg payload GPR)
//   -> PSEUDO_XSAI_ZAMES_* with cfg operands -> RA -> (post-RA: emit msetcfg by
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
def xsai_zames_tuimm10 : TImmLeaf<XLenVT, [{ return isUInt<10>(Imm); }]>;
def xsai_zames_tuimm3  : TImmLeaf<XLenVT, [{ return isUInt<3>(Imm); }]>;

let Predicates = [HasStdExtZames, IsRV64], hasSideEffects = 1, mayLoad = 1,
    mayStore = 0, isCodeGenOnly = 1 in {
  def PSEUDO_XSAI_ZAMES_MLA_A_I8_PRE
      : Pseudo<(outs XSAI_ZAMES_TileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_XSAI_ZAMES_MLB_B_I8_PRE
      : Pseudo<(outs XSAI_ZAMES_TileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_XSAI_ZAMES_MLBT_B_I8_PRE
      : Pseudo<(outs XSAI_ZAMES_TileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_XSAI_ZAMES_MLAT_A_I8_PRE
      : Pseudo<(outs XSAI_ZAMES_TileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_XSAI_ZAMES_MLC_C_I32_PRE
      : Pseudo<(outs XSAI_ZAMES_AccReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_XSAI_ZAMES_MLCT_C_I32_PRE
      : Pseudo<(outs XSAI_ZAMES_AccReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }

  def PSEUDO_XSAI_ZAMES_MLA_A_I8
      : Pseudo<(outs XSAI_ZAMES_TileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
    let Size = 8;
  }
  def PSEUDO_XSAI_ZAMES_MLB_B_I8
      : Pseudo<(outs XSAI_ZAMES_TileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
    let Size = 8;
  }
  def PSEUDO_XSAI_ZAMES_MLBT_B_I8
      : Pseudo<(outs XSAI_ZAMES_TileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
    let Size = 8;
  }
  def PSEUDO_XSAI_ZAMES_MLAT_A_I8
      : Pseudo<(outs XSAI_ZAMES_TileReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
    let Size = 8;
  }
  def PSEUDO_XSAI_ZAMES_MLC_C_I32
      : Pseudo<(outs XSAI_ZAMES_AccReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
    let Size = 8;
  }
  def PSEUDO_XSAI_ZAMES_MLCT_C_I32
      : Pseudo<(outs XSAI_ZAMES_AccReg:$md),
               (ins GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
    let Size = 8;
  }
}

let Predicates = [HasStdExtZames, IsRV64], hasSideEffects = 1, mayLoad = 0,
    mayStore = 0, isCodeGenOnly = 1 in {
  def PSEUDO_XSAI_ZAMES_MZERO_C_I32_PRE : Pseudo<(outs XSAI_ZAMES_AccReg:$md), (ins), []> {
    let Size = 12;
  }
  def PSEUDO_XSAI_ZAMES_MMACC_I8_I32_PRE
      : Pseudo<(outs XSAI_ZAMES_AccReg:$md_wb),
               (ins XSAI_ZAMES_AccReg:$md, XSAI_ZAMES_TileReg:$ms2, XSAI_ZAMES_TileReg:$ms1), []> {
    let Constraints = "$md_wb = $md";
    let Size = 28;
  }

  def PSEUDO_XSAI_ZAMES_MZERO_C_I32
      : Pseudo<(outs XSAI_ZAMES_AccReg:$md), (ins GPR:$cfg), []> {
    let Size = 8;
  }
  def PSEUDO_XSAI_ZAMES_MMACC_I8_I32
      : Pseudo<(outs XSAI_ZAMES_AccReg:$md_wb),
               (ins XSAI_ZAMES_AccReg:$md, XSAI_ZAMES_TileReg:$ms2, XSAI_ZAMES_TileReg:$ms1, GPR:$cfg_c,
                    GPR:$cfg_b, GPR:$cfg_a), []> {
    let Constraints = "$md_wb = $md";
    let Size = 16;
  }
}

let Predicates = [HasStdExtZames, IsRV64], hasSideEffects = 1, mayLoad = 0,
    mayStore = 1, isCodeGenOnly = 1 in {
  def PSEUDO_XSAI_ZAMES_MSC_C_I32_PRE
      : Pseudo<(outs),
               (ins XSAI_ZAMES_AccReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_XSAI_ZAMES_MSA_A_I8_PRE
      : Pseudo<(outs),
               (ins XSAI_ZAMES_TileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_XSAI_ZAMES_MSAT_A_I8_PRE
      : Pseudo<(outs),
               (ins XSAI_ZAMES_TileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_XSAI_ZAMES_MSB_B_I8_PRE
      : Pseudo<(outs),
               (ins XSAI_ZAMES_TileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_XSAI_ZAMES_MSBT_B_I8_PRE
      : Pseudo<(outs),
               (ins XSAI_ZAMES_TileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }
  def PSEUDO_XSAI_ZAMES_MSCT_C_I32_PRE
      : Pseudo<(outs),
               (ins XSAI_ZAMES_AccReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
    let Size = 12;
  }

  def PSEUDO_XSAI_ZAMES_MSC_C_I32
      : Pseudo<(outs),
               (ins XSAI_ZAMES_AccReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg),
               []> {
    let Size = 8;
  }
  def PSEUDO_XSAI_ZAMES_MSA_A_I8
      : Pseudo<(outs),
               (ins XSAI_ZAMES_TileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg),
               []> {
    let Size = 8;
  }
  def PSEUDO_XSAI_ZAMES_MSAT_A_I8
      : Pseudo<(outs),
               (ins XSAI_ZAMES_TileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg),
               []> {
    let Size = 8;
  }
  def PSEUDO_XSAI_ZAMES_MSB_B_I8
      : Pseudo<(outs),
               (ins XSAI_ZAMES_TileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg),
               []> {
    let Size = 8;
  }
  def PSEUDO_XSAI_ZAMES_MSBT_B_I8
      : Pseudo<(outs),
               (ins XSAI_ZAMES_TileReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg),
               []> {
    let Size = 8;
  }
  def PSEUDO_XSAI_ZAMES_MSCT_C_I32
      : Pseudo<(outs),
               (ins XSAI_ZAMES_AccReg:$md, GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg),
               []> {
    let Size = 8;
  }
}

class PatXSAI_ZAMES_SetTileReg<SDPatternOperator OpNode, Instruction Inst>
    : Pat<(OpNode (XLenVT GPR:$rs1)), (Inst GPR:$rs1)>;

// Shared shells for the typed ZAMES pseudo instructions. Concrete defs carry
// the PSEUDO_XSAI_ZAMES_<OP>_<ROLE>_<TYPE> names so every instance stays
// reachable from the pre-RA and late C++ expansion switches.
class XSAI_ZAMES_LdPseudoPRE<RegisterClass RC>
    : Pseudo<(outs RC:$md), (ins GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
  let Size = 12;
}
class XSAI_ZAMES_LdPseudoCFG<RegisterClass RC>
    : Pseudo<(outs RC:$md),
             (ins GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
  let Size = 8;
}
class XSAI_ZAMES_StPseudoPRE<RegisterClass RC>
    : Pseudo<(outs), (ins RC:$md, GPRMemZeroOffset:$rs1, GPR:$rs2), []> {
  let Size = 12;
}
class XSAI_ZAMES_StPseudoCFG<RegisterClass RC>
    : Pseudo<(outs),
             (ins RC:$md, GPRMemZeroOffset:$rs1, GPR:$rs2, GPR:$cfg), []> {
  let Size = 8;
}
class XSAI_ZAMES_MZeroPseudoPRE<RegisterClass RC>
    : Pseudo<(outs RC:$md), (ins), []> {
  let Size = 12;
}
class XSAI_ZAMES_MZeroPseudoCFG<RegisterClass RC>
    : Pseudo<(outs RC:$md), (ins GPR:$cfg), []> {
  let Size = 8;
}
class XSAI_ZAMES_MMAccPseudoPRE
    : Pseudo<(outs XSAI_ZAMES_AccReg:$md_wb),
             (ins XSAI_ZAMES_AccReg:$md, XSAI_ZAMES_TileReg:$ms2, XSAI_ZAMES_TileReg:$ms1), []> {
  let Constraints = "$md_wb = $md";
  let Size = 28;
}
class XSAI_ZAMES_MMAccPseudoCFG
    : Pseudo<(outs XSAI_ZAMES_AccReg:$md_wb),
             (ins XSAI_ZAMES_AccReg:$md, XSAI_ZAMES_TileReg:$ms2, XSAI_ZAMES_TileReg:$ms1, GPR:$cfg_c,
                  GPR:$cfg_b, GPR:$cfg_a), []> {
  let Constraints = "$md_wb = $md";
  let Size = 16;
}

// Typed load pseudo instances: A/B tiles use every supported input element;
// C accumulators use fp32.
let Predicates = [HasStdExtZames, IsRV64], hasSideEffects = 0, mayLoad = 1, mayStore = 0,
    isCodeGenOnly = 1 in {
  def PSEUDO_XSAI_ZAMES_MLA_A_FP8E4_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLA_A_FP8E4 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLA_A_FP8E5_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLA_A_FP8E5 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLA_A_F16_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLA_A_F16 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLA_A_BF16_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLA_A_BF16 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLAT_A_FP8E4_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLAT_A_FP8E4 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLAT_A_FP8E5_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLAT_A_FP8E5 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLAT_A_F16_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLAT_A_F16 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLAT_A_BF16_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLAT_A_BF16 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLB_B_FP8E4_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLB_B_FP8E4 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLB_B_FP8E5_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLB_B_FP8E5 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLB_B_F16_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLB_B_F16 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLB_B_BF16_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLB_B_BF16 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLBT_B_FP8E4_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLBT_B_FP8E4 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLBT_B_FP8E5_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLBT_B_FP8E5 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLBT_B_F16_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLBT_B_F16 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLBT_B_BF16_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLBT_B_BF16 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MLC_C_F32_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_AccReg>;
  def PSEUDO_XSAI_ZAMES_MLC_C_F32 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_AccReg>;
  def PSEUDO_XSAI_ZAMES_MLCT_C_F32_PRE : XSAI_ZAMES_LdPseudoPRE<XSAI_ZAMES_AccReg>;
  def PSEUDO_XSAI_ZAMES_MLCT_C_F32 : XSAI_ZAMES_LdPseudoCFG<XSAI_ZAMES_AccReg>;
}

let Predicates = [HasStdExtZames, IsRV64], hasSideEffects = 0, mayLoad = 0, mayStore = 1,
    isCodeGenOnly = 1 in {
  def PSEUDO_XSAI_ZAMES_MSA_A_FP8E4_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSA_A_FP8E4 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSA_A_FP8E5_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSA_A_FP8E5 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSA_A_F16_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSA_A_F16 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSA_A_BF16_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSA_A_BF16 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSAT_A_FP8E4_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSAT_A_FP8E4 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSAT_A_FP8E5_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSAT_A_FP8E5 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSAT_A_F16_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSAT_A_F16 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSAT_A_BF16_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSAT_A_BF16 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSB_B_FP8E4_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSB_B_FP8E4 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSB_B_FP8E5_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSB_B_FP8E5 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSB_B_F16_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSB_B_F16 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSB_B_BF16_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSB_B_BF16 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSBT_B_FP8E4_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSBT_B_FP8E4 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSBT_B_FP8E5_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSBT_B_FP8E5 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSBT_B_F16_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSBT_B_F16 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSBT_B_BF16_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSBT_B_BF16 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MSC_C_F32_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_AccReg>;
  def PSEUDO_XSAI_ZAMES_MSC_C_F32 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_AccReg>;
  def PSEUDO_XSAI_ZAMES_MSCT_C_F32_PRE : XSAI_ZAMES_StPseudoPRE<XSAI_ZAMES_AccReg>;
  def PSEUDO_XSAI_ZAMES_MSCT_C_F32 : XSAI_ZAMES_StPseudoCFG<XSAI_ZAMES_AccReg>;
}

// Typed mzero pseudo instances preserve the input/output register partition.
let Predicates = [HasStdExtZames, IsRV64], hasSideEffects = 0, mayLoad = 0, mayStore = 0,
    isCodeGenOnly = 1 in {
  def PSEUDO_XSAI_ZAMES_MZERO_T_I8_PRE : XSAI_ZAMES_MZeroPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MZERO_T_I8 : XSAI_ZAMES_MZeroPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MZERO_T_FP8E4_PRE : XSAI_ZAMES_MZeroPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MZERO_T_FP8E4 : XSAI_ZAMES_MZeroPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MZERO_T_FP8E5_PRE : XSAI_ZAMES_MZeroPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MZERO_T_FP8E5 : XSAI_ZAMES_MZeroPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MZERO_T_F16_PRE : XSAI_ZAMES_MZeroPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MZERO_T_F16 : XSAI_ZAMES_MZeroPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MZERO_T_BF16_PRE : XSAI_ZAMES_MZeroPseudoPRE<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MZERO_T_BF16 : XSAI_ZAMES_MZeroPseudoCFG<XSAI_ZAMES_TileReg>;
  def PSEUDO_XSAI_ZAMES_MZERO_C_F32_PRE : XSAI_ZAMES_MZeroPseudoPRE<XSAI_ZAMES_AccReg>;
  def PSEUDO_XSAI_ZAMES_MZERO_C_F32 : XSAI_ZAMES_MZeroPseudoCFG<XSAI_ZAMES_AccReg>;
}

// Typed mmacc pseudo instances for the six supported combinations.
let Predicates = [HasStdExtZames, IsRV64], hasSideEffects = 0, mayLoad = 0, mayStore = 0,
    isCodeGenOnly = 1 in {
  def PSEUDO_XSAI_ZAMES_MMACC_I8_F32_PRE : XSAI_ZAMES_MMAccPseudoPRE;
  def PSEUDO_XSAI_ZAMES_MMACC_I8_F32 : XSAI_ZAMES_MMAccPseudoCFG;
  def PSEUDO_XSAI_ZAMES_MMACC_FP8E4_F32_PRE : XSAI_ZAMES_MMAccPseudoPRE;
  def PSEUDO_XSAI_ZAMES_MMACC_FP8E4_F32 : XSAI_ZAMES_MMAccPseudoCFG;
  def PSEUDO_XSAI_ZAMES_MMACC_FP8E5_F32_PRE : XSAI_ZAMES_MMAccPseudoPRE;
  def PSEUDO_XSAI_ZAMES_MMACC_FP8E5_F32 : XSAI_ZAMES_MMAccPseudoCFG;
  def PSEUDO_XSAI_ZAMES_MMACC_F16_F32_PRE : XSAI_ZAMES_MMAccPseudoPRE;
  def PSEUDO_XSAI_ZAMES_MMACC_F16_F32 : XSAI_ZAMES_MMAccPseudoCFG;
  def PSEUDO_XSAI_ZAMES_MMACC_BF16_F32_PRE : XSAI_ZAMES_MMAccPseudoPRE;
  def PSEUDO_XSAI_ZAMES_MMACC_BF16_F32 : XSAI_ZAMES_MMAccPseudoCFG;
}

class PatXSAI_ZAMES_Load<SDPatternOperator OpNode, Instruction Inst, ValueType RetTy>
    : Pat<(RetTy (OpNode GPRMemZeroOffset:$rs1, GPR:$rs2)),
          (Inst GPRMemZeroOffset:$rs1, GPR:$rs2)>;

class PatXSAI_ZAMES_Store<SDPatternOperator OpNode, Instruction Inst,
                    RegisterClass Reg, ValueType RegTy>
    : Pat<(OpNode (RegTy Reg:$md), GPRMemZeroOffset:$rs1, GPR:$rs2),
          (Inst (RegTy Reg:$md), GPRMemZeroOffset:$rs1, GPR:$rs2)>;

class PatXSAI_ZAMES_WholeLoad<SDPatternOperator OpNode, Instruction Inst,
                        ValueType RetTy>
    : Pat<(RetTy (OpNode GPRMemZeroOffset:$rs1)),
          (Inst GPRMemZeroOffset:$rs1)>;

class PatXSAI_ZAMES_WholeStore<SDPatternOperator OpNode, Instruction Inst,
                         RegisterClass Reg, ValueType RegTy>
    : Pat<(OpNode (RegTy Reg:$md), GPRMemZeroOffset:$rs1),
          (Inst (RegTy Reg:$md), GPRMemZeroOffset:$rs1)>;

let Predicates = [HasStdExtZames, IsRV64] in {
  def : Pat<(int_riscv_xsai_zames_msettilemi xsai_zames_tuimm10:$imm),
            (XSAI_ZAMES_MSETTILEMI timm:$imm)>;
  def : Pat<(int_riscv_xsai_zames_msettileni xsai_zames_tuimm10:$imm),
            (XSAI_ZAMES_MSETTILENI timm:$imm)>;
  def : Pat<(int_riscv_xsai_zames_msettileki xsai_zames_tuimm10:$imm),
            (XSAI_ZAMES_MSETTILEKI timm:$imm)>;

  def : PatXSAI_ZAMES_SetTileReg<int_riscv_xsai_zames_msettilem,
                           XSAI_ZAMES_MSETTILEM>;
  def : PatXSAI_ZAMES_SetTileReg<int_riscv_xsai_zames_msettilen,
                           XSAI_ZAMES_MSETTILEN>;
  def : PatXSAI_ZAMES_SetTileReg<int_riscv_xsai_zames_msettilek,
                           XSAI_ZAMES_MSETTILEK>;

  def : Pat<(int_riscv_xsai_zames_msetcfg xsai_zames_tuimm3:$cfg, (XLenVT GPR:$rs1)),
            (XSAI_ZAMES_MSETCFG timm:$cfg, GPR:$rs1)>;

  def : Pat<(int_riscv_xsai_zames_minit), (XSAI_ZAMES_MINIT)>;
  def : Pat<(XLenVT (int_riscv_xsai_zames_mgetcfg xsai_zames_tuimm3:$cfg)),
            (XSAI_ZAMES_MGETCFG timm:$cfg)>;

  def : Pat<(xsai_mi32_t (int_riscv_xsai_zames_mzero)),
            (PSEUDO_XSAI_ZAMES_MZERO_C_I32_PRE)>;

  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mla, PSEUDO_XSAI_ZAMES_MLA_A_I8_PRE, xsai_mi8_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlb, PSEUDO_XSAI_ZAMES_MLB_B_I8_PRE, xsai_mi8_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlbt, PSEUDO_XSAI_ZAMES_MLBT_B_I8_PRE, xsai_mi8_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlat, PSEUDO_XSAI_ZAMES_MLAT_A_I8_PRE, xsai_mi8_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlc, PSEUDO_XSAI_ZAMES_MLC_C_I32_PRE, xsai_mi32_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlct, PSEUDO_XSAI_ZAMES_MLCT_C_I32_PRE, xsai_mi32_t>;

  def : PatXSAI_ZAMES_WholeLoad<int_riscv_xsai_zames_mla_whole, XSAI_ZAMES_MLA_WHOLE, xsai_mi8_t>;
  def : PatXSAI_ZAMES_WholeLoad<int_riscv_xsai_zames_mlb_whole, XSAI_ZAMES_MLB_WHOLE, xsai_mi8_t>;
  def : PatXSAI_ZAMES_WholeLoad<int_riscv_xsai_zames_mlc_whole, XSAI_ZAMES_MLC_WHOLE, xsai_mi32_t>;

  def : PatXSAI_ZAMES_WholeStore<int_riscv_xsai_zames_msa_whole, XSAI_ZAMES_MSA_WHOLE,
                           XSAI_ZAMES_TileReg, xsai_mi8_t>;
  def : PatXSAI_ZAMES_WholeStore<int_riscv_xsai_zames_msb_whole, XSAI_ZAMES_MSB_WHOLE,
                           XSAI_ZAMES_TileReg, xsai_mi8_t>;
  def : PatXSAI_ZAMES_WholeStore<int_riscv_xsai_zames_msc_whole, XSAI_ZAMES_MSC_WHOLE,
                           XSAI_ZAMES_AccReg, xsai_mi32_t>;

  def : Pat<(xsai_mi32_t (int_riscv_xsai_zames_mmacc (xsai_mi8_t XSAI_ZAMES_TileReg:$rs1),
                                           (xsai_mi8_t XSAI_ZAMES_TileReg:$rs2),
                                           (xsai_mi32_t XSAI_ZAMES_AccReg:$rs3))),
            (PSEUDO_XSAI_ZAMES_MMACC_I8_I32_PRE (xsai_mi32_t XSAI_ZAMES_AccReg:$rs3),
                                           (xsai_mi8_t XSAI_ZAMES_TileReg:$rs2),
                                           (xsai_mi8_t XSAI_ZAMES_TileReg:$rs1))>;

  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mla, PSEUDO_XSAI_ZAMES_MLA_A_FP8E4_PRE,
                     xsai_mf8e4_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mla, PSEUDO_XSAI_ZAMES_MLA_A_FP8E5_PRE,
                     xsai_mf8e5_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mla, PSEUDO_XSAI_ZAMES_MLA_A_F16_PRE, xsai_mf16_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mla, PSEUDO_XSAI_ZAMES_MLA_A_BF16_PRE,
                     xsai_mbf16_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlat, PSEUDO_XSAI_ZAMES_MLAT_A_FP8E4_PRE,
                     xsai_mf8e4_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlat, PSEUDO_XSAI_ZAMES_MLAT_A_FP8E5_PRE,
                     xsai_mf8e5_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlat, PSEUDO_XSAI_ZAMES_MLAT_A_F16_PRE,
                     xsai_mf16_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlat, PSEUDO_XSAI_ZAMES_MLAT_A_BF16_PRE,
                     xsai_mbf16_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlb, PSEUDO_XSAI_ZAMES_MLB_B_FP8E4_PRE,
                     xsai_mf8e4_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlb, PSEUDO_XSAI_ZAMES_MLB_B_FP8E5_PRE,
                     xsai_mf8e5_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlb, PSEUDO_XSAI_ZAMES_MLB_B_F16_PRE, xsai_mf16_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlb, PSEUDO_XSAI_ZAMES_MLB_B_BF16_PRE,
                     xsai_mbf16_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlbt, PSEUDO_XSAI_ZAMES_MLBT_B_FP8E4_PRE,
                     xsai_mf8e4_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlbt, PSEUDO_XSAI_ZAMES_MLBT_B_FP8E5_PRE,
                     xsai_mf8e5_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlbt, PSEUDO_XSAI_ZAMES_MLBT_B_F16_PRE,
                     xsai_mf16_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlbt, PSEUDO_XSAI_ZAMES_MLBT_B_BF16_PRE,
                     xsai_mbf16_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlc, PSEUDO_XSAI_ZAMES_MLC_C_F32_PRE, xsai_mf32_t>;
  def : PatXSAI_ZAMES_Load<int_riscv_xsai_zames_mlct, PSEUDO_XSAI_ZAMES_MLCT_C_F32_PRE,
                     xsai_mf32_t>;

  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msa, PSEUDO_XSAI_ZAMES_MSA_A_FP8E4_PRE,
                      XSAI_ZAMES_TileReg, xsai_mf8e4_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msa, PSEUDO_XSAI_ZAMES_MSA_A_FP8E5_PRE,
                      XSAI_ZAMES_TileReg, xsai_mf8e5_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msa, PSEUDO_XSAI_ZAMES_MSA_A_F16_PRE,
                      XSAI_ZAMES_TileReg, xsai_mf16_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msa, PSEUDO_XSAI_ZAMES_MSA_A_BF16_PRE,
                      XSAI_ZAMES_TileReg, xsai_mbf16_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msat, PSEUDO_XSAI_ZAMES_MSAT_A_FP8E4_PRE,
                      XSAI_ZAMES_TileReg, xsai_mf8e4_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msat, PSEUDO_XSAI_ZAMES_MSAT_A_FP8E5_PRE,
                      XSAI_ZAMES_TileReg, xsai_mf8e5_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msat, PSEUDO_XSAI_ZAMES_MSAT_A_F16_PRE,
                      XSAI_ZAMES_TileReg, xsai_mf16_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msat, PSEUDO_XSAI_ZAMES_MSAT_A_BF16_PRE,
                      XSAI_ZAMES_TileReg, xsai_mbf16_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msb, PSEUDO_XSAI_ZAMES_MSB_B_FP8E4_PRE,
                      XSAI_ZAMES_TileReg, xsai_mf8e4_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msb, PSEUDO_XSAI_ZAMES_MSB_B_FP8E5_PRE,
                      XSAI_ZAMES_TileReg, xsai_mf8e5_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msb, PSEUDO_XSAI_ZAMES_MSB_B_F16_PRE,
                      XSAI_ZAMES_TileReg, xsai_mf16_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msb, PSEUDO_XSAI_ZAMES_MSB_B_BF16_PRE,
                      XSAI_ZAMES_TileReg, xsai_mbf16_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msbt, PSEUDO_XSAI_ZAMES_MSBT_B_FP8E4_PRE,
                      XSAI_ZAMES_TileReg, xsai_mf8e4_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msbt, PSEUDO_XSAI_ZAMES_MSBT_B_FP8E5_PRE,
                      XSAI_ZAMES_TileReg, xsai_mf8e5_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msbt, PSEUDO_XSAI_ZAMES_MSBT_B_F16_PRE,
                      XSAI_ZAMES_TileReg, xsai_mf16_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msbt, PSEUDO_XSAI_ZAMES_MSBT_B_BF16_PRE,
                      XSAI_ZAMES_TileReg, xsai_mbf16_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msc, PSEUDO_XSAI_ZAMES_MSC_C_F32_PRE, XSAI_ZAMES_AccReg,
                      xsai_mf32_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msct, PSEUDO_XSAI_ZAMES_MSCT_C_F32_PRE,
                      XSAI_ZAMES_AccReg, xsai_mf32_t>;

  def : PatXSAI_ZAMES_WholeLoad<int_riscv_xsai_zames_mla_whole, XSAI_ZAMES_MLA_WHOLE,
                          xsai_mf8e4_t>;
  def : PatXSAI_ZAMES_WholeLoad<int_riscv_xsai_zames_mla_whole, XSAI_ZAMES_MLA_WHOLE,
                          xsai_mf8e5_t>;
  def : PatXSAI_ZAMES_WholeLoad<int_riscv_xsai_zames_mla_whole, XSAI_ZAMES_MLA_WHOLE,
                          xsai_mf16_t>;
  def : PatXSAI_ZAMES_WholeLoad<int_riscv_xsai_zames_mla_whole, XSAI_ZAMES_MLA_WHOLE,
                          xsai_mbf16_t>;
  def : PatXSAI_ZAMES_WholeLoad<int_riscv_xsai_zames_mlb_whole, XSAI_ZAMES_MLB_WHOLE,
                          xsai_mf8e4_t>;
  def : PatXSAI_ZAMES_WholeLoad<int_riscv_xsai_zames_mlb_whole, XSAI_ZAMES_MLB_WHOLE,
                          xsai_mf8e5_t>;
  def : PatXSAI_ZAMES_WholeLoad<int_riscv_xsai_zames_mlb_whole, XSAI_ZAMES_MLB_WHOLE,
                          xsai_mf16_t>;
  def : PatXSAI_ZAMES_WholeLoad<int_riscv_xsai_zames_mlb_whole, XSAI_ZAMES_MLB_WHOLE,
                          xsai_mbf16_t>;
  def : PatXSAI_ZAMES_WholeLoad<int_riscv_xsai_zames_mlc_whole, XSAI_ZAMES_MLC_WHOLE, xsai_mf32_t>;
  def : PatXSAI_ZAMES_WholeStore<int_riscv_xsai_zames_msa_whole, XSAI_ZAMES_MSA_WHOLE,
                           XSAI_ZAMES_TileReg, xsai_mf8e4_t>;
  def : PatXSAI_ZAMES_WholeStore<int_riscv_xsai_zames_msa_whole, XSAI_ZAMES_MSA_WHOLE,
                           XSAI_ZAMES_TileReg, xsai_mf8e5_t>;
  def : PatXSAI_ZAMES_WholeStore<int_riscv_xsai_zames_msa_whole, XSAI_ZAMES_MSA_WHOLE,
                           XSAI_ZAMES_TileReg, xsai_mf16_t>;
  def : PatXSAI_ZAMES_WholeStore<int_riscv_xsai_zames_msa_whole, XSAI_ZAMES_MSA_WHOLE,
                           XSAI_ZAMES_TileReg, xsai_mbf16_t>;
  def : PatXSAI_ZAMES_WholeStore<int_riscv_xsai_zames_msb_whole, XSAI_ZAMES_MSB_WHOLE,
                           XSAI_ZAMES_TileReg, xsai_mf8e4_t>;
  def : PatXSAI_ZAMES_WholeStore<int_riscv_xsai_zames_msb_whole, XSAI_ZAMES_MSB_WHOLE,
                           XSAI_ZAMES_TileReg, xsai_mf8e5_t>;
  def : PatXSAI_ZAMES_WholeStore<int_riscv_xsai_zames_msb_whole, XSAI_ZAMES_MSB_WHOLE,
                           XSAI_ZAMES_TileReg, xsai_mf16_t>;
  def : PatXSAI_ZAMES_WholeStore<int_riscv_xsai_zames_msb_whole, XSAI_ZAMES_MSB_WHOLE,
                           XSAI_ZAMES_TileReg, xsai_mbf16_t>;
  def : PatXSAI_ZAMES_WholeStore<int_riscv_xsai_zames_msc_whole, XSAI_ZAMES_MSC_WHOLE,
                           XSAI_ZAMES_AccReg, xsai_mf32_t>;

  def : Pat<(xsai_mi8_t (int_riscv_xsai_zames_mzero)), (PSEUDO_XSAI_ZAMES_MZERO_T_I8_PRE)>;
  def : Pat<(xsai_mf8e4_t (int_riscv_xsai_zames_mzero)),
            (PSEUDO_XSAI_ZAMES_MZERO_T_FP8E4_PRE)>;
  def : Pat<(xsai_mf8e5_t (int_riscv_xsai_zames_mzero)),
            (PSEUDO_XSAI_ZAMES_MZERO_T_FP8E5_PRE)>;
  def : Pat<(xsai_mf16_t (int_riscv_xsai_zames_mzero)), (PSEUDO_XSAI_ZAMES_MZERO_T_F16_PRE)>;
  def : Pat<(xsai_mbf16_t (int_riscv_xsai_zames_mzero)),
            (PSEUDO_XSAI_ZAMES_MZERO_T_BF16_PRE)>;
  def : Pat<(xsai_mf32_t (int_riscv_xsai_zames_mzero)), (PSEUDO_XSAI_ZAMES_MZERO_C_F32_PRE)>;

  def : Pat<(xsai_mf32_t (int_riscv_xsai_zames_mmacc (xsai_mi8_t XSAI_ZAMES_TileReg:$rs1),
                                            (xsai_mi8_t XSAI_ZAMES_TileReg:$rs2),
                                            (xsai_mf32_t XSAI_ZAMES_AccReg:$rs3))),
            (PSEUDO_XSAI_ZAMES_MMACC_I8_F32_PRE (xsai_mf32_t XSAI_ZAMES_AccReg:$rs3),
                                           (xsai_mi8_t XSAI_ZAMES_TileReg:$rs2),
                                           (xsai_mi8_t XSAI_ZAMES_TileReg:$rs1))>;
  def : Pat<(xsai_mf32_t (int_riscv_xsai_zames_mmacc (xsai_mf8e4_t XSAI_ZAMES_TileReg:$rs1),
                                            (xsai_mf8e4_t XSAI_ZAMES_TileReg:$rs2),
                                            (xsai_mf32_t XSAI_ZAMES_AccReg:$rs3))),
            (PSEUDO_XSAI_ZAMES_MMACC_FP8E4_F32_PRE (xsai_mf32_t XSAI_ZAMES_AccReg:$rs3),
                                              (xsai_mf8e4_t XSAI_ZAMES_TileReg:$rs2),
                                              (xsai_mf8e4_t XSAI_ZAMES_TileReg:$rs1))>;
  def : Pat<(xsai_mf32_t (int_riscv_xsai_zames_mmacc (xsai_mf8e5_t XSAI_ZAMES_TileReg:$rs1),
                                            (xsai_mf8e5_t XSAI_ZAMES_TileReg:$rs2),
                                            (xsai_mf32_t XSAI_ZAMES_AccReg:$rs3))),
            (PSEUDO_XSAI_ZAMES_MMACC_FP8E5_F32_PRE (xsai_mf32_t XSAI_ZAMES_AccReg:$rs3),
                                              (xsai_mf8e5_t XSAI_ZAMES_TileReg:$rs2),
                                              (xsai_mf8e5_t XSAI_ZAMES_TileReg:$rs1))>;
  def : Pat<(xsai_mf32_t (int_riscv_xsai_zames_mmacc (xsai_mf16_t XSAI_ZAMES_TileReg:$rs1),
                                            (xsai_mf16_t XSAI_ZAMES_TileReg:$rs2),
                                            (xsai_mf32_t XSAI_ZAMES_AccReg:$rs3))),
            (PSEUDO_XSAI_ZAMES_MMACC_F16_F32_PRE (xsai_mf32_t XSAI_ZAMES_AccReg:$rs3),
                                            (xsai_mf16_t XSAI_ZAMES_TileReg:$rs2),
                                            (xsai_mf16_t XSAI_ZAMES_TileReg:$rs1))>;
  def : Pat<(xsai_mf32_t (int_riscv_xsai_zames_mmacc (xsai_mbf16_t XSAI_ZAMES_TileReg:$rs1),
                                            (xsai_mbf16_t XSAI_ZAMES_TileReg:$rs2),
                                            (xsai_mf32_t XSAI_ZAMES_AccReg:$rs3))),
            (PSEUDO_XSAI_ZAMES_MMACC_BF16_F32_PRE (xsai_mf32_t XSAI_ZAMES_AccReg:$rs3),
                                             (xsai_mbf16_t XSAI_ZAMES_TileReg:$rs2),
                                             (xsai_mbf16_t XSAI_ZAMES_TileReg:$rs1))>;

  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msc, PSEUDO_XSAI_ZAMES_MSC_C_I32_PRE, XSAI_ZAMES_AccReg,
                      xsai_mi32_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msa, PSEUDO_XSAI_ZAMES_MSA_A_I8_PRE, XSAI_ZAMES_TileReg,
                      xsai_mi8_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msat, PSEUDO_XSAI_ZAMES_MSAT_A_I8_PRE,
                      XSAI_ZAMES_TileReg, xsai_mi8_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msb, PSEUDO_XSAI_ZAMES_MSB_B_I8_PRE, XSAI_ZAMES_TileReg,
                      xsai_mi8_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msbt, PSEUDO_XSAI_ZAMES_MSBT_B_I8_PRE,
                      XSAI_ZAMES_TileReg, xsai_mi8_t>;
  def : PatXSAI_ZAMES_Store<int_riscv_xsai_zames_msct, PSEUDO_XSAI_ZAMES_MSCT_C_I32_PRE,
                      XSAI_ZAMES_AccReg, xsai_mi32_t>;
}

let Predicates = [HasStdExtZmasync, IsRV64] in {
  def : Pat<(xsai_msync_t (int_riscv_xsai_zmasync_msyncregreset)),
            (XSAI_ZMASYNC_MSYNCREGRESET)>;
  def : Pat<(xsai_msync_t (int_riscv_xsai_zmasync_mrelease (xsai_msync_t XSAI_ZMASYNC_SyncR:$sync))),
            (XSAI_ZMASYNC_MRELEASE (xsai_msync_t XSAI_ZMASYNC_SyncR:$sync))>;
  def : Pat<(int_riscv_xsai_zmasync_macquire (xsai_msync_t XSAI_ZMASYNC_SyncR:$sync),
                                         (XLenVT GPR:$rs1)),
            (XSAI_ZMASYNC_MACQUIRE (xsai_msync_t XSAI_ZMASYNC_SyncR:$sync), (XLenVT GPR:$rs1))>;
  def : Pat<(int_riscv_xsai_zmasync_mfence), (XSAI_ZMASYNC_MFENCE)>;
}
