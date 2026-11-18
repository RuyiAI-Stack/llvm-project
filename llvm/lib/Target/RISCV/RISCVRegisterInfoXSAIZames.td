//===-- XSAI Zames registers -------------------------------*- tablegen -*-===//
// RISCVRegisterInfoXSAIZames.td
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
class XSAI_ZAMES_TileRegBase<bits<3> Enc, string n> : Register<n> {
  let HWEncoding{2-0} = Enc;
  let HWEncoding{4-3} = 0b00;
}

// Keep ZAMES records distinct from BOSC AME's identically spelled registers.
def XSAI_ZAMES_TR0 : XSAI_ZAMES_TileRegBase<0, "tr0">;
def XSAI_ZAMES_TR1 : XSAI_ZAMES_TileRegBase<1, "tr1">;
def XSAI_ZAMES_TR2 : XSAI_ZAMES_TileRegBase<2, "tr2">;
def XSAI_ZAMES_TR3 : XSAI_ZAMES_TileRegBase<3, "tr3">;

// Base class for Accumulation Registers
class XSAI_ZAMES_AccRegBase<bits<3> Enc, string n> : Register<n> {
  let HWEncoding{2-0} = Enc;
  let HWEncoding{4-3} = 0b00;
}

// Define 4 Accumulation Registers: acc0-acc3 occupy the hardware register
// slots 4-7.
def XSAI_ZAMES_ACC0 : XSAI_ZAMES_AccRegBase<4, "acc0">;
def XSAI_ZAMES_ACC1 : XSAI_ZAMES_AccRegBase<5, "acc1">;
def XSAI_ZAMES_ACC2 : XSAI_ZAMES_AccRegBase<6, "acc2">;
def XSAI_ZAMES_ACC3 : XSAI_ZAMES_AccRegBase<7, "acc3">;

// ZMASYNC Sync Registers (sync0-sync15)
class XSAI_ZMASYNC_SyncReg<bits<5> Enc, string n> : Register<n> {
  let HWEncoding{4-0} = Enc;
}

foreach Index = 0-15 in {
  def XSAI_ZMASYNC_SYNC#Index : XSAI_ZMASYNC_SyncReg<Index, "sync"#Index>;
}

} // End Namespace = "RISCV"

defvar xsai_mi8_t = riscv_xsai_zames_tile_i8;
defvar xsai_mi32_t = riscv_xsai_zames_tile_i32;
defvar xsai_msync_t = riscv_xsai_zmasync_sync;
defvar xsai_mf8e4_t = riscv_xsai_zames_tile_fp8e4;
defvar xsai_mf8e5_t = riscv_xsai_zames_tile_fp8e5;
defvar xsai_mf16_t = riscv_xsai_zames_tile_f16;
defvar xsai_mbf16_t = riscv_xsai_zames_tile_bf16;
defvar xsai_mf32_t = riscv_xsai_zames_tile_f32;

// Tile Register class (tr0-tr3)
// Note: Size is set to 256 as a placeholder; actual size depends on MLEN
def XSAI_ZAMES_TileReg
    : RegisterClass<"RISCV", [xsai_mi8_t, xsai_mf8e4_t, xsai_mf8e5_t, xsai_mf16_t, xsai_mbf16_t], 256,
                    (add XSAI_ZAMES_TR0, XSAI_ZAMES_TR1, XSAI_ZAMES_TR2, XSAI_ZAMES_TR3)> {
  let Size = 256;  // Placeholder: actual MLEN is hardware-defined
}

// Accumulation Register class (acc0-acc3)
def XSAI_ZAMES_AccReg
    : RegisterClass<"RISCV", [xsai_mi32_t, xsai_mf32_t], 1024,
                    (add XSAI_ZAMES_ACC0, XSAI_ZAMES_ACC1, XSAI_ZAMES_ACC2, XSAI_ZAMES_ACC3)> {
  let Size = 1024;  // Placeholder: actual MLEN×AMUL is hardware-defined
}

// Union of XSAI_ZAMES_TileReg and XSAI_ZAMES_AccReg used only as a machine-instruction
// operand class for real instructions whose encoding accepts both register
// files (e.g. mzero). Virtual registers are still allocated through
// XSAI_ZAMES_TileReg or XSAI_ZAMES_AccReg according to their MVT; this class never
// participates in register allocation.
def XSAI_ZAMES_TileOrAccReg : RegisterClass<"RISCV",
                                      [xsai_mi8_t, xsai_mf8e4_t, xsai_mf8e5_t, xsai_mi32_t, xsai_mf16_t,
                                       xsai_mbf16_t, xsai_mf32_t], 1024,
                                      (add XSAI_ZAMES_TileReg, XSAI_ZAMES_AccReg)> {
  let Size = 1024;  // Placeholder, matches XSAI_ZAMES_AccReg
}

// Sync register class used by ZMASYNC instructions.
def XSAI_ZMASYNC_SyncR : RegisterClass<"RISCV", [xsai_msync_t], 64,
                          (add (sequence "XSAI_ZMASYNC_SYNC%u", 0, 15))>;
