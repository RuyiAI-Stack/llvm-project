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

let Predicates = [HasVendorXTHeadAME], hasSideEffects = 1, mayLoad = 0, mayStore = 0 in {
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

let Predicates = [HasVendorXTHeadAME], hasSideEffects = 1, mayLoad = 0, mayStore = 0 in {
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
  def TH_MZERO   : RVInstXTAMEMISC<(outs MatrixRegOp:$md), (ins),
                                 "th.mzero", "$md",
                                 0b1010, 0b000> {
    let uimm3 = 0b000;
  }

  // Zero 2 matrix registers (uimm3 = 001)
  def TH_MZERO2R : RVInstXTAMEMISC<(outs MatrixRegOp:$md), (ins),
                                 "th.mzero2r", "$md",
                                 0b1010, 0b000> {
    let uimm3 = 0b001;
  }

  // Zero 4 matrix registers (uimm3 = 011)
  def TH_MZERO4R : RVInstXTAMEMISC<(outs MatrixRegOp:$md), (ins),
                                 "th.mzero4r", "$md",
                                 0b1010, 0b000> {
    let uimm3 = 0b011;
  }

  // Zero 8 matrix registers (uimm3 = 111)
  def TH_MZERO8R : RVInstXTAMEMISC<(outs MatrixRegOp:$md), (ins),
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
def TH_MMOV_MM : RVInstXTAMEMMOV<(outs MatrixRegOp:$md), (ins MatrixRegOp:$ms1),
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
    : RVInstXTAMESMMOVE<0b0001, (outs MatrixRegOp:$md), (ins GPR:$rs2),
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
    : RVInstXTAMESMMOVE<0b0010, (outs MatrixRegOp:$md), (ins GPR:$rs2, GPR:$rs1),
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
    : RVInst<(outs GPR:$rd), (ins MatrixRegOp:$ms2, GPR:$rs1),
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
    : RVInstXTAME32<(outs MatrixRegOp:$md), (ins MatrixRegOp:$ms1, uimm3:$uimm3),
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
    : RVInstXTAME32<(outs MatrixRegOp:$md),
                  (ins MatrixRegOp:$ms2, MatrixRegOp:$ms1),
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
// Direct SelectionDAG patterns for XTHead AME real instructions.
//
// Matrix operands are SSA values in MatrixReg.  The concrete MVT lists below
// match the MatrixReg types registered by RISCVISelLowering.cpp.
//===----------------------------------------------------------------------===//

defvar XTAME_I8 = [nxv64i8, nxv256i8, nxv1024i8];
defvar XTAME_I16 = [nxv32i16, nxv128i16, nxv512i16];
defvar XTAME_I32 = [nxv16i32, nxv64i32, nxv256i32];
defvar XTAME_I64 = [nxv8i64, nxv32i64, nxv128i64];
defvar XTAME_F16 = [nxv32f16, nxv128f16, nxv512f16];
defvar XTAME_F32 = [nxv16f32, nxv64f32, nxv256f32];
defvar XTAME_F64 = [nxv8f64, nxv32f64, nxv128f64];
defvar XTAME_ALL = !listconcat(XTAME_I8, XTAME_I16, XTAME_I32, XTAME_I64,
                               XTAME_F16, XTAME_F32, XTAME_F64);

def xtame_tuimm32 : TImmLeaf<XLenVT, [{return isUInt<32>(Imm);}]>;

class XTAMEPatConfigImm<SDPatternOperator OpNode, RVInst Inst>
    : Pat<(OpNode xtame_tuimm32:$imm),
          (Inst xtame_tuimm32:$imm)>;

class XTAMEPatZero<SDPatternOperator OpNode, Instruction Inst,
                   ValueType MatrixType>
    : Pat<(MatrixType (OpNode)),
          (MatrixType (Inst))>;

class XTAMEPatLoad<SDPatternOperator OpNode, Instruction Inst,
                   ValueType MatrixType>
    : Pat<(MatrixType (OpNode (XLenVT GPR:$stride), iPTR:$base)),
          (MatrixType (Inst GPR:$stride, GPR:$base))>;

class XTAMEPatStore<SDPatternOperator OpNode, Instruction Inst,
                    ValueType MatrixType>
    : Pat<(OpNode (MatrixType MatrixReg:$matrix), (XLenVT GPR:$stride),
                  iPTR:$base),
          (Inst (MatrixType MatrixReg:$matrix), GPR:$base, GPR:$stride)>;

class XTAMEPatUnaryMatrix<SDPatternOperator OpNode, Instruction Inst,
                          ValueType MatrixType>
    : Pat<(MatrixType (OpNode (MatrixType MatrixReg:$src))),
          (MatrixType (Inst (MatrixType MatrixReg:$src)))>;

class XTAMEPatMatrixScalar<SDPatternOperator OpNode, Instruction Inst,
                           ValueType MatrixType>
    : Pat<(MatrixType (OpNode (XLenVT GPR:$value))),
          (MatrixType (Inst GPR:$value))>;

class XTAMEPatMatrixScalarIndexed<SDPatternOperator OpNode, Instruction Inst,
                                  ValueType MatrixType>
    : Pat<(MatrixType (OpNode (XLenVT GPR:$value),
                              (XLenVT GPR:$index))),
          (MatrixType (Inst GPR:$value, GPR:$index))>;

class XTAMEPatMatrixToScalar<SDPatternOperator OpNode, Instruction Inst,
                             ValueType MatrixType>
    : Pat<(XLenVT (OpNode (MatrixType MatrixReg:$matrix),
                         (XLenVT GPR:$index))),
          (XLenVT (Inst (MatrixType MatrixReg:$matrix), GPR:$index))>;

class XTAMEPatBroadcast<SDPatternOperator OpNode, Instruction Inst,
                        ValueType MatrixType>
    : Pat<(MatrixType (OpNode (MatrixType MatrixReg:$src), uimm3:$index)),
          (MatrixType (Inst (MatrixType MatrixReg:$src), uimm3:$index))>;

class XTAMEPatBinaryMatrix<SDPatternOperator OpNode, Instruction Inst,
                           ValueType MatrixType>
    : Pat<(MatrixType (OpNode (MatrixType MatrixReg:$lhs),
                              (MatrixType MatrixReg:$rhs))),
          (MatrixType (Inst (MatrixType MatrixReg:$lhs),
                            (MatrixType MatrixReg:$rhs)))>;

class XTAMEPatMMA<SDPatternOperator OpNode, Instruction Inst,
                  ValueType MatrixType>
    : Pat<(MatrixType
             (OpNode (MatrixType MatrixReg:$acc),
                     (MatrixType MatrixReg:$lhs),
                     (MatrixType MatrixReg:$rhs))),
          (MatrixType
             (Inst (MatrixType MatrixReg:$acc),
                   (MatrixType MatrixReg:$lhs),
                   (MatrixType MatrixReg:$rhs)))>;

class XTAMEPatWidenMMA<SDPatternOperator OpNode, Instruction Inst,
                       ValueType DstType, ValueType SrcType>
    : Pat<(DstType
             (OpNode (DstType MatrixReg:$acc),
                     (SrcType MatrixReg:$lhs),
                     (SrcType MatrixReg:$rhs))),
          (DstType
             (Inst (DstType MatrixReg:$acc),
                   (SrcType MatrixReg:$lhs),
                   (SrcType MatrixReg:$rhs)))>;

let Predicates = [HasVendorXTHeadAME] in {
  // Configuration instructions have void intrinsic results.
  def : Pat<(int_riscv_th_mcfg (XLenVT GPR:$rs1)),
            (TH_MCFG GPR:$rs1)>;
  def : Pat<(int_riscv_th_mcfgm (XLenVT GPR:$rs1)),
            (TH_MCFGM GPR:$rs1)>;
  def : Pat<(int_riscv_th_mcfgn (XLenVT GPR:$rs1)),
            (TH_MCFGN GPR:$rs1)>;
  def : Pat<(int_riscv_th_mcfgk (XLenVT GPR:$rs1)),
            (TH_MCFGK GPR:$rs1)>;

  def : XTAMEPatConfigImm<int_riscv_th_mcfgmi, TH_MCFGMI>;
  def : XTAMEPatConfigImm<int_riscv_th_mcfgni, TH_MCFGNI>;
  def : XTAMEPatConfigImm<int_riscv_th_mcfgki, TH_MCFGKI>;

  // mzero produces a new MatrixReg value.
  foreach T = XTAME_ALL in {
    def : XTAMEPatZero<int_riscv_th_mzero, TH_MZERO, T>;
    def : XTAMEPatZero<int_riscv_th_mzero2r, TH_MZERO2R, T>;
    def : XTAMEPatZero<int_riscv_th_mzero4r, TH_MZERO4R, T>;
    def : XTAMEPatZero<int_riscv_th_mzero8r, TH_MZERO8R, T>;
  }

  // Matrix and scalar moves.
  foreach T = XTAME_ALL in {
    def : XTAMEPatUnaryMatrix<int_riscv_th_mmov_mm, TH_MMOV_MM, T>;

    def : XTAMEPatBroadcast<int_riscv_th_mmov_mv_i,
                            TH_MMOV_MV_I, T>;
    def : XTAMEPatBinaryMatrix<int_riscv_th_mpack_mm, TH_MPACK_MM, T>;
    def : XTAMEPatBinaryMatrix<int_riscv_th_mpackhl_mm, TH_MPACKHL_MM, T>;
    def : XTAMEPatBinaryMatrix<int_riscv_th_mpackhh_mm, TH_MPACKHH_MM, T>;

    def : XTAMEPatMatrixScalar<int_riscv_th_mdupb_m_x, TH_MDUPB_M_X, T>;
    def : XTAMEPatMatrixScalar<int_riscv_th_mduph_m_x, TH_MDUPH_M_X, T>;
    def : XTAMEPatMatrixScalar<int_riscv_th_mdupw_m_x, TH_MDUPW_M_X, T>;
    def : XTAMEPatMatrixScalar<int_riscv_th_mdupd_m_x, TH_MDUPD_M_X, T>;

    def : XTAMEPatMatrixScalarIndexed<int_riscv_th_mmovb_m_x,
                                      TH_MMOVB_M_X, T>;
    def : XTAMEPatMatrixScalarIndexed<int_riscv_th_mmovh_m_x,
                                      TH_MMOVH_M_X, T>;
    def : XTAMEPatMatrixScalarIndexed<int_riscv_th_mmovw_m_x,
                                      TH_MMOVW_M_X, T>;
    def : XTAMEPatMatrixScalarIndexed<int_riscv_th_mmovd_m_x,
                                      TH_MMOVD_M_X, T>;

    def : XTAMEPatMatrixToScalar<int_riscv_th_mmovb_x_m,
                                 TH_MMOVB_X_M, T>;
    def : XTAMEPatMatrixToScalar<int_riscv_th_mmovh_x_m,
                                 TH_MMOVH_X_M, T>;
    def : XTAMEPatMatrixToScalar<int_riscv_th_mmovw_x_m,
                                 TH_MMOVW_X_M, T>;
    def : XTAMEPatMatrixToScalar<int_riscv_th_mmovd_x_m,
                                 TH_MMOVD_X_M, T>;
  }

  foreach T = XTAME_ALL in {
    def : XTAMEPatBroadcast<int_riscv_th_mcmovb_mv_i,
                            TH_MCMOVB_MV_I, T>;
    def : XTAMEPatBroadcast<int_riscv_th_mcmovh_mv_i,
                            TH_MCMOVH_MV_I, T>;
    def : XTAMEPatBroadcast<int_riscv_th_mcmovw_mv_i,
                            TH_MCMOVW_MV_I, T>;
    def : XTAMEPatBroadcast<int_riscv_th_mcmovd_mv_i,
                            TH_MCMOVD_MV_I, T>;
  }

  // Loads use intrinsic operands (stride, base), while the instruction uses
  // (rs2=stride, rs1=base).
  foreach T = XTAME_I8 in
    foreach Op = ["mlde", "mldte", "mslde", "msldte"] in
      def : XTAMEPatLoad<
        !cast<SDPatternOperator>("int_riscv_th_"#Op#"8"),
        !cast<Instruction>("TH_"#!toupper(Op)#"8"), T>;
  foreach T = XTAME_I16 in
    foreach Op = ["mlde", "mldte", "mslde", "msldte"] in
      def : XTAMEPatLoad<
        !cast<SDPatternOperator>("int_riscv_th_"#Op#"16"),
        !cast<Instruction>("TH_"#!toupper(Op)#"16"), T>;
  foreach T = XTAME_I32 in
    foreach Op = ["mlde", "mldte", "mslde", "msldte"] in
      def : XTAMEPatLoad<
        !cast<SDPatternOperator>("int_riscv_th_"#Op#"32"),
        !cast<Instruction>("TH_"#!toupper(Op)#"32"), T>;
  foreach T = XTAME_I64 in
    foreach Op = ["mlde", "mldte", "mslde", "msldte"] in
      def : XTAMEPatLoad<
        !cast<SDPatternOperator>("int_riscv_th_"#Op#"64"),
        !cast<Instruction>("TH_"#!toupper(Op)#"64"), T>;
  foreach T = XTAME_F16 in
    foreach Op = ["mlde", "mldte", "mslde", "msldte"] in
      def : XTAMEPatLoad<
        !cast<SDPatternOperator>("int_riscv_th_"#Op#"16"),
        !cast<Instruction>("TH_"#!toupper(Op)#"16"), T>;
  foreach T = XTAME_F32 in
    foreach Op = ["mlde", "mldte", "mslde", "msldte"] in
      def : XTAMEPatLoad<
        !cast<SDPatternOperator>("int_riscv_th_"#Op#"32"),
        !cast<Instruction>("TH_"#!toupper(Op)#"32"), T>;
  foreach T = XTAME_F64 in
    foreach Op = ["mlde", "mldte", "mslde", "msldte"] in
      def : XTAMEPatLoad<
        !cast<SDPatternOperator>("int_riscv_th_"#Op#"64"),
        !cast<Instruction>("TH_"#!toupper(Op)#"64"), T>;

  // Prefetch operands are also (stride, base), but no matrix result.
  def : Pat<(int_riscv_th_mplde8 (XLenVT GPR:$stride), iPTR:$base),
            (TH_MPLDE8 GPR:$stride, GPR:$base)>;
  def : Pat<(int_riscv_th_mplde16 (XLenVT GPR:$stride), iPTR:$base),
            (TH_MPLDE16 GPR:$stride, GPR:$base)>;
  def : Pat<(int_riscv_th_mplde32 (XLenVT GPR:$stride), iPTR:$base),
            (TH_MPLDE32 GPR:$stride, GPR:$base)>;
  def : Pat<(int_riscv_th_mplde64 (XLenVT GPR:$stride), iPTR:$base),
            (TH_MPLDE64 GPR:$stride, GPR:$base)>;
  def : Pat<(int_riscv_th_mpldte8 (XLenVT GPR:$stride), iPTR:$base),
            (TH_MPLDTE8 GPR:$stride, GPR:$base)>;
  def : Pat<(int_riscv_th_mpldte16 (XLenVT GPR:$stride), iPTR:$base),
            (TH_MPLDTE16 GPR:$stride, GPR:$base)>;
  def : Pat<(int_riscv_th_mpldte32 (XLenVT GPR:$stride), iPTR:$base),
            (TH_MPLDTE32 GPR:$stride, GPR:$base)>;
  def : Pat<(int_riscv_th_mpldte64 (XLenVT GPR:$stride), iPTR:$base),
            (TH_MPLDTE64 GPR:$stride, GPR:$base)>;

  // Stores use intrinsic operands (matrix, stride, base); the real
  // instruction operands are (matrix, base, stride).
  foreach T = XTAME_I8 in
    foreach Op = ["mste", "mstte", "msste", "msstte"] in
      def : XTAMEPatStore<
        !cast<SDPatternOperator>("int_riscv_th_"#Op#"8"),
        !cast<Instruction>("TH_"#!toupper(Op)#"8"), T>;
  foreach T = XTAME_I16 in
    foreach Op = ["mste", "mstte", "msste", "msstte"] in
      def : XTAMEPatStore<
        !cast<SDPatternOperator>("int_riscv_th_"#Op#"16"),
        !cast<Instruction>("TH_"#!toupper(Op)#"16"), T>;
  foreach T = XTAME_I32 in
    foreach Op = ["mste", "mstte", "msste", "msstte"] in
      def : XTAMEPatStore<
        !cast<SDPatternOperator>("int_riscv_th_"#Op#"32"),
        !cast<Instruction>("TH_"#!toupper(Op)#"32"), T>;
  foreach T = XTAME_I64 in
    foreach Op = ["mste", "mstte", "msste", "msstte"] in
      def : XTAMEPatStore<
        !cast<SDPatternOperator>("int_riscv_th_"#Op#"64"),
        !cast<Instruction>("TH_"#!toupper(Op)#"64"), T>;
  foreach T = XTAME_F16 in
    foreach Op = ["mste", "mstte", "msste", "msstte"] in
      def : XTAMEPatStore<
        !cast<SDPatternOperator>("int_riscv_th_"#Op#"16"),
        !cast<Instruction>("TH_"#!toupper(Op)#"16"), T>;
  foreach T = XTAME_F32 in
    foreach Op = ["mste", "mstte", "msste", "msstte"] in
      def : XTAMEPatStore<
        !cast<SDPatternOperator>("int_riscv_th_"#Op#"32"),
        !cast<Instruction>("TH_"#!toupper(Op)#"32"), T>;
  foreach T = XTAME_F64 in
    foreach Op = ["mste", "mstte", "msste", "msstte"] in
      def : XTAMEPatStore<
        !cast<SDPatternOperator>("int_riscv_th_"#Op#"64"),
        !cast<Instruction>("TH_"#!toupper(Op)#"64"), T>;

  // Integer widening MMA: i8 x i8 -> i32.
  foreach Op = ["mmacc_w_b", "mmaccu_w_b", "mmaccus_w_b", "mmaccsu_w_b"] in {
    def : XTAMEPatWidenMMA<
      !cast<SDPatternOperator>("int_riscv_th_"#Op),
      !cast<Instruction>("TH_"#!toupper(Op)),
      nxv16i32, nxv64i8>;
    def : XTAMEPatWidenMMA<
      !cast<SDPatternOperator>("int_riscv_th_"#Op),
      !cast<Instruction>("TH_"#!toupper(Op)),
      nxv64i32, nxv256i8>;
    def : XTAMEPatWidenMMA<
      !cast<SDPatternOperator>("int_riscv_th_"#Op),
      !cast<Instruction>("TH_"#!toupper(Op)),
      nxv256i32, nxv1024i8>;
  }

  // Non-widening floating MMA. BF16 has no MatrixReg MVT yet.
  def : XTAMEPatMMA<int_riscv_th_mfmacc_h_m, TH_MFMACC_H, nxv32f16>;
  def : XTAMEPatMMA<int_riscv_th_mfmacc_h_m, TH_MFMACC_H, nxv128f16>;
  def : XTAMEPatMMA<int_riscv_th_mfmacc_h_m, TH_MFMACC_H, nxv512f16>;
  def : XTAMEPatMMA<int_riscv_th_mfmacc_s_m, TH_MFMACC_S, nxv16f32>;
  def : XTAMEPatMMA<int_riscv_th_mfmacc_s_m, TH_MFMACC_S, nxv64f32>;
  def : XTAMEPatMMA<int_riscv_th_mfmacc_s_m, TH_MFMACC_S, nxv256f32>;
  def : XTAMEPatMMA<int_riscv_th_mfmacc_d_m, TH_MFMACC_D, nxv8f64>;
  def : XTAMEPatMMA<int_riscv_th_mfmacc_d_m, TH_MFMACC_D, nxv32f64>;
  def : XTAMEPatMMA<int_riscv_th_mfmacc_d_m, TH_MFMACC_D, nxv128f64>;

  // Widening floating MMA forms with supported source/destination MVTs.
  foreach W = [0, 1, 2] in {
    def : XTAMEPatWidenMMA<int_riscv_th_mfmacc_s_h_m, TH_MFMACC_S_H,
                           !if(!eq(W, 0), nxv16f32,
                               !if(!eq(W, 1), nxv64f32, nxv256f32)),
                           !if(!eq(W, 0), nxv32f16,
                               !if(!eq(W, 1), nxv128f16, nxv512f16))>;
    def : XTAMEPatWidenMMA<int_riscv_th_mfmacc_d_s_m, TH_MFMACC_D_S,
                           !if(!eq(W, 0), nxv8f64,
                               !if(!eq(W, 1), nxv32f64, nxv128f64)),
                           !if(!eq(W, 0), nxv16f32,
                               !if(!eq(W, 1), nxv64f32, nxv256f32))>;
  }
}

// The E4M3/E5M2 and BF16 widening forms are intentionally left unmatched
// until dedicated MatrixReg MVTs are added for those element formats.
