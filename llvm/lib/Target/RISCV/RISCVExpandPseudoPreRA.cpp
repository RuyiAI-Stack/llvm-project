//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains one of the several passes that expand pseudo instructions
// into target instructions. This pass is run before register allocation.
//
//===----------------------------------------------------------------------===//

#include "RISCV.h"
#include "RISCVExpandPseudoBase.h"
#include "RISCVInstrInfo.h"
#include "RISCVSubtarget.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

#define RISCV_EXPAND_PSEUDO_PRE_RA_NAME                                        \
  "RISC-V Pseudo Instruction Expansion - Pre-RA"

namespace {

class RISCVExpandPseudoPreRAImpl final : public RISCVExpandPseudoImplBase {
  bool expandMI(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                MachineBasicBlock::iterator &NextMBBI) const override;

  bool expandAuipcInstPair(MachineBasicBlock &MBB,
                           MachineBasicBlock::iterator MBBI, unsigned FlagsHi,
                           unsigned SecondOpcode) const;

  bool expandLoadLocalAddress(MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator MBBI) const;

  bool expandLoadGlobalAddress(MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI) const;

  bool expandLoadTLSIEAddress(MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator MBBI) const;

  bool expandLoadTLSGDAddress(MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator MBBI) const;

  bool expandLoadTLSDescAddress(MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator MBBI) const;

  bool expandZamesConfigPseudo(MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI) const;
};

class RISCVExpandPseudoPreRALegacy : public MachineFunctionPass {
public:
  static char ID;

  RISCVExpandPseudoPreRALegacy() : MachineFunctionPass(ID) {}

  bool runOnMachineFunction(MachineFunction &MF) override {
    return RISCVExpandPseudoPreRAImpl().run(MF);
  }

  MachineFunctionProperties getRequiredProperties() const override {
    return MachineFunctionProperties().setIsSSA();
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    MachineFunctionPass::getAnalysisUsage(AU);
  }
  StringRef getPassName() const override {
    return RISCV_EXPAND_PSEUDO_PRE_RA_NAME;
  }
};

} // anonymous namespace

