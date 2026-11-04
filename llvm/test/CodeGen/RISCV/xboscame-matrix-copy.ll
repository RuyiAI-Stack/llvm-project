; RUN: llc -mtriple=riscv64 -mattr=+xboscame,-v -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=riscv64 -mattr=+xboscame,+v -verify-machineinstrs < %s | FileCheck %s

; copyPhysReg for two registers in the same matrix file. The fixed asm
; registers make the copy mandatory: the value is defined in tr1 or acc1 and
; used in tr0 or acc0. nxv128i8 is a tile type, so the move is mmve64.t.t.
; nxv32i32 is an accumulator type and is not an RVV legal type, so the move
; stays mmve64.a.a both with and without V. Both RUN lines also require the
; copies to pass machine verification.

define void @copy_tile() {
; CHECK-LABEL: copy_tile:
; CHECK: mmve64.t.t tr0, tr1
  %v = call <vscale x 128 x i8> asm sideeffect "", "={tr1}"()
  call void asm sideeffect "", "{tr0}"(<vscale x 128 x i8> %v)
  ret void
}

define void @copy_acc() {
; CHECK-LABEL: copy_acc:
; CHECK: mmve64.a.a acc0, acc1
  %v = call <vscale x 32 x i32> asm sideeffect "", "={acc1}"()
  call void asm sideeffect "", "{acc0}"(<vscale x 32 x i32> %v)
  ret void
}
