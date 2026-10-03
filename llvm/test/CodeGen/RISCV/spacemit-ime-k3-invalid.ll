; RUN: split-file %s %t
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/hp-high.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=HP
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/hp-negative.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=HP
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/sp-high.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=SP
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/sp-negative.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=SP
; HP: Cannot select: intrinsic %llvm.riscv.ime.vmadot.hp
; SP: Cannot select: intrinsic %llvm.riscv.ime.vmadot.sp

;--- hp-high.ll
declare <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half>, <vscale x 8 x i8>, <vscale x 8 x i8>, <vscale x 4 x half>, i32 immarg)
define <vscale x 4 x half> @bad(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p) {
%r = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p, i32 8)
ret <vscale x 4 x half> %r
}

;--- hp-negative.ll
declare <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half>, <vscale x 8 x i8>, <vscale x 8 x i8>, <vscale x 4 x half>, i32 immarg)
define <vscale x 4 x half> @bad(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p) {
%r = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p, i32 -1)
ret <vscale x 4 x half> %r
}

;--- sp-high.ll
declare <vscale x 4 x i32> @llvm.riscv.ime.vmadot.sp(<vscale x 4 x i32>, <vscale x 16 x i8>, <vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
define <vscale x 4 x i32> @bad(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b, <vscale x 8 x i8> %p) {
%r = call <vscale x 4 x i32> @llvm.riscv.ime.vmadot.sp(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b, <vscale x 8 x i8> %p, i32 4)
ret <vscale x 4 x i32> %r
}

;--- sp-negative.ll
declare <vscale x 4 x i32> @llvm.riscv.ime.vmadot.sp(<vscale x 4 x i32>, <vscale x 16 x i8>, <vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
define <vscale x 4 x i32> @bad(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b, <vscale x 8 x i8> %p) {
%r = call <vscale x 4 x i32> @llvm.riscv.ime.vmadot.sp(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b, <vscale x 8 x i8> %p, i32 -1)
ret <vscale x 4 x i32> %r
}
