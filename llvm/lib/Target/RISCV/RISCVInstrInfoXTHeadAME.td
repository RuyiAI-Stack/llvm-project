//===- RISCVInstrInfoXTHeadAME.td --------------------------------------*- tablegen -*-===//
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
// T-Head AME 32-bit matrix extension instructions.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// XTAME (RISC-V Matrix Extension) 32-bit Instructions
//===----------------------------------------------------------------------===//
// Reference: RISC-V Matrix Extension Specification

def MatrixIndexAsmOperand : AsmOperandClass {
  let Name = "MatrixIndex";
  let RenderMethod = "addImmOperands";
  let PredicateMethod = "isUImm3";
  let DiagnosticType = "InvalidMatrixIndex";
}

// Operand type for MatrixReg index (0-7), printed with "m" prefix in AsmString
def MatrixIndex : RISCVOp<i64> {
  let ParserMatchClass = MatrixIndexAsmOperand;
  let DecoderMethod = "decodeUImmOperand<3>";
  let OperandType = "OPERAND_UIMM3";
}

def MatrixRegAsmOperand : AsmOperandClass {
  let Name = "MatrixRegOp";
  let ParserMethod = "parseMatrixReg";
  let RenderMethod = "addRegOperands";
  let PredicateMethod = "isMatrixReg";
}

def MatrixRegOp : RegisterOperand<MatrixReg> {
  let ParserMatchClass = MatrixRegAsmOperand;
  let PrintMethod = "printMatrixReg";
}

//===----------------------------------------------------------------------===//
// XTAME 32-bit Instruction Format Base Class
//===----------------------------------------------------------------------===//

// Base class for XTAME 32-bit matrix multiplication instructions
// Uses MatrixReg for inputs (ms1, ms2) and MatrixReg for output (md)
class RVInstXTAME32<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<4> func4;
  bits<3> uop = 0b000;        // usually 0
  bit     size;
  bits<3> ms2;
  bits<3> ms1;
  bits<3> md;
  bits<3> func3 = 0b000;      // usually 0
  bits<2> size_w;
  bits<3> type;
  bits<7> opcode = 0b0101011;

  let Inst{31-28} = func4;
  let Inst{27-25} = uop;
  let Inst{24} = size;
  let Inst{23-21} = ms2;
  let Inst{20-18} = ms1;
  let Inst{17-15} = md;
  let Inst{14-12} = func3;
  let Inst{11-10} = size_w;
  let Inst{9-7} = type;
  let Inst{6-0} = opcode;
}

//===----------------------------------------------------------------------===//
// AME Matrix Multiplication Instructions
//===----------------------------------------------------------------------===//
class TH_MMACC<bits<3> type_val, string opcodestr>
    : RVInstXTAME32<(outs MatrixRegOp:$md),
                  (ins MatrixRegOp:$md_in, MatrixRegOp:$ms2, MatrixRegOp:$ms1),
                  opcodestr, "$md, $ms2, $ms1"> {
  let Constraints = "$md = $md_in";
  let func4   = 0b0010;
  let uop     = 0b000;
  let size    = 0;
  let func3   = 0b000;
  let size_w    = 0b00;
  let type    = type_val;
  let opcode  = 0b0101011;
}

// th.mmacc.w.b - int8 × int8 → int32 accumulate
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MMACC_W_B : TH_MMACC<0b000, "th.mmacc.w.b">;
// th.mmaccu.w.b - uint8 × uint8 → uint32 accumulate
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MMACCU_W_B : TH_MMACC<0b001, "th.mmaccu.w.b">;

//===----------------------------------------------------------------------===//
// AME Matrix Multiplication Instructions (float)
//===----------------------------------------------------------------------===//
class TH_MFMACC<bit size_val, bits<2> size_w_val, bits<3> type_val, string opcodestr>
    : RVInstXTAME32<(outs MatrixRegOp:$md),
                  (ins MatrixRegOp:$md_in, MatrixRegOp:$ms2, MatrixRegOp:$ms1),
                  opcodestr, "$md, $ms2, $ms1"> {
  let Constraints = "$md = $md_in";
  let func4   = 0b0001;
  let uop     = 0b000;
  let size    = size_val;
  let func3   = 0b000;
  let size_w  = size_w_val;
  let type    = type_val;
  let opcode  = 0b0101011;
}

// th.mfmacc.s - float32 × float32 → float32 accumulate
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MFMACC_S : TH_MFMACC<0b0, 0b10, 0b000, "th.mfmacc.s">;

