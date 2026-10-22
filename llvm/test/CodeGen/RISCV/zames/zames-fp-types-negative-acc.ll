; RUN: not --crash llc -mtriple=riscv64 -mattr=+zames %s -o /dev/null 2>&1 \
; RUN:   | FileCheck %s

; FP8 inputs only accumulate into fp32. An i32 accumulator has no mmacc
; pattern and must fail selection explicitly.

; CHECK: LLVM ERROR: Cannot select: intrinsic %llvm.riscv.zames.mmacc

define void @bad_mmacc_acc(ptr %src, ptr %dst) {
  %a4 = call target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mla.whole.triscv.ame.tile.fp8e4t(ptr %src)
  %b4 = call target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mla.whole.triscv.ame.tile.fp8e4t(ptr %dst)
  %c = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.int32t(ptr %src)
  %r = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mmacc.triscv.ame.tile.int32t.triscv.ame.tile.fp8e4t.triscv.ame.tile.fp8e4t(target("riscv.ame.tile.fp8e4") %a4, target("riscv.ame.tile.fp8e4") %b4, target("riscv.ame.tile.int32") %c)
  call void @llvm.riscv.zames.msc.whole.triscv.ame.tile.int32t(target("riscv.ame.tile.int32") %r, ptr %dst)
  ret void
}

declare target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mla.whole.triscv.ame.tile.fp8e4t(ptr)
declare target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.int32t(ptr)
declare target("riscv.ame.tile.int32") @llvm.riscv.zames.mmacc.triscv.ame.tile.int32t.triscv.ame.tile.fp8e4t.triscv.ame.tile.fp8e4t(target("riscv.ame.tile.fp8e4"), target("riscv.ame.tile.fp8e4"), target("riscv.ame.tile.int32"))
declare void @llvm.riscv.zames.msc.whole.triscv.ame.tile.int32t(target("riscv.ame.tile.int32"), ptr)
