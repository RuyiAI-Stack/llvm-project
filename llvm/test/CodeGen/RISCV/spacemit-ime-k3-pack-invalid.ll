; RUN: split-file %s %t
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/vpack--1.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=VPACK
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/vpack-4.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=VPACK
; VPACK: Cannot select: intrinsic %llvm.riscv.ime.vpack
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/vupack--1.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=VUPACK
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/vupack-4.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=VUPACK
; VUPACK: Cannot select: intrinsic %llvm.riscv.ime.vupack
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/vnpack--1.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=VNPACK
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/vnpack-4.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=VNPACK
; VNPACK: Cannot select: intrinsic %llvm.riscv.ime.vnpack
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/vnspack--1.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=VNSPACK
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/vnspack-4.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=VNSPACK
; VNSPACK: Cannot select: intrinsic %llvm.riscv.ime.vnspack
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/vnpack4--1.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=VNPACK4
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/vnpack4-4.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=VNPACK4
; VNPACK4: Cannot select: intrinsic %llvm.riscv.ime.vnpack4
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/vnspack4--1.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=VNSPACK4
; RUN: not --crash llc -mtriple=riscv64 -mcpu=spacemit-a100 %t/vnspack4-4.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=VNSPACK4
; VNSPACK4: Cannot select: intrinsic %llvm.riscv.ime.vnspack4

;--- vpack--1.ll
declare <vscale x 16 x i8> @llvm.riscv.ime.vpack.nxv16i8(<vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
define <vscale x 16 x i8> @bad(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b) {
 %r = call <vscale x 16 x i8> @llvm.riscv.ime.vpack.nxv16i8(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b, i32 -1)
 ret <vscale x 16 x i8> %r
}

;--- vpack-4.ll
declare <vscale x 16 x i8> @llvm.riscv.ime.vpack.nxv16i8(<vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
define <vscale x 16 x i8> @bad(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b) {
 %r = call <vscale x 16 x i8> @llvm.riscv.ime.vpack.nxv16i8(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b, i32 4)
 ret <vscale x 16 x i8> %r
}

;--- vupack--1.ll
declare <vscale x 16 x i8> @llvm.riscv.ime.vupack.nxv16i8(<vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
define <vscale x 16 x i8> @bad(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b) {
 %r = call <vscale x 16 x i8> @llvm.riscv.ime.vupack.nxv16i8(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b, i32 -1)
 ret <vscale x 16 x i8> %r
}

;--- vupack-4.ll
declare <vscale x 16 x i8> @llvm.riscv.ime.vupack.nxv16i8(<vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
define <vscale x 16 x i8> @bad(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b) {
 %r = call <vscale x 16 x i8> @llvm.riscv.ime.vupack.nxv16i8(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b, i32 4)
 ret <vscale x 16 x i8> %r
}

;--- vnpack--1.ll
declare <vscale x 8 x i8> @llvm.riscv.ime.vnpack.nxv4i16(<vscale x 4 x i16>, <vscale x 4 x i16>, i32 immarg)
define <vscale x 8 x i8> @bad(<vscale x 4 x i16> %a, <vscale x 4 x i16> %b) {
 %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnpack.nxv4i16(<vscale x 4 x i16> %a, <vscale x 4 x i16> %b, i32 -1)
 ret <vscale x 8 x i8> %r
}

;--- vnpack-4.ll
declare <vscale x 8 x i8> @llvm.riscv.ime.vnpack.nxv4i16(<vscale x 4 x i16>, <vscale x 4 x i16>, i32 immarg)
define <vscale x 8 x i8> @bad(<vscale x 4 x i16> %a, <vscale x 4 x i16> %b) {
 %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnpack.nxv4i16(<vscale x 4 x i16> %a, <vscale x 4 x i16> %b, i32 4)
 ret <vscale x 8 x i8> %r
}

;--- vnspack--1.ll
declare <vscale x 8 x i8> @llvm.riscv.ime.vnspack.nxv4i16(<vscale x 4 x i16>, <vscale x 4 x i16>, i32 immarg)
define <vscale x 8 x i8> @bad(<vscale x 4 x i16> %a, <vscale x 4 x i16> %b) {
 %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnspack.nxv4i16(<vscale x 4 x i16> %a, <vscale x 4 x i16> %b, i32 -1)
 ret <vscale x 8 x i8> %r
}

;--- vnspack-4.ll
declare <vscale x 8 x i8> @llvm.riscv.ime.vnspack.nxv4i16(<vscale x 4 x i16>, <vscale x 4 x i16>, i32 immarg)
define <vscale x 8 x i8> @bad(<vscale x 4 x i16> %a, <vscale x 4 x i16> %b) {
 %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnspack.nxv4i16(<vscale x 4 x i16> %a, <vscale x 4 x i16> %b, i32 4)
 ret <vscale x 8 x i8> %r
}

;--- vnpack4--1.ll
declare <vscale x 8 x i8> @llvm.riscv.ime.vnpack4(<vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
define <vscale x 8 x i8> @bad(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b) {
 %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnpack4(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b, i32 -1)
 ret <vscale x 8 x i8> %r
}

;--- vnpack4-4.ll
declare <vscale x 8 x i8> @llvm.riscv.ime.vnpack4(<vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
define <vscale x 8 x i8> @bad(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b) {
 %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnpack4(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b, i32 4)
 ret <vscale x 8 x i8> %r
}

;--- vnspack4--1.ll
declare <vscale x 8 x i8> @llvm.riscv.ime.vnspack4(<vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
define <vscale x 8 x i8> @bad(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b) {
 %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnspack4(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b, i32 -1)
 ret <vscale x 8 x i8> %r
}

;--- vnspack4-4.ll
declare <vscale x 8 x i8> @llvm.riscv.ime.vnspack4(<vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
define <vscale x 8 x i8> @bad(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b) {
 %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnspack4(<vscale x 8 x i8> %a, <vscale x 8 x i8> %b, i32 4)
 ret <vscale x 8 x i8> %r
}
