# RUN: not llvm-mc %s -triple=riscv64 -mattr=+zmasync 2>&1 | FileCheck %s

# Wrong operand type.
msyncregreset a0
# CHECK: error:
mrelease a0
# CHECK: error:
mrelease sr0
# CHECK: error:

# Out-of-range sync registers.
msyncregreset sync16
# CHECK: error:
macquire sync31, a0
# CHECK: error:

# Wrong operand type.
macquire sync0, sync1
# CHECK: error:
