//===- RISCVInstrInfoZtt.td - 'Ztt' ----------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the RISC-V instructions from the standard 'Ztt'
// extension, providing Attached Matrix Extension instructions.
// This version is still experimental as the 'Ztt' extension hasn't been
// ratified yet.
//
//===----------------------------------------------------------------------===//

// These operand types allow intrinsics to pass immediate indices
// for matrix (0-16/0-32) and accumulator (0/0-1/0-3) registers.
// hardcodes "acc" and "m" prefixes so that indices 0-7 are printed as
// acc0-acc7 and tr0-tr7 respectively, without modifying LLVM submodule.
   
// AsmOperandClass for matrix register index (0-16 or 0-32 depending on implementation)
def AMEMatrixRegIndexAsmOperand : AsmOperandClass {
  let Name = "AMEMatrixRegIndex";
  let RenderMethod = "addImmOperands";
  let PredicateMethod = "isAMETileIndex";
  let DiagnosticType = "InvalidAMETileIndex";
}

// AsmOperandClass for matrix register index (0, 0-1, 0-3 depending on implementation)
def AMEAccRegIndexAsmOperand : AsmOperandClass {
  let Name = "AMEAccRegIndex";
  let RenderMethod = "addImmOperands";
  let PredicateMethod = "isAMEAccIndex";
  let DiagnosticType = "InvalidAMEAccIndex";
}

// Operand type for AMEMatrixRegIndex (0-16 or 0-32)
def AMEMatrixRegIndex : RISCVOp<i64> {
  let ParserMatchClass = AMEMatrixRegIndexAsmOperand;
  let DecoderMethod = "decodeUImmOperand<5>";
  let OperandType = "OPERAND_UIMM5";
}

// Operand type for AMEAccRegIndex (0, 0-1 or 0-3)
def AMEAccRegIndex : RISCVOp<i64> {
  let ParserMatchClass = AMEAccRegIndexAsmOperand;
  let DecoderMethod = "decodeUImmOperand<2>";
  let OperandType = "OPERAND_UIMM2";
}

//===----------------------------------------------------------------------===//
// AME (Ztt) 32-bit real/concrete instructions
//===----------------------------------------------------------------------===//

// AME (Ztt) 32-bit instruction template
class RVInstAME32<bits<7> funct7, dag outs, dag ins, string opcodestr,
                  string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  let Inst{31 - 25} = funct7;
  let Inst{6 - 0} = 0b0101011; // RISC-V custom-1 opcode space
}

// Base class for single matrix input, matrix output instructions (op md, ms1).
// Input and output are matrix registers
class AME_UNARYELEMENTWISE<bits<7> funct7, bits<3> funct3, string opcodestr>
    : RVInstAME32<funct7,
                  (outs),
                  (ins AMEMatrixRegIndex:$md, AMEMatrixRegIndex:$ms1),
                  opcodestr, "$md, $ms1"> {
  bits<5> ms1;
  bits<5> md;

  // unused here; other instructions use this slot to encode ms2/xs1
  let Inst{24 - 20} = 0b00000; 
  let Inst{19 - 15} = ms1;
  let Inst{14 - 12} = funct3;
  let Inst{11 - 7} = md;
}

