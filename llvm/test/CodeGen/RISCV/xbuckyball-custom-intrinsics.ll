; RUN: llc -mtriple=riscv64 -mattr=+xbuckyball %s -o - | FileCheck %s

; CHECK-LABEL: xbuckyball_custom:
;       CHECK: bb_custom 49, a0, a1
;       CHECK: bb_custom 65, a0, a1
define void @xbuckyball_custom(i64 %rs1, i64 %rs2) {
  call void @llvm.riscv.buckyball.custom(i64 %rs1, i64 %rs2, i32 49)
  call void @llvm.riscv.buckyball.custom(i64 %rs1, i64 %rs2, i32 65)
  ret void
}

declare void @llvm.riscv.buckyball.custom(i64, i64, i32 immarg)
