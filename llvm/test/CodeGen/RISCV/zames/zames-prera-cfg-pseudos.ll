; RUN: llc -mtriple=riscv64 -mattr=+zames -stop-after=riscv-expand-pseudo-pre-ra -o - %s | FileCheck %s

define void @zames_prera_materializes_cfg(ptr %a, ptr %b, ptr %c,
                                          i64 %stride_a, i64 %stride_b,
                                          i64 %stride_c) {
; CHECK-LABEL: name: zames_prera_materializes_cfg
; CHECK:       %[[CFG_A:[0-9]+]]:gpr = ADDI $x0, 2
; CHECK-NEXT:  %[[TILE_A:[0-9]+]]:zamestilereg = PSEUDO_ZAMES_MLA_A_I8 %{{[0-9]+}}, %{{[0-9]+}}, %[[CFG_A]]
; CHECK:       %[[CFG_B:[0-9]+]]:gpr = ADDI $x0, 2
; CHECK-NEXT:  %[[TILE_B:[0-9]+]]:zamestilereg = PSEUDO_ZAMES_MLBT_B_I8 %{{[0-9]+}}, %{{[0-9]+}}, %[[CFG_B]]
; CHECK:       %[[CFG_ZERO:[0-9]+]]:gpr = ADDI $x0, 4
; CHECK-NEXT:  %[[ZERO:[0-9]+]]:zamesaccreg = PSEUDO_ZAMES_MZERO_C_I32 %[[CFG_ZERO]]
; CHECK:       %[[CFG_ACC:[0-9]+]]:gpr = ADDI $x0, 4
; CHECK-NEXT:  %[[CFG_MAT:[0-9]+]]:gpr = ADDI $x0, 2
; CHECK-NEXT:  %[[ACC:[0-9]+]]:zamesaccreg = PSEUDO_ZAMES_MMACC_I8_I32 %[[ZERO]], %[[TILE_B]], %[[TILE_A]], %[[CFG_ACC]], %[[CFG_MAT]], %[[CFG_MAT]]
; CHECK:       %[[CFG_STORE:[0-9]+]]:gpr = ADDI $x0, 4
; CHECK-NEXT:  PSEUDO_ZAMES_MSC_C_I32 %[[ACC]], %{{[0-9]+}}, %{{[0-9]+}}, %[[CFG_STORE]]
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

define void @zames_prera_materializes_mlb_cfg(ptr %a, ptr %b, ptr %c,
                                               i64 %stride_a,
                                               i64 %stride_b,
                                               i64 %stride_c) {
; CHECK-LABEL: name: zames_prera_materializes_mlb_cfg
; CHECK:       %[[MLB_CFG_A:[0-9]+]]:gpr = ADDI $x0, 2
; CHECK-NEXT:  %[[MLB_TILE_A:[0-9]+]]:zamestilereg = PSEUDO_ZAMES_MLA_A_I8 %{{[0-9]+}}, %{{[0-9]+}}, %[[MLB_CFG_A]]
; CHECK:       %[[MLB_CFG_B:[0-9]+]]:gpr = ADDI $x0, 2
; CHECK-NEXT:  %[[MLB_TILE_B:[0-9]+]]:zamestilereg = PSEUDO_ZAMES_MLB_B_I8 %{{[0-9]+}}, %{{[0-9]+}}, %[[MLB_CFG_B]]
; CHECK:       %[[MLB_CFG_ZERO:[0-9]+]]:gpr = ADDI $x0, 4
; CHECK-NEXT:  %[[MLB_ZERO:[0-9]+]]:zamesaccreg = PSEUDO_ZAMES_MZERO_C_I32 %[[MLB_CFG_ZERO]]
; CHECK:       %[[MLB_CFG_ACC:[0-9]+]]:gpr = ADDI $x0, 4
; CHECK-NEXT:  %[[MLB_CFG_MAT:[0-9]+]]:gpr = ADDI $x0, 2
; CHECK-NEXT:  %[[MLB_ACC:[0-9]+]]:zamesaccreg = PSEUDO_ZAMES_MMACC_I8_I32 %[[MLB_ZERO]], %[[MLB_TILE_B]], %[[MLB_TILE_A]], %[[MLB_CFG_ACC]], %[[MLB_CFG_MAT]], %[[MLB_CFG_MAT]]
; CHECK:       %[[MLB_CFG_STORE:[0-9]+]]:gpr = ADDI $x0, 4
; CHECK-NEXT:  PSEUDO_ZAMES_MSC_C_I32 %[[MLB_ACC]], %{{[0-9]+}}, %{{[0-9]+}}, %[[MLB_CFG_STORE]]
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

define void @zames_prera_materializes_mlc_cfg(ptr %c, i64 %stride_c) {
; CHECK-LABEL: name: zames_prera_materializes_mlc_cfg
; CHECK:       %[[MLC_CFG:[0-9]+]]:gpr = ADDI $x0, 4
; CHECK-NEXT:  %[[MLC_ACC:[0-9]+]]:zamesaccreg = PSEUDO_ZAMES_MLC_C_I32 %{{[0-9]+}}, %{{[0-9]+}}, %[[MLC_CFG]]
  %acc = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.triscv.ame.tile.int32t(ptr %c, i64 %stride_c)
  ret void
}

define void @zames_prera_transpose_store_cfg(ptr %a, ptr %c,
                                             i64 %sa, i64 %sc) {
; CHECK-LABEL: name: zames_prera_transpose_store_cfg
; CHECK:       %[[T_CFG_A:[0-9]+]]:gpr = ADDI $x0, 2
; CHECK-NEXT:  %[[T_TILE_A:[0-9]+]]:zamestilereg = PSEUDO_ZAMES_MLAT_A_I8 %{{[0-9]+}}, %{{[0-9]+}}, %[[T_CFG_A]]
; CHECK:       %[[T_CFG_C:[0-9]+]]:gpr = ADDI $x0, 4
; CHECK-NEXT:  %[[T_ACC_C:[0-9]+]]:zamesaccreg = PSEUDO_ZAMES_MLCT_C_I32 %{{[0-9]+}}, %{{[0-9]+}}, %[[T_CFG_C]]
; CHECK:       %[[T_CFG_SA:[0-9]+]]:gpr = ADDI $x0, 2
; CHECK-NEXT:  PSEUDO_ZAMES_MSAT_A_I8 %[[T_TILE_A]], %{{[0-9]+}}, %{{[0-9]+}}, %[[T_CFG_SA]]
; CHECK:       %[[T_CFG_SC:[0-9]+]]:gpr = ADDI $x0, 4
; CHECK-NEXT:  PSEUDO_ZAMES_MSCT_C_I32 %[[T_ACC_C]], %{{[0-9]+}}, %{{[0-9]+}}, %[[T_CFG_SC]]
  %ta = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlat.triscv.ame.tile.int8t(ptr %a, i64 %sa)
  %tc = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mlct.triscv.ame.tile.int32t(ptr %c, i64 %sc)
  call void @llvm.riscv.zames.msat.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %ta, ptr %a, i64 %sa)
  call void @llvm.riscv.zames.msct.triscv.ame.tile.int32t(target("riscv.ame.tile.int32") %tc, ptr %c, i64 %sc)
  ret void
}

define void @zames_prera_ab_store_cfg(ptr %a, ptr %b, i64 %s) {
; CHECK-LABEL: name: zames_prera_ab_store_cfg
; CHECK:       %[[AB_CFG_A:[0-9]+]]:gpr = ADDI $x0, 2
; CHECK-NEXT:  %[[AB_TILE_A:[0-9]+]]:zamestilereg = PSEUDO_ZAMES_MLA_A_I8 %{{[0-9]+}}, %{{[0-9]+}}, %[[AB_CFG_A]]
; CHECK:       %[[AB_CFG_B:[0-9]+]]:gpr = ADDI $x0, 2
; CHECK-NEXT:  %[[AB_TILE_B:[0-9]+]]:zamestilereg = PSEUDO_ZAMES_MLB_B_I8 %{{[0-9]+}}, %{{[0-9]+}}, %[[AB_CFG_B]]
; CHECK:       %[[AB_CFG_SA:[0-9]+]]:gpr = ADDI $x0, 2
; CHECK-NEXT:  PSEUDO_ZAMES_MSA_A_I8 %[[AB_TILE_A]], %{{[0-9]+}}, %{{[0-9]+}}, %[[AB_CFG_SA]]
; CHECK:       %[[AB_CFG_SB:[0-9]+]]:gpr = ADDI $x0, 2
; CHECK-NEXT:  PSEUDO_ZAMES_MSB_B_I8 %[[AB_TILE_B]], %{{[0-9]+}}, %{{[0-9]+}}, %[[AB_CFG_SB]]
; CHECK:       %[[AB_CFG_ST:[0-9]+]]:gpr = ADDI $x0, 2
; CHECK-NEXT:  PSEUDO_ZAMES_MSBT_B_I8 %[[AB_TILE_B]], %{{[0-9]+}}, %{{[0-9]+}}, %[[AB_CFG_ST]]
  %ta = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.triscv.ame.tile.int8t(ptr %a, i64 %s)
  %tb = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlb.triscv.ame.tile.int8t(ptr %b, i64 %s)
  call void @llvm.riscv.zames.msa.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %ta, ptr %a, i64 %s)
  call void @llvm.riscv.zames.msb.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %tb, ptr %b, i64 %s)
  call void @llvm.riscv.zames.msbt.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %tb, ptr %b, i64 %s)
  ret void
}

define void @zames_prera_whole_no_cfg(ptr %src, ptr %dst) {
; CHECK-LABEL: name: zames_prera_whole_no_cfg
; CHECK-NOT:   ADDI
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