// th.mfmacc.d.s - float32 × float32 → float64 accumulate
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MFMACC_D_S : TH_MFMACC<0b1, 0b10, 0b000, "th.mfmacc.d.s">;

//===----------------------------------------------------------------------===//
// AME 32-bit Configuration Instructions (Register Type)
// Reference: RISC-V Matrix Specification v0.5.0, Section 4.1, Table 7
// Format:
// | 31 | 30:28 | 27:25 | 24:20 | 19:15 | 14:12 | 11:9 | 8 | 7 | 6:0      |
// | 1  | func  | 111   | 00000 | rs1   | 000   | 000  | 0 | 0 | 0101011  |
//===----------------------------------------------------------------------===//

// Base class for 32-bit register-type configuration instructions
class RVInstXTAMEConfig32Reg<dag outs, dag ins, string opcodestr, string argstr,
                           bits<3> func_val>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<5> rs1;

  let Inst{31}   = 1;               // register type
  let Inst{30-28}= func_val;
  let Inst{27-25}= 0b111;           // uop fixed to 111
  let Inst{24-20}= 0b00000;         // reserved
  let Inst{19-15}= rs1;
  let Inst{14-12}= 0b000;           // func3 fixed to 000
  let Inst{11-9} = 0b000;           // nop field
  let Inst{8}    = 0;               // mxb = 0
  let Inst{7}    = 0;               // mxa = 0
  let Inst{6-0}  = 0b0101011;       // custom-1 opcode
}

//===----------------------------------------------------------------------===//
// AME 32-bit Configuration Instructions (Immediate Type)
// Reference: RISC-V Matrix Specification v0.5.0, Section 4.1, Table 7
// Format:
// | 31 | 30:28 | 27:25 | 24:18 | 17:15 | 14:12 | 11:9 | 8 | 7 | 6:0      |
// | 0  | func  | 111   | uimm7 | 000   | 000   | 000  | 0 | 0 | 0101011  |
//===----------------------------------------------------------------------===//

// Base class for 32-bit immediate-type configuration instructions
class RVInstXTAMEConfig32Imm<dag outs, dag ins, string opcodestr, string argstr,
                           bits<3> func_val>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<7> imm;

  let Inst{31}   = 0;               // immediate type
  let Inst{30-28}= func_val;
  let Inst{27-25}= 0b111;           // uop fixed to 111
  let Inst{24-18}= imm{6-0};        // imm[6:0]
  let Inst{17-15}= 0b000;           // reserved
  let Inst{14-12}= 0b000;           // func3 fixed to 000
  let Inst{11-9} = 0b000;           // nop field
  let Inst{8}    = 0;               // mxb = 0
  let Inst{7}    = 0;               // mxa = 0
  let Inst{6-0}  = 0b0101011;       // custom-1 opcode
}

//===----------------------------------------------------------------------===//
// Concrete Instructions
//===----------------------------------------------------------------------===//

let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // th.mcfgk - configure tile K dimension (func=000)
  def TH_MCFGK : RVInstXTAMEConfig32Reg<(outs), (ins GPR:$rs1),
                                       "th.mcfgk", "$rs1", 0b000>;

  // th.mcfgm - configure tile M dimension (func=001)
  def TH_MCFGM : RVInstXTAMEConfig32Reg<(outs), (ins GPR:$rs1),
                                       "th.mcfgm", "$rs1", 0b001>;

  // th.mcfgn - configure tile N dimension (func=010)
  def TH_MCFGN : RVInstXTAMEConfig32Reg<(outs), (ins GPR:$rs1),
                                       "th.mcfgn", "$rs1", 0b010>;

  // th.mcfg - configure entire tile size (func=111)
  def TH_MCFG  : RVInstXTAMEConfig32Reg<(outs), (ins GPR:$rs1),
                                       "th.mcfg", "$rs1", 0b111>;
}

let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // th.mcfgki - configure tile K dimension from immediate (func=000)
  def TH_MCFGKI : RVInstXTAMEConfig32Imm<(outs), (ins uimm32:$imm),
                                        "th.mcfgki", "$imm", 0b000>;

  // th.mcfgmi - configure tile M dimension from immediate (func=001)
  def TH_MCFGMI : RVInstXTAMEConfig32Imm<(outs), (ins uimm32:$imm),
                                        "th.mcfgmi", "$imm", 0b001>;

  // th.mcfgni - configure tile N dimension from immediate (func=010)
  def TH_MCFGNI : RVInstXTAMEConfig32Imm<(outs), (ins uimm32:$imm),
                                        "th.mcfgni", "$imm", 0b010>;
}

