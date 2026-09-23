//===- RISCVFPGARegisterAllocation.cpp - Fixed matrix slots ----------------===//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//===----------------------------------------------------------------------===//
// Allocate only explicitly slotted FPGA matrix values. PHIs and destructive
// accumulator updates retain the slot chosen by the SSA seed. Validate actual
// CFG liveness before replacing virtual registers; no matrix COPY or spill is
// synthesized, at any optimization level. The ordinary allocator handles GPRs
// and RVV values afterwards. The upstream BOSC AME pathway is untouched.

#include "RISCV.h"
#include "RISCVSubtarget.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include <map>
#include <set>

using namespace llvm;

namespace {
static bool allocateFPGAMatrixSlots(MachineFunction &MF);

class RISCVFPGARegisterAllocation : public MachineFunctionPass {
public:
  static char ID;
  RISCVFPGARegisterAllocation() : MachineFunctionPass(ID) {
    initializeRISCVFPGARegisterAllocationPass(*PassRegistry::getPassRegistry());
  }
  StringRef getPassName() const override { return "RISC-V FPGA matrix slots"; }
  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    MachineFunctionPass::getAnalysisUsage(AU);
  }
  bool runOnMachineFunction(MachineFunction &MF) override {
    return allocateFPGAMatrixSlots(MF);
  }
};

struct RegisterGroups {
  DenseMap<Register, Register> Parent;
  Register find(Register R) {
    auto I = Parent.find(R);
    if (I == Parent.end()) {
      Parent[R] = R;
      return R;
    }
    Register P = I->second;
    if (P == R)
      return R;
    return Parent[R] = find(P);
  }
  void join(Register A, Register B) { Parent[find(A)] = find(B); }
};

static unsigned realLoad(unsigned Opcode) {
  switch (Opcode) {
  case RISCV::PseudoFPGA_LOAD_A:
    return RISCV::BOSC_AME_FPGA_MLAE8_M;
  case RISCV::PseudoFPGA_LOAD_B:
    return RISCV::BOSC_AME_FPGA_MLBE8_M;
  case RISCV::PseudoFPGA_LOAD_BT:
    return RISCV::BOSC_AME_FPGA_MLBTE8_M;
  case RISCV::PseudoFPGA_LOAD_ACC:
    return RISCV::BOSC_AME_FPGA_MLCE32_M;
  default:
    return 0;
  }
}
} // namespace

char RISCVFPGARegisterAllocation::ID = 0;
INITIALIZE_PASS(RISCVFPGARegisterAllocation, "riscv-fpga-matrix-slots",
                "RISC-V FPGA matrix slots", false, false)

FunctionPass *llvm::createRISCVFPGARegisterAllocationPass() {
  return new RISCVFPGARegisterAllocation();
}

