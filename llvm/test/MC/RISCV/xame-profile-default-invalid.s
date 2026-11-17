# RUN: not llvm-mc -triple=riscv64 -mattr=+xame -show-encoding %s 2>&1 | FileCheck %s

madd.ew m16, m16, m16

# CHECK: error: invalid operand for selected XAME profile
