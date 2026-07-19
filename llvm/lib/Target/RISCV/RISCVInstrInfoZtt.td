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
   
// AsmOperandClass for matrix register index (m0-m16 or m0-m32 depending on implementation)
def ZttMatrixRegIndexAsmOperand : AsmOperandClass {
  let Name = "ZttMatrixRegIndex";
  let ParserMethod = "parseZttMatrixRegIndex";
  let RenderMethod = "addImmOperands";
  let PredicateMethod = "isUImm5";
  let DiagnosticType = "InvalidZttMatrixRegIndex";
}

// AsmOperandClass for matrix register index (acc0, acc0-acc1, acc0-acc3 depending on implementation)
def ZttAccRegIndexAsmOperand : AsmOperandClass {
  let Name = "ZttAccRegIndex";
  let ParserMethod = "parseZttAccRegIndex";
  let RenderMethod = "addImmOperands";
  let PredicateMethod = "isUImm2";
  let DiagnosticType = "InvalidZttAccRegIndex";
}

// Operand type for ZttMatrixRegIndex (0-16 or 0-32)
def ZttMatrixRegIndex : RISCVOp<i64> {
  let ParserMatchClass = ZttMatrixRegIndexAsmOperand;
  // TODO: implement register index numeric range checks 
  // against enabled mregs/accregs subfeature in decoder method.
  let DecoderMethod = "decodeUImmOperand<5>";
  let OperandType = "OPERAND_ZTT_MATRIX_REG";
  let PrintMethod = "printZttMatrixRegIndex";
}

