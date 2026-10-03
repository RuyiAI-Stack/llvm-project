; RUN: llc -mtriple=riscv64 -mcpu=spacemit-a100 -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -O0 -mtriple=riscv64 -mcpu=spacemit-a100 -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=riscv64 -mcpu=spacemit-a100 -stop-after=finalize-isel -verify-machineinstrs < %s | FileCheck %s --check-prefix=ISEL
; RUN: not --crash llc -mtriple=riscv64 -mattr=+v,+zvl1024b < %s -o /dev/null 2>&1 | FileCheck %s --check-prefix=NO-EXT
; NO-EXT: Cannot select: intrinsic %llvm.riscv.ime.vpack

; Narrowing uses destination SEW; pack/upack double the register group while keeping LMUL=1.
; Early-clobber prevents destination/source overlap for all six transforms.

declare <vscale x 16 x i8> @llvm.riscv.ime.vpack.nxv16i8(<vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
declare <vscale x 8 x i16> @llvm.riscv.ime.vpack.nxv8i16(<vscale x 4 x i16>, <vscale x 4 x i16>, i32 immarg)
declare <vscale x 4 x i32> @llvm.riscv.ime.vpack.nxv4i32(<vscale x 2 x i32>, <vscale x 2 x i32>, i32 immarg)
declare <vscale x 2 x i64> @llvm.riscv.ime.vpack.nxv2i64(<vscale x 1 x i64>, <vscale x 1 x i64>, i32 immarg)
declare <vscale x 16 x i8> @llvm.riscv.ime.vupack.nxv16i8(<vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
declare <vscale x 8 x i16> @llvm.riscv.ime.vupack.nxv8i16(<vscale x 4 x i16>, <vscale x 4 x i16>, i32 immarg)
declare <vscale x 4 x i32> @llvm.riscv.ime.vupack.nxv4i32(<vscale x 2 x i32>, <vscale x 2 x i32>, i32 immarg)
declare <vscale x 2 x i64> @llvm.riscv.ime.vupack.nxv2i64(<vscale x 1 x i64>, <vscale x 1 x i64>, i32 immarg)
declare <vscale x 8 x i8> @llvm.riscv.ime.vnpack.nxv4i16(<vscale x 4 x i16>, <vscale x 4 x i16>, i32 immarg)
declare <vscale x 4 x i16> @llvm.riscv.ime.vnpack.nxv2i32(<vscale x 2 x i32>, <vscale x 2 x i32>, i32 immarg)
declare <vscale x 2 x i32> @llvm.riscv.ime.vnpack.nxv1i64(<vscale x 1 x i64>, <vscale x 1 x i64>, i32 immarg)
declare <vscale x 8 x i8> @llvm.riscv.ime.vnspack.nxv4i16(<vscale x 4 x i16>, <vscale x 4 x i16>, i32 immarg)
declare <vscale x 4 x i16> @llvm.riscv.ime.vnspack.nxv2i32(<vscale x 2 x i32>, <vscale x 2 x i32>, i32 immarg)
declare <vscale x 2 x i32> @llvm.riscv.ime.vnspack.nxv1i64(<vscale x 1 x i64>, <vscale x 1 x i64>, i32 immarg)
declare <vscale x 8 x i8> @llvm.riscv.ime.vnpack4(<vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
declare <vscale x 8 x i8> @llvm.riscv.ime.vnspack4(<vscale x 8 x i8>, <vscale x 8 x i8>, i32 immarg)
; CHECK-LABEL: c_vpack_8_0:
; CHECK: vsetvli {{.*}}, zero, e8, m1
; CHECK: smt.vpack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vpack_8_0
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VPACK_VV_M1 {{.*}}, 0, -1 {{.*}}, 3 {{.*}}, implicit $vl, implicit $vtype
define void @c_vpack_8_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 8 x i8>, ptr %a, align 1
  %vb = load <vscale x 8 x i8>, ptr %b, align 1
  %r = call <vscale x 16 x i8> @llvm.riscv.ime.vpack.nxv16i8(<vscale x 8 x i8> %va, <vscale x 8 x i8> %vb, i32 0)
  store <vscale x 16 x i8> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vpack_8_3:
; CHECK: vsetvli {{.*}}, zero, e8, m1
; CHECK: smt.vpack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vpack_8_3
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VPACK_VV_M1 {{.*}}, 3, -1 {{.*}}, 3 {{.*}}, implicit $vl, implicit $vtype
define void @c_vpack_8_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 8 x i8>, ptr %a, align 1
  %vb = load <vscale x 8 x i8>, ptr %b, align 1
  %r = call <vscale x 16 x i8> @llvm.riscv.ime.vpack.nxv16i8(<vscale x 8 x i8> %va, <vscale x 8 x i8> %vb, i32 3)
  store <vscale x 16 x i8> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vpack_16_0:
; CHECK: vsetvli {{.*}}, zero, e16, m1
; CHECK: smt.vpack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vpack_16_0
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VPACK_VV_M1 {{.*}}, 0, -1 {{.*}}, 4 {{.*}}, implicit $vl, implicit $vtype
define void @c_vpack_16_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 4 x i16>, ptr %a, align 1
  %vb = load <vscale x 4 x i16>, ptr %b, align 1
  %r = call <vscale x 8 x i16> @llvm.riscv.ime.vpack.nxv8i16(<vscale x 4 x i16> %va, <vscale x 4 x i16> %vb, i32 0)
  store <vscale x 8 x i16> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vpack_16_3:
; CHECK: vsetvli {{.*}}, zero, e16, m1
; CHECK: smt.vpack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vpack_16_3
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VPACK_VV_M1 {{.*}}, 3, -1 {{.*}}, 4 {{.*}}, implicit $vl, implicit $vtype
define void @c_vpack_16_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 4 x i16>, ptr %a, align 1
  %vb = load <vscale x 4 x i16>, ptr %b, align 1
  %r = call <vscale x 8 x i16> @llvm.riscv.ime.vpack.nxv8i16(<vscale x 4 x i16> %va, <vscale x 4 x i16> %vb, i32 3)
  store <vscale x 8 x i16> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vpack_32_0:
; CHECK: vsetvli {{.*}}, zero, e32, m1
; CHECK: smt.vpack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vpack_32_0
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VPACK_VV_M1 {{.*}}, 0, -1 {{.*}}, 5 {{.*}}, implicit $vl, implicit $vtype
define void @c_vpack_32_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 2 x i32>, ptr %a, align 1
  %vb = load <vscale x 2 x i32>, ptr %b, align 1
  %r = call <vscale x 4 x i32> @llvm.riscv.ime.vpack.nxv4i32(<vscale x 2 x i32> %va, <vscale x 2 x i32> %vb, i32 0)
  store <vscale x 4 x i32> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vpack_32_3:
; CHECK: vsetvli {{.*}}, zero, e32, m1
; CHECK: smt.vpack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vpack_32_3
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VPACK_VV_M1 {{.*}}, 3, -1 {{.*}}, 5 {{.*}}, implicit $vl, implicit $vtype
define void @c_vpack_32_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 2 x i32>, ptr %a, align 1
  %vb = load <vscale x 2 x i32>, ptr %b, align 1
  %r = call <vscale x 4 x i32> @llvm.riscv.ime.vpack.nxv4i32(<vscale x 2 x i32> %va, <vscale x 2 x i32> %vb, i32 3)
  store <vscale x 4 x i32> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vpack_64_0:
; CHECK: vsetvli {{.*}}, zero, e64, m1
; CHECK: smt.vpack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vpack_64_0
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VPACK_VV_M1 {{.*}}, 0, -1 {{.*}}, 6 {{.*}}, implicit $vl, implicit $vtype
define void @c_vpack_64_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 1 x i64>, ptr %a, align 1
  %vb = load <vscale x 1 x i64>, ptr %b, align 1
  %r = call <vscale x 2 x i64> @llvm.riscv.ime.vpack.nxv2i64(<vscale x 1 x i64> %va, <vscale x 1 x i64> %vb, i32 0)
  store <vscale x 2 x i64> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vpack_64_3:
; CHECK: vsetvli {{.*}}, zero, e64, m1
; CHECK: smt.vpack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vpack_64_3
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VPACK_VV_M1 {{.*}}, 3, -1 {{.*}}, 6 {{.*}}, implicit $vl, implicit $vtype
define void @c_vpack_64_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 1 x i64>, ptr %a, align 1
  %vb = load <vscale x 1 x i64>, ptr %b, align 1
  %r = call <vscale x 2 x i64> @llvm.riscv.ime.vpack.nxv2i64(<vscale x 1 x i64> %va, <vscale x 1 x i64> %vb, i32 3)
  store <vscale x 2 x i64> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vupack_8_0:
; CHECK: vsetvli {{.*}}, zero, e8, m1
; CHECK: smt.vupack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vupack_8_0
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VUPACK_VV_M1 {{.*}}, 0, -1 {{.*}}, 3 {{.*}}, implicit $vl, implicit $vtype
define void @c_vupack_8_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 8 x i8>, ptr %a, align 1
  %vb = load <vscale x 8 x i8>, ptr %b, align 1
  %r = call <vscale x 16 x i8> @llvm.riscv.ime.vupack.nxv16i8(<vscale x 8 x i8> %va, <vscale x 8 x i8> %vb, i32 0)
  store <vscale x 16 x i8> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vupack_8_3:
; CHECK: vsetvli {{.*}}, zero, e8, m1
; CHECK: smt.vupack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vupack_8_3
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VUPACK_VV_M1 {{.*}}, 3, -1 {{.*}}, 3 {{.*}}, implicit $vl, implicit $vtype
define void @c_vupack_8_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 8 x i8>, ptr %a, align 1
  %vb = load <vscale x 8 x i8>, ptr %b, align 1
  %r = call <vscale x 16 x i8> @llvm.riscv.ime.vupack.nxv16i8(<vscale x 8 x i8> %va, <vscale x 8 x i8> %vb, i32 3)
  store <vscale x 16 x i8> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vupack_16_0:
; CHECK: vsetvli {{.*}}, zero, e16, m1
; CHECK: smt.vupack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vupack_16_0
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VUPACK_VV_M1 {{.*}}, 0, -1 {{.*}}, 4 {{.*}}, implicit $vl, implicit $vtype
define void @c_vupack_16_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 4 x i16>, ptr %a, align 1
  %vb = load <vscale x 4 x i16>, ptr %b, align 1
  %r = call <vscale x 8 x i16> @llvm.riscv.ime.vupack.nxv8i16(<vscale x 4 x i16> %va, <vscale x 4 x i16> %vb, i32 0)
  store <vscale x 8 x i16> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vupack_16_3:
; CHECK: vsetvli {{.*}}, zero, e16, m1
; CHECK: smt.vupack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vupack_16_3
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VUPACK_VV_M1 {{.*}}, 3, -1 {{.*}}, 4 {{.*}}, implicit $vl, implicit $vtype
define void @c_vupack_16_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 4 x i16>, ptr %a, align 1
  %vb = load <vscale x 4 x i16>, ptr %b, align 1
  %r = call <vscale x 8 x i16> @llvm.riscv.ime.vupack.nxv8i16(<vscale x 4 x i16> %va, <vscale x 4 x i16> %vb, i32 3)
  store <vscale x 8 x i16> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vupack_32_0:
; CHECK: vsetvli {{.*}}, zero, e32, m1
; CHECK: smt.vupack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vupack_32_0
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VUPACK_VV_M1 {{.*}}, 0, -1 {{.*}}, 5 {{.*}}, implicit $vl, implicit $vtype
define void @c_vupack_32_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 2 x i32>, ptr %a, align 1
  %vb = load <vscale x 2 x i32>, ptr %b, align 1
  %r = call <vscale x 4 x i32> @llvm.riscv.ime.vupack.nxv4i32(<vscale x 2 x i32> %va, <vscale x 2 x i32> %vb, i32 0)
  store <vscale x 4 x i32> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vupack_32_3:
; CHECK: vsetvli {{.*}}, zero, e32, m1
; CHECK: smt.vupack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vupack_32_3
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VUPACK_VV_M1 {{.*}}, 3, -1 {{.*}}, 5 {{.*}}, implicit $vl, implicit $vtype
define void @c_vupack_32_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 2 x i32>, ptr %a, align 1
  %vb = load <vscale x 2 x i32>, ptr %b, align 1
  %r = call <vscale x 4 x i32> @llvm.riscv.ime.vupack.nxv4i32(<vscale x 2 x i32> %va, <vscale x 2 x i32> %vb, i32 3)
  store <vscale x 4 x i32> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vupack_64_0:
; CHECK: vsetvli {{.*}}, zero, e64, m1
; CHECK: smt.vupack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vupack_64_0
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VUPACK_VV_M1 {{.*}}, 0, -1 {{.*}}, 6 {{.*}}, implicit $vl, implicit $vtype
define void @c_vupack_64_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 1 x i64>, ptr %a, align 1
  %vb = load <vscale x 1 x i64>, ptr %b, align 1
  %r = call <vscale x 2 x i64> @llvm.riscv.ime.vupack.nxv2i64(<vscale x 1 x i64> %va, <vscale x 1 x i64> %vb, i32 0)
  store <vscale x 2 x i64> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vupack_64_3:
; CHECK: vsetvli {{.*}}, zero, e64, m1
; CHECK: smt.vupack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vupack_64_3
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VUPACK_VV_M1 {{.*}}, 3, -1 {{.*}}, 6 {{.*}}, implicit $vl, implicit $vtype
define void @c_vupack_64_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 1 x i64>, ptr %a, align 1
  %vb = load <vscale x 1 x i64>, ptr %b, align 1
  %r = call <vscale x 2 x i64> @llvm.riscv.ime.vupack.nxv2i64(<vscale x 1 x i64> %va, <vscale x 1 x i64> %vb, i32 3)
  store <vscale x 2 x i64> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnpack_8_0:
; CHECK: vsetvli {{.*}}, zero, e8, m1
; CHECK: smt.vnpack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vnpack_8_0
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNPACK_VV_M1 {{.*}}, 0, -1 {{.*}}, 3 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnpack_8_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 4 x i16>, ptr %a, align 1
  %vb = load <vscale x 4 x i16>, ptr %b, align 1
  %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnpack.nxv4i16(<vscale x 4 x i16> %va, <vscale x 4 x i16> %vb, i32 0)
  store <vscale x 8 x i8> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnpack_8_3:
; CHECK: vsetvli {{.*}}, zero, e8, m1
; CHECK: smt.vnpack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vnpack_8_3
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNPACK_VV_M1 {{.*}}, 3, -1 {{.*}}, 3 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnpack_8_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 4 x i16>, ptr %a, align 1
  %vb = load <vscale x 4 x i16>, ptr %b, align 1
  %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnpack.nxv4i16(<vscale x 4 x i16> %va, <vscale x 4 x i16> %vb, i32 3)
  store <vscale x 8 x i8> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnpack_16_0:
; CHECK: vsetvli {{.*}}, zero, e16, m1
; CHECK: smt.vnpack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vnpack_16_0
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNPACK_VV_M1 {{.*}}, 0, -1 {{.*}}, 4 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnpack_16_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 2 x i32>, ptr %a, align 1
  %vb = load <vscale x 2 x i32>, ptr %b, align 1
  %r = call <vscale x 4 x i16> @llvm.riscv.ime.vnpack.nxv2i32(<vscale x 2 x i32> %va, <vscale x 2 x i32> %vb, i32 0)
  store <vscale x 4 x i16> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnpack_16_3:
; CHECK: vsetvli {{.*}}, zero, e16, m1
; CHECK: smt.vnpack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vnpack_16_3
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNPACK_VV_M1 {{.*}}, 3, -1 {{.*}}, 4 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnpack_16_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 2 x i32>, ptr %a, align 1
  %vb = load <vscale x 2 x i32>, ptr %b, align 1
  %r = call <vscale x 4 x i16> @llvm.riscv.ime.vnpack.nxv2i32(<vscale x 2 x i32> %va, <vscale x 2 x i32> %vb, i32 3)
  store <vscale x 4 x i16> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnpack_32_0:
; CHECK: vsetvli {{.*}}, zero, e32, m1
; CHECK: smt.vnpack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vnpack_32_0
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNPACK_VV_M1 {{.*}}, 0, -1 {{.*}}, 5 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnpack_32_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 1 x i64>, ptr %a, align 1
  %vb = load <vscale x 1 x i64>, ptr %b, align 1
  %r = call <vscale x 2 x i32> @llvm.riscv.ime.vnpack.nxv1i64(<vscale x 1 x i64> %va, <vscale x 1 x i64> %vb, i32 0)
  store <vscale x 2 x i32> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnpack_32_3:
; CHECK: vsetvli {{.*}}, zero, e32, m1
; CHECK: smt.vnpack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vnpack_32_3
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNPACK_VV_M1 {{.*}}, 3, -1 {{.*}}, 5 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnpack_32_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 1 x i64>, ptr %a, align 1
  %vb = load <vscale x 1 x i64>, ptr %b, align 1
  %r = call <vscale x 2 x i32> @llvm.riscv.ime.vnpack.nxv1i64(<vscale x 1 x i64> %va, <vscale x 1 x i64> %vb, i32 3)
  store <vscale x 2 x i32> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnspack_8_0:
; CHECK: vsetvli {{.*}}, zero, e8, m1
; CHECK: smt.vnspack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vnspack_8_0
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNSPACK_VV_M1 {{.*}}, 0, -1 {{.*}}, 3 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnspack_8_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 4 x i16>, ptr %a, align 1
  %vb = load <vscale x 4 x i16>, ptr %b, align 1
  %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnspack.nxv4i16(<vscale x 4 x i16> %va, <vscale x 4 x i16> %vb, i32 0)
  store <vscale x 8 x i8> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnspack_8_3:
; CHECK: vsetvli {{.*}}, zero, e8, m1
; CHECK: smt.vnspack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vnspack_8_3
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNSPACK_VV_M1 {{.*}}, 3, -1 {{.*}}, 3 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnspack_8_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 4 x i16>, ptr %a, align 1
  %vb = load <vscale x 4 x i16>, ptr %b, align 1
  %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnspack.nxv4i16(<vscale x 4 x i16> %va, <vscale x 4 x i16> %vb, i32 3)
  store <vscale x 8 x i8> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnspack_16_0:
; CHECK: vsetvli {{.*}}, zero, e16, m1
; CHECK: smt.vnspack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vnspack_16_0
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNSPACK_VV_M1 {{.*}}, 0, -1 {{.*}}, 4 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnspack_16_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 2 x i32>, ptr %a, align 1
  %vb = load <vscale x 2 x i32>, ptr %b, align 1
  %r = call <vscale x 4 x i16> @llvm.riscv.ime.vnspack.nxv2i32(<vscale x 2 x i32> %va, <vscale x 2 x i32> %vb, i32 0)
  store <vscale x 4 x i16> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnspack_16_3:
; CHECK: vsetvli {{.*}}, zero, e16, m1
; CHECK: smt.vnspack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vnspack_16_3
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNSPACK_VV_M1 {{.*}}, 3, -1 {{.*}}, 4 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnspack_16_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 2 x i32>, ptr %a, align 1
  %vb = load <vscale x 2 x i32>, ptr %b, align 1
  %r = call <vscale x 4 x i16> @llvm.riscv.ime.vnspack.nxv2i32(<vscale x 2 x i32> %va, <vscale x 2 x i32> %vb, i32 3)
  store <vscale x 4 x i16> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnspack_32_0:
; CHECK: vsetvli {{.*}}, zero, e32, m1
; CHECK: smt.vnspack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vnspack_32_0
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNSPACK_VV_M1 {{.*}}, 0, -1 {{.*}}, 5 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnspack_32_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 1 x i64>, ptr %a, align 1
  %vb = load <vscale x 1 x i64>, ptr %b, align 1
  %r = call <vscale x 2 x i32> @llvm.riscv.ime.vnspack.nxv1i64(<vscale x 1 x i64> %va, <vscale x 1 x i64> %vb, i32 0)
  store <vscale x 2 x i32> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnspack_32_3:
; CHECK: vsetvli {{.*}}, zero, e32, m1
; CHECK: smt.vnspack.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vnspack_32_3
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNSPACK_VV_M1 {{.*}}, 3, -1 {{.*}}, 5 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnspack_32_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 1 x i64>, ptr %a, align 1
  %vb = load <vscale x 1 x i64>, ptr %b, align 1
  %r = call <vscale x 2 x i32> @llvm.riscv.ime.vnspack.nxv1i64(<vscale x 1 x i64> %va, <vscale x 1 x i64> %vb, i32 3)
  store <vscale x 2 x i32> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnpack4_8_0:
; CHECK: vsetvli {{.*}}, zero, e8, m1
; CHECK: smt.vnpack4.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vnpack4_8_0
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNPACK4_VV_M1 {{.*}}, 0, -1 {{.*}}, 3 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnpack4_8_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 8 x i8>, ptr %a, align 1
  %vb = load <vscale x 8 x i8>, ptr %b, align 1
  %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnpack4(<vscale x 8 x i8> %va, <vscale x 8 x i8> %vb, i32 0)
  store <vscale x 8 x i8> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnpack4_8_3:
; CHECK: vsetvli {{.*}}, zero, e8, m1
; CHECK: smt.vnpack4.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vnpack4_8_3
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNPACK4_VV_M1 {{.*}}, 3, -1 {{.*}}, 3 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnpack4_8_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 8 x i8>, ptr %a, align 1
  %vb = load <vscale x 8 x i8>, ptr %b, align 1
  %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnpack4(<vscale x 8 x i8> %va, <vscale x 8 x i8> %vb, i32 3)
  store <vscale x 8 x i8> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnspack4_8_0:
; CHECK: vsetvli {{.*}}, zero, e8, m1
; CHECK: smt.vnspack4.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 0
; ISEL-LABEL: name: c_vnspack4_8_0
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNSPACK4_VV_M1 {{.*}}, 0, -1 {{.*}}, 3 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnspack4_8_0(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 8 x i8>, ptr %a, align 1
  %vb = load <vscale x 8 x i8>, ptr %b, align 1
  %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnspack4(<vscale x 8 x i8> %va, <vscale x 8 x i8> %vb, i32 0)
  store <vscale x 8 x i8> %r, ptr %out, align 1
  ret void
}

; CHECK-LABEL: c_vnspack4_8_3:
; CHECK: vsetvli {{.*}}, zero, e8, m1
; CHECK: smt.vnspack4.vv {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, 3
; ISEL-LABEL: name: c_vnspack4_8_3
; ISEL: early-clobber %{{[0-9]+}}:vr = PseudoSMT_VNSPACK4_VV_M1 {{.*}}, 3, -1 {{.*}}, 3 {{.*}}, implicit $vl, implicit $vtype
define void @c_vnspack4_8_3(ptr %out, ptr %a, ptr %b) {
  %va = load <vscale x 8 x i8>, ptr %a, align 1
  %vb = load <vscale x 8 x i8>, ptr %b, align 1
  %r = call <vscale x 8 x i8> @llvm.riscv.ime.vnspack4(<vscale x 8 x i8> %va, <vscale x 8 x i8> %vb, i32 3)
  store <vscale x 8 x i8> %r, ptr %out, align 1
  ret void
}
