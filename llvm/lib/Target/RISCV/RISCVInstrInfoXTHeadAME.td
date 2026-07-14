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

def THeadAMEMatrixIndexAsmOperand : AsmOperandClass {
  let Name = "THeadAMEMatrixIndex";
  let RenderMethod = "addImmOperands";
  let PredicateMethod = "isUImm3";
  let DiagnosticType = "InvalidTHeadAMEMatrixIndex";
}

// Operand type for THeadAMEMatrixReg index (0-7), printed with "m" prefix in AsmString
def THeadAMEMatrixIndex : RISCVOp<i64> {
  let ParserMatchClass = THeadAMEMatrixIndexAsmOperand;
  let DecoderMethod = "decodeUImmOperand<3>";
  let OperandType = "OPERAND_UIMM3";
}

def THeadAMEMatrixRegAsmOperand : AsmOperandClass {
  let Name = "THeadAMEMatrixRegOp";
  let ParserMethod = "parseTHeadAMEMatrixReg";
  let RenderMethod = "addRegOperands";
  let PredicateMethod = "isTHeadAMEMatrixReg";
}

def THeadAMEMatrixRegOp : RegisterOperand<THeadAMEMatrixReg> {
  let ParserMatchClass = THeadAMEMatrixRegAsmOperand;
  let PrintMethod = "printTHeadAMEMatrixReg";
}

//===----------------------------------------------------------------------===//
// XTAME 32-bit Instruction Format Base Class
//===----------------------------------------------------------------------===//

// Base class for XTAME 32-bit matrix multiplication instructions
// Uses THeadAMEMatrixReg for inputs (ms1, ms2) and THeadAMEMatrixReg for output (md)
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
    : RVInstXTAME32<(outs THeadAMEMatrixRegOp:$md),
                  (ins THeadAMEMatrixRegOp:$md_in, THeadAMEMatrixRegOp:$ms2, THeadAMEMatrixRegOp:$ms1),
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
// th.mmaccu.w.b - uint8 × uint8 → int32 accumulate
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MMACCU_W_B : TH_MMACC<0b001, "th.mmaccu.w.b">;
// th.mmaccus.w.b - uint8 × int8 → int32 accumulate
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MMACCUS_W_B : TH_MMACC<0b010, "th.mmaccus.w.b">;
// th.mmaccsu.w.b - int8 × uint8 → int32 accumulate
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MMACCSU_W_B : TH_MMACC<0b011, "th.mmaccsu.w.b">;

//===----------------------------------------------------------------------===//
// AME Matrix Multiplication Instructions (float)
//===----------------------------------------------------------------------===//
class TH_MFMACC<bit size_val, bits<2> size_w_val, bits<3> type_val, string opcodestr>
    : RVInstXTAME32<(outs THeadAMEMatrixRegOp:$md),
                  (ins THeadAMEMatrixRegOp:$md_in, THeadAMEMatrixRegOp:$ms2, THeadAMEMatrixRegOp:$ms1),
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

// th.mfmacc.h - float16 × float16 → float16 accumulate
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MFMACC_H : TH_MFMACC<0, 0b01, 0b000, "th.mfmacc.h">;
// th.mfmacc.bf16 - bfloat16 × bfloat16 → bfloat16 accumulate
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MFMACC_BF16 : TH_MFMACC<0, 0b01, 0b001, "th.mfmacc.bf16">;
// th.mfmacc.s - float32 × float32 → float32 accumulate
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MFMACC_S : TH_MFMACC<0b0, 0b10, 0b000, "th.mfmacc.s">;
// th.mfmacc.d - float64 × float64 → float64 accumulate
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MFMACC_D : TH_MFMACC<0b0, 0b11, 0b000, "th.mfmacc.d">;
// th.mfmacc.h.e4m3 - float8 x float8 → float16 accumulate with E4M3 format
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MFMACC_H_E4M3 : TH_MFMACC<0b1, 0b00, 0b001, "th.mfmacc.h.e4m3">;
// th.mfmacc.h.e5m2 - float8 x float8 → float16 accumulate with E5M2 format
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MFMACC_H_E5M2 : TH_MFMACC<0b1, 0b00, 0b000, "th.mfmacc.h.e5m2">;
// th.mfmacc.bf16.e4m3 - bfloat8 x bfloat8 → bfloat16 accumulate with E4M3 format
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MFMACC_BF16_E4M3 : TH_MFMACC<0b1, 0b00, 0b011, "th.mfmacc.bf16.e4m3">;
// th.mfmacc.bf16.e5m2 - bfloat8 x bfloat8 → bfloat16 accumulate with E5M2 format
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MFMACC_BF16_E5M2 : TH_MFMACC<0b1, 0b00, 0b010, "th.mfmacc.bf16.e5m2">;
// th.mfmacc.s.h - float16 × float16 → float32 accumulate
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MFMACC_S_H : TH_MFMACC<0b1, 0b01, 0b000, "th.mfmacc.s.h">;
// th.mfmacc.s.bf16 - bfloat16 × bfloat16 → float32 accumulate
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MFMACC_S_BF16 : TH_MFMACC<0b1, 0b01, 0b100, "th.mfmacc.s.bf16">;
// th.mfmacc.d.s - float32 × float32 → float64 accumulate
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MFMACC_D_S : TH_MFMACC<0b1, 0b10, 0b000, "th.mfmacc.d.s">;
// th.mfmacc.s.e4m3 - float8 x float8 → float32 accumulate with E4M3 format
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MFMACC_S_E4M3 : TH_MFMACC<0b1, 0b00, 0b101, "th.mfmacc.s.e4m3">;
// th.mfmacc.s.e5m2 - float8 x float8 → float32 accumulate with E5M2 format
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MFMACC_S_E5M2 : TH_MFMACC<0b1, 0b00, 0b100, "th.mfmacc.s.e5m2">;

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
    : RVInst<(outs THeadAMEMatrixRegOp:$md), (ins GPR:$rs2, GPR:$rs1),
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

