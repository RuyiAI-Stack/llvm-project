; RUN: llvm-as %s -o %t.bc
; RUN: llvm-dis %t.bc -o - | FileCheck %s
; RUN: opt -passes=verify -disable-output %s

; Round-trip every ZAMES/ZMASYNC intrinsic and every target extension type
; through the standard LLVM assembly/disassembly path.

; --- Non-overloaded configuration intrinsics ----------------------------

; CHECK-LABEL: define void @config(
; CHECK: call void @llvm.riscv.xsai.zames.msettilemi(i64 4)
; CHECK: call void @llvm.riscv.xsai.zames.msettileni(i64 8)
; CHECK: call void @llvm.riscv.xsai.zames.msettileki(i64 16)
; CHECK: call void @llvm.riscv.xsai.zames.msettilem(i64 %m)
; CHECK: call void @llvm.riscv.xsai.zames.msettilen(i64 %n)
; CHECK: call void @llvm.riscv.xsai.zames.msettilek(i64 %k)
; CHECK: call void @llvm.riscv.xsai.zames.msetcfg(i64 4, i64 %payload)
; CHECK: %cfg = call i64 @llvm.riscv.xsai.zames.mgetcfg(i64 4)
; CHECK: call void @llvm.riscv.xsai.zames.minit()
define void @config(i64 %m, i64 %n, i64 %k, i64 %payload) {
  call void @llvm.riscv.xsai.zames.msettilemi(i64 4)
  call void @llvm.riscv.xsai.zames.msettileni(i64 8)
  call void @llvm.riscv.xsai.zames.msettileki(i64 16)
  call void @llvm.riscv.xsai.zames.msettilem(i64 %m)
  call void @llvm.riscv.xsai.zames.msettilen(i64 %n)
  call void @llvm.riscv.xsai.zames.msettilek(i64 %k)
  call void @llvm.riscv.xsai.zames.msetcfg(i64 4, i64 %payload)
  %cfg = call i64 @llvm.riscv.xsai.zames.mgetcfg(i64 4)
  call void @llvm.riscv.xsai.zames.minit()
  ret void
}

; --- Overloaded load/store on int8 tiles --------------------------------

; CHECK-LABEL: define void @load_store_i8(
; CHECK: %a = call target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.int8t(ptr %pa, i64 %s)
; CHECK: %at = call target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mlat.triscv.xsai.ame.tile.int8t(ptr %pa, i64 %s)
; CHECK: %aw = call target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mla.whole.triscv.xsai.ame.tile.int8t(ptr %pa)
; CHECK: call void @llvm.riscv.xsai.zames.msa.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8") %a, ptr %pa, i64 %s)
; CHECK: call void @llvm.riscv.xsai.zames.msat.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8") %at, ptr %pa, i64 %s)
; CHECK: call void @llvm.riscv.xsai.zames.msa.whole.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8") %aw, ptr %pa)
define void @load_store_i8(ptr %pa, i64 %s) {
  %a = call target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.int8t(ptr %pa, i64 %s)
  %at = call target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mlat.triscv.xsai.ame.tile.int8t(ptr %pa, i64 %s)
  %aw = call target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mla.whole.triscv.xsai.ame.tile.int8t(ptr %pa)
  call void @llvm.riscv.xsai.zames.msa.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8") %a, ptr %pa, i64 %s)
  call void @llvm.riscv.xsai.zames.msat.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8") %at, ptr %pa, i64 %s)
  call void @llvm.riscv.xsai.zames.msa.whole.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8") %aw, ptr %pa)
  ret void
}

; --- B/C tile class + transposed/whole on int32 accumulator -------------

; CHECK-LABEL: define void @load_store_bc(
; CHECK: %b = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlb.triscv.xsai.ame.tile.int32t(ptr %pb, i64 %s)
; CHECK: %bt = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlbt.triscv.xsai.ame.tile.int32t(ptr %pb, i64 %s)
; CHECK: %bw = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlb.whole.triscv.xsai.ame.tile.int32t(ptr %pb)
; CHECK: %c = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlc.triscv.xsai.ame.tile.int32t(ptr %pc, i64 %s)
; CHECK: %ct = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlct.triscv.xsai.ame.tile.int32t(ptr %pc, i64 %s)
; CHECK: %cw = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlc.whole.triscv.xsai.ame.tile.int32t(ptr %pc)
; CHECK: call void @llvm.riscv.xsai.zames.msb.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %b, ptr %pb, i64 %s)
; CHECK: call void @llvm.riscv.xsai.zames.msbt.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %bt, ptr %pb, i64 %s)
; CHECK: call void @llvm.riscv.xsai.zames.msb.whole.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %bw, ptr %pb)
; CHECK: call void @llvm.riscv.xsai.zames.msc.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %c, ptr %pc, i64 %s)
; CHECK: call void @llvm.riscv.xsai.zames.msct.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %ct, ptr %pc, i64 %s)
; CHECK: call void @llvm.riscv.xsai.zames.msc.whole.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %cw, ptr %pc)
define void @load_store_bc(ptr %pb, ptr %pc, i64 %s) {
  %b = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlb.triscv.xsai.ame.tile.int32t(ptr %pb, i64 %s)
  %bt = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlbt.triscv.xsai.ame.tile.int32t(ptr %pb, i64 %s)
  %bw = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlb.whole.triscv.xsai.ame.tile.int32t(ptr %pb)
  %c = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlc.triscv.xsai.ame.tile.int32t(ptr %pc, i64 %s)
  %ct = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlct.triscv.xsai.ame.tile.int32t(ptr %pc, i64 %s)
  %cw = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlc.whole.triscv.xsai.ame.tile.int32t(ptr %pc)
  call void @llvm.riscv.xsai.zames.msb.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %b, ptr %pb, i64 %s)
  call void @llvm.riscv.xsai.zames.msbt.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %bt, ptr %pb, i64 %s)
  call void @llvm.riscv.xsai.zames.msb.whole.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %bw, ptr %pb)
  call void @llvm.riscv.xsai.zames.msc.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %c, ptr %pc, i64 %s)
  call void @llvm.riscv.xsai.zames.msct.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %ct, ptr %pc, i64 %s)
  call void @llvm.riscv.xsai.zames.msc.whole.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %cw, ptr %pc)
  ret void
}

