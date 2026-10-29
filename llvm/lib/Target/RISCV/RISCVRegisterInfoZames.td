//===-- RISCVRegisterInfoZames.td - ZAMES/ZMASYNC registers -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// ZAMES/ZMASYNC register definitions.
//
//   - 4 Tile Registers (tr0-tr3): input matrices A and B
//   - 4 Accumulation Registers (acc0-acc3): output/accumulation matrix C
//   - 16 Sync Registers (sync0-sync15): ZMASYNC synchronization
//
// RegisterClass Size values are placeholders; the real MLEN/AMUL ABI is not
// part of the MC-level migration.
//
//===----------------------------------------------------------------------===//

let Namespace = "RISCV" in {

// Base class for Tile Registers
class AMETileReg<bits<3> Enc, string n> : Register<n> {
  let HWEncoding{2-0} = Enc;
  let HWEncoding{4-3} = 0b00;
}

// Keep ZAMES records distinct from BOSC AME's identically spelled registers.
def ZAMES_TR0 : AMETileReg<0, "tr0">;
def ZAMES_TR1 : AMETileReg<1, "tr1">;
def ZAMES_TR2 : AMETileReg<2, "tr2">;
def ZAMES_TR3 : AMETileReg<3, "tr3">;

// Base class for Accumulation Registers
class AMEAccReg<bits<3> Enc, string n> : Register<n> {
  let HWEncoding{2-0} = Enc;
  let HWEncoding{4-3} = 0b00;
}

// Define 4 Accumulation Registers: acc0-acc3 occupy the hardware register
// slots 4-7.
def ZAMES_ACC0 : AMEAccReg<4, "acc0">;
def ZAMES_ACC1 : AMEAccReg<5, "acc1">;
def ZAMES_ACC2 : AMEAccReg<6, "acc2">;
def ZAMES_ACC3 : AMEAccReg<7, "acc3">;

// ZMASYNC Sync Registers (sync0-sync15)
class ZMASyncReg<bits<5> Enc, string n> : Register<n> {
  let HWEncoding{4-0} = Enc;
}

foreach Index = 0-15 in {
  def SYNC#Index : ZMASyncReg<Index, "sync"#Index>;
}

} // End Namespace = "RISCV"

defvar mi8_t = riscv_ame_tile_i8;
defvar mi32_t = riscv_ame_tile_i32;
defvar msync_t = riscv_ame_sync;
defvar mf8e4_t = riscv_ame_tile_fp8e4;
defvar mf8e5_t = riscv_ame_tile_fp8e5;
defvar mf16_t = riscv_ame_tile_f16;
defvar mbf16_t = riscv_ame_tile_bf16;
defvar mf32_t = riscv_ame_tile_f32;

// Tile Register class (tr0-tr3)
// Note: Size is set to 256 as a placeholder; actual size depends on MLEN
def ZamesTileReg
    : RegisterClass<"RISCV", [mi8_t, mf8e4_t, mf8e5_t, mf16_t, mbf16_t], 256,
                    (add ZAMES_TR0, ZAMES_TR1, ZAMES_TR2, ZAMES_TR3)> {
  let Size = 256;  // Placeholder: actual MLEN is hardware-defined
}

// Accumulation Register class (acc0-acc3)
def ZamesAccReg
    : RegisterClass<"RISCV", [mi32_t, mf32_t], 1024,
                    (add ZAMES_ACC0, ZAMES_ACC1, ZAMES_ACC2, ZAMES_ACC3)> {
  let Size = 1024;  // Placeholder: actual MLEN×AMUL is hardware-defined
}

// Union of ZamesTileReg and ZamesAccReg used only as a machine-instruction
// operand class for real instructions whose encoding accepts both register
// files (e.g. mzero). Virtual registers are still allocated through
// ZamesTileReg or ZamesAccReg according to their MVT; this class never
// participates in register allocation.
def ZamesTileOrAccReg : RegisterClass<"RISCV",
                                      [mi8_t, mf8e4_t, mf8e5_t, mi32_t, mf16_t,
                                       mbf16_t, mf32_t], 1024,
                                      (add ZamesTileReg, ZamesAccReg)> {
  let Size = 1024;  // Placeholder, matches ZamesAccReg
}

// Sync register class used by ZMASYNC instructions.
def SyncR : RegisterClass<"RISCV", [msync_t], 64,
                          (add (sequence "SYNC%u", 0, 15))>;
