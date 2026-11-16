//===-- RISCVXAMEState.cpp - AME register state preservation
//------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// Author: BOSC & ICT, CAS
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/RISCVBaseInfo.h"
#include "RISCV.h"
#include "RISCVInstrInfo.h"
#include "RISCVRegisterInfo.h"
#include "RISCVSubtarget.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/Support/RISCVXAME.h"
#include <algorithm>

using namespace llvm;

namespace {
class RISCVXAMEState : public MachineFunctionPass {
public:
  static char ID;
  RISCVXAMEState() : MachineFunctionPass(ID) {}
  StringRef getPassName() const override {
    return "RISC-V xame-state register state preservation";
  }
  bool runOnMachineFunction(MachineFunction &MF) override;
  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    MachineFunctionPass::getAnalysisUsage(AU);
  }
};

// Expand before PEI: copies may create stack objects, and every address is
// materialized with a normal frame-index ADDI. No vector-length state is used.
static void transfer(MachineInstr &At, Register Reg, int FI, bool Reload,
                     const RISCVInstrInfo &TII, const RISCVRegisterInfo &TRI) {
  MachineBasicBlock &MBB = *At.getParent();
  DebugLoc DL = At.getDebugLoc();
  bool Acc = RISCV::ZTTAAnyRegClass.contains(Reg);
  const auto &ST = MBB.getParent()->getSubtarget<RISCVSubtarget>();
  const auto Profile = RISCV::getXAMEProfile(ST.hasXAMEGem5());
  unsigned MBytes = Profile.getMRegisterBytes();
  unsigned AccMImages = Profile.getAccMImages();
  unsigned Base = TRI.getEncodingValue(Reg);
  const auto *RC = TRI.getMinimalPhysRegClass(Reg);
  unsigned Count =
      TRI.getRegSizeInBits(*RC).getFixedValue() / (Acc ? 4096 : 2048);
  // ACC values are moved through a temporary M image.  The architectural ACC
  // spill size only covers the logical accumulator payload, while this
  // descriptor-aware sequence also saves the old M scratch images before the
  // move and restores them afterwards.  Grow the existing spill object before
  // PEI lays out the frame; otherwise the high scratch offsets would alias the
  // next stack object.
  unsigned ScratchBytes = 0;
  if (Acc) {
    unsigned Scratch = 8 + AccMImages * MBytes;
    ScratchBytes = Scratch + 8 + AccMImages * MBytes;
  } else {
    ScratchBytes = 8 + Count * MBytes;
  }
  MachineFrameInfo &MFI = MBB.getParent()->getFrameInfo();
  MFI.setObjectSize(FI, std::max<int64_t>(MFI.getObjectSize(FI), ScratchBytes));

  // ACC values are transferred through a contiguous group of M registers.
  // The transfer saves and restores the selected M images and descriptor, so
  // the scratch group may overlap live matrix values.  This is necessary for
  // the default 16-register profile: a function can legitimately use every
  // M0-M15 and still need an ACC spill or cross-file copy.  Keep the choice
  // fixed and profile-valid; the saved images preserve the caller's values.
  const unsigned ScratchBase = 0;
  if (Acc && ScratchBase + AccMImages > Profile.MRegisters)
    report_fatal_error("XAME ACC transfer scratch group exceeds profile");
  constexpr Register Addr = RISCV::X5, Desc = RISCV::X6, Status = RISCV::X7;
  auto emit = [&](unsigned Op) { return BuildMI(MBB, At, DL, TII.get(Op)); };
  auto address = [&](unsigned Offset) {
    // A 16-register M image exceeds ADDI's immediate range. Keep every
    // instruction valid even before PEI resolves the frame index.
    unsigned Chunk = std::min(Offset, 2047U);
    emit(RISCV::ADDI).addDef(Addr).addFrameIndex(FI).addImm(Chunk);
    while (Offset > Chunk) {
      Offset -= Chunk;
      Chunk = std::min(Offset, 2047U);
      emit(RISCV::ADDI).addDef(Addr).addReg(Addr).addImm(Chunk);
    }
  };
  auto word = [&](bool Load, unsigned Offset, Register R) {
    address(Offset);
    emit(Load ? RISCV::LW : RISCV::SW)
        .addReg(R, Load ? RegState::Define : RegState::NoFlags)
        .addReg(Addr)
        .addImm(0);
  };
  auto getType = [&](Register R, bool A) {
    emit(A ? RISCV::ZTT_AGETTYP : RISCV::ZTT_MGETTYP)
        .addDef(Desc)
        .addReg(R, RegState::Undef);
  };
  auto setType = [&](Register R, bool A) {
    // msettyp/asettyp are two-address instructions: the destination
    // descriptor register is tied to the incoming matrix/ACC register.
    emit(A ? RISCV::ZTT_ASETTYP : RISCV::ZTT_MSETTYP)
        .addDef(R)
        .addReg(R, RegState::Undef)
        .addReg(Desc);
  };
  auto raw = [&](Register R, unsigned Offset, bool Load) {
    address(Offset);
    if (Load)
      emit(RISCV::ZTT_MLS_1R).addDef(R).addReg(R, RegState::Undef).addReg(Addr);
    else
      emit(RISCV::ZTT_MSS_1R).addReg(R, RegState::Undef).addReg(Addr);
  };
  // Do not expose status changes made while programming spill scratch state.
  emit(RISCV::CSRRS)
      .addDef(Status)
      .addImm(RISCVSysReg::amestatus)
      .addReg(RISCV::X0);
  if (!Acc) {
    Register M = RISCV::ZTTM0 + Base;
    if (Reload) {
      word(true, 0, Desc);
      setType(M, false);
    } else {
      getType(M, false);
      word(false, 0, Desc);
    }
    for (unsigned I = 0; I < Count; ++I)
      raw(RISCV::ZTTM0 + Base + I, 8 + I * MBytes, Reload);
  } else {
    // A narrow ACC value reserves its complete packed group, but mmov.m.a
    // packs those squares into M images according to the datatype descriptor.
    // The widest descriptor, rather than the allocated ACC group count,
    // bounds this transfer and the scratch span cleared by msettyp.
    unsigned Scratch = 8 + AccMImages * MBytes;
    Register ScratchM = RISCV::ZTTM0 + ScratchBase;
    getType(ScratchM, false);
    word(false, Scratch, Desc);
    for (unsigned I = 0; I < AccMImages; ++I)
      raw(ScratchM + I, Scratch + 8 + I * MBytes, false);
    Register A = RISCV::ZTTA0 + Base;
    if (Reload) {
      word(true, 0, Desc);
      setType(A, true);
      setType(ScratchM, false);
      for (unsigned I = 0; I < AccMImages; ++I)
        raw(ScratchM + I, 8 + I * MBytes, true);
      emit(RISCV::ZTT_MMOV_A_M)
          .addDef(A)
          .addReg(A, RegState::Undef)
          .addReg(ScratchM);
    } else {
      getType(A, true);
      word(false, 0, Desc);
      setType(ScratchM, false);
      emit(RISCV::ZTT_MMOV_M_A)
          .addDef(ScratchM)
          .addReg(ScratchM, RegState::Undef)
          .addReg(A, RegState::Undef);
      raw(ScratchM, 8, false);
      for (unsigned I = 1; I < AccMImages; ++I)
        raw(ScratchM + I, 8 + I * MBytes, false);
    }
    word(true, Scratch, Desc);
    setType(ScratchM, false);
    for (unsigned I = 0; I < AccMImages; ++I)
      raw(ScratchM + I, Scratch + 8 + I * MBytes, true);
  }
  auto End = emit(RISCV::CSRRW)
                 .addDef(RISCV::X0)
                 .addImm(RISCVSysReg::amestatus)
                 .addReg(Status);
  if (Reload)
    End.addReg(Reg, RegState::ImplicitDefine);
  else
    End.addReg(Reg, RegState::Implicit | RegState::Undef);
}
} // namespace

