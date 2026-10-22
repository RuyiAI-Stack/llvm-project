//===-- RISCVInstrInfoZames.td - ZAMES/ZMASYNC instructions -*- tablegen -*-===//
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

def zames_uimm10 : RISCVUImmLeafOp<10>;

// mcfg0..mcfg7 select the hardware matrix configuration register configured by
// msetcfg/mgetcfg. The value is encoded as a 3-bit immediate.
def MCFGSelAsmOperand : AsmOperandClass {
  let Name = "MCFGSel";
  let RenderMethod = "addImmOperands";
  let ParserMethod = "parseMCFGSel";
}

def mcfgsel : RISCVUImmLeafOp<3> {
  let ParserMatchClass = MCFGSelAsmOperand;
  let PrintMethod = "printMCFGSel";
}

class ZAMESInstConfigImm<bits<4> func4, string opcodestr>
    : RVInst<(outs), (ins zames_uimm10:$imm), opcodestr, "$imm", [],
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

class ZAMESInstConfigReg<bits<4> func4, string opcodestr>
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

class ZAMESInstSetCfg<string opcodestr>
    : RVInst<(outs), (ins mcfgsel:$cfg, GPR:$rs1), opcodestr, "$cfg, $rs1",
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

class ZAMESInstGetCfg<string opcodestr>
    : RVInst<(outs GPR:$rd), (ins mcfgsel:$cfg), opcodestr, "$rd, $cfg",
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

class ZAMESInstInit<string opcodestr>
    : RVInst<(outs), (ins), opcodestr, "", [], InstFormatI> {
  let Inst{31-7} = 0;
  let Inst{6-0} = OPC_CUSTOM_1.Value;
}

class ZAMESInstLoadStore<bits<4> func4, bit ls, dag outs, dag ins,
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

class ZAMESInstWholeLoadStore<bits<4> func4, bit ls, dag outs, dag ins,
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

class ZAMESInstMMAcc<bits<4> func4, dag outs, dag ins,
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

class ZAMESInstMisc<bits<4> func4, dag outs, dag ins,
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
  def ZAMES_MSETTILEMI : ZAMESInstConfigImm<0b0010, "msettilemi">;
  def ZAMES_MSETTILENI : ZAMESInstConfigImm<0b0011, "msettileni">;
  def ZAMES_MSETTILEKI : ZAMESInstConfigImm<0b0001, "msettileki">;

  def ZAMES_MSETTILEM : ZAMESInstConfigReg<0b0010, "msettilem">;
  def ZAMES_MSETTILEN : ZAMESInstConfigReg<0b0011, "msettilen">;
  def ZAMES_MSETTILEK : ZAMESInstConfigReg<0b0001, "msettilek">;

  def ZAMES_MSETCFG : ZAMESInstSetCfg<"msetcfg">;
  def ZAMES_MGETCFG : ZAMESInstGetCfg<"mgetcfg">;

  def ZAMES_MINIT : ZAMESInstInit<"minit">;
}

let Predicates = [HasStdExtZames], hasSideEffects = 1, mayLoad = 1,
    mayStore = 0 in {
  def ZAMES_MLA : ZAMESInstLoadStore<0b0000, 0b0, (outs ZamesTileReg:$md),
                                     (ins GPRMemZeroOffset:$rs1, GPR:$rs2),
                                     "mla">;
  def ZAMES_MLB : ZAMESInstLoadStore<0b0001, 0b0, (outs ZamesTileReg:$md),
                                     (ins GPRMemZeroOffset:$rs1, GPR:$rs2),
                                     "mlb">;
  def ZAMES_MLC : ZAMESInstLoadStore<0b0010, 0b0, (outs ZamesAccReg:$md),
                                     (ins GPRMemZeroOffset:$rs1, GPR:$rs2),
                                     "mlc">;
  def ZAMES_MLBT : ZAMESInstLoadStore<0b0101, 0b0, (outs ZamesTileReg:$md),
                                      (ins GPRMemZeroOffset:$rs1, GPR:$rs2),
                                      "mlbt">;
  def ZAMES_MLAT : ZAMESInstLoadStore<0b0100, 0b0, (outs ZamesTileReg:$md),
                                      (ins GPRMemZeroOffset:$rs1, GPR:$rs2),
                                      "mlat">;
  def ZAMES_MLCT : ZAMESInstLoadStore<0b0110, 0b0, (outs ZamesAccReg:$md),
                                      (ins GPRMemZeroOffset:$rs1, GPR:$rs2),
                                      "mlct">;

  def ZAMES_MLA_WHOLE
      : ZAMESInstWholeLoadStore<0b1000, 0b0, (outs ZamesTileReg:$md),
                                (ins GPRMemZeroOffset:$rs1), "mla.whole">;
  def ZAMES_MLB_WHOLE
      : ZAMESInstWholeLoadStore<0b1001, 0b0, (outs ZamesTileReg:$md),
                                (ins GPRMemZeroOffset:$rs1), "mlb.whole">;
  def ZAMES_MLC_WHOLE
      : ZAMESInstWholeLoadStore<0b1010, 0b0, (outs ZamesAccReg:$md),
                                (ins GPRMemZeroOffset:$rs1), "mlc.whole">;
}

