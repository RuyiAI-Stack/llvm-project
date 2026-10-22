; RUN: llc -mtriple=riscv64 -mattr=+zames \
; RUN:   -stop-after=finalize-isel -o - %s \
; RUN:   | FileCheck %s --check-prefix=ISEL
; RUN: llc -mtriple=riscv64 -mattr=+zames \
; RUN:   -stop-after=riscv-expand-pseudo-pre-ra -o - %s \
; RUN:   | FileCheck %s --check-prefix=PRERA
; RUN: llc -mtriple=riscv64 -mattr=+zames \
; RUN:   -stop-after=riscv-expand-pseudo-pre-emit -o - %s \
; RUN:   | FileCheck %s --check-prefix=POSTRA

; Every ZAMES load/store MachineInstr must carry a MachineMemOperand through
; all three expansion stages. Normal/transpose accesses use the conservative
; address-space fallback (no %ir value), whole accesses keep the exact base
; pointer. Load results feed matching stores so nothing is deleted as unused.

define void @zames_mem_ab_i8(ptr %src, ptr %dst, i64 %s) {
; ISEL-LABEL: name: zames_mem_ab_i8
; ISEL: PSEUDO_ZAMES_MLA_A_I8_PRE {{.*}}:: (load unknown-size
; ISEL: PSEUDO_ZAMES_MLAT_A_I8_PRE {{.*}}:: (load unknown-size
; ISEL: PSEUDO_ZAMES_MLB_B_I8_PRE {{.*}}:: (load unknown-size
; ISEL: PSEUDO_ZAMES_MLBT_B_I8_PRE {{.*}}:: (load unknown-size
; ISEL: PSEUDO_ZAMES_MSA_A_I8_PRE {{.*}}:: (store unknown-size
; ISEL: PSEUDO_ZAMES_MSAT_A_I8_PRE {{.*}}:: (store unknown-size
; ISEL: PSEUDO_ZAMES_MSB_B_I8_PRE {{.*}}:: (store unknown-size
; ISEL: PSEUDO_ZAMES_MSBT_B_I8_PRE {{.*}}:: (store unknown-size
; PRERA-LABEL: name: zames_mem_ab_i8
; PRERA: PSEUDO_ZAMES_MLA_A_I8 {{.*}}:: (load unknown-size
; PRERA: PSEUDO_ZAMES_MLAT_A_I8 {{.*}}:: (load unknown-size
; PRERA: PSEUDO_ZAMES_MLB_B_I8 {{.*}}:: (load unknown-size
; PRERA: PSEUDO_ZAMES_MLBT_B_I8 {{.*}}:: (load unknown-size
; PRERA: PSEUDO_ZAMES_MSA_A_I8 {{.*}}:: (store unknown-size
; PRERA: PSEUDO_ZAMES_MSAT_A_I8 {{.*}}:: (store unknown-size
; PRERA: PSEUDO_ZAMES_MSB_B_I8 {{.*}}:: (store unknown-size
; PRERA: PSEUDO_ZAMES_MSBT_B_I8 {{.*}}:: (store unknown-size
; POSTRA-LABEL: name: zames_mem_ab_i8
; POSTRA: ZAMES_MSETCFG {{[^:]*$}}
; POSTRA: ZAMES_MLA {{.*}}:: (load unknown-size
; POSTRA: ZAMES_MLAT {{.*}}:: (load unknown-size
; POSTRA: ZAMES_MLB {{.*}}:: (load unknown-size
; POSTRA: ZAMES_MLBT {{.*}}:: (load unknown-size
; POSTRA: ZAMES_MSA {{.*}}:: (store unknown-size
; POSTRA: ZAMES_MSAT {{.*}}:: (store unknown-size
; POSTRA: ZAMES_MSB {{.*}}:: (store unknown-size
; POSTRA: ZAMES_MSBT {{.*}}:: (store unknown-size
  %ta = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.triscv.ame.tile.int8t(ptr %src, i64 %s)
  %tat = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlat.triscv.ame.tile.int8t(ptr %src, i64 %s)
  %tb = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlb.triscv.ame.tile.int8t(ptr %src, i64 %s)
  %tbt = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlbt.triscv.ame.tile.int8t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msa.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %ta, ptr %dst, i64 %s)
  call void @llvm.riscv.zames.msat.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %tat, ptr %dst, i64 %s)
  call void @llvm.riscv.zames.msb.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %tb, ptr %dst, i64 %s)
  call void @llvm.riscv.zames.msbt.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %tbt, ptr %dst, i64 %s)
  ret void
}

define void @zames_mem_c_i32(ptr %src, ptr %dst, i64 %s) {
; ISEL-LABEL: name: zames_mem_c_i32
; ISEL: PSEUDO_ZAMES_MLC_C_I32_PRE {{.*}}:: (load unknown-size
; ISEL: PSEUDO_ZAMES_MLCT_C_I32_PRE {{.*}}:: (load unknown-size
; ISEL: PSEUDO_ZAMES_MSC_C_I32_PRE {{.*}}:: (store unknown-size
; ISEL: PSEUDO_ZAMES_MSCT_C_I32_PRE {{.*}}:: (store unknown-size
; PRERA-LABEL: name: zames_mem_c_i32
; PRERA: PSEUDO_ZAMES_MLC_C_I32 {{.*}}:: (load unknown-size
; PRERA: PSEUDO_ZAMES_MLCT_C_I32 {{.*}}:: (load unknown-size
; PRERA: PSEUDO_ZAMES_MSC_C_I32 {{.*}}:: (store unknown-size
; PRERA: PSEUDO_ZAMES_MSCT_C_I32 {{.*}}:: (store unknown-size
; POSTRA-LABEL: name: zames_mem_c_i32
; POSTRA: ZAMES_MLC {{.*}}:: (load unknown-size
; POSTRA: ZAMES_MLCT {{.*}}:: (load unknown-size
; POSTRA: ZAMES_MSC {{.*}}:: (store unknown-size
; POSTRA: ZAMES_MSCT {{.*}}:: (store unknown-size
  %tc = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.triscv.ame.tile.int32t(ptr %src, i64 %s)
  %tct = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mlct.triscv.ame.tile.int32t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msc.triscv.ame.tile.int32t(target("riscv.ame.tile.int32") %tc, ptr %dst, i64 %s)
  call void @llvm.riscv.zames.msct.triscv.ame.tile.int32t(target("riscv.ame.tile.int32") %tct, ptr %dst, i64 %s)
  ret void
}

define void @zames_mem_whole(ptr %src, ptr %dst) {
; ISEL-LABEL: name: zames_mem_whole
; ISEL: ZAMES_MLA_WHOLE {{.*}}:: (load unknown-size from %ir.src
; ISEL: ZAMES_MLB_WHOLE {{.*}}:: (load unknown-size from %ir.src
; ISEL: ZAMES_MLC_WHOLE {{.*}}:: (load unknown-size from %ir.src
; ISEL: ZAMES_MSA_WHOLE {{.*}}:: (store unknown-size into %ir.dst
; ISEL: ZAMES_MSB_WHOLE {{.*}}:: (store unknown-size into %ir.dst
; ISEL: ZAMES_MSC_WHOLE {{.*}}:: (store unknown-size into %ir.dst
; PRERA-LABEL: name: zames_mem_whole
; PRERA: ZAMES_MLA_WHOLE {{.*}}:: (load unknown-size from %ir.src
; PRERA: ZAMES_MLB_WHOLE {{.*}}:: (load unknown-size from %ir.src
; PRERA: ZAMES_MLC_WHOLE {{.*}}:: (load unknown-size from %ir.src
; PRERA: ZAMES_MSA_WHOLE {{.*}}:: (store unknown-size into %ir.dst
; PRERA: ZAMES_MSB_WHOLE {{.*}}:: (store unknown-size into %ir.dst
; PRERA: ZAMES_MSC_WHOLE {{.*}}:: (store unknown-size into %ir.dst
; POSTRA-LABEL: name: zames_mem_whole
; POSTRA: ZAMES_MLA_WHOLE {{.*}}:: (load unknown-size from %ir.src
; POSTRA: ZAMES_MLB_WHOLE {{.*}}:: (load unknown-size from %ir.src
; POSTRA: ZAMES_MLC_WHOLE {{.*}}:: (load unknown-size from %ir.src
; POSTRA: ZAMES_MSA_WHOLE {{.*}}:: (store unknown-size into %ir.dst
; POSTRA: ZAMES_MSB_WHOLE {{.*}}:: (store unknown-size into %ir.dst
; POSTRA: ZAMES_MSC_WHOLE {{.*}}:: (store unknown-size into %ir.dst
  %a = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.whole.triscv.ame.tile.int8t(ptr %src)
  %b = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.int8t(ptr %src)
  %c = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.int32t(ptr %src)
  call void @llvm.riscv.zames.msa.whole.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %a, ptr %dst)
  call void @llvm.riscv.zames.msb.whole.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %b, ptr %dst)
  call void @llvm.riscv.zames.msc.whole.triscv.ame.tile.int32t(target("riscv.ame.tile.int32") %c, ptr %dst)
  ret void
}

declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.triscv.ame.tile.int8t(ptr, i64)
declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mlat.triscv.ame.tile.int8t(ptr, i64)
declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mlb.triscv.ame.tile.int8t(ptr, i64)
declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mlbt.triscv.ame.tile.int8t(ptr, i64)
declare target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.triscv.ame.tile.int32t(ptr, i64)
declare target("riscv.ame.tile.int32") @llvm.riscv.zames.mlct.triscv.ame.tile.int32t(ptr, i64)
declare void @llvm.riscv.zames.msa.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), ptr, i64)
declare void @llvm.riscv.zames.msat.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), ptr, i64)
declare void @llvm.riscv.zames.msb.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), ptr, i64)
declare void @llvm.riscv.zames.msbt.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), ptr, i64)
declare void @llvm.riscv.zames.msc.triscv.ame.tile.int32t(target("riscv.ame.tile.int32"), ptr, i64)
declare void @llvm.riscv.zames.msct.triscv.ame.tile.int32t(target("riscv.ame.tile.int32"), ptr, i64)
declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.whole.triscv.ame.tile.int8t(ptr)
declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.int8t(ptr)
declare target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.int32t(ptr)
declare void @llvm.riscv.zames.msa.whole.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), ptr)
declare void @llvm.riscv.zames.msb.whole.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), ptr)
declare void @llvm.riscv.zames.msc.whole.triscv.ame.tile.int32t(target("riscv.ame.tile.int32"), ptr)
