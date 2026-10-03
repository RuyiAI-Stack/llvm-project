# RUN: llvm-mca -mtriple=riscv64 -mcpu=spacemit-a100 -iterations=1 -instruction-info %s | FileCheck %s

# CHECK: [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT: 1 8 1.00 smt.vmadot v8, v2, v4, i8
smt.vmadot v8, v2, v4, i8
# CHECK-NEXT: 1 10 1.00 smt.vmadot.hp v8, v2, v4, v0, 7, i8
smt.vmadot.hp v8, v2, v4, v0, 7, i8
# CHECK-NEXT: 1 9 1.00 smt.vmadot.sp v8, v2, v4, v0, 3, i8
smt.vmadot.sp v8, v2, v4, v0, 3, i8
# CHECK-NEXT: 1 8 1.00 smt.vmadotu v8, v2, v4, i8
smt.vmadotu v8, v2, v4, i8
# CHECK-NEXT: 1 10 1.00 smt.vmadotu.hp v8, v2, v4, v0, 7, i8
smt.vmadotu.hp v8, v2, v4, v0, 7, i8
# CHECK-NEXT: 1 9 1.00 smt.vmadotu.sp v8, v2, v4, v0, 3, i8
smt.vmadotu.sp v8, v2, v4, v0, 3, i8
# CHECK-NEXT: 1 8 1.00 smt.vmadotsu v8, v2, v4, i8
smt.vmadotsu v8, v2, v4, i8
# CHECK-NEXT: 1 10 1.00 smt.vmadotsu.hp v8, v2, v4, v0, 7, i8
smt.vmadotsu.hp v8, v2, v4, v0, 7, i8
# CHECK-NEXT: 1 9 1.00 smt.vmadotsu.sp v8, v2, v4, v0, 3, i8
smt.vmadotsu.sp v8, v2, v4, v0, 3, i8
# CHECK-NEXT: 1 8 1.00 smt.vmadotus v8, v2, v4, i8
smt.vmadotus v8, v2, v4, i8
# CHECK-NEXT: 1 10 1.00 smt.vmadotus.hp v8, v2, v4, v0, 7, i8
smt.vmadotus.hp v8, v2, v4, v0, 7, i8
# CHECK-NEXT: 1 9 1.00 smt.vmadotus.sp v8, v2, v4, v0, 3, i8
smt.vmadotus.sp v8, v2, v4, v0, 3, i8
# CHECK-NEXT: 1 10 1.00 smt.vfwmadot v8, v2, v4
smt.vfwmadot v8, v2, v4

# CHECK-NEXT: 1 3 3.00 {{.*}} vsetvli t0, zero, e32, m1, ta, ma
vsetvli t0, zero, e32, m1, ta, ma
# CHECK-NEXT: 1 3 3.00 {{.*}} vsetivli t0, 31, e16, m1, ta, ma
vsetivli t0, 31, e16, m1, ta, ma
# CHECK-NEXT: 1 4 4.00 {{.*}} vsetvl t0, zero, t1
vsetvl t0, zero, t1
