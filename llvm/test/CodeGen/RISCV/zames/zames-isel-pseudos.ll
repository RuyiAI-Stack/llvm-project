; RUN: llc -mtriple=riscv64 -mattr=+zames -stop-after=finalize-isel -o - %s | FileCheck %s

; The matrix data intrinsics must select to typed pre-RA pseudos first. cfg GPR
; payloads are materialized by riscv-expand-pseudo-pre-ra before RA.

define void @zames_selects_typed_pseudos(ptr %a, ptr %b, ptr %c, i64 %stride_a, i64 %stride_b, i64 %stride_c) {
; CHECK-LABEL: name: zames_selects_typed_pseudos
; CHECK:       PSEUDO_XSAI_ZAMES_MLA_A_I8_PRE
; CHECK:       PSEUDO_XSAI_ZAMES_MLBT_B_I8_PRE
; CHECK:       PSEUDO_XSAI_ZAMES_MZERO_C_I32_PRE
; CHECK:       PSEUDO_XSAI_ZAMES_MMACC_I8_I32_PRE
; CHECK:       PSEUDO_XSAI_ZAMES_MSC_C_I32_PRE
  %tile_a = call target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.int8t(ptr %a, i64 %stride_a)
  %tile_b = call target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mlbt.triscv.xsai.ame.tile.int8t(ptr %b, i64 %stride_b)
  %zero = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mzero.triscv.xsai.ame.tile.int32t()
  %acc = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mmacc.triscv.xsai.ame.tile.int32t.triscv.xsai.ame.tile.int8t.triscv.xsai.ame.tile.int8t(
      target("riscv.xsai.ame.tile.int8") %tile_a,
      target("riscv.xsai.ame.tile.int8") %tile_b,
      target("riscv.xsai.ame.tile.int32") %zero)
  call void @llvm.riscv.xsai.zames.msc.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %acc, ptr %c, i64 %stride_c)
  ret void
}

define void @zames_selects_mlb_pseudo(ptr %a, ptr %b, ptr %c,
                                      i64 %stride_a, i64 %stride_b,
                                      i64 %stride_c) {
; CHECK-LABEL: name: zames_selects_mlb_pseudo
; CHECK:       PSEUDO_XSAI_ZAMES_MLA_A_I8_PRE
; CHECK:       PSEUDO_XSAI_ZAMES_MLB_B_I8_PRE
; CHECK:       PSEUDO_XSAI_ZAMES_MZERO_C_I32_PRE
; CHECK:       PSEUDO_XSAI_ZAMES_MMACC_I8_I32_PRE
; CHECK:       PSEUDO_XSAI_ZAMES_MSC_C_I32_PRE
  %tile_a = call target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.int8t(ptr %a, i64 %stride_a)
  %tile_b = call target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mlb.triscv.xsai.ame.tile.int8t(ptr %b, i64 %stride_b)
  %zero = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mzero.triscv.xsai.ame.tile.int32t()
  %acc = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mmacc.triscv.xsai.ame.tile.int32t.triscv.xsai.ame.tile.int8t.triscv.xsai.ame.tile.int8t(
      target("riscv.xsai.ame.tile.int8") %tile_a,
      target("riscv.xsai.ame.tile.int8") %tile_b,
      target("riscv.xsai.ame.tile.int32") %zero)
  call void @llvm.riscv.xsai.zames.msc.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %acc, ptr %c, i64 %stride_c)
  ret void
}

define void @zames_selects_mlc_pseudo(ptr %c, i64 %stride_c) {
; CHECK-LABEL: name: zames_selects_mlc_pseudo
; CHECK:       PSEUDO_XSAI_ZAMES_MLC_C_I32_PRE
  %acc = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlc.triscv.xsai.ame.tile.int32t(ptr %c, i64 %stride_c)
  ret void
}

define void @zames_selects_transpose_and_store_pseudos(ptr %a, ptr %c,
                                                       i64 %sa, i64 %sc) {
; CHECK-LABEL: name: zames_selects_transpose_and_store_pseudos
; CHECK:       PSEUDO_XSAI_ZAMES_MLAT_A_I8_PRE
; CHECK:       PSEUDO_XSAI_ZAMES_MLCT_C_I32_PRE
; CHECK:       PSEUDO_XSAI_ZAMES_MSAT_A_I8_PRE
; CHECK:       PSEUDO_XSAI_ZAMES_MSCT_C_I32_PRE
  %ta = call target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mlat.triscv.xsai.ame.tile.int8t(ptr %a, i64 %sa)
  %tc = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlct.triscv.xsai.ame.tile.int32t(ptr %c, i64 %sc)
  call void @llvm.riscv.xsai.zames.msat.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8") %ta, ptr %a, i64 %sa)
  call void @llvm.riscv.xsai.zames.msct.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %tc, ptr %c, i64 %sc)
  ret void
}

