; RUN: llc -mtriple=riscv64 -mattr=+xboscame,-v -verify-machineinstrs < %s | FileCheck %s --implicit-check-not=mmve --implicit-check-not=vsetvli
; RUN: llc -mtriple=riscv64 -mattr=+xboscame,+v -verify-machineinstrs < %s | FileCheck %s --implicit-check-not=mmve --implicit-check-not=vsetvli
; RUN: llc -mtriple=riscv64 -mattr=+xboscame,+v -verify-machineinstrs -filetype=obj < %s -o %t.o

; Configuration stays adjacent to its consuming operation through scheduling.
; In particular B1 must not be loaded/configured before MMA0, despite noalias.
; The two independent output values must use independently allocated ACCs;
; the common A tile remains live across both MMAs without a matrix copy.
define void @two_acc(ptr noalias readonly %a, ptr noalias readonly %b0,
                     ptr noalias readonly %b1, ptr noalias %c0,
                     ptr noalias %c1) {
; CHECK-LABEL: two_acc:
; CHECK: msettilem zero,
; CHECK-NEXT: msettilen zero,
; CHECK-NEXT: msettype zero,
; CHECK-NEXT: mlce32.m [[C0:acc[0-7]]],
; CHECK: mlce32.m [[C1:acc[0-7]]],
; CHECK: msettilem zero,
; CHECK-NEXT: msettilek zero,
; CHECK-NEXT: msettype zero,
; CHECK-NEXT: mlae8.m [[A:tr[0-7]]],
; CHECK: msettilen zero,
; CHECK-NEXT: msettilek zero,
; CHECK-NEXT: msettype zero,
; CHECK-NEXT: mlbe8.m [[B0:tr[0-7]]],
; CHECK: msettilem zero,
; CHECK-NEXT: msettilen zero,
; CHECK-NEXT: msettilek zero,
; CHECK-NEXT: msettype zero,
; CHECK-NEXT: mqma.b.mm [[C0]], [[A]], [[B0]]
; CHECK: mlbe8.m [[B1:tr[0-7]]],
; CHECK: mqma.b.mm [[C1]], [[A]], [[B1]]
; CHECK: msce32.m [[C0]],
; CHECK: msce32.m [[C1]],
  %x0 = call <vscale x 32 x i32> @llvm.riscv.bosc.ordered.load.acc.nxv32i32(ptr %c0, i64 3072, i64 32, i64 64, i64 65602)
  %x1 = call <vscale x 32 x i32> @llvm.riscv.bosc.ordered.load.acc.nxv32i32(ptr %c1, i64 3072, i64 32, i64 64, i64 65602)
  %av = call <vscale x 128 x i8> @llvm.riscv.bosc.ordered.load.a.nxv128i8(ptr %a, i64 768, i64 32, i64 64, i64 65552)
  %bv0 = call <vscale x 128 x i8> @llvm.riscv.bosc.ordered.load.b.nxv128i8(ptr %b0, i64 768, i64 64, i64 64, i64 65552)
  %r0 = call <vscale x 32 x i32> @llvm.riscv.bosc.ordered.mma.nxv32i32.nxv128i8(<vscale x 32 x i32> %x0, <vscale x 128 x i8> %av, <vscale x 128 x i8> %bv0, i64 32, i64 64, i64 64, i64 65552)
  %bv1 = call <vscale x 128 x i8> @llvm.riscv.bosc.ordered.load.b.nxv128i8(ptr %b1, i64 768, i64 64, i64 64, i64 65552)
  %r1 = call <vscale x 32 x i32> @llvm.riscv.bosc.ordered.mma.nxv32i32.nxv128i8(<vscale x 32 x i32> %x1, <vscale x 128 x i8> %av, <vscale x 128 x i8> %bv1, i64 32, i64 64, i64 64, i64 65552)
  call void @llvm.riscv.bosc.ordered.store.acc.nxv32i32(<vscale x 32 x i32> %r0, ptr %c0, i64 3072, i64 32, i64 64, i64 65602)
  call void @llvm.riscv.bosc.ordered.store.acc.nxv32i32(<vscale x 32 x i32> %r1, ptr %c1, i64 3072, i64 32, i64 64, i64 65602)
  ret void
}