bool RISCVExpandPseudoPreRAImpl::expandMI(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
    MachineBasicBlock::iterator &NextMBBI) const {

  switch (MBBI->getOpcode()) {
  case RISCV::PseudoLLA:
    return expandLoadLocalAddress(MBB, MBBI);
  case RISCV::PseudoLGA:
    return expandLoadGlobalAddress(MBB, MBBI);
  case RISCV::PseudoLA_TLS_IE:
    return expandLoadTLSIEAddress(MBB, MBBI);
  case RISCV::PseudoLA_TLS_GD:
    return expandLoadTLSGDAddress(MBB, MBBI);
  case RISCV::PseudoLA_TLSDESC:
    return expandLoadTLSDescAddress(MBB, MBBI);
  case RISCV::PSEUDO_ZAMES_MLA_A_I8_PRE:
  case RISCV::PSEUDO_ZAMES_MLB_B_I8_PRE:
  case RISCV::PSEUDO_ZAMES_MLBT_B_I8_PRE:
  case RISCV::PSEUDO_ZAMES_MLAT_A_I8_PRE:
  case RISCV::PSEUDO_ZAMES_MLC_C_I32_PRE:
  case RISCV::PSEUDO_ZAMES_MLCT_C_I32_PRE:
  case RISCV::PSEUDO_ZAMES_MZERO_C_I32_PRE:
  case RISCV::PSEUDO_ZAMES_MMACC_I8_I32_PRE:
  case RISCV::PSEUDO_ZAMES_MSC_C_I32_PRE:
  case RISCV::PSEUDO_ZAMES_MSA_A_I8_PRE:
  case RISCV::PSEUDO_ZAMES_MSAT_A_I8_PRE:
  case RISCV::PSEUDO_ZAMES_MSB_B_I8_PRE:
  case RISCV::PSEUDO_ZAMES_MSBT_B_I8_PRE:
  case RISCV::PSEUDO_ZAMES_MSCT_C_I32_PRE:
  case RISCV::PSEUDO_ZAMES_MLA_A_FP8E4_PRE:
  case RISCV::PSEUDO_ZAMES_MLA_A_FP8E5_PRE:
  case RISCV::PSEUDO_ZAMES_MLA_A_F16_PRE:
  case RISCV::PSEUDO_ZAMES_MLA_A_BF16_PRE:
  case RISCV::PSEUDO_ZAMES_MLAT_A_FP8E4_PRE:
  case RISCV::PSEUDO_ZAMES_MLAT_A_FP8E5_PRE:
  case RISCV::PSEUDO_ZAMES_MLAT_A_F16_PRE:
  case RISCV::PSEUDO_ZAMES_MLAT_A_BF16_PRE:
  case RISCV::PSEUDO_ZAMES_MLB_B_FP8E4_PRE:
  case RISCV::PSEUDO_ZAMES_MLB_B_FP8E5_PRE:
  case RISCV::PSEUDO_ZAMES_MLB_B_F16_PRE:
  case RISCV::PSEUDO_ZAMES_MLB_B_BF16_PRE:
  case RISCV::PSEUDO_ZAMES_MLBT_B_FP8E4_PRE:
  case RISCV::PSEUDO_ZAMES_MLBT_B_FP8E5_PRE:
  case RISCV::PSEUDO_ZAMES_MLBT_B_F16_PRE:
  case RISCV::PSEUDO_ZAMES_MLBT_B_BF16_PRE:
  case RISCV::PSEUDO_ZAMES_MLC_C_F32_PRE:
  case RISCV::PSEUDO_ZAMES_MLCT_C_F32_PRE:
  case RISCV::PSEUDO_ZAMES_MSA_A_FP8E4_PRE:
  case RISCV::PSEUDO_ZAMES_MSA_A_FP8E5_PRE:
  case RISCV::PSEUDO_ZAMES_MSA_A_F16_PRE:
  case RISCV::PSEUDO_ZAMES_MSA_A_BF16_PRE:
  case RISCV::PSEUDO_ZAMES_MSAT_A_FP8E4_PRE:
  case RISCV::PSEUDO_ZAMES_MSAT_A_FP8E5_PRE:
  case RISCV::PSEUDO_ZAMES_MSAT_A_F16_PRE:
  case RISCV::PSEUDO_ZAMES_MSAT_A_BF16_PRE:
  case RISCV::PSEUDO_ZAMES_MSB_B_FP8E4_PRE:
  case RISCV::PSEUDO_ZAMES_MSB_B_FP8E5_PRE:
  case RISCV::PSEUDO_ZAMES_MSB_B_F16_PRE:
  case RISCV::PSEUDO_ZAMES_MSB_B_BF16_PRE:
  case RISCV::PSEUDO_ZAMES_MSBT_B_FP8E4_PRE:
  case RISCV::PSEUDO_ZAMES_MSBT_B_FP8E5_PRE:
  case RISCV::PSEUDO_ZAMES_MSBT_B_F16_PRE:
  case RISCV::PSEUDO_ZAMES_MSBT_B_BF16_PRE:
  case RISCV::PSEUDO_ZAMES_MSC_C_F32_PRE:
  case RISCV::PSEUDO_ZAMES_MSCT_C_F32_PRE:
  case RISCV::PSEUDO_ZAMES_MZERO_T_I8_PRE:
  case RISCV::PSEUDO_ZAMES_MZERO_T_FP8E4_PRE:
  case RISCV::PSEUDO_ZAMES_MZERO_T_FP8E5_PRE:
  case RISCV::PSEUDO_ZAMES_MZERO_T_F16_PRE:
  case RISCV::PSEUDO_ZAMES_MZERO_T_BF16_PRE:
  case RISCV::PSEUDO_ZAMES_MZERO_C_F32_PRE:
  case RISCV::PSEUDO_ZAMES_MMACC_I8_F32_PRE:
  case RISCV::PSEUDO_ZAMES_MMACC_FP8E4_F32_PRE:
  case RISCV::PSEUDO_ZAMES_MMACC_FP8E5_F32_PRE:
  case RISCV::PSEUDO_ZAMES_MMACC_F16_F32_PRE:
  case RISCV::PSEUDO_ZAMES_MMACC_BF16_F32_PRE:
    return expandZamesConfigPseudo(MBB, MBBI);
  }

  return false;
}

static constexpr int64_t ZamesCfgI8 = 0x02;
static constexpr int64_t ZamesCfgI32 = 0x04;
static constexpr int64_t ZamesCfgF8E5 = 0x07;
static constexpr int64_t ZamesCfgF8E4 = 0x08;
static constexpr int64_t ZamesCfgF16 = 0x09;
static constexpr int64_t ZamesCfgBF16 = 0x0a;
static constexpr int64_t ZamesCfgF32 = 0x0c;

