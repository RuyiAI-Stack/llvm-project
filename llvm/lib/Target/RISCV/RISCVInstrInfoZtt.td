//===- RISCVInstrInfoZtt.td - 'Ztt' ----------*- tablegen -*---------------===//
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
class ZTT_UNARYELEMENTWISE<bits<7> funct7, bits<3> funct3, string opcodestr>
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
  def ZTT_MABS_EW : ZTT_UNARYELEMENTWISE<0b0000000, 0b001, "mabs.ew">;
  def ZTT_MCOLUNZIP_EW : ZTT_UNARYELEMENTWISE<0b0000100, 0b001, "mcolunzip.ew">;
  def ZTT_MCOLZIP_EW : ZTT_UNARYELEMENTWISE<0b0000011, 0b001, "mcolzip.ew">;
  def ZTT_MCONV_EW : ZTT_UNARYELEMENTWISE<0b0000000, 0b101, "mconv.ew">;
  def ZTT_MEXP2_EW : ZTT_UNARYELEMENTWISE<0b0000001, 0b001, "mexp2.ew">;
  def ZTT_MLOG2_EW : ZTT_UNARYELEMENTWISE<0b0000010, 0b001, "mlog2.ew">;
  def ZTT_MPREFIXADD_COL : ZTT_UNARYELEMENTWISE<0b0001100, 0b001, "mprefixadd.col">;
  def ZTT_MPREFIXADD_ROW : ZTT_UNARYELEMENTWISE<0b0001000, 0b001, "mprefixadd.row">;
  def ZTT_MPREFIXMAX_COL : ZTT_UNARYELEMENTWISE<0b0001101, 0b001, "mprefixmax.col">;
  def ZTT_MPREFIXMAX_ROW : ZTT_UNARYELEMENTWISE<0b0001001, 0b001, "mprefixmax.row">;
  def ZTT_MREDUCEADD_COL : ZTT_UNARYELEMENTWISE<0b0001010, 0b001, "mreduceadd.col">;
  def ZTT_MREDUCEADD_ROW : ZTT_UNARYELEMENTWISE<0b0000110, 0b001, "mreduceadd.row">;
  def ZTT_MREDUCEMAX_COL : ZTT_UNARYELEMENTWISE<0b0001011, 0b001, "mreducemax.col">;
  def ZTT_MREDUCEMAX_ROW : ZTT_UNARYELEMENTWISE<0b0000111, 0b001, "mreducemax.row">;
  def ZTT_MROWUNZIP_EW : ZTT_UNARYELEMENTWISE<0b0000101, 0b001, "mrowunzip.ew">;
}

