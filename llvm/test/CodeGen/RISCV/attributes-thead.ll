;; Generate ELF attributes from llc.

; RUN: llc -mtriple=riscv32 -mattr=+xtheadba %s -o - | FileCheck --check-prefixes=CHECK,RV32XTHEADBA %s
; RUN: llc -mtriple=riscv32 -mattr=+xtheadbb %s -o - | FileCheck --check-prefixes=CHECK,RV32XTHEADBB %s
; RUN: llc -mtriple=riscv32 -mattr=+xtheadbs %s -o - | FileCheck --check-prefixes=CHECK,RV32XTHEADBS %s
; RUN: llc -mtriple=riscv32 -mattr=+xtheadcmo %s -o - | FileCheck --check-prefix=RV32XTHEADCMO %s
; RUN: llc -mtriple=riscv32 -mattr=+xtheadcondmov %s -o - | FileCheck --check-prefix=RV32XTHEADCONDMOV %s
; RUN: llc -mtriple=riscv32 -mattr=+xtheadfmemidx %s -o - | FileCheck --check-prefix=RV32XTHEADFMEMIDX %s
; RUN: llc -mtriple=riscv32 -mattr=+xtheadmac %s -o - | FileCheck --check-prefixes=CHECK,RV32XTHEADMAC %s
; RUN: llc -mtriple=riscv32 -mattr=+xtheadmemidx %s -o - | FileCheck --check-prefix=RV32XTHEADMEMIDX %s
; RUN: llc -mtriple=riscv32 -mattr=+xtheadmempair %s -o - | FileCheck --check-prefix=RV32XTHEADMEMPAIR %s
; RUN: llc -mtriple=riscv32 -mattr=+xtheadsync %s -o - | FileCheck --check-prefix=RV32XTHEADSYNC %s
; RUN: llc -mtriple=riscv32 -mattr=+xtheadvdot %s -o - | FileCheck --check-prefixes=CHECK,RV32XTHEADVDOT %s

; RUN: llc -mtriple=riscv64 -mattr=+xtheadba %s -o - | FileCheck --check-prefixes=CHECK,RV64XTHEADBA %s
; RUN: llc -mtriple=riscv64 -mattr=+xtheadbb %s -o - | FileCheck --check-prefixes=CHECK,RV64XTHEADBB %s
; RUN: llc -mtriple=riscv64 -mattr=+xtheadbs %s -o - | FileCheck --check-prefixes=CHECK,RV64XTHEADBS %s
; RUN: llc -mtriple=riscv64 -mattr=+xtheadcmo %s -o - | FileCheck --check-prefix=RV64XTHEADCMO %s
; RUN: llc -mtriple=riscv64 -mattr=+xtheadcondmov %s -o - | FileCheck --check-prefix=RV64XTHEADCONDMOV %s
; RUN: llc -mtriple=riscv64 -mattr=+xtheadfmemidx %s -o - | FileCheck --check-prefix=RV64XTHEADFMEMIDX %s
; RUN: llc -mtriple=riscv64 -mattr=+xtheadmac %s -o - | FileCheck --check-prefixes=CHECK,RV64XTHEADMAC %s
; RUN: llc -mtriple=riscv64 -mattr=+xtheadmemidx %s -o - | FileCheck --check-prefix=RV64XTHEADMEMIDX %s
; RUN: llc -mtriple=riscv64 -mattr=+xtheadmempair %s -o - | FileCheck --check-prefix=RV64XTHEADMEMPAIR %s
; RUN: llc -mtriple=riscv64 -mattr=+xtheadsync %s -o - | FileCheck --check-prefix=RV64XTHEADSYNC %s
; RUN: llc -mtriple=riscv64 -mattr=+xtheadvdot %s -o - | FileCheck --check-prefixes=CHECK,RV64XTHEADVDOT %s
; RUN: llc -mtriple=riscv64 -mattr=+m,+a,+f,+d,+c,+xtheadame %s -o - | FileCheck --check-prefixes=CHECK,RV64XTHEADAME %s

