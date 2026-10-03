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
}
