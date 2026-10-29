# RUN: not llvm-mc %s -triple=riscv64 2>&1 | FileCheck %s --check-prefix=CHECK-NONE
# RUN: not llvm-mc %s -triple=riscv64 -mattr=+zames 2>&1 | FileCheck %s --check-prefix=CHECK-ZAMES

# Every ZMASYNC mnemonic must be rejected when the extension is not enabled,
# including when only the base ZAMES extension is enabled.

# CHECK-NONE: error: instruction requires the following: 'ZMASYNC'
# CHECK-ZAMES: error: instruction requires the following: 'ZMASYNC'
msyncregreset sync0
# CHECK-NONE: error: instruction requires the following: 'ZMASYNC'
# CHECK-ZAMES: error: instruction requires the following: 'ZMASYNC'
mrelease sync1
# CHECK-NONE: error: instruction requires the following: 'ZMASYNC'
# CHECK-ZAMES: error: instruction requires the following: 'ZMASYNC'
macquire sync15, a0
# CHECK-NONE: error: instruction requires the following: 'ZMASYNC'
# CHECK-ZAMES: error: instruction requires the following: 'ZMASYNC'
mfence
