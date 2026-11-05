; RUN: split-file %s %t
; RUN: not llvm-as %t/tile-alloca.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=TILE-ALLOCA
; RUN: not llvm-as %t/sync-alloca.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=SYNC-ALLOCA
; RUN: not llvm-as %t/tile-byval.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=TILE-BYVAL
; RUN: not llvm-as %t/sync-byval.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=SYNC-BYVAL
; RUN: not llvm-as %t/tile-zero.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=TILE-ZERO
; RUN: not llvm-as %t/sync-zero.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=SYNC-ZERO
;
; Sized placeholder layouts do not grant stack allocation or zero constants
; to the native matrix and synchronization register types.

;--- tile-alloca.ll
; TILE-ALLOCA: Alloca has illegal target extension type
; TILE-ALLOCA-NEXT: %value = alloca target("riscv.xsai.zames.tile.int8")
define void @tile_alloca() {
  %value = alloca target("riscv.xsai.zames.tile.int8")
  ret void
}

;--- sync-alloca.ll
; SYNC-ALLOCA: Alloca has illegal target extension type
; SYNC-ALLOCA-NEXT: %value = alloca target("riscv.xsai.zmasync.sync")
define void @sync_alloca() {
  %value = alloca target("riscv.xsai.zmasync.sync")
  ret void
}

;--- tile-byval.ll
; TILE-BYVAL: 'byval' argument has illegal target extension type
declare void @tile_byval(ptr byval(target("riscv.xsai.zames.tile.int32")))

;--- sync-byval.ll
; SYNC-BYVAL: 'byval' argument has illegal target extension type
declare void @sync_byval(ptr byval(target("riscv.xsai.zmasync.sync")))

;--- tile-zero.ll
; TILE-ZERO: error: invalid type for null constant
define target("riscv.xsai.zames.tile.fp32") @tile_zero() {
  ret target("riscv.xsai.zames.tile.fp32") zeroinitializer
}

;--- sync-zero.ll
; SYNC-ZERO: error: invalid type for null constant
define target("riscv.xsai.zmasync.sync") @sync_zero() {
  ret target("riscv.xsai.zmasync.sync") zeroinitializer
}