class RVInstXTAMEPrefetch32<bits<4> func4_val, string opcodestr>
    : RVInst<(outs), (ins GPR:$rs2, GPR:$rs1),
               opcodestr, "$rs2, $rs1", [], InstFormatOther> {
  bits<5> rs2;
  bits<5> rs1;
  bits<2> size;

  let Inst{31-28} = func4_val;
  let Inst{27-25} = 0b100;          // uop = 100 for prefetch
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b000;          // func3 = 000
  let Inst{11-10} = size;           // size to be set in derived classes
  let Inst{9-7}   = 0b000;
  let Inst{6-0}   = 0b0101011;      // custom-1 opcode
}

// Base class for all 32-bit store instructions (uop = 101)
class RVInstXTAMEStore32<bits<4> func4_val, string opcodestr>
    : RVInst<(outs), (ins THeadAMEMatrixRegOp:$ms3, GPR:$rs1, GPR:$rs2),
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
// Transposed Store Instructions (func4 = 0011)
// th.mstte8, th.mstte16, th.mstte32, th.mstte64
//===----------------------------------------------------------------------===//
let Predicates = [HasVendorXTHeadAME], mayLoad = 0, mayStore = 1, hasSideEffects = 0 in {
  def TH_MSTTE8  : RVInstXTAMEStore32<0b0011, "th.mstte8">  { let size = 0b00; }
  def TH_MSTTE16 : RVInstXTAMEStore32<0b0011, "th.mstte16"> { let size = 0b01; }
  def TH_MSTTE32 : RVInstXTAMEStore32<0b0011, "th.mstte32"> { let size = 0b10; }
  def TH_MSTTE64 : RVInstXTAMEStore32<0b0011, "th.mstte64"> { let size = 0b11; }
}

//===----------------------------------------------------------------------===//
// Stream Load Instructions (func4 = 0001)
// th.mslde8, th.mslde16, th.mslde32, th.mslde64
//===----------------------------------------------------------------------===//

let Predicates = [HasVendorXTHeadAME], mayLoad = 1, mayStore = 0, hasSideEffects = 0 in {
  def TH_MSLDE8  : RVInstXTAMELoad32<0b0001, "th.mslde8">  { let size = 0b00; }
  def TH_MSLDE16 : RVInstXTAMELoad32<0b0001, "th.mslde16"> { let size = 0b01; }
  def TH_MSLDE32 : RVInstXTAMELoad32<0b0001, "th.mslde32"> { let size = 0b10; }
  def TH_MSLDE64 : RVInstXTAMELoad32<0b0001, "th.mslde64"> { let size = 0b11; }
}

//===----------------------------------------------------------------------===//
// Stream Store Instructions (func4 = 0001)
// th.msste8, th.msste16, th.msste32, th.msste64
//===----------------------------------------------------------------------===//

let Predicates = [HasVendorXTHeadAME], mayLoad = 0, mayStore = 1, hasSideEffects = 0 in {
  def TH_MSSTE8  : RVInstXTAMEStore32<0b0001, "th.msste8">  { let size = 0b00; }
  def TH_MSSTE16 : RVInstXTAMEStore32<0b0001, "th.msste16"> { let size = 0b01; }
  def TH_MSSTE32 : RVInstXTAMEStore32<0b0001, "th.msste32"> { let size = 0b10; }
  def TH_MSSTE64 : RVInstXTAMEStore32<0b0001, "th.msste64"> { let size = 0b11; }
}

//===----------------------------------------------------------------------===//
// Transposed Stream Load Instructions (func4 = 0100)
// th.msldte8, th.msldte16, th.msldte32, th.msldte64
//===----------------------------------------------------------------------===//

let Predicates = [HasVendorXTHeadAME], mayLoad = 1, mayStore = 0, hasSideEffects = 0 in {
  def TH_MSLDTE8  : RVInstXTAMELoad32<0b0100, "th.msldte8">  { let size = 0b00; }
  def TH_MSLDTE16 : RVInstXTAMELoad32<0b0100, "th.msldte16"> { let size = 0b01; }
  def TH_MSLDTE32 : RVInstXTAMELoad32<0b0100, "th.msldte32"> { let size = 0b10; }
  def TH_MSLDTE64 : RVInstXTAMELoad32<0b0100, "th.msldte64"> { let size = 0b11; }
}

//===----------------------------------------------------------------------===//
// Transposed Stream Store Instructions (func4 = 0100)
// th.msstte8, th.msstte16, th.msstte32, th.msstte64
//===----------------------------------------------------------------------===//

let Predicates = [HasVendorXTHeadAME], mayLoad = 0, mayStore = 1, hasSideEffects = 0 in {
  def TH_MSSTTE8  : RVInstXTAMEStore32<0b0100, "th.msstte8">  { let size = 0b00; }
  def TH_MSSTTE16 : RVInstXTAMEStore32<0b0100, "th.msstte16"> { let size = 0b01; }
  def TH_MSSTTE32 : RVInstXTAMEStore32<0b0100, "th.msstte32"> { let size = 0b10; }
  def TH_MSSTTE64 : RVInstXTAMEStore32<0b0100, "th.msstte64"> { let size = 0b11; }
}

