# RUN: not llvm-mc -triple=riscv64 -mattr=+xame,+xame-gem5 -show-encoding %s 2>&1 | FileCheck %s

mzero.2d.acc acc4

# CHECK: error: invalid operand for selected XAME profile
