//===------ RISCVInstrInfoXBOSCAME.td --------------------------------------===//
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
// This is the instruction information file for the RISC-V BOSC AME extension.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// BOSC AME (RISC-V Matrix Extension) 32-bit Instructions
//===----------------------------------------------------------------------===//
// Reference: BOSC RISC-V Matrix Extension Specification
// 32-bit encoding format with prefix 1110111 at bits [6:0]
//
// Register Model:
//   - TileReg (tr0-tr7): Input matrices A and B, MLEN bits each
//   - AccReg (acc0-acc7): Accumulator matrix C, MLEN×AMUL bits each
//
// Data Flow:
//   Memory --[mlae/mlbe]--> TileReg --[mma]--> AccReg --[msce]--> Memory
//
// Matrix Multiplication Instruction Format (32-bit):
// | 31:26  | 25 | 24 | 23:20 | 19 | 18:15 | 14:12 | 11 | 10:7 | 6:0    |
// | funct6 | fp | sa | ms2   | sn | ms1   | eew   | ma | md   | OP-M32 |
//
// suffix = 1110111 (BOSC AME prefix)
//
// Widening Instructions (required for AMUL > 1):
//   - mqma.b.mm: int8 → int32 (quad-widen, AMUL ≥ 4, mmi8i32 MANDATORY)
//   - mwma.h.mm: int16 → int32 (double-widen, AMUL ≥ 2)
//   - mwma.w.mm: int32 → int64 (double-widen, AMUL ≥ 2)
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// BOSC AME 32-bit Instruction Format Base Class
//===----------------------------------------------------------------------===//

// Base class for BOSC AME 32-bit matrix multiplication instructions
// Matrix operands are constrained by the instruction subclasses to TileReg
// or AccReg. Register allocation chooses the physical trN/accN register.
class RVInstBOSCAME32<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<6> funct6;
  bit     fp;     // 0 for integer, 1 for floating-point (if supported in future)
  bit     sa;     // 0 for unsaturated, 1 for saturated
  bits<4> ms2;
  bit     sn;     // Whether the source operand is signed (for integers), 0 for floating-point
  bits<4> ms1;
  bits<3> eew;    // 0=int8, 1=int16, 2=int32, 3=int64, 7=int4
  bit     ma = 0b1;
  bits<4> md;
  bits<7> opcode = 0b1110111;

  let Inst{31-26} = funct6;
  let Inst{25}    = fp;
  let Inst{24}    = sa;
  let Inst{23-20} = ms2;
  let Inst{19}    = sn;
  let Inst{18-15} = ms1;
  let Inst{14-12} = eew;
  let Inst{11}    = ma;
  let Inst{10-7}  = md;
  let Inst{6-0} = 0b1110111;
}

//===----------------------------------------------------------------------===//
// BOSC AME 32-bit Matrix Multiplication Instructions
//===----------------------------------------------------------------------===//
// Format: mma.{h|w|dw}.mm acc, tr, tr
// Semantics: acc = acc + tr1 * tr2
//
// Data Flow: TileReg × TileReg → AccReg (accumulate)
//   - ms1: TileReg for matrix A
//   - ms2: TileReg for matrix B
//   - md:  AccReg for accumulation result C
//
// eew encoding:
//   000 = int8 (b), 001 = int16 (h), 010 = int32 (w), 011 = int64 (dw)
//   100 = use mtype.msew, 111 = int4
//
// funct6 encoding:
//   001000 = no-widen
//   001001 = double-widen
//   001010 = quad-widen
//   001011 = oct-widen
//===----------------------------------------------------------------------===//

// No-widen matrix multiply-accumulate: acc = acc + tr1 * tr2
// Input and output have the same element width
class BOSC_AME_MMA_NO_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                   bits<3> eew_val, string opcodestr>
    : RVInstBOSCAME32<(outs AccReg:$md),
                  (ins AccReg:$md_in, TileReg:$ms1, TileReg:$ms2),
                  opcodestr, "$md, $ms1, $ms2"> {
  let Constraints = "$md = $md_in";  // Accumulator constraint
  let funct6 = 0b001000;     // No widening
  let fp = fp_val;
  let sa = sa_val;        // Matrix multiplication
  let sn = sn_val;        // (signed for integers, 0 for floating-point)
  let eew = eew_val;
  let ma = 0b1;       // Accumulate
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // int 16 32 64 , output no-widen
  def BOSC_AME_MMA_MM    : BOSC_AME_MMA_NO_WIDEN<0b0, 0b0, 0b1, 0b100, "mma.mm">;
  def BOSC_AME_MMA_H_MM  : BOSC_AME_MMA_NO_WIDEN<0b0, 0b0, 0b1, 0b001, "mma.h.mm">;
  def BOSC_AME_MMA_W_MM  : BOSC_AME_MMA_NO_WIDEN<0b0, 0b0, 0b1, 0b010, "mma.w.mm">;
  def BOSC_AME_MMA_DW_MM : BOSC_AME_MMA_NO_WIDEN<0b0, 0b0, 0b1, 0b011, "mma.dw.mm">;

  // int 16 32 64 , output  no-widen and saturated
  def BOSC_AME_MSMA_MM    : BOSC_AME_MMA_NO_WIDEN<0b0, 0b1, 0b1, 0b100, "msma.mm">;
  def BOSC_AME_MSMA_H_MM  : BOSC_AME_MMA_NO_WIDEN<0b0, 0b1, 0b1, 0b001, "msma.h.mm">;
  def BOSC_AME_MSMA_W_MM  : BOSC_AME_MMA_NO_WIDEN<0b0, 0b1, 0b1, 0b010, "msma.w.mm">;
  def BOSC_AME_MSMA_DW_MM : BOSC_AME_MMA_NO_WIDEN<0b0, 0b1, 0b1, 0b011, "msma.dw.mm">;

  // uint 16 32 64 , output no-widen
  def BOSC_AME_MMAU_MM    : BOSC_AME_MMA_NO_WIDEN<0b0, 0b0, 0b0, 0b100, "mmau.mm">;
  def BOSC_AME_MMAU_H_MM  : BOSC_AME_MMA_NO_WIDEN<0b0, 0b0, 0b0, 0b001, "mmau.h.mm">;
  def BOSC_AME_MMAU_W_MM  : BOSC_AME_MMA_NO_WIDEN<0b0, 0b0, 0b0, 0b010, "mmau.w.mm">;
  def BOSC_AME_MMAU_DW_MM : BOSC_AME_MMA_NO_WIDEN<0b0, 0b0, 0b0, 0b011, "mmau.dw.mm">;

  // uint 16 32 64 , output no-widen and saturated
  def BOSC_AME_MSMAU_MM    : BOSC_AME_MMA_NO_WIDEN<0b0, 0b1, 0b0, 0b100, "msmau.mm">;
  def BOSC_AME_MSMAU_H_MM  : BOSC_AME_MMA_NO_WIDEN<0b0, 0b1, 0b0, 0b001, "msmau.h.mm">;
  def BOSC_AME_MSMAU_W_MM  : BOSC_AME_MMA_NO_WIDEN<0b0, 0b1, 0b0, 0b010, "msmau.w.mm">;
  def BOSC_AME_MSMAU_DW_MM : BOSC_AME_MMA_NO_WIDEN<0b0, 0b1, 0b0, 0b011, "msmau.dw.mm">;

  // float point 16 32 64 , output no-widen
  def BOSC_AME_MFMA_MM    : BOSC_AME_MMA_NO_WIDEN<0b1, 0b0, 0b0, 0b100, "mfma.mm">;
  def BOSC_AME_MFMA_HF_MM : BOSC_AME_MMA_NO_WIDEN<0b1, 0b0, 0b0, 0b001, "mfma.hf.mm">;
  def BOSC_AME_MFMA_F_MM  : BOSC_AME_MMA_NO_WIDEN<0b1, 0b0, 0b0, 0b010, "mfma.f.mm">;
  def BOSC_AME_MFMA_D_MM  : BOSC_AME_MMA_NO_WIDEN<0b1, 0b0, 0b0, 0b011, "mfma.d.mm">;
}

// double-widen matrix multiply-accumulate: acc = acc + tr1 * tr2
class BOSC_AME_MMA_DOUBLE_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                                bits<3> eew_val, string opcodestr>
    : RVInstBOSCAME32<(outs AccReg:$md),
                      (ins AccReg:$md_in, TileReg:$ms1, TileReg:$ms2),
                      opcodestr, "$md, $ms1, $ms2"> {
  let Constraints = "$md = $md_in";
  let funct6 = 0b001001;
  let fp     = fp_val;
  let sa     = sa_val;
  let sn     = sn_val;
  let eew    = eew_val;
  let ma     = 0b1;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // uint 16→32, 32→64 with double widening
  def BOSC_AME_MWMAU_MM    : BOSC_AME_MMA_DOUBLE_WIDEN<0b0, 0b0, 0b0, 0b100, "mwmau.mm">;
  def BOSC_AME_MWMAU_H_MM  : BOSC_AME_MMA_DOUBLE_WIDEN<0b0, 0b0, 0b0, 0b001, "mwmau.h.mm">;
  def BOSC_AME_MWMAU_W_MM  : BOSC_AME_MMA_DOUBLE_WIDEN<0b0, 0b0, 0b0, 0b010, "mwmau.w.mm">;

  // uint 16→32, 32→64 with double widening and saturation
  def BOSC_AME_MSWMAU_MM   : BOSC_AME_MMA_DOUBLE_WIDEN<0b0, 0b1, 0b0, 0b100, "mswmau.mm">;
  def BOSC_AME_MSWMAU_H_MM : BOSC_AME_MMA_DOUBLE_WIDEN<0b0, 0b1, 0b0, 0b001, "mswmau.h.mm">;
  def BOSC_AME_MSWMAU_W_MM : BOSC_AME_MMA_DOUBLE_WIDEN<0b0, 0b1, 0b0, 0b010, "mswmau.w.mm">;

  // int 16→32, 32→64 with double widening
  def BOSC_AME_MWMA_MM     : BOSC_AME_MMA_DOUBLE_WIDEN<0b0, 0b0, 0b1, 0b100, "mwma.mm">;
  def BOSC_AME_MWMA_H_MM   : BOSC_AME_MMA_DOUBLE_WIDEN<0b0, 0b0, 0b1, 0b001, "mwma.h.mm">;
  def BOSC_AME_MWMA_W_MM   : BOSC_AME_MMA_DOUBLE_WIDEN<0b0, 0b0, 0b1, 0b010, "mwma.w.mm">;

  // int 16→32, 32→64 with double widening and saturation
  def BOSC_AME_MSWMA_MM    : BOSC_AME_MMA_DOUBLE_WIDEN<0b0, 0b1, 0b1, 0b100, "mswma.mm">;
  def BOSC_AME_MSWMA_H_MM  : BOSC_AME_MMA_DOUBLE_WIDEN<0b0, 0b1, 0b1, 0b001, "mswma.h.mm">;
  def BOSC_AME_MSWMA_W_MM  : BOSC_AME_MMA_DOUBLE_WIDEN<0b0, 0b1, 0b1, 0b010, "mswma.w.mm">;

  // float point 8→16, 16→32, 32→64 with double widening
  def BOSC_AME_MFWMA_MM    : BOSC_AME_MMA_DOUBLE_WIDEN<0b1, 0b0, 0b0, 0b100, "mfwma.mm">;
  def BOSC_AME_MFWMA_CF_MM : BOSC_AME_MMA_DOUBLE_WIDEN<0b1, 0b0, 0b0, 0b000, "mfwma.cf.mm">;
  def BOSC_AME_MFWMA_HF_MM : BOSC_AME_MMA_DOUBLE_WIDEN<0b1, 0b0, 0b0, 0b001, "mfwma.hf.mm">;
  def BOSC_AME_MFWMA_F_MM  : BOSC_AME_MMA_DOUBLE_WIDEN<0b1, 0b0, 0b0, 0b010, "mfwma.f.mm">;
}

// quad-widen matrix multiply-accumulate: acc = acc + tr1 * tr2
class BOSC_AME_MMA_QUAD_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                               bits<3> eew_val, string opcodestr>
    : RVInstBOSCAME32<(outs AccReg:$md),
                      (ins AccReg:$md_in, TileReg:$ms1, TileReg:$ms2),
                      opcodestr, "$md, $ms1, $ms2"> {
  let Constraints = "$md = $md_in";
  let funct6 = 0b001010;
  let fp     = fp_val;
  let sa     = sa_val;
  let sn     = sn_val;
  let eew    = eew_val;
  let ma     = 0b1;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // uint 8→32 with quad widening
  def BOSC_AME_MQMAU_MM   : BOSC_AME_MMA_QUAD_WIDEN<0b0, 0b0, 0b0, 0b100, "mqmau.mm">;
  def BOSC_AME_MQMAU_B_MM : BOSC_AME_MMA_QUAD_WIDEN<0b0, 0b0, 0b0, 0b000, "mqmau.b.mm">;
  // uint 8→32 with quad widening and saturation
  def BOSC_AME_MSQMAU_MM   : BOSC_AME_MMA_QUAD_WIDEN<0b0, 0b1, 0b0, 0b100, "msqmau.mm">;
  def BOSC_AME_MSQMAU_B_MM : BOSC_AME_MMA_QUAD_WIDEN<0b0, 0b1, 0b0, 0b000, "msqmau.b.mm">;
  // int 8→32 with quad widening
  def BOSC_AME_MQMA_MM   : BOSC_AME_MMA_QUAD_WIDEN<0b0, 0b0, 0b1, 0b100, "mqma.mm">;
  def BOSC_AME_MQMA_B_MM : BOSC_AME_MMA_QUAD_WIDEN<0b0, 0b0, 0b1, 0b000, "mqma.b.mm">;
  // int 8→32 with quad widening and saturation
  def BOSC_AME_MSQMA_MM   : BOSC_AME_MMA_QUAD_WIDEN<0b0, 0b1, 0b1, 0b100, "msqma.mm">;
  def BOSC_AME_MSQMA_B_MM : BOSC_AME_MMA_QUAD_WIDEN<0b0, 0b1, 0b1, 0b000, "msqma.b.mm">;
  // float point 8→32 with quad widening
  def BOSC_AME_MFQMA_MM    : BOSC_AME_MMA_QUAD_WIDEN<0b1, 0b0, 0b1, 0b100, "mfqma.mm">;
  def BOSC_AME_MFQMA_CF_MM : BOSC_AME_MMA_QUAD_WIDEN<0b1, 0b0, 0b1, 0b000, "mfqma.cf.mm">;
}

// oct-widen matrix multiply-accumulate: acc = acc + tr1 * tr2
class BOSC_AME_MMA_OCT_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                              bits<3> eew_val, string opcodestr>
    : RVInstBOSCAME32<(outs AccReg:$md),
                      (ins AccReg:$md_in, TileReg:$ms1, TileReg:$ms2),
                      opcodestr, "$md, $ms1, $ms2"> {
  let Constraints = "$md = $md_in";
  let funct6 = 0b001011;
  let fp     = fp_val;
  let sa     = sa_val;
  let sn     = sn_val;
  let eew    = eew_val;
  let ma     = 0b1;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // uint 4→32 with oct widening
  def BOSC_AME_MOMAU_MM    : BOSC_AME_MMA_OCT_WIDEN<0b0, 0b0, 0b0, 0b100, "momau.mm">;
  def BOSC_AME_MOMAU_HB_MM : BOSC_AME_MMA_OCT_WIDEN<0b0, 0b0, 0b0, 0b111, "momau.hb.mm">;
  // uint 4→32 with oct widening and saturation
  def BOSC_AME_MSOMAU_MM    : BOSC_AME_MMA_OCT_WIDEN<0b0, 0b1, 0b0, 0b100, "msomau.mm">;
  def BOSC_AME_MSOMAU_HB_MM : BOSC_AME_MMA_OCT_WIDEN<0b0, 0b1, 0b0, 0b111, "msomau.hb.mm">;
  // int 4→32 with oct widening
  def BOSC_AME_MOMA_MM    : BOSC_AME_MMA_OCT_WIDEN<0b0, 0b0, 0b1, 0b100, "moma.mm">;
  def BOSC_AME_MOMA_HB_MM : BOSC_AME_MMA_OCT_WIDEN<0b0, 0b0, 0b1, 0b111, "moma.hb.mm">;
  // int 4→32 with oct widening and saturation
  def BOSC_AME_MSOMA_MM    : BOSC_AME_MMA_OCT_WIDEN<0b0, 0b1, 0b1, 0b100, "msoma.mm">;
  def BOSC_AME_MSOMA_HB_MM : BOSC_AME_MMA_OCT_WIDEN<0b0, 0b1, 0b1, 0b111, "msoma.hb.mm">;
}

class RVInstBOSCSMM<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<6> funct6;
  bit     fp;     // 0 for integer, 1 for floating-point (if supported in future)
  bit     sa;     // 0 for unsaturated, 1 for saturated
  bits<4> ms2;
  bit     sn;     // Whether the source operand is signed (for integers), 0 for floating-point
  bits<4> ms1;
  bits<3> eew;    
  bit     sp;
  bits<4> md;
  bits<7> opcode = 0b1110111;

  let Inst{31-26} = funct6;
  let Inst{25}    = fp;
  let Inst{24}    = sa;
  let Inst{23-20} = ms2;
  let Inst{19}    = sn;
  let Inst{18-15} = ms1;
  let Inst{14-12} = eew;
  let Inst{11}    = sp;
  let Inst{10-7}  = md;
  let Inst{6-0} = 0b1110111;
}

