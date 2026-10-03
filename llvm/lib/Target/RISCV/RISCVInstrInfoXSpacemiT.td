//===-- RISCVInstrInfoXSpacemiT.td -------------------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the vendor extensions defined by SpacemiT.
//
//===----------------------------------------------------------------------===//

include "RISCVInstrFormatsSpacemitV.td"

// A100 dot instruction and pseudo scheduling is supplied by InstRW mappings
// in RISCVSchedSpacemitA100.td, including accumulator dependency latencies.

let DecoderNamespace = "XSMT" in {
  let Predicates = [HasVendorXSMTVDot, IsRV64], ElementsDependOn = EltDepsNone,
      VS1VS2Constraint = WidenV, DestEEW = EEWSEWx4 in {
    // Base vector dot product (no slide) instructions
    // NOTE: Destination registers (vd) MUST be even-numbered (v0, v2, ..., v30)
    //       due to the number of elements processed requires a pair of register operations.
    // Using odd registers may cause undefined behavior.

    foreach a = VTypeEncodes in
      def SMT_VMADOT#!toupper(a.Name) :
            SMTVMADot<a.Encoding, "smt.vmadot"#a.Name>, Sched<[]>;

    //===----------------------------------------------------------------------===//
    // Sliding-window Vector Dot Product Instructions
    //
    // The numeric suffix (1, 2, 3) specifies the stride of the sliding window:
    //   1: Window slides by 1 element per operation
    //   2: Window slides by 2 elements per operation
    //   3: Window slides by 3 elements per operation
    //
    // These instructions compute dot products with overlapping operand windows
    // where the window position increments by <N> elements between
    // computations.
    //===----------------------------------------------------------------------===//
    // NOTE: Destination registers (vd) and first source register (vs1) MUST be
    //       even-numbered (v0, v2, ..., v30) due to the number of elements processed
    //       requires a pair of register operations.
    //       Using odd registers may cause undefined behavior.

    foreach a = SlideEncodes in
      foreach b = VTypeEncodes in
        def SMT_VMADOT#!toupper(a.Name)#!toupper(b.Name) :
            SMTVMADotSlide<a.Encoding, b.Encoding, "smt.vmadot"#a.Name#b.Name>, Sched<[]>;
  }

  class VFWMADTSLIDE_INSN<bits<3> funct3, string opcodestr>
      : SMTVFWMADOT<funct3, (outs VRM2:$vd_wb),
                    (ins VRM2:$vd, VRM2:$vs1, VR:$vs2),
                    opcodestr, "$vd, $vs1, $vs2">, Sched<[]>;

  class VNPACK_INSN<bits<7> funct7, bit funct1, string opcodestr>
      : SMTVPACK<funct7, funct1, (outs VR:$vd),
                 (ins VR:$vs1, VR:$vs2, uimm2:$imm2), opcodestr,
                 "$vd, $vs1, $vs2, $imm2">, Sched<[]>;

  class VPACK_INSN<bits<7> funct7, bit funct1, string opcodestr>
      : SMTVPACK<funct7, funct1, (outs VRM2:$vd),
                 (ins VR:$vs1, VR:$vs2, uimm2:$imm2), opcodestr,
                 "$vd, $vs1, $vs2, $imm2">, Sched<[]>;

  let Predicates = [HasVendorXSMTVDotII, IsRV64], ElementsDependOn = EltDepsNone in {
    let VS1VS2Constraint = WidenV in {
      // Base VMADOT II instructions
      // Support smt.vmadot/smt.vmadotu/smt.vmadotus/smt.vmadotsu
      foreach a = VTypeEncodes in
        def VMADOT#!toupper(a.Name) :
            SMTVMADotII<a.Encoding, "smt.vmadot"#a.Name>, Sched<[]>;

      // VMADOT Slide
      foreach a = SlideEncodes in
        foreach b = VTypeEncodes in
          def VMADOT#!toupper(a.Name)#!toupper(b.Name):
              SMTVMADotSlideII<a.Encoding, b.Encoding, "smt.vmadot"#a.Name#b.Name>, Sched<[]>;

      // Support smt.vmadot.sp/smt.vmadotu.sp/smt.vmadotus.sp/smt.vmadotsu.sp
      foreach a = VTypeEncodes in
        def VMADOT#!toupper(a.Name)#_SP :
            SMTVMADOTSP<a.Encoding, "smt.vmadot"#a.Name#".sp",
                        "$vd, $vs1, $vs2, $vmask, $imm2$vtype">, Sched<[]>;

      // Support smt.vmadot.hp/smt.vmadotu.hp/smt.vmadotus.hp/smt.vmadotsu.hp
      foreach c = HPEncodes in
        def VMADOT#!toupper(c.Name)#_HP :
            SMTVMADOTHP<c.Encoding, "smt.vmadot"#c.Name#".hp",
                        "$vd, $vs1, $vs2, $vmask, $imm3$vtype">, Sched<[]>;

      let DestEEW = EEWSEWx2, Constraints = "$vd = $vd_wb" in {
        // VFWMADOT
        def VFWMADOT :
            SMTVFWMADOT<0b100, (outs VRM2:$vd_wb),
                        (ins VRM2:$vd, VR:$vs1, VR:$vs2),
                        "smt.vfwmadot", "$vd, $vs1, $vs2">, Sched<[]>;
        // VFWMADOT Slide
        def VFWMADOT1 : VFWMADTSLIDE_INSN<0b101, "smt.vfwmadot1">;
        def VFWMADOT2 : VFWMADTSLIDE_INSN<0b110, "smt.vfwmadot2">;
        def VFWMADOT3 : VFWMADTSLIDE_INSN<0b111, "smt.vfwmadot3">;
      }

      def VNPACK_VV : VNPACK_INSN<0b0110001, 0b0, "smt.vnpack.vv">;
      def VNSPACK_VV : VNPACK_INSN<0b0110001, 0b1, "smt.vnspack.vv">;
      def VNPACK4_VV : VNPACK_INSN<0b0100001, 0b0, "smt.vnpack4.vv">;
      def VNSPACK4_VV : VNPACK_INSN<0b0100001, 0b1, "smt.vnspack4.vv">;
      def VPACK_VV : VPACK_INSN<0b0110011, 0b0, "smt.vpack.vv">;
      def VUPACK_VV : VPACK_INSN<0b0110011, 0b1, "smt.vupack.vv">;
    }
  }
} // DecoderNamespace = "XSMT"