//===----------------------------------------------------------------------===//
// Prefetch Load Instructions (func4 = 0101)
// th.mplde8, th.mplde16, th.mplde32, th.mplde64
//===----------------------------------------------------------------------===//

let Predicates = [HasVendorXTHeadAME], mayLoad = 1, mayStore = 0, hasSideEffects = 1 in {
  def TH_MPLDE8  : RVInstXTAMEPrefetch32<0b0101, "th.mplde8">  { let size = 0b00; }
  def TH_MPLDE16 : RVInstXTAMEPrefetch32<0b0101, "th.mplde16"> { let size = 0b01; }
  def TH_MPLDE32 : RVInstXTAMEPrefetch32<0b0101, "th.mplde32"> { let size = 0b10; }
  def TH_MPLDE64 : RVInstXTAMEPrefetch32<0b0101, "th.mplde64"> { let size = 0b11; }
}

//===----------------------------------------------------------------------===//
// Transposed Prefetch Load Instructions (func4 = 0110)
// th.mpldte8, th.mpldte16, th.mpldte32, th.mpldte64
//===----------------------------------------------------------------------===//

let Predicates = [HasVendorXTHeadAME], mayLoad = 1, mayStore = 0, hasSideEffects = 1 in {
  def TH_MPLDTE8  : RVInstXTAMEPrefetch32<0b0110, "th.mpldte8">  { let size = 0b00; }
  def TH_MPLDTE16 : RVInstXTAMEPrefetch32<0b0110, "th.mpldte16"> { let size = 0b01; }
  def TH_MPLDTE32 : RVInstXTAMEPrefetch32<0b0110, "th.mpldte32"> { let size = 0b10; }
  def TH_MPLDTE64 : RVInstXTAMEPrefetch32<0b0110, "th.mpldte64"> { let size = 0b11; }
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
  def TH_MZERO   : RVInstXTAMEMISC<(outs), (ins THeadAMEMatrixRegOp:$md),
                                 "th.mzero", "$md",
                                 0b1010, 0b000> {
    let uimm3 = 0b000;
  }

  // Zero 2 matrix registers (uimm3 = 001)
  def TH_MZERO2R : RVInstXTAMEMISC<(outs), (ins THeadAMEMatrixRegOp:$md),
                                 "th.mzero2r", "$md",
                                 0b1010, 0b000> {
    let uimm3 = 0b001;
  }

  // Zero 4 matrix registers (uimm3 = 011)
  def TH_MZERO4R : RVInstXTAMEMISC<(outs), (ins THeadAMEMatrixRegOp:$md),
                                 "th.mzero4r", "$md",
                                 0b1010, 0b000> {
    let uimm3 = 0b011;
  }

  // Zero 8 matrix registers (uimm3 = 111)
  def TH_MZERO8R : RVInstXTAMEMISC<(outs), (ins THeadAMEMatrixRegOp:$md),
                                 "th.mzero8r", "$md",
                                 0b1010, 0b000> {
    let uimm3 = 0b111;
  }
}

//===----------------------------------------------------------------------===//
// MISC Data Move Instructions
//===----------------------------------------------------------------------===//

// Data Move Instructions between Matrix Registers
class RVInstXTAMEMMOV<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<4> func4  = 0b0000;
  bits<3> uop;
  bit     ctrl   = 0b0;
  bits<3> ms2    = 0b000;
  bits<3> ms1;
  bits<3> md;
  bits<3> func3  = 0b000;
  bits<2> size   = 0b00;
  bits<3> type;
  bits<7> opcode = 0b0101011;

  let Inst{31-28} = func4;
  let Inst{27-25} = uop;
  let Inst{24}    = ctrl;
  let Inst{23-21} = ms2;
  let Inst{20-18} = ms1;
  let Inst{17-15} = md;
  let Inst{14-12} = func3;
  let Inst{11-10} = size;
  let Inst{9-7}   = type;
  let Inst{6-0}   = opcode;
}

// th.mmov.mm - move between matrix registers (uop = 000)
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def TH_MMOV_MM : RVInstXTAMEMMOV<(outs THeadAMEMatrixReg:$md), (ins THeadAMEMatrixReg:$ms1),
                                "th.mmov.mm", "$md, $ms1"> {
  let uop  = 0b000;
  let type = 0b001;
}

// Data Move Instructions between Integer and Matrix
// matrix-scalar move instructions (uop = 110)
class RVInstXTAMESMMOVE<bits<4> func4_val,
                        dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<3> uop     = 0b110;
  bits<5> rs2;
  bits<5> rs1;
  bits<3> func3   = 0b000;
  bits<2> size;
  bits<3> md;
  bits<7> opcode  = 0b0101011;

  let Inst{31-28} = func4_val;
  let Inst{27-25} = uop;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = func3;
  let Inst{11-10} = size;
  let Inst{9-7}   = md;
  let Inst{6-0}   = opcode;
}

// matrix-scalar mov with duplicate
class TH_MDUP<bits<2> sz, string opcodestr>
    : RVInstXTAMESMMOVE<0b0001, (outs THeadAMEMatrixReg:$md), (ins GPR:$rs2),
                        opcodestr, "$md, $rs2"> {
  let rs1 = 0b00000;
  let size = sz;
}

