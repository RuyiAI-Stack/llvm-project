; RUN: llc -mtriple=riscv64 -mattr=+xame -verify-machineinstrs < %s | FileCheck %s

; Narrow ACC groups are packed by mmov.m.a/mmov.a.m. Preserve the base
; descriptor and the profile's two M images, including the live M scratch
; data, around the call.

declare void @external()
declare target("riscv.ztt.acc", i8, 8, 8, 4)
    @llvm.riscv.ztt.mzero.2d.acc(target("riscv.ztt.acc", i8, 8, 8, 4))

define target("riscv.ztt.acc", i8, 8, 8, 4) @preserve_acc_group(
    target("riscv.ztt.acc", i8, 8, 8, 4) %acc) {
; CHECK-LABEL: preserve_acc_group:
; CHECK:       mgettyp t1, m0
; CHECK:       mss.1r m1,
; CHECK:       agettyp t1, acc0
; CHECK:       mmov.m.a m0, acc0
; CHECK:       mss.1r m1,
; CHECK:       msettyp m0, t1
; CHECK:       mls.1r m1,
; CHECK:       call external
; CHECK:       mss.1r m1,
; CHECK:       asettyp acc0, t1
; CHECK:       mls.1r m1,
; CHECK:       mmov.a.m acc0, m0
; CHECK:       msettyp m0, t1
; CHECK:       mls.1r m1,
  call void @external()
  %r = call target("riscv.ztt.acc", i8, 8, 8, 4)
      @llvm.riscv.ztt.mzero.2d.acc(
          target("riscv.ztt.acc", i8, 8, 8, 4) %acc)
  ret target("riscv.ztt.acc", i8, 8, 8, 4) %r
}