let Predicates = [HasStdExtZtt], hasSideEffects = 1, mayLoad = 0,
    mayStore = 0 in {
  def AME_MABS_EW : AME_UNARYELEMENTWISE<0b0000000, 0b001, "mabs.ew">;
  def AME_MCOLUNZIP_EW : AME_UNARYELEMENTWISE<0b0000100, 0b001, "mcolunzip.ew">;
  def AME_MCOLZIP_EW : AME_UNARYELEMENTWISE<0b0000011, 0b001, "mcolzip.ew">;
  def AME_MCONV_EW : AME_UNARYELEMENTWISE<0b0000000, 0b101, "mconv.ew">;
  def AME_MEXP2_EW : AME_UNARYELEMENTWISE<0b0000001, 0b001, "mexp2.ew">;
  def AME_MLOG2_EW : AME_UNARYELEMENTWISE<0b0000010, 0b001, "mlog2.ew">;
  def AME_MPREFIXADD_COL : AME_UNARYELEMENTWISE<0b0001100, 0b001, "mprefixadd.col">;
  def AME_MPREFIXADD_ROW : AME_UNARYELEMENTWISE<0b0001000, 0b001, "mprefixadd.row">;
  def AME_MPREFIXMAX_COL : AME_UNARYELEMENTWISE<0b0001101, 0b001, "mprefixmax.col">;
  def AME_MPREFIXMAX_ROW : AME_UNARYELEMENTWISE<0b0001001, 0b001, "mprefixmax.row">;
  def AME_MREDUCEADD_COL : AME_UNARYELEMENTWISE<0b0001010, 0b001, "mreduceadd.col">;
  def AME_MREDUCEADD_ROW : AME_UNARYELEMENTWISE<0b0000110, 0b001, "mreduceadd.row">;
  def AME_MREDUCEMAX_COL : AME_UNARYELEMENTWISE<0b0001011, 0b001, "mreducemax.col">;
  def AME_MREDUCEMAX_ROW : AME_UNARYELEMENTWISE<0b0000111, 0b001, "mreducemax.row">;
  def AME_MROWUNZIP_EW : AME_UNARYELEMENTWISE<0b0000101, 0b001, "mrowunzip.ew">;
}

// Base class for binary matrix input, matrix output instructions
// (op md, ms1, ms2).
class AME_BINARYELEMENTWISE<bits<7> funct7, bits<3> funct3, string opcodestr>
    : RVInstAME32<funct7,
                  (outs),
                  (ins AMEMatrixRegIndex: $md, AMEMatrixRegIndex
                   : $ms1, AMEMatrixRegIndex
                   : $ms2),
                  opcodestr, "$md, $ms1, $ms2"> {
  bits<5> ms1;
  bits<5> ms2;
  bits<5> md;

  let Inst{24 - 20} = ms2;
  let Inst{19 - 15} = ms1;
  let Inst{14 - 12} = funct3;
  let Inst{11 - 7} = md;
}

