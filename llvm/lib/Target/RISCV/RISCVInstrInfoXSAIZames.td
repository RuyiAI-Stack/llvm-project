//===-- RISCVInstrInfoXSAIZames.td - ZAMES/ZMASYNC instructions -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// ZAMES/ZMASYNC real instruction definitions (MC layer). Codegen-only
// pseudos and SelectionDAG patterns are intentionally not part of this file.
//
//===----------------------------------------------------------------------===//

def xsai_zames_uimm10 : RISCVUImmLeafOp<10>;

// mcfg0..mcfg7 select the hardware matrix configuration register configured by
// msetcfg/mgetcfg. The value is encoded as a 3-bit immediate.
def XSAIZamesMCFGSelAsmOperand : AsmOperandClass {
  let Name = "XSAIZamesMCFGSel";
  let RenderMethod = "addImmOperands";
  let ParserMethod = "parseXSAIZamesMCFGSel";
}

def xsai_zames_mcfgsel : RISCVUImmLeafOp<3> {
  let ParserMatchClass = XSAIZamesMCFGSelAsmOperand;
  let PrintMethod = "printXSAIZamesMCFGSel";
}

class XSAI_ZAMES_InstConfigImm<bits<4> func4, string opcodestr>
    : RVInst<(outs), (ins xsai_zames_uimm10:$imm), opcodestr, "$imm", [],
             InstFormatI> {
  bits<10> imm;

  let Inst{31-28} = func4;
  let Inst{27-26} = 0b00;
  let Inst{25} = 0b0;
  let Inst{24-15} = imm;
  let Inst{14-12} = 0b000;
  let Inst{11-7} = 0b00000;
  let Inst{6-0} = OPC_CUSTOM_1.Value;
}

class XSAI_ZAMES_InstConfigReg<bits<4> func4, string opcodestr>
    : RVInst<(outs), (ins GPR:$rs1), opcodestr, "$rs1", [],
             InstFormatI> {
  bits<5> rs1;

  let Inst{31-28} = func4;
  let Inst{27-26} = 0b00;
  let Inst{25} = 0b1;
  let Inst{24-20} = 0b00000;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b000;
  let Inst{11-7} = 0b00000;
  let Inst{6-0} = OPC_CUSTOM_1.Value;
}

class XSAI_ZAMES_InstSetCfg<string opcodestr>
    : RVInst<(outs), (ins xsai_zames_mcfgsel:$cfg, GPR:$rs1), opcodestr, "$cfg, $rs1",
             [], InstFormatI> {
  bits<3> cfg;
  bits<5> rs1;

  let Inst{31-28} = 0b0100;
  let Inst{27-26} = 0b00;
  let Inst{25} = 0b1;
  let Inst{24-20} = 0b00000;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b000;
  let Inst{11-10} = 0b00;
  let Inst{9-7} = cfg;
  let Inst{6-0} = OPC_CUSTOM_1.Value;
}

class XSAI_ZAMES_InstGetCfg<string opcodestr>
    : RVInst<(outs GPR:$rd), (ins xsai_zames_mcfgsel:$cfg), opcodestr, "$rd, $cfg",
             [], InstFormatI> {
  bits<5> rd;
  bits<3> cfg;

  let Inst{31-28} = 0b0101;
  let Inst{27-26} = 0b00;
  let Inst{25} = 0b0;
  let Inst{24-20} = 0b00000;
  let Inst{19-18} = 0b00;
  let Inst{17-15} = cfg;
  let Inst{14-12} = 0b000;
  let Inst{11-7} = rd;
  let Inst{6-0} = OPC_CUSTOM_1.Value;
}

class XSAI_ZAMES_InstInit<string opcodestr>
    : RVInst<(outs), (ins), opcodestr, "", [], InstFormatI> {
  let Inst{31-7} = 0;
  let Inst{6-0} = OPC_CUSTOM_1.Value;
}

