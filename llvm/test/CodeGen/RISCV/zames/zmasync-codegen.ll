; RUN: llc -mtriple=riscv64 -mattr=+zmasync -verify-machineinstrs < %s | FileCheck %s

define void @zmasync_intrinsics(i64 %target) {
; CHECK-LABEL: zmasync_intrinsics:
; CHECK:       msyncregreset sync0
; CHECK-NEXT:  mrelease sync0
; CHECK-NEXT:  macquire sync0, a0
; CHECK-NEXT:  mfence
; CHECK-NEXT:  ret
  %sync0 = call target("riscv.xsai.zmasync.sync") @llvm.riscv.xsai.zmasync.msyncregreset()
  %sync1 = call target("riscv.xsai.zmasync.sync") @llvm.riscv.xsai.zmasync.mrelease(target("riscv.xsai.zmasync.sync") %sync0)
  call void @llvm.riscv.xsai.zmasync.macquire(target("riscv.xsai.zmasync.sync") %sync1, i64 %target)
  call void @llvm.riscv.xsai.zmasync.mfence()
  ret void
}

declare target("riscv.xsai.zmasync.sync") @llvm.riscv.xsai.zmasync.msyncregreset()
declare target("riscv.xsai.zmasync.sync") @llvm.riscv.xsai.zmasync.mrelease(target("riscv.xsai.zmasync.sync"))
declare void @llvm.riscv.xsai.zmasync.macquire(target("riscv.xsai.zmasync.sync"), i64)
declare void @llvm.riscv.xsai.zmasync.mfence()
