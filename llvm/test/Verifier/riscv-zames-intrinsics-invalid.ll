; Wrong signatures must be rejected by the verifier, proving the names are
; resolved as real intrinsics (an unregistered name would be accepted as an
; ordinary external function).

; RUN: split-file %s %t
; RUN: not llvm-as %t/wrong-ret-settilem.ll -o /dev/null
; RUN: not llvm-as %t/whole-load-stride.ll -o /dev/null
; RUN: not llvm-as %t/acquire-wrong-ret.ll -o /dev/null
; RUN: not llvm-as %t/whole-store-stride.ll -o /dev/null
; RUN: not llvm-as %t/nonimm-cfg.ll -o /dev/null
; RUN: not llvm-as %t/nonimm-settilemi.ll -o /dev/null
; RUN: not llvm-as %t/nonimm-settileni.ll -o /dev/null
; RUN: not llvm-as %t/nonimm-settileki.ll -o /dev/null
; RUN: not llvm-as %t/range-settilemi-neg.ll -o /dev/null
; RUN: not llvm-as %t/range-settileni-1024.ll -o /dev/null
; RUN: not llvm-as %t/range-settileki-1024.ll -o /dev/null
; RUN: not llvm-as %t/range-msetcfg-8.ll -o /dev/null
; RUN: not llvm-as %t/range-mgetcfg-neg.ll -o /dev/null

; Note: an overload suffix that disagrees with the argument types (e.g.
; msa.triscv.ame.tile.int8t taking an int32 tile) is NOT a verifier error —
; the parser re-mangles the name from the argument types. Signature
; violations must therefore probe arity/type/immarg constraints.

;--- wrong-ret-settilem.ll
; msettilem returns void.
declare i64 @llvm.riscv.zames.msettilem(i64)

define i64 @f(i64 %m) {
  %r = call i64 @llvm.riscv.zames.msettilem(i64 %m)
  ret i64 %r
}

;--- whole-load-stride.ll
; .whole loads are pointer-only; a stride operand is not allowed.
declare target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.whole.triscv.ame.tile.int8t(ptr, i64)

define target("riscv.ame.tile.int8") @f(ptr %p, i64 %s) {
  %r = call target("riscv.ame.tile.int8") @llvm.riscv.zames.mla.whole.triscv.ame.tile.int8t(ptr %p, i64 %s)
  ret target("riscv.ame.tile.int8") %r
}

;--- acquire-wrong-ret.ll
; macquire returns void.
declare target("riscv.ame.sync") @llvm.riscv.zmasync.macquire.triscv.ame.synct(target("riscv.ame.sync"), i64)

define target("riscv.ame.sync") @f(target("riscv.ame.sync") %s, i64 %sem) {
  %r = call target("riscv.ame.sync") @llvm.riscv.zmasync.macquire.triscv.ame.synct(target("riscv.ame.sync") %s, i64 %sem)
  ret target("riscv.ame.sync") %r
}

;--- whole-store-stride.ll
; .whole stores take tile + pointer only.
declare void @llvm.riscv.zames.msa.whole.triscv.ame.tile.int8t(target("riscv.ame.tile.int8"), ptr, i64)

define void @f(target("riscv.ame.tile.int8") %t, ptr %p, i64 %s) {
  call void @llvm.riscv.zames.msa.whole.triscv.ame.tile.int8t(target("riscv.ame.tile.int8") %t, ptr %p, i64 %s)
  ret void
}

;--- nonimm-cfg.ll
; The msetcfg selector operand is an ImmArg.
declare void @llvm.riscv.zames.msetcfg(i64, i64)

define void @f(i64 %sel, i64 %payload) {
  call void @llvm.riscv.zames.msetcfg(i64 %sel, i64 %payload)
  ret void
}

;--- nonimm-settilemi.ll
; The immediate tile setters take a constant uimm10; a dynamic value is an
; ImmArg violation. Range selection (register form for >=1024) is done by
; the Buddy lowering, not the verifier.
declare void @llvm.riscv.zames.msettilemi(i64)

define void @f(i64 %m) {
  call void @llvm.riscv.zames.msettilemi(i64 %m)
  ret void
}

;--- nonimm-settileni.ll
declare void @llvm.riscv.zames.msettileni(i64)

define void @f(i64 %n) {
  call void @llvm.riscv.zames.msettileni(i64 %n)
  ret void
}

;--- nonimm-settileki.ll
declare void @llvm.riscv.zames.msettileki(i64)

define void @f(i64 %k) {
  call void @llvm.riscv.zames.msettileki(i64 %k)
  ret void
}

;--- range-settilemi-neg.ll
; The immediate tile setters encode a uimm10 field: the LLVM contract is the
; half-open range [0, 1024). Out-of-range constants must be rejected even
; though they are immediates.
declare void @llvm.riscv.zames.msettilemi(i64)

define void @f() {
  call void @llvm.riscv.zames.msettilemi(i64 -1)
  ret void
}

;--- range-settileni-1024.ll
declare void @llvm.riscv.zames.msettileni(i64)

define void @f() {
  call void @llvm.riscv.zames.msettileni(i64 1024)
  ret void
}

;--- range-settileki-1024.ll
declare void @llvm.riscv.zames.msettileki(i64)

define void @f() {
  call void @llvm.riscv.zames.msettileki(i64 1024)
  ret void
}

;--- range-msetcfg-8.ll
; The config selector is a 3-bit field: the LLVM contract is [0, 8). The
; payload argument is a full GPR value and is intentionally unconstrained.
declare void @llvm.riscv.zames.msetcfg(i64, i64)

define void @f(i64 %payload) {
  call void @llvm.riscv.zames.msetcfg(i64 8, i64 %payload)
  ret void
}

;--- range-mgetcfg-neg.ll
declare i64 @llvm.riscv.zames.mgetcfg(i64)

define i64 @f() {
  %r = call i64 @llvm.riscv.zames.mgetcfg(i64 -1)
  ret i64 %r
}