let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // th.mdupb.m.x - duplicate byte from GPR to all elements in a matrix register
  def TH_MDUPB_M_X : TH_MDUP<0b00, "th.mdupb.m.x">;
  // th.mduph.m.x - duplicate halfword from GPR to all elements in a matrix register
  def TH_MDUPH_M_X : TH_MDUP<0b01, "th.mduph.m.x">;
  // th.mdupw.m.x - duplicate word from GPR to all elements in a matrix register
  def TH_MDUPW_M_X : TH_MDUP<0b10, "th.mdupw.m.x">;
  // th.mdupd.m.x - duplicate doubleword from GPR to all elements in a matrix register
  def TH_MDUPD_M_X : TH_MDUP<0b11, "th.mdupd.m.x">;
}

// matrix-scalar move
class TH_MMOV<bits<2> sz, string opcodestr>
    : RVInstXTAMESMMOVE<0b0010, (outs THeadAMEMatrixReg:$md), (ins GPR:$rs2, GPR:$rs1),
                        opcodestr, "$md, $rs2, $rs1"> {
  let size = sz;
}

let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // th.mmovb.m.x
  def TH_MMOVB_M_X : TH_MMOV<0b00, "th.mmovb.m.x">;
  // th.mmovh.m.x
  def TH_MMOVH_M_X : TH_MMOV<0b01, "th.mmovh.m.x">;
  // th.mmovw.m.x
  def TH_MMOVW_M_X : TH_MMOV<0b10, "th.mmovw.m.x">;
  // th.mmovd.m.x
  def TH_MMOVD_M_X : TH_MMOV<0b11, "th.mmovd.m.x">;
}

// scalar-matrix move instructions (uop = 110)
class RVInstXTAMEMSMOVE<bits<2> sz, string opcodestr>
    : RVInst<(outs GPR:$rd), (ins THeadAMEMatrixReg:$ms2, GPR:$rs1),
             opcodestr, "$rd, $ms2, $rs1", [], InstFormatOther> {
  bits<5> rd;
  bits<3> ms2;
  bits<5> rs1;

  let Inst{31-28} = 0b0000;
  let Inst{27-25} = 0b110;
  let Inst{24}    = sz{1};
  let Inst{23-21} = ms2;
  let Inst{20}    = sz{0};
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b000;
  let Inst{11-7}  = rd;
  let Inst{6-0}   = 0b0101011;
}

let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // b (00): bit 24 = 0, bit 20 = 0 -> {0, rs1}
  def TH_MMOVB_X_M : RVInstXTAMEMSMOVE<0b00, "th.mmovb.x.m">;

  // h (01): bit 24 = 0, bit 20 = 1 -> {1, rs1}
  def TH_MMOVH_X_M : RVInstXTAMEMSMOVE<0b01, "th.mmovh.x.m">;

  // w (10): bit 24 = 1, bit 20 = 0 -> {0, rs1}
  def TH_MMOVW_X_M : RVInstXTAMEMSMOVE<0b10, "th.mmovw.x.m">;

  // d (11): bit 24 = 1, bit 20 = 1 -> {1, rs1}
  def TH_MMOVD_X_M : RVInstXTAMEMSMOVE<0b11, "th.mmovd.x.m">;
}

// Data Broadcast Instructions
class RVInstXTAMEDB<bits<4> func4_val, bits<3> uop_val, bits<2> sz, string opcodestr>
    : RVInstXTAME32<(outs THeadAMEMatrixReg:$md), (ins THeadAMEMatrixReg:$ms1, uimm3:$uimm3),
                    opcodestr, "$md, $ms1[$uimm3]"> {
  bits<3> uimm3;

  let func4  = func4_val;
  let uop    = uop_val;
  let size   = 0b0;
  let ms2    = 0b000;
  let func3  = 0b000;
  let size_w = sz;
  let type   = uimm3;
  let opcode = 0b0101011;
}

let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // 1. th.mmov.mv.i , size_w = 00
  // func4 = 0000, uop = 010
  def TH_MMOV_MV_I : RVInstXTAMEDB<0b0000, 0b010, 0b00, "th.mmov.mv.i">;
}

class TH_MCMOV<bits<2> sz, string opcodestr>
      : RVInstXTAMEDB<0b0101, 0b110, sz, opcodestr>;

let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  def TH_MCMOVB_MV_I : TH_MCMOV<0b00, "th.mcmovb.mv.i">;
  def TH_MCMOVH_MV_I : TH_MCMOV<0b01, "th.mcmovh.mv.i">;
  def TH_MCMOVW_MV_I : TH_MCMOV<0b10, "th.mcmovw.mv.i">;
  def TH_MCMOVD_MV_I : TH_MCMOV<0b11, "th.mcmovd.mv.i">;
}

// Matrix Pack Instructions
class TH_MPACK<bits<3> type_val, string opcodestr>
    : RVInstXTAME32<(outs THeadAMEMatrixReg:$md), (ins THeadAMEMatrixReg:$ms2, THeadAMEMatrixReg:$ms1),
                    opcodestr, "$md, $ms2, $ms1"> {
  let func4  = 0b0011;
  let uop    = 0b110;
  let size   = 0b0;
  let func3  = 0b000;
  let size_w = 0b00;
  let type   = type_val;
  let opcode = 0b0101011;
}

