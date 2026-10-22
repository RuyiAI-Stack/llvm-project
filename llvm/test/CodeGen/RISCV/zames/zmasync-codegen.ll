; RUN: llc -mtriple=riscv64 -mattr=+zmasync -verify-machineinstrs < %s | FileCheck %s

define void @zmasync_intrinsics(i64 %target) {
; CHECK-LABEL: zmasync_intrinsics:
; CHECK:       msyncregreset sync0
; CHECK-NEXT:  mrelease sync0
; CHECK-NEXT:  macquire sync0, a0
; CHECK-NEXT:  mfence
; CHECK-NEXT:  ret
  %sync0 = call target("riscv.ame.sync") @llvm.riscv.zmasync.msyncregreset()
  %sync1 = call target("riscv.ame.sync") @llvm.riscv.zmasync.mrelease(target("riscv.ame.sync") %sync0)
  call void @llvm.riscv.zmasync.macquire(target("riscv.ame.sync") %sync1, i64 %target)
  call void @llvm.riscv.zmasync.mfence()
  ret void
}

declare target("riscv.ame.sync") @llvm.riscv.zmasync.msyncregreset()
declare target("riscv.ame.sync") @llvm.riscv.zmasync.mrelease(target("riscv.ame.sync"))
declare void @llvm.riscv.zmasync.macquire(target("riscv.ame.sync"), i64)
declare void @llvm.riscv.zmasync.mfence()
