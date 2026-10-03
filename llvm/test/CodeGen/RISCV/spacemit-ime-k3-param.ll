; RUN: llc -mtriple=riscv64 -mcpu=spacemit-a100 -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=riscv64 -mattr=+v,+zvfh,+xsmtvdotii -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=riscv64 -mcpu=spacemit-a100 -verify-machineinstrs -stop-after=finalize-isel < %s | FileCheck %s --check-prefix=ISEL

; Native A100 tiles require VLEN=1024: HP has 64 fp16 lanes in one VR,
; SP has 64 int32 lanes in VRM2 and 256 int8 elements in its A pair.
; v0/v1 carry HP scale groups or SP recovery parameters, not RVV masks.

declare <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half>, <vscale x 8 x i8>, <vscale x 8 x i8>, <vscale x 4 x half>, i32 immarg)

define <vscale x 4 x half> @signed_hp(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %params) {
; ISEL-LABEL: name: signed_hp
; ISEL-DAG: [[A:%[0-9]+]]:zzz_vrsmtnov0v1 = COPY $v9
; ISEL-DAG: [[B:%[0-9]+]]:zzz_vrsmtnov0v1 = COPY $v10
; ISEL: [[P:%[0-9]+]]:zzz_vrsmtv0v1 = COPY
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VMADOT_HP_M1 %{{[0-9]+}}, [[A]], [[B]], [[P]], 7, 3, -1 {{.*}}, 4
; CHECK-LABEL: signed_hp:
; CHECK: vsetvli {{.*}}, zero, e16, m1,
; CHECK: smt.vmadot.hp {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, {{v[01]}}, 7, i8
%r = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %params, i32 7)
ret <vscale x 4 x half> %r
}

declare <vscale x 4 x half> @llvm.riscv.ime.vmadotu.hp(<vscale x 4 x half>, <vscale x 8 x i8>, <vscale x 8 x i8>, <vscale x 4 x half>, i32 immarg)

define <vscale x 4 x half> @unsigned_hp(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %params) {
; ISEL-LABEL: name: unsigned_hp
; ISEL: PseudoSMT_VMADOTU_HP_M1
; CHECK-LABEL: unsigned_hp:
; CHECK: vsetvli {{.*}}, zero, e16, m1,
; CHECK: smt.vmadotu.hp {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, {{v[01]}}, 7, i8
%r = call <vscale x 4 x half> @llvm.riscv.ime.vmadotu.hp(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %params, i32 7)
ret <vscale x 4 x half> %r
}

declare <vscale x 4 x half> @llvm.riscv.ime.vmadotsu.hp(<vscale x 4 x half>, <vscale x 8 x i8>, <vscale x 8 x i8>, <vscale x 4 x half>, i32 immarg)

define <vscale x 4 x half> @signed_unsigned_hp(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %params) {
; ISEL-LABEL: name: signed_unsigned_hp
; ISEL: PseudoSMT_VMADOTSU_HP_M1
; CHECK-LABEL: signed_unsigned_hp:
; CHECK: vsetvli {{.*}}, zero, e16, m1,
; CHECK: smt.vmadotsu.hp {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, {{v[01]}}, 7, i8
%r = call <vscale x 4 x half> @llvm.riscv.ime.vmadotsu.hp(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %params, i32 7)
ret <vscale x 4 x half> %r
}

declare <vscale x 4 x half> @llvm.riscv.ime.vmadotus.hp(<vscale x 4 x half>, <vscale x 8 x i8>, <vscale x 8 x i8>, <vscale x 4 x half>, i32 immarg)

define <vscale x 4 x half> @unsigned_signed_hp(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %params) {
; ISEL-LABEL: name: unsigned_signed_hp
; ISEL: PseudoSMT_VMADOTUS_HP_M1
; CHECK-LABEL: unsigned_signed_hp:
; CHECK: vsetvli {{.*}}, zero, e16, m1,
; CHECK: smt.vmadotus.hp {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, {{v[01]}}, 7, i8
%r = call <vscale x 4 x half> @llvm.riscv.ime.vmadotus.hp(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %params, i32 7)
ret <vscale x 4 x half> %r
}

declare <vscale x 4 x i32> @llvm.riscv.ime.vmadot.sp(<vscale x 4 x i32>, <vscale x 16 x i8>, <vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)

define <vscale x 4 x i32> @signed_sp(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b, <vscale x 8 x i8> %params) {
; ISEL-LABEL: name: signed_sp
; ISEL-DAG: [[A:%[0-9]+]]:vrm2nov0 = COPY
; ISEL-DAG: [[B:%[0-9]+]]:zzz_vrsmtnov0v1 = COPY
; ISEL: [[P:%[0-9]+]]:zzz_vrsmtv0v1 = COPY
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VMADOT_SP_M1 %{{[0-9]+}}, [[A]], [[B]], [[P]], 3, 3, -1 {{.*}}, 5
; CHECK-LABEL: signed_sp:
; CHECK: vsetvli {{.*}}, zero, e32, m1,
; CHECK: smt.vmadot.sp {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, {{v[01]}}, 3, i8
%r = call <vscale x 4 x i32> @llvm.riscv.ime.vmadot.sp(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b, <vscale x 8 x i8> %params, i32 3)
ret <vscale x 4 x i32> %r
}

declare <vscale x 4 x i32> @llvm.riscv.ime.vmadotu.sp(<vscale x 4 x i32>, <vscale x 16 x i8>, <vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)

define <vscale x 4 x i32> @unsigned_sp(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b, <vscale x 8 x i8> %params) {
; ISEL-LABEL: name: unsigned_sp
; ISEL: PseudoSMT_VMADOTU_SP_M1
; CHECK-LABEL: unsigned_sp:
; CHECK: vsetvli {{.*}}, zero, e32, m1,
; CHECK: smt.vmadotu.sp {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, {{v[01]}}, 3, i8
%r = call <vscale x 4 x i32> @llvm.riscv.ime.vmadotu.sp(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b, <vscale x 8 x i8> %params, i32 3)
ret <vscale x 4 x i32> %r
}

declare <vscale x 4 x i32> @llvm.riscv.ime.vmadotsu.sp(<vscale x 4 x i32>, <vscale x 16 x i8>, <vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)

define <vscale x 4 x i32> @signed_unsigned_sp(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b, <vscale x 8 x i8> %params) {
; ISEL-LABEL: name: signed_unsigned_sp
; ISEL: PseudoSMT_VMADOTSU_SP_M1
; CHECK-LABEL: signed_unsigned_sp:
; CHECK: vsetvli {{.*}}, zero, e32, m1,
; CHECK: smt.vmadotsu.sp {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, {{v[01]}}, 3, i8
%r = call <vscale x 4 x i32> @llvm.riscv.ime.vmadotsu.sp(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b, <vscale x 8 x i8> %params, i32 3)
ret <vscale x 4 x i32> %r
}

declare <vscale x 4 x i32> @llvm.riscv.ime.vmadotus.sp(<vscale x 4 x i32>, <vscale x 16 x i8>, <vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)

define <vscale x 4 x i32> @unsigned_signed_sp(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b, <vscale x 8 x i8> %params) {
; ISEL-LABEL: name: unsigned_signed_sp
; ISEL: PseudoSMT_VMADOTUS_SP_M1
; CHECK-LABEL: unsigned_signed_sp:
; CHECK: vsetvli {{.*}}, zero, e32, m1,
; CHECK: smt.vmadotus.sp {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, {{v[01]}}, 3, i8
%r = call <vscale x 4 x i32> @llvm.riscv.ime.vmadotus.sp(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b, <vscale x 8 x i8> %params, i32 3)
ret <vscale x 4 x i32> %r
}

define <vscale x 4 x half> @hp_all_groups(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p) {
; CHECK-LABEL: hp_all_groups:
; CHECK: vsetvli {{.*}}, zero, e16, m1,
; ISEL-LABEL: name: hp_all_groups
; CHECK: smt.vmadot.hp {{.*}}, 0, i8
%c0 = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p, i32 0)
; CHECK: smt.vmadot.hp {{.*}}, 1, i8
%c1 = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c0, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p, i32 1)
; CHECK: smt.vmadot.hp {{.*}}, 2, i8
%c2 = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c1, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p, i32 2)
; CHECK: smt.vmadot.hp {{.*}}, 3, i8
%c3 = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c2, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p, i32 3)
; CHECK: smt.vmadot.hp {{.*}}, 4, i8
%c4 = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c3, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p, i32 4)
; CHECK: smt.vmadot.hp {{.*}}, 5, i8
%c5 = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c4, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p, i32 5)
; CHECK: smt.vmadot.hp {{.*}}, 6, i8
%c6 = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c5, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p, i32 6)
; CHECK: smt.vmadot.hp {{.*}}, 7, i8
%c7 = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c6, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p, i32 7)
ret <vscale x 4 x half> %c7
}