let Predicates = [HasVendorXTHeadAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // th.mpack.mm: pack the low part of ms2 and low part of ms1 into md
  def TH_MPACK_MM   : TH_MPACK<0b000, "th.mpack.mm">;
  // th.mpackhl.mm: pack the high part of ms2 and low part of ms1 into md
  def TH_MPACKHL_MM : TH_MPACK<0b010, "th.mpackhl.mm">;
  // th.mpackhh.mm: pack the high part of ms2 and high part of ms1 into md
  def TH_MPACKHH_MM : TH_MPACK<0b011, "th.mpackhh.mm">;
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

// Configured Register instructions (no matrix register)
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 1, mayLoad = 0, mayStore = 0,
    isCodeGenOnly = 1 in {
  def TH_MCFGM_PSEUDO : Pseudo<(outs), (ins GPR:$rs1), []> {
    let AsmString = "th.mcfgm\t$rs1";
  }
  def TH_MCFGN_PSEUDO : Pseudo<(outs), (ins GPR:$rs1), []> {
    let AsmString = "th.mcfgn\t$rs1";
  }
  def TH_MCFGK_PSEUDO : Pseudo<(outs), (ins GPR:$rs1), []> {
    let AsmString = "th.mcfgk\t$rs1";
  }
  def TH_MCFG_PSEUDO : Pseudo<(outs), (ins GPR:$rs1), []> {
    let AsmString = "th.mcfg\t$rs1";
  }
}

// Zero instruction (single matrix register)
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 1, mayLoad = 0, mayStore = 0,
    isCodeGenOnly = 1 in {
  def TH_MZERO_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md), []> {
    let AsmString = "th.mzero\tm$md";
  }
  def TH_MZERO2R_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md), []> {
    let AsmString = "th.mzero2r\tm$md";
  }
  def TH_MZERO4R_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md), []> {
    let AsmString = "th.mzero4r\tm$md";
  }
  def TH_MZERO8R_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md), []> {
    let AsmString = "th.mzero8r\tm$md";
  }
}

// MISC Instructions
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 1, mayLoad = 0, mayStore = 0,
    isCodeGenOnly = 1 in {
  // 1. Data Move Instructions between Matrix Registers
  def TH_MMOV_MM_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mmov.mm\tm$md, m$ms1";
  }
  // 2. Data Move Instructions between Integer and Matrix (Duplicate)
  def TH_MDUPB_M_X_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2), []> {
    let AsmString = "th.mdupb.m.x\tm$md, $rs2";
  }
  def TH_MDUPH_M_X_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2), []> {
    let AsmString = "th.mduph.m.x\tm$md, $rs2";
  }
  def TH_MDUPW_M_X_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2), []> {
    let AsmString = "th.mdupw.m.x\tm$md, $rs2";
  }
  def TH_MDUPD_M_X_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2), []> {
    let AsmString = "th.mdupd.m.x\tm$md, $rs2";
  }
  // 3. Data Move Instructions between Integer and Matrix (Scalar to Matrix)
  def TH_MMOVB_M_X_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mmovb.m.x\tm$md, $rs2, $rs1";
  }
  def TH_MMOVH_M_X_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mmovh.m.x\tm$md, $rs2, $rs1";
  }
  def TH_MMOVW_M_X_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mmovw.m.x\tm$md, $rs2, $rs1";
  }
  def TH_MMOVD_M_X_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mmovd.m.x\tm$md, $rs2, $rs1";
  }
  // 4. Data Move Instructions between Integer and Matrix (Matrix to Scalar)
  def TH_MMOVB_X_M_PSEUDO : Pseudo<(outs GPR:$rd), (ins THeadAMEMatrixIndex:$ms2, GPR:$rs1), []> {
    let AsmString = "th.mmovb.x.m\t$rd, m$ms2, $rs1";
  }
  def TH_MMOVH_X_M_PSEUDO : Pseudo<(outs GPR:$rd), (ins THeadAMEMatrixIndex:$ms2, GPR:$rs1), []> {
    let AsmString = "th.mmovh.x.m\t$rd, m$ms2, $rs1";
  }
  def TH_MMOVW_X_M_PSEUDO : Pseudo<(outs GPR:$rd), (ins THeadAMEMatrixIndex:$ms2, GPR:$rs1), []> {
    let AsmString = "th.mmovw.x.m\t$rd, m$ms2, $rs1";
  }
  def TH_MMOVD_X_M_PSEUDO : Pseudo<(outs GPR:$rd), (ins THeadAMEMatrixIndex:$ms2, GPR:$rs1), []> {
    let AsmString = "th.mmovd.x.m\t$rd, m$ms2, $rs1";
  }
  // 5. Data Broadcast Instructions
  def TH_MMOV_MV_I_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms1, uimm3:$uimm3), []> {
    let AsmString = "th.mmov.mv.i\tm$md, m$ms1[$uimm3]";
  }
  def TH_MCMOVB_MV_I_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms1, uimm3:$uimm3), []> {
    let AsmString = "th.mcmovb.mv.i\tm$md, m$ms1[$uimm3]";
  }
  def TH_MCMOVH_MV_I_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms1, uimm3:$uimm3), []> {
    let AsmString = "th.mcmovh.mv.i\tm$md, m$ms1[$uimm3]";
  }
  def TH_MCMOVW_MV_I_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms1, uimm3:$uimm3), []> {
    let AsmString = "th.mcmovw.mv.i\tm$md, m$ms1[$uimm3]";
  }
  def TH_MCMOVD_MV_I_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms1, uimm3:$uimm3), []> {
    let AsmString = "th.mcmovd.mv.i\tm$md, m$ms1[$uimm3]";
  }
  // 6. Matrix Pack Instructions
  def TH_MPACK_MM_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mpack.mm\tm$md, m$ms2, m$ms1";
  }
  def TH_MPACKHL_MM_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mpackhl.mm\tm$md, m$ms2, m$ms1";
  }
  def TH_MPACKHH_MM_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mpackhh.mm\tm$md, m$ms2, m$ms1";
  }
}

