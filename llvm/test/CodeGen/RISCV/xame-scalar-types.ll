; RUN: llc -mtriple=riscv64 -mattr=+xame -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=riscv32 -mattr=+xame -verify-machineinstrs < %s | FileCheck %s --check-prefixes=CHECK,RV32
; RUN: opt -passes=verify -disable-output %s

; XAME scalar operands/results are overloaded in IR, but each instruction uses
; one XLEN GPR. RV64 promotes narrow values and RV32 truncates wide operands.
; Check scalar results, matrix results, and void memory intrinsics so both
; legalization paths preserve the intrinsic chain and register operands.

declare i8 @llvm.riscv.ztt.ame.acquire.i8(i8)

define i8 @acquire_i8(i8 %x) {
; CHECK-LABEL: acquire_i8:
; CHECK:       ame.acquire a0, a0
  %r = call i8 @llvm.riscv.ztt.ame.acquire.i8(i8 %x)
  ret i8 %r
}

declare i16 @llvm.riscv.ztt.ame.acquire.i16(i16)

define i16 @acquire_i16(i16 %x) {
; CHECK-LABEL: acquire_i16:
; CHECK:       ame.acquire a0, a0
  %r = call i16 @llvm.riscv.ztt.ame.acquire.i16(i16 %x)
  ret i16 %r
}

declare i32 @llvm.riscv.ztt.ame.acquire.i32(i32)

define i32 @acquire_i32(i32 %x) {
; CHECK-LABEL: acquire_i32:
; CHECK:       ame.acquire a0, a0
  %r = call i32 @llvm.riscv.ztt.ame.acquire.i32(i32 %x)
  ret i32 %r
}

declare i64 @llvm.riscv.ztt.ame.acquire.i64(i64)

define i64 @acquire_i64(i64 %x) {
; CHECK-LABEL: acquire_i64:
; CHECK:       ame.acquire a0, a0
  %r = call i64 @llvm.riscv.ztt.ame.acquire.i64(i64 %x)
  ret i64 %r
}

declare i8 @llvm.riscv.ztt.mgettyp.i8.triscv.ztt.matrix_i8_8_8t(
    target("riscv.ztt.matrix", i8, 8, 8))

define i8 @gettyp_i8(target("riscv.ztt.matrix", i8, 8, 8) %m) {
; CHECK-LABEL: gettyp_i8:
; CHECK:       mgettyp a0, m0
  %r = call i8 @llvm.riscv.ztt.mgettyp.i8.triscv.ztt.matrix_i8_8_8t(
      target("riscv.ztt.matrix", i8, 8, 8) %m)
  ret i8 %r
}

declare target("riscv.ztt.matrix", i8, 8, 8)
    @llvm.riscv.ztt.msettyp.triscv.ztt.matrix_i8_8_8t.i8(
      target("riscv.ztt.matrix", i8, 8, 8), i8)

define target("riscv.ztt.matrix", i8, 8, 8) @settyp_i8(
    target("riscv.ztt.matrix", i8, 8, 8) %m, i8 %x) {
; CHECK-LABEL: settyp_i8:
; CHECK:       msettyp m0, a0
  %r = call target("riscv.ztt.matrix", i8, 8, 8)
      @llvm.riscv.ztt.msettyp.triscv.ztt.matrix_i8_8_8t.i8(
        target("riscv.ztt.matrix", i8, 8, 8) %m, i8 %x)
  ret target("riscv.ztt.matrix", i8, 8, 8) %r
}

declare i64 @llvm.riscv.ztt.agettyp.i64.triscv.ztt.acc_i32_8_8t(
    target("riscv.ztt.acc", i32, 8, 8))

define i64 @agettyp_i64(target("riscv.ztt.acc", i32, 8, 8) %a) {
; CHECK-LABEL: agettyp_i64:
; CHECK:       agettyp a0, acc0
; RV32:        li a1, 0
  %r = call i64 @llvm.riscv.ztt.agettyp.i64.triscv.ztt.acc_i32_8_8t(
      target("riscv.ztt.acc", i32, 8, 8) %a)
  ret i64 %r
}

declare target("riscv.ztt.acc", i32, 8, 8)
    @llvm.riscv.ztt.asettyp.triscv.ztt.acc_i32_8_8t.i16(
      target("riscv.ztt.acc", i32, 8, 8), i16)

define target("riscv.ztt.acc", i32, 8, 8) @asettyp_i16(
    target("riscv.ztt.acc", i32, 8, 8) %a, i16 %x) {
; CHECK-LABEL: asettyp_i16:
; CHECK:       asettyp acc0, a0
  %r = call target("riscv.ztt.acc", i32, 8, 8)
      @llvm.riscv.ztt.asettyp.triscv.ztt.acc_i32_8_8t.i16(
        target("riscv.ztt.acc", i32, 8, 8) %a, i16 %x)
  ret target("riscv.ztt.acc", i32, 8, 8) %r
}

declare target("riscv.ztt.matrix", i8, 8, 8)
    @llvm.riscv.ztt.mls.st.triscv.ztt.matrix_i8_8_8t.i16(
      target("riscv.ztt.matrix", i8, 8, 8), ptr, i16)

define target("riscv.ztt.matrix", i8, 8, 8) @load_stride_i16(
    target("riscv.ztt.matrix", i8, 8, 8) %m, ptr %p, i16 %stride) {
; CHECK-LABEL: load_stride_i16:
; CHECK:       mls.st m0, (a0), a1
  %r = call target("riscv.ztt.matrix", i8, 8, 8)
      @llvm.riscv.ztt.mls.st.triscv.ztt.matrix_i8_8_8t.i16(
        target("riscv.ztt.matrix", i8, 8, 8) %m, ptr %p, i16 %stride)
  ret target("riscv.ztt.matrix", i8, 8, 8) %r
}

declare void @llvm.riscv.ztt.mss.st.triscv.ztt.matrix_i8_8_8t.i16(
    target("riscv.ztt.matrix", i8, 8, 8), ptr, i16)

define void @store_stride_i16(
    target("riscv.ztt.matrix", i8, 8, 8) %m, ptr %p, i16 %stride) {
; CHECK-LABEL: store_stride_i16:
; CHECK:       mss.st m0, (a0), a1
  call void @llvm.riscv.ztt.mss.st.triscv.ztt.matrix_i8_8_8t.i16(
      target("riscv.ztt.matrix", i8, 8, 8) %m, ptr %p, i16 %stride)
  ret void
}

; The high bits of a truncated value may still be present in the incoming GPR.
; Clear them before instructions consume the complete XLEN operand; an input
; of 256, for example, must acquire with descriptor 0 rather than BAD_DESC.
define i8 @acquire_truncated(i64 %input) {
; CHECK-LABEL: acquire_truncated:
; CHECK:       zext.b a0, a0
; CHECK-NEXT:  ame.acquire a0, a0
  %byte = trunc i64 %input to i8
  %r = call i8 @llvm.riscv.ztt.ame.acquire.i8(i8 %byte)
  ret i8 %r
}

; Constants follow the same unsigned-bit-pattern convention as variables.
define i8 @acquire_unsigned_constant() {
; CHECK-LABEL: acquire_unsigned_constant:
; CHECK:       li a0, 240
; CHECK-NEXT:  ame.acquire a0, a0
  %r = call i8 @llvm.riscv.ztt.ame.acquire.i8(i8 -16)
  ret i8 %r
}

define target("riscv.ztt.matrix", i8, 8, 8) @settyp_truncated(
    target("riscv.ztt.matrix", i8, 8, 8) %m, i64 %input) {
; CHECK-LABEL: settyp_truncated:
; CHECK:       zext.b a0, a0
; CHECK-NEXT:  msettyp m0, a0
  %byte = trunc i64 %input to i8
  %r = call target("riscv.ztt.matrix", i8, 8, 8)
      @llvm.riscv.ztt.msettyp.triscv.ztt.matrix_i8_8_8t.i8(
          target("riscv.ztt.matrix", i8, 8, 8) %m, i8 %byte)
  ret target("riscv.ztt.matrix", i8, 8, 8) %r
}

declare i8 @llvm.riscv.ztt.mmove32.x.m.i8.triscv.ztt.matrix_i32_8_8t(
    target("riscv.ztt.matrix", i32, 8, 8), i8)

define i8 @extract_index_truncated(
    target("riscv.ztt.matrix", i32, 8, 8) %m, i64 %input) {
; CHECK-LABEL: extract_index_truncated:
; CHECK:       zext.b a0, a0
; CHECK-NEXT:  mmove32.x.m a0, m0, a0
  %byte = trunc i64 %input to i8
  %r = call i8 @llvm.riscv.ztt.mmove32.x.m.i8.triscv.ztt.matrix_i32_8_8t(
      target("riscv.ztt.matrix", i32, 8, 8) %m, i8 %byte)
  ret i8 %r
}