; CHECK: .attribute 4, 16

; RV32XTHEADBA: .attribute 5, "rv32i2p1_xtheadba1p0"
; RV32XTHEADBB: .attribute 5, "rv32i2p1_xtheadbb1p0"
; RV32XTHEADBS: .attribute 5, "rv32i2p1_xtheadbs1p0"
; RV32XTHEADCMO: .attribute 5, "rv32i2p1_xtheadcmo1p0"
; RV32XTHEADCONDMOV: .attribute 5, "rv32i2p1_xtheadcondmov1p0"
; RV32XTHEADFMEMIDX: .attribute 5, "rv32i2p1_xtheadfmemidx1p0"
; RV32XTHEADMAC: .attribute 5, "rv32i2p1_xtheadmac1p0"
; RV32XTHEADMEMIDX: .attribute 5, "rv32i2p1_xtheadmemidx1p0"
; RV32XTHEADMEMPAIR: .attribute 5, "rv32i2p1_xtheadmempair1p0"
; RV32XTHEADSYNC: .attribute 5, "rv32i2p1_xtheadsync1p0"
; RV32XTHEADVDOT: .attribute 5, "rv32i2p1_f2p2_d2p2_v1p0_zicsr2p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0_xtheadvdot1p0"

; RV64XTHEADBA: .attribute 5, "rv64i2p1_xtheadba1p0"
; RV64XTHEADBB: .attribute 5, "rv64i2p1_xtheadbb1p0"
; RV64XTHEADBS: .attribute 5, "rv64i2p1_xtheadbs1p0"
; RV64XTHEADCMO: .attribute 5, "rv64i2p1_xtheadcmo1p0"
; RV64XTHEADCONDMOV: .attribute 5, "rv64i2p1_xtheadcondmov1p0"
; RV64XTHEADFMEMIDX: .attribute 5, "rv64i2p1_xtheadfmemidx1p0"
; RV64XTHEADMAC: .attribute 5, "rv64i2p1_xtheadmac1p0"
; RV64XTHEADMEMIDX: .attribute 5, "rv64i2p1_xtheadmemidx1p0"
; RV64XTHEADMEMPAIR: .attribute 5, "rv64i2p1_xtheadmempair1p0"
; RV64XTHEADSYNC: .attribute 5, "rv64i2p1_xtheadsync1p0"
; RV64XTHEADVDOT: .attribute 5, "rv64i2p1_f2p2_d2p2_v1p0_zicsr2p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0_xtheadvdot1p0"
; RV64XTHEADAME: .attribute 5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_xtheadmatrix3p0_xtheadmatrixmin0p5_xtheadmdma0p5_xtheadmew16b0p5_xtheadmew32b0p5_xtheadmew4b0p5_xtheadmew64b0p5_xtheadmew8b0p5_xtheadmfew0p5_xtheadmfic0p5_xtheadmhp0p5_xtheadmiew0p5_xtheadmmbf16bbf16b0p5_xtheadmmbf16bf32b0p5_xtheadmmbf20bf32b0p5_xtheadmmf16bf16b0p5_xtheadmmf16bf32b0p5_xtheadmmf32bf32b0p5_xtheadmmf32bf64b0p5_xtheadmmf4bbf16b0p5_xtheadmmf4bf16b0p5_xtheadmmf4bf32b0p5_xtheadmmf64bf64b0p5_xtheadmmf8bbf16b0p5_xtheadmmf8bf16b0p5_xtheadmmf8bf32b0p5_xtheadmmi4bi32b0p5_xtheadmmi8bi32b0p5_xtheadmmmxf4b0p5_xtheadmmmxf8b0p5_xtheadmmmxf8bmxf4b0p5_xtheadmred0p5"

define i32 @addi(i32 %a) {
  %1 = add i32 %a, 1
  ret i32 %1
}