// Base class for binary matrix input, matrix output instructions
// (op md, ms1, ms2).
class ZTT_BINARYELEMENTWISE<bits<7> funct7, bits<3> funct3, string opcodestr>
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
  def ZTT_MABSDIFF_EW : ZTT_BINARYELEMENTWISE<0b0000100, 0b000, "mabsdiff.ew">;
  def ZTT_MADD_EW : ZTT_BINARYELEMENTWISE<0b0000000, 0b000, "madd.ew">;
  def ZTT_MAND_EW : ZTT_BINARYELEMENTWISE<0b0000111, 0b000, "mand.ew">;
  def ZTT_MANDNOT_EW : ZTT_BINARYELEMENTWISE<0b0001000, 0b000, "mandnot.ew">;
  def ZTT_MCMOVGE_EW : ZTT_BINARYELEMENTWISE<0b0010000, 0b000, "mcmovge.ew">;
  def ZTT_MCMOVLT_EW : ZTT_BINARYELEMENTWISE<0b0010001, 0b000, "mcmovlt.ew">;
  def ZTT_MCMPGE_EW : ZTT_BINARYELEMENTWISE<0b0001100, 0b000, "mcmpge.ew">;
  def ZTT_MCMPLT_EW : ZTT_BINARYELEMENTWISE<0b0001101, 0b000, "mcmplt.ew">;
  def ZTT_MGATHER_EW : ZTT_BINARYELEMENTWISE<0b0011000, 0b000, "mgather.ew">;
  def ZTT_MHDIFF_EW : ZTT_BINARYELEMENTWISE<0b0000011, 0b000, "mhdiff.ew">;
  def ZTT_MLDEXP_EW : ZTT_BINARYELEMENTWISE<0b0010010, 0b000, "mldexp.ew">;
  def ZTT_MLDEXPACC_EW : ZTT_BINARYELEMENTWISE<0b0010011, 0b000, "mldexpacc.ew">;
  def ZTT_MLOG2SUB_EW : ZTT_BINARYELEMENTWISE<0b0010110, 0b000, "mlog2sub.ew">;
  def ZTT_MMAX_EW : ZTT_BINARYELEMENTWISE<0b0000101, 0b000, "mmax.ew">;
  def ZTT_MMEAN_EW : ZTT_BINARYELEMENTWISE<0b0000010, 0b000, "mmean.ew">;
  def ZTT_MMIN_EW : ZTT_BINARYELEMENTWISE<0b0000110, 0b000, "mmin.ew">;
  def ZTT_MMUL_EW : ZTT_BINARYELEMENTWISE<0b0011100, 0b000, "mmul.ew">;
  def ZTT_MMULACC_EW : ZTT_BINARYELEMENTWISE<0b0011101, 0b000, "mmulacc.ew">;
  def ZTT_MMULACCNEG_EW : ZTT_BINARYELEMENTWISE<0b0100000, 0b000, "mmulaccneg.ew">;
  def ZTT_MMULADD_EW : ZTT_BINARYELEMENTWISE<0b0011110, 0b000, "mmuladd.ew">;
  def ZTT_MMULNEG_EW : ZTT_BINARYELEMENTWISE<0b0100001, 0b000, "mmulneg.ew">;
  def ZTT_MMULSUB_EW : ZTT_BINARYELEMENTWISE<0b0011111, 0b000, "mmulsub.ew">;
  def ZTT_MOR_EW : ZTT_BINARYELEMENTWISE<0b0001001, 0b000, "mor.ew">;
  def ZTT_MORNOT_EW : ZTT_BINARYELEMENTWISE<0b0001010, 0b000, "mornot.ew">;
  def ZTT_MRDEXP_EW : ZTT_BINARYELEMENTWISE<0b0010100, 0b000, "mrdexp.ew">;
  def ZTT_MRDEXPACC_EW : ZTT_BINARYELEMENTWISE<0b0010101, 0b000, "mrdexpacc.ew">;
  def ZTT_MROWZIP_EW : ZTT_BINARYELEMENTWISE<0b0011011, 0b000, "mrowzip.ew">;
  def ZTT_MSCATADD_COL : ZTT_BINARYELEMENTWISE<0b0100010, 0b000, "mscatadd.col">;
  def ZTT_MSCATADD_ROW : ZTT_BINARYELEMENTWISE<0b0011001, 0b000, "mscatadd.row">;
  def ZTT_MSCATMAX_COL : ZTT_BINARYELEMENTWISE<0b0100011, 0b000, "mscatmax.col">;
  def ZTT_MSCATMAX_ROW : ZTT_BINARYELEMENTWISE<0b0011010, 0b000, "mscatmax.row">;
  def ZTT_MSELGE_EW : ZTT_BINARYELEMENTWISE<0b0001110, 0b000, "mselge.ew">;
  def ZTT_MSELLT_EW : ZTT_BINARYELEMENTWISE<0b0001111, 0b000, "msellt.ew">;
  def ZTT_MSUB_EW : ZTT_BINARYELEMENTWISE<0b0000001, 0b000, "msub.ew">;
  def ZTT_MSUBLOG2_EW : ZTT_BINARYELEMENTWISE<0b0010111, 0b000, "msublog2.ew">;
  def ZTT_MXOR_EW : ZTT_BINARYELEMENTWISE<0b0001011, 0b000, "mxor.ew">;
}

