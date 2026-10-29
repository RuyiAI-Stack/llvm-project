; RUN: llc -mtriple=riscv64 -mattr=+zames -stop-after=finalize-isel -o - %s | FileCheck %s

; The matrix data intrinsics must select to typed pre-RA pseudos first. cfg GPR
; payloads are materialized by riscv-expand-pseudo-pre-ra before RA.

define void @zames_selects_typed_pseudos(ptr %a, ptr %b, ptr %c, i64 %stride_a, i64 %stride_b, i64 %stride_c) {
; CHECK-LABEL: name: zames_selects_typed_pseudos
; CHECK:       PSEUDO_ZAMES_MLA_A_I8_PRE
; CHECK:       PSEUDO_ZAMES_MLBT_B_I8_PRE
; CHECK:       PSEUDO_ZAMES_MZERO_C_I32_PRE
; CHECK:       PSEUDO_ZAMES_MMACC_I8_I32_PRE
; CHECK:       PSEUDO_ZAMES_MSC_C_I32_PRE
  %tile_a = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.triscv.ame.tile.int8t(ptr %a, i64 %stride_a)
  %tile_b = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlbt.triscv.ame.tile.int8t(ptr %b, i64 %stride_b)
  %zero = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mzero.triscv.ame.tile.int32t()
  %acc = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mmacc.triscv.ame.tile.int32t.triscv.ame.tile.int8t.triscv.ame.tile.int8t(
      target("riscv.ame.tile.int8") %tile_a,
      target("riscv.ame.tile.int8") %tile_b,
      target("riscv.ame.tile.int32") %zero)
  call void @llvm.riscv.zames.msc.triscv.ame.tile.int32t(target("riscv.ame.tile.int32") %acc, ptr %c, i64 %stride_c)
  ret void
}

define void @zames_selects_mlb_pseudo(ptr %a, ptr %b, ptr %c,
                                      i64 %stride_a, i64 %stride_b,
                                      i64 %stride_c) {
; CHECK-LABEL: name: zames_selects_mlb_pseudo
; CHECK:       PSEUDO_ZAMES_MLA_A_I8_PRE
; CHECK:       PSEUDO_ZAMES_MLB_B_I8_PRE
; CHECK:       PSEUDO_ZAMES_MZERO_C_I32_PRE
; CHECK:       PSEUDO_ZAMES_MMACC_I8_I32_PRE
; CHECK:       PSEUDO_ZAMES_MSC_C_I32_PRE
  %tile_a = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.triscv.ame.tile.int8t(ptr %a, i64 %stride_a)
  %tile_b = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlb.triscv.ame.tile.int8t(ptr %b, i64 %stride_b)
  %zero = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mzero.triscv.ame.tile.int32t()
  %acc = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mmacc.triscv.ame.tile.int32t.triscv.ame.tile.int8t.triscv.ame.tile.int8t(
      target("riscv.ame.tile.int8") %tile_a,
      target("riscv.ame.tile.int8") %tile_b,
      target("riscv.ame.tile.int32") %zero)
  call void @llvm.riscv.zames.msc.triscv.ame.tile.int32t(target("riscv.ame.tile.int32") %acc, ptr %c, i64 %stride_c)
  ret void
}

define void @zames_selects_mlc_pseudo(ptr %c, i64 %stride_c) {
; CHECK-LABEL: name: zames_selects_mlc_pseudo
; CHECK:       PSEUDO_ZAMES_MLC_C_I32_PRE
  %acc = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.triscv.ame.tile.int32t(ptr %c, i64 %stride_c)
  ret void
}

define void @zames_selects_transpose_and_store_pseudos(ptr %a, ptr %c,
                                                       i64 %sa, i64 %sc) {
; CHECK-LABEL: name: zames_selects_transpose_and_store_pseudos
; CHECK:       PSEUDO_ZAMES_MLAT_A_I8_PRE
; CHECK:       PSEUDO_ZAMES_MLCT_C_I32_PRE
; CHECK:       PSEUDO_ZAMES_MSAT_A_I8_PRE
; CHECK:       PSEUDO_ZAMES_MSCT_C_I32_PRE
  %ta = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlat.triscv.ame.tile.int8t(ptr %a, i64 %sa)
  %tc = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mlct.triscv.ame.tile.int32t(ptr %c, i64 %sc)
  call void @llvm.riscv.zames.msat.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %ta, ptr %a, i64 %sa)
  call void @llvm.riscv.zames.msct.triscv.ame.tile.int32t(target("riscv.ame.tile.int32") %tc, ptr %c, i64 %sc)
  ret void
}

