//===- RISCVXAME.h - Fixed XAME implementation profiles -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
// XAME implements the provisional ZTT v0.6 instruction set. The ISA leaves
// the matrix register-file profile to the implementation; these are the two
// profiles used by the AME toolchain.
//===----------------------------------------------------------------------===//

#ifndef LLVM_SUPPORT_RISCVXAME_H
#define LLVM_SUPPORT_RISCVXAME_H

namespace llvm::RISCV {

struct XAMEProfile {
  unsigned TileSide;
  unsigned MRegisters;
  unsigned AccRegisters;
  unsigned MaxElementBits;

  static constexpr unsigned UnitBits = 32;

  constexpr unsigned getMRegisterBytes() const {
    return TileSide * TileSide * UnitBits / 8;
  }

  constexpr unsigned getAccMImages() const { return MaxElementBits / UnitBits; }
};

inline constexpr XAMEProfile XAMEDefaultProfile{8, 16, 8, 64};
inline constexpr XAMEProfile XAMEGem5Profile{4, 32, 4, 128};

constexpr XAMEProfile getXAMEProfile(bool Gem5) {
  return Gem5 ? XAMEGem5Profile : XAMEDefaultProfile;
}

} // namespace llvm::RISCV

#endif // LLVM_SUPPORT_RISCVXAME_H