// Base class for binary matrix input, matrix output instructions where the
// second source is a scalar GPR instead of a matrix register
// (op md, xs1, ms2). Scalar type is inferred from Md[ms2].
class ZTT_BINARYELEMENTWISE_X<bits<7> funct7, bits<3> funct3, string opcodestr>
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
  def ZTT_MABSDIFF_EW_X : ZTT_BINARYELEMENTWISE_X<0b0000101, 0b010, "mabsdiff.ew.x">;
  def ZTT_MADD_EW_X : ZTT_BINARYELEMENTWISE_X<0b0000000, 0b010, "madd.ew.x">;
  def ZTT_MAND_EW_X : ZTT_BINARYELEMENTWISE_X<0b0000111, 0b010, "mand.ew.x">;
  def ZTT_MANDNOT_EW_X : ZTT_BINARYELEMENTWISE_X<0b0001000, 0b010, "mandnot.ew.x">;
  def ZTT_MCMPGE_EW_X : ZTT_BINARYELEMENTWISE_X<0b0001100, 0b010, "mcmpge.ew.x">;
  def ZTT_MCMPLT_EW_X : ZTT_BINARYELEMENTWISE_X<0b0001101, 0b010, "mcmplt.ew.x">;
  def ZTT_MHDIFF_EW_X : ZTT_BINARYELEMENTWISE_X<0b0000110, 0b010, "mhdiff.ew.x">;
  def ZTT_MLDEXP_EW_X : ZTT_BINARYELEMENTWISE_X<0b0010000, 0b010, "mldexp.ew.x">;
  def ZTT_MLDEXPACC_EW_X : ZTT_BINARYELEMENTWISE_X<0b0010001, 0b010, "mldexpacc.ew.x">;
  def ZTT_MLOG2SUB_EW_X : ZTT_BINARYELEMENTWISE_X<0b0001110, 0b010, "mlog2sub.ew.x">;
  def ZTT_MMAX_EW_X : ZTT_BINARYELEMENTWISE_X<0b0000011, 0b010, "mmax.ew.x">;
  def ZTT_MMEAN_EW_X : ZTT_BINARYELEMENTWISE_X<0b0000100, 0b010, "mmean.ew.x">;
  def ZTT_MMIN_EW_X : ZTT_BINARYELEMENTWISE_X<0b0000010, 0b010, "mmin.ew.x">;
  def ZTT_MMUL_EW_X : ZTT_BINARYELEMENTWISE_X<0b0010010, 0b010, "mmul.ew.x">;
  def ZTT_MMULACC_EW_X : ZTT_BINARYELEMENTWISE_X<0b0010011, 0b010, "mmulacc.ew.x">;
  def ZTT_MMULACCNEG_EW_X : ZTT_BINARYELEMENTWISE_X<0b0010110, 0b010, "mmulaccneg.ew.x">;
  def ZTT_MMULADD_EW_X : ZTT_BINARYELEMENTWISE_X<0b0010100, 0b010, "mmuladd.ew.x">;
  def ZTT_MMULNEG_EW_X : ZTT_BINARYELEMENTWISE_X<0b0010111, 0b010, "mmulneg.ew.x">;
  def ZTT_MMULSUB_EW_X : ZTT_BINARYELEMENTWISE_X<0b0010101, 0b010, "mmulsub.ew.x">;
  def ZTT_MOR_EW_X : ZTT_BINARYELEMENTWISE_X<0b0001001, 0b010, "mor.ew.x">;
  def ZTT_MORNOT_EW_X : ZTT_BINARYELEMENTWISE_X<0b0001010, 0b010, "mornot.ew.x">;
  def ZTT_MSUB_EW_X : ZTT_BINARYELEMENTWISE_X<0b0000001, 0b010, "msub.ew.x">;
  def ZTT_MSUBLOG2_EW_X : ZTT_BINARYELEMENTWISE_X<0b0001111, 0b010, "msublog2.ew.x">;
  def ZTT_MXOR_EW_X : ZTT_BINARYELEMENTWISE_X<0b0001011, 0b010, "mxor.ew.x">;
}