let Predicates = [HasStdExtZtt], hasSideEffects = 1, mayLoad = 0,
    mayStore = 0 in {
  def AME_MABSDIFF_EW : AME_BINARYELEMENTWISE<0b0000100, 0b000, "mabsdiff.ew">;
  def AME_MADD_EW : AME_BINARYELEMENTWISE<0b0000000, 0b000, "madd.ew">;
  def AME_MAND_EW : AME_BINARYELEMENTWISE<0b0000111, 0b000, "mand.ew">;
  def AME_MANDNOT_EW : AME_BINARYELEMENTWISE<0b0001000, 0b000, "mandnot.ew">;
  def AME_MCMOVGE_EW : AME_BINARYELEMENTWISE<0b0010000, 0b000, "mcmovge.ew">;
  def AME_MCMOVLT_EW : AME_BINARYELEMENTWISE<0b0010001, 0b000, "mcmovlt.ew">;
  def AME_MCMPGE_EW : AME_BINARYELEMENTWISE<0b0001100, 0b000, "mcmpge.ew">;
  def AME_MCMPLT_EW : AME_BINARYELEMENTWISE<0b0001101, 0b000, "mcmplt.ew">;
  def AME_MGATHER_EW : AME_BINARYELEMENTWISE<0b0011000, 0b000, "mgather.ew">;
  def AME_MHDIFF_EW : AME_BINARYELEMENTWISE<0b0000011, 0b000, "mhdiff.ew">;
  def AME_MLDEXP_EW : AME_BINARYELEMENTWISE<0b0010010, 0b000, "mldexp.ew">;
  def AME_MLDEXPACC_EW : AME_BINARYELEMENTWISE<0b0010011, 0b000, "mldexpacc.ew">;
  def AME_MLOG2SUB_EW : AME_BINARYELEMENTWISE<0b0010110, 0b000, "mlog2sub.ew">;
  def AME_MMAX_EW : AME_BINARYELEMENTWISE<0b0000101, 0b000, "mmax.ew">;
  def AME_MMEAN_EW : AME_BINARYELEMENTWISE<0b0000010, 0b000, "mmean.ew">;
  def AME_MMIN_EW : AME_BINARYELEMENTWISE<0b0000110, 0b000, "mmin.ew">;
  def AME_MMUL_EW : AME_BINARYELEMENTWISE<0b0011100, 0b000, "mmul.ew">;
  def AME_MMULACC_EW : AME_BINARYELEMENTWISE<0b0011101, 0b000, "mmulacc.ew">;
  def AME_MMULACCNEG_EW : AME_BINARYELEMENTWISE<0b0100000, 0b000, "mmulaccneg.ew">;
  def AME_MMULADD_EW : AME_BINARYELEMENTWISE<0b0011110, 0b000, "mmuladd.ew">;
  def AME_MMULNEG_EW : AME_BINARYELEMENTWISE<0b0100001, 0b000, "mmulneg.ew">;
  def AME_MMULSUB_EW : AME_BINARYELEMENTWISE<0b0011111, 0b000, "mmulsub.ew">;
  def AME_MOR_EW : AME_BINARYELEMENTWISE<0b0001001, 0b000, "mor.ew">;
  def AME_MORNOT_EW : AME_BINARYELEMENTWISE<0b0001010, 0b000, "mornot.ew">;
  def AME_MRDEXP_EW : AME_BINARYELEMENTWISE<0b0010100, 0b000, "mrdexp.ew">;
  def AME_MRDEXPACC_EW : AME_BINARYELEMENTWISE<0b0010101, 0b000, "mrdexpacc.ew">;
  def AME_MROWZIP_EW : AME_BINARYELEMENTWISE<0b0011011, 0b000, "mrowzip.ew">;
  def AME_MSCATADD_COL : AME_BINARYELEMENTWISE<0b0100010, 0b000, "mscatadd.col">;
  def AME_MSCATADD_ROW : AME_BINARYELEMENTWISE<0b0011001, 0b000, "mscatadd.row">;
  def AME_MSCATMAX_COL : AME_BINARYELEMENTWISE<0b0100011, 0b000, "mscatmax.col">;
  def AME_MSCATMAX_ROW : AME_BINARYELEMENTWISE<0b0011010, 0b000, "mscatmax.row">;
  def AME_MSELGE_EW : AME_BINARYELEMENTWISE<0b0001110, 0b000, "mselge.ew">;
  def AME_MSELLT_EW : AME_BINARYELEMENTWISE<0b0001111, 0b000, "msellt.ew">;
  def AME_MSUB_EW : AME_BINARYELEMENTWISE<0b0000001, 0b000, "msub.ew">;
  def AME_MSUBLOG2_EW : AME_BINARYELEMENTWISE<0b0010111, 0b000, "msublog2.ew">;
  def AME_MXOR_EW : AME_BINARYELEMENTWISE<0b0001011, 0b000, "mxor.ew">;
}

// Base class for binary matrix input, matrix output instructions where the
// second source is a scalar GPR instead of a matrix register
// (op md, xs1, ms2). Scalar type is inferred from Md[ms2].
class AME_BINARYELEMENTWISE_X<bits<7> funct7, bits<3> funct3, string opcodestr>
    : RVInstAME32<funct7,
                  (outs ),
                  (ins AMEMatrixRegIndex
                   : $md, GPR
                   : $xs1, AMEMatrixRegIndex
                   : $ms2),
                  opcodestr, "$md, $xs1, $ms2"> {
  bits<5> xs1;
  bits<5> ms2;
  bits<5> md;

  let Inst{24 - 20} = ms2;
  let Inst{19 - 15} = xs1;
  let Inst{14 - 12} = funct3;
  let Inst{11 - 7} = md;
}