define <vscale x 4 x half> @hp_two_params(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p0, <vscale x 4 x half> %p1) {
; CHECK-LABEL: hp_two_params:
; ISEL-LABEL: name: hp_two_params
; CHECK: smt.vmadot.hp {{.*}}, {{v[01]}}, 0, i8
%c0 = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p0, i32 0)
; CHECK: smt.vmadot.hp {{.*}}, {{v[01]}}, 1, i8
%c1 = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c0, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p1, i32 1)
; CHECK: smt.vmadot.hp {{.*}}, {{v[01]}}, 2, i8
%c2 = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c1, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p0, i32 2)
ret <vscale x 4 x half> %c2
}

; A matrix source and the scale/parameter operand can have identical SSA bits.
; They must still occupy different physical registers: the matrix source
; classes exclude both v0 and v1, including the v0m2 pair for SP A.
define <vscale x 4 x half> @hp_b_as_scales(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b) {
; CHECK-LABEL: hp_b_as_scales:
; CHECK: smt.vmadot.hp {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, {{v[01]}}, 0, i8
; ISEL-LABEL: name: hp_b_as_scales
; ISEL: {{%[0-9]+}}:zzz_vrsmtv0v1 = COPY
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VMADOT_HP_M1
  %p = bitcast <vscale x 8 x i8> %b to <vscale x 4 x half>
  %r = call <vscale x 4 x half> @llvm.riscv.ime.vmadot.hp(<vscale x 4 x half> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b, <vscale x 4 x half> %p, i32 0)
  ret <vscale x 4 x half> %r
}

define <vscale x 4 x i32> @sp_b_as_params(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b) {
; CHECK-LABEL: sp_b_as_params:
; CHECK: smt.vmadot.sp {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, {{v[01]}}, 0, i8
; ISEL-LABEL: name: sp_b_as_params
; ISEL: {{%[0-9]+}}:zzz_vrsmtv0v1 = COPY
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VMADOT_SP_M1
  %r = call <vscale x 4 x i32> @llvm.riscv.ime.vmadot.sp(<vscale x 4 x i32> %c, <vscale x 16 x i8> %a, <vscale x 8 x i8> %b, <vscale x 8 x i8> %b, i32 0)
  ret <vscale x 4 x i32> %r
}
