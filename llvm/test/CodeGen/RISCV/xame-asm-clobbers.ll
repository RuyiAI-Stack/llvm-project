; RUN: llc -mtriple=riscv32 -verify-machineinstrs -stop-after=finalize-isel < %s | FileCheck %s
; RUN: llc -mtriple=riscv64 -verify-machineinstrs -stop-after=finalize-isel < %s | FileCheck %s

; Check the physical bank as well as the spelling: XAIFET masks also print
; m0-m7, and the legacy AME register bank also prints acc0-acc7.
define void @common_clobbers() #0 {
; CHECK-LABEL: name: common_clobbers
; CHECK: INLINEASM
; CHECK-SAME: implicit-def dead early-clobber $zttm0
; CHECK-SAME: implicit-def dead early-clobber $zttm1
; CHECK-SAME: implicit-def dead early-clobber $zttm7
; CHECK-SAME: implicit-def dead early-clobber $zttm15
; CHECK-SAME: implicit-def dead early-clobber $ztta0
; CHECK-SAME: implicit-def dead early-clobber $ztta3
  call void asm sideeffect "", "~{m0},~{m1},~{m7},~{m15},~{acc0},~{acc3},~{memory}"()
  ret void
}

define void @default_clobbers() #0 {
; CHECK-LABEL: name: default_clobbers
; CHECK: INLINEASM
; CHECK-SAME: implicit-def dead early-clobber $zttm15
; CHECK-SAME: implicit-def dead early-clobber $ztta7
  call void asm sideeffect "", "~{M15},~{ACC7}"()
  ret void
}

define void @gem5_clobbers() #1 {
; CHECK-LABEL: name: gem5_clobbers
; CHECK: INLINEASM
; CHECK-SAME: implicit-def dead early-clobber $zttm31
; CHECK-SAME: implicit-def dead early-clobber $ztta3
  call void asm sideeffect "", "~{m31},~{acc3}"()
  ret void
}

; Profile-invalid names must not fall through to another register bank.
define void @default_out_of_range_clobbers() #0 {
; CHECK-LABEL: name: default_out_of_range_clobbers
; CHECK: INLINEASM
; CHECK-NOT: implicit-def
; CHECK: PseudoRET
  call void asm sideeffect "", "~{m16},~{acc8}"()
  ret void
}

define void @gem5_out_of_range_clobbers() #1 {
; CHECK-LABEL: name: gem5_out_of_range_clobbers
; CHECK: INLINEASM
; CHECK-NOT: implicit-def
; CHECK: PseudoRET
  call void asm sideeffect "", "~{m32},~{acc4}"()
  ret void
}

define void @disabled_clobbers() #2 {
; CHECK-LABEL: name: disabled_clobbers
; CHECK: INLINEASM
; CHECK-NOT: $ztt
; CHECK: PseudoRET
  call void asm sideeffect "", "~{m0},~{acc0}"()
  ret void
}

attributes #0 = { "target-features"="+xame,-xame-gem5" }
attributes #1 = { "target-features"="+xame,+xame-gem5" }
attributes #2 = { "target-features"="-xame,-xame-gem5" }
