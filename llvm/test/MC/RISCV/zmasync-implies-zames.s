# RUN: llvm-mc %s -triple=riscv64 -show-encoding | FileCheck %s

# `zmasync` is a superset of `zames`: enabling it through `.option arch`
# must make ordinary ZAMES instructions available as well.
.option arch, rv64i_zmasync

# CHECK: msettilemi 4
msettilemi 4

# CHECK: msyncregreset sync0
msyncregreset sync0