static Register createZamesConfigPayload(const RISCVInstrInfo *TII,
                                         MachineBasicBlock &MBB,
                                         MachineBasicBlock::iterator MBBI,
                                         DebugLoc DL, int64_t Payload) {
  MachineFunction *MF = MBB.getParent();
  Register ConfigReg =
      MF->getRegInfo().createVirtualRegister(&RISCV::GPRRegClass);
  BuildMI(MBB, MBBI, DL, TII->get(RISCV::ADDI), ConfigReg)
      .addReg(RISCV::X0)
      .addImm(Payload);
  return ConfigReg;
}

// Expand a single-config _PRE pseudo: materialize the payload GPR, rebuild
// the second-level pseudo with all original operands plus the payload
// register, and carry the memory operands over.
static void expandZamesPreRASingleConfig(const RISCVInstrInfo *TII,
                                         MachineBasicBlock &MBB,
                                         MachineBasicBlock::iterator MBBI,
                                         MachineInstr &MI, unsigned NewOpc,
                                         int64_t Payload) {
  Register ConfigReg =
      createZamesConfigPayload(TII, MBB, MBBI, MI.getDebugLoc(), Payload);
  auto MIB = BuildMI(MBB, MBBI, MI.getDebugLoc(), TII->get(NewOpc));
  for (const MachineOperand &MO : MI.operands())
    MIB.add(MO);
  MIB.addReg(ConfigReg);
  MIB.cloneMemRefs(MI);
}

// Expand an mmacc _PRE pseudo: materialize the accumulator and matrix
// payload GPRs and rebuild the second-level pseudo. The B and A matrices
// always share the element type in every supported combination, so one
// payload register feeds both config operands.
static void expandZamesPreRAMMAcc(const RISCVInstrInfo *TII,
                                  MachineBasicBlock &MBB,
                                  MachineBasicBlock::iterator MBBI,
                                  MachineInstr &MI, unsigned NewOpc,
                                  int64_t AccPayload, int64_t MatPayload) {
  DebugLoc DL = MI.getDebugLoc();
  Register AccConfigReg =
      createZamesConfigPayload(TII, MBB, MBBI, DL, AccPayload);
  Register MatConfigReg =
      createZamesConfigPayload(TII, MBB, MBBI, DL, MatPayload);
  BuildMI(MBB, MBBI, DL, TII->get(NewOpc))
      .add(MI.getOperand(0))
      .add(MI.getOperand(1))
      .add(MI.getOperand(2))
      .add(MI.getOperand(3))
      .addReg(AccConfigReg)
      .addReg(MatConfigReg)
      .addReg(MatConfigReg);
}