//===----------------------------------------------------------------------===//
// XTAME 32-bit Load/Store Instructions
// Reference: RISC-V Matrix Specification v0.5.0, Section 4.4, Table 10
// Format:
// | 31:28 | 27:25 | 24:20 | 19:15 | 14:12 | 11:10 | 9:7   | 6:0          |
// | func4 | uop   | rs2   | rs1   | func3 | size  | md/ms3| opcode       |
// func3 = 000, opcode = 0b0101011 (custom-1)
//===----------------------------------------------------------------------===//

// Base class for all 32-bit load instructions (uop = 100)
class RVInstXTAMELoad32<bits<4> func4_val, string opcodestr>
    : RVInst<(outs MatrixRegOp:$md), (ins GPR:$rs2, GPR:$rs1),
               opcodestr, "$md, $rs2, $rs1", [], InstFormatOther> {
  bits<5> rs2;
  bits<5> rs1;
  bits<3> md;
  bits<2> size;

  let Inst{31-28} = func4_val;
  let Inst{27-25} = 0b100;          // uop = 100 for load
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b000;          // func3 = 000
  let Inst{11-10} = size;           // size to be set in derived classes
  let Inst{9-7}   = md;
  let Inst{6-0}   = 0b0101011;      // custom-1 opcode
}

// Base class for all 32-bit store instructions (uop = 101)
class RVInstXTAMEStore32<bits<4> func4_val, string opcodestr>
    : RVInst<(outs), (ins MatrixRegOp:$ms3, GPR:$rs1, GPR:$rs2),
               opcodestr, "$ms3, $rs2, $rs1", [], InstFormatOther> {
  bits<5> rs2;
  bits<5> rs1;
  bits<3> ms3;
  bits<2> size;

  let Inst{31-28} = func4_val;
  let Inst{27-25} = 0b101;          // uop = 101 for store
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b000;          // func3 = 000
  let Inst{11-10} = size;           // size to be set in derived classes
  let Inst{9-7}   = ms3;
  let Inst{6-0}   = 0b0101011;      // custom-1 opcode
}

//===----------------------------------------------------------------------===//
// Normal Load Instructions (func4 = 0000)
// th.mld.e8, th.mld.e16, th.mld.e32, th.mld.e64
//===----------------------------------------------------------------------===//
let Predicates = [HasVendorXTHeadAME], mayLoad = 1, mayStore = 0, hasSideEffects = 0 in {
  def TH_MLDE8  : RVInstXTAMELoad32<0b0000, "th.mlde8">  { let size = 0b00; }
  def TH_MLDE16 : RVInstXTAMELoad32<0b0000, "th.mlde16"> { let size = 0b01; }
  def TH_MLDE32 : RVInstXTAMELoad32<0b0000, "th.mlde32"> { let size = 0b10; }
  def TH_MLDE64 : RVInstXTAMELoad32<0b0000, "th.mlde64"> { let size = 0b11; }
}

//===----------------------------------------------------------------------===//
// Normal Store Instructions (func4 = 0000)
// th.mst.e8, th.mst.e16, th.mst.e32, th.mst.e64
//===----------------------------------------------------------------------===//
let Predicates = [HasVendorXTHeadAME], mayLoad = 0, mayStore = 1, hasSideEffects = 0 in {
  def TH_MSTE8  : RVInstXTAMEStore32<0b0000, "th.mste8">  { let size = 0b00; }
  def TH_MSTE16 : RVInstXTAMEStore32<0b0000, "th.mste16"> { let size = 0b01; }
  def TH_MSTE32 : RVInstXTAMEStore32<0b0000, "th.mste32"> { let size = 0b10; }
  def TH_MSTE64 : RVInstXTAMEStore32<0b0000, "th.mste64"> { let size = 0b11; }
}

//===----------------------------------------------------------------------===//
// Transposed Load Instructions (func4 = 0011)
// th.mldt.e8, th.mldt.e16, th.mldt.e32, th.mldt.e64
//===----------------------------------------------------------------------===//
let Predicates = [HasVendorXTHeadAME], mayLoad = 1, mayStore = 0, hasSideEffects = 0 in {
  def TH_MLDTE8  : RVInstXTAMELoad32<0b0011, "th.mldte8">  { let size = 0b00; }
  def TH_MLDTE16 : RVInstXTAMELoad32<0b0011, "th.mldte16"> { let size = 0b01; }
  def TH_MLDTE32 : RVInstXTAMELoad32<0b0011, "th.mldte32"> { let size = 0b10; }
  def TH_MLDTE64 : RVInstXTAMELoad32<0b0011, "th.mldte64"> { let size = 0b11; }
}