class XSAI_ZAMES_InstLoadStore<bits<4> func4, bit ls, dag outs, dag ins,
                         string opcodestr>
    : RVInst<outs, ins, opcodestr, "$md, $rs1, $rs2", [],
             InstFormatI> {
  bits<5> md;
  bits<5> rs1;
  bits<5> rs2;

  let Inst{31-28} = func4;
  let Inst{27-26} = 0b00;
  let Inst{25} = ls;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b001;
  let Inst{11-7} = md;
  let Inst{6-0} = OPC_CUSTOM_1.Value;
}

class XSAI_ZAMES_InstWholeLoadStore<bits<4> func4, bit ls, dag outs, dag ins,
                              string opcodestr>
    : RVInst<outs, ins, opcodestr, "$md, $rs1", [], InstFormatI> {
  bits<5> md;
  bits<5> rs1;

  let Inst{31-28} = func4;
  let Inst{27-26} = 0b00;
  let Inst{25} = ls;
  let Inst{24-20} = 0b00000;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b001;
  let Inst{11-7} = md;
  let Inst{6-0} = OPC_CUSTOM_1.Value;
}

class XSAI_ZAMES_InstMMAcc<bits<4> func4, dag outs, dag ins,
                     string opcodestr>
    : RVInst<outs, ins, opcodestr, "$md, $ms2, $ms1", [],
             InstFormatI> {
  bits<5> md;
  bits<5> ms1;
  bits<5> ms2;

  let Inst{31-28} = func4;
  let Inst{27-25} = 0b000;
  let Inst{24-20} = ms2;
  let Inst{19-15} = ms1;
  let Inst{14-12} = 0b010;
  let Inst{11-7} = md;
  let Inst{6-0} = OPC_CUSTOM_1.Value;
}

class XSAI_ZAMES_InstMisc<bits<4> func4, dag outs, dag ins,
                    string opcodestr>
    : RVInst<outs, ins, opcodestr, "$md", [], InstFormatI> {
  bits<5> md;

  let Inst{31-28} = func4;
  let Inst{27-15} = 0b0000000000000;
  let Inst{14-12} = 0b011;
  let Inst{11-7} = md;
  let Inst{6-0} = OPC_CUSTOM_1.Value;
}

let Predicates = [HasStdExtZames], hasSideEffects = 1, mayLoad = 0,
    mayStore = 0 in {
  def XSAI_ZAMES_MSETTILEMI : XSAI_ZAMES_InstConfigImm<0b0010, "msettilemi">;
  def XSAI_ZAMES_MSETTILENI : XSAI_ZAMES_InstConfigImm<0b0011, "msettileni">;
  def XSAI_ZAMES_MSETTILEKI : XSAI_ZAMES_InstConfigImm<0b0001, "msettileki">;

  def XSAI_ZAMES_MSETTILEM : XSAI_ZAMES_InstConfigReg<0b0010, "msettilem">;
  def XSAI_ZAMES_MSETTILEN : XSAI_ZAMES_InstConfigReg<0b0011, "msettilen">;
  def XSAI_ZAMES_MSETTILEK : XSAI_ZAMES_InstConfigReg<0b0001, "msettilek">;

  def XSAI_ZAMES_MSETCFG : XSAI_ZAMES_InstSetCfg<"msetcfg">;
  def XSAI_ZAMES_MGETCFG : XSAI_ZAMES_InstGetCfg<"mgetcfg">;

  def XSAI_ZAMES_MINIT : XSAI_ZAMES_InstInit<"minit">;
}

