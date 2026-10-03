; RUN: llc -mtriple=riscv64 -mcpu=spacemit-a100 -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=riscv64 -mattr=+v,+zvfh,+xsmtvdotii -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=riscv64 -mcpu=spacemit-a100 -verify-machineinstrs -stop-after=finalize-isel < %s | FileCheck %s --check-prefix=ISEL

; A100 inputs use one vector register and the accumulator uses two.
; Computing the dot requires LMUL=1, not the accumulator's LMUL=2.
declare <vscale x 4 x i32> @llvm.riscv.ime.vmadot.nxv4i32.nxv8i8.nxv8i8(<vscale x 4 x i32>, <vscale x 8 x i8>, <vscale x 8 x i8>)
declare <vscale x 4 x i32> @llvm.riscv.ime.vmadotu.nxv4i32.nxv8i8.nxv8i8(<vscale x 4 x i32>, <vscale x 8 x i8>, <vscale x 8 x i8>)
declare <vscale x 4 x i32> @llvm.riscv.ime.vmadotsu.nxv4i32.nxv8i8.nxv8i8(<vscale x 4 x i32>, <vscale x 8 x i8>, <vscale x 8 x i8>)
declare <vscale x 4 x i32> @llvm.riscv.ime.vmadotus.nxv4i32.nxv8i8.nxv8i8(<vscale x 4 x i32>, <vscale x 8 x i8>, <vscale x 8 x i8>)
declare <vscale x 4 x float> @llvm.riscv.ime.vfmadot.nxv4f32.nxv4f16.nxv4f16(<vscale x 4 x float>, <vscale x 4 x half>, <vscale x 4 x half>)

define <vscale x 4 x i32> @signed_dot(<vscale x 4 x i32> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b) {
; ISEL-LABEL: name: signed_dot
; ISEL-DAG: [[C:%[0-9]+]]:vrm2 = COPY $v8m2
; ISEL-DAG: [[A:%[0-9]+]]:vr = COPY $v10
; ISEL-DAG: [[B:%[0-9]+]]:vr = COPY $v11
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VMADOT_M1 [[C]], [[A]], [[B]], 3, -1 {{.*}}, 5 {{.*}}, implicit $vl, implicit $vtype
; CHECK-LABEL: signed_dot:
; CHECK: vsetvli {{.*}}, zero, e32, m1,
; CHECK-NEXT: smt.vmadot {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, i8
  %r = call <vscale x 4 x i32> @llvm.riscv.ime.vmadot.nxv4i32.nxv8i8.nxv8i8(<vscale x 4 x i32> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b)
  ret <vscale x 4 x i32> %r
}

define <vscale x 4 x i32> @unsigned_dot(<vscale x 4 x i32> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b) {
; ISEL-LABEL: name: unsigned_dot
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VMADOTU_M1
; CHECK-LABEL: unsigned_dot:
; CHECK: vsetvli {{.*}}, zero, e32, m1,
; CHECK-NEXT: smt.vmadotu {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, i8
  %r = call <vscale x 4 x i32> @llvm.riscv.ime.vmadotu.nxv4i32.nxv8i8.nxv8i8(<vscale x 4 x i32> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b)
  ret <vscale x 4 x i32> %r
}

define <vscale x 4 x i32> @signed_unsigned_dot(<vscale x 4 x i32> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b) {
; ISEL-LABEL: name: signed_unsigned_dot
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VMADOTSU_M1
; CHECK-LABEL: signed_unsigned_dot:
; CHECK: vsetvli {{.*}}, zero, e32, m1,
; CHECK-NEXT: smt.vmadotsu {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, i8
  %r = call <vscale x 4 x i32> @llvm.riscv.ime.vmadotsu.nxv4i32.nxv8i8.nxv8i8(<vscale x 4 x i32> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b)
  ret <vscale x 4 x i32> %r
}

define <vscale x 4 x i32> @unsigned_signed_dot(<vscale x 4 x i32> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b) {
; ISEL-LABEL: name: unsigned_signed_dot
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VMADOTUS_M1
; CHECK-LABEL: unsigned_signed_dot:
; CHECK: vsetvli {{.*}}, zero, e32, m1,
; CHECK-NEXT: smt.vmadotus {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, i8
  %r = call <vscale x 4 x i32> @llvm.riscv.ime.vmadotus.nxv4i32.nxv8i8.nxv8i8(<vscale x 4 x i32> %c, <vscale x 8 x i8> %a, <vscale x 8 x i8> %b)
  ret <vscale x 4 x i32> %r
}

define <vscale x 4 x float> @fp16_dot(<vscale x 4 x float> %c, <vscale x 4 x half> %a, <vscale x 4 x half> %b) {
; ISEL-LABEL: name: fp16_dot
; ISEL-DAG: [[FC:%[0-9]+]]:vrm2 = COPY $v8m2
; ISEL-DAG: [[FA:%[0-9]+]]:vr = COPY $v10
; ISEL-DAG: [[FB:%[0-9]+]]:vr = COPY $v11
; ISEL: early-clobber %{{[0-9]+}}:vrm2 = PseudoSMT_VFWMADOT_M1 [[FC]], [[FA]], [[FB]], -1 {{.*}}, 5 {{.*}}, implicit $vl, implicit $vtype
; CHECK-LABEL: fp16_dot:
; CHECK: vsetvli {{.*}}, zero, e32, m1,
; CHECK-NEXT: smt.vfwmadot {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}
  %r = call <vscale x 4 x float> @llvm.riscv.ime.vfmadot.nxv4f32.nxv4f16.nxv4f16(<vscale x 4 x float> %c, <vscale x 4 x half> %a, <vscale x 4 x half> %b)
  ret <vscale x 4 x float> %r
}