// Base class for 2D matrix multiply instructions (op acc, ms1, ms2).
// acc is only 2 bits, freeing bits 14-10.
class ZTT_MATMUL2D<bits<7> funct7, string opcodestr>
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
  def ZTT_MMUL_2D : ZTT_MATMUL2D<0b0000000, "mmul.2d">;
  def ZTT_MMULACC_2D : ZTT_MATMUL2D<0b0000001, "mmulacc.2d">;
  def ZTT_MMULACCNEG_2D : ZTT_MATMUL2D<0b0000011, "mmulaccneg.2d">;
  def ZTT_MMULAT_2D : ZTT_MATMUL2D<0b0000100, "mmulat.2d">;
  def ZTT_MMULATACC_2D : ZTT_MATMUL2D<0b0000101, "mmulatacc.2d">;
  def ZTT_MMULBT_2D : ZTT_MATMUL2D<0b0000110, "mmulbt.2d">;
  def ZTT_MMULBTACC_2D : ZTT_MATMUL2D<0b0000111, "mmulbtacc.2d">;
  def ZTT_MMULNEG_2D : ZTT_MATMUL2D<0b0000010, "mmulneg.2d">;
}

// Base class for the interoperability load instructions (mls, mls.cm,
// mls.rm).
class ZTT_LOAD<bits<7> funct7, string opcodestr>
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
  def ZTT_MLS : ZTT_LOAD<0b0000010, "mls">;
  def ZTT_MLS_CM : ZTT_LOAD<0b0000001, "mls.cm">;
  def ZTT_MLS_RM : ZTT_LOAD<0b0000000, "mls.rm">;
}

// Base class for the interoperability store instructions (mss, mss.cm,
// mss.rm). 
class ZTT_STORE<bits<7> funct7, string opcodestr>
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
  def ZTT_MSS : ZTT_STORE<0b0000101, "mss">;
  def ZTT_MSS_CM : ZTT_STORE<0b0000100, "mss.cm">;
  def ZTT_MSS_RM : ZTT_STORE<0b0000011, "mss.rm">;
}

def Simm7AsmOperand : SImmAsmOperand<7>;

// 7-bit signed intermediate instr operand class (for ZTT_MSHIFT_EW)
def simm7 : Operand<XLenVT> {
  let ParserMatchClass = Simm7AsmOperand;
  let DecoderMethod = "decodeSImmOperand<7>";
  let OperandType = "OPERAND_IMMEDIATE";
}

