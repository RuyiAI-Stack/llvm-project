; RUN: llc -mtriple=riscv64 -mattr=+zames \
; RUN:   -stop-after=finalize-isel -o - %s \
; RUN:   | FileCheck %s --check-prefix=ISEL
; RUN: llc -mtriple=riscv64 -mattr=+zames \
; RUN:   -stop-after=riscv-expand-pseudo-pre-ra -o - %s \
; RUN:   | FileCheck %s --check-prefix=PRERA
; RUN: llc -mtriple=riscv64 -mattr=+zames \
; RUN:   -stop-after=riscv-expand-pseudo-pre-emit -o - %s \
; RUN:   | FileCheck %s --check-prefix=POSTRA
; RUN: llc -mtriple=riscv64 -mattr=+zames -filetype=obj %s -o %t.o
; RUN: llvm-objdump --mattr=+zames -d %t.o \
; RUN:   | FileCheck %s --check-prefix=OBJ

; FP8E4/FP8E5/FP16/BF16 are input tile types; FP32 is an accumulator type.
; Typed loads, stores, mzero and mmacc expand through the two-level pseudo
; chain with the type payload from the spec (i8=0x02, i32=0x04,
; fp8e5m2=0x07, fp8e4m3=0x08, fp16=0x09, bf16=0x0a, fp32=0x0c). Pre-RA,
; payload materialization immediately precedes its typed pseudo; post-RA,
; msetcfg immediately precedes the real instruction.