// Load instructions (normal and transposed)
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 1, mayLoad = 1, mayStore = 0,
    isCodeGenOnly = 1 in {
  def TH_MLDE8_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mlde8\tm$md, $rs2, ($rs1)";
  }
  def TH_MLDE16_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mlde16\tm$md, $rs2, ($rs1)";
  }
  def TH_MLDE32_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mlde32\tm$md, $rs2, ($rs1)";
  }
  def TH_MLDE64_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mlde64\tm$md, $rs2, ($rs1)";
  }
  def TH_MLDTE8_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mldte8\tm$md, $rs2, ($rs1)";
  }
  def TH_MLDTE16_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mldte16\tm$md, $rs2, ($rs1)";
  }
  def TH_MLDTE32_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mldte32\tm$md, $rs2, ($rs1)";
  }
  def TH_MLDTE64_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mldte64\tm$md, $rs2, ($rs1)";
  }
  def TH_MSLDE8_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mslde8\tm$md, $rs2, ($rs1)";
  }
  def TH_MSLDE16_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mslde16\tm$md, $rs2, ($rs1)";
  }
  def TH_MSLDE32_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mslde32\tm$md, $rs2, ($rs1)";
  }
  def TH_MSLDE64_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mslde64\tm$md, $rs2, ($rs1)";
  }
  def TH_MSLDTE8_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.msldte8\tm$md, $rs2, ($rs1)";
  }
  def TH_MSLDTE16_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.msldte16\tm$md, $rs2, ($rs1)";
  }
  def TH_MSLDTE32_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.msldte32\tm$md, $rs2, ($rs1)";
  }
  def TH_MSLDTE64_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$md, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.msldte64\tm$md, $rs2, ($rs1)";
  }
}

// Prefetch instructions (normal and transposed)
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 1, mayLoad = 1, mayStore = 0,
    isCodeGenOnly = 1 in {
  def TH_MPLDE8_PSEUDO : Pseudo<(outs), (ins GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mplde8\t$rs2, ($rs1)";
  }
  def TH_MPLDE16_PSEUDO : Pseudo<(outs), (ins GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mplde16\t$rs2, ($rs1)";
  }
  def TH_MPLDE32_PSEUDO : Pseudo<(outs), (ins GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mplde32\t$rs2, ($rs1)";
  }
  def TH_MPLDE64_PSEUDO : Pseudo<(outs), (ins GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mplde64\t$rs2, ($rs1)";
  }
  def TH_MPLDTE8_PSEUDO : Pseudo<(outs), (ins GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mpldte8\t$rs2, ($rs1)";
  }
  def TH_MPLDTE16_PSEUDO : Pseudo<(outs), (ins GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mpldte16\t$rs2, ($rs1)";
  }
  def TH_MPLDTE32_PSEUDO : Pseudo<(outs), (ins GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mpldte32\t$rs2, ($rs1)";
  }
  def TH_MPLDTE64_PSEUDO : Pseudo<(outs), (ins GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mpldte64\t$rs2, ($rs1)";
  }
}

// Store instruction
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 1, mayLoad = 0, mayStore = 1,
    isCodeGenOnly = 1 in {
  def TH_MSTE8_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mste8\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSTE16_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mste16\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSTE32_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mste32\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSTE64_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mste64\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSTTE8_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mstte8\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSTTE16_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mstte16\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSTTE32_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mstte32\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSTTE64_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.mstte64\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSSTE8_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.msste8\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSSTE16_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.msste16\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSSTE32_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.msste32\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSSTE64_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.msste64\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSSTTE8_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.msstte8\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSSTTE16_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.msstte16\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSSTTE32_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.msstte32\tm$ms3, $rs2, ($rs1)";
  }
  def TH_MSSTTE64_PSEUDO : Pseudo<(outs), (ins THeadAMEMatrixIndex:$ms3, GPR:$rs2, GPR:$rs1), []> {
    let AsmString = "th.msstte64\tm$ms3, $rs2, ($rs1)";
  }
}