char RISCVXAMEState::ID = 0;
INITIALIZE_PASS(RISCVXAMEState, "riscv-xame-state",
                "RISC-V xame-state register state preservation", false, false)

static bool runXAMEState(MachineFunction &MF);

bool RISCVXAMEState::runOnMachineFunction(MachineFunction &MF) {
  return runXAMEState(MF);
}

PreservedAnalyses
RISCVXAMEStatePass::run(MachineFunction &MF,
                        MachineFunctionAnalysisManager &MFAM) {
  (void)MFAM;
  return runXAMEState(MF) ? PreservedAnalyses::none()
                          : PreservedAnalyses::all();
}

static bool runXAMEState(MachineFunction &MF) {
  const auto &ST = MF.getSubtarget<RISCVSubtarget>();
  if (!ST.hasVendorXAME())
    return false;
  const auto &TII = *ST.getInstrInfo();
  const auto &TRI = *ST.getRegisterInfo();
  bool Changed = false;
  for (MachineBasicBlock &MBB : MF) {
    for (MachineInstr &MI : make_early_inc_range(MBB)) {
      unsigned Op = MI.getOpcode();
      if (MI.isCopy() &&
          (RISCV::ZTTMAnyRegClass.contains(MI.getOperand(0).getReg()) ||
           RISCV::ZTTAAnyRegClass.contains(MI.getOperand(0).getReg()))) {
        Register Dst = MI.getOperand(0).getReg(),
                 Src = MI.getOperand(1).getReg();
        if (Dst != Src) {
          const auto *SrcRC = TRI.getMinimalPhysRegClass(Src);
          const auto *DstRC = TRI.getMinimalPhysRegClass(Dst);
          // Register allocation routinely materializes a copy between a
          // group register and its first-register alias (for example
          // ZTTA0G4 -> ZTTA0).  Both names denote the same architectural
          // storage, so expanding this as a memory transfer needlessly
          // clobbers scratch M registers and bloats leaf functions.
          bool IsContainedAlias =
              TRI.regsOverlap(Dst, Src) &&
              TRI.getEncodingValue(Dst) == TRI.getEncodingValue(Src) &&
              TRI.getRegSizeInBits(*SrcRC).getFixedValue() >=
                  TRI.getRegSizeInBits(*DstRC).getFixedValue();
          if (!IsContainedAlias) {
            // The descriptor-aware transfer for an ACC value needs its
            // scratch image in addition to the logical payload.  A
            // cross-file M -> ACC copy therefore needs more space than the
            // source M spill class.
            unsigned SpillSize =
                std::max(TRI.getSpillSize(*SrcRC), TRI.getSpillSize(*DstRC));
            Align SpillAlign =
                std::max(TRI.getSpillAlign(*SrcRC), TRI.getSpillAlign(*DstRC));
            int FI = MF.getFrameInfo().CreateStackObject(SpillSize, SpillAlign,
                                                         true);
            transfer(MI, Src, FI, false, TII, TRI);
            transfer(MI, Dst, FI, true, TII, TRI);
          }
        }
      } else if (Op == RISCV::ZTT_SPILL_M || Op == RISCV::ZTT_SPILL_A ||
                 Op == RISCV::ZTT_RELOAD_M || Op == RISCV::ZTT_RELOAD_A) {
        transfer(MI, MI.getOperand(0).getReg(), MI.getOperand(1).getIndex(),
                 Op == RISCV::ZTT_RELOAD_M || Op == RISCV::ZTT_RELOAD_A, TII,
                 TRI);
      } else {
        continue;
      }
      MI.eraseFromParent();
      Changed = true;
    }
  }
  return Changed;
}

FunctionPass *llvm::createRISCVXAMEStatePass() { return new RISCVXAMEState(); }