// Operand type for ZttAccRegIndex (0, 0-1 or 0-3)
def ZttAccRegIndex : RISCVOp<i64> {
  let ParserMatchClass = ZttAccRegIndexAsmOperand;
  // TODO: implement register index numeric range checks 
  // against enabled mregs/accregs subfeature in decoder method.
  let DecoderMethod = "decodeUImmOperand<2>";
  let OperandType = "OPERAND_ZTT_ACC_REG";
  let PrintMethod = "printZttAccRegIndex";
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
                  (ins ZttMatrixRegIndex:$md, ZttMatrixRegIndex:$ms1),
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
                  (ins ZttMatrixRegIndex: $md, 
                       ZttMatrixRegIndex: $ms1, 
                       ZttMatrixRegIndex: $ms2),
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
                  (outs),
                  (ins ZttMatrixRegIndex: $md, 
                       GPR: $xs1, 
                       ZttMatrixRegIndex: $ms2),
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
                  (ins ZttAccRegIndex: $acc, 
                       ZttMatrixRegIndex: $ms1, 
                       ZttMatrixRegIndex: $ms2),
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
                  (ins ZttMatrixRegIndex: $md, 
                       GPR: $xs1),
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
                  (ins ZttMatrixRegIndex: $ms1, 
                       GPR: $xs1),
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

def Simm7AsmOperand : SImmAsmOperand<7>;

// 7-bit signed intermediate instr operand class (for AME_MSHIFT_EW)
def simm7 : Operand<XLenVT> {
  let ParserMatchClass = Simm7AsmOperand;
  let DecoderMethod = "decodeSImmOperand<7>";
  let OperandType = "OPERAND_SIMM7";
}

let Predicates = [HasStdExtZtt], hasSideEffects = 1, mayLoad = 0,
    mayStore = 0 in {
  // mzero.2d - clears an accumulator.
  def AME_MZERO_2D : RVInstAME32<0b0001000, (outs),
                                 (ins ZttAccRegIndex: $acc), "mzero.2d", "$acc"> {
    bits<2> acc;

    let Inst{24 - 10} = 0b000000000010001;
    let Inst{9 - 8} = acc;
    let Inst{7} = 0b0;
  }

  // mmov.a.m - copy an Acc register into an M register.
  def AME_MMOV_A_M : RVInstAME32<0b0000011, (outs ),
                                 (ins ZttMatrixRegIndex: $md, 
                                      ZttAccRegIndex: $acc),
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
                                 (ins ZttMatrixRegIndex: $md, 
                                      ZttMatrixRegIndex: $ms),
                                 "mmov.m.m", "$md, $ms"> {
    bits<5> ms;
    bits<5> md;

    let Inst{24 - 20} = ms;
    let Inst{19 - 12} = 0b00000100;
    let Inst{11 - 7} = md;
  }

  // mgettyp - read an M register's dtype tag into a GPR.
  def AME_MGETTYP : RVInstAME32<0b0000010, (outs GPR: $xd),
                                (ins ZttMatrixRegIndex: $ms1),
                                "mgettyp", "$xd, $ms1"> {
    bits<5> ms1;
    bits<5> xd;

    let Inst{24 - 20} = 0b00000;
    let Inst{19 - 15} = ms1;
    let Inst{14 - 12} = 0b101;
    let Inst{11 - 7} = xd;
  }

  // agettyp - read an Acc register's dtype tag into a GPR.
  def AME_AGETTYP : RVInstAME32<0b0000100, (outs GPR: $xd),
                                (ins ZttAccRegIndex: $ad),
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
                                (ins ZttMatrixRegIndex: $md, 
                                     GPR: $xs1),
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
                                (ins ZttAccRegIndex: $ad, 
                                     GPR: $xs1),
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
                                 (ins ZttMatrixRegIndex: $md, 
                                      GPR: $xs1),
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
                            (ins ZttMatrixRegIndex:$md, ZttMatrixRegIndex:$ms1, simm7:$imm),
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

//===-----------------------------------------------------------------------------------===//
// Pattern Matching: LLVM IR Intrinsics -> AME (Ztt) 32-bit real/concrete instructions
//===-----------------------------------------------------------------------------------===//

// Base pattern helper for AME unary operations
class AMEUnaryPat<Intrinsic intr, Instruction inst>
    : Pat<(intr timm:$md, timm:$ms1),
          (inst timm:$md, timm:$ms1)>;

let Predicates = [HasStdExtZtt] in {
  def : AMEUnaryPat<int_riscv_ame_mabs_ew,       AME_MABS_EW>;
  def : AMEUnaryPat<int_riscv_ame_mcolunzip_ew,  AME_MCOLUNZIP_EW>;
  def : AMEUnaryPat<int_riscv_ame_mcolzip_ew,    AME_MCOLZIP_EW>;
  def : AMEUnaryPat<int_riscv_ame_mconv_ew,      AME_MCONV_EW>;
  def : AMEUnaryPat<int_riscv_ame_mexp2_ew,      AME_MEXP2_EW>;
  def : AMEUnaryPat<int_riscv_ame_mlog2_ew,      AME_MLOG2_EW>;
  def : AMEUnaryPat<int_riscv_ame_mprefixadd_col, AME_MPREFIXADD_COL>;
  def : AMEUnaryPat<int_riscv_ame_mprefixadd_row, AME_MPREFIXADD_ROW>;
  def : AMEUnaryPat<int_riscv_ame_mprefixmax_col, AME_MPREFIXMAX_COL>;
  def : AMEUnaryPat<int_riscv_ame_mprefixmax_row, AME_MPREFIXMAX_ROW>;
  def : AMEUnaryPat<int_riscv_ame_mreduceadd_col, AME_MREDUCEADD_COL>;
  def : AMEUnaryPat<int_riscv_ame_mreduceadd_row, AME_MREDUCEADD_ROW>;
  def : AMEUnaryPat<int_riscv_ame_mreducemax_col, AME_MREDUCEMAX_COL>;
  def : AMEUnaryPat<int_riscv_ame_mreducemax_row, AME_MREDUCEMAX_ROW>;
  def : AMEUnaryPat<int_riscv_ame_mrowunzip_ew,  AME_MROWUNZIP_EW>;
}

// Base pattern helper for matrix-matrix binary operations
class AMEBinMatPat<Intrinsic intr, Instruction inst>
    : Pat<(intr timm:$md, timm:$ms1, timm:$ms2),
          (inst timm:$md, timm:$ms1, timm:$ms2)>;

let Predicates = [HasStdExtZtt] in {
  def : AMEBinMatPat<int_riscv_ame_mabsdiff_ew,   AME_MABSDIFF_EW>;
  def : AMEBinMatPat<int_riscv_ame_madd_ew,       AME_MADD_EW>;
  def : AMEBinMatPat<int_riscv_ame_mand_ew,       AME_MAND_EW>;
  def : AMEBinMatPat<int_riscv_ame_mandnot_ew,    AME_MANDNOT_EW>;
  def : AMEBinMatPat<int_riscv_ame_mcmovge_ew,    AME_MCMOVGE_EW>;
  def : AMEBinMatPat<int_riscv_ame_mcmovlt_ew,    AME_MCMOVLT_EW>;
  def : AMEBinMatPat<int_riscv_ame_mcmpge_ew,     AME_MCMPGE_EW>;
  def : AMEBinMatPat<int_riscv_ame_mcmplt_ew,     AME_MCMPLT_EW>;
  def : AMEBinMatPat<int_riscv_ame_mgather_ew,    AME_MGATHER_EW>;
  def : AMEBinMatPat<int_riscv_ame_mhdiff_ew,     AME_MHDIFF_EW>;
  def : AMEBinMatPat<int_riscv_ame_mldexp_ew,     AME_MLDEXP_EW>;
  def : AMEBinMatPat<int_riscv_ame_mldexpacc_ew,  AME_MLDEXPACC_EW>;
  def : AMEBinMatPat<int_riscv_ame_mlog2sub_ew,   AME_MLOG2SUB_EW>;
  def : AMEBinMatPat<int_riscv_ame_mmax_ew,       AME_MMAX_EW>;
  def : AMEBinMatPat<int_riscv_ame_mmean_ew,       AME_MMEAN_EW>;
  def : AMEBinMatPat<int_riscv_ame_mmin_ew,       AME_MMIN_EW>;
  def : AMEBinMatPat<int_riscv_ame_mmul_ew,       AME_MMUL_EW>;
  def : AMEBinMatPat<int_riscv_ame_mmulacc_ew,    AME_MMULACC_EW>;
  def : AMEBinMatPat<int_riscv_ame_mmulaccneg_ew, AME_MMULACCNEG_EW>;
  def : AMEBinMatPat<int_riscv_ame_mmuladd_ew,    AME_MMULADD_EW>;
  def : AMEBinMatPat<int_riscv_ame_mmulneg_ew,    AME_MMULNEG_EW>;
  def : AMEBinMatPat<int_riscv_ame_mmulsub_ew,    AME_MMULSUB_EW>;
  def : AMEBinMatPat<int_riscv_ame_mor_ew,        AME_MOR_EW>;
  def : AMEBinMatPat<int_riscv_ame_mornot_ew,     AME_MORNOT_EW>;
  def : AMEBinMatPat<int_riscv_ame_mrdexp_ew,     AME_MRDEXP_EW>;
  def : AMEBinMatPat<int_riscv_ame_mrdexpacc_ew,  AME_MRDEXPACC_EW>;
  def : AMEBinMatPat<int_riscv_ame_mrowzip_ew,    AME_MROWZIP_EW>;
  def : AMEBinMatPat<int_riscv_ame_mscatadd_col,  AME_MSCATADD_COL>;
  def : AMEBinMatPat<int_riscv_ame_mscatadd_row,  AME_MSCATADD_ROW>;
  def : AMEBinMatPat<int_riscv_ame_mscatmax_col,  AME_MSCATMAX_COL>;
  def : AMEBinMatPat<int_riscv_ame_mscatmax_row,  AME_MSCATMAX_ROW>;
  def : AMEBinMatPat<int_riscv_ame_mselge_ew,     AME_MSELGE_EW>;
  def : AMEBinMatPat<int_riscv_ame_msellt_ew,     AME_MSELLT_EW>;
  def : AMEBinMatPat<int_riscv_ame_msub_ew,       AME_MSUB_EW>;
  def : AMEBinMatPat<int_riscv_ame_msublog2_ew,   AME_MSUBLOG2_EW>;
  def : AMEBinMatPat<int_riscv_ame_mxor_ew,       AME_MXOR_EW>;
}

// Base pattern helper for matrix-scalar operations.
// The second argument in the intrinsic is the scalar.
class AMEBinScalarPat<Intrinsic intr, Instruction inst>
    : Pat<(intr timm:$md, i64:$xs1, timm:$ms2),
          (inst timm:$md, GPR:$xs1, timm:$ms2)>;

let Predicates = [HasStdExtZtt, IsRV64] in {
  def : AMEBinScalarPat<int_riscv_ame_mabsdiff_ew_x,   AME_MABSDIFF_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_madd_ew_x,       AME_MADD_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mand_ew_x,       AME_MAND_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mandnot_ew_x,    AME_MANDNOT_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mcmpge_ew_x,     AME_MCMPGE_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mcmplt_ew_x,     AME_MCMPLT_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mhdiff_ew_x,      AME_MHDIFF_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mldexp_ew_x,     AME_MLDEXP_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mldexpacc_ew_x,  AME_MLDEXPACC_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mlog2sub_ew_x,   AME_MLOG2SUB_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mmax_ew_x,       AME_MMAX_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mmean_ew_x,       AME_MMEAN_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mmin_ew_x,       AME_MMIN_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mmul_ew_x,       AME_MMUL_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mmulacc_ew_x,    AME_MMULACC_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mmulaccneg_ew_x, AME_MMULACCNEG_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mmuladd_ew_x,    AME_MMULADD_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mmulneg_ew_x,    AME_MMULNEG_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mmulsub_ew_x,    AME_MMULSUB_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mor_ew_x,        AME_MOR_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mornot_ew_x,     AME_MORNOT_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_msub_ew_x,       AME_MSUB_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_msublog2_ew_x,   AME_MSUBLOG2_EW_X>;
  def : AMEBinScalarPat<int_riscv_ame_mxor_ew_x,       AME_MXOR_EW_X>;
}

// Base class helper for matrix multiplication operations.
// These instructions write to accumulator registers.
class AMEMatMulPat<Intrinsic intr, Instruction inst>
    : Pat<(intr timm:$acc, timm:$ms1, timm:$ms2),
          (inst timm:$acc, timm:$ms1, timm:$ms2)>;

let Predicates = [HasStdExtZtt] in {
  def : AMEMatMulPat<int_riscv_ame_mmul_2d,        AME_MMUL_2D>;
  def : AMEMatMulPat<int_riscv_ame_mmulacc_2d,     AME_MMULACC_2D>;
  def : AMEMatMulPat<int_riscv_ame_mmulaccneg_2d,  AME_MMULACCNEG_2D>;
  def : AMEMatMulPat<int_riscv_ame_mmulat_2d,      AME_MMULAT_2D>;
  def : AMEMatMulPat<int_riscv_ame_mmulatacc_2d,   AME_MMULATACC_2D>;
  def : AMEMatMulPat<int_riscv_ame_mmulbt_2d,      AME_MMULBT_2D>;
  def : AMEMatMulPat<int_riscv_ame_mmulbtacc_2d,   AME_MMULBTACC_2D>;
  def : AMEMatMulPat<int_riscv_ame_mmulneg_2d,     AME_MMULNEG_2D>;
}

// Miscellaneous instructions
let Predicates = [HasStdExtZtt] in {
  // Load/Store Patterns (Memory addresses are handled as ptr_ty -> GPR)
  def : Pat<(int_riscv_ame_mls timm:$md, iPTR:$xs1), (AME_MLS timm:$md, GPR:$xs1)>;
  def : Pat<(int_riscv_ame_mls_cm timm:$md, iPTR:$xs1), (AME_MLS_CM timm:$md, GPR:$xs1)>;
  def : Pat<(int_riscv_ame_mls_rm timm:$md, iPTR:$xs1), (AME_MLS_RM timm:$md, GPR:$xs1)>;
  def : Pat<(int_riscv_ame_mss timm:$ms1, iPTR:$xs1), (AME_MSS timm:$ms1, GPR:$xs1)>;
  def : Pat<(int_riscv_ame_mss_cm timm:$ms1, iPTR:$xs1), (AME_MSS_CM timm:$ms1, GPR:$xs1)>;
  def : Pat<(int_riscv_ame_mss_rm timm:$ms1, iPTR:$xs1), (AME_MSS_RM timm:$ms1, GPR:$xs1)>;

  // Broadcast & Zero
  def : Pat<(int_riscv_ame_mzero_2d timm:$acc), (AME_MZERO_2D timm:$acc)>;

  // Type operations
  def : Pat<(int_riscv_ame_mgettyp timm:$ms1), (AME_MGETTYP timm:$ms1)>;
  def : Pat<(int_riscv_ame_agettyp timm:$ad), (AME_AGETTYP timm:$ad)>;

  // Moves
  def : Pat<(int_riscv_ame_mmov_a_m timm:$md, timm:$acc), (AME_MMOV_A_M timm:$md, timm:$acc)>;
  def : Pat<(int_riscv_ame_mmov_m_m timm:$md, timm:$ms), (AME_MMOV_M_M timm:$md, timm:$ms)>;
  def : Pat<(int_riscv_ame_mshift_ew timm:$md, timm:$ms1, timm:$imm), 
            (AME_MSHIFT_EW timm:$md, timm:$ms1, timm:$imm)>;
}

// Miscellaneous instructions with scalar operands
let Predicates = [HasStdExtZtt, IsRV64] in {
  // Broadcast & Zero
  def : Pat<(int_riscv_ame_mbcast_x timm:$md, i64:$xs1), (AME_MBCAST_X timm:$md, GPR:$xs1)>;

  // Type operations
  def : Pat<(int_riscv_ame_msettyp timm:$md, i64:$xs1), (AME_MSETTYP timm:$md, GPR:$xs1)>;
  def : Pat<(int_riscv_ame_asettyp timm:$ad, i64:$xs1), (AME_ASETTYP timm:$ad, GPR:$xs1)>;
}

// TODO:
// Define mpack.ew.x / munpack.ew.x (instruction defintiion/encoding and LLVM IR intrinsics -> MachineInstruction/MCInst isel patterns).
//
// As currently drafted in the spec, both encode to funct7=0000001, funct3=101, identical field
// positions. The spec gives no way to distinguish them. 