define void @zames_selects_ab_store_pseudos(ptr %a, ptr %b, i64 %s) {
; CHECK-LABEL: name: zames_selects_ab_store_pseudos
; CHECK:       PSEUDO_XSAI_ZAMES_MSA_A_I8_PRE
; CHECK:       PSEUDO_XSAI_ZAMES_MSB_B_I8_PRE
; CHECK:       PSEUDO_XSAI_ZAMES_MSBT_B_I8_PRE
  %ta = call target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.int8t(ptr %a, i64 %s)
  %tb = call target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mlb.triscv.xsai.ame.tile.int8t(ptr %b, i64 %s)
  call void @llvm.riscv.xsai.zames.msa.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8") %ta, ptr %a, i64 %s)
  call void @llvm.riscv.xsai.zames.msb.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8") %tb, ptr %b, i64 %s)
  call void @llvm.riscv.xsai.zames.msbt.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8") %tb, ptr %b, i64 %s)
  ret void
}

define void @zames_selects_whole_direct(ptr %src, ptr %dst) {
; CHECK-LABEL: name: zames_selects_whole_direct
; CHECK-NOT:   PSEUDO
; CHECK:       XSAI_ZAMES_MLA_WHOLE
; CHECK:       XSAI_ZAMES_MLB_WHOLE
; CHECK:       XSAI_ZAMES_MLC_WHOLE
; CHECK:       XSAI_ZAMES_MSA_WHOLE
; CHECK:       XSAI_ZAMES_MSB_WHOLE
; CHECK:       XSAI_ZAMES_MSC_WHOLE
  %a = call target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mla.whole.triscv.xsai.ame.tile.int8t(ptr %src)
  %b = call target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mlb.whole.triscv.xsai.ame.tile.int8t(ptr %src)
  %c = call target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlc.whole.triscv.xsai.ame.tile.int32t(ptr %src)
  call void @llvm.riscv.xsai.zames.msa.whole.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8") %a, ptr %dst)
  call void @llvm.riscv.xsai.zames.msb.whole.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8") %b, ptr %dst)
  call void @llvm.riscv.xsai.zames.msc.whole.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32") %c, ptr %dst)
  ret void
}

declare target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mla.triscv.xsai.ame.tile.int8t(ptr, i64)
declare target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mlb.triscv.xsai.ame.tile.int8t(ptr, i64)
declare target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mlbt.triscv.xsai.ame.tile.int8t(ptr, i64)
declare target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlc.triscv.xsai.ame.tile.int32t(ptr, i64)
declare target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mzero.triscv.xsai.ame.tile.int32t()
declare target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mmacc.triscv.xsai.ame.tile.int32t.triscv.xsai.ame.tile.int8t.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8"), target("riscv.xsai.ame.tile.int8"), target("riscv.xsai.ame.tile.int32"))
declare void @llvm.riscv.xsai.zames.msc.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32"), ptr, i64)
declare target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mlat.triscv.xsai.ame.tile.int8t(ptr, i64)
declare target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlct.triscv.xsai.ame.tile.int32t(ptr, i64)
declare void @llvm.riscv.xsai.zames.msa.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8"), ptr, i64)
declare void @llvm.riscv.xsai.zames.msb.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8"), ptr, i64)
declare void @llvm.riscv.xsai.zames.msat.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8"), ptr, i64)
declare void @llvm.riscv.xsai.zames.msbt.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8"), ptr, i64)
declare void @llvm.riscv.xsai.zames.msct.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32"), ptr, i64)
declare target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mla.whole.triscv.xsai.ame.tile.int8t(ptr)
declare target("riscv.xsai.ame.tile.int8") @llvm.riscv.xsai.zames.mlb.whole.triscv.xsai.ame.tile.int8t(ptr)
declare target("riscv.xsai.ame.tile.int32") @llvm.riscv.xsai.zames.mlc.whole.triscv.xsai.ame.tile.int32t(ptr)
declare void @llvm.riscv.xsai.zames.msa.whole.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8"), ptr)
declare void @llvm.riscv.xsai.zames.msb.whole.triscv.xsai.ame.tile.int8t(target("riscv.xsai.ame.tile.int8"), ptr)
declare void @llvm.riscv.xsai.zames.msc.whole.triscv.xsai.ame.tile.int32t(target("riscv.xsai.ame.tile.int32"), ptr)
