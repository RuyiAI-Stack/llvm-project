; RUN: split-file %s %t
; RUN: not llvm-as %t/pack-imm.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=IMM
; RUN: not llvm-as %t/narrow-imm.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=IMM
; RUN: not llvm-as %t/nibble-imm.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=IMM
; RUN: not llvm-as %t/pack-type.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=TYPE
; RUN: not llvm-as %t/narrow-type.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=RET
; IMM: immarg operand has non-immediate parameter
; TYPE: intrinsic argument 1 type
; TYPE-SAME: expected <vscale x 8 x i8>
; TYPE-SAME: but got <vscale x 4 x i16>
; RET: intrinsic return type

;--- pack-imm.ll
declare <vscale x 16 x i8> @llvm.riscv.ime.vpack.nxv16i8(<vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
define <vscale x 16 x i8> @bad(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b, i32 %imm) {
  %r = call <vscale x 16 x i8> @llvm.riscv.ime.vpack.nxv16i8(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b, i32 %imm)
  ret <vscale x 16 x i8> %r
}

;--- narrow-imm.ll
declare <vscale x 8 x i8> @llvm.riscv.ime.vnpack.nxv4i16(<vscale x 4 x i16>, <vscale x 4 x i16>, i32 immarg)
define <vscale x 8 x i8> @bad(<vscale x 4 x i16> %a, <vscale x 4 x i16> %b, i32 %imm) {
  %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnpack.nxv4i16(<vscale x 4 x i16> %a, <vscale x 4 x i16> %b, i32 %imm)
  ret <vscale x 8 x i8> %r
}

;--- nibble-imm.ll
declare <vscale x 8 x i8> @llvm.riscv.ime.vnpack4(<vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
define <vscale x 8 x i8> @bad(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b, i32 %imm) {
  %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnpack4(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b, i32 %imm)
  ret <vscale x 8 x i8> %r
}

;--- pack-type.ll
; Inputs must have the same element width and half the result element count.
declare <vscale x 16 x i8> @llvm.riscv.ime.vpack.nxv16i8(<vscale x 8 x i8>, <vscale x 4 x i16>, i32 immarg)

;--- narrow-type.ll
; Narrowing doubles the element count and halves the element width.
declare <vscale x 4 x i8> @llvm.riscv.ime.vnpack.nxv4i16(<vscale x 4 x i16>, <vscale x 4 x i16>, i32 immarg)
