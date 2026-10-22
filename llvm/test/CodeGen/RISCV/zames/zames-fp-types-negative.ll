; RUN: not --crash llc -mtriple=riscv64 -mattr=+zames %s -o /dev/null 2>&1 \
; RUN:   | FileCheck %s

; Mixed input element types have no mmacc pattern: fp8e4 x fp8e5 is not a
; supported combination and must fail selection explicitly.

; CHECK: LLVM ERROR: Cannot select: intrinsic %llvm.riscv.zames.mmacc

define void @bad_mmacc(ptr %src, ptr %dst) {
  %a4 = call target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mla.whole.triscv.ame.tile.fp8e4t(ptr %src)
  %a5 = call target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mla.whole.triscv.ame.tile.fp8e5t(ptr %src)
  %c = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.fp32t(ptr %src)
  %r = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mmacc.triscv.ame.tile.fp32t.triscv.ame.tile.fp8e4t.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e4") %a4, target("riscv.ame.tile.fp8e5") %a5, target("riscv.ame.tile.fp32") %c)
  call void @llvm.riscv.zames.msc.whole.triscv.ame.tile.fp32t(target("riscv.ame.tile.fp32") %r, ptr %dst)
  ret void
}

declare target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mla.whole.triscv.ame.tile.fp8e4t(ptr)
declare target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mla.whole.triscv.ame.tile.fp8e5t(ptr)
declare target("riscv.ame.tile.fp32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.fp32t(ptr)
declare target("riscv.ame.tile.fp32") @llvm.riscv.zames.mmacc.triscv.ame.tile.fp32t.triscv.ame.tile.fp8e4t.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e4"), target("riscv.ame.tile.fp8e5"), target("riscv.ame.tile.fp32"))
declare void @llvm.riscv.zames.msc.whole.triscv.ame.tile.fp32t(target("riscv.ame.tile.fp32"), ptr)