define void @zames_fp_ab_ls(ptr %src, ptr %dst, i64 %s) {
; ISEL-LABEL: name: zames_fp_ab_ls
; ISEL: PSEUDO_ZAMES_MLA_A_FP8E4_PRE
; ISEL: PSEUDO_ZAMES_MSA_A_FP8E4_PRE
; ISEL: PSEUDO_ZAMES_MLAT_A_FP8E4_PRE
; ISEL: PSEUDO_ZAMES_MSAT_A_FP8E4_PRE
; ISEL: PSEUDO_ZAMES_MLB_B_FP8E4_PRE
; ISEL: PSEUDO_ZAMES_MSB_B_FP8E4_PRE
; ISEL: PSEUDO_ZAMES_MLBT_B_FP8E4_PRE
; ISEL: PSEUDO_ZAMES_MSBT_B_FP8E4_PRE
; ISEL: PSEUDO_ZAMES_MLA_A_FP8E5_PRE
; ISEL: PSEUDO_ZAMES_MSA_A_FP8E5_PRE
; ISEL: PSEUDO_ZAMES_MLAT_A_FP8E5_PRE
; ISEL: PSEUDO_ZAMES_MSAT_A_FP8E5_PRE
; ISEL: PSEUDO_ZAMES_MLB_B_FP8E5_PRE
; ISEL: PSEUDO_ZAMES_MSB_B_FP8E5_PRE
; ISEL: PSEUDO_ZAMES_MLBT_B_FP8E5_PRE
; ISEL: PSEUDO_ZAMES_MSBT_B_FP8E5_PRE
; PRERA-LABEL: name: zames_fp_ab_ls
; PRERA: %[[C8:[0-9]+]]:gpr = ADDI $x0, 8
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLA_A_FP8E4 {{.*}}, %[[C8]] ::
; PRERA: %[[C8:[0-9]+]]:gpr = ADDI $x0, 8
; PRERA-NEXT: PSEUDO_ZAMES_MSA_A_FP8E4 {{.*}}, %[[C8]] ::
; PRERA: %[[C8:[0-9]+]]:gpr = ADDI $x0, 8
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLAT_A_FP8E4 {{.*}}, %[[C8]] ::
; PRERA: %[[C8:[0-9]+]]:gpr = ADDI $x0, 8
; PRERA-NEXT: PSEUDO_ZAMES_MSAT_A_FP8E4 {{.*}}, %[[C8]] ::
; PRERA: %[[C8:[0-9]+]]:gpr = ADDI $x0, 8
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLB_B_FP8E4 {{.*}}, %[[C8]] ::
; PRERA: %[[C8:[0-9]+]]:gpr = ADDI $x0, 8
; PRERA-NEXT: PSEUDO_ZAMES_MSB_B_FP8E4 {{.*}}, %[[C8]] ::
; PRERA: %[[C8:[0-9]+]]:gpr = ADDI $x0, 8
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLBT_B_FP8E4 {{.*}}, %[[C8]] ::
; PRERA: %[[C8:[0-9]+]]:gpr = ADDI $x0, 8
; PRERA-NEXT: PSEUDO_ZAMES_MSBT_B_FP8E4 {{.*}}, %[[C8]] ::
; PRERA: %[[C7:[0-9]+]]:gpr = ADDI $x0, 7
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLA_A_FP8E5 {{.*}}, %[[C7]] ::
; PRERA: %[[C7:[0-9]+]]:gpr = ADDI $x0, 7
; PRERA-NEXT: PSEUDO_ZAMES_MSA_A_FP8E5 {{.*}}, %[[C7]] ::
; PRERA: %[[C7:[0-9]+]]:gpr = ADDI $x0, 7
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLAT_A_FP8E5 {{.*}}, %[[C7]] ::
; PRERA: %[[C7:[0-9]+]]:gpr = ADDI $x0, 7
; PRERA-NEXT: PSEUDO_ZAMES_MSAT_A_FP8E5 {{.*}}, %[[C7]] ::
; PRERA: %[[C7:[0-9]+]]:gpr = ADDI $x0, 7
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLB_B_FP8E5 {{.*}}, %[[C7]] ::
; PRERA: %[[C7:[0-9]+]]:gpr = ADDI $x0, 7
; PRERA-NEXT: PSEUDO_ZAMES_MSB_B_FP8E5 {{.*}}, %[[C7]] ::
; PRERA: %[[C7:[0-9]+]]:gpr = ADDI $x0, 7
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLBT_B_FP8E5 {{.*}}, %[[C7]] ::
; PRERA: %[[C7:[0-9]+]]:gpr = ADDI $x0, 7
; PRERA-NEXT: PSEUDO_ZAMES_MSBT_B_FP8E5 {{.*}}, %[[C7]] ::
; POSTRA-LABEL: name: zames_fp_ab_ls
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 8
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLA {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 8
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSA {{.*}}:: (store unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 8
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLAT {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 8
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSAT {{.*}}:: (store unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 8
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLB {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 8
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSB {{.*}}:: (store unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 8
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLBT {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 8
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSBT {{.*}}:: (store unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 7
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLA {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 7
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSA {{.*}}:: (store unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 7
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLAT {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 7
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSAT {{.*}}:: (store unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 7
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLB {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 7
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSB {{.*}}:: (store unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 7
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLBT {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 7
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSBT {{.*}}:: (store unknown-size
; OBJ-LABEL: <zames_fp_ab_ls>:
; OBJ: mla{{[ \t]}}
; OBJ: msa{{[ \t]}}
; OBJ: mlat{{[ \t]}}
; OBJ: msat{{[ \t]}}
; OBJ: mlb{{[ \t]}}
; OBJ: msb{{[ \t]}}
; OBJ: mlbt{{[ \t]}}
; OBJ: msbt{{[ \t]}}
; OBJ: mla{{[ \t]}}
; OBJ: msa{{[ \t]}}
; OBJ: mlat{{[ \t]}}
; OBJ: msat{{[ \t]}}
; OBJ: mlb{{[ \t]}}
; OBJ: msb{{[ \t]}}
; OBJ: mlbt{{[ \t]}}
; OBJ: msbt{{[ \t]}}
  %t1 = call target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mla.triscv.ame.tile.fp8e4t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msa.triscv.ame.tile.fp8e4t(target("riscv.ame.tile.fp8e4") %t1, ptr %dst, i64 %s)
  %t2 = call target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mlat.triscv.ame.tile.fp8e4t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msat.triscv.ame.tile.fp8e4t(target("riscv.ame.tile.fp8e4") %t2, ptr %dst, i64 %s)
  %t3 = call target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mlb.triscv.ame.tile.fp8e4t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msb.triscv.ame.tile.fp8e4t(target("riscv.ame.tile.fp8e4") %t3, ptr %dst, i64 %s)
  %t4 = call target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mlbt.triscv.ame.tile.fp8e4t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msbt.triscv.ame.tile.fp8e4t(target("riscv.ame.tile.fp8e4") %t4, ptr %dst, i64 %s)
  %t5 = call target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mla.triscv.ame.tile.fp8e5t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msa.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e5") %t5, ptr %dst, i64 %s)
  %t6 = call target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mlat.triscv.ame.tile.fp8e5t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msat.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e5") %t6, ptr %dst, i64 %s)
  %t7 = call target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mlb.triscv.ame.tile.fp8e5t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msb.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e5") %t7, ptr %dst, i64 %s)
  %t8 = call target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mlbt.triscv.ame.tile.fp8e5t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msbt.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e5") %t8, ptr %dst, i64 %s)
  ret void
}

define void @zames_fp_c_ls(ptr %src, ptr %dst, i64 %s) {
; ISEL-LABEL: name: zames_fp_c_ls
; ISEL: PSEUDO_ZAMES_MLC_C_F32_PRE
; ISEL: PSEUDO_ZAMES_MSC_C_F32_PRE
; ISEL: PSEUDO_ZAMES_MLCT_C_F32_PRE
; ISEL: PSEUDO_ZAMES_MSCT_C_F32_PRE
; PRERA-LABEL: name: zames_fp_c_ls
; PRERA: %[[C12:[0-9]+]]:gpr = ADDI $x0, 12
; PRERA-NEXT: %{{[0-9]+}}:zamesaccreg = PSEUDO_ZAMES_MLC_C_F32 {{.*}}, %[[C12]] ::
; PRERA: %[[C12:[0-9]+]]:gpr = ADDI $x0, 12
; PRERA-NEXT: PSEUDO_ZAMES_MSC_C_F32 {{.*}}, %[[C12]] ::
; PRERA: %[[C12:[0-9]+]]:gpr = ADDI $x0, 12
; PRERA-NEXT: %{{[0-9]+}}:zamesaccreg = PSEUDO_ZAMES_MLCT_C_F32 {{.*}}, %[[C12]] ::
; PRERA: %[[C12:[0-9]+]]:gpr = ADDI $x0, 12
; PRERA-NEXT: PSEUDO_ZAMES_MSCT_C_F32 {{.*}}, %[[C12]] ::
; POSTRA-LABEL: name: zames_fp_c_ls
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 12
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLC {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 12
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSC {{.*}}:: (store unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 12
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLCT {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 12
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSCT {{.*}}:: (store unknown-size
; OBJ-LABEL: <zames_fp_c_ls>:
; OBJ: mlc{{[ \t]}}
; OBJ: msc{{[ \t]}}
; OBJ: mlct{{[ \t]}}
; OBJ: msct{{[ \t]}}
  %c5 = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mlc.triscv.ame.tile.fp32t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msc.triscv.ame.tile.fp32t(target("riscv.ame.tile.fp32") %c5, ptr %dst, i64 %s)
  %c6 = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mlct.triscv.ame.tile.fp32t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msct.triscv.ame.tile.fp32t(target("riscv.ame.tile.fp32") %c6, ptr %dst, i64 %s)
  ret void
}

define void @zames_fp16_bf16_ab_ls(ptr %src, ptr %dst, i64 %s) {
; ISEL-LABEL: name: zames_fp16_bf16_ab_ls
; ISEL: PSEUDO_ZAMES_MLA_A_F16_PRE
; ISEL: PSEUDO_ZAMES_MSA_A_F16_PRE
; ISEL: PSEUDO_ZAMES_MLAT_A_F16_PRE
; ISEL: PSEUDO_ZAMES_MSAT_A_F16_PRE
; ISEL: PSEUDO_ZAMES_MLB_B_F16_PRE
; ISEL: PSEUDO_ZAMES_MSB_B_F16_PRE
; ISEL: PSEUDO_ZAMES_MLBT_B_F16_PRE
; ISEL: PSEUDO_ZAMES_MSBT_B_F16_PRE
; ISEL: PSEUDO_ZAMES_MLA_A_BF16_PRE
; ISEL: PSEUDO_ZAMES_MSA_A_BF16_PRE
; ISEL: PSEUDO_ZAMES_MLAT_A_BF16_PRE
; ISEL: PSEUDO_ZAMES_MSAT_A_BF16_PRE
; ISEL: PSEUDO_ZAMES_MLB_B_BF16_PRE
; ISEL: PSEUDO_ZAMES_MSB_B_BF16_PRE
; ISEL: PSEUDO_ZAMES_MLBT_B_BF16_PRE
; ISEL: PSEUDO_ZAMES_MSBT_B_BF16_PRE
; PRERA-LABEL: name: zames_fp16_bf16_ab_ls
; PRERA: %[[C9:[0-9]+]]:gpr = ADDI $x0, 9
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLA_A_F16 {{.*}}, %[[C9]] ::
; PRERA: %[[C9:[0-9]+]]:gpr = ADDI $x0, 9
; PRERA-NEXT: PSEUDO_ZAMES_MSA_A_F16 {{.*}}, %[[C9]] ::
; PRERA: %[[C9:[0-9]+]]:gpr = ADDI $x0, 9
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLAT_A_F16 {{.*}}, %[[C9]] ::
; PRERA: %[[C9:[0-9]+]]:gpr = ADDI $x0, 9
; PRERA-NEXT: PSEUDO_ZAMES_MSAT_A_F16 {{.*}}, %[[C9]] ::
; PRERA: %[[C9:[0-9]+]]:gpr = ADDI $x0, 9
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLB_B_F16 {{.*}}, %[[C9]] ::
; PRERA: %[[C9:[0-9]+]]:gpr = ADDI $x0, 9
; PRERA-NEXT: PSEUDO_ZAMES_MSB_B_F16 {{.*}}, %[[C9]] ::
; PRERA: %[[C9:[0-9]+]]:gpr = ADDI $x0, 9
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLBT_B_F16 {{.*}}, %[[C9]] ::
; PRERA: %[[C9:[0-9]+]]:gpr = ADDI $x0, 9
; PRERA-NEXT: PSEUDO_ZAMES_MSBT_B_F16 {{.*}}, %[[C9]] ::
; PRERA: %[[C10:[0-9]+]]:gpr = ADDI $x0, 10
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLA_A_BF16 {{.*}}, %[[C10]] ::
; PRERA: %[[C10:[0-9]+]]:gpr = ADDI $x0, 10
; PRERA-NEXT: PSEUDO_ZAMES_MSA_A_BF16 {{.*}}, %[[C10]] ::
; PRERA: %[[C10:[0-9]+]]:gpr = ADDI $x0, 10
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLAT_A_BF16 {{.*}}, %[[C10]] ::
; PRERA: %[[C10:[0-9]+]]:gpr = ADDI $x0, 10
; PRERA-NEXT: PSEUDO_ZAMES_MSAT_A_BF16 {{.*}}, %[[C10]] ::
; PRERA: %[[C10:[0-9]+]]:gpr = ADDI $x0, 10
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLB_B_BF16 {{.*}}, %[[C10]] ::
; PRERA: %[[C10:[0-9]+]]:gpr = ADDI $x0, 10
; PRERA-NEXT: PSEUDO_ZAMES_MSB_B_BF16 {{.*}}, %[[C10]] ::
; PRERA: %[[C10:[0-9]+]]:gpr = ADDI $x0, 10
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MLBT_B_BF16 {{.*}}, %[[C10]] ::
; PRERA: %[[C10:[0-9]+]]:gpr = ADDI $x0, 10
; PRERA-NEXT: PSEUDO_ZAMES_MSBT_B_BF16 {{.*}}, %[[C10]] ::
; POSTRA-LABEL: name: zames_fp16_bf16_ab_ls
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 9
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLA {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 9
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSA {{.*}}:: (store unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 9
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLAT {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 9
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSAT {{.*}}:: (store unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 9
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLB {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 9
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSB {{.*}}:: (store unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 9
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLBT {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 9
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSBT {{.*}}:: (store unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 10
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLA {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 10
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSA {{.*}}:: (store unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 10
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLAT {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 10
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSAT {{.*}}:: (store unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 10
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLB {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 10
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSB {{.*}}:: (store unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 10
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: {{.*}} = ZAMES_MLBT {{.*}}:: (load unknown-size
; POSTRA: [[P:\$x[0-9]+]] = ADDI $x0, 10
; POSTRA: ZAMES_MSETCFG {{[0-9]+}}, {{.*}}[[P]]{{$}}
; POSTRA-NEXT: ZAMES_MSBT {{.*}}:: (store unknown-size
; OBJ-LABEL: <zames_fp16_bf16_ab_ls>:
; OBJ: mla{{[ \t]}}
; OBJ: msa{{[ \t]}}
; OBJ: mlat{{[ \t]}}
; OBJ: msat{{[ \t]}}
; OBJ: mlb{{[ \t]}}
; OBJ: msb{{[ \t]}}
; OBJ: mlbt{{[ \t]}}
; OBJ: msbt{{[ \t]}}
; OBJ: mla{{[ \t]}}
; OBJ: msa{{[ \t]}}
; OBJ: mlat{{[ \t]}}
; OBJ: msat{{[ \t]}}
; OBJ: mlb{{[ \t]}}
; OBJ: msb{{[ \t]}}
; OBJ: mlbt{{[ \t]}}
; OBJ: msbt{{[ \t]}}
  %t1 = call target("riscv.ame.tile.fp16") @llvm.riscv.zames.mla.triscv.ame.tile.fp16t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msa.triscv.ame.tile.fp16t(target("riscv.ame.tile.fp16") %t1, ptr %dst, i64 %s)
  %t2 = call target("riscv.ame.tile.fp16") @llvm.riscv.zames.mlat.triscv.ame.tile.fp16t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msat.triscv.ame.tile.fp16t(target("riscv.ame.tile.fp16") %t2, ptr %dst, i64 %s)
  %t3 = call target("riscv.ame.tile.fp16") @llvm.riscv.zames.mlb.triscv.ame.tile.fp16t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msb.triscv.ame.tile.fp16t(target("riscv.ame.tile.fp16") %t3, ptr %dst, i64 %s)
  %t4 = call target("riscv.ame.tile.fp16") @llvm.riscv.zames.mlbt.triscv.ame.tile.fp16t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msbt.triscv.ame.tile.fp16t(target("riscv.ame.tile.fp16") %t4, ptr %dst, i64 %s)
  %t5 = call target("riscv.ame.tile.bf16") @llvm.riscv.zames.mla.triscv.ame.tile.bf16t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msa.triscv.ame.tile.bf16t(target("riscv.ame.tile.bf16") %t5, ptr %dst, i64 %s)
  %t6 = call target("riscv.ame.tile.bf16") @llvm.riscv.zames.mlat.triscv.ame.tile.bf16t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msat.triscv.ame.tile.bf16t(target("riscv.ame.tile.bf16") %t6, ptr %dst, i64 %s)
  %t7 = call target("riscv.ame.tile.bf16") @llvm.riscv.zames.mlb.triscv.ame.tile.bf16t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msb.triscv.ame.tile.bf16t(target("riscv.ame.tile.bf16") %t7, ptr %dst, i64 %s)
  %t8 = call target("riscv.ame.tile.bf16") @llvm.riscv.zames.mlbt.triscv.ame.tile.bf16t(ptr %src, i64 %s)
  call void @llvm.riscv.zames.msbt.triscv.ame.tile.bf16t(target("riscv.ame.tile.bf16") %t8, ptr %dst, i64 %s)
  ret void
}

; Whole loads and stores select the real instruction directly; the transfer
; does not read the type config, so no msetcfg is emitted for them.
define void @zames_fp_whole(ptr %src, ptr %dst) {
; ISEL-LABEL: name: zames_fp_whole
; ISEL: ZAMES_MLA_WHOLE
; ISEL: ZAMES_MSA_WHOLE
; ISEL: ZAMES_MLB_WHOLE
; ISEL: ZAMES_MSB_WHOLE
; ISEL: ZAMES_MLA_WHOLE
; ISEL: ZAMES_MSA_WHOLE
; ISEL: ZAMES_MLB_WHOLE
; ISEL: ZAMES_MSB_WHOLE
; ISEL: ZAMES_MLC_WHOLE
; ISEL: ZAMES_MSC_WHOLE
; OBJ-LABEL: <zames_fp_whole>:
; OBJ-NOT: msetcfg
; OBJ: mla.whole{{[ \t]}}
; OBJ: msa.whole{{[ \t]}}
; OBJ: mlb.whole{{[ \t]}}
; OBJ: msb.whole{{[ \t]}}
; OBJ: mla.whole{{[ \t]}}
; OBJ: msa.whole{{[ \t]}}
; OBJ: mlb.whole{{[ \t]}}
; OBJ: msb.whole{{[ \t]}}
; OBJ: mlc.whole{{[ \t]}}
; OBJ: msc.whole{{[ \t]}}
  %a = call target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mla.whole.triscv.ame.tile.fp8e4t(ptr %src)
  call void @llvm.riscv.zames.msa.whole.triscv.ame.tile.fp8e4t(target("riscv.ame.tile.fp8e4") %a, ptr %dst)
  %b = call target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.fp8e5t(ptr %src)
  call void @llvm.riscv.zames.msb.whole.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e5") %b, ptr %dst)
  %a16 = call target("riscv.ame.tile.fp16") @llvm.riscv.zames.mla.whole.triscv.ame.tile.fp16t(ptr %src)
  call void @llvm.riscv.zames.msa.whole.triscv.ame.tile.fp16t(target("riscv.ame.tile.fp16") %a16, ptr %dst)
  %bb16 = call target("riscv.ame.tile.bf16") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.bf16t(ptr %src)
  call void @llvm.riscv.zames.msb.whole.triscv.ame.tile.bf16t(target("riscv.ame.tile.bf16") %bb16, ptr %dst)
  %c = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.fp32t(ptr %src)
  call void @llvm.riscv.zames.msc.whole.triscv.ame.tile.fp32t(target("riscv.ame.tile.fp32") %c, ptr %dst)
  ret void
}

; mzero covers all five input tile types and both accumulator types, each
; bound to its payload config and register class.
define void @zames_fp_mzero(ptr %dst) {
; ISEL-LABEL: name: zames_fp_mzero
; ISEL: PSEUDO_ZAMES_MZERO_T_I8_PRE
; ISEL: PSEUDO_ZAMES_MZERO_T_FP8E4_PRE
; ISEL: PSEUDO_ZAMES_MZERO_T_FP8E5_PRE
; ISEL: PSEUDO_ZAMES_MZERO_C_I32_PRE
; ISEL: PSEUDO_ZAMES_MZERO_T_F16_PRE
; ISEL: PSEUDO_ZAMES_MZERO_T_BF16_PRE
; ISEL: PSEUDO_ZAMES_MZERO_C_F32_PRE
; PRERA-LABEL: name: zames_fp_mzero
; PRERA: %[[C2:[0-9]+]]:gpr = ADDI $x0, 2
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MZERO_T_I8 %[[C2]]{{$}}
; PRERA: %[[C8:[0-9]+]]:gpr = ADDI $x0, 8
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MZERO_T_FP8E4 %[[C8]]{{$}}
; PRERA: %[[C7:[0-9]+]]:gpr = ADDI $x0, 7
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MZERO_T_FP8E5 %[[C7]]{{$}}
; PRERA: %[[C4:[0-9]+]]:gpr = ADDI $x0, 4
; PRERA-NEXT: %{{[0-9]+}}:zamesaccreg = PSEUDO_ZAMES_MZERO_C_I32 %[[C4]]{{$}}
; PRERA: %[[C9:[0-9]+]]:gpr = ADDI $x0, 9
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MZERO_T_F16 %[[C9]]{{$}}
; PRERA: %[[C10:[0-9]+]]:gpr = ADDI $x0, 10
; PRERA-NEXT: %{{[0-9]+}}:zamestilereg = PSEUDO_ZAMES_MZERO_T_BF16 %[[C10]]{{$}}
; PRERA: %[[C12:[0-9]+]]:gpr = ADDI $x0, 12
; PRERA-NEXT: %{{[0-9]+}}:zamesaccreg = PSEUDO_ZAMES_MZERO_C_F32 %[[C12]]{{$}}
; POSTRA-LABEL: name: zames_fp_mzero
; POSTRA: ZAMES_MSETCFG [[#T:]], {{.*}}
; POSTRA-NEXT: {{.*}}$zames_tr[[#T]] = ZAMES_MZERO{{$}}
; POSTRA: ZAMES_MSETCFG [[#T:]], {{.*}}
; POSTRA-NEXT: {{.*}}$zames_tr[[#T]] = ZAMES_MZERO{{$}}
; POSTRA: ZAMES_MSETCFG [[#T:]], {{.*}}
; POSTRA-NEXT: {{.*}}$zames_tr[[#T]] = ZAMES_MZERO{{$}}
; POSTRA: ZAMES_MSETCFG [[#C:]], {{.*}}
; POSTRA-NEXT: {{.*}}$zames_acc[[#C-4]] = ZAMES_MZERO{{$}}
; POSTRA: ZAMES_MSETCFG [[#T:]], {{.*}}
; POSTRA-NEXT: {{.*}}$zames_tr[[#T]] = ZAMES_MZERO{{$}}
; POSTRA: ZAMES_MSETCFG [[#T:]], {{.*}}
; POSTRA-NEXT: {{.*}}$zames_tr[[#T]] = ZAMES_MZERO{{$}}
; POSTRA: ZAMES_MSETCFG [[#C:]], {{.*}}
; POSTRA-NEXT: {{.*}}$zames_acc[[#C-4]] = ZAMES_MZERO{{$}}
; OBJ-LABEL: <zames_fp_mzero>:
; OBJ: mzero{{[ \t]}}tr{{[0-3]}}
; OBJ: mzero{{[ \t]}}tr{{[0-3]}}
; OBJ: mzero{{[ \t]}}tr{{[0-3]}}
; OBJ: mzero{{[ \t]}}acc{{[0-3]}}
; OBJ: mzero{{[ \t]}}tr{{[0-3]}}
; OBJ: mzero{{[ \t]}}tr{{[0-3]}}
; OBJ: mzero{{[ \t]}}acc{{[0-3]}}
  %z1 = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mzero.triscv.ame.tile.int8t()
  call void @llvm.riscv.zames.msa.whole.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %z1, ptr %dst)
  %z2 = call target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mzero.triscv.ame.tile.fp8e4t()
  call void @llvm.riscv.zames.msa.whole.triscv.ame.tile.fp8e4t(target("riscv.ame.tile.fp8e4") %z2, ptr %dst)
  %z3 = call target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mzero.triscv.ame.tile.fp8e5t()
  call void @llvm.riscv.zames.msa.whole.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e5") %z3, ptr %dst)
  %z4 = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mzero.triscv.ame.tile.int32t()
  call void @llvm.riscv.zames.msc.whole.triscv.ame.tile.int32t(target("riscv.ame.tile.int32") %z4, ptr %dst)
  %z5 = call target("riscv.ame.tile.fp16") @llvm.riscv.zames.mzero.triscv.ame.tile.fp16t()
  call void @llvm.riscv.zames.msa.whole.triscv.ame.tile.fp16t(target("riscv.ame.tile.fp16") %z5, ptr %dst)
  %z6 = call target("riscv.ame.tile.bf16") @llvm.riscv.zames.mzero.triscv.ame.tile.bf16t()
  call void @llvm.riscv.zames.msa.whole.triscv.ame.tile.bf16t(target("riscv.ame.tile.bf16") %z6, ptr %dst)
  %z7 = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mzero.triscv.ame.tile.fp32t()
  call void @llvm.riscv.zames.msc.whole.triscv.ame.tile.fp32t(target("riscv.ame.tile.fp32") %z7, ptr %dst)
  ret void
}

; mmacc covers the six supported element combinations. Distinct A/B pointers
; and load opcodes keep the required machine operand order C, B, A observable.
; Pre-RA materializes the accumulator and input payloads; late expansion emits
; one msetcfg per physical matrix operand.
define void @zames_fp_mmacc(ptr %src, ptr %src2, ptr %dst) {
; ISEL-LABEL: name: zames_fp_mmacc
; ISEL: %[[A1:[0-9]+]]:zamestilereg = ZAMES_MLA_WHOLE
; ISEL: %[[B1:[0-9]+]]:zamestilereg = ZAMES_MLB_WHOLE
; ISEL: %[[C1:[0-9]+]]:zamesaccreg = ZAMES_MLC_WHOLE
; ISEL: PSEUDO_ZAMES_MMACC_I8_I32_PRE %[[C1]], {{.*}}%[[B1]], {{.*}}%[[A1]]{{$}}
; ISEL: %[[A2:[0-9]+]]:zamestilereg = ZAMES_MLA_WHOLE
; ISEL: %[[B2:[0-9]+]]:zamestilereg = ZAMES_MLB_WHOLE
; ISEL: %[[C2:[0-9]+]]:zamesaccreg = ZAMES_MLC_WHOLE
; ISEL: PSEUDO_ZAMES_MMACC_I8_F32_PRE %[[C2]], {{.*}}%[[B2]], {{.*}}%[[A2]]{{$}}
; ISEL: %[[A3:[0-9]+]]:zamestilereg = ZAMES_MLA_WHOLE
; ISEL: %[[B3:[0-9]+]]:zamestilereg = ZAMES_MLB_WHOLE
; ISEL: %[[C3:[0-9]+]]:zamesaccreg = ZAMES_MLC_WHOLE
; ISEL: PSEUDO_ZAMES_MMACC_FP8E4_F32_PRE %[[C3]], {{.*}}%[[B3]], {{.*}}%[[A3]]{{$}}
; ISEL: %[[A4:[0-9]+]]:zamestilereg = ZAMES_MLA_WHOLE
; ISEL: %[[B4:[0-9]+]]:zamestilereg = ZAMES_MLB_WHOLE
; ISEL: %[[C4:[0-9]+]]:zamesaccreg = ZAMES_MLC_WHOLE
; ISEL: PSEUDO_ZAMES_MMACC_FP8E5_F32_PRE %[[C4]], {{.*}}%[[B4]], {{.*}}%[[A4]]{{$}}
; ISEL: %[[A5:[0-9]+]]:zamestilereg = ZAMES_MLA_WHOLE
; ISEL: %[[B5:[0-9]+]]:zamestilereg = ZAMES_MLB_WHOLE
; ISEL: %[[C5:[0-9]+]]:zamesaccreg = ZAMES_MLC_WHOLE
; ISEL: PSEUDO_ZAMES_MMACC_F16_F32_PRE %[[C5]], {{.*}}%[[B5]], {{.*}}%[[A5]]{{$}}
; ISEL: %[[A6:[0-9]+]]:zamestilereg = ZAMES_MLA_WHOLE
; ISEL: %[[B6:[0-9]+]]:zamestilereg = ZAMES_MLB_WHOLE
; ISEL: %[[C6:[0-9]+]]:zamesaccreg = ZAMES_MLC_WHOLE
; ISEL: PSEUDO_ZAMES_MMACC_BF16_F32_PRE %[[C6]], {{.*}}%[[B6]], {{.*}}%[[A6]]{{$}}
; PRERA-LABEL: name: zames_fp_mmacc
; PRERA: %[[CC:[0-9]+]]:gpr = ADDI $x0, 4
; PRERA-NEXT: %[[MC:[0-9]+]]:gpr = ADDI $x0, 2
; PRERA-NEXT: %{{[0-9]+}}:zamesaccreg = PSEUDO_ZAMES_MMACC_I8_I32 %{{[0-9]+}}, {{.*}}%{{[0-9]+}}, {{.*}}%{{[0-9]+}}, %[[CC]], %[[MC]], %[[MC]]{{$}}
; PRERA: %[[CC:[0-9]+]]:gpr = ADDI $x0, 12
; PRERA-NEXT: %[[MC:[0-9]+]]:gpr = ADDI $x0, 2
; PRERA-NEXT: %{{[0-9]+}}:zamesaccreg = PSEUDO_ZAMES_MMACC_I8_F32 %{{[0-9]+}}, {{.*}}%{{[0-9]+}}, {{.*}}%{{[0-9]+}}, %[[CC]], %[[MC]], %[[MC]]{{$}}
; PRERA: %[[CC:[0-9]+]]:gpr = ADDI $x0, 12
; PRERA-NEXT: %[[MC:[0-9]+]]:gpr = ADDI $x0, 8
; PRERA-NEXT: %{{[0-9]+}}:zamesaccreg = PSEUDO_ZAMES_MMACC_FP8E4_F32 %{{[0-9]+}}, {{.*}}%{{[0-9]+}}, {{.*}}%{{[0-9]+}}, %[[CC]], %[[MC]], %[[MC]]{{$}}
; PRERA: %[[CC:[0-9]+]]:gpr = ADDI $x0, 12
; PRERA-NEXT: %[[MC:[0-9]+]]:gpr = ADDI $x0, 7
; PRERA-NEXT: %{{[0-9]+}}:zamesaccreg = PSEUDO_ZAMES_MMACC_FP8E5_F32 %{{[0-9]+}}, {{.*}}%{{[0-9]+}}, {{.*}}%{{[0-9]+}}, %[[CC]], %[[MC]], %[[MC]]{{$}}
; PRERA: %[[CC:[0-9]+]]:gpr = ADDI $x0, 12
; PRERA-NEXT: %[[MC:[0-9]+]]:gpr = ADDI $x0, 9
; PRERA-NEXT: %{{[0-9]+}}:zamesaccreg = PSEUDO_ZAMES_MMACC_F16_F32 %{{[0-9]+}}, {{.*}}%{{[0-9]+}}, {{.*}}%{{[0-9]+}}, %[[CC]], %[[MC]], %[[MC]]{{$}}
; PRERA: %[[CC:[0-9]+]]:gpr = ADDI $x0, 12
; PRERA-NEXT: %[[MC:[0-9]+]]:gpr = ADDI $x0, 10
; PRERA-NEXT: %{{[0-9]+}}:zamesaccreg = PSEUDO_ZAMES_MMACC_BF16_F32 %{{[0-9]+}}, {{.*}}%{{[0-9]+}}, {{.*}}%{{[0-9]+}}, %[[CC]], %[[MC]], %[[MC]]{{$}}
; POSTRA-LABEL: name: zames_fp_mmacc
; POSTRA: ZAMES_MSETCFG [[#C:]], {{.*}}
; POSTRA-NEXT: ZAMES_MSETCFG [[#B:]], {{.*}}
; POSTRA-NEXT: ZAMES_MSETCFG [[#A:]], {{.*}}
; POSTRA-NEXT: {{.*}}$zames_acc[[#C-4]] = ZAMES_MMACC {{.*}}$zames_acc[[#C-4]], {{.*}}$zames_tr[[#B]], {{.*}}$zames_tr[[#A]]{{$}}
; POSTRA: ZAMES_MSETCFG [[#C:]], {{.*}}
; POSTRA-NEXT: ZAMES_MSETCFG [[#B:]], {{.*}}
; POSTRA-NEXT: ZAMES_MSETCFG [[#A:]], {{.*}}
; POSTRA-NEXT: {{.*}}$zames_acc[[#C-4]] = ZAMES_MMACC {{.*}}$zames_acc[[#C-4]], {{.*}}$zames_tr[[#B]], {{.*}}$zames_tr[[#A]]{{$}}
; POSTRA: ZAMES_MSETCFG [[#C:]], {{.*}}
; POSTRA-NEXT: ZAMES_MSETCFG [[#B:]], {{.*}}
; POSTRA-NEXT: ZAMES_MSETCFG [[#A:]], {{.*}}
; POSTRA-NEXT: {{.*}}$zames_acc[[#C-4]] = ZAMES_MMACC {{.*}}$zames_acc[[#C-4]], {{.*}}$zames_tr[[#B]], {{.*}}$zames_tr[[#A]]{{$}}
; POSTRA: ZAMES_MSETCFG [[#C:]], {{.*}}
; POSTRA-NEXT: ZAMES_MSETCFG [[#B:]], {{.*}}
; POSTRA-NEXT: ZAMES_MSETCFG [[#A:]], {{.*}}
; POSTRA-NEXT: {{.*}}$zames_acc[[#C-4]] = ZAMES_MMACC {{.*}}$zames_acc[[#C-4]], {{.*}}$zames_tr[[#B]], {{.*}}$zames_tr[[#A]]{{$}}
; POSTRA: ZAMES_MSETCFG [[#C:]], {{.*}}
; POSTRA-NEXT: ZAMES_MSETCFG [[#B:]], {{.*}}
; POSTRA-NEXT: ZAMES_MSETCFG [[#A:]], {{.*}}
; POSTRA-NEXT: {{.*}}$zames_acc[[#C-4]] = ZAMES_MMACC {{.*}}$zames_acc[[#C-4]], {{.*}}$zames_tr[[#B]], {{.*}}$zames_tr[[#A]]{{$}}
; POSTRA: ZAMES_MSETCFG [[#C:]], {{.*}}
; POSTRA-NEXT: ZAMES_MSETCFG [[#B:]], {{.*}}
; POSTRA-NEXT: ZAMES_MSETCFG [[#A:]], {{.*}}
; POSTRA-NEXT: {{.*}}$zames_acc[[#C-4]] = ZAMES_MMACC {{.*}}$zames_acc[[#C-4]], {{.*}}$zames_tr[[#B]], {{.*}}$zames_tr[[#A]]{{$}}
; OBJ-LABEL: <zames_fp_mmacc>:
; OBJ: mmacc{{[ \t]}}acc{{[0-3]}}, tr{{[0-3]}}, tr{{[0-3]}}
; OBJ: mmacc{{[ \t]}}acc{{[0-3]}}, tr{{[0-3]}}, tr{{[0-3]}}
; OBJ: mmacc{{[ \t]}}acc{{[0-3]}}, tr{{[0-3]}}, tr{{[0-3]}}
; OBJ: mmacc{{[ \t]}}acc{{[0-3]}}, tr{{[0-3]}}, tr{{[0-3]}}
; OBJ: mmacc{{[ \t]}}acc{{[0-3]}}, tr{{[0-3]}}, tr{{[0-3]}}
; OBJ: mmacc{{[ \t]}}acc{{[0-3]}}, tr{{[0-3]}}, tr{{[0-3]}}
  %a1 = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.whole.triscv.ame.tile.int8t(ptr %src)
  %b1 = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.int8t(ptr %src2)
  %c1 = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.int32t(ptr %src)
  %r1 = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mmacc.triscv.ame.tile.int32t.triscv.ame.tile.int8t.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %a1, target("riscv.ame.tile.int8") %b1, target("riscv.ame.tile.int32") %c1)
  call void @llvm.riscv.zames.msc.whole.triscv.ame.tile.int32t(target("riscv.ame.tile.int32") %r1, ptr %dst)
  %a2 = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.whole.triscv.ame.tile.int8t(ptr %src)
  %b2 = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.int8t(ptr %src2)
  %c2 = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.fp32t(ptr %src)
  %r2 = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mmacc.triscv.ame.tile.fp32t.triscv.ame.tile.int8t.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %a2, target("riscv.ame.tile.int8") %b2, target("riscv.ame.tile.fp32") %c2)
  call void @llvm.riscv.zames.msc.whole.triscv.ame.tile.fp32t(target("riscv.ame.tile.fp32") %r2, ptr %dst)
  %a3 = call target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mla.whole.triscv.ame.tile.fp8e4t(ptr %src)
  %b3 = call target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.fp8e4t(ptr %src2)
  %c3 = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.fp32t(ptr %src)
  %r3 = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mmacc.triscv.ame.tile.fp32t.triscv.ame.tile.fp8e4t.triscv.ame.tile.fp8e4t(target("riscv.ame.tile.fp8e4") %a3, target("riscv.ame.tile.fp8e4") %b3, target("riscv.ame.tile.fp32") %c3)
  call void @llvm.riscv.zames.msc.whole.triscv.ame.tile.fp32t(target("riscv.ame.tile.fp32") %r3, ptr %dst)
  %a4 = call target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mla.whole.triscv.ame.tile.fp8e5t(ptr %src)
  %b4 = call target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.fp8e5t(ptr %src2)
  %c4 = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.fp32t(ptr %src)
  %r4 = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mmacc.triscv.ame.tile.fp32t.triscv.ame.tile.fp8e5t.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e5") %a4, target("riscv.ame.tile.fp8e5") %b4, target("riscv.ame.tile.fp32") %c4)
  call void @llvm.riscv.zames.msc.whole.triscv.ame.tile.fp32t(target("riscv.ame.tile.fp32") %r4, ptr %dst)
  %a5 = call target("riscv.ame.tile.fp16") @llvm.riscv.zames.mla.whole.triscv.ame.tile.fp16t(ptr %src)
  %b5 = call target("riscv.ame.tile.fp16") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.fp16t(ptr %src2)
  %c5 = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.fp32t(ptr %src)
  %r5 = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mmacc.triscv.ame.tile.fp32t.triscv.ame.tile.fp16t.triscv.ame.tile.fp16t(target("riscv.ame.tile.fp16") %a5, target("riscv.ame.tile.fp16") %b5, target("riscv.ame.tile.fp32") %c5)
  call void @llvm.riscv.zames.msc.whole.triscv.ame.tile.fp32t(target("riscv.ame.tile.fp32") %r5, ptr %dst)
  %a6 = call target("riscv.ame.tile.bf16") @llvm.riscv.zames.mla.whole.triscv.ame.tile.bf16t(ptr %src)
  %b6 = call target("riscv.ame.tile.bf16") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.bf16t(ptr %src2)
  %c6 = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.fp32t(ptr %src)
  %r6 = call target("riscv.ame.tile.fp32") @llvm.riscv.zames.mmacc.triscv.ame.tile.fp32t.triscv.ame.tile.bf16t.triscv.ame.tile.bf16t(target("riscv.ame.tile.bf16") %a6, target("riscv.ame.tile.bf16") %b6, target("riscv.ame.tile.fp32") %c6)
  call void @llvm.riscv.zames.msc.whole.triscv.ame.tile.fp32t(target("riscv.ame.tile.fp32") %r6, ptr %dst)
  ret void
}

declare target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mla.triscv.ame.tile.fp8e4t(ptr, i64)
declare target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mlat.triscv.ame.tile.fp8e4t(ptr, i64)
declare target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mlb.triscv.ame.tile.fp8e4t(ptr, i64)
declare target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mlbt.triscv.ame.tile.fp8e4t(ptr, i64)
declare target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mla.triscv.ame.tile.fp8e5t(ptr, i64)
declare target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mlat.triscv.ame.tile.fp8e5t(ptr, i64)
declare target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mlb.triscv.ame.tile.fp8e5t(ptr, i64)
declare target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mlbt.triscv.ame.tile.fp8e5t(ptr, i64)
declare target("riscv.ame.tile.fp16") @llvm.riscv.zames.mla.triscv.ame.tile.fp16t(ptr, i64)
declare target("riscv.ame.tile.fp16") @llvm.riscv.zames.mlat.triscv.ame.tile.fp16t(ptr, i64)
declare target("riscv.ame.tile.fp16") @llvm.riscv.zames.mlb.triscv.ame.tile.fp16t(ptr, i64)
declare target("riscv.ame.tile.fp16") @llvm.riscv.zames.mlbt.triscv.ame.tile.fp16t(ptr, i64)
declare target("riscv.ame.tile.bf16") @llvm.riscv.zames.mla.triscv.ame.tile.bf16t(ptr, i64)
declare target("riscv.ame.tile.bf16") @llvm.riscv.zames.mlat.triscv.ame.tile.bf16t(ptr, i64)
declare target("riscv.ame.tile.bf16") @llvm.riscv.zames.mlb.triscv.ame.tile.bf16t(ptr, i64)
declare target("riscv.ame.tile.bf16") @llvm.riscv.zames.mlbt.triscv.ame.tile.bf16t(ptr, i64)
declare target("riscv.ame.tile.fp32") @llvm.riscv.zames.mlc.triscv.ame.tile.fp32t(ptr, i64)
declare target("riscv.ame.tile.fp32") @llvm.riscv.zames.mlct.triscv.ame.tile.fp32t(ptr, i64)
declare void @llvm.riscv.zames.msa.triscv.ame.tile.fp8e4t(target("riscv.ame.tile.fp8e4"), ptr, i64)
declare void @llvm.riscv.zames.msat.triscv.ame.tile.fp8e4t(target("riscv.ame.tile.fp8e4"), ptr, i64)
declare void @llvm.riscv.zames.msb.triscv.ame.tile.fp8e4t(target("riscv.ame.tile.fp8e4"), ptr, i64)
declare void @llvm.riscv.zames.msbt.triscv.ame.tile.fp8e4t(target("riscv.ame.tile.fp8e4"), ptr, i64)
declare void @llvm.riscv.zames.msa.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e5"), ptr, i64)
declare void @llvm.riscv.zames.msat.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e5"), ptr, i64)
declare void @llvm.riscv.zames.msb.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e5"), ptr, i64)
declare void @llvm.riscv.zames.msbt.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e5"), ptr, i64)
declare void @llvm.riscv.zames.msa.triscv.ame.tile.fp16t(target("riscv.ame.tile.fp16"), ptr, i64)
declare void @llvm.riscv.zames.msat.triscv.ame.tile.fp16t(target("riscv.ame.tile.fp16"), ptr, i64)
declare void @llvm.riscv.zames.msb.triscv.ame.tile.fp16t(target("riscv.ame.tile.fp16"), ptr, i64)
declare void @llvm.riscv.zames.msbt.triscv.ame.tile.fp16t(target("riscv.ame.tile.fp16"), ptr, i64)
declare void @llvm.riscv.zames.msa.triscv.ame.tile.bf16t(target("riscv.ame.tile.bf16"), ptr, i64)
declare void @llvm.riscv.zames.msat.triscv.ame.tile.bf16t(target("riscv.ame.tile.bf16"), ptr, i64)
declare void @llvm.riscv.zames.msb.triscv.ame.tile.bf16t(target("riscv.ame.tile.bf16"), ptr, i64)
declare void @llvm.riscv.zames.msbt.triscv.ame.tile.bf16t(target("riscv.ame.tile.bf16"), ptr, i64)
declare void @llvm.riscv.zames.msc.triscv.ame.tile.fp32t(target("riscv.ame.tile.fp32"), ptr, i64)
declare void @llvm.riscv.zames.msct.triscv.ame.tile.fp32t(target("riscv.ame.tile.fp32"), ptr, i64)
declare target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mla.whole.triscv.ame.tile.fp8e4t(ptr)
declare target("riscv.ame.tile.fp16") @llvm.riscv.zames.mla.whole.triscv.ame.tile.fp16t(ptr)
declare target("riscv.ame.tile.bf16") @llvm.riscv.zames.mla.whole.triscv.ame.tile.bf16t(ptr)
declare target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.fp8e5t(ptr)
declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.int8t(ptr)
declare target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.fp8e4t(ptr)
declare target("riscv.ame.tile.fp16") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.fp16t(ptr)
declare target("riscv.ame.tile.bf16") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.bf16t(ptr)
declare target("riscv.ame.tile.fp32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.fp32t(ptr)
declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.whole.triscv.ame.tile.int8t(ptr)
declare target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.int32t(ptr)
declare target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mla.whole.triscv.ame.tile.fp8e5t(ptr)
declare void @llvm.riscv.zames.msa.whole.triscv.ame.tile.fp8e4t(target("riscv.ame.tile.fp8e4"), ptr)
declare void @llvm.riscv.zames.msa.whole.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e5"), ptr)
declare void @llvm.riscv.zames.msa.whole.triscv.ame.tile.fp16t(target("riscv.ame.tile.fp16"), ptr)
declare void @llvm.riscv.zames.msa.whole.triscv.ame.tile.bf16t(target("riscv.ame.tile.bf16"), ptr)
declare void @llvm.riscv.zames.msb.whole.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e5"), ptr)
declare void @llvm.riscv.zames.msb.whole.triscv.ame.tile.bf16t(target("riscv.ame.tile.bf16"), ptr)
declare void @llvm.riscv.zames.msc.whole.triscv.ame.tile.fp32t(target("riscv.ame.tile.fp32"), ptr)
declare void @llvm.riscv.zames.msa.whole.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), ptr)
declare void @llvm.riscv.zames.msc.whole.triscv.ame.tile.int32t(target("riscv.ame.tile.int32"), ptr)
declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mzero.triscv.ame.tile.int8t()
declare target("riscv.ame.tile.fp8e4") @llvm.riscv.zames.mzero.triscv.ame.tile.fp8e4t()
declare target("riscv.ame.tile.fp8e5") @llvm.riscv.zames.mzero.triscv.ame.tile.fp8e5t()
declare target("riscv.ame.tile.int32") @llvm.riscv.zames.mzero.triscv.ame.tile.int32t()
declare target("riscv.ame.tile.fp16") @llvm.riscv.zames.mzero.triscv.ame.tile.fp16t()
declare target("riscv.ame.tile.bf16") @llvm.riscv.zames.mzero.triscv.ame.tile.bf16t()
declare target("riscv.ame.tile.fp32") @llvm.riscv.zames.mzero.triscv.ame.tile.fp32t()
declare target("riscv.ame.tile.int32") @llvm.riscv.zames.mmacc.triscv.ame.tile.int32t.triscv.ame.tile.int8t.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), target("riscv.ame.tile.int8"), target("riscv.ame.tile.int32"))
declare target("riscv.ame.tile.fp32") @llvm.riscv.zames.mmacc.triscv.ame.tile.fp32t.triscv.ame.tile.int8t.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), target("riscv.ame.tile.int8"), target("riscv.ame.tile.fp32"))
declare target("riscv.ame.tile.fp32") @llvm.riscv.zames.mmacc.triscv.ame.tile.fp32t.triscv.ame.tile.fp8e4t.triscv.ame.tile.fp8e4t(target("riscv.ame.tile.fp8e4"), target("riscv.ame.tile.fp8e4"), target("riscv.ame.tile.fp32"))
declare target("riscv.ame.tile.fp32") @llvm.riscv.zames.mmacc.triscv.ame.tile.fp32t.triscv.ame.tile.fp8e5t.triscv.ame.tile.fp8e5t(target("riscv.ame.tile.fp8e5"), target("riscv.ame.tile.fp8e5"), target("riscv.ame.tile.fp32"))
declare target("riscv.ame.tile.fp32") @llvm.riscv.zames.mmacc.triscv.ame.tile.fp32t.triscv.ame.tile.fp16t.triscv.ame.tile.fp16t(target("riscv.ame.tile.fp16"), target("riscv.ame.tile.fp16"), target("riscv.ame.tile.fp32"))
declare target("riscv.ame.tile.fp32") @llvm.riscv.zames.mmacc.triscv.ame.tile.fp32t.triscv.ame.tile.bf16t.triscv.ame.tile.bf16t(target("riscv.ame.tile.bf16"), target("riscv.ame.tile.bf16"), target("riscv.ame.tile.fp32"))