define void @zames_selects_ab_store_pseudos(ptr %a, ptr %b, i64 %s) {
; CHECK-LABEL: name: zames_selects_ab_store_pseudos
; CHECK:       PSEUDO_ZAMES_MSA_A_I8_PRE
; CHECK:       PSEUDO_ZAMES_MSB_B_I8_PRE
; CHECK:       PSEUDO_ZAMES_MSBT_B_I8_PRE
  %ta = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.triscv.ame.tile.int8t(ptr %a, i64 %s)
  %tb = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlb.triscv.ame.tile.int8t(ptr %b, i64 %s)
  call void @llvm.riscv.zames.msa.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %ta, ptr %a, i64 %s)
  call void @llvm.riscv.zames.msb.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %tb, ptr %b, i64 %s)
  call void @llvm.riscv.zames.msbt.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %tb, ptr %b, i64 %s)
  ret void
}

define void @zames_selects_whole_direct(ptr %src, ptr %dst) {
; CHECK-LABEL: name: zames_selects_whole_direct
; CHECK-NOT:   PSEUDO
; CHECK:       ZAMES_MLA_WHOLE
; CHECK:       ZAMES_MLB_WHOLE
; CHECK:       ZAMES_MLC_WHOLE
; CHECK:       ZAMES_MSA_WHOLE
; CHECK:       ZAMES_MSB_WHOLE
; CHECK:       ZAMES_MSC_WHOLE
  %a = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.whole.triscv.ame.tile.int8t(ptr %src)
  %b = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.int8t(ptr %src)
  %c = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.int32t(ptr %src)
  call void @llvm.riscv.zames.msa.whole.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %a, ptr %dst)
  call void @llvm.riscv.zames.msb.whole.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %b, ptr %dst)
  call void @llvm.riscv.zames.msc.whole.triscv.ame.tile.int32t(target("riscv.ame.tile.int32") %c, ptr %dst)
  ret void
}

declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.triscv.ame.tile.int8t(ptr, i64)
declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mlb.triscv.ame.tile.int8t(ptr, i64)
declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mlbt.triscv.ame.tile.int8t(ptr, i64)
declare target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.triscv.ame.tile.int32t(ptr, i64)
declare target("riscv.ame.tile.int32") @llvm.riscv.zames.mzero.triscv.ame.tile.int32t()
declare target("riscv.ame.tile.int32") @llvm.riscv.zames.mmacc.triscv.ame.tile.int32t.triscv.ame.tile.int8t.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), target("riscv.ame.tile.int8"), target("riscv.ame.tile.int32"))
declare void @llvm.riscv.zames.msc.triscv.ame.tile.int32t(target("riscv.ame.tile.int32"), ptr, i64)
declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mlat.triscv.ame.tile.int8t(ptr, i64)
declare target("riscv.ame.tile.int32") @llvm.riscv.zames.mlct.triscv.ame.tile.int32t(ptr, i64)
declare void @llvm.riscv.zames.msa.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), ptr, i64)
declare void @llvm.riscv.zames.msb.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), ptr, i64)
declare void @llvm.riscv.zames.msat.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), ptr, i64)
declare void @llvm.riscv.zames.msbt.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), ptr, i64)
declare void @llvm.riscv.zames.msct.triscv.ame.tile.int32t(target("riscv.ame.tile.int32"), ptr, i64)
declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.whole.triscv.ame.tile.int8t(ptr)
declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.int8t(ptr)
declare target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.int32t(ptr)
declare void @llvm.riscv.zames.msa.whole.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), ptr)
declare void @llvm.riscv.zames.msb.whole.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), ptr)
declare void @llvm.riscv.zames.msc.whole.triscv.ame.tile.int32t(target("riscv.ame.tile.int32"), ptr)