//===----------------------------------------------------------------------===//
// MISC Instructions (format "others") - Base class
//===----------------------------------------------------------------------===//

class RVInstXTAMEMISC<dag outs, dag ins, string opcodestr, string argstr,
                    bits<4> func4_val, bits<3> uop_val>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<4> func4 = func4_val;
  bits<3> uop   = uop_val;
  bit     ctrl  = 0;              // bit 24 must be 0 for mzero
  bits<3> ms2   = 0b000;          // fixed to 000
  bits<3> ms1   = 0b000;          // fixed to 000
  bits<3> md;                     // destination base matrix register
  bits<3> func3 = 0b000;          // fixed to 000
  bits<2> size  = 0b00;           // size field (00 for mzero)
  bits<3> uimm3;                  // immediate for register count encoding
  bits<7> opcode = 0b0101011;     // custom-1

  let Inst{31-28} = func4;
  let Inst{27-25} = uop;
  let Inst{24}    = ctrl;
  let Inst{23-21} = ms2;
  let Inst{20-18} = ms1;
  let Inst{17-15} = md;
  let Inst{14-12} = func3;
  let Inst{11-10} = size;
  let Inst{9-7}   = uimm3;
  let Inst{6-0}   = opcode;
}

//===----------------------------------------------------------------------===//
// th.mzero variants (different uimm3 encodings)
//===----------------------------------------------------------------------===//

let Predicates = [HasVendorXTHeadAME], hasSideEffects = 1, mayLoad = 0, mayStore = 0 in {
  // Zero 1 matrix register (uimm3 = 000)
  def TH_MZERO   : RVInstXTAMEMISC<(outs), (ins MatrixRegOp:$md),
                                 "th.mzero", "$md",
                                 0b1010, 0b000> {
    let uimm3 = 0b000;
  }

  // Zero 2 matrix registers (uimm3 = 001)
  def TH_MZERO2R : RVInstXTAMEMISC<(outs), (ins MatrixRegOp:$md),
                                 "th.mzero2r", "$md",
                                 0b1010, 0b000> {
    let uimm3 = 0b001;
  }

  // Zero 4 matrix registers (uimm3 = 011)
  def TH_MZERO4R : RVInstXTAMEMISC<(outs), (ins MatrixRegOp:$md),
                                 "th.mzero4r", "$md",
                                 0b1010, 0b000> {
    let uimm3 = 0b011;
  }

  // Zero 8 matrix registers (uimm3 = 111)
  def TH_MZERO8R : RVInstXTAMEMISC<(outs), (ins MatrixRegOp:$md),
                                 "th.mzero8r", "$md",
                                 0b1010, 0b000> {
    let uimm3 = 0b111;
  }
}

//===----------------------------------------------------------------------===//
// Pseudo Instructions for 32-bit New Instructions
//===----------------------------------------------------------------------===//

// Configuration immediate instructions (no matrix register)
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 1, mayLoad = 0, mayStore = 0,
    isCodeGenOnly = 1 in {
  def TH_MCFGMI_PSEUDO : Pseudo<(outs), (ins i64imm:$imm), []> {
    let AsmString = "th.mcfgmi\t$imm";
  }
  def TH_MCFGNI_PSEUDO : Pseudo<(outs), (ins i64imm:$imm), []> {
    let AsmString = "th.mcfgni\t$imm";
  }
  def TH_MCFGKI_PSEUDO : Pseudo<(outs), (ins i64imm:$imm), []> {
    let AsmString = "th.mcfgki\t$imm";
  }
}

// Zero instruction (single matrix register)
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 1, mayLoad = 0, mayStore = 0,
    isCodeGenOnly = 1 in {
  def TH_MZERO_PSEUDO : Pseudo<(outs), (ins MatrixIndex:$md), []> {
    let AsmString = "th.mzero\tm$md";
  }
}