namespace {
bool allocateFPGAMatrixSlots(MachineFunction &MF) {
  const auto &ST = MF.getSubtarget<RISCVSubtarget>();
  if (!ST.hasVendorXBOSCAMEFPGA())
    return false;
  auto &MRI = MF.getRegInfo();
  const auto *TII = ST.getInstrInfo();
  auto isMatrix = [&](Register R) {
    if (!R.isVirtual())
      return false;
    const auto *RC = MRI.getRegClass(R);
    return RISCV::TileRegRegClass.hasSubClassEq(RC) ||
           RISCV::AccRegRegClass.hasSubClassEq(RC);
  };
  auto isAcc = [&](Register R) {
    return RISCV::AccRegRegClass.hasSubClassEq(MRI.getRegClass(R));
  };
  RegisterGroups Slots, Copies;
  std::set<Register> Matrices;
  SmallVector<std::pair<Register, unsigned>> Hints;
  auto join = [&](Register A, Register B) {
    if (!isMatrix(A) || !isMatrix(B) || isAcc(A) != isAcc(B))
      report_fatal_error("BOSC AME FPGA matrix COPY crosses a register role or "
                         "function boundary");
    Slots.join(A, B);
  };
  for (auto &MBB : MF) {
    for (auto &MI : MBB) {
      for (auto &MO : MI.operands())
        if (MO.isReg() && isMatrix(MO.getReg())) {
          if (MO.getSubReg())
            report_fatal_error(
                "BOSC AME FPGA matrix subregister is unsupported");
          Matrices.insert(MO.getReg());
        }
      if (realLoad(MI.getOpcode())) {
        int64_t Slot = MI.getOperand(3).getImm();
        bool Acc = MI.getOpcode() == RISCV::PseudoFPGA_LOAD_ACC;
        bool A = MI.getOpcode() == RISCV::PseudoFPGA_LOAD_A;
        if (Slot < 0 || Slot > 7 || (A && Slot != 0 && Slot != 2) ||
            (!Acc && !A && Slot < 4))
          report_fatal_error("BOSC AME FPGA slot is outside its A/B/ACC bank");
        Hints.emplace_back(MI.getOperand(0).getReg(), Slot);
      }
      if (MI.isPHI() && isMatrix(MI.getOperand(0).getReg())) {
        for (unsigned I = 1; I < MI.getNumOperands(); I += 2)
          join(MI.getOperand(0).getReg(), MI.getOperand(I).getReg());
      } else if (MI.isCopy() && (isMatrix(MI.getOperand(0).getReg()) ||
                                 isMatrix(MI.getOperand(1).getReg()))) {
        Register D = MI.getOperand(0).getReg(), S = MI.getOperand(1).getReg();
        join(D, S);
        Copies.join(D, S);
      }
      for (unsigned I = 0; I < MI.getNumExplicitOperands(); ++I) {
        auto &MO = MI.getOperand(I);
        if (!MO.isReg() || !MO.isUse() || !isMatrix(MO.getReg()))
          continue;
        int Tied = MI.getDesc().getOperandConstraint(I, MCOI::TIED_TO);
        if (Tied >= 0)
          join(MO.getReg(), MI.getOperand(Tied).getReg());
      }
    }
  }
  if (Matrices.empty())
    return false;

  DenseMap<Register, unsigned> GroupSlot;
  for (auto [R, Slot] : Hints) {
    auto Result = GroupSlot.try_emplace(Slots.find(R), Slot);
    if (!Result.second && Result.first->second != Slot)
      report_fatal_error("BOSC AME FPGA matrix COPY/PHI requires incompatible "
                         "fixed slots");
  }
  const MCPhysReg Tiles[] = {RISCV::TR0, RISCV::TR1, RISCV::TR2, RISCV::TR3,
                             RISCV::TR4, RISCV::TR5, RISCV::TR6, RISCV::TR7};
  const MCPhysReg Accs[] = {RISCV::ACC0, RISCV::ACC1, RISCV::ACC2, RISCV::ACC3,
                            RISCV::ACC4, RISCV::ACC5, RISCV::ACC6, RISCV::ACC7};
  DenseMap<Register, MCPhysReg> Assigned;
  for (Register R : Matrices) {
    auto I = GroupSlot.find(Slots.find(R));
    if (I == GroupSlot.end())
      report_fatal_error(
          "BOSC AME FPGA matrix value has no explicit load slot");
    Assigned[R] = isAcc(R) ? Accs[I->second] : Tiles[I->second];
  }

  // Phi uses are live on their incoming edge, not in every predecessor. This
  // also handles the seed and backedge values of the eight K-loop chains.
  using LiveSet = std::set<Register>;
  DenseMap<MachineBasicBlock *, LiveSet> LiveIn, LiveOut;
  auto step = [&](MachineInstr &MI, LiveSet &Live) {
    for (auto &MO : MI.operands())
      if (MO.isReg() && MO.isDef() && isMatrix(MO.getReg()))
        Live.erase(MO.getReg());
    if (!MI.isPHI())
      for (auto &MO : MI.operands())
        if (MO.isReg() && MO.isUse() && !MO.isUndef() && isMatrix(MO.getReg()))
          Live.insert(MO.getReg());
  };
  bool Changed;
  do {
    Changed = false;
    for (auto &MBB : llvm::reverse(MF)) {
      LiveSet Out;
      for (auto *Succ : MBB.successors()) {
        Out.insert(LiveIn[Succ].begin(), LiveIn[Succ].end());
        for (auto &Phi : Succ->phis()) {
          if (!isMatrix(Phi.getOperand(0).getReg()))
            continue;
          for (unsigned I = 1; I < Phi.getNumOperands(); I += 2)
            if (Phi.getOperand(I + 1).getMBB() == &MBB)
              Out.insert(Phi.getOperand(I).getReg());
        }
      }
      LiveSet In = Out;
      for (auto &MI : llvm::reverse(MBB))
        step(MI, In);
      if (LiveIn[&MBB] != In || LiveOut[&MBB] != Out) {
        LiveIn[&MBB] = std::move(In);
        LiveOut[&MBB] = std::move(Out);
        Changed = true;
      }
    }
  } while (Changed);

  auto check = [&](const LiveSet &Live) {
    std::map<MCPhysReg, Register> Occupied;
    for (Register R : Live) {
      auto Result = Occupied.emplace(Assigned[R], Copies.find(R));
      if (!Result.second && Result.first->second != Copies.find(R))
        report_fatal_error(
            "BOSC AME matrix registers cannot be spilled: "
            "simultaneously live values overlap a fixed FPGA slot");
    }
  };
  for (auto &MBB : MF) {
    LiveSet Live = LiveOut[&MBB];
    check(Live);
    for (auto &MI : llvm::reverse(MBB)) {
      if (MI.isCall() && !Live.empty())
        report_fatal_error(
            "BOSC AME FPGA matrix values cannot live across calls");
      // Even a dead definition writes its physical slot. In particular, the
      // discarded resync MMA must not overwrite another resident accumulator.
      LiveSet WithDefs = Live;
      for (auto &MO : MI.operands())
        if (MO.isReg() && MO.isDef() && isMatrix(MO.getReg()))
          WithDefs.insert(MO.getReg());
      check(WithDefs);
      step(MI, Live);
      check(Live);
    }
  }

  for (auto &MBB : MF) {
    for (Register R : LiveIn[&MBB])
      if (!MBB.isLiveIn(Assigned[R]))
        MBB.addLiveIn(Assigned[R]);
    for (auto &MI : make_early_inc_range(MBB)) {
      if ((MI.isPHI() || MI.isCopy()) && isMatrix(MI.getOperand(0).getReg())) {
        if (MI.isPHI() && !MBB.isLiveIn(Assigned[MI.getOperand(0).getReg()]))
          MBB.addLiveIn(Assigned[MI.getOperand(0).getReg()]);
        MI.eraseFromParent();
        continue;
      }
      if (unsigned Opcode = realLoad(MI.getOpcode())) {
        MI.removeOperand(3);
        MI.setDesc(TII->get(Opcode));
      }
      for (auto &MO : MI.operands())
        if (MO.isReg() && isMatrix(MO.getReg())) {
          MO.setReg(Assigned[MO.getReg()]);
          if (MO.isUse())
            MO.setIsKill(false);
          if (MO.isDef())
            MO.setIsDead(false);
          MO.setIsRenamable(false);
        }
    }
  }
  return true;
}
} // namespace

PreservedAnalyses
RISCVFPGARegisterAllocationPass::run(MachineFunction &MF,
                                     MachineFunctionAnalysisManager &MFAM) {
  if (!allocateFPGAMatrixSlots(MF))
    return PreservedAnalyses::all();
  PreservedAnalyses PA = getMachineFunctionPassPreservedAnalyses();
  PA.preserveSet<CFGAnalyses>();
  return PA;
}
