; RUN: llc -mtriple=riscv64 -mattr=+zames -verify-machineinstrs < %s | FileCheck %s --implicit-check-not=llvm.riscv.buddy
; RUN: llc -mtriple=riscv64 -mattr=+zames -filetype=obj %s -o %t.o
; RUN: llvm-objdump --mattr=+zames -d %t.o | FileCheck %s --check-prefix=CHECK-OBJ

; This file intentionally keeps every matrix value in one basic block with
; short live ranges. Matrix-register copy, spill, reload, frame layout, and ABI
; handling are outside the current backend contract.

define void @zames_settile_immediates() {
; CHECK-LABEL: zames_settile_immediates:
; CHECK:       msettilemi 4
; CHECK-NEXT:  msettileni 8
; CHECK-NEXT:  msettileki 16
; CHECK-NEXT:  ret
  call void @llvm.riscv.zames.msettilemi(i64 4)
  call void @llvm.riscv.zames.msettileni(i64 8)
  call void @llvm.riscv.zames.msettileki(i64 16)
  ret void
}

; Encoding boundary of the uimm10 tile field and the 3-bit config selector:
; the inclusive hardware endpoints must still select. tile=0 is an LLVM
; encoding-boundary check only; the ZAMES dialect never emits zero sizes.
define void @zames_settile_immediate_boundaries() {
; CHECK-LABEL: zames_settile_immediate_boundaries:
; CHECK:       msettilemi 0
; CHECK-NEXT:  msettileni 1023
; CHECK-NEXT:  msettileki 0
; CHECK-NEXT:  ret
  call void @llvm.riscv.zames.msettilemi(i64 0)
  call void @llvm.riscv.zames.msettileni(i64 1023)
  call void @llvm.riscv.zames.msettileki(i64 0)
  ret void
}

define void @zames_settile_registers(i64 %m, i64 %n, i64 %k) {
; CHECK-LABEL: zames_settile_registers:
; CHECK:       msettilem a0
; CHECK-NEXT:  msettilen a1
; CHECK-NEXT:  msettilek a2
; CHECK-NEXT:  ret
; CHECK-OBJ-LABEL: <zames_settile_registers>:
; CHECK-OBJ:       msettilem a0
; CHECK-OBJ-NEXT:  msettilen a1
; CHECK-OBJ-NEXT:  msettilek a2
  call void @llvm.riscv.zames.msettilem(i64 %m)
  call void @llvm.riscv.zames.msettilen(i64 %n)
  call void @llvm.riscv.zames.msettilek(i64 %k)
  ret void
}

define void @zames_minit() {
; CHECK-LABEL: zames_minit:
; CHECK:       # %bb.0:
; CHECK-NEXT:  minit
; CHECK-NEXT:  ret
; CHECK-OBJ-LABEL: <zames_minit>:
; CHECK-OBJ:       minit{{$}}
  call void @llvm.riscv.zames.minit()
  ret void
}

define i64 @zames_cfg_intrinsics(i64 %value) {
; CHECK-LABEL: zames_cfg_intrinsics:
; CHECK:       msetcfg mcfg3, a0
; CHECK-NEXT:  mgetcfg a0, mcfg3
; CHECK-NEXT:  ret
  call void @llvm.riscv.zames.msetcfg(i64 3, i64 %value)
  %cfg = call i64 @llvm.riscv.zames.mgetcfg(i64 3)
  ret i64 %cfg
}

define i64 @zames_cfg_immediate_boundaries(i64 %value) {
; CHECK-LABEL: zames_cfg_immediate_boundaries:
; CHECK:       msetcfg mcfg0, a0
; CHECK-NEXT:  mgetcfg a0, mcfg7
; CHECK-NEXT:  ret
  call void @llvm.riscv.zames.msetcfg(i64 0, i64 %value)
  %cfg = call i64 @llvm.riscv.zames.mgetcfg(i64 7)
  ret i64 %cfg
}