let Predicates = [HasStdExtZames], hasSideEffects = 1, mayLoad = 1,
    mayStore = 0 in {
  def XSAI_ZAMES_MLA : XSAI_ZAMES_InstLoadStore<0b0000, 0b0, (outs XSAI_ZAMES_TileReg:$md),
                                     (ins GPRMemZeroOffset:$rs1, GPR:$rs2),
                                     "mla">;
  def XSAI_ZAMES_MLB : XSAI_ZAMES_InstLoadStore<0b0001, 0b0, (outs XSAI_ZAMES_TileReg:$md),
                                     (ins GPRMemZeroOffset:$rs1, GPR:$rs2),
                                     "mlb">;
  def XSAI_ZAMES_MLC : XSAI_ZAMES_InstLoadStore<0b0010, 0b0, (outs XSAI_ZAMES_AccReg:$md),
                                     (ins GPRMemZeroOffset:$rs1, GPR:$rs2),
                                     "mlc">;
  def XSAI_ZAMES_MLBT : XSAI_ZAMES_InstLoadStore<0b0101, 0b0, (outs XSAI_ZAMES_TileReg:$md),
                                      (ins GPRMemZeroOffset:$rs1, GPR:$rs2),
                                      "mlbt">;
  def XSAI_ZAMES_MLAT : XSAI_ZAMES_InstLoadStore<0b0100, 0b0, (outs XSAI_ZAMES_TileReg:$md),
                                      (ins GPRMemZeroOffset:$rs1, GPR:$rs2),
                                      "mlat">;
  def XSAI_ZAMES_MLCT : XSAI_ZAMES_InstLoadStore<0b0110, 0b0, (outs XSAI_ZAMES_AccReg:$md),
                                      (ins GPRMemZeroOffset:$rs1, GPR:$rs2),
                                      "mlct">;

  def XSAI_ZAMES_MLA_WHOLE
      : XSAI_ZAMES_InstWholeLoadStore<0b1000, 0b0, (outs XSAI_ZAMES_TileReg:$md),
                                (ins GPRMemZeroOffset:$rs1), "mla.whole">;
  def XSAI_ZAMES_MLB_WHOLE
      : XSAI_ZAMES_InstWholeLoadStore<0b1001, 0b0, (outs XSAI_ZAMES_TileReg:$md),
                                (ins GPRMemZeroOffset:$rs1), "mlb.whole">;
  def XSAI_ZAMES_MLC_WHOLE
      : XSAI_ZAMES_InstWholeLoadStore<0b1010, 0b0, (outs XSAI_ZAMES_AccReg:$md),
                                (ins GPRMemZeroOffset:$rs1), "mlc.whole">;
}

let Predicates = [HasStdExtZames], hasSideEffects = 1, mayLoad = 0,
    mayStore = 1 in {
  def XSAI_ZAMES_MSC : XSAI_ZAMES_InstLoadStore<0b0010, 0b1, (outs),
                                     (ins XSAI_ZAMES_AccReg:$md,
                                          GPRMemZeroOffset:$rs1, GPR:$rs2),
                                     "msc">;
  def XSAI_ZAMES_MSA : XSAI_ZAMES_InstLoadStore<0b0000, 0b1, (outs),
                                     (ins XSAI_ZAMES_TileReg:$md,
                                          GPRMemZeroOffset:$rs1, GPR:$rs2),
                                     "msa">;
  def XSAI_ZAMES_MSB : XSAI_ZAMES_InstLoadStore<0b0001, 0b1, (outs),
                                     (ins XSAI_ZAMES_TileReg:$md,
                                          GPRMemZeroOffset:$rs1, GPR:$rs2),
                                     "msb">;
  def XSAI_ZAMES_MSAT : XSAI_ZAMES_InstLoadStore<0b0100, 0b1, (outs),
                                      (ins XSAI_ZAMES_TileReg:$md,
                                           GPRMemZeroOffset:$rs1, GPR:$rs2),
                                      "msat">;
  def XSAI_ZAMES_MSBT : XSAI_ZAMES_InstLoadStore<0b0101, 0b1, (outs),
                                      (ins XSAI_ZAMES_TileReg:$md,
                                           GPRMemZeroOffset:$rs1, GPR:$rs2),
                                      "msbt">;
  def XSAI_ZAMES_MSCT : XSAI_ZAMES_InstLoadStore<0b0110, 0b1, (outs),
                                      (ins XSAI_ZAMES_AccReg:$md,
                                           GPRMemZeroOffset:$rs1, GPR:$rs2),
                                      "msct">;

  def XSAI_ZAMES_MSA_WHOLE
      : XSAI_ZAMES_InstWholeLoadStore<0b1000, 0b1, (outs),
                                (ins XSAI_ZAMES_TileReg:$md, GPRMemZeroOffset:$rs1),
                                "msa.whole">;
  def XSAI_ZAMES_MSB_WHOLE
      : XSAI_ZAMES_InstWholeLoadStore<0b1001, 0b1, (outs),
                                (ins XSAI_ZAMES_TileReg:$md, GPRMemZeroOffset:$rs1),
                                "msb.whole">;
  def XSAI_ZAMES_MSC_WHOLE
      : XSAI_ZAMES_InstWholeLoadStore<0b1010, 0b1, (outs),
                                (ins XSAI_ZAMES_AccReg:$md, GPRMemZeroOffset:$rs1),
                                "msc.whole">;
}