let Predicates = [HasStdExtZtt], hasSideEffects = 1, mayLoad = 0,
    mayStore = 0 in {
  // mzero.2d - clears an accumulator.
  def ZTT_MZERO_2D : RVInstAME32<0b0001000, (outs),
                                 (ins ZttAccRegIndex: $acc), "mzero.2d", "$acc"> {
    bits<2> acc;

    let Inst{24 - 10} = 0b000000000010001;
    let Inst{9 - 8} = acc;
    let Inst{7} = 0b0;
  }

  // mmov.a.m - copy an Acc register into an M register.
  def ZTT_MMOV_A_M : RVInstAME32<0b0000011, (outs ),
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
  def ZTT_MMOV_M_M : RVInstAME32<0b0000010, (outs ),
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
  def ZTT_MGETTYP : RVInstAME32<0b0000010, (outs GPR: $xd),
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
  def ZTT_AGETTYP : RVInstAME32<0b0000100, (outs GPR: $xd),
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
  def ZTT_MSETTYP : RVInstAME32<0b0000001, (outs ),
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
  def ZTT_ASETTYP : RVInstAME32<0b0000011, (outs ),
                                (ins ZttAccRegIndex: $ad, 
                                     GPR: $xs1),
                                "asettyp", "$ad, $xs1"> {
    bits<5> xs1;
    bits<2> ad;

    let Inst{24 - 20} = 0b00000;
    let Inst{19 - 15} = xs1;
    let Inst{14 - 10} = 0b10100;
    let Inst{9 - 8} = ad;
    let Inst{7} = 0b0;
  }

  // mbcast.x - broadcast a GPR scalar to every element of an M register.
  def ZTT_MBCAST_X : RVInstAME32<0b0000000, (outs ),
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
  def ZTT_MSHIFT_EW : RVInst<(outs ),
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

let Predicates = [HasStdExtZtt] in {
  // mshift.m1 - alias for mshift.ew when imm = -1
  def ZTT_MSHIFT_M1: InstAlias<"mshift.m1 $md, $ms1",
                 (ZTT_MSHIFT_EW ZttMatrixRegIndex:$md, ZttMatrixRegIndex:$ms1, -1)>;

  // mshift.p1 - alias for mshift.ew when imm = 1
  def ZTT_MSHIFT_P1: InstAlias<"mshift.p1 $md, $ms1",
                 (ZTT_MSHIFT_EW ZttMatrixRegIndex:$md, ZttMatrixRegIndex:$ms1, 1)>;
}

//===-----------------------------------------------------------------------------------===//
// Pattern Matching: LLVM IR Intrinsics -> AME (Ztt) 32-bit real/concrete instructions
//===-----------------------------------------------------------------------------------===//

// Base pattern helper for AME unary operations
class AMEUnaryPat<Intrinsic intr, Instruction inst>
    : Pat<(intr timm:$md, timm:$ms1),
          (inst timm:$md, timm:$ms1)>;

let Predicates = [HasStdExtZtt] in {
  def : AMEUnaryPat<int_riscv_ztt_mabs_ew,       ZTT_MABS_EW>;
  def : AMEUnaryPat<int_riscv_ztt_mcolunzip_ew,  ZTT_MCOLUNZIP_EW>;
  def : AMEUnaryPat<int_riscv_ztt_mcolzip_ew,    ZTT_MCOLZIP_EW>;
  def : AMEUnaryPat<int_riscv_ztt_mconv_ew,      ZTT_MCONV_EW>;
  def : AMEUnaryPat<int_riscv_ztt_mexp2_ew,      ZTT_MEXP2_EW>;
  def : AMEUnaryPat<int_riscv_ztt_mlog2_ew,      ZTT_MLOG2_EW>;
  def : AMEUnaryPat<int_riscv_ztt_mprefixadd_col, ZTT_MPREFIXADD_COL>;
  def : AMEUnaryPat<int_riscv_ztt_mprefixadd_row, ZTT_MPREFIXADD_ROW>;
  def : AMEUnaryPat<int_riscv_ztt_mprefixmax_col, ZTT_MPREFIXMAX_COL>;
  def : AMEUnaryPat<int_riscv_ztt_mprefixmax_row, ZTT_MPREFIXMAX_ROW>;
  def : AMEUnaryPat<int_riscv_ztt_mreduceadd_col, ZTT_MREDUCEADD_COL>;
  def : AMEUnaryPat<int_riscv_ztt_mreduceadd_row, ZTT_MREDUCEADD_ROW>;
  def : AMEUnaryPat<int_riscv_ztt_mreducemax_col, ZTT_MREDUCEMAX_COL>;
  def : AMEUnaryPat<int_riscv_ztt_mreducemax_row, ZTT_MREDUCEMAX_ROW>;
  def : AMEUnaryPat<int_riscv_ztt_mrowunzip_ew,  ZTT_MROWUNZIP_EW>;
}

// Base pattern helper for matrix-matrix binary operations
class AMEBinMatPat<Intrinsic intr, Instruction inst>
    : Pat<(intr timm:$md, timm:$ms1, timm:$ms2),
          (inst timm:$md, timm:$ms1, timm:$ms2)>;

let Predicates = [HasStdExtZtt] in {
  def : AMEBinMatPat<int_riscv_ztt_mabsdiff_ew,   ZTT_MABSDIFF_EW>;
  def : AMEBinMatPat<int_riscv_ztt_madd_ew,       ZTT_MADD_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mand_ew,       ZTT_MAND_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mandnot_ew,    ZTT_MANDNOT_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mcmovge_ew,    ZTT_MCMOVGE_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mcmovlt_ew,    ZTT_MCMOVLT_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mcmpge_ew,     ZTT_MCMPGE_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mcmplt_ew,     ZTT_MCMPLT_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mgather_ew,    ZTT_MGATHER_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mhdiff_ew,     ZTT_MHDIFF_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mldexp_ew,     ZTT_MLDEXP_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mldexpacc_ew,  ZTT_MLDEXPACC_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mlog2sub_ew,   ZTT_MLOG2SUB_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mmax_ew,       ZTT_MMAX_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mmean_ew,       ZTT_MMEAN_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mmin_ew,       ZTT_MMIN_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mmul_ew,       ZTT_MMUL_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mmulacc_ew,    ZTT_MMULACC_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mmulaccneg_ew, ZTT_MMULACCNEG_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mmuladd_ew,    ZTT_MMULADD_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mmulneg_ew,    ZTT_MMULNEG_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mmulsub_ew,    ZTT_MMULSUB_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mor_ew,        ZTT_MOR_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mornot_ew,     ZTT_MORNOT_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mrdexp_ew,     ZTT_MRDEXP_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mrdexpacc_ew,  ZTT_MRDEXPACC_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mrowzip_ew,    ZTT_MROWZIP_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mscatadd_col,  ZTT_MSCATADD_COL>;
  def : AMEBinMatPat<int_riscv_ztt_mscatadd_row,  ZTT_MSCATADD_ROW>;
  def : AMEBinMatPat<int_riscv_ztt_mscatmax_col,  ZTT_MSCATMAX_COL>;
  def : AMEBinMatPat<int_riscv_ztt_mscatmax_row,  ZTT_MSCATMAX_ROW>;
  def : AMEBinMatPat<int_riscv_ztt_mselge_ew,     ZTT_MSELGE_EW>;
  def : AMEBinMatPat<int_riscv_ztt_msellt_ew,     ZTT_MSELLT_EW>;
  def : AMEBinMatPat<int_riscv_ztt_msub_ew,       ZTT_MSUB_EW>;
  def : AMEBinMatPat<int_riscv_ztt_msublog2_ew,   ZTT_MSUBLOG2_EW>;
  def : AMEBinMatPat<int_riscv_ztt_mxor_ew,       ZTT_MXOR_EW>;
}

// Base pattern helper for matrix-scalar operations.
// The second argument in the intrinsic is the scalar.
class AMEBinScalarPat<Intrinsic intr, Instruction inst>
    : Pat<(intr timm:$md, i64:$xs1, timm:$ms2),
          (inst timm:$md, GPR:$xs1, timm:$ms2)>;

let Predicates = [HasStdExtZtt, IsRV64] in {
  def : AMEBinScalarPat<int_riscv_ztt_mabsdiff_ew_x,   ZTT_MABSDIFF_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_madd_ew_x,       ZTT_MADD_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mand_ew_x,       ZTT_MAND_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mandnot_ew_x,    ZTT_MANDNOT_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mcmpge_ew_x,     ZTT_MCMPGE_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mcmplt_ew_x,     ZTT_MCMPLT_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mhdiff_ew_x,      ZTT_MHDIFF_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mldexp_ew_x,     ZTT_MLDEXP_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mldexpacc_ew_x,  ZTT_MLDEXPACC_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mlog2sub_ew_x,   ZTT_MLOG2SUB_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mmax_ew_x,       ZTT_MMAX_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mmean_ew_x,       ZTT_MMEAN_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mmin_ew_x,       ZTT_MMIN_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mmul_ew_x,       ZTT_MMUL_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mmulacc_ew_x,    ZTT_MMULACC_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mmulaccneg_ew_x, ZTT_MMULACCNEG_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mmuladd_ew_x,    ZTT_MMULADD_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mmulneg_ew_x,    ZTT_MMULNEG_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mmulsub_ew_x,    ZTT_MMULSUB_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mor_ew_x,        ZTT_MOR_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mornot_ew_x,     ZTT_MORNOT_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_msub_ew_x,       ZTT_MSUB_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_msublog2_ew_x,   ZTT_MSUBLOG2_EW_X>;
  def : AMEBinScalarPat<int_riscv_ztt_mxor_ew_x,       ZTT_MXOR_EW_X>;
}

// Base class helper for matrix multiplication operations.
// These instructions write to accumulator registers.
class AMEMatMulPat<Intrinsic intr, Instruction inst>
    : Pat<(intr timm:$acc, timm:$ms1, timm:$ms2),
          (inst timm:$acc, timm:$ms1, timm:$ms2)>;

let Predicates = [HasStdExtZtt] in {
  def : AMEMatMulPat<int_riscv_ztt_mmul_2d,        ZTT_MMUL_2D>;
  def : AMEMatMulPat<int_riscv_ztt_mmulacc_2d,     ZTT_MMULACC_2D>;
  def : AMEMatMulPat<int_riscv_ztt_mmulaccneg_2d,  ZTT_MMULACCNEG_2D>;
  def : AMEMatMulPat<int_riscv_ztt_mmulat_2d,      ZTT_MMULAT_2D>;
  def : AMEMatMulPat<int_riscv_ztt_mmulatacc_2d,   ZTT_MMULATACC_2D>;
  def : AMEMatMulPat<int_riscv_ztt_mmulbt_2d,      ZTT_MMULBT_2D>;
  def : AMEMatMulPat<int_riscv_ztt_mmulbtacc_2d,   ZTT_MMULBTACC_2D>;
  def : AMEMatMulPat<int_riscv_ztt_mmulneg_2d,     ZTT_MMULNEG_2D>;
}

// Miscellaneous instructions
let Predicates = [HasStdExtZtt] in {
  // Load/Store Patterns (Memory addresses are handled as ptr_ty -> GPR)
  def : Pat<(int_riscv_ztt_mls timm:$md, iPTR:$xs1), (ZTT_MLS timm:$md, GPR:$xs1)>;
  def : Pat<(int_riscv_ztt_mls_cm timm:$md, iPTR:$xs1), (ZTT_MLS_CM timm:$md, GPR:$xs1)>;
  def : Pat<(int_riscv_ztt_mls_rm timm:$md, iPTR:$xs1), (ZTT_MLS_RM timm:$md, GPR:$xs1)>;
  def : Pat<(int_riscv_ztt_mss timm:$ms1, iPTR:$xs1), (ZTT_MSS timm:$ms1, GPR:$xs1)>;
  def : Pat<(int_riscv_ztt_mss_cm timm:$ms1, iPTR:$xs1), (ZTT_MSS_CM timm:$ms1, GPR:$xs1)>;
  def : Pat<(int_riscv_ztt_mss_rm timm:$ms1, iPTR:$xs1), (ZTT_MSS_RM timm:$ms1, GPR:$xs1)>;

  // Broadcast & Zero
  def : Pat<(int_riscv_ztt_mzero_2d timm:$acc), (ZTT_MZERO_2D timm:$acc)>;

  // Type operations
  def : Pat<(int_riscv_ztt_mgettyp timm:$ms1), (ZTT_MGETTYP timm:$ms1)>;
  def : Pat<(int_riscv_ztt_agettyp timm:$ad), (ZTT_AGETTYP timm:$ad)>;

  // Moves
  def : Pat<(int_riscv_ztt_mmov_a_m timm:$md, timm:$acc), (ZTT_MMOV_A_M timm:$md, timm:$acc)>;
  def : Pat<(int_riscv_ztt_mmov_m_m timm:$md, timm:$ms), (ZTT_MMOV_M_M timm:$md, timm:$ms)>;
  def : Pat<(int_riscv_ztt_mshift_ew timm:$md, timm:$ms1, timm:$imm), 
            (ZTT_MSHIFT_EW timm:$md, timm:$ms1, timm:$imm)>;
}

// Miscellaneous instructions with scalar operands
let Predicates = [HasStdExtZtt, IsRV64] in {
  // Broadcast & Zero
  def : Pat<(int_riscv_ztt_mbcast_x timm:$md, i64:$xs1), (ZTT_MBCAST_X timm:$md, GPR:$xs1)>;

  // Type operations
  def : Pat<(int_riscv_ztt_msettyp timm:$md, i64:$xs1), (ZTT_MSETTYP timm:$md, GPR:$xs1)>;
  def : Pat<(int_riscv_ztt_asettyp timm:$ad, i64:$xs1), (ZTT_ASETTYP timm:$ad, GPR:$xs1)>;
}

// TODO:
// Define mpack.ew.x / munpack.ew.x (instruction defintiion/encoding and LLVM IR intrinsics -> MachineInstruction/MCInst isel patterns).
//
// As currently drafted in the spec, both encode to funct7=0000001, funct3=101, identical field
// positions. The spec gives no way to distinguish them. 