// Matrix multiply instruction
let Predicates = [HasVendorXTHeadAME], hasSideEffects = 1,
    isCodeGenOnly = 1 in {
  def TH_MMACC_W_B_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mmacc.w.b\tm$md, m$ms2, m$ms1";
  }
  def TH_MMACCU_W_B_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mmaccu.w.b\tm$md, m$ms2, m$ms1";
  }
  def TH_MMACCUS_W_B_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mmaccus.w.b\tm$md, m$ms2, m$ms1";
  }
  def TH_MMACCSU_W_B_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mmaccsu.w.b\tm$md, m$ms2, m$ms1";
  }
  def TH_MFMACC_H_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mfmacc.h\tm$md, m$ms2, m$ms1";
  }
  def TH_MFMACC_BF16_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mfmacc.bf16\tm$md, m$ms2, m$ms1";
  }
  def TH_MFMACC_S_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mfmacc.s\tm$md, m$ms2, m$ms1";
  }
  def TH_MFMACC_D_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mfmacc.d\tm$md, m$ms2, m$ms1";
  }
  def TH_MFMACC_H_E4M3_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mfmacc.h.e4m3\tm$md, m$ms2, m$ms1";
  }
  def TH_MFMACC_H_E5M2_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mfmacc.h.e5m2\tm$md, m$ms2, m$ms1";
  }
  def TH_MFMACC_BF16_E4M3_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mfmacc.bf16.e4m3\tm$md, m$ms2, m$ms1";
  }
  def TH_MFMACC_BF16_E5M2_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mfmacc.bf16.e5m2\tm$md, m$ms2, m$ms1";
  }
  def TH_MFMACC_S_H_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mfmacc.s.h\tm$md, m$ms2, m$ms1";
  }
  def TH_MFMACC_S_BF16_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mfmacc.s.bf16\tm$md, m$ms2, m$ms1";
  }
  def TH_MFMACC_D_S_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mfmacc.d.s\tm$md, m$ms2, m$ms1";
  }
  def TH_MFMACC_S_E4M3_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mfmacc.s.e4m3\tm$md, m$ms2, m$ms1";
  }
  def TH_MFMACC_S_E5M2_PSEUDO : Pseudo<(outs),
      (ins THeadAMEMatrixIndex:$md, THeadAMEMatrixIndex:$ms2, THeadAMEMatrixIndex:$ms1), []> {
    let AsmString = "th.mfmacc.s.e5m2\tm$md, m$ms2, m$ms1";
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

  // Configured Register instructions
  def : Pat<(int_riscv_th_mcfgm i64:$rs1),
          (TH_MCFGM_PSEUDO GPR:$rs1)>;

  def : Pat<(int_riscv_th_mcfgn i64:$rs1),
          (TH_MCFGN_PSEUDO GPR:$rs1)>;

  def : Pat<(int_riscv_th_mcfgk i64:$rs1),
          (TH_MCFGK_PSEUDO GPR:$rs1)>;

  def : Pat<(int_riscv_th_mcfg i64:$rs1),
          (TH_MCFG_PSEUDO GPR:$rs1)>;

  // Zero instruction
  def : Pat<(int_riscv_th_mzero timm:$md),
            (TH_MZERO_PSEUDO timm:$md)>;
  def : Pat<(int_riscv_th_mzero2r timm:$md),
            (TH_MZERO2R_PSEUDO timm:$md)>;
  def : Pat<(int_riscv_th_mzero4r timm:$md),
            (TH_MZERO4R_PSEUDO timm:$md)>;
  def : Pat<(int_riscv_th_mzero8r timm:$md),
            (TH_MZERO8R_PSEUDO timm:$md)>;

  // MISC instructions
  // 1. Data Move Instructions between Matrix Registers
  def : Pat<(int_riscv_th_mmov_mm timm:$md, timm:$ms1),
          (TH_MMOV_MM_PSEUDO timm:$md, timm:$ms1)>;

  // 2. Data Move Instructions between Integer and Matrix (Duplicate)
  def : Pat<(int_riscv_th_mdupb_m_x timm:$md, i64:$rs2),
          (TH_MDUPB_M_X_PSEUDO timm:$md, GPR:$rs2)>;
  def : Pat<(int_riscv_th_mduph_m_x timm:$md, i64:$rs2),
          (TH_MDUPH_M_X_PSEUDO timm:$md, GPR:$rs2)>;
  def : Pat<(int_riscv_th_mdupw_m_x timm:$md, i64:$rs2),
          (TH_MDUPW_M_X_PSEUDO timm:$md, GPR:$rs2)>;
  def : Pat<(int_riscv_th_mdupd_m_x timm:$md, i64:$rs2),
          (TH_MDUPD_M_X_PSEUDO timm:$md, GPR:$rs2)>;

  // 3. Data Move Instructions between Integer and Matrix (Scalar to Matrix)
  def : Pat<(int_riscv_th_mmovb_m_x timm:$md, i64:$rs2, i64:$rs1),
          (TH_MMOVB_M_X_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mmovh_m_x timm:$md, i64:$rs2, i64:$rs1),
          (TH_MMOVH_M_X_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mmovw_m_x timm:$md, i64:$rs2, i64:$rs1),
          (TH_MMOVW_M_X_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mmovd_m_x timm:$md, i64:$rs2, i64:$rs1),
          (TH_MMOVD_M_X_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;

  // 4. Data Move Instructions between Integer and Matrix (Matrix to Scalar)
  def : Pat<(int_riscv_th_mmovb_x_m timm:$ms2, i64:$rs1),
          (TH_MMOVB_X_M_PSEUDO timm:$ms2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mmovh_x_m timm:$ms2, i64:$rs1),
          (TH_MMOVH_X_M_PSEUDO timm:$ms2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mmovw_x_m timm:$ms2, i64:$rs1),
          (TH_MMOVW_X_M_PSEUDO timm:$ms2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mmovd_x_m timm:$ms2, i64:$rs1),
          (TH_MMOVD_X_M_PSEUDO timm:$ms2, GPR:$rs1)>;

  // 5. Data Broadcast Instructions
  def : Pat<(int_riscv_th_mmov_mv_i timm:$md, timm:$ms1, imm:$uimm3),
          (TH_MMOV_MV_I_PSEUDO timm:$md, timm:$ms1, imm:$uimm3)>;
  def : Pat<(int_riscv_th_mcmovb_mv_i timm:$md, timm:$ms1, imm:$uimm3),
          (TH_MCMOVB_MV_I_PSEUDO timm:$md, timm:$ms1, imm:$uimm3)>;
  def : Pat<(int_riscv_th_mcmovh_mv_i timm:$md, timm:$ms1, imm:$uimm3),
          (TH_MCMOVH_MV_I_PSEUDO timm:$md, timm:$ms1, imm:$uimm3)>;
  def : Pat<(int_riscv_th_mcmovw_mv_i timm:$md, timm:$ms1, imm:$uimm3),
          (TH_MCMOVW_MV_I_PSEUDO timm:$md, timm:$ms1, imm:$uimm3)>;
  def : Pat<(int_riscv_th_mcmovd_mv_i timm:$md, timm:$ms1, imm:$uimm3),
          (TH_MCMOVD_MV_I_PSEUDO timm:$md, timm:$ms1, imm:$uimm3)>;

  // 6. Matrix Pack Instructions
  def : Pat<(int_riscv_th_mpack_mm timm:$md, timm:$ms2, timm:$ms1),
          (TH_MPACK_MM_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mpackhl_mm timm:$md, timm:$ms2, timm:$ms1),
          (TH_MPACKHL_MM_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mpackhh_mm timm:$md, timm:$ms2, timm:$ms1),
          (TH_MPACKHH_MM_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;

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
  def : Pat<(int_riscv_th_mslde8 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MSLDE8_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mslde16 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MSLDE16_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mslde32 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MSLDE32_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mslde64 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MSLDE64_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_msldte8 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MSLDTE8_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_msldte16 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MSLDTE16_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_msldte32 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MSLDTE32_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_msldte64 timm:$md, i64:$rs2, iPTR:$rs1),
            (TH_MSLDTE64_PSEUDO timm:$md, GPR:$rs2, GPR:$rs1)>;

  // Prefetch instructions
  def : Pat<(int_riscv_th_mplde8 i64:$rs2, iPTR:$rs1),
            (TH_MPLDE8_PSEUDO GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mplde16 i64:$rs2, iPTR:$rs1),
            (TH_MPLDE16_PSEUDO GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mplde32 i64:$rs2, iPTR:$rs1),
            (TH_MPLDE32_PSEUDO GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mplde64 i64:$rs2, iPTR:$rs1),
            (TH_MPLDE64_PSEUDO GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mpldte8 i64:$rs2, iPTR:$rs1),
            (TH_MPLDTE8_PSEUDO GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mpldte16 i64:$rs2, iPTR:$rs1),
            (TH_MPLDTE16_PSEUDO GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mpldte32 i64:$rs2, iPTR:$rs1),
            (TH_MPLDTE32_PSEUDO GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mpldte64 i64:$rs2, iPTR:$rs1),
            (TH_MPLDTE64_PSEUDO GPR:$rs2, GPR:$rs1)>;

  // Store instruction
  def : Pat<(int_riscv_th_mste8 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSTE8_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mste16 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSTE16_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mste32 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSTE32_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mste64 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSTE64_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mstte8 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSTTE8_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mstte16 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSTTE16_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mstte32 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSTTE32_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_mstte64 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSTTE64_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_msste8 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSSTE8_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_msste16 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSSTE16_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_msste32 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSSTE32_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_msste64 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSSTE64_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_msstte8 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSSTTE8_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_msstte16 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSSTTE16_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_msstte32 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSSTTE32_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;
  def : Pat<(int_riscv_th_msstte64 timm:$ms3, i64:$rs2, iPTR:$rs1),
            (TH_MSSTTE64_PSEUDO timm:$ms3, GPR:$rs2, GPR:$rs1)>;

  // Matrix multiply instruction
  def : Pat<(int_riscv_th_mmacc_w_b timm:$md, timm:$ms2, timm:$ms1),
            (TH_MMACC_W_B_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mmaccu_w_b timm:$md, timm:$ms2, timm:$ms1),
            (TH_MMACCU_W_B_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mmaccus_w_b timm:$md, timm:$ms2, timm:$ms1),
            (TH_MMACCUS_W_B_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mmaccsu_w_b timm:$md, timm:$ms2, timm:$ms1),
            (TH_MMACCSU_W_B_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mfmacc_h timm:$md, timm:$ms2, timm:$ms1),
            (TH_MFMACC_H_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mfmacc_bf16 timm:$md, timm:$ms2, timm:$ms1),
            (TH_MFMACC_BF16_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mfmacc_s timm:$md, timm:$ms2, timm:$ms1),
            (TH_MFMACC_S_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mfmacc_d timm:$md, timm:$ms2, timm:$ms1),
            (TH_MFMACC_D_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mfmacc_h_e4m3 timm:$md, timm:$ms2, timm:$ms1),
            (TH_MFMACC_H_E4M3_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mfmacc_h_e5m2 timm:$md, timm:$ms2, timm:$ms1),
            (TH_MFMACC_H_E5M2_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mfmacc_bf16_e4m3 timm:$md, timm:$ms2, timm:$ms1),
            (TH_MFMACC_BF16_E4M3_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mfmacc_bf16_e5m2 timm:$md, timm:$ms2, timm:$ms1),
            (TH_MFMACC_BF16_E5M2_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mfmacc_s_h timm:$md, timm:$ms2, timm:$ms1),
            (TH_MFMACC_S_H_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mfmacc_s_bf16 timm:$md, timm:$ms2, timm:$ms1),
            (TH_MFMACC_S_BF16_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mfmacc_d_s timm:$md, timm:$ms2, timm:$ms1),
            (TH_MFMACC_D_S_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mfmacc_s_e4m3 timm:$md, timm:$ms2, timm:$ms1),
            (TH_MFMACC_S_E4M3_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
  def : Pat<(int_riscv_th_mfmacc_s_e5m2 timm:$md, timm:$ms2, timm:$ms1),
            (TH_MFMACC_S_E5M2_PSEUDO timm:$md, timm:$ms2, timm:$ms1)>;
}