let Predicates = [HasStdExtZtt], hasSideEffects = 1, mayLoad = 0,
    mayStore = 0 in {
  def AME_MABSDIFF_EW_X : AME_BINARYELEMENTWISE_X<0b0000101, 0b010, "mabsdiff.ew.x">;
  def AME_MADD_EW_X : AME_BINARYELEMENTWISE_X<0b0000000, 0b010, "madd.ew.x">;
  def AME_MAND_EW_X : AME_BINARYELEMENTWISE_X<0b0000111, 0b010, "mand.ew.x">;
  def AME_MANDNOT_EW_X : AME_BINARYELEMENTWISE_X<0b0001000, 0b010, "mandnot.ew.x">;
  def AME_MCMPGE_EW_X : AME_BINARYELEMENTWISE_X<0b0001100, 0b010, "mcmpge.ew.x">;
  def AME_MCMPLT_EW_X : AME_BINARYELEMENTWISE_X<0b0001101, 0b010, "mcmplt.ew.x">;
  def AME_MHDIFF_EW_X : AME_BINARYELEMENTWISE_X<0b0000110, 0b010, "mhdiff.ew.x">;
  def AME_MLDEXP_EW_X : AME_BINARYELEMENTWISE_X<0b0010000, 0b010, "mldexp.ew.x">;
  def AME_MLDEXPACC_EW_X : AME_BINARYELEMENTWISE_X<0b0010001, 0b010, "mldexpacc.ew.x">;
  def AME_MLOG2SUB_EW_X : AME_BINARYELEMENTWISE_X<0b0001110, 0b010, "mlog2sub.ew.x">;
  def AME_MMAX_EW_X : AME_BINARYELEMENTWISE_X<0b0000011, 0b010, "mmax.ew.x">;
  def AME_MMEAN_EW_X : AME_BINARYELEMENTWISE_X<0b0000100, 0b010, "mmean.ew.x">;
  def AME_MMIN_EW_X : AME_BINARYELEMENTWISE_X<0b0000010, 0b010, "mmin.ew.x">;
  def AME_MMUL_EW_X : AME_BINARYELEMENTWISE_X<0b0010010, 0b010, "mmul.ew.x">;
  def AME_MMULACC_EW_X : AME_BINARYELEMENTWISE_X<0b0010011, 0b010, "mmulacc.ew.x">;
  def AME_MMULACCNEG_EW_X : AME_BINARYELEMENTWISE_X<0b0010110, 0b010, "mmulaccneg.ew.x">;
  def AME_MMULADD_EW_X : AME_BINARYELEMENTWISE_X<0b0010100, 0b010, "mmuladd.ew.x">;
  def AME_MMULNEG_EW_X : AME_BINARYELEMENTWISE_X<0b0010111, 0b010, "mmulneg.ew.x">;
  def AME_MMULSUB_EW_X : AME_BINARYELEMENTWISE_X<0b0010101, 0b010, "mmulsub.ew.x">;
  def AME_MOR_EW_X : AME_BINARYELEMENTWISE_X<0b0001001, 0b010, "mor.ew.x">;
  def AME_MORNOT_EW_X : AME_BINARYELEMENTWISE_X<0b0001010, 0b010, "mornot.ew.x">;
  def AME_MSUB_EW_X : AME_BINARYELEMENTWISE_X<0b0000001, 0b010, "msub.ew.x">;
  def AME_MSUBLOG2_EW_X : AME_BINARYELEMENTWISE_X<0b0001111, 0b010, "msublog2.ew.x">;
  def AME_MXOR_EW_X : AME_BINARYELEMENTWISE_X<0b0001011, 0b010, "mxor.ew.x">;
}

// Base class for 2D matrix multiply instructions (op acc, ms1, ms2).
// acc is only 2 bits, freeing bits 14-10.
class AME_MATMUL2D<bits<7> funct7, string opcodestr>
    : RVInstAME32<funct7,
                  (outs ),
                  (ins AMEAccRegIndex
                   : $acc, AMEMatrixRegIndex
                   : $ms1, AMEMatrixRegIndex
                   : $ms2),
                  opcodestr, "$acc, $ms1, $ms2"> {
  bits<5> ms1;
  bits<5> ms2;
  bits<2> acc;

  let Inst{24 - 20} = ms2;
  let Inst{19 - 15} = ms1;
  let Inst{14 - 10} = 0b01000;
  let Inst{9 - 8} = acc;
  let Inst{7} = 0b0;
}

