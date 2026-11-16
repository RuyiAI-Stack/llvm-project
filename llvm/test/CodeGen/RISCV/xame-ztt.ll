; RUN: llc -mtriple=riscv64 -mattr=+xame -verify-machineinstrs < %s | FileCheck %s

; XAME uses target-extension types in LLVM IR.  The element type and optional
; square count select the concrete MVT and register group before instruction
; selection; the instructions themselves use the common ZTT operand classes.

declare target("riscv.ztt.matrix", i32, 8, 8) @llvm.riscv.ztt.madd.ew(
    target("riscv.ztt.matrix", i32, 8, 8),
    target("riscv.ztt.matrix", i32, 8, 8),
    target("riscv.ztt.matrix", i32, 8, 8))

define target("riscv.ztt.matrix", i32, 8, 8) @matrix_madd(
    target("riscv.ztt.matrix", i32, 8, 8) %d,
    target("riscv.ztt.matrix", i32, 8, 8) %a,
    target("riscv.ztt.matrix", i32, 8, 8) %b) {
; CHECK-LABEL: matrix_madd:
; CHECK:       madd.ew m0, m1, m2
; CHECK-NEXT:  ret
  %r = call target("riscv.ztt.matrix", i32, 8, 8)
      @llvm.riscv.ztt.madd.ew(
          target("riscv.ztt.matrix", i32, 8, 8) %d,
          target("riscv.ztt.matrix", i32, 8, 8) %a,
          target("riscv.ztt.matrix", i32, 8, 8) %b)
  ret target("riscv.ztt.matrix", i32, 8, 8) %r
}

declare target("riscv.ztt.matrix", i32, 8, 8, 4) @llvm.riscv.ztt.madd.ew.m4(
    target("riscv.ztt.matrix", i32, 8, 8, 4),
    target("riscv.ztt.matrix", i32, 8, 8, 4),
    target("riscv.ztt.matrix", i32, 8, 8, 4))

define target("riscv.ztt.matrix", i32, 8, 8, 4) @matrix_madd4(
    target("riscv.ztt.matrix", i32, 8, 8, 4) %d,
    target("riscv.ztt.matrix", i32, 8, 8, 4) %a,
    target("riscv.ztt.matrix", i32, 8, 8, 4) %b) {
; CHECK-LABEL: matrix_madd4:
; CHECK:       madd.ew m0, m4, m8
; CHECK-NEXT:  ret
  %r = call target("riscv.ztt.matrix", i32, 8, 8, 4)
      @llvm.riscv.ztt.madd.ew.m4(
          target("riscv.ztt.matrix", i32, 8, 8, 4) %d,
          target("riscv.ztt.matrix", i32, 8, 8, 4) %a,
          target("riscv.ztt.matrix", i32, 8, 8, 4) %b)
  ret target("riscv.ztt.matrix", i32, 8, 8, 4) %r
}

declare target("riscv.ztt.acc", i8, 8, 8, 4) @llvm.riscv.ztt.mmulacc.2d(
    target("riscv.ztt.acc", i8, 8, 8, 4),
    target("riscv.ztt.matrix", i8, 8, 8),
    target("riscv.ztt.matrix", i8, 8, 8))

define target("riscv.ztt.acc", i8, 8, 8, 4) @packed_acc_mma(
    target("riscv.ztt.acc", i8, 8, 8, 4) %d,
    target("riscv.ztt.matrix", i8, 8, 8) %a,
    target("riscv.ztt.matrix", i8, 8, 8) %b) {
; CHECK-LABEL: packed_acc_mma:
; CHECK:       mmulacc.2d acc0, m0, m1
  %r = call target("riscv.ztt.acc", i8, 8, 8, 4)
      @llvm.riscv.ztt.mmulacc.2d(
          target("riscv.ztt.acc", i8, 8, 8, 4) %d,
          target("riscv.ztt.matrix", i8, 8, 8) %a,
          target("riscv.ztt.matrix", i8, 8, 8) %b)
  ret target("riscv.ztt.acc", i8, 8, 8, 4) %r
}

declare target("riscv.ztt.matrix", i32, 8, 8) @llvm.riscv.ztt.mzero.2d.m(
    target("riscv.ztt.matrix", i32, 8, 8))

define target("riscv.ztt.matrix", i32, 8, 8) @matrix_zero(
    target("riscv.ztt.matrix", i32, 8, 8) %m) {
; CHECK-LABEL: matrix_zero:
; CHECK:       mzero.2d.m m0
  %r = call target("riscv.ztt.matrix", i32, 8, 8)
      @llvm.riscv.ztt.mzero.2d.m(
          target("riscv.ztt.matrix", i32, 8, 8) %m)
  ret target("riscv.ztt.matrix", i32, 8, 8) %r
}