// These native tile overloads assume VLEN=1024 (vscale=16). In particular,
// nxv8i8 is a 128-byte 8x16 int8 tile only at that VLEN. A100 enables
// zvl1024b, but software must execute on its fixed-1024-bit vector cores.
// A100 matrix operands occupy one vector register, while the accumulator
// occupies an aligned pair. Model the required e32,m1 VTYPE independently of
// the accumulator's register class. The matrix instruction reads the entire
// tile, including the second accumulator register, irrespective of VL.
class SMTDotPseudo<Instruction Base, bit IsInteger>
    : RISCVVPseudo<(outs VRM2:$vd_wb),
                    !if(IsInteger,
                        (ins VRM2:$vd, VR:$vs1, VR:$vs2, SMT_INT:$vtype,
                             AVL:$vl, sew:$sew),
                        (ins VRM2:$vd, VR:$vs1, VR:$vs2,
                             AVL:$vl, sew:$sew))> {
  let BaseInstr = Base;
  let VLMul = 0; // LMUL=1 is mandatory even though vd occupies two registers.
  let HasVLOp = 1;
  let HasSEWOp = 1;
  let ReadsPastVL = 1;
  let Uses = [VL, VTYPE];
  let Constraints = "@earlyclobber $vd_wb, $vd = $vd_wb";
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

// HP writes a single register. SP writes a pair and reads a pair for A.
// Both instructions use LMUL=1 regardless of their operand register groups.
// ImmArg operands arrive as TargetConstant nodes, with an i32 IR type.
def smt_uimm3 : RISCVOp<i32>, TImmLeaf<i32, [{ return isUInt<3>(Imm); }]> {
  let OperandType = "OPERAND_UIMM3";
}
def smt_uimm2 : RISCVOp<i32>, TImmLeaf<i32, [{ return isUInt<2>(Imm); }]> {
  let OperandType = "OPERAND_UIMM2";
}

class SMTParamDotPseudo<Instruction Base, bit IsHP>
    : RISCVVPseudo<!if(IsHP, (outs VR:$vd_wb), (outs VRM2:$vd_wb)),
                    !if(IsHP,
                        (ins VR:$vd, ZZZ_VRSMTNoV0V1:$vs1, ZZZ_VRSMTNoV0V1:$vs2,
                             ZZZ_VRSMTV0V1:$vmask, smt_uimm3:$imm, SMT_INT:$vtype,
                             AVL:$vl, sew:$sew),
                        (ins VRM2:$vd, VRM2NoV0:$vs1, ZZZ_VRSMTNoV0V1:$vs2,
                             ZZZ_VRSMTV0V1:$vmask, smt_uimm2:$imm, SMT_INT:$vtype,
                             AVL:$vl, sew:$sew))> {
  let BaseInstr = Base;
  let VLMul = 0;
  let HasVLOp = 1;
  let HasSEWOp = 1;
  let ReadsPastVL = 1;
  let Uses = [VL, VTYPE];
  let Constraints = "@earlyclobber $vd_wb, $vd = $vd_wb";
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

let Predicates = [HasVendorXSMTVDotII, IsRV64] in {
  foreach Suffix = ["", "u", "su", "us"] in {
    defvar HPReal = !cast<Instruction>("VMADOT" # !toupper(Suffix) # "_HP");
    defvar SPReal = !cast<Instruction>("VMADOT" # !toupper(Suffix) # "_SP");
    defvar HPIntr = !cast<Intrinsic>("int_riscv_ime_vmadot" # Suffix # "_hp");
    defvar SPIntr = !cast<Intrinsic>("int_riscv_ime_vmadot" # Suffix # "_sp");
    def "PseudoSMT_VMADOT" # !toupper(Suffix) # "_HP_M1" :
        SMTParamDotPseudo<HPReal, 1>;
    def "PseudoSMT_VMADOT" # !toupper(Suffix) # "_SP_M1" :
        SMTParamDotPseudo<SPReal, 0>;
    def : Pat<(HPIntr nxv4f16:$vd, nxv8i8:$vs1, nxv8i8:$vs2,
                      nxv4f16:$vmask, smt_uimm3:$imm),
              (!cast<Instruction>("PseudoSMT_VMADOT" # !toupper(Suffix) # "_HP_M1")
                  VR:$vd, ZZZ_VRSMTNoV0V1:$vs1, ZZZ_VRSMTNoV0V1:$vs2, ZZZ_VRSMTV0V1:$vmask,
                  smt_uimm3:$imm, (XLenVT 3), (XLenVT -1), (XLenVT 4))>;
    def : Pat<(SPIntr nxv4i32:$vd, nxv16i8:$vs1, nxv8i8:$vs2,
                      nxv8i8:$vmask, smt_uimm2:$imm),
              (!cast<Instruction>("PseudoSMT_VMADOT" # !toupper(Suffix) # "_SP_M1")
                  VRM2:$vd, VRM2NoV0:$vs1, ZZZ_VRSMTNoV0V1:$vs2, ZZZ_VRSMTV0V1:$vmask,
                  smt_uimm2:$imm, (XLenVT 3), (XLenVT -1), (XLenVT 5))>;

    defvar Real = !cast<Instruction>("VMADOT" # !toupper(Suffix));
    defvar Intr = !cast<Intrinsic>("int_riscv_ime_vmadot" # Suffix);
    def "PseudoSMT_VMADOT" # !toupper(Suffix) # "_M1" :
        SMTDotPseudo<Real, 1>;
    def : Pat<(nxv4i32 (Intr nxv4i32:$vd, nxv8i8:$vs1, nxv8i8:$vs2)),
              (!cast<Instruction>("PseudoSMT_VMADOT" # !toupper(Suffix) # "_M1")
                  VRM2:$vd, VR:$vs1, VR:$vs2,
                  (XLenVT 3), (XLenVT -1), (XLenVT 5))>;
  }

  def PseudoSMT_VFWMADOT_M1 : SMTDotPseudo<VFWMADOT, 0>;
  def : Pat<(nxv4f32 (int_riscv_ime_vfmadot
                       nxv4f32:$vd, nxv4f16:$vs1, nxv4f16:$vs2)),
            (PseudoSMT_VFWMADOT_M1 VRM2:$vd, VR:$vs1, VR:$vs2,
                                 (XLenVT -1), (XLenVT 5))>;
}
