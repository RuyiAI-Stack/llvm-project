; RUN: not --crash llc -mtriple=riscv64 -mattr=+xboscame,-v -o /dev/null %s 2>&1 | FileCheck %s

; nxv32i32 can be named in either file, but a value defined in tr0 and used
; in acc0 is a cross-file copy. mmve64.a.t is a lane move, not a whole-register
; copy, so copyPhysReg reports a fatal error. not --crash accepts the abort
; from report_fatal_error, and FileCheck matches the diagnostic.

define void @cross_tile_acc() {
; CHECK: LLVM ERROR: copying between the AME tile and accumulator register files is not representable as a single instruction
  %v = call <vscale x 32 x i32> asm sideeffect "", "={tr0}"()
  call void asm sideeffect "", "{acc0}"(<vscale x 32 x i32> %v)
  ret void
}
