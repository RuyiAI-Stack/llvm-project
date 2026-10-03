# RUN: llvm-mca -mtriple=riscv64 -mcpu=spacemit-a100 -iterations=1 -instruction-info %s | FileCheck %s

# CHECK: [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT: 1 5 4.00 smt.vpack.vv v8, v2, v4, 0
smt.vpack.vv v8, v2, v4, 0
# CHECK-NEXT: 1 5 4.00 smt.vupack.vv v8, v2, v4, 3
smt.vupack.vv v8, v2, v4, 3
# CHECK-NEXT: 1 13 13.00 smt.vupack.vv v8, v2, v4, 0
smt.vupack.vv v8, v2, v4, 0
# CHECK-NEXT: 1 13 13.00 smt.vupack.vv v8, v2, v4, 1
smt.vupack.vv v8, v2, v4, 1
# CHECK-NEXT: 1 6 4.00 smt.vupack.vv v8, v2, v4, 2
smt.vupack.vv v8, v2, v4, 2
# CHECK-NEXT: 1 3 2.00 smt.vnpack.vv v8, v2, v4, 0
smt.vnpack.vv v8, v2, v4, 0
# CHECK-NEXT: 1 3 2.00 smt.vnspack.vv v8, v2, v4, 1
smt.vnspack.vv v8, v2, v4, 1
# CHECK-NEXT: 1 3 2.00 smt.vnpack4.vv v8, v2, v4, 2
smt.vnpack4.vv v8, v2, v4, 2
# CHECK-NEXT: 1 3 2.00 smt.vnspack4.vv v8, v2, v4, 3
smt.vnspack4.vv v8, v2, v4, 3
