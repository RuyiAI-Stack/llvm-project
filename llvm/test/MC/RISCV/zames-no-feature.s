# RUN: not llvm-mc %s -triple=riscv64 2>&1 | FileCheck %s

# Every ZAMES mnemonic must be rejected when the extension is not enabled.

# CHECK: error: instruction requires the following: 'ZAMES'
msettilemi 4
# CHECK: error: instruction requires the following: 'ZAMES'
msettileni 4
# CHECK: error: instruction requires the following: 'ZAMES'
msettileki 8
# CHECK: error: instruction requires the following: 'ZAMES'
msettilem a0
# CHECK: error: instruction requires the following: 'ZAMES'
msettilen a1
# CHECK: error: instruction requires the following: 'ZAMES'
msettilek a2
# CHECK: error: instruction requires the following: 'ZAMES'
msetcfg mcfg0, a0
# CHECK: error: instruction requires the following: 'ZAMES'
mgetcfg a0, mcfg5
# CHECK: error: instruction requires the following: 'ZAMES'
minit
# CHECK: error: instruction requires the following: 'ZAMES'
mzero acc0
# CHECK: error: instruction requires the following: 'ZAMES'
mmacc acc0, tr1, tr0
# CHECK: error: instruction requires the following: 'ZAMES'
mla tr0, (a0), a3
# CHECK: error: instruction requires the following: 'ZAMES'
mlb tr2, (a0), a3
# CHECK: error: instruction requires the following: 'ZAMES'
mlbt tr1, (a1), a4
# CHECK: error: instruction requires the following: 'ZAMES'
mlc acc2, (a0), a3
# CHECK: error: instruction requires the following: 'ZAMES'
mlat tr1, (a0), a3
# CHECK: error: instruction requires the following: 'ZAMES'
mlct acc1, (a0), a3
# CHECK: error: instruction requires the following: 'ZAMES'
msa tr0, (a2), a5
# CHECK: error: instruction requires the following: 'ZAMES'
msb tr1, (a2), a5
# CHECK: error: instruction requires the following: 'ZAMES'
msat tr2, (a2), a5
# CHECK: error: instruction requires the following: 'ZAMES'
msbt tr3, (a2), a5
# CHECK: error: instruction requires the following: 'ZAMES'
msc acc0, (a2), a5
# CHECK: error: instruction requires the following: 'ZAMES'
msct acc0, (a2), a5
# CHECK: error: instruction requires the following: 'ZAMES'
mla.whole tr0, (a0)
# CHECK: error: instruction requires the following: 'ZAMES'
mlb.whole tr1, (a0)
# CHECK: error: instruction requires the following: 'ZAMES'
mlc.whole acc0, (a0)
# CHECK: error: instruction requires the following: 'ZAMES'
msa.whole tr0, (a2)
# CHECK: error: instruction requires the following: 'ZAMES'
msb.whole tr1, (a2)
# CHECK: error: instruction requires the following: 'ZAMES'
msc.whole acc0, (a2)