let Predicates = [HasStdExtZames], hasSideEffects = 1, mayLoad = 0,
    mayStore = 1 in {
  def ZAMES_MSC : ZAMESInstLoadStore<0b0010, 0b1, (outs),
                                     (ins ZamesAccReg:$md,
                                          GPRMemZeroOffset:$rs1, GPR:$rs2),
                                     "msc">;
  def ZAMES_MSA : ZAMESInstLoadStore<0b0000, 0b1, (outs),
                                     (ins ZamesTileReg:$md,
                                          GPRMemZeroOffset:$rs1, GPR:$rs2),
                                     "msa">;
  def ZAMES_MSB : ZAMESInstLoadStore<0b0001, 0b1, (outs),
                                     (ins ZamesTileReg:$md,
                                          GPRMemZeroOffset:$rs1, GPR:$rs2),
                                     "msb">;
  def ZAMES_MSAT : ZAMESInstLoadStore<0b0100, 0b1, (outs),
                                      (ins ZamesTileReg:$md,
                                           GPRMemZeroOffset:$rs1, GPR:$rs2),
                                      "msat">;
  def ZAMES_MSBT : ZAMESInstLoadStore<0b0101, 0b1, (outs),
                                      (ins ZamesTileReg:$md,
                                           GPRMemZeroOffset:$rs1, GPR:$rs2),
                                      "msbt">;
  def ZAMES_MSCT : ZAMESInstLoadStore<0b0110, 0b1, (outs),
                                      (ins ZamesAccReg:$md,
                                           GPRMemZeroOffset:$rs1, GPR:$rs2),
                                      "msct">;

  def ZAMES_MSA_WHOLE
      : ZAMESInstWholeLoadStore<0b1000, 0b1, (outs),
                                (ins ZamesTileReg:$md, GPRMemZeroOffset:$rs1),
                                "msa.whole">;
  def ZAMES_MSB_WHOLE
      : ZAMESInstWholeLoadStore<0b1001, 0b1, (outs),
                                (ins ZamesTileReg:$md, GPRMemZeroOffset:$rs1),
                                "msb.whole">;
  def ZAMES_MSC_WHOLE
      : ZAMESInstWholeLoadStore<0b1010, 0b1, (outs),
                                (ins ZamesAccReg:$md, GPRMemZeroOffset:$rs1),
                                "msc.whole">;
}

let Predicates = [HasStdExtZames], hasSideEffects = 1, mayLoad = 0,
    mayStore = 0 in {
  def ZAMES_MZERO : ZAMESInstMisc<0b0000, (outs ZamesTileOrAccReg:$md), (ins),
                                 "mzero">;

  def ZAMES_MMACC : ZAMESInstMMAcc<0b0000, (outs ZamesAccReg:$md_wb),
                                   (ins ZamesAccReg:$md, ZamesTileReg:$ms2,
                                        ZamesTileReg:$ms1),
                                   "mmacc"> {
    let Constraints = "$md_wb = $md";
  }
}

//===----------------------------------------------------------------------===//
// ZMASYNC Matrix Async Synchronization Instructions
//===----------------------------------------------------------------------===//

class ZMASYNCInst<bits<4> func4, dag outs, dag ins,
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
  def ZMASYNC_MSYNCREGRESET
      : ZMASYNCInst<0b1000, (outs SyncR:$sync), (ins),
                    "msyncregreset", "$sync"> {
    let rs1 = 0b00000;
  }

  let Constraints = "$sync = $src" in {
    def ZMASYNC_MRELEASE
        : ZMASYNCInst<0b1001, (outs SyncR:$sync), (ins SyncR:$src),
                      "mrelease", "$sync"> {
      let rs1 = 0b00000;
    }
  }

  def ZMASYNC_MACQUIRE
      : ZMASYNCInst<0b1010, (outs), (ins SyncR:$sync, GPR:$rs1),
                    "macquire", "$sync, $rs1">;

  def ZMASYNC_MFENCE
      : ZMASYNCInst<0b1011, (outs), (ins), "mfence", ""> {
    let rs1 = 0b00000;
    let sync = 0b00000;
  }
}
