; RUN: not --crash llc -mtriple=riscv64 -verify-machineinstrs < %s 2>&1 | FileCheck %s

; Without +zames, the target must not legally select ZAMES matrix intrinsics.

define void @zames_requires_feature(ptr %c, i64 %stride) {
; CHECK: Cannot select: intrinsic %llvm.riscv.xsai.zames.msc
  call void @llvm.riscv.xsai.zames.msc.triscv.xsai.zames.tile.int32t(
      target("riscv.xsai.zames.tile.int32") undef, ptr %c, i64 %stride)
  ret void
}

declare void @llvm.riscv.xsai.zames.msc.triscv.xsai.zames.tile.int32t(target("riscv.xsai.zames.tile.int32"), ptr, i64)
