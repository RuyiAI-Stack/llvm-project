;; Generate ELF attributes for selected vendor extensions from llc.

; RUN: llc -mtriple=riscv32 -mattr=+xboscame %s -o - | FileCheck --check-prefixes=CHECK,RV32XBOSCAME %s
; RUN: llc -mtriple=riscv64 -mattr=+xboscame %s -o - | FileCheck --check-prefixes=CHECK,RV64XBOSCAME %s
; RUN: llc -mtriple=riscv32 -mattr=+xgemmini %s -o - | FileCheck --check-prefixes=CHECK,RV32XGEMMINI %s
; RUN: llc -mtriple=riscv64 -mattr=+xgemmini %s -o - | FileCheck --check-prefixes=CHECK,RV64XGEMMINI %s
; RUN: llc -mtriple=riscv32 -mattr=+v,+xsmtime %s -o - | FileCheck --check-prefixes=CHECK,RV32XSMTIME %s
; RUN: llc -mtriple=riscv64 -mattr=+v,+xsmtime %s -o - | FileCheck --check-prefixes=CHECK,RV64XSMTIME %s

; CHECK: .attribute 4, 16

; RV32XBOSCAME: .attribute 5, "rv32i2p1_xxiangshaname1p0"
; RV64XBOSCAME: .attribute 5, "rv64i2p1_xxiangshaname1p0"
; RV32XGEMMINI: .attribute 5, "rv32i2p1_xgemmini1p0"
; RV64XGEMMINI: .attribute 5, "rv64i2p1_xgemmini1p0"
; RV32XSMTIME: .attribute 5, "rv32i2p1_f2p2_d2p2_v1p0_zicsr2p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0_xsmtime1p0"
; RV64XSMTIME: .attribute 5, "rv64i2p1_f2p2_d2p2_v1p0_zicsr2p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0_xsmtime1p0"

define i32 @addi(i32 %a) {
  %1 = add i32 %a, 1
  ret i32 %1
}