let Predicates = [HasStdExtZtt], hasSideEffects = 1, mayLoad = 0,
    mayStore = 0 in {
  def AME_MMUL_2D : AME_MATMUL2D<0b0000000, "mmul.2d">;
  def AME_MMULACC_2D : AME_MATMUL2D<0b0000001, "mmulacc.2d">;
  def AME_MMULACCNEG_2D : AME_MATMUL2D<0b0000011, "mmulaccneg.2d">;
  def AME_MMULAT_2D : AME_MATMUL2D<0b0000100, "mmulat.2d">;
  def AME_MMULATACC_2D : AME_MATMUL2D<0b0000101, "mmulatacc.2d">;
  def AME_MMULBT_2D : AME_MATMUL2D<0b0000110, "mmulbt.2d">;
  def AME_MMULBTACC_2D : AME_MATMUL2D<0b0000111, "mmulbtacc.2d">;
  def AME_MMULNEG_2D : AME_MATMUL2D<0b0000010, "mmulneg.2d">;
}

// Base class for the interoperability load instructions (mls, mls.cm,
// mls.rm).
class AME_LOAD<bits<7> funct7, string opcodestr>
    : RVInstAME32<funct7, (outs ),
                  (ins AMEMatrixRegIndex
                            : $md, GPR
                   : $xs1),
                  opcodestr, "$md, $xs1"> {
  bits<5> xs1;
  bits<5> md;

  let Inst{24 - 20} = 0b00000;
  let Inst{19 - 15} = xs1;
  let Inst{14 - 12} = 0b011;
  let Inst{11 - 7} = md;
}

let Predicates = [HasStdExtZtt], hasSideEffects = 1, mayLoad = 1,
    mayStore = 0 in {
  def AME_MLS : AME_LOAD<0b0000010, "mls">;
  def AME_MLS_CM : AME_LOAD<0b0000001, "mls.cm">;
  def AME_MLS_RM : AME_LOAD<0b0000000, "mls.rm">;
}

// Base class for the interoperability store instructions (mss, mss.cm,
// mss.rm). 
class AME_STORE<bits<7> funct7, string opcodestr>
    : RVInstAME32<funct7, (outs),
                  (ins AMEMatrixRegIndex
                   : $ms1, GPR
                   : $xs1),
                  opcodestr, "$ms1, $xs1"> {
  bits<5> xs1;
  bits<5> ms1;

  let Inst{24 - 20} = 0b00000;
  let Inst{19 - 15} = xs1;
  let Inst{14 - 12} = 0b011;
  let Inst{11 - 7} = ms1;
}

let Predicates = [HasStdExtZtt], hasSideEffects = 1, mayLoad = 0,
    mayStore = 1 in {
  def AME_MSS : AME_STORE<0b0000101, "mss">;
  def AME_MSS_CM : AME_STORE<0b0000100, "mss.cm">;
  def AME_MSS_RM : AME_STORE<0b0000011, "mss.rm">;
}