; Two defining clears and two loop-carried accumulators: no initial C load,
; hardcoded acc0 output, cross-file copy, spill, or RVV register allocation.
define void @zero_two_acc_loop(ptr %a, ptr %b0, ptr %b1, ptr %c0, ptr %c1,
                              i64 %trips) {
; CHECK-LABEL: zero_two_acc_loop:
; CHECK: mwsub.h.mm [[Z0:acc[0-7]]], [[Z0]], [[Z0]]
; CHECK: mwsub.h.mm [[Z1:acc[0-7]]], [[Z1]], [[Z1]]
; CHECK: [[LOOP:.LBB[0-9_]+]]:
; CHECK: mlae8.m [[LA:tr[0-7]]],
; CHECK: mlbe8.m [[LB0:tr[0-7]]],
; CHECK: mqma.b.mm [[Z0]], [[LA]], [[LB0]]
; CHECK: mlbe8.m [[LB1:tr[0-7]]],
; CHECK: mqma.b.mm [[Z1]], [[LA]], [[LB1]]
; CHECK: {{b[a-z]+}} {{.*}}, [[LOOP]]
; CHECK: msce32.m [[Z0]],
; CHECK: msce32.m [[Z1]],
entry:
  %z0 = call <vscale x 32 x i32> @llvm.riscv.bosc.ordered.zero.acc.nxv32i32(i64 4, i64 64, i64 33)
  %z1 = call <vscale x 32 x i32> @llvm.riscv.bosc.ordered.zero.acc.nxv32i32(i64 4, i64 64, i64 33)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %loop]
  %acc0 = phi <vscale x 32 x i32> [%z0, %entry], [%r0, %loop]
  %acc1 = phi <vscale x 32 x i32> [%z1, %entry], [%r1, %loop]
  %off = shl i64 %i, 6
  %ap = getelementptr i8, ptr %a, i64 %off
  %bp0 = getelementptr i8, ptr %b0, i64 %off
  %bp1 = getelementptr i8, ptr %b1, i64 %off
  %av = call <vscale x 128 x i8> @llvm.riscv.bosc.ordered.load.a.nxv128i8(ptr %ap, i64 768, i64 4, i64 64, i64 65552)
  %bv0 = call <vscale x 128 x i8> @llvm.riscv.bosc.ordered.load.b.nxv128i8(ptr %bp0, i64 768, i64 64, i64 64, i64 65552)
  %r0 = call <vscale x 32 x i32> @llvm.riscv.bosc.ordered.mma.nxv32i32.nxv128i8(<vscale x 32 x i32> %acc0, <vscale x 128 x i8> %av, <vscale x 128 x i8> %bv0, i64 4, i64 64, i64 64, i64 65552)
  %bv1 = call <vscale x 128 x i8> @llvm.riscv.bosc.ordered.load.b.nxv128i8(ptr %bp1, i64 768, i64 64, i64 64, i64 65552)
  %r1 = call <vscale x 32 x i32> @llvm.riscv.bosc.ordered.mma.nxv32i32.nxv128i8(<vscale x 32 x i32> %acc1, <vscale x 128 x i8> %av, <vscale x 128 x i8> %bv1, i64 4, i64 64, i64 64, i64 65552)
  %next = add i64 %i, 1
  %more = icmp ult i64 %next, %trips
  br i1 %more, label %loop, label %exit
exit:
  call void @llvm.riscv.bosc.ordered.store.acc.nxv32i32(<vscale x 32 x i32> %r0, ptr %c0, i64 3072, i64 4, i64 64, i64 65602)
  call void @llvm.riscv.bosc.ordered.store.acc.nxv32i32(<vscale x 32 x i32> %r1, ptr %c1, i64 3072, i64 4, i64 64, i64 65602)
  ret void
}

; Branch relaxation runs before the late expansion. Counting the two pseudos
; as 4-byte instructions would miss this out-of-range conditional branch.
define void @relax_configured_branch(i1 %cond, ptr %c) {
; CHECK-LABEL: relax_configured_branch:
; CHECK: bnez {{.*}}, [[BODY:.LBB[0-9_]+]]
; CHECK-NEXT: j [[EXIT:.LBB[0-9_]+]]
; CHECK: [[BODY]]:
; CHECK: mwsub.h.mm
; CHECK: msce32.m
; CHECK: .zero 4048
; CHECK: [[EXIT]]:
  br i1 %cond, label %work, label %exit
work:
  %z = call <vscale x 32 x i32> @llvm.riscv.bosc.ordered.zero.acc.nxv32i32(i64 4, i64 64, i64 33)
  call void @llvm.riscv.bosc.ordered.store.acc.nxv32i32(<vscale x 32 x i32> %z, ptr %c, i64 3072, i64 4, i64 64, i64 65602)
  call void asm sideeffect ".space 4048", ""()
  br label %exit
exit:
  ret void
}

declare <vscale x 128 x i8> @llvm.riscv.bosc.ordered.load.a.nxv128i8(ptr, i64, i64, i64, i64)
declare <vscale x 128 x i8> @llvm.riscv.bosc.ordered.load.b.nxv128i8(ptr, i64, i64, i64, i64)
declare <vscale x 32 x i32> @llvm.riscv.bosc.ordered.load.acc.nxv32i32(ptr, i64, i64, i64, i64)
declare <vscale x 32 x i32> @llvm.riscv.bosc.ordered.mma.nxv32i32.nxv128i8(<vscale x 32 x i32>, <vscale x 128 x i8>, <vscale x 128 x i8>, i64, i64, i64, i64)
declare void @llvm.riscv.bosc.ordered.store.acc.nxv32i32(<vscale x 32 x i32>, ptr, i64, i64, i64, i64)
declare <vscale x 32 x i32> @llvm.riscv.bosc.ordered.zero.acc.nxv32i32(i64, i64, i64)