bool RISCVExpandPseudoPreRAImpl::expandZamesConfigPseudo(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI) const {
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();
  unsigned Opc = MI.getOpcode();

  switch (Opc) {
  default:
    llvm_unreachable("Unexpected ZAMES pre-RA pseudo opcode");
  case RISCV::PSEUDO_ZAMES_MLA_A_I8_PRE: {
    Register ConfigReg =
        createZamesConfigPayload(TII, MBB, MBBI, DL, ZamesCfgI8);
    BuildMI(MBB, MBBI, DL, TII->get(RISCV::PSEUDO_ZAMES_MLA_A_I8))
        .add(MI.getOperand(0))
        .add(MI.getOperand(1))
        .add(MI.getOperand(2))
        .addReg(ConfigReg)
        .cloneMemRefs(MI);
    break;
  }
  case RISCV::PSEUDO_ZAMES_MLB_B_I8_PRE: {
    Register ConfigReg =
        createZamesConfigPayload(TII, MBB, MBBI, DL, ZamesCfgI8);
    BuildMI(MBB, MBBI, DL, TII->get(RISCV::PSEUDO_ZAMES_MLB_B_I8))
        .add(MI.getOperand(0))
        .add(MI.getOperand(1))
        .add(MI.getOperand(2))
        .addReg(ConfigReg)
        .cloneMemRefs(MI);
    break;
  }
  case RISCV::PSEUDO_ZAMES_MLBT_B_I8_PRE: {
    Register ConfigReg =
        createZamesConfigPayload(TII, MBB, MBBI, DL, ZamesCfgI8);
    BuildMI(MBB, MBBI, DL, TII->get(RISCV::PSEUDO_ZAMES_MLBT_B_I8))
        .add(MI.getOperand(0))
        .add(MI.getOperand(1))
        .add(MI.getOperand(2))
        .addReg(ConfigReg)
        .cloneMemRefs(MI);
    break;
  }
  case RISCV::PSEUDO_ZAMES_MLAT_A_I8_PRE: {
    Register ConfigReg =
        createZamesConfigPayload(TII, MBB, MBBI, DL, ZamesCfgI8);
    BuildMI(MBB, MBBI, DL, TII->get(RISCV::PSEUDO_ZAMES_MLAT_A_I8))
        .add(MI.getOperand(0))
        .add(MI.getOperand(1))
        .add(MI.getOperand(2))
        .addReg(ConfigReg)
        .cloneMemRefs(MI);
    break;
  }
  case RISCV::PSEUDO_ZAMES_MLC_C_I32_PRE: {
    Register ConfigReg =
        createZamesConfigPayload(TII, MBB, MBBI, DL, ZamesCfgI32);
    BuildMI(MBB, MBBI, DL, TII->get(RISCV::PSEUDO_ZAMES_MLC_C_I32))
        .add(MI.getOperand(0))
        .add(MI.getOperand(1))
        .add(MI.getOperand(2))
        .addReg(ConfigReg)
        .cloneMemRefs(MI);
    break;
  }
  case RISCV::PSEUDO_ZAMES_MLCT_C_I32_PRE: {
    Register ConfigReg =
        createZamesConfigPayload(TII, MBB, MBBI, DL, ZamesCfgI32);
    BuildMI(MBB, MBBI, DL, TII->get(RISCV::PSEUDO_ZAMES_MLCT_C_I32))
        .add(MI.getOperand(0))
        .add(MI.getOperand(1))
        .add(MI.getOperand(2))
        .addReg(ConfigReg)
        .cloneMemRefs(MI);
    break;
  }
  case RISCV::PSEUDO_ZAMES_MZERO_C_I32_PRE: {
    Register ConfigReg =
        createZamesConfigPayload(TII, MBB, MBBI, DL, ZamesCfgI32);
    BuildMI(MBB, MBBI, DL, TII->get(RISCV::PSEUDO_ZAMES_MZERO_C_I32))
        .add(MI.getOperand(0))
        .addReg(ConfigReg);
    break;
  }
  case RISCV::PSEUDO_ZAMES_MMACC_I8_I32_PRE: {
    Register AccConfigReg =
        createZamesConfigPayload(TII, MBB, MBBI, DL, ZamesCfgI32);
    Register MatConfigReg =
        createZamesConfigPayload(TII, MBB, MBBI, DL, ZamesCfgI8);
    BuildMI(MBB, MBBI, DL, TII->get(RISCV::PSEUDO_ZAMES_MMACC_I8_I32))
        .add(MI.getOperand(0))
        .add(MI.getOperand(1))
        .add(MI.getOperand(2))
        .add(MI.getOperand(3))
        .addReg(AccConfigReg)
        .addReg(MatConfigReg)
        .addReg(MatConfigReg);
    break;
  }
  case RISCV::PSEUDO_ZAMES_MSC_C_I32_PRE: {
    Register ConfigReg =
        createZamesConfigPayload(TII, MBB, MBBI, DL, ZamesCfgI32);
    BuildMI(MBB, MBBI, DL, TII->get(RISCV::PSEUDO_ZAMES_MSC_C_I32))
        .add(MI.getOperand(0))
        .add(MI.getOperand(1))
        .add(MI.getOperand(2))
        .addReg(ConfigReg)
        .cloneMemRefs(MI);
    break;
  }
  case RISCV::PSEUDO_ZAMES_MSA_A_I8_PRE: {
    Register ConfigReg =
        createZamesConfigPayload(TII, MBB, MBBI, DL, ZamesCfgI8);
    BuildMI(MBB, MBBI, DL, TII->get(RISCV::PSEUDO_ZAMES_MSA_A_I8))
        .add(MI.getOperand(0))
        .add(MI.getOperand(1))
        .add(MI.getOperand(2))
        .addReg(ConfigReg)
        .cloneMemRefs(MI);
    break;
  }
  case RISCV::PSEUDO_ZAMES_MSAT_A_I8_PRE: {
    Register ConfigReg =
        createZamesConfigPayload(TII, MBB, MBBI, DL, ZamesCfgI8);
    BuildMI(MBB, MBBI, DL, TII->get(RISCV::PSEUDO_ZAMES_MSAT_A_I8))
        .add(MI.getOperand(0))
        .add(MI.getOperand(1))
        .add(MI.getOperand(2))
        .addReg(ConfigReg)
        .cloneMemRefs(MI);
    break;
  }
  case RISCV::PSEUDO_ZAMES_MSB_B_I8_PRE: {
    Register ConfigReg =
        createZamesConfigPayload(TII, MBB, MBBI, DL, ZamesCfgI8);
    BuildMI(MBB, MBBI, DL, TII->get(RISCV::PSEUDO_ZAMES_MSB_B_I8))
        .add(MI.getOperand(0))
        .add(MI.getOperand(1))
        .add(MI.getOperand(2))
        .addReg(ConfigReg)
        .cloneMemRefs(MI);
    break;
  }
  case RISCV::PSEUDO_ZAMES_MSBT_B_I8_PRE: {
    Register ConfigReg =
        createZamesConfigPayload(TII, MBB, MBBI, DL, ZamesCfgI8);
    BuildMI(MBB, MBBI, DL, TII->get(RISCV::PSEUDO_ZAMES_MSBT_B_I8))
        .add(MI.getOperand(0))
        .add(MI.getOperand(1))
        .add(MI.getOperand(2))
        .addReg(ConfigReg)
        .cloneMemRefs(MI);
    break;
  }
  case RISCV::PSEUDO_ZAMES_MSCT_C_I32_PRE: {
    Register ConfigReg =
        createZamesConfigPayload(TII, MBB, MBBI, DL, ZamesCfgI32);
    BuildMI(MBB, MBBI, DL, TII->get(RISCV::PSEUDO_ZAMES_MSCT_C_I32))
        .add(MI.getOperand(0))
        .add(MI.getOperand(1))
        .add(MI.getOperand(2))
        .addReg(ConfigReg)
        .cloneMemRefs(MI);
    break;
  }
  case RISCV::PSEUDO_ZAMES_MLA_A_FP8E4_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MLA_A_FP8E4, ZamesCfgF8E4);
    break;
  case RISCV::PSEUDO_ZAMES_MLA_A_FP8E5_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MLA_A_FP8E5, ZamesCfgF8E5);
    break;
  case RISCV::PSEUDO_ZAMES_MLA_A_F16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MLA_A_F16, ZamesCfgF16);
    break;
  case RISCV::PSEUDO_ZAMES_MLA_A_BF16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MLA_A_BF16, ZamesCfgBF16);
    break;
  case RISCV::PSEUDO_ZAMES_MLAT_A_FP8E4_PRE:
    expandZamesPreRASingleConfig(
        TII, MBB, MBBI, MI, RISCV::PSEUDO_ZAMES_MLAT_A_FP8E4, ZamesCfgF8E4);
    break;
  case RISCV::PSEUDO_ZAMES_MLAT_A_FP8E5_PRE:
    expandZamesPreRASingleConfig(
        TII, MBB, MBBI, MI, RISCV::PSEUDO_ZAMES_MLAT_A_FP8E5, ZamesCfgF8E5);
    break;
  case RISCV::PSEUDO_ZAMES_MLAT_A_F16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MLAT_A_F16, ZamesCfgF16);
    break;
  case RISCV::PSEUDO_ZAMES_MLAT_A_BF16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MLAT_A_BF16, ZamesCfgBF16);
    break;
  case RISCV::PSEUDO_ZAMES_MLB_B_FP8E4_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MLB_B_FP8E4, ZamesCfgF8E4);
    break;
  case RISCV::PSEUDO_ZAMES_MLB_B_FP8E5_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MLB_B_FP8E5, ZamesCfgF8E5);
    break;
  case RISCV::PSEUDO_ZAMES_MLB_B_F16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MLB_B_F16, ZamesCfgF16);
    break;
  case RISCV::PSEUDO_ZAMES_MLB_B_BF16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MLB_B_BF16, ZamesCfgBF16);
    break;
  case RISCV::PSEUDO_ZAMES_MLBT_B_FP8E4_PRE:
    expandZamesPreRASingleConfig(
        TII, MBB, MBBI, MI, RISCV::PSEUDO_ZAMES_MLBT_B_FP8E4, ZamesCfgF8E4);
    break;
  case RISCV::PSEUDO_ZAMES_MLBT_B_FP8E5_PRE:
    expandZamesPreRASingleConfig(
        TII, MBB, MBBI, MI, RISCV::PSEUDO_ZAMES_MLBT_B_FP8E5, ZamesCfgF8E5);
    break;
  case RISCV::PSEUDO_ZAMES_MLBT_B_F16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MLBT_B_F16, ZamesCfgF16);
    break;
  case RISCV::PSEUDO_ZAMES_MLBT_B_BF16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MLBT_B_BF16, ZamesCfgBF16);
    break;
  case RISCV::PSEUDO_ZAMES_MLC_C_F32_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MLC_C_F32, ZamesCfgF32);
    break;
  case RISCV::PSEUDO_ZAMES_MLCT_C_F32_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MLCT_C_F32, ZamesCfgF32);
    break;
  case RISCV::PSEUDO_ZAMES_MSA_A_FP8E4_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MSA_A_FP8E4, ZamesCfgF8E4);
    break;
  case RISCV::PSEUDO_ZAMES_MSA_A_FP8E5_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MSA_A_FP8E5, ZamesCfgF8E5);
    break;
  case RISCV::PSEUDO_ZAMES_MSA_A_F16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MSA_A_F16, ZamesCfgF16);
    break;
  case RISCV::PSEUDO_ZAMES_MSA_A_BF16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MSA_A_BF16, ZamesCfgBF16);
    break;
  case RISCV::PSEUDO_ZAMES_MSAT_A_FP8E4_PRE:
    expandZamesPreRASingleConfig(
        TII, MBB, MBBI, MI, RISCV::PSEUDO_ZAMES_MSAT_A_FP8E4, ZamesCfgF8E4);
    break;
  case RISCV::PSEUDO_ZAMES_MSAT_A_FP8E5_PRE:
    expandZamesPreRASingleConfig(
        TII, MBB, MBBI, MI, RISCV::PSEUDO_ZAMES_MSAT_A_FP8E5, ZamesCfgF8E5);
    break;
  case RISCV::PSEUDO_ZAMES_MSAT_A_F16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MSAT_A_F16, ZamesCfgF16);
    break;
  case RISCV::PSEUDO_ZAMES_MSAT_A_BF16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MSAT_A_BF16, ZamesCfgBF16);
    break;
  case RISCV::PSEUDO_ZAMES_MSB_B_FP8E4_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MSB_B_FP8E4, ZamesCfgF8E4);
    break;
  case RISCV::PSEUDO_ZAMES_MSB_B_FP8E5_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MSB_B_FP8E5, ZamesCfgF8E5);
    break;
  case RISCV::PSEUDO_ZAMES_MSB_B_F16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MSB_B_F16, ZamesCfgF16);
    break;
  case RISCV::PSEUDO_ZAMES_MSB_B_BF16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MSB_B_BF16, ZamesCfgBF16);
    break;
  case RISCV::PSEUDO_ZAMES_MSBT_B_FP8E4_PRE:
    expandZamesPreRASingleConfig(
        TII, MBB, MBBI, MI, RISCV::PSEUDO_ZAMES_MSBT_B_FP8E4, ZamesCfgF8E4);
    break;
  case RISCV::PSEUDO_ZAMES_MSBT_B_FP8E5_PRE:
    expandZamesPreRASingleConfig(
        TII, MBB, MBBI, MI, RISCV::PSEUDO_ZAMES_MSBT_B_FP8E5, ZamesCfgF8E5);
    break;
  case RISCV::PSEUDO_ZAMES_MSBT_B_F16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MSBT_B_F16, ZamesCfgF16);
    break;
  case RISCV::PSEUDO_ZAMES_MSBT_B_BF16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MSBT_B_BF16, ZamesCfgBF16);
    break;
  case RISCV::PSEUDO_ZAMES_MSC_C_F32_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MSC_C_F32, ZamesCfgF32);
    break;
  case RISCV::PSEUDO_ZAMES_MSCT_C_F32_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MSCT_C_F32, ZamesCfgF32);
    break;
  case RISCV::PSEUDO_ZAMES_MZERO_T_I8_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MZERO_T_I8, ZamesCfgI8);
    break;
  case RISCV::PSEUDO_ZAMES_MZERO_T_FP8E4_PRE:
    expandZamesPreRASingleConfig(
        TII, MBB, MBBI, MI, RISCV::PSEUDO_ZAMES_MZERO_T_FP8E4, ZamesCfgF8E4);
    break;
  case RISCV::PSEUDO_ZAMES_MZERO_T_FP8E5_PRE:
    expandZamesPreRASingleConfig(
        TII, MBB, MBBI, MI, RISCV::PSEUDO_ZAMES_MZERO_T_FP8E5, ZamesCfgF8E5);
    break;
  case RISCV::PSEUDO_ZAMES_MZERO_T_F16_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MZERO_T_F16, ZamesCfgF16);
    break;
  case RISCV::PSEUDO_ZAMES_MZERO_T_BF16_PRE:
    expandZamesPreRASingleConfig(
        TII, MBB, MBBI, MI, RISCV::PSEUDO_ZAMES_MZERO_T_BF16, ZamesCfgBF16);
    break;
  case RISCV::PSEUDO_ZAMES_MZERO_C_F32_PRE:
    expandZamesPreRASingleConfig(TII, MBB, MBBI, MI,
                                 RISCV::PSEUDO_ZAMES_MZERO_C_F32, ZamesCfgF32);
    break;
  case RISCV::PSEUDO_ZAMES_MMACC_I8_F32_PRE:
    expandZamesPreRAMMAcc(TII, MBB, MBBI, MI, RISCV::PSEUDO_ZAMES_MMACC_I8_F32,
                          ZamesCfgF32, ZamesCfgI8);
    break;
  case RISCV::PSEUDO_ZAMES_MMACC_FP8E4_F32_PRE:
    expandZamesPreRAMMAcc(TII, MBB, MBBI, MI,
                          RISCV::PSEUDO_ZAMES_MMACC_FP8E4_F32, ZamesCfgF32,
                          ZamesCfgF8E4);
    break;
  case RISCV::PSEUDO_ZAMES_MMACC_FP8E5_F32_PRE:
    expandZamesPreRAMMAcc(TII, MBB, MBBI, MI,
                          RISCV::PSEUDO_ZAMES_MMACC_FP8E5_F32, ZamesCfgF32,
                          ZamesCfgF8E5);
    break;
  case RISCV::PSEUDO_ZAMES_MMACC_F16_F32_PRE:
    expandZamesPreRAMMAcc(TII, MBB, MBBI, MI, RISCV::PSEUDO_ZAMES_MMACC_F16_F32,
                          ZamesCfgF32, ZamesCfgF16);
    break;
  case RISCV::PSEUDO_ZAMES_MMACC_BF16_F32_PRE:
    expandZamesPreRAMMAcc(TII, MBB, MBBI, MI,
                          RISCV::PSEUDO_ZAMES_MMACC_BF16_F32, ZamesCfgF32,
                          ZamesCfgBF16);
    break;
  }

  MI.eraseFromParent();
  return true;
}