let Predicates = [HasStdExtZtt], hasSideEffects = 1, mayLoad = 0,
    mayStore = 0 in {
  // mzero.2d - clears an accumulator.
  def AME_MZERO_2D : RVInstAME32<0b0001000, (outs ),
                                 (ins AMEAccRegIndex
                                              : $acc), "mzero.2d", "$acc"> {
    bits<2> acc;

    let Inst{24 - 10} = 0b000000000010001;
    let Inst{9 - 8} = acc;
    let Inst{7} = 0b0;
  }

  // mmov.a.m - copy an Acc register into an M register.
  def AME_MMOV_A_M : RVInstAME32<0b0000011, (outs ),
                                 (ins AMEMatrixRegIndex
                                              : $md, AMEAccRegIndex
                                  : $acc),
                                 "mmov.a.m", "$md, $acc"> {
    bits<2> acc;
    bits<5> md;

    let Inst{24 - 22} = 0b000;
    let Inst{21 - 20} = acc;
    let Inst{19 - 12} = 0b00000100;
    let Inst{11 - 7} = md;
  }

  // mmov.m.m - copy one M register into another.
  def AME_MMOV_M_M : RVInstAME32<0b0000010, (outs ),
                                 (ins AMEMatrixRegIndex
                                              : $md, AMEMatrixRegIndex
                                  : $ms),
                                 "mmov.m.m", "$md, $ms"> {
    bits<5> ms;
    bits<5> md;

    let Inst{24 - 20} = ms;
    let Inst{19 - 12} = 0b00000100;
    let Inst{11 - 7} = md;
  }

  // mgettyp - read an M register's dtype tag into a GPR.
  def AME_MGETTYP : RVInstAME32<0b0000010, (outs GPR
                                             : $xd),
                                (ins AMEMatrixRegIndex
                                 : $ms1),
                                "mgettyp", "$xd, $ms1"> {
    bits<5> ms1;
    bits<5> xd;

    let Inst{24 - 20} = 0b00000;
    let Inst{19 - 15} = ms1;
    let Inst{14 - 12} = 0b101;
    let Inst{11 - 7} = xd;
  }

  // agettyp - read an Acc register's dtype tag into a GPR.
  def AME_AGETTYP : RVInstAME32<0b0000100, (outs GPR
                                             : $xd),
                                (ins AMEAccRegIndex
                                 : $ad),
                                "agettyp", "$xd, $ad"> {
    bits<2> ad;
    bits<5> xd;

    let Inst{24 - 17} = 0b00000000;
    let Inst{16 - 15} = ad;
    let Inst{14 - 12} = 0b101;
    let Inst{11 - 7} = xd;
  }

  // msettyp - write a GPR value as an M register's dtype tag.
  def AME_MSETTYP : RVInstAME32<0b0000001, (outs ),
                                (ins AMEMatrixRegIndex
                                             : $md, GPR
                                 : $xs1),
                                "msettyp", "$md, $xs1"> {
    bits<5> xs1;
    bits<5> md;

    let Inst{24 - 20} = 0b00000;
    let Inst{19 - 15} = xs1;
    let Inst{14 - 12} = 0b101;
    let Inst{11 - 7} = md;
  }

  // asettyp - write a GPR value as an Acc register's dtype tag.
  def AME_ASETTYP : RVInstAME32<0b0000011, (outs ),
                                (ins AMEAccRegIndex
                                             : $ad, GPR
                                 : $xs1),
                                "asettyp", "$ad, $xs1"> {
    bits<5> xs1;
    bits<2> ad;

    let Inst{19 - 15} = xs1;
    let Inst{14 - 10} = 0b10100;
    let Inst{9 - 8} = ad;
    let Inst{7} = 0b0;
  }

  // mbcast.x - broadcast a GPR scalar to every element of an M register.
  def AME_MBCAST_X : RVInstAME32<0b0000000, (outs ),
                                 (ins AMEMatrixRegIndex
                                              : $md, GPR
                                  : $xs1),
                                 "mbcast.x", "$md, $xs1"> {
    bits<5> xs1;
    bits<5> md;

    let Inst{24 - 20} = 0b00000;
    let Inst{19 - 15} = xs1;
    let Inst{14 - 12} = 0b100;
    let Inst{11 - 7} = md;
  }

  // mshift.ew - md[i,j] = ms1[i, j+imm], or 0 if j+imm is out of bounds
  def AME_MSHIFT_EW : RVInst<(outs ),
                            (ins AMEMatrixRegIndex:$md, AMEMatrixRegIndex:$ms1, i64imm:$imm),
                            "mshift.ew", "$md, $ms1, $imm", [], InstFormatOther> {
    bits<5> ms1;
    bits<7> imm;
    bits<5> md;
  
    let Inst{31 - 27} = 0b00000;
    let Inst{26 - 20} = imm;
    let Inst{19 - 15} = ms1;
    let Inst{14 - 12} = 0b110;
    let Inst{11 - 7} = md;
    let Inst{6 - 0} = 0b0101011;
  }
}

// TODO:
// Define mpack.ew.x / munpack.ew.x real and pseudo instructions, and intrinsics -> pseudo instructions isel patterns.
//
// As currently drafted in the spec, both encode to funct7=0000001, funct3=101, identical field
// positions. The spec gives no way to distinguish them. 
