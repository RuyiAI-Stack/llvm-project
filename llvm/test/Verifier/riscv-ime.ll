; RUN: split-file %s %t
; RUN: not llvm-as %t/hp.ll -o /dev/null 2>&1 | FileCheck %s
; RUN: not llvm-as %t/sp.ll -o /dev/null 2>&1 | FileCheck %s
; CHECK: immarg operand has non-immediate parameter

;--- hp.ll
declare <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half>, <vscale x 8 x i8>, <vscale x 8 x i8>, <vscale x 4 x half>, i32 immarg)
define <vscale x 4 x half> @bad(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p, i32 %group) {
%r = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p, i32 %group)
ret <vscale x 4 x half> %r
}

;--- sp.ll
declare <vscale x 4 x i32> @llvm.riscv.ime.vmadot.sp(<vscale x 4 x i32>, <vscale x 16 x i8>, <vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
define <vscale x 4 x i32> @bad(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b, <vscale x 8 x i8> %p, i32 %group) {
%r = call <vscale x 4 x i32> @llvm.riscv.ime.vmadot.sp(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b, <vscale x 8 x i8> %p, i32 %group)
ret <vscale x 4 x i32> %r
}
