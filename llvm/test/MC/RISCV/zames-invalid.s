# RUN: not llvm-mc %s -triple=riscv64 -mattr=+zames 2>&1 | FileCheck %s

# ACC register where only TileReg is accepted.
mla acc0, (a0), a1
# CHECK: error:

# Out-of-range tile/accumulator registers.
mla tr4, (a0), a1
# CHECK: error:
mzero acc4
# CHECK: error:

# Wrong operand count.
msetcfg a0
# CHECK: error:

# Illegal mcfg selector.
msetcfg mcfg8, a0
# CHECK: error:

# Wrong operand type.
msetcfg mcfg0, mcfg1
# CHECK: error:
