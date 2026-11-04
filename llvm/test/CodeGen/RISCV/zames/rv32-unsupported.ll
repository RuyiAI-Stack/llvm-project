; RV32 is not a supported ZAMES/ZMASYNC code generation target: the
; intrinsic scalar interfaces are i64 and the SelectionDAG patterns and
; pseudos are constrained to RV64. llc must reject RV32 with a stable
; diagnostic before instruction selection, without "Cannot select", a
; stack trace, or a crash.
;
; RUN: not llc -mtriple=riscv32 -mattr=+zames,+zmasync %s -o /dev/null 2>&1 | FileCheck %s

; CHECK-NOT: Cannot select
; CHECK: error: {{.*}}ZAMES/ZMASYNC code generation requires RV64
; CHECK-NOT: Cannot select

define target("riscv.xsai.zames.tile.int8") @rv32_zames(ptr %p, i64 %stride) {
  %t = call target("riscv.xsai.zames.tile.int8") @llvm.riscv.xsai.zames.mla.triscv.xsai.zames.tile.int8t(ptr %p, i64 %stride)
  ret target("riscv.xsai.zames.tile.int8") %t
}

define void @rv32_zmasync() {
  %s = call target("riscv.xsai.zmasync.sync") @llvm.riscv.xsai.zmasync.msyncregreset()
  call void @llvm.riscv.xsai.zmasync.mfence()
  ret void
}

declare target("riscv.xsai.zames.tile.int8") @llvm.riscv.xsai.zames.mla.triscv.xsai.zames.tile.int8t(ptr, i64)
declare target("riscv.xsai.zmasync.sync") @llvm.riscv.xsai.zmasync.msyncregreset()
declare void @llvm.riscv.xsai.zmasync.mfence()