bool RISCVExpandPseudoPreRAImpl::expandAuipcInstPair(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI, unsigned FlagsHi,
    unsigned SecondOpcode) const {
  MachineFunction *MF = MBB.getParent();
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  Register DestReg = MI.getOperand(0).getReg();
  Register ScratchReg =
      MF->getRegInfo().createVirtualRegister(&RISCV::GPRRegClass);

  MachineOperand &Symbol = MI.getOperand(1);
  Symbol.setTargetFlags(FlagsHi);
  MCSymbol *AUIPCSymbol = MF->getContext().createNamedTempSymbol("pcrel_hi");

  MachineInstr *MIAUIPC =
      BuildMI(MBB, MBBI, DL, TII->get(RISCV::AUIPC), ScratchReg).add(Symbol);
  MIAUIPC->setPreInstrSymbol(*MF, AUIPCSymbol);

  MachineInstr *SecondMI =
      BuildMI(MBB, MBBI, DL, TII->get(SecondOpcode), DestReg)
          .addReg(ScratchReg)
          .addSym(AUIPCSymbol, RISCVII::MO_PCREL_LO);

  if (MI.hasOneMemOperand())
    SecondMI->addMemOperand(*MF, *MI.memoperands_begin());

  MI.eraseFromParent();
  return true;
}

