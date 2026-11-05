; RUN: split-file %s %t
; RUN: not llvm-as %t/tile-alloca.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=TILE-ALLOCA
; RUN: not llvm-as %t/sync-alloca.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=SYNC-ALLOCA
; RUN: not llvm-as %t/tile-byval.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=TILE-BYVAL
; RUN: not llvm-as %t/sync-byval.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=SYNC-BYVAL
; RUN: not llvm-as %t/tile-zero.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=TILE-ZERO
; RUN: not llvm-as %t/sync-zero.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=SYNC-ZERO
; RUN: not llvm-as %t/tile-load.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=TILE-LOAD
; RUN: not llvm-as %t/sync-load.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=SYNC-LOAD
; RUN: not llvm-as %t/tile-store.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=TILE-STORE
; RUN: not llvm-as %t/sync-store.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=SYNC-STORE
; RUN: not llvm-as %t/tile-gep.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=TILE-GEP
; RUN: not llvm-as %t/sync-gep.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=SYNC-GEP
; RUN: not llvm-as %t/tile-constant-gep.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=TILE-CONSTANT-GEP
; RUN: not llvm-as %t/sync-constant-gep.ll -o /dev/null 2>&1 | FileCheck %s --check-prefix=SYNC-CONSTANT-GEP
; RUN: opt -passes=verify -disable-output %t/ssa.ll
;
; Native matrix and synchronization values are unsized register resources.
; Ordinary memory objects and zero constants are invalid; SSA carriers remain valid.

;--- tile-alloca.ll
; TILE-ALLOCA: Cannot allocate unsized type
define void @tile_alloca() {
  %value = alloca target("riscv.xsai.zames.tile.int8")
  ret void
}

;--- sync-alloca.ll
; SYNC-ALLOCA: Cannot allocate unsized type
define void @sync_alloca() {
  %value = alloca target("riscv.xsai.zmasync.sync")
  ret void
}

;--- tile-byval.ll
; TILE-BYVAL: Attribute 'byval' does not support unsized types!
declare void @tile_byval(ptr byval(target("riscv.xsai.zames.tile.int32")))

;--- sync-byval.ll
; SYNC-BYVAL: Attribute 'byval' does not support unsized types!
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

;--- tile-load.ll
; TILE-LOAD: loading unsized types is not allowed
define target("riscv.xsai.zames.tile.int8") @tile_load(ptr %p) {
  %value = load target("riscv.xsai.zames.tile.int8"), ptr %p, align 1
  ret target("riscv.xsai.zames.tile.int8") %value
}

;--- sync-load.ll
; SYNC-LOAD: loading unsized types is not allowed
define target("riscv.xsai.zmasync.sync") @sync_load(ptr %p) {
  %value = load target("riscv.xsai.zmasync.sync"), ptr %p, align 1
  ret target("riscv.xsai.zmasync.sync") %value
}

;--- tile-store.ll
; TILE-STORE: storing unsized types is not allowed
define void @tile_store(ptr %p, target("riscv.xsai.zames.tile.fp16") %value) {
  store target("riscv.xsai.zames.tile.fp16") %value, ptr %p, align 1
  ret void
}

;--- sync-store.ll
; SYNC-STORE: storing unsized types is not allowed
define void @sync_store(ptr %p, target("riscv.xsai.zmasync.sync") %value) {
  store target("riscv.xsai.zmasync.sync") %value, ptr %p, align 1
  ret void
}

;--- tile-gep.ll
; TILE-GEP: base element of getelementptr must be sized
define ptr @tile_gep(ptr %p) {
  %next = getelementptr target("riscv.xsai.zames.tile.int32"), ptr %p, i64 1
  ret ptr %next
}

;--- sync-gep.ll
; SYNC-GEP: base element of getelementptr must be sized
define ptr @sync_gep(ptr %p) {
  %next = getelementptr target("riscv.xsai.zmasync.sync"), ptr %p, i64 1
  ret ptr %next
}

;--- tile-constant-gep.ll
; TILE-CONSTANT-GEP: base element of getelementptr must be sized
define ptr @tile_constant_gep() {
  ret ptr getelementptr (target("riscv.xsai.zames.tile.bf16"), ptr null, i64 1)
}

;--- sync-constant-gep.ll
; SYNC-CONSTANT-GEP: base element of getelementptr must be sized
define ptr @sync_constant_gep() {
  ret ptr getelementptr (target("riscv.xsai.zmasync.sync"), ptr null, i64 1)
}

;--- ssa.ll
define target("riscv.xsai.zames.tile.int8") @tile_ssa(i1 %condition, target("riscv.xsai.zames.tile.int8") %a, target("riscv.xsai.zames.tile.int8") %b) {
  br i1 %condition, label %left, label %right
left:
  br label %merge
right:
  br label %merge
merge:
  %value = phi target("riscv.xsai.zames.tile.int8") [ %a, %left ], [ %b, %right ]
  %result = select i1 %condition, target("riscv.xsai.zames.tile.int8") %value, target("riscv.xsai.zames.tile.int8") %b
  ret target("riscv.xsai.zames.tile.int8") %result
}

define target("riscv.xsai.zmasync.sync") @sync_ssa(i1 %condition, target("riscv.xsai.zmasync.sync") %a, target("riscv.xsai.zmasync.sync") %b) {
  br i1 %condition, label %left, label %right
left:
  br label %merge
right:
  br label %merge
merge:
  %value = phi target("riscv.xsai.zmasync.sync") [ %a, %left ], [ %b, %right ]
  %result = select i1 %condition, target("riscv.xsai.zmasync.sync") %value, target("riscv.xsai.zmasync.sync") %b
  ret target("riscv.xsai.zmasync.sync") %result
}