class BOSC_MMA_SP_NO_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                   bits<3> eew_val, bit sp_val, string opcodestr>
    : RVInstBOSCSMM<(outs AccReg:$md),
                  (ins AccReg:$md_in, TileReg:$ms1, TileReg:$ms2),
                  opcodestr, "$md, $ms1, $ms2"> {
  let Constraints = "$md = $md_in";  // Accumulator constraint
  let funct6 = 0b101000;     // No widening
  let fp = fp_val;
  let sa = sa_val;        // Matrix multiplication
  let sn = sn_val;        // (signed for integers, 0 for floating-point)
  let eew = eew_val;
  let sp = sp_val;       // Special instruction
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {

  def BOSC_AME_MMAU_SPA_MM    : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b0, 0b100, 0b0, "mmau.spa.mm">;
  def BOSC_AME_MMAU_SPA_H_MM  : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b0, 0b001, 0b0, "mmau.spa.h.mm">;
  def BOSC_AME_MMAU_SPA_W_MM  : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b0, 0b010, 0b0, "mmau.spa.w.mm">;
  def BOSC_AME_MMAU_SPA_DW_MM : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b0, 0b011, 0b0, "mmau.spa.dw.mm">;
  def BOSC_AME_MMAU_SPB_MM    : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b0, 0b100, 0b1, "mmau.spb.mm">;
  def BOSC_AME_MMAU_SPB_H_MM  : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b0, 0b001, 0b1, "mmau.spb.h.mm">;
  def BOSC_AME_MMAU_SPB_W_MM  : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b0, 0b010, 0b1, "mmau.spb.w.mm">;
  def BOSC_AME_MMAU_SPB_DW_MM : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b0, 0b011, 0b1, "mmau.spb.dw.mm">;

  def BOSC_AME_MSMAU_SPA_MM   : BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b0, 0b100, 0b0, "msmau.spa.mm">;
  def BOSC_AME_MSMAU_SPA_H_MM : BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b0, 0b001, 0b0, "msmau.spa.h.mm">;
  def BOSC_AME_MSMAU_SPA_W_MM : BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b0, 0b010, 0b0, "msmau.spa.w.mm">;
  def BOSC_AME_MSMAU_SPA_DW_MM: BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b0, 0b011, 0b0, "msmau.spa.dw.mm">;
  def BOSC_AME_MSMAU_SPB_MM   : BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b0, 0b100, 0b1, "msmau.spb.mm">;
  def BOSC_AME_MSMAU_SPB_H_MM : BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b0, 0b001, 0b1, "msmau.spb.h.mm">;
  def BOSC_AME_MSMAU_SPB_W_MM : BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b0, 0b010, 0b1, "msmau.spb.w.mm">;
  def BOSC_AME_MSMAU_SPB_DW_MM: BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b0, 0b011, 0b1, "msmau.spb.dw.mm">;

  def BOSC_AME_MMA_SPA_MM    : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b1, 0b100, 0b0, "mma.spa.mm">;
  def BOSC_AME_MMA_SPA_H_MM  : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b1, 0b001, 0b0, "mma.spa.h.mm">;
  def BOSC_AME_MMA_SPA_W_MM  : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b1, 0b010, 0b0, "mma.spa.w.mm">;
  def BOSC_AME_MMA_SPA_DW_MM : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b1, 0b011, 0b0, "mma.spa.dw.mm">;
  def BOSC_AME_MMA_SPB_MM    : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b1, 0b100, 0b1, "mma.spb.mm">;
  def BOSC_AME_MMA_SPB_H_MM  : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b1, 0b001, 0b1, "mma.spb.h.mm">;
  def BOSC_AME_MMA_SPB_W_MM  : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b1, 0b010, 0b1, "mma.spb.w.mm">;
  def BOSC_AME_MMA_SPB_DW_MM : BOSC_MMA_SP_NO_WIDEN<0b0, 0b0, 0b1, 0b011, 0b1, "mma.spb.dw.mm">;

  def BOSC_AME_MSMA_SPA_MM   : BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b1, 0b100, 0b0, "msma.spa.mm">;
  def BOSC_AME_MSMA_SPA_H_MM : BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b1, 0b001, 0b0, "msma.spa.h.mm">;
  def BOSC_AME_MSMA_SPA_W_MM : BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b1, 0b010, 0b0, "msma.spa.w.mm">;
  def BOSC_AME_MSMA_SPA_DW_MM: BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b1, 0b011, 0b0, "msma.spa.dw.mm">;
  def BOSC_AME_MSMA_SPB_MM   : BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b1, 0b100, 0b1, "msma.spb.mm">;
  def BOSC_AME_MSMA_SPB_H_MM : BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b1, 0b001, 0b1, "msma.spb.h.mm">;
  def BOSC_AME_MSMA_SPB_W_MM : BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b1, 0b010, 0b1, "msma.spb.w.mm">;
  def BOSC_AME_MSMA_SPB_DW_MM: BOSC_MMA_SP_NO_WIDEN<0b0, 0b1, 0b1, 0b011, 0b1, "msma.spb.dw.mm">;

  def BOSC_AME_MFMA_SPA_MM   : BOSC_MMA_SP_NO_WIDEN<0b1, 0b0, 0b1, 0b100, 0b0, "mfma.spa.mm">;
  def BOSC_AME_MFMA_SPA_HF_MM: BOSC_MMA_SP_NO_WIDEN<0b1, 0b0, 0b1, 0b001, 0b0, "mfma.spa.hf.mm">;
  def BOSC_AME_MFMA_SPA_F_MM : BOSC_MMA_SP_NO_WIDEN<0b1, 0b0, 0b1, 0b010, 0b0, "mfma.spa.f.mm">;
  def BOSC_AME_MFMA_SPA_D_MM : BOSC_MMA_SP_NO_WIDEN<0b1, 0b0, 0b1, 0b011, 0b0, "mfma.spa.d.mm">;
  def BOSC_AME_MFMA_SPB_MM   : BOSC_MMA_SP_NO_WIDEN<0b1, 0b0, 0b1, 0b100, 0b1, "mfma.spb.mm">;
  def BOSC_AME_MFMA_SPB_HF_MM: BOSC_MMA_SP_NO_WIDEN<0b1, 0b0, 0b1, 0b001, 0b1, "mfma.spb.hf.mm">;
  def BOSC_AME_MFMA_SPB_F_MM : BOSC_MMA_SP_NO_WIDEN<0b1, 0b0, 0b1, 0b010, 0b1, "mfma.spb.f.mm">;
  def BOSC_AME_MFMA_SPB_D_MM : BOSC_MMA_SP_NO_WIDEN<0b1, 0b0, 0b1, 0b011, 0b1, "mfma.spb.d.mm">;
}

class BOSC_MMA_SP_DOUBLE_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                   bits<3> eew_val, bit sp_val, string opcodestr>
    : RVInstBOSCSMM<(outs AccReg:$md),
                  (ins AccReg:$md_in, TileReg:$ms1, TileReg:$ms2),
                  opcodestr, "$md, $ms1, $ms2"> {
  let Constraints = "$md = $md_in";  // Accumulator constraint
  let funct6 = 0b101001;     // Double widening
  let fp = fp_val;
  let sa = sa_val;        // Matrix multiplication
  let sn = sn_val;        // (signed for integers, 0 for floating-point)
  let eew = eew_val;
  let sp = sp_val;       // Special instruction
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {

  def BOSC_AME_MWMAU_SPA_MM    : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b0, 0b0, 0b100, 0b0, "mwmau.spa.mm">;
  def BOSC_AME_MWMAU_SPA_H_MM  : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b0, 0b0, 0b001, 0b0, "mwmau.spa.h.mm">;
  def BOSC_AME_MWMAU_SPA_W_MM  : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b0, 0b0, 0b010, 0b0, "mwmau.spa.w.mm">;
  def BOSC_AME_MWMAU_SPB_MM    : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b0, 0b0, 0b100, 0b1, "mwmau.spb.mm">;
  def BOSC_AME_MWMAU_SPB_H_MM  : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b0, 0b0, 0b001, 0b1, "mwmau.spb.h.mm">;
  def BOSC_AME_MWMAU_SPB_W_MM  : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b0, 0b0, 0b010, 0b1, "mwmau.spb.w.mm">;

  def BOSC_AME_MSWMAU_SPA_MM   : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b1, 0b0, 0b100, 0b0, "mswmau.spa.mm">;
  def BOSC_AME_MSWMAU_SPA_H_MM : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b1, 0b0, 0b001, 0b0, "mswmau.spa.h.mm">;
  def BOSC_AME_MSWMAU_SPA_W_MM : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b1, 0b0, 0b010, 0b0, "mswmau.spa.w.mm">;
  def BOSC_AME_MSWMAU_SPB_MM   : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b1, 0b0, 0b100, 0b1, "mswmau.spb.mm">;
  def BOSC_AME_MSWMAU_SPB_H_MM : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b1, 0b0, 0b001, 0b1, "mswmau.spb.h.mm">;
  def BOSC_AME_MSWMAU_SPB_W_MM : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b1, 0b0, 0b010, 0b1, "mswmau.spb.w.mm">;

  def BOSC_AME_MWMA_SPA_MM    : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b0, 0b1, 0b100, 0b0, "mwma.spa.mm">;
  def BOSC_AME_MWMA_SPA_H_MM  : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b0, 0b1, 0b001, 0b0, "mwma.spa.h.mm">;
  def BOSC_AME_MWMA_SPA_W_MM  : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b0, 0b1, 0b010, 0b0, "mwma.spa.w.mm">;
  def BOSC_AME_MWMA_SPB_MM    : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b0, 0b1, 0b100, 0b1, "mwma.spb.mm">;
  def BOSC_AME_MWMA_SPB_H_MM  : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b0, 0b1, 0b001, 0b1, "mwma.spb.h.mm">;
  def BOSC_AME_MWMA_SPB_W_MM  : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b0, 0b1, 0b010, 0b1, "mwma.spb.w.mm">;

  def BOSC_AME_MSWMA_SPA_MM   : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b1, 0b1, 0b100, 0b0, "mswma.spa.mm">;
  def BOSC_AME_MSWMA_SPA_H_MM : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b1, 0b1, 0b001, 0b0, "mswma.spa.h.mm">;
  def BOSC_AME_MSWMA_SPA_W_MM : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b1, 0b1, 0b010, 0b0, "mswma.spa.w.mm">;
  def BOSC_AME_MSWMA_SPB_MM   : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b1, 0b1, 0b100, 0b1, "mswma.spb.mm">;
  def BOSC_AME_MSWMA_SPB_H_MM : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b1, 0b1, 0b001, 0b1, "mswma.spb.h.mm">;
  def BOSC_AME_MSWMA_SPB_W_MM : BOSC_MMA_SP_DOUBLE_WIDEN<0b0, 0b1, 0b1, 0b010, 0b1, "mswma.spb.w.mm">;

  def BOSC_AME_MFWMA_SPA_MM   : BOSC_MMA_SP_DOUBLE_WIDEN<0b1, 0b0, 0b1, 0b100, 0b0, "mfwma.spa.mm">;
  def BOSC_AME_MFWMA_SPA_HF_MM: BOSC_MMA_SP_DOUBLE_WIDEN<0b1, 0b0, 0b1, 0b001, 0b0, "mfwma.spa.hf.mm">;
  def BOSC_AME_MFWMA_SPA_F_MM : BOSC_MMA_SP_DOUBLE_WIDEN<0b1, 0b0, 0b1, 0b010, 0b0, "mfwma.spa.f.mm">;
  def BOSC_AME_MFWMA_SPB_MM   : BOSC_MMA_SP_DOUBLE_WIDEN<0b1, 0b0, 0b1, 0b100, 0b1, "mfwma.spb.mm">;
  def BOSC_AME_MFWMA_SPB_HF_MM: BOSC_MMA_SP_DOUBLE_WIDEN<0b1, 0b0, 0b1, 0b001, 0b1, "mfwma.spb.hf.mm">;
  def BOSC_AME_MFWMA_SPB_F_MM : BOSC_MMA_SP_DOUBLE_WIDEN<0b1, 0b0, 0b1, 0b010, 0b1, "mfwma.spb.f.mm">;
}

class BOSC_MMA_SP_QUAD_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                   bits<3> eew_val, bit sp_val, string opcodestr>
    : RVInstBOSCSMM<(outs AccReg:$md),
                  (ins AccReg:$md_in, TileReg:$ms1, TileReg:$ms2),
                  opcodestr, "$md, $ms1, $ms2"> {
  let Constraints = "$md = $md_in";  // Accumulator constraint
  let funct6 = 0b101010;     // Quad widening
  let fp = fp_val;
  let sa = sa_val;        // Matrix multiplication
  let sn = sn_val;        // (signed for integers, 0 for floating-point)
  let eew = eew_val;
  let sp = sp_val;       // Special instruction
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {

  def BOSC_AME_MQMAU_SPA_MM    : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b0, 0b0, 0b100, 0b0, "mqmau.spa.mm">;
  def BOSC_AME_MQMAU_SPA_B_MM  : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b0, 0b0, 0b000, 0b0, "mqmau.spa.b.mm">;
  def BOSC_AME_MQMAU_SPB_MM    : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b0, 0b0, 0b100, 0b1, "mqmau.spb.mm">;
  def BOSC_AME_MQMAU_SPB_B_MM  : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b0, 0b0, 0b000, 0b1, "mqmau.spb.b.mm">;

  def BOSC_AME_MSQMAU_SPA_MM   : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b1, 0b0, 0b100, 0b0, "msqmau.spa.mm">;
  def BOSC_AME_MSQMAU_SPA_B_MM : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b1, 0b0, 0b000, 0b0, "msqmau.spa.b.mm">;
  def BOSC_AME_MSQMAU_SPB_MM   : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b1, 0b0, 0b100, 0b1, "msqmau.spb.mm">;
  def BOSC_AME_MSQMAU_SPB_B_MM : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b1, 0b0, 0b000, 0b1, "msqmau.spb.b.mm">;

  def BOSC_AME_MQMA_SPA_MM    : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b0, 0b1, 0b100, 0b0, "mqma.spa.mm">;
  def BOSC_AME_MQMA_SPA_B_MM  : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b0, 0b1, 0b000, 0b0, "mqma.spa.b.mm">;
  def BOSC_AME_MQMA_SPB_MM    : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b0, 0b1, 0b100, 0b1, "mqma.spb.mm">;
  def BOSC_AME_MQMA_SPB_B_MM  : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b0, 0b1, 0b000, 0b1, "mqma.spb.b.mm">;

  def BOSC_AME_MSQMA_SPA_MM   : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b1, 0b1, 0b100, 0b0, "msqma.spa.mm">;
  def BOSC_AME_MSQMA_SPA_B_MM : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b1, 0b1, 0b000, 0b0, "msqma.spa.b.mm">;
  def BOSC_AME_MSQMA_SPB_MM   : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b1, 0b1, 0b100, 0b1, "msqma.spb.mm">;
  def BOSC_AME_MSQMA_SPB_B_MM : BOSC_MMA_SP_QUAD_WIDEN<0b0, 0b1, 0b1, 0b000, 0b1, "msqma.spb.b.mm">;

  def BOSC_AME_MFQMA_SPA_MM   : BOSC_MMA_SP_QUAD_WIDEN<0b1, 0b0, 0b1, 0b100, 0b0, "mfqma.spa.mm">;
  def BOSC_AME_MFQMA_SPA_CF_MM: BOSC_MMA_SP_QUAD_WIDEN<0b1, 0b0, 0b1, 0b001, 0b0, "mfqma.spa.cf.mm">;
  def BOSC_AME_MFQMA_SPB_MM   : BOSC_MMA_SP_QUAD_WIDEN<0b1, 0b0, 0b1, 0b100, 0b1, "mfqma.spb.mm">;
  def BOSC_AME_MFQMA_SPB_CF_MM: BOSC_MMA_SP_QUAD_WIDEN<0b1, 0b0, 0b1, 0b001, 0b1, "mfqma.spb.cf.mm">;
}

class BOSC_MMA_SP_OCT_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                   bits<3> eew_val, bit sp_val, string opcodestr>
    : RVInstBOSCSMM<(outs AccReg:$md),
                  (ins AccReg:$md_in, TileReg:$ms1, TileReg:$ms2),
                  opcodestr, "$md, $ms1, $ms2"> {
  let Constraints = "$md = $md_in";  // Accumulator constraint
  let funct6 = 0b101011;     // Oct widening
  let fp = fp_val;
  let sa = sa_val;        // Matrix multiplication
  let sn = sn_val;        // (signed for integers, 0 for floating-point)
  let eew = eew_val;
  let sp = sp_val;       // Special instruction
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {

  def BOSC_AME_MOMAU_SPA_MM    : BOSC_MMA_SP_OCT_WIDEN<0b0, 0b0, 0b0, 0b100, 0b0, "momau.spa.mm">;
  def BOSC_AME_MOMAU_SPA_HB_MM : BOSC_MMA_SP_OCT_WIDEN<0b0, 0b0, 0b0, 0b111, 0b0, "momau.spa.hb.mm">;
  def BOSC_AME_MOMAU_SPB_MM    : BOSC_MMA_SP_OCT_WIDEN<0b0, 0b0, 0b0, 0b100, 0b1, "momau.spb.mm">;
  def BOSC_AME_MOMAU_SPB_HB_MM : BOSC_MMA_SP_OCT_WIDEN<0b0, 0b0, 0b0, 0b111, 0b1, "momau.spb.hb.mm">;

  def BOSC_AME_MSOMAU_SPA_MM   : BOSC_MMA_SP_OCT_WIDEN<0b0, 0b1, 0b0, 0b100, 0b0, "msomau.spa.mm">;
  def BOSC_AME_MSOMAU_SPA_HB_MM: BOSC_MMA_SP_OCT_WIDEN<0b0, 0b1, 0b0, 0b111, 0b0, "msomau.spa.hb.mm">;
  def BOSC_AME_MSOMAU_SPB_MM   : BOSC_MMA_SP_OCT_WIDEN<0b0, 0b1, 0b0, 0b100, 0b1, "msomau.spb.mm">;
  def BOSC_AME_MSOMAU_SPB_HB_MM: BOSC_MMA_SP_OCT_WIDEN<0b0, 0b1, 0b0, 0b111, 0b1, "msomau.spb.hb.mm">;

  def BOSC_AME_MOMA_SPA_MM    : BOSC_MMA_SP_OCT_WIDEN<0b0, 0b0, 0b1, 0b100, 0b0, "moma.spa.mm">;
  def BOSC_AME_MOMA_SPA_HB_MM : BOSC_MMA_SP_OCT_WIDEN<0b0, 0b0, 0b1, 0b111, 0b0, "moma.spa.hb.mm">;
  def BOSC_AME_MOMA_SPB_MM    : BOSC_MMA_SP_OCT_WIDEN<0b0, 0b0, 0b1, 0b100, 0b1, "moma.spb.mm">;
  def BOSC_AME_MOMA_SPB_HB_MM : BOSC_MMA_SP_OCT_WIDEN<0b0, 0b0, 0b1, 0b111, 0b1, "moma.spb.hb.mm">;

  def BOSC_AME_MSOMA_SPA_MM   : BOSC_MMA_SP_OCT_WIDEN<0b0, 0b1, 0b1, 0b100, 0b0, "msoma.spa.mm">;
  def BOSC_AME_MSOMA_SPA_HB_MM: BOSC_MMA_SP_OCT_WIDEN<0b0, 0b1, 0b1, 0b111, 0b0, "msoma.spa.hb.mm">;
  def BOSC_AME_MSOMA_SPB_MM   : BOSC_MMA_SP_OCT_WIDEN<0b0, 0b1, 0b1, 0b100, 0b1, "msoma.spb.mm">;
  def BOSC_AME_MSOMA_SPB_HB_MM: BOSC_MMA_SP_OCT_WIDEN<0b0, 0b1, 0b1, 0b111, 0b1, "msoma.spb.hb.mm">;
}

//===----------------------------------------------------------------------===//
// BOSC AME Element-Wise Instructions
//===----------------------------------------------------------------------===//
// Matrix element-wise add/sub/multiply instructions.
class BOSC_AME_MADD_NO_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                              bits<3> eew_val, string opcodestr>
    : RVInstBOSCAME32<(outs AccReg:$md),
                      (ins AccReg:$ms1, AccReg:$ms2),
                      opcodestr, "$md, $ms1, $ms2"> {
  let funct6 = 0b001000;
  let fp     = fp_val;
  let sa     = sa_val;
  let sn     = sn_val;
  let eew    = eew_val;
  let ma     = 0b0;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // uint 4 8 16 32 64 , output no-widen
  def BOSC_AME_MADDU_MM    : BOSC_AME_MADD_NO_WIDEN<0b0, 0b0, 0b0, 0b100, "maddu.mm">;
  def BOSC_AME_MADDU_HB_MM : BOSC_AME_MADD_NO_WIDEN<0b0, 0b0, 0b0, 0b111, "maddu.hb.mm">;
  def BOSC_AME_MADDU_B_MM  : BOSC_AME_MADD_NO_WIDEN<0b0, 0b0, 0b0, 0b000, "maddu.b.mm">;
  def BOSC_AME_MADDU_H_MM  : BOSC_AME_MADD_NO_WIDEN<0b0, 0b0, 0b0, 0b001, "maddu.h.mm">;
  def BOSC_AME_MADDU_W_MM  : BOSC_AME_MADD_NO_WIDEN<0b0, 0b0, 0b0, 0b010, "maddu.w.mm">;
  def BOSC_AME_MADDU_DW_MM : BOSC_AME_MADD_NO_WIDEN<0b0, 0b0, 0b0, 0b011, "maddu.dw.mm">;
  // uint 4 8 16 32 64 , output no-widen and saturated
  def BOSC_AME_MSADDU_MM    : BOSC_AME_MADD_NO_WIDEN<0b0, 0b1, 0b0, 0b100, "msaddu.mm">;
  def BOSC_AME_MSADDU_HB_MM : BOSC_AME_MADD_NO_WIDEN<0b0, 0b1, 0b0, 0b111, "msaddu.hb.mm">;
  def BOSC_AME_MSADDU_B_MM  : BOSC_AME_MADD_NO_WIDEN<0b0, 0b1, 0b0, 0b000, "msaddu.b.mm">;
  def BOSC_AME_MSADDU_H_MM  : BOSC_AME_MADD_NO_WIDEN<0b0, 0b1, 0b0, 0b001, "msaddu.h.mm">;
  def BOSC_AME_MSADDU_W_MM  : BOSC_AME_MADD_NO_WIDEN<0b0, 0b1, 0b0, 0b010, "msaddu.w.mm">;
  def BOSC_AME_MSADDU_DW_MM : BOSC_AME_MADD_NO_WIDEN<0b0, 0b1, 0b0, 0b011, "msaddu.dw.mm">;
  // int 4 8 16 32 64 , output no-widen
  def BOSC_AME_MADD_MM    : BOSC_AME_MADD_NO_WIDEN<0b0, 0b0, 0b1, 0b100, "madd.mm">;
  def BOSC_AME_MADD_HB_MM : BOSC_AME_MADD_NO_WIDEN<0b0, 0b0, 0b1, 0b111, "madd.hb.mm">;
  def BOSC_AME_MADD_B_MM  : BOSC_AME_MADD_NO_WIDEN<0b0, 0b0, 0b1, 0b000, "madd.b.mm">;
  def BOSC_AME_MADD_H_MM  : BOSC_AME_MADD_NO_WIDEN<0b0, 0b0, 0b1, 0b001, "madd.h.mm">;
  def BOSC_AME_MADD_W_MM  : BOSC_AME_MADD_NO_WIDEN<0b0, 0b0, 0b1, 0b010, "madd.w.mm">;
  def BOSC_AME_MADD_DW_MM : BOSC_AME_MADD_NO_WIDEN<0b0, 0b0, 0b1, 0b011, "madd.dw.mm">;
  // int 4 8 16 32 64 , output no-widen and saturated
  def BOSC_AME_MSADD_MM    : BOSC_AME_MADD_NO_WIDEN<0b0, 0b1, 0b1, 0b100, "msadd.mm">;
  def BOSC_AME_MSADD_HB_MM : BOSC_AME_MADD_NO_WIDEN<0b0, 0b1, 0b1, 0b111, "msadd.hb.mm">;
  def BOSC_AME_MSADD_B_MM  : BOSC_AME_MADD_NO_WIDEN<0b0, 0b1, 0b1, 0b000, "msadd.b.mm">;
  def BOSC_AME_MSADD_H_MM  : BOSC_AME_MADD_NO_WIDEN<0b0, 0b1, 0b1, 0b001, "msadd.h.mm">;
  def BOSC_AME_MSADD_W_MM  : BOSC_AME_MADD_NO_WIDEN<0b0, 0b1, 0b1, 0b010, "msadd.w.mm">;
  def BOSC_AME_MSADD_DW_MM : BOSC_AME_MADD_NO_WIDEN<0b0, 0b1, 0b1, 0b011, "msadd.dw.mm">;
  // float point 8 16 32 64 , output no-widen
  def BOSC_AME_MFADD_MM    : BOSC_AME_MADD_NO_WIDEN<0b1, 0b0, 0b1, 0b100, "mfadd.mm">;
  def BOSC_AME_MFADD_CF_MM : BOSC_AME_MADD_NO_WIDEN<0b1, 0b0, 0b1, 0b000, "mfadd.cf.mm">;
  def BOSC_AME_MFADD_HF_MM : BOSC_AME_MADD_NO_WIDEN<0b1, 0b0, 0b1, 0b001, "mfadd.hf.mm">;
  def BOSC_AME_MFADD_F_MM  : BOSC_AME_MADD_NO_WIDEN<0b1, 0b0, 0b1, 0b010, "mfadd.f.mm">;
  def BOSC_AME_MFADD_D_MM  : BOSC_AME_MADD_NO_WIDEN<0b1, 0b0, 0b1, 0b011, "mfadd.d.mm">;
}

class BOSC_AME_MADD_DOUBLE_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                                  bits<3> eew_val, string opcodestr>
    : RVInstBOSCAME32<(outs AccReg:$md),
                      (ins AccReg:$ms1, AccReg:$ms2),
                      opcodestr, "$md, $ms1, $ms2"> {
  let funct6 = 0b001001;
  let fp     = fp_val;
  let sa     = sa_val;
  let sn     = sn_val;
  let eew    = eew_val;
  let ma     = 0b0;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // uint 4 8 16 32 , output double-widen
  def BOSC_AME_MWADDU_MM    : BOSC_AME_MADD_DOUBLE_WIDEN<0b0, 0, 0, 0b100, "mwaddu.mm">;
  def BOSC_AME_MWADDU_HB_MM : BOSC_AME_MADD_DOUBLE_WIDEN<0b0, 0, 0, 0b111, "mwaddu.hb.mm">;
  def BOSC_AME_MWADDU_B_MM  : BOSC_AME_MADD_DOUBLE_WIDEN<0b0, 0, 0, 0b000, "mwaddu.b.mm">;
  def BOSC_AME_MWADDU_H_MM  : BOSC_AME_MADD_DOUBLE_WIDEN<0b0, 0, 0, 0b001, "mwaddu.h.mm">;
  def BOSC_AME_MWADDU_W_MM  : BOSC_AME_MADD_DOUBLE_WIDEN<0b0, 0, 0, 0b010, "mwaddu.w.mm">;
  // int 4 8 16 32 , output double-widen
  def BOSC_AME_MWADD_MM    : BOSC_AME_MADD_DOUBLE_WIDEN<0b0, 0, 0b1, 0b100, "mwadd.mm">;
  def BOSC_AME_MWADD_HB_MM : BOSC_AME_MADD_DOUBLE_WIDEN<0b0, 0, 0b1, 0b111, "mwadd.hb.mm">;
  def BOSC_AME_MWADD_B_MM  : BOSC_AME_MADD_DOUBLE_WIDEN<0b0, 0, 0b1, 0b000, "mwadd.b.mm">;
  def BOSC_AME_MWADD_H_MM  : BOSC_AME_MADD_DOUBLE_WIDEN<0b0, 0, 0b1, 0b001, "mwadd.h.mm">;
  def BOSC_AME_MWADD_W_MM  : BOSC_AME_MADD_DOUBLE_WIDEN<0b0, 0, 0b1, 0b010, "mwadd.w.mm">;
  // float point 8 16 32 , output double-widen
  def BOSC_AME_MFWADD_MM    : BOSC_AME_MADD_DOUBLE_WIDEN<0b1, 0b0, 0b1, 0b100, "mfwadd.mm">;
  def BOSC_AME_MFWADD_CF_MM : BOSC_AME_MADD_DOUBLE_WIDEN<0b1, 0b0, 0b1, 0b000, "mfwadd.cf.mm">;
  def BOSC_AME_MFWADD_HF_MM : BOSC_AME_MADD_DOUBLE_WIDEN<0b1, 0b0, 0b1, 0b001, "mfwadd.hf.mm">;
  def BOSC_AME_MFWADD_F_MM  : BOSC_AME_MADD_DOUBLE_WIDEN<0b1, 0b0, 0b1, 0b010, "mfwadd.f.mm">;
}

class BOSC_AME_MSUB_NO_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                                  bits<3> eew_val, string opcodestr>
    : RVInstBOSCAME32<(outs AccReg:$md),
                      (ins AccReg:$ms1, AccReg:$ms2),
                      opcodestr, "$md, $ms1, $ms2"> {
  let funct6 = 0b001010;
  let fp     = fp_val;
  let sa     = sa_val;
  let sn     = sn_val;
  let eew    = eew_val;
  let ma     = 0b0;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {

  def BOSC_AME_MSUBU_MM    : BOSC_AME_MSUB_NO_WIDEN<0, 0, 0, 0b100, "msubu.mm">;
  def BOSC_AME_MSUBU_HB_MM : BOSC_AME_MSUB_NO_WIDEN<0, 0, 0, 0b111, "msubu.hb.mm">;
  def BOSC_AME_MSUBU_B_MM  : BOSC_AME_MSUB_NO_WIDEN<0, 0, 0, 0b000, "msubu.b.mm">;
  def BOSC_AME_MSUBU_H_MM  : BOSC_AME_MSUB_NO_WIDEN<0, 0, 0, 0b001, "msubu.h.mm">;
  def BOSC_AME_MSUBU_W_MM  : BOSC_AME_MSUB_NO_WIDEN<0, 0, 0, 0b010, "msubu.w.mm">;
  def BOSC_AME_MSUBU_DW_MM : BOSC_AME_MSUB_NO_WIDEN<0, 0, 0, 0b011, "msubu.dw.mm">;

  def BOSC_AME_MSSUBU_MM    : BOSC_AME_MSUB_NO_WIDEN<0, 1, 0, 0b100, "mssubu.mm">;
  def BOSC_AME_MSSUBU_HB_MM : BOSC_AME_MSUB_NO_WIDEN<0, 1, 0, 0b111, "mssubu.hb.mm">;
  def BOSC_AME_MSSUBU_B_MM  : BOSC_AME_MSUB_NO_WIDEN<0, 1, 0, 0b000, "mssubu.b.mm">;
  def BOSC_AME_MSSUBU_H_MM  : BOSC_AME_MSUB_NO_WIDEN<0, 1, 0, 0b001, "mssubu.h.mm">;
  def BOSC_AME_MSSUBU_W_MM  : BOSC_AME_MSUB_NO_WIDEN<0, 1, 0, 0b010, "mssubu.w.mm">;
  def BOSC_AME_MSSUBU_DW_MM : BOSC_AME_MSUB_NO_WIDEN<0, 1, 0, 0b011, "mssubu.dw.mm">;

  def BOSC_AME_MSUB_MM    : BOSC_AME_MSUB_NO_WIDEN<0, 0, 1, 0b100, "msub.mm">;
  def BOSC_AME_MSUB_HB_MM : BOSC_AME_MSUB_NO_WIDEN<0, 0, 1, 0b111, "msub.hb.mm">;
  def BOSC_AME_MSUB_B_MM  : BOSC_AME_MSUB_NO_WIDEN<0, 0, 1, 0b000, "msub.b.mm">;
  def BOSC_AME_MSUB_H_MM  : BOSC_AME_MSUB_NO_WIDEN<0, 0, 1, 0b001, "msub.h.mm">;
  def BOSC_AME_MSUB_W_MM  : BOSC_AME_MSUB_NO_WIDEN<0, 0, 1, 0b010, "msub.w.mm">;
  def BOSC_AME_MSUB_DW_MM : BOSC_AME_MSUB_NO_WIDEN<0, 0, 1, 0b011, "msub.dw.mm">;

  def BOSC_AME_MSSUB_MM    : BOSC_AME_MSUB_NO_WIDEN<0, 1, 1, 0b100, "mssub.mm">;
  def BOSC_AME_MSSUB_HB_MM : BOSC_AME_MSUB_NO_WIDEN<0, 1, 1, 0b111, "mssub.hb.mm">;
  def BOSC_AME_MSSUB_B_MM  : BOSC_AME_MSUB_NO_WIDEN<0, 1, 1, 0b000, "mssub.b.mm">;
  def BOSC_AME_MSSUB_H_MM  : BOSC_AME_MSUB_NO_WIDEN<0, 1, 1, 0b001, "mssub.h.mm">;
  def BOSC_AME_MSSUB_W_MM  : BOSC_AME_MSUB_NO_WIDEN<0, 1, 1, 0b010, "mssub.w.mm">;
  def BOSC_AME_MSSUB_DW_MM : BOSC_AME_MSUB_NO_WIDEN<0, 1, 1, 0b011, "mssub.dw.mm">;

  def BOSC_AME_MFSUB_MM    : BOSC_AME_MSUB_NO_WIDEN<1, 0, 1, 0b100, "mfsub.mm">;
  def BOSC_AME_MFSUB_CF_MM : BOSC_AME_MSUB_NO_WIDEN<1, 0, 1, 0b000, "mfsub.cf.mm">;
  def BOSC_AME_MFSUB_HF_MM : BOSC_AME_MSUB_NO_WIDEN<1, 0, 1, 0b001, "mfsub.hf.mm">;
  def BOSC_AME_MFSUB_F_MM  : BOSC_AME_MSUB_NO_WIDEN<1, 0, 1, 0b010, "mfsub.f.mm">;
  def BOSC_AME_MFSUB_D_MM  : BOSC_AME_MSUB_NO_WIDEN<1, 0, 1, 0b011, "mfsub.d.mm">;
}

class BOSC_AME_MSUB_DOUBLE_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                                bits<3> eew_val, string opcodestr>
    : RVInstBOSCAME32<(outs AccReg:$md),
                      (ins AccReg:$ms1, AccReg:$ms2),
                      opcodestr, "$md, $ms1, $ms2"> {
  let funct6 = 0b001011;
  let fp     = fp_val;
  let sa     = sa_val;
  let sn     = sn_val;
  let eew    = eew_val;
  let ma     = 0b0;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {

  def BOSC_AME_MWSUBU_MM    : BOSC_AME_MSUB_DOUBLE_WIDEN<0, 0, 0, 0b100, "mwsubu.mm">;
  def BOSC_AME_MWSUBU_HB_MM : BOSC_AME_MSUB_DOUBLE_WIDEN<0, 0, 0, 0b111, "mwsubu.hb.mm">;
  def BOSC_AME_MWSUBU_B_MM  : BOSC_AME_MSUB_DOUBLE_WIDEN<0, 0, 0, 0b000, "mwsubu.b.mm">;
  def BOSC_AME_MWSUBU_H_MM  : BOSC_AME_MSUB_DOUBLE_WIDEN<0, 0, 0, 0b001, "mwsubu.h.mm">;
  def BOSC_AME_MWSUBU_W_MM  : BOSC_AME_MSUB_DOUBLE_WIDEN<0, 0, 0, 0b010, "mwsubu.w.mm">;

  def BOSC_AME_MWSUB_MM    : BOSC_AME_MSUB_DOUBLE_WIDEN<0, 0, 1, 0b100, "mwsub.mm">;
  def BOSC_AME_MWSUB_HB_MM : BOSC_AME_MSUB_DOUBLE_WIDEN<0, 0, 1, 0b111, "mwsub.hb.mm">;
  def BOSC_AME_MWSUB_B_MM  : BOSC_AME_MSUB_DOUBLE_WIDEN<0, 0, 1, 0b000, "mwsub.b.mm">;
  def BOSC_AME_MWSUB_H_MM  : BOSC_AME_MSUB_DOUBLE_WIDEN<0, 0, 1, 0b001, "mwsub.h.mm">;
  def BOSC_AME_MWSUB_W_MM  : BOSC_AME_MSUB_DOUBLE_WIDEN<0, 0, 1, 0b010, "mwsub.w.mm">;

  def BOSC_AME_MFWSUB_MM    : BOSC_AME_MSUB_DOUBLE_WIDEN<1, 0, 1, 0b100, "mfwsub.mm">;
  def BOSC_AME_MFWSUB_CF_MM : BOSC_AME_MSUB_DOUBLE_WIDEN<1, 0, 1, 0b000, "mfwsub.cf.mm">;
  def BOSC_AME_MFWSUB_HF_MM : BOSC_AME_MSUB_DOUBLE_WIDEN<1, 0, 1, 0b001, "mfwsub.hf.mm">;
  def BOSC_AME_MFWSUB_F_MM  : BOSC_AME_MSUB_DOUBLE_WIDEN<1, 0, 1, 0b010, "mfwsub.f.mm">;
}

class BOSC_AME_MMINMAX_NO_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                                bits<3> eew_val, string opcodestr>
    : RVInstBOSCAME32<(outs AccReg:$md),
                      (ins AccReg:$ms1, AccReg:$ms2),
                      opcodestr, "$md, $ms1, $ms2"> {
  let funct6 = 0b001100;
  let fp     = fp_val;
  let sa     = sa_val;
  let sn     = sn_val;
  let eew    = eew_val;
  let ma     = 0b0;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {

  def BOSC_AME_MMINU_MM    : BOSC_AME_MMINMAX_NO_WIDEN<0, 0, 0, 0b100, "mminu.mm">;
  def BOSC_AME_MMINU_HB_MM : BOSC_AME_MMINMAX_NO_WIDEN<0, 0, 0, 0b111, "mminu.hb.mm">;
  def BOSC_AME_MMINU_B_MM  : BOSC_AME_MMINMAX_NO_WIDEN<0, 0, 0, 0b000, "mminu.b.mm">;
  def BOSC_AME_MMINU_H_MM  : BOSC_AME_MMINMAX_NO_WIDEN<0, 0, 0, 0b001, "mminu.h.mm">;
  def BOSC_AME_MMINU_W_MM  : BOSC_AME_MMINMAX_NO_WIDEN<0, 0, 0, 0b010, "mminu.w.mm">;
  def BOSC_AME_MMINU_DW_MM : BOSC_AME_MMINMAX_NO_WIDEN<0, 0, 0, 0b011, "mminu.dw.mm">;

  def BOSC_AME_MMAXU_MM    : BOSC_AME_MMINMAX_NO_WIDEN<0, 1, 0, 0b100, "mmaxu.mm">;
  def BOSC_AME_MMAXU_HB_MM : BOSC_AME_MMINMAX_NO_WIDEN<0, 1, 0, 0b111, "mmaxu.hb.mm">;
  def BOSC_AME_MMAXU_B_MM  : BOSC_AME_MMINMAX_NO_WIDEN<0, 1, 0, 0b000, "mmaxu.b.mm">;
  def BOSC_AME_MMAXU_H_MM  : BOSC_AME_MMINMAX_NO_WIDEN<0, 1, 0, 0b001, "mmaxu.h.mm">;
  def BOSC_AME_MMAXU_W_MM  : BOSC_AME_MMINMAX_NO_WIDEN<0, 1, 0, 0b010, "mmaxu.w.mm">;
  def BOSC_AME_MMAXU_DW_MM : BOSC_AME_MMINMAX_NO_WIDEN<0, 1, 0, 0b011, "mmaxu.dw.mm">;

  def BOSC_AME_MMIN_MM    : BOSC_AME_MMINMAX_NO_WIDEN<0, 0, 1, 0b100, "mmin.mm">;
  def BOSC_AME_MMIN_HB_MM : BOSC_AME_MMINMAX_NO_WIDEN<0, 0, 1, 0b111, "mmin.hb.mm">;
  def BOSC_AME_MMIN_B_MM  : BOSC_AME_MMINMAX_NO_WIDEN<0, 0, 1, 0b000, "mmin.b.mm">;
  def BOSC_AME_MMIN_H_MM  : BOSC_AME_MMINMAX_NO_WIDEN<0, 0, 1, 0b001, "mmin.h.mm">;
  def BOSC_AME_MMIN_W_MM  : BOSC_AME_MMINMAX_NO_WIDEN<0, 0, 1, 0b010, "mmin.w.mm">;
  def BOSC_AME_MMIN_DW_MM : BOSC_AME_MMINMAX_NO_WIDEN<0, 0, 1, 0b011, "mmin.dw.mm">;

  def BOSC_AME_MMAX_MM    : BOSC_AME_MMINMAX_NO_WIDEN<0, 1, 1, 0b100, "mmax.mm">;
  def BOSC_AME_MMAX_HB_MM : BOSC_AME_MMINMAX_NO_WIDEN<0, 1, 1, 0b111, "mmax.hb.mm">;
  def BOSC_AME_MMAX_B_MM  : BOSC_AME_MMINMAX_NO_WIDEN<0, 1, 1, 0b000, "mmax.b.mm">;
  def BOSC_AME_MMAX_H_MM  : BOSC_AME_MMINMAX_NO_WIDEN<0, 1, 1, 0b001, "mmax.h.mm">;
  def BOSC_AME_MMAX_W_MM  : BOSC_AME_MMINMAX_NO_WIDEN<0, 1, 1, 0b010, "mmax.w.mm">;
  def BOSC_AME_MMAX_DW_MM : BOSC_AME_MMINMAX_NO_WIDEN<0, 1, 1, 0b011, "mmax.dw.mm">;

  def BOSC_AME_MFMIN_MM    : BOSC_AME_MMINMAX_NO_WIDEN<1, 0, 1, 0b100, "mfmin.mm">;
  def BOSC_AME_MFMIN_CF_MM : BOSC_AME_MMINMAX_NO_WIDEN<1, 0, 1, 0b000, "mfmin.cf.mm">;
  def BOSC_AME_MFMIN_HF_MM : BOSC_AME_MMINMAX_NO_WIDEN<1, 0, 1, 0b001, "mfmin.hf.mm">;
  def BOSC_AME_MFMIN_F_MM  : BOSC_AME_MMINMAX_NO_WIDEN<1, 0, 1, 0b010, "mfmin.f.mm">;
  def BOSC_AME_MFMIN_D_MM  : BOSC_AME_MMINMAX_NO_WIDEN<1, 0, 1, 0b011, "mfmin.d.mm">;

  def BOSC_AME_MFMAX_MM    : BOSC_AME_MMINMAX_NO_WIDEN<1, 1, 1, 0b100, "mfmax.mm">;
  def BOSC_AME_MFMAX_CF_MM : BOSC_AME_MMINMAX_NO_WIDEN<1, 1, 1, 0b000, "mfmax.cf.mm">;
  def BOSC_AME_MFMAX_HF_MM : BOSC_AME_MMINMAX_NO_WIDEN<1, 1, 1, 0b001, "mfmax.hf.mm">;
  def BOSC_AME_MFMAX_F_MM  : BOSC_AME_MMINMAX_NO_WIDEN<1, 1, 1, 0b010, "mfmax.f.mm">;
  def BOSC_AME_MFMAX_D_MM  : BOSC_AME_MMINMAX_NO_WIDEN<1, 1, 1, 0b011, "mfmax.d.mm">;
}

class BOSC_AME_MMUL_NO_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                                  bits<3> eew_val, string opcodestr>
    : RVInstBOSCAME32<(outs AccReg:$md),
                      (ins AccReg:$ms1, AccReg:$ms2),
                      opcodestr, "$md, $ms1, $ms2"> {
  let funct6 = 0b001101;
  let fp     = fp_val;
  let sa     = sa_val;
  let sn     = sn_val;
  let eew    = eew_val;
  let ma     = 0b0;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {

  def BOSC_AME_MSMULU_MM    : BOSC_AME_MMUL_NO_WIDEN<0, 1, 0, 0b100, "msmulu.mm">;
  def BOSC_AME_MSMULU_HB_MM : BOSC_AME_MMUL_NO_WIDEN<0, 1, 0, 0b111, "msmulu.hb.mm">;
  def BOSC_AME_MSMULU_B_MM  : BOSC_AME_MMUL_NO_WIDEN<0, 1, 0, 0b000, "msmulu.b.mm">;
  def BOSC_AME_MSMULU_H_MM  : BOSC_AME_MMUL_NO_WIDEN<0, 1, 0, 0b001, "msmulu.h.mm">;
  def BOSC_AME_MSMULU_W_MM  : BOSC_AME_MMUL_NO_WIDEN<0, 1, 0, 0b010, "msmulu.w.mm">;
  def BOSC_AME_MSMULU_DW_MM : BOSC_AME_MMUL_NO_WIDEN<0, 1, 0, 0b011, "msmulu.dw.mm">;

  def BOSC_AME_MMUL_MM    : BOSC_AME_MMUL_NO_WIDEN<0, 0, 1, 0b100, "mmul.mm">;
  def BOSC_AME_MMUL_HB_MM : BOSC_AME_MMUL_NO_WIDEN<0, 0, 1, 0b111, "mmul.hb.mm">;
  def BOSC_AME_MMUL_B_MM  : BOSC_AME_MMUL_NO_WIDEN<0, 0, 1, 0b000, "mmul.b.mm">;
  def BOSC_AME_MMUL_H_MM  : BOSC_AME_MMUL_NO_WIDEN<0, 0, 1, 0b001, "mmul.h.mm">;
  def BOSC_AME_MMUL_W_MM  : BOSC_AME_MMUL_NO_WIDEN<0, 0, 1, 0b010, "mmul.w.mm">;
  def BOSC_AME_MMUL_DW_MM : BOSC_AME_MMUL_NO_WIDEN<0, 0, 1, 0b011, "mmul.dw.mm">;

  def BOSC_AME_MSMUL_MM    : BOSC_AME_MMUL_NO_WIDEN<0, 1, 1, 0b100, "msmul.mm">;
  def BOSC_AME_MSMUL_HB_MM : BOSC_AME_MMUL_NO_WIDEN<0, 1, 1, 0b111, "msmul.hb.mm">;
  def BOSC_AME_MSMUL_B_MM  : BOSC_AME_MMUL_NO_WIDEN<0, 1, 1, 0b000, "msmul.b.mm">;
  def BOSC_AME_MSMUL_H_MM  : BOSC_AME_MMUL_NO_WIDEN<0, 1, 1, 0b001, "msmul.h.mm">;
  def BOSC_AME_MSMUL_W_MM  : BOSC_AME_MMUL_NO_WIDEN<0, 1, 1, 0b010, "msmul.w.mm">;
  def BOSC_AME_MSMUL_DW_MM : BOSC_AME_MMUL_NO_WIDEN<0, 1, 1, 0b011, "msmul.dw.mm">;

  def BOSC_AME_MFMUL_MM    : BOSC_AME_MMUL_NO_WIDEN<1, 0, 1, 0b100, "mfmul.mm">;
  def BOSC_AME_MFMUL_CF_MM : BOSC_AME_MMUL_NO_WIDEN<1, 0, 1, 0b000, "mfmul.cf.mm">;
  def BOSC_AME_MFMUL_HF_MM : BOSC_AME_MMUL_NO_WIDEN<1, 0, 1, 0b001, "mfmul.hf.mm">;
  def BOSC_AME_MFMUL_F_MM  : BOSC_AME_MMUL_NO_WIDEN<1, 0, 1, 0b010, "mfmul.f.mm">;
  def BOSC_AME_MFMUL_D_MM  : BOSC_AME_MMUL_NO_WIDEN<1, 0, 1, 0b011, "mfmul.d.mm">;
}

class BOSC_AME_MMULH_DIV_NO_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                                  bits<3> eew_val, string opcodestr>
    : RVInstBOSCAME32<(outs AccReg:$md),
                      (ins AccReg:$ms1, AccReg:$ms2),
                      opcodestr, "$md, $ms1, $ms2"> {
  let funct6 = 0b001110;
  let fp     = fp_val;
  let sa     = sa_val;
  let sn     = sn_val;
  let eew    = eew_val;
  let ma     = 0b0;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {

  def BOSC_AME_MMULHU_MM    : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 0, 0, 0b100, "mmulhu.mm">;
  def BOSC_AME_MMULHU_HB_MM : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 0, 0, 0b111, "mmulhu.hb.mm">;
  def BOSC_AME_MMULHU_B_MM  : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 0, 0, 0b000, "mmulhu.b.mm">;
  def BOSC_AME_MMULHU_H_MM  : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 0, 0, 0b001, "mmulhu.h.mm">;
  def BOSC_AME_MMULHU_W_MM  : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 0, 0, 0b010, "mmulhu.w.mm">;
  def BOSC_AME_MMULHU_DW_MM : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 0, 0, 0b011, "mmulhu.dw.mm">;

  def BOSC_AME_MMULH_MM    : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 0, 1, 0b100, "mmulh.mm">;
  def BOSC_AME_MMULH_HB_MM : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 0, 1, 0b111, "mmulh.hb.mm">;
  def BOSC_AME_MMULH_B_MM  : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 0, 1, 0b000, "mmulh.b.mm">;
  def BOSC_AME_MMULH_H_MM  : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 0, 1, 0b001, "mmulh.h.mm">;
  def BOSC_AME_MMULH_W_MM  : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 0, 1, 0b010, "mmulh.w.mm">;
  def BOSC_AME_MMULH_DW_MM : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 0, 1, 0b011, "mmulh.dw.mm">;

  def BOSC_AME_MMULHSU_MM    : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 1, 0, 0b100, "mmulhsu.mm">;
  def BOSC_AME_MMULHSU_HB_MM : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 1, 0, 0b111, "mmulhsu.hb.mm">;
  def BOSC_AME_MMULHSU_B_MM  : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 1, 0, 0b000, "mmulhsu.b.mm">;
  def BOSC_AME_MMULHSU_H_MM  : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 1, 0, 0b001, "mmulhsu.h.mm">;
  def BOSC_AME_MMULHSU_W_MM  : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 1, 0, 0b010, "mmulhsu.w.mm">;
  def BOSC_AME_MMULHSU_DW_MM : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 1, 0, 0b011, "mmulhsu.dw.mm">;

  def BOSC_AME_MSMULSU_MM    : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 1, 1, 0b100, "msmulsu.mm">;
  def BOSC_AME_MSMULSU_HB_MM : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 1, 1, 0b111, "msmulsu.hb.mm">;
  def BOSC_AME_MSMULSU_B_MM  : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 1, 1, 0b000, "msmulsu.b.mm">;
  def BOSC_AME_MSMULSU_H_MM  : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 1, 1, 0b001, "msmulsu.h.mm">;
  def BOSC_AME_MSMULSU_W_MM  : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 1, 1, 0b010, "msmulsu.w.mm">;
  def BOSC_AME_MSMULSU_DW_MM : BOSC_AME_MMULH_DIV_NO_WIDEN<0, 1, 1, 0b011, "msmulsu.dw.mm">;

  def BOSC_AME_MFDIV_MM    : BOSC_AME_MMULH_DIV_NO_WIDEN<1, 0, 1, 0b100, "mfdiv.mm">;
  def BOSC_AME_MFDIV_CF_MM : BOSC_AME_MMULH_DIV_NO_WIDEN<1, 0, 1, 0b000, "mfdiv.cf.mm">;
  def BOSC_AME_MFDIV_HF_MM : BOSC_AME_MMULH_DIV_NO_WIDEN<1, 0, 1, 0b001, "mfdiv.hf.mm">;
  def BOSC_AME_MFDIV_F_MM  : BOSC_AME_MMULH_DIV_NO_WIDEN<1, 0, 1, 0b010, "mfdiv.f.mm">;
  def BOSC_AME_MFDIV_D_MM  : BOSC_AME_MMULH_DIV_NO_WIDEN<1, 0, 1, 0b011, "mfdiv.d.mm">;
}

class BOSC_AME_MMUL_DOUBLE_WIDEN<bit fp_val, bit sa_val, bit sn_val,
                                  bits<3> eew_val, string opcodestr>
    : RVInstBOSCAME32<(outs AccReg:$md),
                      (ins AccReg:$ms1, AccReg:$ms2),
                      opcodestr, "$md, $ms1, $ms2"> {
  let funct6 = 0b001111;
  let fp     = fp_val;
  let sa     = sa_val;
  let sn     = sn_val;
  let eew    = eew_val;
  let ma     = 0b0;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {

  def BOSC_AME_MWMULU_MM    : BOSC_AME_MMUL_DOUBLE_WIDEN<0, 0, 0, 0b100, "mwmulu.mm">;
  def BOSC_AME_MWMULU_HB_MM : BOSC_AME_MMUL_DOUBLE_WIDEN<0, 0, 0, 0b111, "mwmulu.hb.mm">;
  def BOSC_AME_MWMULU_B_MM  : BOSC_AME_MMUL_DOUBLE_WIDEN<0, 0, 0, 0b000, "mwmulu.b.mm">;
  def BOSC_AME_MWMULU_H_MM  : BOSC_AME_MMUL_DOUBLE_WIDEN<0, 0, 0, 0b001, "mwmulu.h.mm">;
  def BOSC_AME_MWMULU_W_MM  : BOSC_AME_MMUL_DOUBLE_WIDEN<0, 0, 0, 0b010, "mwmulu.w.mm">;

  def BOSC_AME_MWMUL_MM    : BOSC_AME_MMUL_DOUBLE_WIDEN<0, 0, 1, 0b100, "mwmul.mm">;
  def BOSC_AME_MWMUL_HB_MM : BOSC_AME_MMUL_DOUBLE_WIDEN<0, 0, 1, 0b111, "mwmul.hb.mm">;
  def BOSC_AME_MWMUL_B_MM  : BOSC_AME_MMUL_DOUBLE_WIDEN<0, 0, 1, 0b000, "mwmul.b.mm">;
  def BOSC_AME_MWMUL_H_MM  : BOSC_AME_MMUL_DOUBLE_WIDEN<0, 0, 1, 0b001, "mwmul.h.mm">;
  def BOSC_AME_MWMUL_W_MM  : BOSC_AME_MMUL_DOUBLE_WIDEN<0, 0, 1, 0b010, "mwmul.w.mm">;

  def BOSC_AME_MWMULSU_MM    : BOSC_AME_MMUL_DOUBLE_WIDEN<0, 1, 1, 0b100, "mwmulsu.mm">;
  def BOSC_AME_MWMULSU_HB_MM : BOSC_AME_MMUL_DOUBLE_WIDEN<0, 1, 1, 0b111, "mwmulsu.hb.mm">;
  def BOSC_AME_MWMULSU_B_MM  : BOSC_AME_MMUL_DOUBLE_WIDEN<0, 1, 1, 0b000, "mwmulsu.b.mm">;
  def BOSC_AME_MWMULSU_H_MM  : BOSC_AME_MMUL_DOUBLE_WIDEN<0, 1, 1, 0b001, "mwmulsu.h.mm">;
  def BOSC_AME_MWMULSU_W_MM  : BOSC_AME_MMUL_DOUBLE_WIDEN<0, 1, 1, 0b010, "mwmulsu.w.mm">;

  def BOSC_AME_MFWMUL_MM    : BOSC_AME_MMUL_DOUBLE_WIDEN<1, 0, 1, 0b100, "mfwmul.mm">;
  def BOSC_AME_MFWMUL_CF_MM : BOSC_AME_MMUL_DOUBLE_WIDEN<1, 0, 1, 0b000, "mfwmul.cf.mm">;
  def BOSC_AME_MFWMUL_HF_MM : BOSC_AME_MMUL_DOUBLE_WIDEN<1, 0, 1, 0b001, "mfwmul.hf.mm">;
  def BOSC_AME_MFWMUL_F_MM  : BOSC_AME_MMUL_DOUBLE_WIDEN<1, 0, 1, 0b010, "mfwmul.f.mm">;
}

class BOSC_AME_LOGIC_NO_WIDEN<bit sa_val, bit sn_val, string opcodestr>
    : RVInstBOSCAME32<(outs AccReg:$md),
                      (ins AccReg:$ms1, AccReg:$ms2),
                      opcodestr, "$md, $ms1, $ms2"> {
  let funct6 = 0b010000;
  let fp     = 0b0;
  let sa     = sa_val;
  let sn     = sn_val;
  let eew    = 0b100;
  let ma     = 0b0;
  let opcode = 0b1110111;
}

class BOSC_AME_SQRT_NO_WIDEN<bits<3> eew_val, string opcodestr>
    : RVInstBOSCAME32<(outs AccReg:$md),
                      (ins AccReg:$ms1),
                      opcodestr, "$md, $ms1"> {
  let funct6 = 0b010000;
  let fp     = 0b1;
  let sa     = 0b0;
  let ms2    = 0b0000;
  let sn     = 0b1;
  let eew    = eew_val;
  let ma     = 0b0;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {

  def BOSC_AME_MAND_MM : BOSC_AME_LOGIC_NO_WIDEN<0, 0, "mand.mm">;
  def BOSC_AME_MOR_MM  : BOSC_AME_LOGIC_NO_WIDEN<1, 0, "mor.mm">;
  def BOSC_AME_MXOR_MM : BOSC_AME_LOGIC_NO_WIDEN<1, 1, "mxor.mm">;

  def BOSC_AME_MFSQRT_M     : BOSC_AME_SQRT_NO_WIDEN<0b100, "mfsqrt.m">;
  def BOSC_AME_MFSQRT_CF_M  : BOSC_AME_SQRT_NO_WIDEN<0b000, "mfsqrt.cf.m">;
  def BOSC_AME_MFSQRT_HF_M  : BOSC_AME_SQRT_NO_WIDEN<0b001, "mfsqrt.hf.m">;
  def BOSC_AME_MFSQRT_F_M   : BOSC_AME_SQRT_NO_WIDEN<0b010, "mfsqrt.f.m">;
  def BOSC_AME_MFSQRT_D_M   : BOSC_AME_SQRT_NO_WIDEN<0b011, "mfsqrt.d.m">;
}

class BOSC_AME_SHIFT_NO_WIDEN<bit sa_val, bit sn_val,
                              bits<3> eew_val, string opcodestr>
    : RVInstBOSCAME32<(outs AccReg:$md),
                      (ins AccReg:$ms1, AccReg:$ms2),
                      opcodestr, "$md, $ms1, $ms2"> {
  let funct6 = 0b010001;
  let fp     = 0b0;
  let sa     = sa_val;
  let sn     = sn_val;
  let eew    = eew_val;
  let ma     = 0b0;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {

  def BOSC_AME_MSLL_MM    : BOSC_AME_SHIFT_NO_WIDEN<0, 0, 0b100, "msll.mm">;
  def BOSC_AME_MSLL_HB_MM : BOSC_AME_SHIFT_NO_WIDEN<0, 0, 0b111, "msll.hb.mm">;
  def BOSC_AME_MSLL_B_MM  : BOSC_AME_SHIFT_NO_WIDEN<0, 0, 0b000, "msll.b.mm">;
  def BOSC_AME_MSLL_H_MM  : BOSC_AME_SHIFT_NO_WIDEN<0, 0, 0b001, "msll.h.mm">;
  def BOSC_AME_MSLL_W_MM  : BOSC_AME_SHIFT_NO_WIDEN<0, 0, 0b010, "msll.w.mm">;
  def BOSC_AME_MSLL_DW_MM : BOSC_AME_SHIFT_NO_WIDEN<0, 0, 0b011, "msll.dw.mm">;

  def BOSC_AME_MSRL_MM    : BOSC_AME_SHIFT_NO_WIDEN<1, 0, 0b100, "msrl.mm">;
  def BOSC_AME_MSRL_HB_MM : BOSC_AME_SHIFT_NO_WIDEN<1, 0, 0b111, "msrl.hb.mm">;
  def BOSC_AME_MSRL_B_MM  : BOSC_AME_SHIFT_NO_WIDEN<1, 0, 0b000, "msrl.b.mm">;
  def BOSC_AME_MSRL_H_MM  : BOSC_AME_SHIFT_NO_WIDEN<1, 0, 0b001, "msrl.h.mm">;
  def BOSC_AME_MSRL_W_MM  : BOSC_AME_SHIFT_NO_WIDEN<1, 0, 0b010, "msrl.w.mm">;
  def BOSC_AME_MSRL_DW_MM : BOSC_AME_SHIFT_NO_WIDEN<1, 0, 0b011, "msrl.dw.mm">;

  def BOSC_AME_MSRA_MM    : BOSC_AME_SHIFT_NO_WIDEN<1, 1, 0b100, "msra.mm">;
  def BOSC_AME_MSRA_HB_MM : BOSC_AME_SHIFT_NO_WIDEN<1, 1, 0b111, "msra.hb.mm">;
  def BOSC_AME_MSRA_B_MM  : BOSC_AME_SHIFT_NO_WIDEN<1, 1, 0b000, "msra.b.mm">;
  def BOSC_AME_MSRA_H_MM  : BOSC_AME_SHIFT_NO_WIDEN<1, 1, 0b001, "msra.h.mm">;
  def BOSC_AME_MSRA_W_MM  : BOSC_AME_SHIFT_NO_WIDEN<1, 1, 0b010, "msra.w.mm">;
  def BOSC_AME_MSRA_DW_MM : BOSC_AME_SHIFT_NO_WIDEN<1, 1, 0b011, "msra.dw.mm">;
}

class RVInstBOSCAMETypeConvert<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<6> funct6;
  bit     fd;   
  bits<3> f3;    
  bits<2> nw;
  bit     sn;    
  bits<4> ms1;
  bits<3> eew;   
  bit     ma;
  bits<4> md;
  bits<7> opcode = 0b1110111;

  let Inst{31-26} = funct6;
  let Inst{25}    = fd;
  let Inst{24-22} = f3;
  let Inst{21-20} = nw;
  let Inst{19}    = sn;
  let Inst{18-15} = ms1;
  let Inst{14-12} = eew;
  let Inst{11}    = ma;
  let Inst{10-7}  = md;
  let Inst{6-0} = 0b1110111;
}

class BOSC_AME_CVT_INT<bits<3> f3_val, bits<2> nw_val, bit sn_val,
                   bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMETypeConvert<(outs AccReg:$md),
                  (ins AccReg:$ms1),
                  opcodestr, "$md, $ms1"> {
  let funct6 = 0b011000;     
  let fd = 0b0;
  let f3 = f3_val;
  let nw = nw_val;        
  let sn = sn_val;        // (signed for integers, 0 for floating-point)
  let eew = eew_val;
  let ma = 0b0;       
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  //uint to int
  def BOSC_AME_MCVT_X_XU_M   : BOSC_AME_CVT_INT<0b000, 0b00, 0b1, 0b100, "mcvt.x.xu.m">;
  def BOSC_AME_MCVT_HB_UHB_M : BOSC_AME_CVT_INT<0b000, 0b00, 0b1, 0b111, "mcvt.hb.uhb.m">;
  def BOSC_AME_MCVT_B_UB_M   : BOSC_AME_CVT_INT<0b000, 0b00, 0b1, 0b000, "mcvt.b.ub.m">;
  def BOSC_AME_MCVT_H_UH_M   : BOSC_AME_CVT_INT<0b000, 0b00, 0b1, 0b001, "mcvt.h.uh.m">;
  def BOSC_AME_MCVT_W_UW_M   : BOSC_AME_CVT_INT<0b000, 0b00, 0b1, 0b010, "mcvt.w.uw.m">;
  def BOSC_AME_MCVT_DW_UDW_M : BOSC_AME_CVT_INT<0b000, 0b00, 0b1, 0b011, "mcvt.dw.udw.m">;
  //int to uint
  def BOSC_AME_MCVT_XU_X_M   : BOSC_AME_CVT_INT<0b001, 0b00, 0b1, 0b100, "mcvt.xu.x.m">;
  def BOSC_AME_MCVT_UHB_HB_M : BOSC_AME_CVT_INT<0b001, 0b00, 0b1, 0b111, "mcvt.uhb.hb.m">;
  def BOSC_AME_MCVT_UB_B_M   : BOSC_AME_CVT_INT<0b001, 0b00, 0b1, 0b000, "mcvt.ub.b.m">;
  def BOSC_AME_MCVT_UH_H_M   : BOSC_AME_CVT_INT<0b001, 0b00, 0b1, 0b001, "mcvt.uh.h.m">;
  def BOSC_AME_MCVT_UW_W_M   : BOSC_AME_CVT_INT<0b001, 0b00, 0b1, 0b010, "mcvt.uw.w.m">;
  def BOSC_AME_MCVT_UDW_DW_M : BOSC_AME_CVT_INT<0b001, 0b00, 0b1, 0b011, "mcvt.udw.dw.m">;
  //uint to (widen)uint
  def BOSC_AME_MWCVTU_XW_X_M : BOSC_AME_CVT_INT<0b000, 0b01, 0b0, 0b100, "mwcvtu.xw.x.m">;
  def BOSC_AME_MWCVTU_XQ_X_M : BOSC_AME_CVT_INT<0b001, 0b01, 0b0, 0b100, "mwcvtu.xq.x.m">;
  def BOSC_AME_MWCVTU_XO_X_M : BOSC_AME_CVT_INT<0b010, 0b01, 0b0, 0b100, "mwcvtu.xo.x.m">;
  def BOSC_AME_MWCVTU_B_HB_M : BOSC_AME_CVT_INT<0b000, 0b01, 0b0, 0b111, "mwcvtu.b.hb.m">;
  def BOSC_AME_MWCVTU_H_HB_M : BOSC_AME_CVT_INT<0b001, 0b01, 0b0, 0b111, "mwcvtu.h.hb.m">;
  def BOSC_AME_MWCVTU_W_HB_M : BOSC_AME_CVT_INT<0b010, 0b01, 0b0, 0b111, "mwcvtu.w.hb.m">;
  def BOSC_AME_MWCVTU_H_B_M  : BOSC_AME_CVT_INT<0b000, 0b01, 0b0, 0b000, "mwcvtu.h.b.m">;
  def BOSC_AME_MWCVTU_W_B_M  : BOSC_AME_CVT_INT<0b001, 0b01, 0b0, 0b000, "mwcvtu.w.b.m">;
  def BOSC_AME_MWCVTU_W_H_M  : BOSC_AME_CVT_INT<0b000, 0b01, 0b0, 0b001, "mwcvtu.w.h.m">;
  def BOSC_AME_MWCVTU_DW_W_M : BOSC_AME_CVT_INT<0b000, 0b01, 0b0, 0b010, "mwcvtu.dw.w.m">;
  //int to (widen)int
  def BOSC_AME_MWCVT_XW_X_M : BOSC_AME_CVT_INT<0b000, 0b01, 0b1, 0b100, "mwcvt.xw.x.m">;
  def BOSC_AME_MWCVT_XQ_X_M : BOSC_AME_CVT_INT<0b001, 0b01, 0b1, 0b100, "mwcvt.xq.x.m">;
  def BOSC_AME_MWCVT_XO_X_M : BOSC_AME_CVT_INT<0b010, 0b01, 0b1, 0b100, "mwcvt.xo.x.m">;
  def BOSC_AME_MWCVT_B_HB_M : BOSC_AME_CVT_INT<0b000, 0b01, 0b1, 0b111, "mwcvt.b.hb.m">;
  def BOSC_AME_MWCVT_H_HB_M : BOSC_AME_CVT_INT<0b001, 0b01, 0b1, 0b111, "mwcvt.h.hb.m">;
  def BOSC_AME_MWCVT_W_HB_M : BOSC_AME_CVT_INT<0b010, 0b01, 0b1, 0b111, "mwcvt.w.hb.m">;
  def BOSC_AME_MWCVT_H_B_M  : BOSC_AME_CVT_INT<0b000, 0b01, 0b1, 0b000, "mwcvt.h.b.m">;
  def BOSC_AME_MWCVT_W_B_M  : BOSC_AME_CVT_INT<0b001, 0b01, 0b1, 0b000, "mwcvt.w.b.m">;
  def BOSC_AME_MWCVT_W_H_M  : BOSC_AME_CVT_INT<0b000, 0b01, 0b1, 0b001, "mwcvt.w.h.m">;
  def BOSC_AME_MWCVT_DW_W_M : BOSC_AME_CVT_INT<0b000, 0b01, 0b1, 0b010, "mwcvt.dw.w.m">;
  //(widen)uint to uint
  def BOSC_AME_MNCVTU_X_XW_M : BOSC_AME_CVT_INT<0b000, 0b10, 0b0, 0b100, "mncvtu.x.xw.m">;
  def BOSC_AME_MNCVTU_X_XQ_M : BOSC_AME_CVT_INT<0b001, 0b10, 0b0, 0b100, "mncvtu.x.xq.m">;
  def BOSC_AME_MNCVTU_X_XO_M : BOSC_AME_CVT_INT<0b010, 0b10, 0b0, 0b100, "mncvtu.x.xo.m">;
  def BOSC_AME_MNCVTU_HB_B_M : BOSC_AME_CVT_INT<0b000, 0b10, 0b0, 0b000, "mncvtu.hb.b.m">;
  def BOSC_AME_MNCVTU_HB_H_M : BOSC_AME_CVT_INT<0b001, 0b10, 0b0, 0b001, "mncvtu.hb.h.m">;
  def BOSC_AME_MNCVTU_HB_W_M : BOSC_AME_CVT_INT<0b010, 0b10, 0b0, 0b010, "mncvtu.hb.w.m">;
  def BOSC_AME_MNCVTU_B_H_M  : BOSC_AME_CVT_INT<0b000, 0b10, 0b0, 0b001, "mncvtu.b.h.m">;
  def BOSC_AME_MNCVTU_B_W_M  : BOSC_AME_CVT_INT<0b001, 0b10, 0b0, 0b010, "mncvtu.b.w.m">;
  def BOSC_AME_MNCVTU_H_W_M  : BOSC_AME_CVT_INT<0b000, 0b10, 0b0, 0b010, "mncvtu.h.w.m">;
  def BOSC_AME_MNCVTU_W_DW_M : BOSC_AME_CVT_INT<0b000, 0b10, 0b0, 0b011, "mncvtu.w.dw.m">;
  //(widen)int to int
  def BOSC_AME_MNCVT_X_XW_M : BOSC_AME_CVT_INT<0b000, 0b10, 0b1, 0b100, "mncvt.x.xw.m">;
  def BOSC_AME_MNCVT_X_XQ_M : BOSC_AME_CVT_INT<0b001, 0b10, 0b1, 0b100, "mncvt.x.xq.m">;
  def BOSC_AME_MNCVT_X_XO_M : BOSC_AME_CVT_INT<0b010, 0b10, 0b1, 0b100, "mncvt.x.xo.m">;
  def BOSC_AME_MNCVT_HB_B_M : BOSC_AME_CVT_INT<0b000, 0b10, 0b1, 0b000, "mncvt.hb.b.m">;
  def BOSC_AME_MNCVT_HB_H_M : BOSC_AME_CVT_INT<0b001, 0b10, 0b1, 0b001, "mncvt.hb.h.m">;
  def BOSC_AME_MNCVT_HB_W_M : BOSC_AME_CVT_INT<0b010, 0b10, 0b1, 0b010, "mncvt.hb.w.m">;
  def BOSC_AME_MNCVT_B_H_M  : BOSC_AME_CVT_INT<0b000, 0b10, 0b1, 0b001, "mncvt.b.h.m">;
  def BOSC_AME_MNCVT_B_W_M  : BOSC_AME_CVT_INT<0b001, 0b10, 0b1, 0b010, "mncvt.b.w.m">;
  def BOSC_AME_MNCVT_H_W_M  : BOSC_AME_CVT_INT<0b000, 0b10, 0b1, 0b010, "mncvt.h.w.m">;
  def BOSC_AME_MNCVT_W_DW_M : BOSC_AME_CVT_INT<0b000, 0b10, 0b1, 0b011, "mncvt.w.dw.m">;
}

class BOSC_AME_CVT_FP<bit fd_val, bits<3> f3_val, bits<2> nw_val, bit sn_val,
                   bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMETypeConvert<(outs AccReg:$md),
                  (ins AccReg:$ms1),
                  opcodestr, "$md, $ms1"> {
  let funct6 = 0b011001;     
  let fd = fd_val;
  let f3 = f3_val;
  let nw = nw_val;        
  let sn = sn_val;        // (signed for integers, 0 for floating-point)
  let eew = eew_val;
  let ma = 0b0;       
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  //float to float(No widening)
  def BOSC_AME_MFCVT_BF_HF_M  : BOSC_AME_CVT_FP<0b1, 0b000, 0b00, 0b0, 0b001, "mfcvt.bf.hf.m">;
  def BOSC_AME_MFCVT_HF_BF_M  : BOSC_AME_CVT_FP<0b1, 0b000, 0b00, 0b1, 0b001, "mfcvt.hf.bf.m">;
  //float to float(widen)
  def BOSC_AME_MFWCVT_FW_F_M  : BOSC_AME_CVT_FP<0b1, 0b001, 0b01, 0b0, 0b100, "mfwcvt.fw.f.m">;
  def BOSC_AME_MFWCVT_HF_CF_M : BOSC_AME_CVT_FP<0b1, 0b001, 0b01, 0b0, 0b000, "mfwcvt.hf.cf.m">;
  def BOSC_AME_MFWCVT_F_HF_M  : BOSC_AME_CVT_FP<0b1, 0b001, 0b01, 0b0, 0b001, "mfwcvt.f.hf.m">;
  def BOSC_AME_MFWCVT_D_F_M   : BOSC_AME_CVT_FP<0b1, 0b001, 0b01, 0b0, 0b010, "mfwcvt.d.f.m">;
  //(widen)float to float
  def BOSC_AME_MFNCVT_F_FW_M  : BOSC_AME_CVT_FP<0b1, 0b001, 0b10, 0b0, 0b100, "mfncvt.f.fw.m">;
  def BOSC_AME_MFNCVT_CF_HF_M : BOSC_AME_CVT_FP<0b1, 0b001, 0b10, 0b0, 0b001, "mfncvt.cf.hf.m">;
  def BOSC_AME_MFNCVT_HF_F_M  : BOSC_AME_CVT_FP<0b1, 0b001, 0b10, 0b0, 0b010, "mfncvt.hf.f.m">;
  def BOSC_AME_MFNCVT_F_D_M   : BOSC_AME_CVT_FP<0b1, 0b001, 0b10, 0b0, 0b011, "mfncvt.f.d.m">;
  //uint to float
  def BOSC_AME_MFCVTU_F_X_M   : BOSC_AME_CVT_FP<0b1, 0b010, 0b00, 0b0, 0b100, "mfcvtu.f.x.m">;
  def BOSC_AME_MFCVTU_HF_H_M  : BOSC_AME_CVT_FP<0b1, 0b010, 0b00, 0b0, 0b001, "mfcvtu.hf.h.m">;
  def BOSC_AME_MFCVTU_F_W_M   : BOSC_AME_CVT_FP<0b1, 0b010, 0b00, 0b0, 0b010, "mfcvtu.f.w.m">;
  def BOSC_AME_MFCVTU_D_DW_M  : BOSC_AME_CVT_FP<0b1, 0b010, 0b00, 0b0, 0b011, "mfcvtu.d.dw.m">;
  //int to float
  def BOSC_AME_MFCVT_F_X_M    : BOSC_AME_CVT_FP<0b1, 0b010, 0b00, 0b1, 0b100, "mfcvt.f.x.m">;
  def BOSC_AME_MFCVT_HF_H_M   : BOSC_AME_CVT_FP<0b1, 0b010, 0b00, 0b1, 0b001, "mfcvt.hf.h.m">;
  def BOSC_AME_MFCVT_F_W_M    : BOSC_AME_CVT_FP<0b1, 0b010, 0b00, 0b1, 0b010, "mfcvt.f.w.m">;
  def BOSC_AME_MFCVT_D_DW_M   : BOSC_AME_CVT_FP<0b1, 0b010, 0b00, 0b1, 0b011, "mfcvt.d.dw.m">;
  //uint to (widen)float
  def BOSC_AME_MFWCVTU_FW_X_M  : BOSC_AME_CVT_FP<0b1, 0b010, 0b01, 0b0, 0b100, "mfwcvtu.fw.x.m">;
  def BOSC_AME_MFWCVTU_FQ_X_M  : BOSC_AME_CVT_FP<0b1, 0b110, 0b01, 0b0, 0b100, "mfwcvtu.fq.x.m">;
  def BOSC_AME_MFWCVTU_FO_X_M  : BOSC_AME_CVT_FP<0b1, 0b111, 0b01, 0b0, 0b100, "mfwcvtu.fo.x.m">;
  def BOSC_AME_MFWCVTU_HF_HB_M : BOSC_AME_CVT_FP<0b1, 0b110, 0b01, 0b0, 0b111, "mfwcvtu.hf.hb.m">;
  def BOSC_AME_MFWCVTU_F_HB_M  : BOSC_AME_CVT_FP<0b1, 0b111, 0b01, 0b0, 0b111, "mfwcvtu.f.hb.m">;
  def BOSC_AME_MFWCVTU_HF_B_M  : BOSC_AME_CVT_FP<0b1, 0b010, 0b01, 0b0, 0b000, "mfwcvtu.hf.b.m">;
  def BOSC_AME_MFWCVTU_F_B_M   : BOSC_AME_CVT_FP<0b1, 0b110, 0b01, 0b0, 0b000, "mfwcvtu.f.b.m">;
  def BOSC_AME_MFWCVTU_F_H_M   : BOSC_AME_CVT_FP<0b1, 0b010, 0b01, 0b0, 0b001, "mfwcvtu.f.h.m">;
  def BOSC_AME_MFWCVTU_D_W_M   : BOSC_AME_CVT_FP<0b1, 0b010, 0b01, 0b0, 0b010, "mfwcvtu.d.w.m">;
  //int to (widen)float
  def BOSC_AME_MFWCVT_FW_X_M   : BOSC_AME_CVT_FP<0b1, 0b010, 0b01, 0b1, 0b100, "mfwcvt.fw.x.m">;
  def BOSC_AME_MFWCVT_FQ_X_M   : BOSC_AME_CVT_FP<0b1, 0b110, 0b01, 0b1, 0b100, "mfwcvt.fq.x.m">;
  def BOSC_AME_MFWCVT_FO_X_M   : BOSC_AME_CVT_FP<0b1, 0b111, 0b01, 0b1, 0b100, "mfwcvt.fo.x.m">;
  def BOSC_AME_MFWCVT_HF_HB_M  : BOSC_AME_CVT_FP<0b1, 0b110, 0b01, 0b1, 0b111, "mfwcvt.hf.hb.m">;
  def BOSC_AME_MFWCVT_F_HB_M   : BOSC_AME_CVT_FP<0b1, 0b111, 0b01, 0b1, 0b111, "mfwcvt.f.hb.m">;
  def BOSC_AME_MFWCVT_HF_B_M   : BOSC_AME_CVT_FP<0b1, 0b010, 0b01, 0b1, 0b000, "mfwcvt.hf.b.m">;
  def BOSC_AME_MFWCVT_F_B_M    : BOSC_AME_CVT_FP<0b1, 0b110, 0b01, 0b1, 0b000, "mfwcvt.f.b.m">;
  def BOSC_AME_MFWCVT_F_H_M    : BOSC_AME_CVT_FP<0b1, 0b010, 0b01, 0b1, 0b001, "mfwcvt.f.h.m">;
  def BOSC_AME_MFWCVT_D_W_M    : BOSC_AME_CVT_FP<0b1, 0b010, 0b01, 0b1, 0b010, "mfwcvt.d.w.m">;
  //(widen)uint to float
  def BOSC_AME_MFNCVTU_F_XW_M  : BOSC_AME_CVT_FP<0b1, 0b010, 0b10, 0b0, 0b100, "mfncvtu.f.xw.m">;
  def BOSC_AME_MFNCVTU_HF_W_M  : BOSC_AME_CVT_FP<0b1, 0b010, 0b10, 0b0, 0b010, "mfncvtu.hf.w.m">;
  def BOSC_AME_MFNCVTU_F_DW_M  : BOSC_AME_CVT_FP<0b1, 0b010, 0b10, 0b0, 0b011, "mfncvtu.f.dw.m">;
  //(widen)int to float
  def BOSC_AME_MFNCVT_F_XW_M   : BOSC_AME_CVT_FP<0b1, 0b010, 0b10, 0b1, 0b100, "mfncvt.f.xw.m">;
  def BOSC_AME_MFNCVT_HF_W_M   : BOSC_AME_CVT_FP<0b1, 0b010, 0b10, 0b1, 0b010, "mfncvt.hf.w.m">;
  def BOSC_AME_MFNCVT_F_DW_M   : BOSC_AME_CVT_FP<0b1, 0b010, 0b10, 0b1, 0b011, "mfncvt.f.dw.m">;
  //float to uint
  def BOSC_AME_MFCVTU_X_F_M    : BOSC_AME_CVT_FP<0b0, 0b010, 0b00, 0b0, 0b100, "mfcvtu.x.f.m">;
  def BOSC_AME_MFCVTU_H_HF_M   : BOSC_AME_CVT_FP<0b0, 0b010, 0b00, 0b0, 0b001, "mfcvtu.h.hf.m">;
  def BOSC_AME_MFCVTU_W_F_M    : BOSC_AME_CVT_FP<0b0, 0b010, 0b00, 0b0, 0b010, "mfcvtu.w.f.m">;
  def BOSC_AME_MFCVTU_DW_D_M   : BOSC_AME_CVT_FP<0b0, 0b010, 0b00, 0b0, 0b011, "mfcvtu.dw.d.m">;
  //float to int
  def BOSC_AME_MFCVT_X_F_M     : BOSC_AME_CVT_FP<0b0, 0b010, 0b00, 0b1, 0b100, "mfcvt.x.f.m">;
  def BOSC_AME_MFCVT_H_HF_M    : BOSC_AME_CVT_FP<0b0, 0b010, 0b00, 0b1, 0b001, "mfcvt.h.hf.m">;
  def BOSC_AME_MFCVT_W_F_M     : BOSC_AME_CVT_FP<0b0, 0b010, 0b00, 0b1, 0b010, "mfcvt.w.f.m">;
  def BOSC_AME_MFCVT_DW_D_M    : BOSC_AME_CVT_FP<0b0, 0b010, 0b00, 0b1, 0b011, "mfcvt.dw.d.m">;
  //float to (widen)uint
  def BOSC_AME_MFWCVTU_XW_F_M  : BOSC_AME_CVT_FP<0b0, 0b010, 0b01, 0b0, 0b100, "mfwcvtu.xw.f.m">;
  def BOSC_AME_MFWCVTU_W_HF_M  : BOSC_AME_CVT_FP<0b0, 0b010, 0b01, 0b0, 0b001, "mfwcvtu.w.hf.m">;
  def BOSC_AME_MFWCVTU_DW_F_M  : BOSC_AME_CVT_FP<0b0, 0b010, 0b01, 0b0, 0b010, "mfwcvtu.dw.f.m">;
  //float to (widen)int
  def BOSC_AME_MFWCVT_XW_F_M   : BOSC_AME_CVT_FP<0b0, 0b010, 0b01, 0b1, 0b100, "mfwcvt.xw.f.m">;
  def BOSC_AME_MFWCVT_W_HF_M   : BOSC_AME_CVT_FP<0b0, 0b010, 0b01, 0b1, 0b001, "mfwcvt.w.hf.m">;
  def BOSC_AME_MFWCVT_DW_F_M   : BOSC_AME_CVT_FP<0b0, 0b010, 0b01, 0b1, 0b010, "mfwcvt.dw.f.m">;
  //(widen)float to uint
  def BOSC_AME_MFNCVTU_X_FW_M  : BOSC_AME_CVT_FP<0b0, 0b010, 0b10, 0b0, 0b100, "mfncvtu.x.fw.m">;
  def BOSC_AME_MFNCVTU_X_FQ_M  : BOSC_AME_CVT_FP<0b0, 0b110, 0b10, 0b0, 0b100, "mfncvtu.x.fq.m">;
  def BOSC_AME_MFNCVTU_X_FO_M  : BOSC_AME_CVT_FP<0b0, 0b111, 0b10, 0b0, 0b100, "mfncvtu.x.fo.m">;
  def BOSC_AME_MFNCVTU_HB_HF_M : BOSC_AME_CVT_FP<0b0, 0b110, 0b10, 0b0, 0b001, "mfncvtu.hb.hf.m">;
  def BOSC_AME_MFNCVTU_HB_F_M  : BOSC_AME_CVT_FP<0b0, 0b111, 0b10, 0b0, 0b010, "mfncvtu.hb.f.m">;
  def BOSC_AME_MFNCVTU_B_HF_M  : BOSC_AME_CVT_FP<0b0, 0b010, 0b10, 0b0, 0b001, "mfncvtu.b.hf.m">;
  def BOSC_AME_MFNCVTU_B_F_M   : BOSC_AME_CVT_FP<0b0, 0b110, 0b10, 0b0, 0b010, "mfncvtu.b.f.m">;
  def BOSC_AME_MFNCVTU_H_F_M   : BOSC_AME_CVT_FP<0b0, 0b010, 0b10, 0b0, 0b010, "mfncvtu.h.f.m">;
  def BOSC_AME_MFNCVTU_W_D_M   : BOSC_AME_CVT_FP<0b0, 0b010, 0b10, 0b0, 0b011, "mfncvtu.w.d.m">;
  //(widen)float to int
  def BOSC_AME_MFNCVT_X_FW_M   : BOSC_AME_CVT_FP<0b0, 0b010, 0b10, 0b1, 0b100, "mfncvt.x.fw.m">;
  def BOSC_AME_MFNCVT_X_FQ_M   : BOSC_AME_CVT_FP<0b0, 0b110, 0b10, 0b1, 0b100, "mfncvt.x.fq.m">;
  def BOSC_AME_MFNCVT_X_FO_M   : BOSC_AME_CVT_FP<0b0, 0b111, 0b10, 0b1, 0b100, "mfncvt.x.fo.m">;
  def BOSC_AME_MFNCVT_HB_HF_M  : BOSC_AME_CVT_FP<0b0, 0b110, 0b10, 0b1, 0b001, "mfncvt.hb.hf.m">;
  def BOSC_AME_MFNCVT_HB_F_M   : BOSC_AME_CVT_FP<0b0, 0b111, 0b10, 0b1, 0b010, "mfncvt.hb.f.m">;
  def BOSC_AME_MFNCVT_B_HF_M   : BOSC_AME_CVT_FP<0b0, 0b010, 0b10, 0b1, 0b001, "mfncvt.b.hf.m">;
  def BOSC_AME_MFNCVT_B_F_M    : BOSC_AME_CVT_FP<0b0, 0b110, 0b10, 0b1, 0b010, "mfncvt.b.f.m">;
  def BOSC_AME_MFNCVT_H_F_M    : BOSC_AME_CVT_FP<0b0, 0b010, 0b10, 0b1, 0b010, "mfncvt.h.f.m">;
  def BOSC_AME_MFNCVT_W_D_M    : BOSC_AME_CVT_FP<0b0, 0b010, 0b10, 0b1, 0b011, "mfncvt.w.d.m">;
}

//===----------------------------------------------------------------------===//
// BOSC AME Configuration Instructions
//===----------------------------------------------------------------------===//
// Configuration instruction format (32-bit):
// Configuration Immediate Instructions:
// | 31:26  | 25 | 24:15 | 14:12  | 11:7 | 6:0    |
// | funct6 | im | imm10 | funct3 | rd   | OP-M32 |
// Configuration Instructions:
// | 31:26  | 25 | 24:20 | 19:15 | 14:12  | 11:7 | 6:0    |
// | funct6 | im | 00000 | rs1   | funct3 | rd   | OP-M32 |
//===----------------------------------------------------------------------===//

class RVInstBOSCAMEConfig32<bits<6> funct6_val, bits<3> funct3_val, string opcodestr>
    : RVInst<(outs GPR:$rd), (ins GPR:$rs1),
               opcodestr, "$rd, $rs1", [], InstFormatOther> {
  bits<5> rs1;
  bits<5> rd;

  let Inst{6-0} = 0b1110111;
  let Inst{11-7} = rd;
  let Inst{14-12} = funct3_val;
  let Inst{19-15} = rs1;
  let Inst{24-20} = 0b00000;
  let Inst{25}    = 0b0;  // 0 for register source
  let Inst{31-26} = funct6_val;  // To be defined in subclasses
}

class RVInstBOSCAMEConfigImm32<bits<6> funct6_val, bits<3> funct3_val, string opcodestr>
    : RVInst<(outs GPR:$rd), (ins uimm10:$imm),
               opcodestr, "$rd, $imm", [], InstFormatOther> {
  bits<5> rd;
  bits<10> imm;    // 10-bit immediate

  let Inst{6-0} = 0b1110111;
  let Inst{11-7} = rd;
  let Inst{14-12} = funct3_val;
  let Inst{24-15} = imm;
  let Inst{25}    = 0b1;  // 1 for immediate source
  let Inst{31-26} = funct6_val;  // To be defined in subclasses
}

class RVInstBOSCAMEConfigSew<bits<5> field_val, string opcodestr>
    : RVInst<(outs GPR:$rd), (ins uimm5:$rs2),
               opcodestr, "$rd, $rs2", [], InstFormatOther> {
  bits<5> rs2;
  bits<5> rd;

  let Inst{6-0} = 0b1110111;
  let Inst{11-7} = rd;
  let Inst{14-12} = 0b110;
  let Inst{19-15} = field_val;
  let Inst{24-20} = rs2;
  let Inst{25}    = 0b1;  // 1 for register source
  let Inst{31-26} = 0b000000;  
}

class RVInstBOSCAMEConfigSpi<bits<6> funct6_val, string opcodestr>
    : RVInst<(outs GPR:$rd), (ins uimm5:$imm),
               opcodestr, "$rd, $imm", [], InstFormatOther> {
  bits<5> imm;
  bits<5> rd;

  let Inst{6-0} = 0b1110111;
  let Inst{11-7} = rd;
  let Inst{14-12} = 0b111;
  let Inst{19-15} = imm;
  let Inst{24-20} = 0b00000;
  let Inst{25}    = 0b1;  // 1 for register source
  let Inst{31-26} = funct6_val;  
}

class RVInstBOSCAMEConfigReg2<bits<6> funct6_val, bits<3> funct3_val, string opcodestr>
    : RVInst<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
               opcodestr, "$rd, $rs1, $rs2", [], InstFormatOther> {
  bits<5> rs2;
  bits<5> rs1;
  bits<5> rd;

  let Inst{6-0} = 0b1110111;
  let Inst{11-7} = rd;
  let Inst{14-12} = funct3_val;
  let Inst{19-15} = rs1;
  let Inst{24-20} = rs2;
  let Inst{25}    = 0b0;  // 0 for register source
  let Inst{31-26} = funct6_val;  // To be defined in subclasses
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 1, mayLoad = 0, mayStore = 0 in {
  // msettype - set the mtype CSR based on the value in a register
  def BOSC_AME_MSETTYPE : RVInstBOSCAMEConfig32<0b000000, 0b100, "msettype">;
  // msettilem - set tile M dimension from register
  def BOSC_AME_MSETTILEM : RVInstBOSCAMEConfig32<0b000001, 0b101, "msettilem">;
  // msettilen - set tile N dimension from register
  def BOSC_AME_MSETTILEN : RVInstBOSCAMEConfig32<0b000001, 0b100, "msettilen">;
  // msettilek - set tile K dimension from register
  def BOSC_AME_MSETTILEK : RVInstBOSCAMEConfig32<0b000001, 0b110, "msettilek">;

  def BOSC_AME_MSETTSP : RVInstBOSCAMEConfig32<0b000000, 0b111, "msettsp">;
  def BOSC_AME_MSETTSPI : RVInstBOSCAMEConfigSpi<0b000000, "msettspi">;
  def BOSC_AME_MSETDSP : RVInstBOSCAMEConfig32<0b000001, 0b111, "msetdsp">;
  def BOSC_AME_MSETDSPI : RVInstBOSCAMEConfigSpi<0b000001, "msetdspi">;

  def BOSC_AME_MSETOUTSH : RVInstBOSCAMEConfigReg2<0b000010, 0b100, "msetoutsh">;
  def BOSC_AME_MSETINSH : RVInstBOSCAMEConfigReg2<0b000010, 0b101, "msetinsh">;
  def BOSC_AME_MSETSK : RVInstBOSCAMEConfigReg2<0b000010, 0b110, "msetsk">;
  def BOSC_AME_MSETPADVAL : RVInstBOSCAMEConfig32<0b000010, 0b111, "msetpadval">;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 1, mayLoad = 0, mayStore = 0 in {
  // msettypei - set the mtype CSR based on their arguments
  def BOSC_AME_MSETTYPEI : RVInstBOSCAMEConfigImm32<0b000000, 0b100, "msettypei">;
  // msettypehi
  def BOSC_AME_MSETTYPEHI : RVInstBOSCAMEConfigImm32<0b000000, 0b101, "msettypehi">;
  // msettilemi - set tile M dimension from immediate
  def BOSC_AME_MSETTILEMI : RVInstBOSCAMEConfigImm32<0b000001, 0b101, "msettilemi">;
  // msettileni - set tile N dimension from immediate
  def BOSC_AME_MSETTILENI : RVInstBOSCAMEConfigImm32<0b000001, 0b100, "msettileni">;
  // msettileki - set tile K dimension from immediate
  def BOSC_AME_MSETTILEKI : RVInstBOSCAMEConfigImm32<0b000001, 0b110, "msettileki">;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 1, mayLoad = 0, mayStore = 0 in {
  // msetsew - set the SEW CSR based on the value in a register
  def BOSC_AME_MSETSEW : RVInstBOSCAMEConfigSew<0b00000, "msetsew">;
  def BOSC_AME_MSETINT4 : RVInstBOSCAMEConfigSew<0b00001, "msetint4">;
  def BOSC_AME_MSETINT8 : RVInstBOSCAMEConfigSew<0b00010, "msetint8">;
  def BOSC_AME_MSETINT16 : RVInstBOSCAMEConfigSew<0b00011, "msetint16">;
  def BOSC_AME_MSETINT32 : RVInstBOSCAMEConfigSew<0b00100, "msetint32">;
  def BOSC_AME_MSETINT64 : RVInstBOSCAMEConfigSew<0b00101, "msetint64">;
  def BOSC_AME_MSETFP8 : RVInstBOSCAMEConfigSew<0b00110, "msetfp8">;
  def BOSC_AME_MSETFP16 : RVInstBOSCAMEConfigSew<0b00111, "msetfp16">;
  def BOSC_AME_MSETFP32 : RVInstBOSCAMEConfigSew<0b01000, "msetfp32">;
  def BOSC_AME_MSETFP64 : RVInstBOSCAMEConfigSew<0b01001, "msetfp64">;
  def BOSC_AME_MSETBA : RVInstBOSCAMEConfigSew<0b01010, "msetba">;
}

//===----------------------------------------------------------------------===//
// BOSC AME Load/Store Instructions
//===----------------------------------------------------------------------===//
// Load/Store instruction format (32-bit):
// | 31:26  | 25 | 24:20 | 19:15 | 14:12 | 11 | 10:7    | 6:0    |
// | funct6 | ls | rs2   | rs1   | eew   | tr | ms3/td  | OP-M32 |
//
// ls: 0 for load (mlae/mlbe), 1 for store (msce)
// tr: whether the operand in register is transposed
// eew: 000=int8, 001=int16, 010=int32, 011=int64, 111=int4
//
// Data Flow Examples:
//   mlae32.m tr0, (a0), a1    # Load matrix A into TileReg
//   mlbe32.m tr1, (a0), a1    # Load matrix B into TileReg
//   mqma.b.mm acc0, tr0, tr1  # Compute: AccReg = AccReg + TileReg × TileReg
//   msce32.m acc0, (a0), a1   # Store AccReg to memory
//===----------------------------------------------------------------------===//

// Load into TileReg (for matrix A and B)
class RVInstBOSCAMELoadTile32<bits<6> funct6_val, bits<3> eew_val, bit tr_val, string opcodestr>
    : RVInst<(outs TileReg:$md), (ins GPR:$rs1, GPR:$rs2),
               opcodestr, "$md, (${rs1}), $rs2", [], InstFormatOther> {
  bits<5> rs2;
  bits<5> rs1;
  bits<4> md;  // TileReg index for load

  let Inst{6-0}   = 0b1110111;   // AME prefix
  let Inst{10-7}  = md;
  let Inst{11}    = tr_val;
  let Inst{14-12} = eew_val;
  let Inst{19-15} = rs1;
  let Inst{24-20} = rs2;
  let Inst{25}    = 0;           // ls = 0 for load
  let Inst{31-26} = funct6_val;  // funct6
}

// Load into AccReg (for accumulator C)
class RVInstBOSCAMELoadAcc32<bits<6> funct6_val, bits<3> eew_val, bit tr_val, string opcodestr>
    : RVInst<(outs AccReg:$md), (ins GPR:$rs1, GPR:$rs2),
               opcodestr, "$md, (${rs1}), $rs2", [], InstFormatOther> {
  bits<5> rs2;
  bits<5> rs1;
  bits<4> md;  // AccReg index for load

  let Inst{6-0}   = 0b1110111;   // AME prefix
  let Inst{10-7}  = md;
  let Inst{11}    = tr_val;
  let Inst{14-12} = eew_val;
  let Inst{19-15} = rs1;
  let Inst{24-20} = rs2;
  let Inst{25}    = 0;           // ls = 0 for load
  let Inst{31-26} = funct6_val;  // funct6
}

class RVInstBOSCAMELoadVector<bits<6> funct6_val, bits<3> eew_val, string opcodestr>
    : RVInst<(outs VR:$vd), (ins GPR:$rs1, GPR:$rs2),
               opcodestr, "$vd, (${rs1}), $rs2", [], InstFormatOther> {
  bits<5> rs2;
  bits<5> rs1;
  bits<5> vd;

  let Inst{6-0}   = 0b1110111;   // AME prefix
  let Inst{11-7}  = vd;
  let Inst{14-12} = eew_val;
  let Inst{19-15} = rs1;
  let Inst{24-20} = rs2;
  let Inst{25}    = 0;           // ls = 0 for load
  let Inst{31-26} = funct6_val;  // funct6
}

class RVInstBOSCAMELoadUnfoldTile<bits<6> funct6_val, bits<3> eew_val, string opcodestr>
    : RVInst<(outs TileReg:$md), (ins GPR:$rs1, GPR:$rs2),
               opcodestr, "$md, (${rs1}), $rs2", [], InstFormatOther> {
  bits<5> rs2;
  bits<5> rs1;
  bits<4> md;  // TileReg index for load

  let Inst{6-0}   = 0b1110111;   // AME prefix
  let Inst{10-7}  = md;
  let Inst{11}    = 0;
  let Inst{14-12} = eew_val;
  let Inst{19-15} = rs1;
  let Inst{24-20} = rs2;
  let Inst{25}    = 0;           // ls = 0 for load
  let Inst{31-26} = funct6_val;  // funct6
}

// Store from TileReg (for matrix A and B)
class RVInstBOSCAMEStoreTile32<bits<6> funct6_val, bits<3> eew_val, bit tr_val, string opcodestr>
    : RVInst<(outs), (ins TileReg:$ms3, GPR:$rs1, GPR:$rs2),
               opcodestr, "$ms3, (${rs1}), $rs2", [], InstFormatOther> {
  bits<5> rs2;
  bits<5> rs1;
  bits<4> ms3;  // TileReg index for store

  let Inst{6-0}   = 0b1110111;   // AME prefix
  let Inst{10-7}  = ms3;
  let Inst{11}    = tr_val;
  let Inst{14-12} = eew_val;
  let Inst{19-15} = rs1;
  let Inst{24-20} = rs2;
  let Inst{25}    = 1;           // ls = 1 for store
  let Inst{31-26} = funct6_val;  // funct6
}

// Store from AccReg (for accumulator C)
class RVInstBOSCAMEStoreAcc32<bits<6> funct6_val, bits<3> eew_val, bit tr_val, string opcodestr>
    : RVInst<(outs), (ins AccReg:$ms3, GPR:$rs1, GPR:$rs2),
               opcodestr, "$ms3, (${rs1}), $rs2", [], InstFormatOther> {
  bits<5> rs2;
  bits<5> rs1;
  bits<4> ms3;  // AccReg index for store

  let Inst{6-0}   = 0b1110111;   // AME prefix
  let Inst{10-7}  = ms3;
  let Inst{11}    = tr_val;
  let Inst{14-12} = eew_val;
  let Inst{19-15} = rs1;
  let Inst{24-20} = rs2;
  let Inst{25}    = 1;           // ls = 1 for store
  let Inst{31-26} = funct6_val;  // funct6
}

class RVInstBOSCAMEStoreVector<bits<6> funct6_val, bits<3> eew_val, string opcodestr>
    : RVInst<(outs), (ins VR:$vs3, GPR:$rs1, GPR:$rs2),
               opcodestr, "$vs3, (${rs1}), $rs2", [], InstFormatOther> {
  bits<5> rs2;
  bits<5> rs1;
  bits<5> vs3;  // VR index for store

  let Inst{6-0}   = 0b1110111;   // AME prefix
  let Inst{11-7}  = vs3;
  let Inst{14-12} = eew_val;
  let Inst{19-15} = rs1;
  let Inst{24-20} = rs2;
  let Inst{25}    = 1;           // ls = 1 for store
  let Inst{31-26} = funct6_val;  // funct6
}

class RVInstBOSCAMEStoreFoldTile<bits<6> funct6_val, bits<3> eew_val, string opcodestr>
    : RVInst<(outs), (ins TileReg:$ms3, GPR:$rs1, GPR:$rs2),
               opcodestr, "$ms3, (${rs1}), $rs2", [], InstFormatOther> {
  bits<5> rs2;
  bits<5> rs1;
  bits<4> ms3;  // TileReg index for store

  let Inst{6-0}   = 0b1110111;   // AME prefix
  let Inst{10-7}  = ms3;
  let Inst{11}    = 0;
  let Inst{14-12} = eew_val;
  let Inst{19-15} = rs1;
  let Inst{24-20} = rs2;
  let Inst{25}    = 1;           // ls = 1 for store
  let Inst{31-26} = funct6_val;  // funct6
}

//===----------------------------------------------------------------------===//
// Load matrix A into TileReg - mlae*.m
// Syntax: mlae{8|16|32|64}.m md, (rs1), rs2
//   md:  Destination TileReg
//   rs1: Base address (GPR)
//   rs2: Row stride in bytes (GPR)
//===----------------------------------------------------------------------===//
let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 1, mayStore = 0 in {
  def BOSC_AME_MLAE8_M  : RVInstBOSCAMELoadTile32<0b000001, 0b000, 0b0, "mlae8.m">;
  def BOSC_AME_MLAE16_M : RVInstBOSCAMELoadTile32<0b000001, 0b001, 0b0, "mlae16.m">;
  def BOSC_AME_MLAE32_M : RVInstBOSCAMELoadTile32<0b000001, 0b010, 0b0, "mlae32.m">;
  def BOSC_AME_MLAE64_M : RVInstBOSCAMELoadTile32<0b000001, 0b011, 0b0, "mlae64.m">;

  def BOSC_AME_MLATE8_M  : RVInstBOSCAMELoadTile32<0b000001, 0b000, 0b1, "mlate8.m">;
  def BOSC_AME_MLATE16_M : RVInstBOSCAMELoadTile32<0b000001, 0b001, 0b1, "mlate16.m">;
  def BOSC_AME_MLATE32_M : RVInstBOSCAMELoadTile32<0b000001, 0b010, 0b1, "mlate32.m">;
  def BOSC_AME_MLATE64_M : RVInstBOSCAMELoadTile32<0b000001, 0b011, 0b1, "mlate64.m">;

  def BOSC_AME_MLTRE8_M  : RVInstBOSCAMELoadTile32<0b000011, 0b000, 0b0, "mltre8.m">;
  def BOSC_AME_MLTRE16_M : RVInstBOSCAMELoadTile32<0b000011, 0b001, 0b0, "mltre16.m">;
  def BOSC_AME_MLTRE32_M : RVInstBOSCAMELoadTile32<0b000011, 0b010, 0b0, "mltre32.m">;
  def BOSC_AME_MLTRE64_M : RVInstBOSCAMELoadTile32<0b000011, 0b011, 0b0, "mltre64.m">;
}

//===----------------------------------------------------------------------===//
// Load matrix B into TileReg - mlbe*.m
// Syntax: mlbe{8|16|32|64}.m md, (rs1), rs2
//===----------------------------------------------------------------------===//
let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 1, mayStore = 0 in {
  def BOSC_AME_MLBE8_M  : RVInstBOSCAMELoadTile32<0b000010, 0b000, 0b0, "mlbe8.m">;
  def BOSC_AME_MLBE16_M : RVInstBOSCAMELoadTile32<0b000010, 0b001, 0b0, "mlbe16.m">;
  def BOSC_AME_MLBE32_M : RVInstBOSCAMELoadTile32<0b000010, 0b010, 0b0, "mlbe32.m">;
  def BOSC_AME_MLBE64_M : RVInstBOSCAMELoadTile32<0b000010, 0b011, 0b0, "mlbe64.m">;

  def BOSC_AME_MLBTE8_M  : RVInstBOSCAMELoadTile32<0b000010, 0b000, 0b1, "mlbte8.m">;
  def BOSC_AME_MLBTE16_M : RVInstBOSCAMELoadTile32<0b000010, 0b001, 0b1, "mlbte16.m">;
  def BOSC_AME_MLBTE32_M : RVInstBOSCAMELoadTile32<0b000010, 0b010, 0b1, "mlbte32.m">;
  def BOSC_AME_MLBTE64_M : RVInstBOSCAMELoadTile32<0b000010, 0b011, 0b1, "mlbte64.m">;
}

//===----------------------------------------------------------------------===//
// Load matrix C (accumulator) into AccReg - mlce*.m
// Syntax: mlce{8|16|32|64}.m md, (rs1), rs2
//   md: Destination AccReg (MLEN×AMUL bits)
// Note: eew here refers to the output element width after widening
//===----------------------------------------------------------------------===//
let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 1, mayStore = 0 in {
  def BOSC_AME_MLCE8_M  : RVInstBOSCAMELoadAcc32<0b000000, 0b000, 0b0, "mlce8.m">;
  def BOSC_AME_MLCE16_M : RVInstBOSCAMELoadAcc32<0b000000, 0b001, 0b0, "mlce16.m">;
  def BOSC_AME_MLCE32_M : RVInstBOSCAMELoadAcc32<0b000000, 0b010, 0b0, "mlce32.m">;
  def BOSC_AME_MLCE64_M : RVInstBOSCAMELoadAcc32<0b000000, 0b011, 0b0, "mlce64.m">;

  def BOSC_AME_MLCTE8_M  : RVInstBOSCAMELoadAcc32<0b000000, 0b000, 0b1, "mlcte8.m">;
  def BOSC_AME_MLCTE16_M : RVInstBOSCAMELoadAcc32<0b000000, 0b001, 0b1, "mlcte16.m">;
  def BOSC_AME_MLCTE32_M : RVInstBOSCAMELoadAcc32<0b000000, 0b010, 0b1, "mlcte32.m">;
  def BOSC_AME_MLCTE64_M : RVInstBOSCAMELoadAcc32<0b000000, 0b011, 0b1, "mlcte64.m">;

  def BOSC_AME_MLACCE8_M  : RVInstBOSCAMELoadAcc32<0b000011, 0b000, 0b1, "mlacce8.m">;
  def BOSC_AME_MLACCE16_M : RVInstBOSCAMELoadAcc32<0b000011, 0b001, 0b1, "mlacce16.m">;
  def BOSC_AME_MLACCE32_M : RVInstBOSCAMELoadAcc32<0b000011, 0b010, 0b1, "mlacce32.m">;
  def BOSC_AME_MLACCE64_M : RVInstBOSCAMELoadAcc32<0b000011, 0b011, 0b1, "mlacce64.m">;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 1, mayStore = 0 in {
  def BOSC_AME_MLAE8_V  : RVInstBOSCAMELoadVector<0b100001, 0b000, "mlae8.v">;
  def BOSC_AME_MLAE16_V : RVInstBOSCAMELoadVector<0b100001, 0b001, "mlae16.v">;
  def BOSC_AME_MLAE32_V : RVInstBOSCAMELoadVector<0b100001, 0b010, "mlae32.v">;
  def BOSC_AME_MLAE64_V : RVInstBOSCAMELoadVector<0b100001, 0b011, "mlae64.v">;
  def BOSC_AME_MLBE8_V  : RVInstBOSCAMELoadVector<0b100010, 0b000, "mlbe8.v">;
  def BOSC_AME_MLBE16_V : RVInstBOSCAMELoadVector<0b100010, 0b001, "mlbe16.v">;
  def BOSC_AME_MLBE32_V : RVInstBOSCAMELoadVector<0b100010, 0b010, "mlbe32.v">;
  def BOSC_AME_MLBE64_V : RVInstBOSCAMELoadVector<0b100010, 0b011, "mlbe64.v">;
  def BOSC_AME_MLCE8_V  : RVInstBOSCAMELoadVector<0b100000, 0b000, "mlce8.v">;
  def BOSC_AME_MLCE16_V : RVInstBOSCAMELoadVector<0b100000, 0b001, "mlce16.v">;
  def BOSC_AME_MLCE32_V : RVInstBOSCAMELoadVector<0b100000, 0b010, "mlce32.v">;
  def BOSC_AME_MLCE64_V : RVInstBOSCAMELoadVector<0b100000, 0b011, "mlce64.v">;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 1, mayStore = 0 in {
  def BOSC_AME_MLUFAE8_M  : RVInstBOSCAMELoadUnfoldTile<0b100001, 0b100, "mlufae8.m">;
  def BOSC_AME_MLUFAE16_M : RVInstBOSCAMELoadUnfoldTile<0b100001, 0b101, "mlufae16.m">;
  def BOSC_AME_MLUFAE32_M : RVInstBOSCAMELoadUnfoldTile<0b100001, 0b110, "mlufae32.m">;
  def BOSC_AME_MLUFAE64_M : RVInstBOSCAMELoadUnfoldTile<0b100001, 0b111, "mlufae64.m">;
  def BOSC_AME_MLUFBE8_M  : RVInstBOSCAMELoadUnfoldTile<0b100010, 0b100, "mlufbe8.m">;
  def BOSC_AME_MLUFBE16_M : RVInstBOSCAMELoadUnfoldTile<0b100010, 0b101, "mlufbe16.m">;
  def BOSC_AME_MLUFBE32_M : RVInstBOSCAMELoadUnfoldTile<0b100010, 0b110, "mlufbe32.m">;
  def BOSC_AME_MLUFBE64_M : RVInstBOSCAMELoadUnfoldTile<0b100010, 0b111, "mlufbe64.m">;
  def BOSC_AME_MLUFCE8_M  : RVInstBOSCAMELoadUnfoldTile<0b100000, 0b100, "mlufce8.m">;
  def BOSC_AME_MLUFCE16_M : RVInstBOSCAMELoadUnfoldTile<0b100000, 0b101, "mlufce16.m">;
  def BOSC_AME_MLUFCE32_M : RVInstBOSCAMELoadUnfoldTile<0b100000, 0b110, "mlufce32.m">;
  def BOSC_AME_MLUFCE64_M : RVInstBOSCAMELoadUnfoldTile<0b100000, 0b111, "mlufce64.m">;
}

//===----------------------------------------------------------------------===//
// Store matrix A from TileReg - msae*.m
// Syntax: msae{8|16|32|64}.m ms3, (rs1), rs2
//===----------------------------------------------------------------------===//
let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 1 in {
  def BOSC_AME_MSAE8_M  : RVInstBOSCAMEStoreTile32<0b000001, 0b000, 0b0, "msae8.m">;
  def BOSC_AME_MSAE16_M : RVInstBOSCAMEStoreTile32<0b000001, 0b001, 0b0, "msae16.m">;
  def BOSC_AME_MSAE32_M : RVInstBOSCAMEStoreTile32<0b000001, 0b010, 0b0, "msae32.m">;
  def BOSC_AME_MSAE64_M : RVInstBOSCAMEStoreTile32<0b000001, 0b011, 0b0, "msae64.m">;

  def BOSC_AME_MSATE8_M  : RVInstBOSCAMEStoreTile32<0b000001, 0b000, 0b1, "msate8.m">;
  def BOSC_AME_MSATE16_M : RVInstBOSCAMEStoreTile32<0b000001, 0b001, 0b1, "msate16.m">;
  def BOSC_AME_MSATE32_M : RVInstBOSCAMEStoreTile32<0b000001, 0b010, 0b1, "msate32.m">;
  def BOSC_AME_MSATE64_M : RVInstBOSCAMEStoreTile32<0b000001, 0b011, 0b1, "msate64.m">;

  def BOSC_AME_MSTRE8_M  : RVInstBOSCAMEStoreTile32<0b000011, 0b000, 0b0, "mstre8.m">;
  def BOSC_AME_MSTRE16_M : RVInstBOSCAMEStoreTile32<0b000011, 0b001, 0b0, "mstre16.m">;
  def BOSC_AME_MSTRE32_M : RVInstBOSCAMEStoreTile32<0b000011, 0b010, 0b0, "mstre32.m">;
  def BOSC_AME_MSTRE64_M : RVInstBOSCAMEStoreTile32<0b000011, 0b011, 0b0, "mstre64.m">;
}

//===----------------------------------------------------------------------===//
// Store matrix B from TileReg - msbe*.m
// Syntax: msbe{8|16|32|64}.m ms3, (rs1), rs2
//===----------------------------------------------------------------------===//
let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 1 in {
  def BOSC_AME_MSBE8_M  : RVInstBOSCAMEStoreTile32<0b000010, 0b000, 0b0, "msbe8.m">;
  def BOSC_AME_MSBE16_M : RVInstBOSCAMEStoreTile32<0b000010, 0b001, 0b0, "msbe16.m">;
  def BOSC_AME_MSBE32_M : RVInstBOSCAMEStoreTile32<0b000010, 0b010, 0b0, "msbe32.m">;
  def BOSC_AME_MSBE64_M : RVInstBOSCAMEStoreTile32<0b000010, 0b011, 0b0, "msbe64.m">;

  def BOSC_AME_MSBTE8_M  : RVInstBOSCAMEStoreTile32<0b000010, 0b000, 0b1, "msbte8.m">;
  def BOSC_AME_MSBTE16_M : RVInstBOSCAMEStoreTile32<0b000010, 0b001, 0b1, "msbte16.m">;
  def BOSC_AME_MSBTE32_M : RVInstBOSCAMEStoreTile32<0b000010, 0b010, 0b1, "msbte32.m">;
  def BOSC_AME_MSBTE64_M : RVInstBOSCAMEStoreTile32<0b000010, 0b011, 0b1, "msbte64.m">;
}

//===----------------------------------------------------------------------===//
// Store matrix C (accumulator) from AccReg - msce*.m
// Syntax: msce{8|16|32|64}.m ms3, (rs1), rs2
//   ms3: Source AccReg (MLEN×AMUL bits)
// This is the primary store for computation results
//===----------------------------------------------------------------------===//
let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 1 in {
  def BOSC_AME_MSCE8_M  : RVInstBOSCAMEStoreAcc32<0b000000, 0b000, 0b0, "msce8.m">;
  def BOSC_AME_MSCE16_M : RVInstBOSCAMEStoreAcc32<0b000000, 0b001, 0b0, "msce16.m">;
  def BOSC_AME_MSCE32_M : RVInstBOSCAMEStoreAcc32<0b000000, 0b010, 0b0, "msce32.m">;
  def BOSC_AME_MSCE64_M : RVInstBOSCAMEStoreAcc32<0b000000, 0b011, 0b0, "msce64.m">;

  def BOSC_AME_MSCTE8_M  : RVInstBOSCAMEStoreAcc32<0b000000, 0b000, 0b1, "mscte8.m">;
  def BOSC_AME_MSCTE16_M : RVInstBOSCAMEStoreAcc32<0b000000, 0b001, 0b1, "mscte16.m">;
  def BOSC_AME_MSCTE32_M : RVInstBOSCAMEStoreAcc32<0b000000, 0b010, 0b1, "mscte32.m">;
  def BOSC_AME_MSCTE64_M : RVInstBOSCAMEStoreAcc32<0b000000, 0b011, 0b1, "mscte64.m">;

  def BOSC_AME_MSACCE8_M  : RVInstBOSCAMEStoreAcc32<0b000011, 0b000, 0b1, "msacce8.m">;
  def BOSC_AME_MSACCE16_M : RVInstBOSCAMEStoreAcc32<0b000011, 0b001, 0b1, "msacce16.m">;
  def BOSC_AME_MSACCE32_M : RVInstBOSCAMEStoreAcc32<0b000011, 0b010, 0b1, "msacce32.m">;
  def BOSC_AME_MSACCE64_M : RVInstBOSCAMEStoreAcc32<0b000011, 0b011, 0b1, "msacce64.m">;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 1 in {
  def BOSC_AME_MSAE8_V  : RVInstBOSCAMEStoreVector<0b100001, 0b000, "msae8.v">;
  def BOSC_AME_MSAE16_V : RVInstBOSCAMEStoreVector<0b100001, 0b001, "msae16.v">;
  //def BOSC_AME_MSAE32_V : RVInstBOSCAMEStoreVector<0b100001, 0b010, "msae32.v">;
  def BOSC_AME_MSAE64_V : RVInstBOSCAMEStoreVector<0b100001, 0b011, "msae64.v">;
  def BOSC_AME_MSBE8_V  : RVInstBOSCAMEStoreVector<0b100010, 0b000, "msbe8.v">;
  def BOSC_AME_MSBE16_V : RVInstBOSCAMEStoreVector<0b100010, 0b001, "msbe16.v">;
  //def BOSC_AME_MSBE32_V : RVInstBOSCAMEStoreVector<0b100010, 0b010, "msbe32.v">;
  def BOSC_AME_MSBE64_V : RVInstBOSCAMEStoreVector<0b100010, 0b011, "msbe64.v">;
  def BOSC_AME_MSCE8_V  : RVInstBOSCAMEStoreVector<0b100000, 0b000, "msce8.v">;
  def BOSC_AME_MSCE16_V : RVInstBOSCAMEStoreVector<0b100000, 0b001, "msce16.v">;
  //def BOSC_AME_MSCE32_V : RVInstBOSCAMEStoreVector<0b100000, 0b010, "msce32.v">;
  def BOSC_AME_MSCE64_V : RVInstBOSCAMEStoreVector<0b100000, 0b011, "msce64.v">;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 1 in {
  def BOSC_AME_MSFDAE8_M  : RVInstBOSCAMEStoreFoldTile<0b100001, 0b100, "msfdae8.m">;
  def BOSC_AME_MSFDAE16_M : RVInstBOSCAMEStoreFoldTile<0b100001, 0b101, "msfdae16.m">;
  def BOSC_AME_MSFDAE32_M : RVInstBOSCAMEStoreFoldTile<0b100001, 0b110, "msfdae32.m">;
  def BOSC_AME_MSFDAE64_M : RVInstBOSCAMEStoreFoldTile<0b100001, 0b111, "msfdae64.m">;
  def BOSC_AME_MSFDBE8_M  : RVInstBOSCAMEStoreFoldTile<0b100010, 0b100, "msfdbe8.m">;
  def BOSC_AME_MSFDBE16_M : RVInstBOSCAMEStoreFoldTile<0b100010, 0b101, "msfdbe16.m">;
  def BOSC_AME_MSFDBE32_M : RVInstBOSCAMEStoreFoldTile<0b100010, 0b110, "msfdbe32.m">;
  def BOSC_AME_MSFDBE64_M : RVInstBOSCAMEStoreFoldTile<0b100010, 0b111, "msfdbe64.m">;
  def BOSC_AME_MSFDCE8_M  : RVInstBOSCAMEStoreFoldTile<0b100000, 0b100, "msfdce8.m">;
  def BOSC_AME_MSFDCE16_M : RVInstBOSCAMEStoreFoldTile<0b100000, 0b101, "msfdce16.m">;
  def BOSC_AME_MSFDCE32_M : RVInstBOSCAMEStoreFoldTile<0b100000, 0b110, "msfdce32.m">;
  def BOSC_AME_MSFDCE64_M : RVInstBOSCAMEStoreFoldTile<0b100000, 0b111, "msfdce64.m">;
}

//===----------------------------------------------------------------------===//
// BOSC AME Data Move Instructions
//===----------------------------------------------------------------------===//
// Data Move Instruction format (32-bit):
// | 31:26  | 25 | 24:20 | 19:15 | 14:12 | 11:7 | 6:0    |
// | funct6 | di | rs2   | rs1   | eew   | rd   | OP-M32 |
//===----------------------------------------------------------------------===//
class RVInstBOSCAMEMove<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<6> funct6;
  bit     di;
  bits<5> rs2;
  bits<5> rs1;
  bits<3> eew;    // 0=int8, 1=int16, 2=int32, 3=int64, 7=int4
  bits<5> rd;
  bits<7> opcode = 0b1110111;

  let Inst{31-26} = funct6;
  let Inst{25}    = di;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = eew;
  let Inst{11-7}  = rd;
  let Inst{6-0} = 0b1110111;
}

// Data Move Instructions between Matrix Registers
class RVInstBOSCAMEMove_T_T<bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs TileReg:$md), (ins TileReg:$ms1),
                        opcodestr, "$md, $ms1"> {
  bits<5> md;   // TileReg index for store
  bits<5> ms1;  // TileReg index for load

  let funct6 = 0b000111;
  let di     = 0b0;
  let rs2    = 0b00000;
  let rs1    = ms1;
  let eew    = eew_val;
  let rd     = md;
  let opcode = 0b1110111;
}

class RVInstBOSCAMEMove_A_A<bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs AccReg:$md), (ins AccReg:$ms1),
                        opcodestr, "$md, $ms1"> {
  bits<5> md;   // AccReg index for store
  bits<5> ms1;  // AccReg index for load

  let funct6 = 0b000111;
  let di     = 0b0;
  let rs2    = 0b00001;
  let rs1    = ms1;
  let eew    = eew_val;
  let rd     = md;
  let opcode = 0b1110111;
}

class RVInstBOSCAMEMove_A_T<bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs AccReg:$md), (ins TileReg:$ms1, GPR:$rs2),
                        opcodestr, "$md, $ms1, $rs2"> {
  bits<5> md;   // AccReg index for store
  bits<5> ms1;  // TileReg index for load

  let funct6 = 0b000100;
  let di     = 0b0;
  let rs1    = ms1;
  let eew    = eew_val;
  let rd     = md;
  let opcode = 0b1110111;
}

class RVInstBOSCAMEMove_T_A<bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs TileReg:$md), (ins AccReg:$ms1, GPR:$rs2),
                        opcodestr, "$md, $ms1, $rs2"> {
  bits<5> md;   // TileReg index for load
  bits<5> ms1;  // AccReg index for store

  let funct6 = 0b000100;
  let di     = 0b1;
  let rs1    = ms1;
  let eew    = eew_val;
  let rd     = md;
  let opcode = 0b1110111;
}

class RVInstBOSCAMEMoveImm_A_T<bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs AccReg:$md), (ins TileReg:$ms1, uimm5:$imm),
                         opcodestr, "$md, $ms1, $imm"> {
  bits<5> imm;
  bits<5> ms1;
  bits<5> md;

  let funct6 = 0b000100;
  let di     = 0b0;
  let rs2    = imm;
  let rs1    = ms1;
  let eew    = eew_val;
  let rd     = md;
  let opcode = 0b1110111;
}

class RVInstBOSCAMEMoveImm_T_A<bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs TileReg:$md), (ins AccReg:$ms1, uimm5:$imm),
                         opcodestr, "$md, $ms1, $imm"> {
  bits<5> imm;
  bits<5> ms1;
  bits<5> md;

  let funct6 = 0b000100;
  let di     = 0b1;
  let rs2    = imm;
  let rs1    = ms1;
  let eew    = eew_val;
  let rd     = md;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {

  def BOSC_AME_MMVE8_T_T  : RVInstBOSCAMEMove_T_T<0b000, "mmve8.t.t">;
  def BOSC_AME_MMVE16_T_T : RVInstBOSCAMEMove_T_T<0b001, "mmve16.t.t">;
  def BOSC_AME_MMVE32_T_T : RVInstBOSCAMEMove_T_T<0b010, "mmve32.t.t">;
  def BOSC_AME_MMVE64_T_T : RVInstBOSCAMEMove_T_T<0b011, "mmve64.t.t">;

  def BOSC_AME_MMVE8_A_A  : RVInstBOSCAMEMove_A_A<0b000, "mmve8.a.a">;
  def BOSC_AME_MMVE16_A_A : RVInstBOSCAMEMove_A_A<0b001, "mmve16.a.a">;
  def BOSC_AME_MMVE32_A_A : RVInstBOSCAMEMove_A_A<0b010, "mmve32.a.a">;
  def BOSC_AME_MMVE64_A_A : RVInstBOSCAMEMove_A_A<0b011, "mmve64.a.a">;

  def BOSC_AME_MMVE8_A_T  : RVInstBOSCAMEMove_A_T<0b000, "mmve8.a.t">;
  def BOSC_AME_MMVE16_A_T : RVInstBOSCAMEMove_A_T<0b001, "mmve16.a.t">;
  def BOSC_AME_MMVE32_A_T : RVInstBOSCAMEMove_A_T<0b010, "mmve32.a.t">;
  def BOSC_AME_MMVE64_A_T : RVInstBOSCAMEMove_A_T<0b011, "mmve64.a.t">;

  def BOSC_AME_MMVE8_T_A  : RVInstBOSCAMEMove_T_A<0b000, "mmve8.t.a">;
  def BOSC_AME_MMVE16_T_A : RVInstBOSCAMEMove_T_A<0b001, "mmve16.t.a">;
  def BOSC_AME_MMVE32_T_A : RVInstBOSCAMEMove_T_A<0b010, "mmve32.t.a">;
  def BOSC_AME_MMVE64_T_A : RVInstBOSCAMEMove_T_A<0b011, "mmve64.t.a">;

  def BOSC_AME_MMVIE8_A_T  : RVInstBOSCAMEMoveImm_A_T<0b100, "mmvie8.a.t">;
  def BOSC_AME_MMVIE16_A_T : RVInstBOSCAMEMoveImm_A_T<0b101, "mmvie16.a.t">;
  def BOSC_AME_MMVIE32_A_T : RVInstBOSCAMEMoveImm_A_T<0b110, "mmvie32.a.t">;
  def BOSC_AME_MMVIE64_A_T : RVInstBOSCAMEMoveImm_A_T<0b111, "mmvie64.a.t">;

  def BOSC_AME_MMVIE8_T_A  : RVInstBOSCAMEMoveImm_T_A<0b100, "mmvie8.t.a">;
  def BOSC_AME_MMVIE16_T_A : RVInstBOSCAMEMoveImm_T_A<0b101, "mmvie16.t.a">;
  def BOSC_AME_MMVIE32_T_A : RVInstBOSCAMEMoveImm_T_A<0b110, "mmvie32.t.a">;
  def BOSC_AME_MMVIE64_T_A : RVInstBOSCAMEMoveImm_T_A<0b111, "mmvie64.t.a">;
}

// Data Move Instructions between Matrix and Integer
class RVInstBOSCAMEMove_X_T<bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs GPR:$rd), (ins TileReg:$ms1, GPR:$rs2),
                        opcodestr, "$rd, $ms1, $rs2"> {
  bits<5> rs2;
  bits<5> ms1;
  bits<5> rd;

  let funct6 = 0b000101;
  let di     = 0b0;
  let rs1    = ms1;
  let eew    = eew_val;
}

class RVInstBOSCAMEMove_T_X<bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs TileReg:$md), (ins TileReg:$md_in, GPR:$rs1, GPR:$rs2),
                        opcodestr, "$md, $rs1, $rs2"> {
  bits<5> md;

  let Constraints = "$md = $md_in";
  let funct6 = 0b000101;
  let di     = 0b1;
  let eew    = eew_val;
  let rd     = md;
}

class RVInstBOSCAMEMove_X_A<bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs GPR:$rd), (ins AccReg:$ms1, GPR:$rs2),
                        opcodestr, "$rd, $ms1, $rs2"> {
  bits<5> rs2;
  bits<5> ms1;
  bits<5> rd;

  let funct6 = 0b000101;
  let di     = 0b0;
  let rs1    = ms1;
  let eew    = eew_val;
}

class RVInstBOSCAMEMove_A_X<bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs AccReg:$md), (ins AccReg:$md_in, GPR:$rs1, GPR:$rs2),
                        opcodestr, "$md, $rs1, $rs2"> {
  bits<5> md;

  let Constraints = "$md = $md_in";
  let funct6 = 0b000101;
  let di     = 0b1;
  let eew    = eew_val;
  let rd     = md;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {

  def BOSC_AME_MMVE8_X_T  : RVInstBOSCAMEMove_X_T<0b000, "mmve8.x.t">;
  def BOSC_AME_MMVE16_X_T : RVInstBOSCAMEMove_X_T<0b001, "mmve16.x.t">;
  def BOSC_AME_MMVE32_X_T : RVInstBOSCAMEMove_X_T<0b010, "mmve32.x.t">;
  def BOSC_AME_MMVE64_X_T : RVInstBOSCAMEMove_X_T<0b011, "mmve64.x.t">;

  def BOSC_AME_MMVE8_T_X  : RVInstBOSCAMEMove_T_X<0b000, "mmve8.t.x">;
  def BOSC_AME_MMVE16_T_X : RVInstBOSCAMEMove_T_X<0b001, "mmve16.t.x">;
  def BOSC_AME_MMVE32_T_X : RVInstBOSCAMEMove_T_X<0b010, "mmve32.t.x">;
  def BOSC_AME_MMVE64_T_X : RVInstBOSCAMEMove_T_X<0b011, "mmve64.t.x">;

  def BOSC_AME_MMVE8_X_A  : RVInstBOSCAMEMove_X_A<0b100, "mmve8.x.a">;
  def BOSC_AME_MMVE16_X_A : RVInstBOSCAMEMove_X_A<0b101, "mmve16.x.a">;
  def BOSC_AME_MMVE32_X_A : RVInstBOSCAMEMove_X_A<0b110, "mmve32.x.a">;
  def BOSC_AME_MMVE64_X_A : RVInstBOSCAMEMove_X_A<0b111, "mmve64.x.a">;

  def BOSC_AME_MMVE8_A_X  : RVInstBOSCAMEMove_A_X<0b100, "mmve8.a.x">;
  def BOSC_AME_MMVE16_A_X : RVInstBOSCAMEMove_A_X<0b101, "mmve16.a.x">;
  def BOSC_AME_MMVE32_A_X : RVInstBOSCAMEMove_A_X<0b110, "mmve32.a.x">;
  def BOSC_AME_MMVE64_A_X : RVInstBOSCAMEMove_A_X<0b111, "mmve64.a.x">;
}

// Data Move Instructions between Matrix and Float-point
class RVInstBOSCAMEFMove_F_T<bits<3> eew_val, string opcodestr,
                             RegisterClass FPRC>
    : RVInstBOSCAMEMove<(outs FPRC:$rd),
                        (ins TileReg:$ms1, GPR:$rs2),
                        opcodestr, "$rd, $ms1, $rs2"> {
  bits<5> rs2;
  bits<5> ms1;
  bits<5> rd;

  let funct6 = 0b000110;
  let di     = 0b0;
  let rs1    = ms1;
  let eew    = eew_val;
}

// scalar float -> TileReg
class RVInstBOSCAMEFMove_T_F<bits<3> eew_val, string opcodestr,
                             RegisterClass FPRC>
    : RVInstBOSCAMEMove<(outs TileReg:$md),
                        (ins TileReg:$md_in, FPRC:$rs1, GPR:$rs2),
                        opcodestr, "$md, $rs1, $rs2"> {
  bits<5> md;

  let Constraints = "$md = $md_in";
  let funct6 = 0b000110;
  let di     = 0b1;
  let eew    = eew_val;
  let rd     = md;
}

// AccReg -> scalar float
class RVInstBOSCAMEFMove_F_A<bits<3> eew_val, string opcodestr,
                             RegisterClass FPRC>
    : RVInstBOSCAMEMove<(outs FPRC:$rd),
                        (ins AccReg:$ms1, GPR:$rs2),
                        opcodestr, "$rd, $ms1, $rs2"> {
  bits<5> rs2;
  bits<5> ms1;
  bits<5> rd;

  let funct6 = 0b000110;
  let di     = 0b0;
  let rs1    = ms1;
  let eew    = eew_val;
}

// scalar float -> AccReg
class RVInstBOSCAMEFMove_A_F<bits<3> eew_val, string opcodestr,
                             RegisterClass FPRC>
    : RVInstBOSCAMEMove<(outs AccReg:$md),
                        (ins AccReg:$md_in, FPRC:$rs1, GPR:$rs2),
                        opcodestr, "$md, $rs1, $rs2"> {
  bits<5> md;

  let Constraints = "$md = $md_in";
  let funct6 = 0b000110;
  let di     = 0b1;
  let eew    = eew_val;
  let rd     = md;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {

  def BOSC_AME_MFMVE8_F_T  : RVInstBOSCAMEFMove_F_T<0b000, "mfmve8.f.t", FPR32>;
  def BOSC_AME_MFMVE16_F_T : RVInstBOSCAMEFMove_F_T<0b001, "mfmve16.f.t", FPR16>;
  def BOSC_AME_MFMVE32_F_T : RVInstBOSCAMEFMove_F_T<0b010, "mfmve32.f.t", FPR32>;
  def BOSC_AME_MFMVE64_F_T : RVInstBOSCAMEFMove_F_T<0b011, "mfmve64.f.t", FPR64>;

  def BOSC_AME_MFMVE8_T_F  : RVInstBOSCAMEFMove_T_F<0b000, "mfmve8.t.f", FPR32>;
  def BOSC_AME_MFMVE16_T_F : RVInstBOSCAMEFMove_T_F<0b001, "mfmve16.t.f", FPR16>;
  def BOSC_AME_MFMVE32_T_F : RVInstBOSCAMEFMove_T_F<0b010, "mfmve32.t.f", FPR32>;
  def BOSC_AME_MFMVE64_T_F : RVInstBOSCAMEFMove_T_F<0b011, "mfmve64.t.f", FPR64>;

  def BOSC_AME_MFMVE8_F_A  : RVInstBOSCAMEFMove_F_A<0b100, "mfmve8.f.a", FPR32>;
  def BOSC_AME_MFMVE16_F_A : RVInstBOSCAMEFMove_F_A<0b101, "mfmve16.f.a", FPR16>;
  def BOSC_AME_MFMVE32_F_A : RVInstBOSCAMEFMove_F_A<0b110, "mfmve32.f.a", FPR32>;
  def BOSC_AME_MFMVE64_F_A : RVInstBOSCAMEFMove_F_A<0b111, "mfmve64.f.a", FPR64>;

  def BOSC_AME_MFMVE8_A_F  : RVInstBOSCAMEFMove_A_F<0b100, "mfmve8.a.f", FPR32>;
  def BOSC_AME_MFMVE16_A_F : RVInstBOSCAMEFMove_A_F<0b101, "mfmve16.a.f", FPR16>;
  def BOSC_AME_MFMVE32_A_F : RVInstBOSCAMEFMove_A_F<0b110, "mfmve32.a.f", FPR32>;
  def BOSC_AME_MFMVE64_A_F : RVInstBOSCAMEFMove_A_F<0b111, "mfmve64.a.f", FPR64>;
}

// For data moving between vector and matrix
// The vsew of vector must equal to msew of matrix.
class RVInstBOSCAMEMove_V_M<bits<6> funct6_val, bit var_val, bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs VR:$vd),
                        (ins TileReg:$ms1, GPR:$rs2),
                        opcodestr, "$vd, $ms1, $rs2"> {
  bits<5> rs2;
  bits<4> ms1;
  bits<5> vd;

  let Inst{31-26} = funct6_val;
  let Inst{25}    = 0b0;
  let Inst{24-20} = rs2;
  let Inst{19}    = var_val;
  let Inst{18-15} = ms1;
  let Inst{14-12} = eew_val;
  let Inst{11-7}  = vd;
  let Inst{6-0}   = 0b1110111;
}

class RVInstBOSCAMEMove_M_V<bits<6> funct6_val, bits<3> eew_val, bit var_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs TileReg:$md),
                        (ins VR:$vs1, GPR:$rs2),
                        opcodestr, "$md, $vs1, $rs2"> {
  bits<5> rs2;
  bits<5> vs1;
  bits<4> md;

  let Inst{31-26} = funct6_val;
  let Inst{25}    = 0b1;
  let Inst{24-20} = rs2;
  let Inst{19-15} = vs1;
  let Inst{14-12} = eew_val;
  let Inst{11}    = var_val;
  let Inst{10-7}  = md;
  let Inst{6-0}   = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // Data move between matrix register rows and vector registers.
  def BOSC_AME_MMVARE8_V_M  : RVInstBOSCAMEMove_V_M<0b100110, 0b0, 0b100, "mmvare8.v.m">;
  def BOSC_AME_MMVARE16_V_M : RVInstBOSCAMEMove_V_M<0b100110, 0b0, 0b101, "mmvare16.v.m">;
  def BOSC_AME_MMVARE32_V_M : RVInstBOSCAMEMove_V_M<0b100110, 0b0, 0b110, "mmvare32.v.m">;
  def BOSC_AME_MMVARE64_V_M : RVInstBOSCAMEMove_V_M<0b100110, 0b0, 0b111, "mmvare64.v.m">;
  def BOSC_AME_MMVBRE8_V_M  : RVInstBOSCAMEMove_V_M<0b100110, 0b1, 0b100, "mmvbre8.v.m">;
  def BOSC_AME_MMVBRE16_V_M : RVInstBOSCAMEMove_V_M<0b100110, 0b1, 0b101, "mmvbre16.v.m">;
  def BOSC_AME_MMVBRE32_V_M : RVInstBOSCAMEMove_V_M<0b100110, 0b1, 0b110, "mmvbre32.v.m">;
  def BOSC_AME_MMVBRE64_V_M : RVInstBOSCAMEMove_V_M<0b100110, 0b1, 0b111, "mmvbre64.v.m">;
  def BOSC_AME_MMVCRE8_V_M  : RVInstBOSCAMEMove_V_M<0b100110, 0b0, 0b000, "mmvcre8.v.m">;
  def BOSC_AME_MMVCRE16_V_M : RVInstBOSCAMEMove_V_M<0b100110, 0b0, 0b001, "mmvcre16.v.m">;
  def BOSC_AME_MMVCRE32_V_M : RVInstBOSCAMEMove_V_M<0b100110, 0b0, 0b010, "mmvcre32.v.m">;
  def BOSC_AME_MMVCRE64_V_M : RVInstBOSCAMEMove_V_M<0b100110, 0b0, 0b011, "mmvcre64.v.m">;
  
  def BOSC_AME_MMVARE8_M_V  : RVInstBOSCAMEMove_M_V<0b100110, 0b100, 0b0, "mmvare8.m.v">;
  def BOSC_AME_MMVARE16_M_V : RVInstBOSCAMEMove_M_V<0b100110, 0b101, 0b0, "mmvare16.m.v">;
  def BOSC_AME_MMVARE32_M_V : RVInstBOSCAMEMove_M_V<0b100110, 0b110, 0b0, "mmvare32.m.v">;
  def BOSC_AME_MMVARE64_M_V : RVInstBOSCAMEMove_M_V<0b100110, 0b111, 0b0, "mmvare64.m.v">;
  def BOSC_AME_MMVBRE8_M_V  : RVInstBOSCAMEMove_M_V<0b100110, 0b100, 0b1, "mmvbre8.m.v">;
  def BOSC_AME_MMVBRE16_M_V : RVInstBOSCAMEMove_M_V<0b100110, 0b101, 0b1, "mmvbre16.m.v">;
  def BOSC_AME_MMVBRE32_M_V : RVInstBOSCAMEMove_M_V<0b100110, 0b110, 0b1, "mmvbre32.m.v">;
  def BOSC_AME_MMVBRE64_M_V : RVInstBOSCAMEMove_M_V<0b100110, 0b111, 0b1, "mmvbre64.m.v">;
  def BOSC_AME_MMVCRE8_M_V  : RVInstBOSCAMEMove_M_V<0b100110, 0b000, 0b0, "mmvcre8.m.v">;
  def BOSC_AME_MMVCRE16_M_V : RVInstBOSCAMEMove_M_V<0b100110, 0b001, 0b0, "mmvcre16.m.v">;
  def BOSC_AME_MMVCRE32_M_V : RVInstBOSCAMEMove_M_V<0b100110, 0b010, 0b0, "mmvcre32.m.v">;
  def BOSC_AME_MMVCRE64_M_V : RVInstBOSCAMEMove_M_V<0b100110, 0b011, 0b0, "mmvcre64.m.v">;

  // Data move between matrix register columns and vector registers.
  def BOSC_AME_MMVACE8_V_M  : RVInstBOSCAMEMove_V_M<0b100111, 0b0, 0b100, "mmvace8.v.m">;
  def BOSC_AME_MMVACE16_V_M : RVInstBOSCAMEMove_V_M<0b100111, 0b0, 0b101, "mmvace16.v.m">;
  def BOSC_AME_MMVACE32_V_M : RVInstBOSCAMEMove_V_M<0b100111, 0b0, 0b110, "mmvace32.v.m">;
  def BOSC_AME_MMVACE64_V_M : RVInstBOSCAMEMove_V_M<0b100111, 0b0, 0b111, "mmvace64.v.m">;
  def BOSC_AME_MMVBCE8_V_M  : RVInstBOSCAMEMove_V_M<0b100111, 0b1, 0b100, "mmvbce8.v.m">;
  def BOSC_AME_MMVBCE16_V_M : RVInstBOSCAMEMove_V_M<0b100111, 0b1, 0b101, "mmvbce16.v.m">;
  def BOSC_AME_MMVBCE32_V_M : RVInstBOSCAMEMove_V_M<0b100111, 0b1, 0b110, "mmvbce32.v.m">;
  def BOSC_AME_MMVBCE64_V_M : RVInstBOSCAMEMove_V_M<0b100111, 0b1, 0b111, "mmvbce64.v.m">;
  def BOSC_AME_MMVCCE8_V_M  : RVInstBOSCAMEMove_V_M<0b100111, 0b0, 0b000, "mmvcce8.v.m">;
  def BOSC_AME_MMVCCE16_V_M : RVInstBOSCAMEMove_V_M<0b100111, 0b0, 0b001, "mmvcce16.v.m">;
  def BOSC_AME_MMVCCE32_V_M : RVInstBOSCAMEMove_V_M<0b100111, 0b0, 0b010, "mmvcce32.v.m">;
  def BOSC_AME_MMVCCE64_V_M : RVInstBOSCAMEMove_V_M<0b100111, 0b0, 0b011, "mmvcce64.v.m">;

  def BOSC_AME_MMVACE8_M_V  : RVInstBOSCAMEMove_M_V<0b100111, 0b100, 0b0, "mmvace8.m.v">;
  def BOSC_AME_MMVACE16_M_V : RVInstBOSCAMEMove_M_V<0b100111, 0b101, 0b0, "mmvace16.m.v">;
  def BOSC_AME_MMVACE32_M_V : RVInstBOSCAMEMove_M_V<0b100111, 0b110, 0b0, "mmvace32.m.v">;
  def BOSC_AME_MMVACE64_M_V : RVInstBOSCAMEMove_M_V<0b100111, 0b111, 0b0, "mmvace64.m.v">;
  def BOSC_AME_MMVBCE8_M_V  : RVInstBOSCAMEMove_M_V<0b100111, 0b100, 0b1, "mmvbce8.m.v">;
  def BOSC_AME_MMVBCE16_M_V : RVInstBOSCAMEMove_M_V<0b100111, 0b101, 0b1, "mmvbce16.m.v">;
  def BOSC_AME_MMVBCE32_M_V : RVInstBOSCAMEMove_M_V<0b100111, 0b110, 0b1, "mmvbce32.m.v">;
  def BOSC_AME_MMVBCE64_M_V : RVInstBOSCAMEMove_M_V<0b100111, 0b111, 0b1, "mmvbce64.m.v">;
  def BOSC_AME_MMVCCE8_M_V  : RVInstBOSCAMEMove_M_V<0b100111, 0b000, 0b0, "mmvcce8.m.v">;
  def BOSC_AME_MMVCCE16_M_V : RVInstBOSCAMEMove_M_V<0b100111, 0b001, 0b0, "mmvcce16.m.v">;
  def BOSC_AME_MMVCCE32_M_V : RVInstBOSCAMEMove_M_V<0b100111, 0b010, 0b0, "mmvcce32.m.v">;
  def BOSC_AME_MMVCCE64_M_V : RVInstBOSCAMEMove_M_V<0b100111, 0b011, 0b0, "mmvcce64.m.v">;
}

// Data Broadcast Instructions
class RVInstBOSCAMEBroadcastTile<bits<5> rs2_val, bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs TileReg:$md), (ins TileReg:$ms1),
                        opcodestr, "$md, $ms1"> {
  bits<5> md;
  bits<5> ms1;

  let funct6 = 0b000111;
  let di     = 0b0;
  let rs2    = rs2_val;
  let rs1    = ms1;
  let eew    = eew_val;
  let rd     = md;
  let opcode = 0b1110111;
}

class RVInstBOSCAMEBroadcastAcc<bits<5> rs2_val, bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs AccReg:$md), (ins AccReg:$ms1),
                        opcodestr, "$md, $ms1"> {
  bits<5> md;
  bits<5> ms1;

  let funct6 = 0b000111;
  let di     = 0b0;
  let rs2    = rs2_val;
  let rs1    = ms1;
  let eew    = eew_val;
  let rd     = md;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // Row broadcast from TileReg/AccReg
  def BOSC_AME_MBCAR_M : RVInstBOSCAMEBroadcastTile<0b10001, 0b000, "mbcar.m">;
  def BOSC_AME_MBCBR_M : RVInstBOSCAMEBroadcastTile<0b10010, 0b000, "mbcbr.m">;
  def BOSC_AME_MBCCR_M : RVInstBOSCAMEBroadcastAcc<0b10000, 0b000, "mbccr.m">;
  // Column broadcast from TileReg
  def BOSC_AME_MBCACE8_M  : RVInstBOSCAMEBroadcastTile<0b10101, 0b000, "mbcace8.m">;
  def BOSC_AME_MBCACE16_M : RVInstBOSCAMEBroadcastTile<0b10101, 0b001, "mbcace16.m">;
  def BOSC_AME_MBCACE32_M : RVInstBOSCAMEBroadcastTile<0b10101, 0b010, "mbcace32.m">;
  def BOSC_AME_MBCACE64_M : RVInstBOSCAMEBroadcastTile<0b10101, 0b011, "mbcace64.m">;
  // Column broadcast from TileReg
  def BOSC_AME_MBCBCE8_M  : RVInstBOSCAMEBroadcastTile<0b10110, 0b000, "mbcbce8.m">;
  def BOSC_AME_MBCBCE16_M : RVInstBOSCAMEBroadcastTile<0b10110, 0b001, "mbcbce16.m">;
  def BOSC_AME_MBCBCE32_M : RVInstBOSCAMEBroadcastTile<0b10110, 0b010, "mbcbce32.m">;
  def BOSC_AME_MBCBCE64_M : RVInstBOSCAMEBroadcastTile<0b10110, 0b011, "mbcbce64.m">;
  // Column broadcast from AccReg
  def BOSC_AME_MBCCCE8_M  : RVInstBOSCAMEBroadcastAcc<0b10100, 0b000, "mbccce8.m">;
  def BOSC_AME_MBCCCE16_M : RVInstBOSCAMEBroadcastAcc<0b10100, 0b001, "mbccce16.m">;
  def BOSC_AME_MBCCCE32_M : RVInstBOSCAMEBroadcastAcc<0b10100, 0b010, "mbccce32.m">;
  def BOSC_AME_MBCCCE64_M : RVInstBOSCAMEBroadcastAcc<0b10100, 0b011, "mbccce64.m">;
  // Element broadcast from TileReg
  def BOSC_AME_MBCAEE8_M  : RVInstBOSCAMEBroadcastTile<0b11001, 0b000, "mbcaee8.m">;
  def BOSC_AME_MBCAEE16_M : RVInstBOSCAMEBroadcastTile<0b11001, 0b001, "mbcaee16.m">;
  def BOSC_AME_MBCAEE32_M : RVInstBOSCAMEBroadcastTile<0b11001, 0b010, "mbcaee32.m">;
  def BOSC_AME_MBCAEE64_M : RVInstBOSCAMEBroadcastTile<0b11001, 0b011, "mbcaee64.m">;
  // Element broadcast from TileReg
  def BOSC_AME_MBCBEE8_M  : RVInstBOSCAMEBroadcastTile<0b11010, 0b000, "mbcbee8.m">;
  def BOSC_AME_MBCBEE16_M : RVInstBOSCAMEBroadcastTile<0b11010, 0b001, "mbcbee16.m">;
  def BOSC_AME_MBCBEE32_M : RVInstBOSCAMEBroadcastTile<0b11010, 0b010, "mbcbee32.m">;
  def BOSC_AME_MBCBEE64_M : RVInstBOSCAMEBroadcastTile<0b11010, 0b011, "mbcbee64.m">;
  // Element broadcast from AccReg
  def BOSC_AME_MBCCEE8_M  : RVInstBOSCAMEBroadcastAcc<0b11000, 0b000, "mbccee8.m">;
  def BOSC_AME_MBCCEE16_M : RVInstBOSCAMEBroadcastAcc<0b11000, 0b001, "mbccee16.m">;
  def BOSC_AME_MBCCEE32_M : RVInstBOSCAMEBroadcastAcc<0b11000, 0b010, "mbccee32.m">;
  def BOSC_AME_MBCCEE64_M : RVInstBOSCAMEBroadcastAcc<0b11000, 0b011, "mbccee64.m">;
}

// Matrix Transpose Instructions
class RVInstBOSCAMETransposeTile<bits<5> rs2_val, bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs TileReg:$md), (ins TileReg:$ms1),
                        opcodestr, "$md, $ms1"> {
  bits<5> md;
  bits<5> ms1;

  let funct6 = 0b000111;
  let di     = 0b0;
  let rs2    = rs2_val;
  let rs1    = ms1;
  let eew    = eew_val;
  let rd     = md;
  let opcode = 0b1110111;
}

class RVInstBOSCAMETransposeAcc<bits<5> rs2_val, bits<3> eew_val, string opcodestr>
    : RVInstBOSCAMEMove<(outs AccReg:$md), (ins AccReg:$ms1),
                        opcodestr, "$md, $ms1"> {
  bits<5> md;
  bits<5> ms1;

  let funct6 = 0b000111;
  let di     = 0b0;
  let rs2    = rs2_val;
  let rs1    = ms1;
  let eew    = eew_val;
  let rd     = md;
  let opcode = 0b1110111;
}

let Predicates = [HasVendorXBOSCAME], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // Transpose square matrix of tile register
  def BOSC_AME_MTAE8_M : RVInstBOSCAMETransposeTile<0b11101, 0b000, "mtae8.m">;
  def BOSC_AME_MTAE16_M : RVInstBOSCAMETransposeTile<0b11101, 0b001, "mtae16.m">;
  def BOSC_AME_MTAE32_M : RVInstBOSCAMETransposeTile<0b11101, 0b010, "mtae32.m">;
  def BOSC_AME_MTAE64_M : RVInstBOSCAMETransposeTile<0b11101, 0b011, "mtae64.m">;
  // Transpose square matrix of tile register
  def BOSC_AME_MTBE8_M : RVInstBOSCAMETransposeTile<0b11110, 0b000, "mtbe8.m">;
  def BOSC_AME_MTBE16_M : RVInstBOSCAMETransposeTile<0b11110, 0b001, "mtbe16.m">;
  def BOSC_AME_MTBE32_M : RVInstBOSCAMETransposeTile<0b11110, 0b010, "mtbe32.m">;
  def BOSC_AME_MTBE64_M : RVInstBOSCAMETransposeTile<0b11110, 0b011, "mtbe64.m">;
  // Transpose square matrix of acc register
  def BOSC_AME_MTCE8_M : RVInstBOSCAMETransposeAcc<0b11100, 0b000, "mtce8.m">;
  def BOSC_AME_MTCE16_M : RVInstBOSCAMETransposeAcc<0b11100, 0b001, "mtce16.m">;
  def BOSC_AME_MTCE32_M : RVInstBOSCAMETransposeAcc<0b11100, 0b010, "mtce32.m">;
  def BOSC_AME_MTCE64_M : RVInstBOSCAMETransposeAcc<0b11100, 0b011, "mtce64.m">;
}

//===----------------------------------------------------------------------===//
// Direct SelectionDAG patterns for BOSC AME real instructions.
//
// Replace the old "Pseudo Instructions for Index-Based Operations" section
// and the old pattern section with this content. No RHS below may name a
// *_PSEUDO instruction or use timm/BOSCAMETileIndex/BOSCAMEAccIndex.
//
// Preconditions:
//   * TileReg and AccReg are registered in RISCVRegisterInfo.td.
//   * The intrinsics use SSA matrix operands/results, not i64 register IDs.
//   * nxv128i8/nxv64i16/nxv32i32/nxv16i64 and the floating MVTs below are
//     registered with TileReg in RISCVISelLowering.cpp.
//   * The mfmve real instruction definitions use FPR16/FPR32/FPR64 rather
//     than GPR for their scalar floating operands/results.
//===----------------------------------------------------------------------===//

class BOSCAMETypeInfo<ValueType MatrixType, string NumberValue,
                      string SuffixValue, ValueType ScalarType = XLenVT,
                      RegisterClass ScalarReg = GPR> {
  ValueType Matrix = MatrixType;
  string Number = NumberValue;
  string Suffix = SuffixValue;
  ValueType Scalar = ScalarType;
  RegisterClass ScalarRC = ScalarReg;
}

def BOSCAME_I8  : BOSCAMETypeInfo<nxv128i8,  "8",  "B">;
def BOSCAME_I16 : BOSCAMETypeInfo<nxv64i16,  "16", "H">;
def BOSCAME_I32 : BOSCAMETypeInfo<nxv32i32,  "32", "W">;
def BOSCAME_I64 : BOSCAMETypeInfo<nxv16i64,  "64", "DW">;

// XW/XQ/XO are the wider integer matrix shapes. LLVM has no scalable i128,
// so retain the 64-bit storage element and represent the wider shape by its
// scalable element count.
def BOSCAME_I64_XW : BOSCAMETypeInfo<nxv32i64,  "XW", "XW">;
def BOSCAME_I64_XQ : BOSCAMETypeInfo<nxv64i64,  "XQ", "XQ">;
def BOSCAME_I64_XO : BOSCAMETypeInfo<nxv128i64, "XO", "XO">;

def BOSCAME_F16 : BOSCAMETypeInfo<nxv64f16, "16", "HF", f16, FPR16>;
def BOSCAME_BF16 : BOSCAMETypeInfo<nxv64bf16, "16", "BF">;
def BOSCAME_F32 : BOSCAMETypeInfo<nxv32f32, "32", "F",  f32, FPR32>;
def BOSCAME_F64 : BOSCAMETypeInfo<nxv16f64, "64", "D",  f64, FPR64>;

// Vector instructions use LMUL=1 RVV types allocated by VR.  Matrix/vector
// moves additionally require a matching TileReg MVT; nxv64bf16 is currently
// registered only for AccReg, so BOSCAME_VBF16 is used only by load/store.
class BOSCAMEVectorTypeInfo<BOSCAMETypeInfo MatrixInfoValue,
                             ValueType VectorType> {
  ValueType Matrix = MatrixInfoValue.Matrix;
  ValueType Vector = VectorType;
  string Number = MatrixInfoValue.Number;
}

def BOSCAME_VI8  : BOSCAMEVectorTypeInfo<BOSCAME_I8,  nxv8i8>;
def BOSCAME_VI16 : BOSCAMEVectorTypeInfo<BOSCAME_I16, nxv4i16>;
def BOSCAME_VI32 : BOSCAMEVectorTypeInfo<BOSCAME_I32, nxv2i32>;
def BOSCAME_VI64 : BOSCAMEVectorTypeInfo<BOSCAME_I64, nxv1i64>;
def BOSCAME_VF16 : BOSCAMEVectorTypeInfo<BOSCAME_F16, nxv4f16>;
def BOSCAME_VBF16: BOSCAMEVectorTypeInfo<BOSCAME_BF16, nxv4bf16>;
def BOSCAME_VF32 : BOSCAMEVectorTypeInfo<BOSCAME_F32, nxv2f32>;
def BOSCAME_VF64 : BOSCAMEVectorTypeInfo<BOSCAME_F64, nxv1f64>;

class BOSCAMEWidenInfo<BOSCAMETypeInfo DstType,
                       BOSCAMETypeInfo SrcType, string SuffixValue> {
  BOSCAMETypeInfo Dst = DstType;
  BOSCAMETypeInfo Src = SrcType;
  string Suffix = SuffixValue;
}

// Integer element-wise widen: B->H, H->W, W->DW.
def BOSCAME_I8_TO_I16  : BOSCAMEWidenInfo<BOSCAME_I16, BOSCAME_I8,  "B">;
def BOSCAME_I16_TO_I32 : BOSCAMEWidenInfo<BOSCAME_I32, BOSCAME_I16, "H">;
def BOSCAME_I32_TO_I64 : BOSCAMEWidenInfo<BOSCAME_I64, BOSCAME_I32, "W">;

// Integer widening MMA: H->W and W->DW.
def BOSCAME_I16_TO_I32_MMA : BOSCAMEWidenInfo<BOSCAME_I32, BOSCAME_I16, "H">;
def BOSCAME_I32_TO_I64_MMA : BOSCAMEWidenInfo<BOSCAME_I64, BOSCAME_I32, "W">;

// Floating widen: hf->f and f->d. f8/cf requires a separate LLVM MVT.
def BOSCAME_F16_TO_F32 : BOSCAMEWidenInfo<BOSCAME_F32, BOSCAME_F16, "HF">;
def BOSCAME_F32_TO_F64 : BOSCAMEWidenInfo<BOSCAME_F64, BOSCAME_F32, "F">;

// Immediate operands marked ImmArg in the LLVM intrinsic are lowered to
// TargetConstant nodes.  Use TImmLeaf for the DAG pattern so the matcher
// accepts those target constants (uimm10 is an ImmLeaf used by asm operands).
def boscame_tuimm10 : TImmLeaf<XLenVT, [{return isUInt<10>(Imm);}]>;

class BOSCAMEPatConfigImm<SDPatternOperator OpNode, RVInst Inst>
    : Pat<(XLenVT (OpNode boscame_tuimm10:$imm)),
          (Inst boscame_tuimm10:$imm)>;

class BOSCAMEPatConfigSew<SDPatternOperator OpNode, RVInst Inst>
    : Pat<(XLenVT (OpNode uimm5:$imm)),
          (Inst uimm5:$imm)>;

class BOSCAMEPatLoad<SDPatternOperator OpNode, Instruction Inst,
                     ValueType MatrixType>
    : Pat<(MatrixType (OpNode iPTR:$base, (XLenVT GPR:$stride))),
          (MatrixType (Inst iPTR:$base, (XLenVT GPR:$stride)))>;

class BOSCAMEPatStore<SDPatternOperator OpNode, Instruction Inst,
                      ValueType MatrixType, RegisterClass MatrixRC>
    : Pat<(OpNode (MatrixType MatrixRC:$matrix), iPTR:$base,
                  (XLenVT GPR:$stride)),
          (Inst (MatrixType MatrixRC:$matrix), iPTR:$base,
                (XLenVT GPR:$stride))>;

class BOSCAMEPatVectorLoad<SDPatternOperator OpNode, Instruction Inst,
                            ValueType VectorType>
    : Pat<(VectorType (OpNode iPTR:$base, (XLenVT GPR:$stride))),
          (VectorType (Inst iPTR:$base, (XLenVT GPR:$stride)))>;

class BOSCAMEPatVectorStore<SDPatternOperator OpNode, Instruction Inst,
                             ValueType VectorType>
    : Pat<(OpNode (VectorType VR:$vector), iPTR:$base,
                  (XLenVT GPR:$stride)),
          (Inst (VectorType VR:$vector), iPTR:$base,
                (XLenVT GPR:$stride))>;

class BOSCAMEPatMatrixToVector<SDPatternOperator OpNode, Instruction Inst,
                                ValueType VectorType, ValueType MatrixType>
    : Pat<(VectorType
             (OpNode (MatrixType TileReg:$matrix), (XLenVT GPR:$index))),
          (VectorType
             (Inst (MatrixType TileReg:$matrix), (XLenVT GPR:$index)))>;

class BOSCAMEPatVectorToMatrix<SDPatternOperator OpNode, Instruction Inst,
                                ValueType MatrixType, ValueType VectorType>
    : Pat<(MatrixType
             (OpNode (VectorType VR:$vector), (XLenVT GPR:$index))),
          (MatrixType
             (Inst (VectorType VR:$vector), (XLenVT GPR:$index)))>;

class BOSCAMEPatUnaryMatrix<SDPatternOperator OpNode, Instruction Inst,
                            ValueType DstType, RegisterClass DstRC,
                            ValueType SrcType, RegisterClass SrcRC>
    : Pat<(DstType (OpNode (SrcType SrcRC:$src))),
          (DstType (Inst (SrcType SrcRC:$src)))>;

class BOSCAMEPatMatrixGPR<SDPatternOperator OpNode, Instruction Inst,
                          ValueType DstType, RegisterClass DstRC,
                          ValueType SrcType, RegisterClass SrcRC>
    : Pat<(DstType (OpNode (SrcType SrcRC:$src), (XLenVT GPR:$index))),
          (DstType (Inst (SrcType SrcRC:$src), (XLenVT GPR:$index)))>;

class BOSCAMEPatMatrixImm<SDPatternOperator OpNode, Instruction Inst,
                          ValueType DstType, RegisterClass DstRC,
                          ValueType SrcType, RegisterClass SrcRC>
    : Pat<(DstType (OpNode (SrcType SrcRC:$src), uimm5:$index)),
          (DstType (Inst (SrcType SrcRC:$src), uimm5:$index))>;

class BOSCAMEPatMatrixToScalar<SDPatternOperator OpNode, Instruction Inst,
                               ValueType MatrixType, RegisterClass MatrixRC,
                               ValueType ScalarType, RegisterClass ScalarRC>
    : Pat<(ScalarType
            (OpNode (MatrixType MatrixRC:$matrix), (XLenVT GPR:$index))),
          (ScalarType
            (Inst (MatrixType MatrixRC:$matrix), (XLenVT GPR:$index)))>;

class BOSCAMEPatScalarToMatrix<SDPatternOperator OpNode, Instruction Inst,
                               ValueType MatrixType, RegisterClass MatrixRC,
                               ValueType ScalarType, RegisterClass ScalarRC>
    : Pat<(MatrixType
             (OpNode (MatrixType MatrixRC:$md_in),
                     (ScalarType ScalarRC:$value),
                     (XLenVT GPR:$index))),
          (MatrixType
             (Inst (MatrixType MatrixRC:$md_in),
                   (ScalarType ScalarRC:$value),
                   (XLenVT GPR:$index)))>;

class BOSCAMEPatAccBinary<SDPatternOperator OpNode, Instruction Inst,
                          ValueType MatrixType>
    : Pat<(MatrixType
            (OpNode (MatrixType AccReg:$lhs), (MatrixType AccReg:$rhs))),
          (MatrixType
            (Inst (MatrixType AccReg:$lhs), (MatrixType AccReg:$rhs)))>;

class BOSCAMEPatAccBinaryWiden<SDPatternOperator OpNode, Instruction Inst,
                               ValueType DstType, ValueType SrcType>
    : Pat<(DstType
            (OpNode (SrcType AccReg:$lhs), (SrcType AccReg:$rhs))),
          (DstType
            (Inst (SrcType AccReg:$lhs), (SrcType AccReg:$rhs)))>;

class BOSCAMEPatAccUnary<SDPatternOperator OpNode, Instruction Inst,
                         ValueType MatrixType>
    : Pat<(MatrixType (OpNode (MatrixType AccReg:$src))),
          (MatrixType (Inst (MatrixType AccReg:$src)))>;

// Matrix type-conversion instructions operate on accumulator registers.  The
// intrinsic type is polymorphic, so each pattern supplies the source and
// destination matrix MVT explicitly.
class BOSCAMEPatConvert<SDPatternOperator OpNode, Instruction Inst,
                        ValueType DstType, ValueType SrcType>
    : Pat<(DstType (OpNode (SrcType AccReg:$src))),
          (DstType (Inst (SrcType AccReg:$src)))>;

// The first intrinsic operand is the old accumulator. It selects the tied
// md_in operand; the instruction's "$md = $md_in" constraint ties it to md.
class BOSCAMEPatMMA<SDPatternOperator OpNode, Instruction Inst,
                    ValueType TileType, ValueType AccType>
    : Pat<(AccType
            (OpNode (AccType AccReg:$acc),
                    (TileType TileReg:$lhs),
                    (TileType TileReg:$rhs))),
          (AccType
            (Inst (AccType AccReg:$acc),
                  (TileType TileReg:$lhs),
                  (TileType TileReg:$rhs)))>;

class BOSCAMEPatWidenMMA<SDPatternOperator OpNode, Instruction Inst,
                         ValueType TileType, ValueType AccType>
    : Pat<(AccType
            (OpNode (AccType AccReg:$acc),
                    (TileType TileReg:$lhs),
                    (TileType TileReg:$rhs))),
          (AccType
            (Inst (AccType AccReg:$acc),
                  (TileType TileReg:$lhs),
                  (TileType TileReg:$rhs)))>;

let Predicates = [HasVendorXBOSCAME] in {
  // Configuration instructions.
  def : PatGpr<int_riscv_bosc_msettype,  BOSC_AME_MSETTYPE>;
  def : PatGpr<int_riscv_bosc_msettilem, BOSC_AME_MSETTILEM>;
  def : PatGpr<int_riscv_bosc_msettilen, BOSC_AME_MSETTILEN>;
  def : PatGpr<int_riscv_bosc_msettilek, BOSC_AME_MSETTILEK>;

  def : BOSCAMEPatConfigImm<int_riscv_bosc_msettypei,  BOSC_AME_MSETTYPEI>;
  def : BOSCAMEPatConfigImm<int_riscv_bosc_msettypehi, BOSC_AME_MSETTYPEHI>;
  def : BOSCAMEPatConfigImm<int_riscv_bosc_msettilemi, BOSC_AME_MSETTILEMI>;
  def : BOSCAMEPatConfigImm<int_riscv_bosc_msettileni, BOSC_AME_MSETTILENI>;
  def : BOSCAMEPatConfigImm<int_riscv_bosc_msettileki, BOSC_AME_MSETTILEKI>;

  // Additional configuration forms. Register forms return the configured
  // XLEN value, while the SEW/BA forms consume an immediate encoding.
  def : PatGpr<int_riscv_bosc_msettsp, BOSC_AME_MSETTSP>;
  def : PatGpr<int_riscv_bosc_msetdsp, BOSC_AME_MSETDSP>;
  def : PatGpr<int_riscv_bosc_msetpadval, BOSC_AME_MSETPADVAL>;
  def : BOSCAMEPatConfigImm<int_riscv_bosc_msettspi, BOSC_AME_MSETTSPI>;
  def : BOSCAMEPatConfigImm<int_riscv_bosc_msetdspi, BOSC_AME_MSETDSPI>;
  def : BOSCAMEPatConfigSew<int_riscv_bosc_msetsew, BOSC_AME_MSETSEW>;
  def : BOSCAMEPatConfigSew<int_riscv_bosc_msetba, BOSC_AME_MSETBA>;

  // Every conversion below follows the direction in the instruction-table
  // comments.  HB/CF/FQ/FO formats are deliberately omitted.
  def : BOSCAMEPatConvert<int_riscv_bosc_mcvt_x_xu_m, BOSC_AME_MCVT_X_XU_M, 
                          BOSCAME_I64.Matrix, BOSCAME_I64.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mcvt_b_ub_m, BOSC_AME_MCVT_B_UB_M, 
                          BOSCAME_I8.Matrix, BOSCAME_I8.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mcvt_h_uh_m, BOSC_AME_MCVT_H_UH_M, 
                          BOSCAME_I16.Matrix, BOSCAME_I16.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mcvt_w_uw_m, BOSC_AME_MCVT_W_UW_M, 
                          BOSCAME_I32.Matrix, BOSCAME_I32.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mcvt_dw_udw_m, BOSC_AME_MCVT_DW_UDW_M, 
                          BOSCAME_I64.Matrix, BOSCAME_I64.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mcvt_xu_x_m, BOSC_AME_MCVT_XU_X_M, 
                          BOSCAME_I64.Matrix, BOSCAME_I64.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mcvt_ub_b_m, BOSC_AME_MCVT_UB_B_M, 
                          BOSCAME_I8.Matrix, BOSCAME_I8.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mcvt_uh_h_m, BOSC_AME_MCVT_UH_H_M, 
                          BOSCAME_I16.Matrix, BOSCAME_I16.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mcvt_uw_w_m, BOSC_AME_MCVT_UW_W_M, 
                          BOSCAME_I32.Matrix, BOSCAME_I32.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mcvt_udw_dw_m, BOSC_AME_MCVT_UDW_DW_M, 
                          BOSCAME_I64.Matrix, BOSCAME_I64.Matrix>;

  foreach C = ["mwcvtu", "mwcvt"] in {
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_xw_x_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_XW_X_M"), 
                            BOSCAME_I64_XW.Matrix, BOSCAME_I64.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_xq_x_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_XQ_X_M"), 
                            BOSCAME_I64_XQ.Matrix, BOSCAME_I64.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_xo_x_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_XO_X_M"), 
                            BOSCAME_I64_XO.Matrix, BOSCAME_I64.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_h_b_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_H_B_M"), 
                            BOSCAME_I16.Matrix, BOSCAME_I8.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_w_b_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_W_B_M"), 
                            BOSCAME_I32.Matrix, BOSCAME_I8.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_w_h_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_W_H_M"), 
                            BOSCAME_I32.Matrix, BOSCAME_I16.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_dw_w_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_DW_W_M"), 
                            BOSCAME_I64.Matrix, BOSCAME_I32.Matrix>;
  }
  foreach C = ["mncvtu", "mncvt"] in {
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_x_xw_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_X_XW_M"), 
                            BOSCAME_I64.Matrix, BOSCAME_I64_XW.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_x_xq_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_X_XQ_M"), 
                            BOSCAME_I64.Matrix, BOSCAME_I64_XQ.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_x_xo_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_X_XO_M"), 
                            BOSCAME_I64.Matrix, BOSCAME_I64_XO.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_b_h_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_B_H_M"), 
                            BOSCAME_I8.Matrix, BOSCAME_I16.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_b_w_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_B_W_M"), 
                            BOSCAME_I8.Matrix, BOSCAME_I32.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_h_w_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_H_W_M"), 
                            BOSCAME_I16.Matrix, BOSCAME_I32.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_w_dw_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_W_DW_M"), 
                            BOSCAME_I32.Matrix, BOSCAME_I64.Matrix>;
  }

  // FP<->FP. FW is represented by the available f64 accumulator storage.
  def : BOSCAMEPatConvert<int_riscv_bosc_mfcvt_bf_hf_m, BOSC_AME_MFCVT_BF_HF_M, 
                          BOSCAME_BF16.Matrix, BOSCAME_F16.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mfcvt_hf_bf_m, BOSC_AME_MFCVT_HF_BF_M, 
                          BOSCAME_F16.Matrix, BOSCAME_BF16.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mfwcvt_fw_f_m, BOSC_AME_MFWCVT_FW_F_M, 
                          BOSCAME_F64.Matrix, BOSCAME_F32.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mfwcvt_f_hf_m, BOSC_AME_MFWCVT_F_HF_M, 
                          BOSCAME_F32.Matrix, BOSCAME_F16.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mfwcvt_d_f_m, BOSC_AME_MFWCVT_D_F_M, 
                          BOSCAME_F64.Matrix, BOSCAME_F32.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mfncvt_f_fw_m, BOSC_AME_MFNCVT_F_FW_M, 
                          BOSCAME_F32.Matrix, BOSCAME_F64.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mfncvt_hf_f_m, BOSC_AME_MFNCVT_HF_F_M, 
                          BOSCAME_F16.Matrix, BOSCAME_F32.Matrix>;
  def : BOSCAMEPatConvert<int_riscv_bosc_mfncvt_f_d_m, BOSC_AME_MFNCVT_F_D_M, 
                          BOSCAME_F32.Matrix, BOSCAME_F64.Matrix>;

  // Integer -> FP (unsigned and signed, respectively).
  foreach C = ["mfcvtu", "mfcvt"] in {
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_f_x_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_F_X_M"), 
                            BOSCAME_F64.Matrix, BOSCAME_I64.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_hf_h_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_HF_H_M"), 
                            BOSCAME_F16.Matrix, BOSCAME_I16.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_f_w_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_F_W_M"), 
                            BOSCAME_F32.Matrix, BOSCAME_I32.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_d_dw_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_D_DW_M"), 
                            BOSCAME_F64.Matrix, BOSCAME_I64.Matrix>;
  }
  foreach C = ["mfwcvtu", "mfwcvt"] in {
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_fw_x_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_FW_X_M"), 
                            BOSCAME_F64.Matrix, BOSCAME_I64.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_hf_b_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_HF_B_M"), 
                            BOSCAME_F16.Matrix, BOSCAME_I8.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_f_b_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_F_B_M"), 
                            BOSCAME_F32.Matrix, BOSCAME_I8.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_f_h_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_F_H_M"), 
                            BOSCAME_F32.Matrix, BOSCAME_I16.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_d_w_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_D_W_M"), 
                            BOSCAME_F64.Matrix, BOSCAME_I32.Matrix>;
  }
  foreach C = ["mfncvtu", "mfncvt"] in {
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_f_xw_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_F_XW_M"), 
                            BOSCAME_F32.Matrix, BOSCAME_I64_XW.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_hf_w_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_HF_W_M"), 
                            BOSCAME_F16.Matrix, BOSCAME_I32.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_f_dw_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_F_DW_M"), 
                            BOSCAME_F32.Matrix, BOSCAME_I64.Matrix>;
  }

  // FP -> integer (unsigned and signed, respectively).
  foreach C = ["mfcvtu", "mfcvt"] in {
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_x_f_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_X_F_M"), 
                            BOSCAME_I64.Matrix, BOSCAME_F32.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_h_hf_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_H_HF_M"), 
                            BOSCAME_I16.Matrix, BOSCAME_F16.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_w_f_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_W_F_M"), 
                            BOSCAME_I32.Matrix, BOSCAME_F32.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_dw_d_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_DW_D_M"), 
                            BOSCAME_I64.Matrix, BOSCAME_F64.Matrix>;
  }
  foreach C = ["mfwcvtu", "mfwcvt"] in {
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_xw_f_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_XW_F_M"), 
                            BOSCAME_I64_XW.Matrix, BOSCAME_F32.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_w_hf_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_W_HF_M"), 
                            BOSCAME_I32.Matrix, BOSCAME_F16.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_dw_f_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_DW_F_M"), 
                            BOSCAME_I64.Matrix, BOSCAME_F32.Matrix>;
  }
  foreach C = ["mfncvtu", "mfncvt"] in {
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_x_fw_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_X_FW_M"), 
                            BOSCAME_I64.Matrix, BOSCAME_F64.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_b_hf_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_B_HF_M"), 
                            BOSCAME_I8.Matrix, BOSCAME_F16.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_b_f_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_B_F_M"), 
                            BOSCAME_I8.Matrix, BOSCAME_F32.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_h_f_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_H_F_M"), 
                            BOSCAME_I16.Matrix, BOSCAME_F32.Matrix>;
    def : BOSCAMEPatConvert<!cast<SDPatternOperator>("int_riscv_bosc_"#C#"_w_d_m"), 
                            !cast<Instruction>("BOSC_AME_"#!toupper(C)#"_W_D_M"), 
                            BOSCAME_I32.Matrix, BOSCAME_F64.Matrix>;
  }

  // Memory instructions. A given EEW can be used by an integer or a floating
  // matrix type, so both type families get a pattern for the same instruction.
  foreach T = [BOSCAME_I8, BOSCAME_I16, BOSCAME_I32, BOSCAME_I64,
               BOSCAME_F16, BOSCAME_F32, BOSCAME_F64] in {
    foreach Op = ["mlae", "mlate", "mltre", "mlbe", "mlbte"] in
      def : BOSCAMEPatLoad<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#T.Number#"_m"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#T.Number#"_M"),
        T.Matrix>;

    foreach Op = ["mlce", "mlcte", "mlacce"] in
      def : BOSCAMEPatLoad<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#T.Number#"_m"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#T.Number#"_M"),
        T.Matrix>;

    foreach Op = ["msae", "msate", "mstre", "msbe", "msbte"] in
      def : BOSCAMEPatStore<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#T.Number#"_m"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#T.Number#"_M"),
        T.Matrix, TileReg>;

    foreach Op = ["msce", "mscte", "msacce"] in
      def : BOSCAMEPatStore<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#T.Number#"_m"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#T.Number#"_M"),
        T.Matrix, AccReg>;
  }

  foreach T = [BOSCAME_I8, BOSCAME_I16, BOSCAME_I32, BOSCAME_I64] in {
    foreach Op = ["mlufae", "mlufbe", "mlufce"] in
      def : BOSCAMEPatLoad<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#T.Number#"_m"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#T.Number#"_M"),
        T.Matrix>;

    foreach Op = ["msfdae", "msfdbe", "msfdce"] in
      def : BOSCAMEPatStore<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#T.Number#"_m"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#T.Number#"_M"),
        T.Matrix, TileReg>;
  }

  // Vector loads use an LMUL=1 VR result.  The same EEW encoding supports
  // integer and floating-point vector element types.
  foreach T = [BOSCAME_VI8, BOSCAME_VI16, BOSCAME_VI32, BOSCAME_VI64,
               BOSCAME_VF16, BOSCAME_VBF16, BOSCAME_VF32, BOSCAME_VF64] in
    foreach Op = ["mlae", "mlbe", "mlce"] in
      def : BOSCAMEPatVectorLoad<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#T.Number#"_v"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#T.Number#"_V"),
        T.Vector>;

  // The 32-bit vector-store instruction definitions are currently disabled,
  // so only emit patterns for the active 8/16/64-bit instructions.
  foreach T = [BOSCAME_VI8, BOSCAME_VI16, BOSCAME_VI64,
               BOSCAME_VF16, BOSCAME_VBF16, BOSCAME_VF64] in
    foreach Op = ["msae", "msbe", "msce"] in
      def : BOSCAMEPatVectorStore<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#T.Number#"_v"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#T.Number#"_V"),
        T.Vector>;

  // Move matrix rows/columns to vectors and vectors back to matrix
  // rows/columns.  The register-index operand is held in a GPR.
  foreach T = [BOSCAME_VI8, BOSCAME_VI16, BOSCAME_VI32, BOSCAME_VI64,
               BOSCAME_VF16, BOSCAME_VF32, BOSCAME_VF64] in
    foreach Op = ["mmvare", "mmvbre", "mmvcre",
                  "mmvace", "mmvbce", "mmvcce"] in {
      def : BOSCAMEPatMatrixToVector<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#T.Number#"_v_m"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#T.Number#"_V_M"),
        T.Vector, T.Matrix>;
      def : BOSCAMEPatVectorToMatrix<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#T.Number#"_m_v"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#T.Number#"_M_V"),
        T.Matrix, T.Vector>;
    }


  // Integer matrix moves.
  foreach T = [BOSCAME_I8, BOSCAME_I16, BOSCAME_I32, BOSCAME_I64] in {
    def : BOSCAMEPatUnaryMatrix<
      !cast<SDPatternOperator>("int_riscv_bosc_mmve"#T.Number#"_t_t"),
      !cast<Instruction>("BOSC_AME_MMVE"#T.Number#"_T_T"),
      T.Matrix, TileReg, T.Matrix, TileReg>;
    def : BOSCAMEPatUnaryMatrix<
      !cast<SDPatternOperator>("int_riscv_bosc_mmve"#T.Number#"_a_a"),
      !cast<Instruction>("BOSC_AME_MMVE"#T.Number#"_A_A"),
      T.Matrix, AccReg, T.Matrix, AccReg>;

    def : BOSCAMEPatMatrixGPR<
      !cast<SDPatternOperator>("int_riscv_bosc_mmve"#T.Number#"_a_t"),
      !cast<Instruction>("BOSC_AME_MMVE"#T.Number#"_A_T"),
      T.Matrix, AccReg, T.Matrix, TileReg>;
    def : BOSCAMEPatMatrixGPR<
      !cast<SDPatternOperator>("int_riscv_bosc_mmve"#T.Number#"_t_a"),
      !cast<Instruction>("BOSC_AME_MMVE"#T.Number#"_T_A"),
      T.Matrix, TileReg, T.Matrix, AccReg>;

    def : BOSCAMEPatMatrixImm<
      !cast<SDPatternOperator>("int_riscv_bosc_mmvie"#T.Number#"_a_t"),
      !cast<Instruction>("BOSC_AME_MMVIE"#T.Number#"_A_T"),
      T.Matrix, AccReg, T.Matrix, TileReg>;
    def : BOSCAMEPatMatrixImm<
      !cast<SDPatternOperator>("int_riscv_bosc_mmvie"#T.Number#"_t_a"),
      !cast<Instruction>("BOSC_AME_MMVIE"#T.Number#"_T_A"),
      T.Matrix, TileReg, T.Matrix, AccReg>;

    def : BOSCAMEPatMatrixToScalar<
      !cast<SDPatternOperator>("int_riscv_bosc_mmve"#T.Number#"_x_t"),
      !cast<Instruction>("BOSC_AME_MMVE"#T.Number#"_X_T"),
      T.Matrix, TileReg, XLenVT, GPR>;
    def : BOSCAMEPatMatrixToScalar<
      !cast<SDPatternOperator>("int_riscv_bosc_mmve"#T.Number#"_x_a"),
      !cast<Instruction>("BOSC_AME_MMVE"#T.Number#"_X_A"),
      T.Matrix, AccReg, XLenVT, GPR>;

    def : BOSCAMEPatScalarToMatrix<
      !cast<SDPatternOperator>("int_riscv_bosc_mmve"#T.Number#"_t_x"),
      !cast<Instruction>("BOSC_AME_MMVE"#T.Number#"_T_X"),
      T.Matrix, TileReg, XLenVT, GPR>;
    def : BOSCAMEPatScalarToMatrix<
      !cast<SDPatternOperator>("int_riscv_bosc_mmve"#T.Number#"_a_x"),
      !cast<Instruction>("BOSC_AME_MMVE"#T.Number#"_A_X"),
      T.Matrix, AccReg, XLenVT, GPR>;
  }

  // Floating matrix moves. These require the corresponding real instruction
  // classes to use T.ScalarRC, not GPR, for their scalar float operand/result.
  foreach T = [BOSCAME_F16, BOSCAME_F32, BOSCAME_F64] in {
    def : BOSCAMEPatMatrixToScalar<
      !cast<SDPatternOperator>("int_riscv_bosc_mfmve"#T.Number#"_f_t"),
      !cast<Instruction>("BOSC_AME_MFMVE"#T.Number#"_F_T"),
      T.Matrix, TileReg, T.Scalar, T.ScalarRC>;
    def : BOSCAMEPatMatrixToScalar<
      !cast<SDPatternOperator>("int_riscv_bosc_mfmve"#T.Number#"_f_a"),
      !cast<Instruction>("BOSC_AME_MFMVE"#T.Number#"_F_A"),
      T.Matrix, AccReg, T.Scalar, T.ScalarRC>;
    def : BOSCAMEPatScalarToMatrix<
      !cast<SDPatternOperator>("int_riscv_bosc_mfmve"#T.Number#"_t_f"),
      !cast<Instruction>("BOSC_AME_MFMVE"#T.Number#"_T_F"),
      T.Matrix, TileReg, T.Scalar, T.ScalarRC>;
    def : BOSCAMEPatScalarToMatrix<
      !cast<SDPatternOperator>("int_riscv_bosc_mfmve"#T.Number#"_a_f"),
      !cast<Instruction>("BOSC_AME_MFMVE"#T.Number#"_A_F"),
      T.Matrix, AccReg, T.Scalar, T.ScalarRC>;
  }

  // Broadcast and transpose. The unsuffixed row-broadcast forms are matched
  // for every currently supported matrix MVT; the real instruction controls
  // the fixed encoding.
  foreach T = [BOSCAME_I8, BOSCAME_I16, BOSCAME_I32, BOSCAME_I64,
               BOSCAME_F16, BOSCAME_F32, BOSCAME_F64] in {
    foreach Op = ["mbcar", "mbcbr"] in
      def : BOSCAMEPatUnaryMatrix<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_m"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_M"),
        T.Matrix, TileReg, T.Matrix, TileReg>;
    def : BOSCAMEPatUnaryMatrix<
      int_riscv_bosc_mbccr_m, BOSC_AME_MBCCR_M,
      T.Matrix, AccReg, T.Matrix, AccReg>;

    foreach Op = ["mbcace", "mbcbce", "mbcaee", "mbcbee", "mtae", "mtbe"] in
      def : BOSCAMEPatUnaryMatrix<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#T.Number#"_m"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#T.Number#"_M"),
        T.Matrix, TileReg, T.Matrix, TileReg>;

    foreach Op = ["mbccce", "mbccee", "mtce"] in
      def : BOSCAMEPatUnaryMatrix<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#T.Number#"_m"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#T.Number#"_M"),
        T.Matrix, AccReg, T.Matrix, AccReg>;
  }

  // No-widen integer element-wise operations with EEW inherited from mtype.
  foreach T = [BOSCAME_I8, BOSCAME_I16, BOSCAME_I32, BOSCAME_I64] in {
    foreach Op = ["maddu", "msaddu", "madd", "msadd",
                  "msubu", "mssubu", "msub", "mssub",
                  "mminu", "mmaxu", "mmin", "mmax",
                  "msmulu", "mmul", "msmul",
                  "mmulhu", "mmulh", "mmulhsu", "msmulsu",
                  "mand", "mor", "mxor", "msll", "msrl", "msra"] in
      def : BOSCAMEPatAccBinary<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_mm"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_MM"),
        T.Matrix>;
  }

  // Explicit B/H/W/DW forms. Logic instructions intentionally do not appear:
  // their ISA definitions only provide the mtype-controlled .mm forms.
  foreach T = [BOSCAME_I8, BOSCAME_I16, BOSCAME_I32, BOSCAME_I64] in {
    foreach Op = ["maddu", "msaddu", "madd", "msadd",
                  "msubu", "mssubu", "msub", "mssub",
                  "mminu", "mmaxu", "mmin", "mmax",
                  "msmulu", "mmul", "msmul",
                  "mmulhu", "mmulh", "mmulhsu", "msmulsu"] in
      def : BOSCAMEPatAccBinary<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_"#
                                  !tolower(T.Suffix)#"_mm"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_"#T.Suffix#"_MM"),
        T.Matrix>;

    foreach Op = ["msll", "msrl", "msra"] in
      def : BOSCAMEPatAccBinary<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_"#
                                  !tolower(T.Suffix)#"_mm"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_"#T.Suffix#"_MM"),
        T.Matrix>;
  }

  // No-widen floating element-wise operations.
  foreach T = [BOSCAME_F16, BOSCAME_F32, BOSCAME_F64] in {
    foreach Op = ["mfadd", "mfsub", "mfmin", "mfmax", "mfmul", "mfdiv"] in
      def : BOSCAMEPatAccBinary<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_mm"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_MM"),
        T.Matrix>;

    foreach Op = ["mfadd", "mfsub", "mfmin", "mfmax", "mfmul", "mfdiv"] in
      def : BOSCAMEPatAccBinary<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_"#
                                  !tolower(T.Suffix)#"_mm"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_"#T.Suffix#"_MM"),
        T.Matrix>;

    def : BOSCAMEPatAccUnary<
      !cast<SDPatternOperator>("int_riscv_bosc_mfsqrt_"#
                                !tolower(T.Suffix)#"_m"),
      !cast<Instruction>("BOSC_AME_MFSQRT_"#T.Suffix#"_M"),
      T.Matrix>;
  }

  // The LLVM intrinsic and selected ISA instruction both use the unary `.m`
  // suffix.
  foreach T = [BOSCAME_F16, BOSCAME_F32, BOSCAME_F64] in
    def : BOSCAMEPatAccUnary<int_riscv_bosc_mfsqrt_m,
                              BOSC_AME_MFSQRT_M, T.Matrix>;

  // Integer element-wise widening.
  foreach W = [BOSCAME_I8_TO_I16, BOSCAME_I16_TO_I32,
               BOSCAME_I32_TO_I64] in {
    foreach Op = ["mwaddu", "mwadd", "mwsubu", "mwsub",
                  "mwmulu", "mwmul", "mwmulsu"] in {
      def : BOSCAMEPatAccBinaryWiden<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_mm"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_MM"),
        W.Dst.Matrix, W.Src.Matrix>;
      def : BOSCAMEPatAccBinaryWiden<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_"#
                                  !tolower(W.Suffix)#"_mm"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_"#W.Suffix#"_MM"),
        W.Dst.Matrix, W.Src.Matrix>;
    }
  }

  // Floating element-wise widening. cf requires an f8 matrix MVT and is
  // deliberately not matched by this file.
  foreach W = [BOSCAME_F16_TO_F32, BOSCAME_F32_TO_F64] in {
    foreach Op = ["mfwadd", "mfwsub", "mfwmul"] in {
      def : BOSCAMEPatAccBinaryWiden<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_mm"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_MM"),
        W.Dst.Matrix, W.Src.Matrix>;
      def : BOSCAMEPatAccBinaryWiden<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_"#
                                  !tolower(W.Suffix)#"_mm"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_"#W.Suffix#"_MM"),
        W.Dst.Matrix, W.Src.Matrix>;
    }
  }

  // No-widen integer MMA. The generic .mm form is selected once per concrete
  // matrix MVT, including i8; explicit forms exist only for H/W/DW.
  foreach T = [BOSCAME_I8, BOSCAME_I16, BOSCAME_I32, BOSCAME_I64] in {
    foreach Op = ["mma", "msma", "mmau", "msmau"] in
      def : BOSCAMEPatMMA<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_mm"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_MM"),
        T.Matrix, T.Matrix>;
  }
  foreach T = [BOSCAME_I16, BOSCAME_I32, BOSCAME_I64] in
    foreach Op = ["mma", "msma", "mmau", "msmau"] in
      def : BOSCAMEPatMMA<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_"#
                                  !tolower(T.Suffix)#"_mm"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_"#T.Suffix#"_MM"),
        T.Matrix, T.Matrix>;

  // No-widen floating MMA.
  foreach T = [BOSCAME_F16, BOSCAME_F32, BOSCAME_F64] in {
    def : BOSCAMEPatMMA<int_riscv_bosc_mfma_mm, BOSC_AME_MFMA_MM,
                          T.Matrix, T.Matrix>;
    def : BOSCAMEPatMMA<
      !cast<SDPatternOperator>("int_riscv_bosc_mfma_"#
                                !tolower(T.Suffix)#"_mm"),
      !cast<Instruction>("BOSC_AME_MFMA_"#T.Suffix#"_MM"),
      T.Matrix, T.Matrix>;
  }

  // Double-widen integer MMA.
  foreach W = [BOSCAME_I16_TO_I32_MMA, BOSCAME_I32_TO_I64_MMA] in {
    foreach Op = ["mwmau", "mswmau", "mwma", "mswma"] in {
      def : BOSCAMEPatWidenMMA<
          !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_mm"),
          !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_MM"),
          W.Src.Matrix, W.Dst.Matrix>;
      def : BOSCAMEPatWidenMMA<
          !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_"#
                                    !tolower(W.Suffix)#"_mm"),
          !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_"#W.Suffix#"_MM"),
          W.Src.Matrix, W.Dst.Matrix>;
    }
  }

  // Double-widen floating MMA. cf requires f8 support.
  foreach W = [BOSCAME_F16_TO_F32, BOSCAME_F32_TO_F64] in {
    def : BOSCAMEPatWidenMMA<
      int_riscv_bosc_mfwma_mm, BOSC_AME_MFWMA_MM,
      W.Src.Matrix, W.Dst.Matrix>;
    def : BOSCAMEPatWidenMMA<
      !cast<SDPatternOperator>("int_riscv_bosc_mfwma_"#
                                !tolower(W.Suffix)#"_mm"),
      !cast<Instruction>("BOSC_AME_MFWMA_"#W.Suffix#"_MM"),
      W.Src.Matrix, W.Dst.Matrix>;
  }

  // Quad-widen integer MMA: i8 -> i32.
  foreach Op = ["mqmau", "msqmau", "mqma", "msqma"] in {
    def : BOSCAMEPatWidenMMA<
      !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_mm"),
      !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_MM"),
      BOSCAME_I8.Matrix, BOSCAME_I32.Matrix>;
    def : BOSCAMEPatWidenMMA<
      !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_b_mm"),
      !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_B_MM"),
      BOSCAME_I8.Matrix, BOSCAME_I32.Matrix>;
  }

  // Sparse no-widen MMA. Sparse A/B variants share the same DAG shape; the
  // sparse selector is encoded in the instruction name and does not alter
  // the intrinsic operands.
  foreach T = [BOSCAME_I8, BOSCAME_I16, BOSCAME_I32, BOSCAME_I64] in
    foreach Sp = ["spa", "spb"] in
      foreach Op = ["mma", "msma", "mmau", "msmau"] in
        def : BOSCAMEPatMMA<
          !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_"#Sp#"_mm"),
          !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_"#!toupper(Sp)#"_MM"),
          T.Matrix, T.Matrix>;

  foreach T = [BOSCAME_I16, BOSCAME_I32, BOSCAME_I64] in
    foreach Sp = ["spa", "spb"] in
      foreach Op = ["mma", "msma", "mmau", "msmau"] in
        def : BOSCAMEPatMMA<
          !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_"#Sp#"_"#
                                    !tolower(T.Suffix)#"_mm"),
          !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_"#!toupper(Sp)#"_"#
                             T.Suffix#"_MM"),
          T.Matrix, T.Matrix>;

  foreach T = [BOSCAME_F16, BOSCAME_F32, BOSCAME_F64] in
    foreach Sp = ["spa", "spb"] in
      def : BOSCAMEPatMMA<
        !cast<SDPatternOperator>("int_riscv_bosc_mfma_"#Sp#"_mm"),
        !cast<Instruction>("BOSC_AME_MFMA_"#!toupper(Sp)#"_MM"),
        T.Matrix, T.Matrix>;

  foreach T = [BOSCAME_F16, BOSCAME_F32, BOSCAME_F64] in
    foreach Sp = ["spa", "spb"] in
      def : BOSCAMEPatMMA<
        !cast<SDPatternOperator>("int_riscv_bosc_mfma_"#Sp#"_"#
                                  !tolower(T.Suffix)#"_mm"),
        !cast<Instruction>("BOSC_AME_MFMA_"#!toupper(Sp)#"_"#T.Suffix#"_MM"),
        T.Matrix, T.Matrix>;

  // Sparse double-widen MMA: H->W and W->DW (and HF->F/F->D).
  foreach W = [BOSCAME_I16_TO_I32_MMA, BOSCAME_I32_TO_I64_MMA] in
    foreach Sp = ["spa", "spb"] in
      foreach Op = ["mwmau", "mswmau", "mwma", "mswma"] in {
        def : BOSCAMEPatWidenMMA<
          !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_"#Sp#"_mm"),
          !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_"#!toupper(Sp)#"_MM"),
          W.Src.Matrix, W.Dst.Matrix>;
        def : BOSCAMEPatWidenMMA<
          !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_"#Sp#"_"#
                                    !tolower(W.Suffix)#"_mm"),
          !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_"#!toupper(Sp)#"_"#
                             W.Suffix#"_MM"),
          W.Src.Matrix, W.Dst.Matrix>;
      }

  foreach W = [BOSCAME_F16_TO_F32, BOSCAME_F32_TO_F64] in
    foreach Sp = ["spa", "spb"] in {
      def : BOSCAMEPatWidenMMA<
        !cast<SDPatternOperator>("int_riscv_bosc_mfwma_"#Sp#"_mm"),
        !cast<Instruction>("BOSC_AME_MFWMA_"#!toupper(Sp)#"_MM"),
        W.Src.Matrix, W.Dst.Matrix>;
      def : BOSCAMEPatWidenMMA<
        !cast<SDPatternOperator>("int_riscv_bosc_mfwma_"#Sp#"_"#
                                  !tolower(W.Suffix)#"_mm"),
        !cast<Instruction>("BOSC_AME_MFWMA_"#!toupper(Sp)#"_"#W.Suffix#"_MM"),
        W.Src.Matrix, W.Dst.Matrix>;
    }

  // Sparse quad-widen integer MMA: i8 -> i32.
  foreach Sp = ["spa", "spb"] in {
    foreach Op = ["mqmau", "msqmau", "mqma", "msqma"] in {
      def : BOSCAMEPatWidenMMA<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_"#Sp#"_mm"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_"#!toupper(Sp)#"_MM"),
        BOSCAME_I8.Matrix, BOSCAME_I32.Matrix>;
      def : BOSCAMEPatWidenMMA<
        !cast<SDPatternOperator>("int_riscv_bosc_"#Op#"_"#Sp#"_b_mm"),
        !cast<Instruction>("BOSC_AME_"#!toupper(Op)#"_"#!toupper(Sp)#"_B_MM"),
        BOSCAME_I8.Matrix, BOSCAME_I32.Matrix>;
    }
  }
}

// Unsupported until the type layer is implemented:
//
//   * *_HB_* and MOM*/MSOM*/MOM*/MSOM* need an explicit packed int4 matrix
//     ValueType plus TileReg/AccReg and RISCVISelLowering registration.
//   * *_CF_* and MFQMA_CF need an f8 matrix ValueType plus corresponding
//     register-class and lowering support.
//
// Do not map either family to i8/f16 merely to make TableGen compile: that
// would select a real instruction with a semantically incorrect LLVM type.