bool RISCVExpandPseudoPreRAImpl::expandLoadLocalAddress(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI) const {
  return expandAuipcInstPair(MBB, MBBI, RISCVII::MO_PCREL_HI, RISCV::ADDI);
}

bool RISCVExpandPseudoPreRAImpl::expandLoadGlobalAddress(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI) const {
  unsigned SecondOpcode = STI->is64Bit() ? RISCV::LD : RISCV::LW;
  return expandAuipcInstPair(MBB, MBBI, RISCVII::MO_GOT_HI, SecondOpcode);
}

bool RISCVExpandPseudoPreRAImpl::expandLoadTLSIEAddress(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI) const {
  unsigned SecondOpcode = STI->is64Bit() ? RISCV::LD : RISCV::LW;
  return expandAuipcInstPair(MBB, MBBI, RISCVII::MO_TLS_GOT_HI, SecondOpcode);
}

bool RISCVExpandPseudoPreRAImpl::expandLoadTLSGDAddress(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI) const {
  return expandAuipcInstPair(MBB, MBBI, RISCVII::MO_TLS_GD_HI, RISCV::ADDI);
}

bool RISCVExpandPseudoPreRAImpl::expandLoadTLSDescAddress(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI) const {
  MachineFunction *MF = MBB.getParent();
  MachineInstr &MI = *MBBI;
  DebugLoc DL = MI.getDebugLoc();

  const auto &STI = MF->getSubtarget<RISCVSubtarget>();
  unsigned SecondOpcode = STI.is64Bit() ? RISCV::LD : RISCV::LW;

  Register FinalReg = MI.getOperand(0).getReg();
  Register DestReg =
      MF->getRegInfo().createVirtualRegister(&RISCV::GPRRegClass);
  Register ScratchReg =
      MF->getRegInfo().createVirtualRegister(&RISCV::GPRRegClass);

  MachineOperand &Symbol = MI.getOperand(1);
  Symbol.setTargetFlags(RISCVII::MO_TLSDESC_HI);
  MCSymbol *AUIPCSymbol = MF->getContext().createNamedTempSymbol("tlsdesc_hi");

  MachineInstr *MIAUIPC =
      BuildMI(MBB, MBBI, DL, TII->get(RISCV::AUIPC), ScratchReg).add(Symbol);
  MIAUIPC->setPreInstrSymbol(*MF, AUIPCSymbol);

  BuildMI(MBB, MBBI, DL, TII->get(SecondOpcode), DestReg)
      .addReg(ScratchReg)
      .addSym(AUIPCSymbol, RISCVII::MO_TLSDESC_LOAD_LO);

  BuildMI(MBB, MBBI, DL, TII->get(RISCV::ADDI), RISCV::X10)
      .addReg(ScratchReg)
      .addSym(AUIPCSymbol, RISCVII::MO_TLSDESC_ADD_LO);

  BuildMI(MBB, MBBI, DL, TII->get(RISCV::PseudoTLSDESCCall), RISCV::X5)
      .addReg(DestReg)
      .addImm(0)
      .addSym(AUIPCSymbol, RISCVII::MO_TLSDESC_CALL)
      ->setPhysRegsDeadExcept(Register(RISCV::X10), *STI.getRegisterInfo());

  BuildMI(MBB, MBBI, DL, TII->get(RISCV::ADD), FinalReg)
      .addReg(RISCV::X10)
      .addReg(RISCV::X4);

  MI.eraseFromParent();
  return true;
}

char RISCVExpandPseudoPreRALegacy::ID = 0;

INITIALIZE_PASS(RISCVExpandPseudoPreRALegacy, "riscv-expand-pseudo-pre-ra",
                RISCV_EXPAND_PSEUDO_PRE_RA_NAME, false, false)

FunctionPass *llvm::createRISCVExpandPseudoPreRALegacyPass() {
  return new RISCVExpandPseudoPreRALegacy();
}

PreservedAnalyses
RISCVExpandPseudoPreRAPass::run(MachineFunction &MF,
                                MachineFunctionAnalysisManager &MFAM) {
  MFPropsModifier _(*this, MF);
  bool Changed = RISCVExpandPseudoPreRAImpl().run(MF);
  if (!Changed)
    return PreservedAnalyses::all();

  PreservedAnalyses PA = getMachineFunctionPassPreservedAnalyses();
  PA.preserveSet<CFGAnalyses>();
  return PA;
}
