//===-- RISCVSchedSpacemitA100.td - A100 IME Scheduling ------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// Retain the scalar/RVV scheduling approximations previously inherited from
// SpacemitX60Model, but give A100 a separate model and a pipelined IME unit.
// A100-specific RVV timings remain to be calibrated; sharing these definitions
// does not imply that X60 timings describe A100's 1024-bit vector datapath.
//
// Calibrated on K3 A100: dependent int8 / sparse int8 / HP / FP16 dot chains
// take 8 / 9 / 10 / 10 cycles, respectively. Twelve independent accumulators
// sustain approximately one dot per cycle (including loop control overhead).
// All dot variants share the same pipelined execution resource.
// Use InstRW so both the real MC instructions and the vector pseudos carry
// these timings, without requiring unrelated CPU models to implement XSMT.
def SpacemitA100Model : SpacemitX60SchedModel;
// Back-to-back vsetvli/vsetivli configurations measured three cycles;
// register-configured vsetvl measured four cycles.
defm SMTA100Base : SpacemitX60ModelResources<SpacemitA100Model, 3, 4>;
defm SMTA100Base : SpacemitX60CopyResources<SpacemitA100Model, "SMTA100Base">;

let SchedModel = SpacemitA100Model in {
  def SMTA100_IME : ProcResource<1>;
  let ReleaseAtCycles = [1] in {
    def SMTA100WriteIntDot : SchedWriteRes<[SMTA100_IME]> { let Latency = 8; }
    def SMTA100WriteSparseDot : SchedWriteRes<[SMTA100_IME]> { let Latency = 9; }
    def SMTA100WriteHPDot : SchedWriteRes<[SMTA100_IME]> { let Latency = 10; }
    def SMTA100WriteFPDot : SchedWriteRes<[SMTA100_IME]> { let Latency = 10; }
  }
  def : InstRW<[SMTA100WriteIntDot, ReadDefault, ReadDefault, ReadDefault],
               (instrs VMADOT, VMADOTU, VMADOTSU, VMADOTUS,
                       PseudoSMT_VMADOT_M1, PseudoSMT_VMADOTU_M1,
                       PseudoSMT_VMADOTSU_M1, PseudoSMT_VMADOTUS_M1)>;
  def : InstRW<[SMTA100WriteSparseDot, ReadDefault, ReadDefault, ReadDefault,
                ReadDefault],
               (instrs VMADOT_SP, VMADOTU_SP, VMADOTSU_SP, VMADOTUS_SP,
                       PseudoSMT_VMADOT_SP_M1, PseudoSMT_VMADOTU_SP_M1,
                       PseudoSMT_VMADOTSU_SP_M1, PseudoSMT_VMADOTUS_SP_M1)>;
  def : InstRW<[SMTA100WriteHPDot, ReadDefault, ReadDefault, ReadDefault,
                ReadDefault],
               (instrs VMADOT_HP, VMADOTU_HP, VMADOTSU_HP, VMADOTUS_HP,
                       PseudoSMT_VMADOT_HP_M1, PseudoSMT_VMADOTU_HP_M1,
                       PseudoSMT_VMADOTSU_HP_M1, PseudoSMT_VMADOTUS_HP_M1)>;
  def : InstRW<[SMTA100WriteFPDot, ReadDefault, ReadDefault, ReadDefault],
               (instrs VFWMADOT, PseudoSMT_VFWMADOT_M1)>;

  // K3 A100 LMUL=1 measurements across all supported SEWs and immediates:
  // pack has five-cycle dependency latency / four-cycle reciprocal throughput;
  // single-register narrowing packs have three / two cycles, respectively.
  // upack is operand-dependent: immediates 0/1 sustain one operation per
  // thirteen cycles, 2 averages 5.5 cycles in alternating dependent chains
  // (conservatively model six cycles for the pair),
  // and 3 has a five-cycle dependency. Immediates 2/3 sustain one per four.
  // Model them on the vector integer resource. Contention with other RVV
  // instruction classes remains an approximation, as in the base RVV model.
  def SMTA100WritePack : SchedWriteRes<[SMTA100Base_VIEU]> {
    let Latency = 5;
    let ReleaseAtCycles = [4];
  }
  def SMTA100WriteNarrowPack : SchedWriteRes<[SMTA100Base_VIEU]> {
    let Latency = 3;
    let ReleaseAtCycles = [2];
  }
  def SMTA100WriteSlowUnpack : SchedWriteRes<[SMTA100Base_VIEU]> {
    let Latency = 13;
    let ReleaseAtCycles = [13];
  }
  def SMTA100WriteUnpack256 : SchedWriteRes<[SMTA100Base_VIEU]> {
    let Latency = 6;
    let ReleaseAtCycles = [4];
  }
  // imm2 is operand 3 in both the real instruction and its vector pseudo.
  // MC predicates keep llc and llvm-mca on the same operand-dependent model.
  def SMTA100WriteUnpack : SchedWriteVariant<[
    SchedVar<MCSchedPredicate<CheckImmOperandLT<3, 2>>,
             [SMTA100WriteSlowUnpack]>,
    SchedVar<MCSchedPredicate<CheckImmOperand<3, 2>>,
             [SMTA100WriteUnpack256]>,
    SchedVar<NoSchedPred, [SMTA100WritePack]>
  ]>;
  def : InstRW<[SMTA100WritePack, ReadDefault, ReadDefault],
               (instrs VPACK_VV, PseudoSMT_VPACK_VV_M1)>;
  def : InstRW<[SMTA100WriteUnpack, ReadDefault, ReadDefault],
               (instrs VUPACK_VV, PseudoSMT_VUPACK_VV_M1)>;
  def : InstRW<[SMTA100WriteNarrowPack, ReadDefault, ReadDefault],
               (instrs VNPACK_VV, VNSPACK_VV, VNPACK4_VV, VNSPACK4_VV,
                       PseudoSMT_VNPACK_VV_M1, PseudoSMT_VNSPACK_VV_M1,
                       PseudoSMT_VNPACK4_VV_M1, PseudoSMT_VNSPACK4_VV_M1)>;
}