; --- mzero / mmacc ------------------------------------------------------

; CHECK-LABEL: define target("riscv.xsai.ame.tile.int32") @zero_acc() {
; CHECK: %z = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mzero.triscv.xsai.ame.tile.int32t()
; CHECK: ret target("riscv.xsai.ame.tile.int32") %z
define target("riscv.xsai.ame.tile.int32") @zero_acc() {
  %z = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mzero.triscv.xsai.ame.tile.int32t()
  ret target("riscv.xsai.ame.tile.int32") %z
}

; CHECK-LABEL: define target("riscv.xsai.ame.tile.int32") @matmul(
; CHECK: %r = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mmacc.triscv.xsai.ame.tile.int32t.triscv.xsai.ame.tile.int8t.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8") %a, target("riscv.xsai.ame.tile.int8") %b, target("riscv.xsai.ame.tile.int32") %c)
define target("riscv.xsai.ame.tile.int32") @matmul(target("riscv.xsai.ame.tile.int8") %a, target("riscv.xsai.ame.tile.int8") %b, target("riscv.xsai.ame.tile.int32") %c) {
  %r = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mmacc.triscv.xsai.ame.tile.int32t.triscv.xsai.ame.tile.int8t.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8") %a, target("riscv.xsai.ame.tile.int8") %b, target("riscv.xsai.ame.tile.int32") %c)
  ret target("riscv.xsai.ame.tile.int32") %r
}

; --- Every floating tile type parses and prints -------------------------

; CHECK-LABEL: define void @fp_types(
; CHECK: call target("riscv.xsai.ame.tile.fp8e4") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.fp8e4t(ptr %p, i64 %s)
; CHECK: call target("riscv.xsai.ame.tile.fp8e5") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.fp8e5t(ptr %p, i64 %s)
; CHECK: call target("riscv.xsai.ame.tile.fp16") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.fp16t(ptr %p, i64 %s)
; CHECK: call target("riscv.xsai.ame.tile.bf16") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.bf16t(ptr %p, i64 %s)
; CHECK: call target("riscv.xsai.ame.tile.fp32") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.fp32t(ptr %p, i64 %s)
define void @fp_types(ptr %p, i64 %s) {
  %e4 = call target("riscv.xsai.ame.tile.fp8e4") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.fp8e4t(ptr %p, i64 %s)
  %e5 = call target("riscv.xsai.ame.tile.fp8e5") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.fp8e5t(ptr %p, i64 %s)
  %f16 = call target("riscv.xsai.ame.tile.fp16") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.fp16t(ptr %p, i64 %s)
  %bf16 = call target("riscv.xsai.ame.tile.bf16") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.bf16t(ptr %p, i64 %s)
  %f32 = call target("riscv.xsai.ame.tile.fp32") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.fp32t(ptr %p, i64 %s)
  ret void
}

; --- ZMASYNC ------------------------------------------------------------

; CHECK-LABEL: define void @sync_ops(
; CHECK: %s0 = call target("riscv.xsai.ame.sync") @llvm.riscv.xsai.zmasync.msyncregreset.triscv.xsai.ame.synct()
; CHECK: %s1 = call target("riscv.xsai.ame.sync") @llvm.riscv.xsai.zmasync.mrelease.triscv.xsai.ame.synct(target("riscv.xsai.ame.sync") %s0)
; CHECK: call void @llvm.riscv.xsai.zmasync.macquire.triscv.xsai.ame.synct(target("riscv.xsai.ame.sync") %s1, i64 %sem)
; CHECK: call void @llvm.riscv.xsai.zmasync.mfence()
define void @sync_ops(i64 %sem) {
  %s0 = call target("riscv.xsai.ame.sync") @llvm.riscv.xsai.zmasync.msyncregreset.triscv.xsai.ame.synct()
  %s1 = call target("riscv.xsai.ame.sync") @llvm.riscv.xsai.zmasync.mrelease.triscv.xsai.ame.synct(target("riscv.xsai.ame.sync") %s0)
  call void @llvm.riscv.xsai.zmasync.macquire.triscv.xsai.ame.synct(target("riscv.xsai.ame.sync") %s1, i64 %sem)
  call void @llvm.riscv.xsai.zmasync.mfence()
  ret void
}
