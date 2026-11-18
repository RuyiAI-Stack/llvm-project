; RUN: not --crash llc -mtriple=riscv64 -mattr=+zames %s -o /dev/null 2>&1 \
; RUN:   | FileCheck %s

; Mixed input element types have no mmacc pattern: fp8e4 x fp8e5 is not a
; supported combination and must fail selection explicitly.

; CHECK: LLVM ERROR: Cannot select: intrinsic %llvm.riscv.xsai.zames.mmacc

define void @bad_mmacc(ptr %src, ptr %dst) {
  %a4 = call target("riscv.xsai.zames.tile.fp8e4") @llvm.riscv.xsai.zames.mla.whole.triscv.xsai.zames.tile.fp8e4t(ptr %src)
  %a5 = call target("riscv.xsai.zames.tile.fp8e5") @llvm.riscv.xsai.zames.mla.whole.triscv.xsai.zames.tile.fp8e5t(ptr %src)
  %c = call target("riscv.xsai.zames.tile.fp32") @llvm.riscv.xsai.zames.mlc.whole.triscv.xsai.zames.tile.fp32t(ptr %src)
  %r = call target("riscv.xsai.zames.tile.fp32") @llvm.riscv.xsai.zames.mmacc.triscv.xsai.zames.tile.fp32t.triscv.xsai.zames.tile.fp8e4t.triscv.xsai.zames.tile.fp8e5t(target("riscv.xsai.zames.tile.fp8e4") %a4, target("riscv.xsai.zames.tile.fp8e5") %a5, target("riscv.xsai.zames.tile.fp32") %c)
  call void @llvm.riscv.xsai.zames.msc.whole.triscv.xsai.zames.tile.fp32t(target("riscv.xsai.zames.tile.fp32") %r, ptr %dst)
  ret void
}

declare target("riscv.xsai.zames.tile.fp8e4") @llvm.riscv.xsai.zames.mla.whole.triscv.xsai.zames.tile.fp8e4t(ptr)
declare target("riscv.xsai.zames.tile.fp8e5") @llvm.riscv.xsai.zames.mla.whole.triscv.xsai.zames.tile.fp8e5t(ptr)
declare target("riscv.xsai.zames.tile.fp32") @llvm.riscv.xsai.zames.mlc.whole.triscv.xsai.zames.tile.fp32t(ptr)
declare target("riscv.xsai.zames.tile.fp32") @llvm.riscv.xsai.zames.mmacc.triscv.xsai.zames.tile.fp32t.triscv.xsai.zames.tile.fp8e4t.triscv.xsai.zames.tile.fp8e5t(target("riscv.xsai.zames.tile.fp8e4"), target("riscv.xsai.zames.tile.fp8e5"), target("riscv.xsai.zames.tile.fp32"))
declare void @llvm.riscv.xsai.zames.msc.whole.triscv.xsai.zames.tile.fp32t(target("riscv.xsai.zames.tile.fp32"), ptr)