// Load instructions (normal and transposed)
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 1, mayLoad = 1, mayStore = 0,
    isCodeGenOnly = 1 in {
  def TH_MLDE8_PSEUDO : Pseudo<(outs), (ins MatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mlde8\tm$md, $rs2, ($rs1)";
  }
  def TH_MLDE16_PSEUDO : Pseudo<(outs), (ins MatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mlde16\tm$md, $rs2, ($rs1)";
  }
  def TH_MLDE32_PSEUDO : Pseudo<(outs), (ins MatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mlde32\tm$md, $rs2, ($rs1)";
  }
  def TH_MLDE64_PSEUDO : Pseudo<(outs), (ins MatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mlde64\tm$md, $rs2, ($rs1)";
  }
  def TH_MLDTE8_PSEUDO : Pseudo<(outs), (ins MatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mldte8\tm$md, $rs2, ($rs1)";
  }
  def TH_MLDTE16_PSEUDO : Pseudo<(outs), (ins MatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mldte16\tm$md, $rs2, ($rs1)";
  }
  def TH_MLDTE32_PSEUDO : Pseudo<(outs), (ins MatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mldte32\tm$md, $rs2, ($rs1)";
  }
  def TH_MLDTE64_PSEUDO : Pseudo<(outs), (ins MatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mldte64\tm$md, $rs2, ($rs1)";
  }
}

// Store instruction
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 1, mayLoad = 0, mayStore = 1,
    isCodeGenOnly = 1 in {
  def TH_MSTE8_PSEUDO : Pseudo<(outs), (ins MatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mste8\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSTE16_PSEUDO : Pseudo<(outs), (ins MatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mste16\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSTE32_PSEUDO : Pseudo<(outs), (ins MatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mste32\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSTE64_PSEUDO : Pseudo<(outs), (ins MatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mste64\tm$ms3, $rs2, ($rs1)";
  }
}

// Matrix multiply instruction
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 1,
    isCodeGenOnly = 1 in {
  def TH_MMACC_W_B_PSEUDO : Pseudo<(outs),
      (ins MatrixIndex:$md, MatrixIndex:$ms2, MatrixIndex:$ms1), []> {
    let AsmString = "th.mmacc.w.b\tm$md, m$ms2, m$ms1";
  }
  def TH_MMACCU_W_B_PSEUDO : Pseudo<(outs),
      (ins MatrixIndex:$md, MatrixIndex:$ms2, MatrixIndex:$ms1), []> {
    let AsmString = "th.mmaccu.w.b\tm$md, m$ms2, m$ms1";
  }
  def TH_MFMACC_S_PSEUDO : Pseudo<(outs),
      (ins MatrixIndex:$md, MatrixIndex:$ms2, MatrixIndex:$ms1), []> {
    let AsmString = "th.mfmacc.s\tm$md, m$ms2, m$ms1";
  }

  def TH_MFMACC_D_S_PSEUDO : Pseudo<(outs),
      (ins MatrixIndex:$md, MatrixIndex:$ms2, MatrixIndex:$ms1), []> {
    let AsmString = "th.mfmacc.d.s\tm$md, m$ms2, m$ms1";
  }
}

//===----------------------------------------------------------------------===//
// Pattern Matching for 32-bit New Instructions
//===----------------------------------------------------------------------===//

let Predicates = [HasVendorXTHeadAME] in {

  // Configuration immediate instructions
  def : Pat<(int_riscv_th_mcfgmi timm:$imm),
            (TH_MCFGMI_PSEUDO timm:$imm)>;
  def : Pat<(int_riscv_th_mcfgni timm:$imm),
            (TH_MCFGNI_PSEUDO timm:$imm)>;
  def : Pat<(int_riscv_th_mcfgki timm:$imm),
            (TH_MCFGKI_PSEUDO timm:$imm)>;

  // Zero instruction
  def : Pat<(int_riscv_th_mzero timm:$md),
            (TH_MZERO_PSEUDO timm:$md)>;

  // Load instructions
  def : Pat<(int_riscv_th_mlde8 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MLDE8_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mlde16 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MLDE16_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mlde32 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MLDE32_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mlde64 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MLDE64_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mldte8 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MLDTE8_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mldte16 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MLDTE16_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mldte32 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MLDTE32_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mldte64 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MLDTE64_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;

  // Store instruction
  def : Pat<(int_riscv_th_mste8 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSTE8_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mste16 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSTE16_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mste32 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSTE32_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mste64 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSTE64_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;

  // Matrix multiply instruction
  def : Pat<(int_riscv_th_mmacc_w_b timm:$md, timm:$ms2, timm:$ms1),
            (TH_MMACC_W_B_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mmaccu_w_b timm:$md, timm:$ms2, timm:$ms1),
            (TH_MMACCU_W_B_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mfmacc_s timm:$md, timm:$ms2, timm:$ms1),
            (TH_MFMACC_S_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mfmacc_d_s timm:$md, timm:$ms2, timm:$ms1),
            (TH_MFMACC_D_S_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
}