; Check matrix register/configuration relationships, not GPR materialization
; order or a particular physical register allocation.
define void @zames_straight_line(ptr %a, ptr %b, ptr %c, i64 %stride_a, i64 %stride_b, i64 %stride_c) {
; CHECK-LABEL: zames_straight_line:
; CHECK:       msettilemi 4
; CHECK:       msettileni 4
; CHECK:       msettileki 8
; CHECK:       msetcfg mcfg[[#A:]], {{[a-z0-9]+}}
; CHECK-NEXT:  mla tr[[#A]], (a0), a3
; CHECK:       msetcfg mcfg[[#B:]], {{[a-z0-9]+}}
; CHECK-NEXT:  mlbt tr[[#B]], (a1), a4
; CHECK:       msetcfg mcfg[[#C:]], {{[a-z0-9]+}}
; CHECK-NEXT:  mzero acc[[#C-4]]
; CHECK:       msetcfg mcfg[[#C]], {{[a-z0-9]+}}
; CHECK-NEXT:  msetcfg mcfg[[#B]], {{[a-z0-9]+}}
; CHECK-NEXT:  msetcfg mcfg[[#A]], {{[a-z0-9]+}}
; CHECK-NEXT:  mmacc acc[[#C-4]], tr[[#B]], tr[[#A]]
; CHECK:       msetcfg mcfg[[#C]], {{[a-z0-9]+}}
; CHECK-NEXT:  msc acc[[#C-4]], (a2), a5
; CHECK:       ret
  call void @llvm.riscv.zames.msettilemi(i64 4)
  call void @llvm.riscv.zames.msettileni(i64 4)
  call void @llvm.riscv.zames.msettileki(i64 8)
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

define void @zames_mlb_straight_line(ptr %a, ptr %b, ptr %c,
                                     i64 %stride_a, i64 %stride_b,
                                     i64 %stride_c) {
; CHECK-LABEL: zames_mlb_straight_line:
; CHECK:       msettilemi 4
; CHECK:       msettileni 4
; CHECK:       msettileki 8
; CHECK:       msetcfg mcfg[[#A:]], {{[a-z0-9]+}}
; CHECK-NEXT:  mla tr[[#A]], (a0), a3
; CHECK:       msetcfg mcfg[[#B:]], {{[a-z0-9]+}}
; CHECK-NEXT:  mlb tr[[#B]], (a1), a4
; CHECK:       msetcfg mcfg[[#C:]], {{[a-z0-9]+}}
; CHECK-NEXT:  mzero acc[[#C-4]]
; CHECK:       msetcfg mcfg[[#C]], {{[a-z0-9]+}}
; CHECK-NEXT:  msetcfg mcfg[[#B]], {{[a-z0-9]+}}
; CHECK-NEXT:  msetcfg mcfg[[#A]], {{[a-z0-9]+}}
; CHECK-NEXT:  mmacc acc[[#C-4]], tr[[#B]], tr[[#A]]
; CHECK:       msetcfg mcfg[[#C]], {{[a-z0-9]+}}
; CHECK-NEXT:  msc acc[[#C-4]], (a2), a5
; CHECK:       ret
  call void @llvm.riscv.zames.msettilemi(i64 4)
  call void @llvm.riscv.zames.msettileni(i64 4)
  call void @llvm.riscv.zames.msettileki(i64 8)
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

define void @zames_mlc_straight_line(ptr %c, i64 %stride_c) {
; CHECK-LABEL: zames_mlc_straight_line:
; CHECK:       msettilemi 4
; CHECK:       msettileni 4
; CHECK:       msettileki 8
; CHECK:       msetcfg mcfg[[#C:]], {{[a-z0-9]+}}
; CHECK-NEXT:  mlc acc[[#C-4]], (a0), a1
; CHECK:       ret
  call void @llvm.riscv.zames.msettilemi(i64 4)
  call void @llvm.riscv.zames.msettileni(i64 4)
  call void @llvm.riscv.zames.msettileki(i64 8)
  %acc = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.triscv.ame.tile.int32t(ptr %c, i64 %stride_c)
  ret void
}

define void @zames_transpose_load_store(ptr %a, ptr %c, i64 %stride_a, i64 %stride_c) {
; CHECK-LABEL: zames_transpose_load_store:
; CHECK:       msetcfg mcfg[[#A:]], {{[a-z0-9]+}}
; CHECK-NEXT:  mlat tr[[#A]], (a0), a2
; CHECK:       msetcfg mcfg[[#C:]], {{[a-z0-9]+}}
; CHECK-NEXT:  mlct acc[[#C-4]], (a1), a3
; CHECK:       msetcfg mcfg[[#A]], {{[a-z0-9]+}}
; CHECK-NEXT:  msat tr[[#A]], (a0), a2
; CHECK:       msetcfg mcfg[[#C]], {{[a-z0-9]+}}
; CHECK-NEXT:  msct acc[[#C-4]], (a1), a3
; CHECK:       ret
  %ta = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlat.triscv.ame.tile.int8t(ptr %a, i64 %stride_a)
  %tc = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mlct.triscv.ame.tile.int32t(ptr %c, i64 %stride_c)
  call void @llvm.riscv.zames.msat.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %ta, ptr %a, i64 %stride_a)
  call void @llvm.riscv.zames.msct.triscv.ame.tile.int32t(target("riscv.ame.tile.int32") %tc, ptr %c, i64 %stride_c)
  ret void
}

define void @zames_store_variants(ptr %a, ptr %b, ptr %c, i64 %stride) {
; CHECK-LABEL: zames_store_variants:
; CHECK:       msetcfg mcfg[[#A:]], {{[a-z0-9]+}}
; CHECK-NEXT:  mla tr[[#A]], (a0), a3
; CHECK:       msetcfg mcfg[[#B:]], {{[a-z0-9]+}}
; CHECK-NEXT:  mlb tr[[#B]], (a1), a3
; CHECK:       msetcfg mcfg[[#C:]], {{[a-z0-9]+}}
; CHECK-NEXT:  mlc acc[[#C-4]], (a2), a3
; CHECK:       msetcfg mcfg[[#A]], {{[a-z0-9]+}}
; CHECK-NEXT:  msa tr[[#A]], (a0), a3
; CHECK:       msetcfg mcfg[[#B]], {{[a-z0-9]+}}
; CHECK-NEXT:  msb tr[[#B]], (a1), a3
; CHECK:       msetcfg mcfg[[#B]], {{[a-z0-9]+}}
; CHECK-NEXT:  msbt tr[[#B]], (a1), a3
; CHECK:       msetcfg mcfg[[#C]], {{[a-z0-9]+}}
; CHECK-NEXT:  msct acc[[#C-4]], (a2), a3
; CHECK:       ret
  %ta = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.triscv.ame.tile.int8t(ptr %a, i64 %stride)
  %tb = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlb.triscv.ame.tile.int8t(ptr %b, i64 %stride)
  %tc = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.triscv.ame.tile.int32t(ptr %c, i64 %stride)
  call void @llvm.riscv.zames.msa.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %ta, ptr %a, i64 %stride)
  call void @llvm.riscv.zames.msb.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %tb, ptr %b, i64 %stride)
  call void @llvm.riscv.zames.msbt.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %tb, ptr %b, i64 %stride)
  call void @llvm.riscv.zames.msct.triscv.ame.tile.int32t(target("riscv.ame.tile.int32") %tc, ptr %c, i64 %stride)
  ret void
}

define void @zames_whole(ptr %src, ptr %dst) {
; CHECK-LABEL: zames_whole:
; CHECK-NOT:   msetcfg
; CHECK:       mla.whole tr0, (a0)
; CHECK-NEXT:  mlb.whole tr1, (a0)
; CHECK-NEXT:  mlc.whole acc0, (a0)
; CHECK-NEXT:  msa.whole tr0, (a1)
; CHECK-NEXT:  msb.whole tr1, (a1)
; CHECK-NEXT:  msc.whole acc0, (a1)
; CHECK-NEXT:  ret
; CHECK-OBJ-LABEL: <zames_whole>:
; CHECK-OBJ-NOT:   msetcfg
; CHECK-OBJ:       mla.whole tr0, (a0)
; CHECK-OBJ-NEXT:  mlb.whole tr1, (a0)
; CHECK-OBJ-NEXT:  mlc.whole acc0, (a0)
; CHECK-OBJ-NEXT:  msa.whole tr0, (a1)
; CHECK-OBJ-NEXT:  msb.whole tr1, (a1)
; CHECK-OBJ-NEXT:  msc.whole acc0, (a1)
  %a = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.whole.triscv.ame.tile.int8t(ptr %src)
  %b = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mlb.whole.triscv.ame.tile.int8t(ptr %src)
  %c = call target("riscv.ame.tile.int32") @llvm.riscv.zames.mlc.whole.triscv.ame.tile.int32t(ptr %src)
  call void @llvm.riscv.zames.msa.whole.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %a, ptr %dst)
  call void @llvm.riscv.zames.msb.whole.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %b, ptr %dst)
  call void @llvm.riscv.zames.msc.whole.triscv.ame.tile.int32t(target("riscv.ame.tile.int32") %c, ptr %dst)
  ret void
}

declare void @llvm.riscv.zames.msettilemi(i64)
declare void @llvm.riscv.zames.msettileni(i64)
declare void @llvm.riscv.zames.msettileki(i64)
declare void @llvm.riscv.zames.msettilem(i64)
declare void @llvm.riscv.zames.msettilen(i64)
declare void @llvm.riscv.zames.msettilek(i64)
declare void @llvm.riscv.zames.minit()
declare void @llvm.riscv.zames.msetcfg(i64, i64)
declare i64 @llvm.riscv.zames.mgetcfg(i64)
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