let Predicates = [HasStdExtZames], hasSideEffects = 1, mayLoad = 0,
    mayStore = 0 in {
  def XSAI_ZAMES_MZERO : XSAI_ZAMES_InstMisc<0b0000, (outs XSAI_ZAMES_TileOrAccReg:$md), (ins),
                                 "mzero">;

  def XSAI_ZAMES_MMACC : XSAI_ZAMES_InstMMAcc<0b0000, (outs XSAI_ZAMES_AccReg:$md_wb),
                                   (ins XSAI_ZAMES_AccReg:$md, XSAI_ZAMES_TileReg:$ms2,
                                        XSAI_ZAMES_TileReg:$ms1),
                                   "mmacc"> {
    let Constraints = "$md_wb = $md";
  }
}

//===----------------------------------------------------------------------===//
// ZMASYNC Matrix Async Synchronization Instructions
//===----------------------------------------------------------------------===//

class XSAI_ZMASYNC_Inst<bits<4> func4, dag outs, dag ins,
                  string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> rs1;
  bits<5> sync;

  let Inst{31-28} = func4;
  let Inst{27-26} = 0b00;
  let Inst{25} = 0b0;
  let Inst{24-20} = sync;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b100;
  let Inst{11-7} = 0b00000;
  let Inst{6-0} = OPC_CUSTOM_1.Value;
}

let Predicates = [HasStdExtZmasync], hasSideEffects = 1, mayLoad = 0,
    mayStore = 0 in {
  def XSAI_ZMASYNC_MSYNCREGRESET
      : XSAI_ZMASYNC_Inst<0b1000, (outs XSAI_ZMASYNC_SyncR:$sync), (ins),
                    "msyncregreset", "$sync"> {
    let rs1 = 0b00000;
  }

  let Constraints = "$sync = $src" in {
    def XSAI_ZMASYNC_MRELEASE
        : XSAI_ZMASYNC_Inst<0b1001, (outs XSAI_ZMASYNC_SyncR:$sync), (ins XSAI_ZMASYNC_SyncR:$src),
                      "mrelease", "$sync"> {
      let rs1 = 0b00000;
    }
  }

  def XSAI_ZMASYNC_MACQUIRE
      : XSAI_ZMASYNC_Inst<0b1010, (outs), (ins XSAI_ZMASYNC_SyncR:$sync, GPR:$rs1),
                    "macquire", "$sync, $rs1">;

  def XSAI_ZMASYNC_MFENCE
      : XSAI_ZMASYNC_Inst<0b1011, (outs), (ins), "mfence", ""> {
    let rs1 = 0b00000;
    let sync = 0b00000;
  }
}
