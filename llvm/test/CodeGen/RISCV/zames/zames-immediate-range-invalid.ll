; Defensive ISel negatives: with the IR verifier disabled, an out-of-range
; immediate must still fail selection instead of being truncated into the
; 10-bit tile field or the 3-bit config selector.

; RUN: split-file %s %t
; RUN: not --crash llc -mtriple=riscv64 -mattr=+zames -disable-verify %t/settilemi-neg.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=MI-NEG
; RUN: not --crash llc -mtriple=riscv64 -mattr=+zames -disable-verify %t/settileni-1024.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=NI-1024
; RUN: not --crash llc -mtriple=riscv64 -mattr=+zames -disable-verify %t/settileki-1024.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=KI-1024
; RUN: not --crash llc -mtriple=riscv64 -mattr=+zames -disable-verify %t/msetcfg-8.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=SETCFG-8
; RUN: not --crash llc -mtriple=riscv64 -mattr=+zames -disable-verify %t/mgetcfg-neg.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=GETCFG-NEG

;--- settilemi-neg.ll
declare void @llvm.riscv.zames.msettilemi(i64)

define void @f() {
; MI-NEG: Cannot select
  call void @llvm.riscv.zames.msettilemi(i64 -1)
  ret void
}

;--- settileni-1024.ll
declare void @llvm.riscv.zames.msettileni(i64)

define void @f() {
; NI-1024: Cannot select
  call void @llvm.riscv.zames.msettileni(i64 1024)
  ret void
}

;--- settileki-1024.ll
declare void @llvm.riscv.zames.msettileki(i64)

define void @f() {
; KI-1024: Cannot select
  call void @llvm.riscv.zames.msettileki(i64 1024)
  ret void
}

;--- msetcfg-8.ll
declare void @llvm.riscv.zames.msetcfg(i64, i64)

define void @f(i64 %payload) {
; SETCFG-8: Cannot select
  call void @llvm.riscv.zames.msetcfg(i64 8, i64 %payload)
  ret void
}

;--- mgetcfg-neg.ll
declare i64 @llvm.riscv.zames.mgetcfg(i64)

define i64 @f() {
; GETCFG-NEG: Cannot select
  %r = call i64 @llvm.riscv.zames.mgetcfg(i64 -1)
  ret i64 %r
}
