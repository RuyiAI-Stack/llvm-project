# RUN: llvm-mc -triple=riscv32 -mattr=+xame -show-encoding %s \
# RUN:   | FileCheck %s --check-prefixes=CHECK-INST,CHECK-ENCODING
# RUN: llvm-mc -triple=riscv64 -mattr=+xame -show-encoding %s \
# RUN:   | FileCheck %s --check-prefixes=CHECK-INST,CHECK-ENCODING
# RUN: llvm-mc -triple=riscv64 -mattr=+xame,+xame-gem5 -show-encoding %s \
# RUN:   | FileCheck %s --check-prefixes=CHECK-INST,CHECK-ENCODING
# RUN: llvm-mc -triple=riscv64 -mattr=+xame -filetype=obj %s \
# RUN:   | llvm-objdump -d --mattr=+xame - \
# RUN:   | FileCheck %s --check-prefix=CHECK-INST
# RUN: llvm-mc -triple=riscv64 -mattr=+xame,+xame-gem5 -filetype=obj %s \
# RUN:   | llvm-objdump -d --mattr=+xame,+xame-gem5 - \
# RUN:   | FileCheck %s --check-prefix=CHECK-INST
# RUN: not llvm-mc -triple=riscv64 %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=CHECK-ERROR

# ZTT v0.6 encodings, shared by both XAME implementation profiles. Exercise
# overlapping register names, distinct operand fields and tied destinations.
# CHECK-ERROR: instruction requires the following: 'XAME' (Attached Matrix Extension v0.6)

ame.acquire a0, a1
# CHECK-INST: ame.acquire a0, a1
# CHECK-ENCODING: [0x2b,0x85,0x95,0xa4]

ame.release
# CHECK-INST: ame.release
# CHECK-ENCODING: [0x2b,0x00,0xa0,0xa4]

agettyp a0, acc3
# CHECK-INST: agettyp a0, acc3
# CHECK-ENCODING: [0x2b,0x85,0x01,0xa2]

asettyp acc3, a1
# CHECK-INST: asettyp acc3, a1
# CHECK-ENCODING: [0xab,0x81,0x15,0xa2]

mgettyp a0, m15
# CHECK-INST: mgettyp a0, m15
# CHECK-ENCODING: [0x2b,0x85,0x27,0xa2]

msettyp m15, a1
# CHECK-INST: msettyp m15, a1
# CHECK-ENCODING: [0xab,0x87,0x35,0xa2]

madd.ew m0, m1, m15
# CHECK-INST: madd.ew m0, m1, m15
# CHECK-ENCODING: [0x2b,0x80,0xf0,0x04]

madd.ew.x m15, a1, m2
# CHECK-INST: madd.ew.x m15, a1, m2
# CHECK-ENCODING: [0xab,0x87,0x25,0x06]

mabs.ew m2, m1
# CHECK-INST: mabs.ew m2, m1
# CHECK-ENCODING: [0x2b,0x81,0x40,0xa2]

mls.st m15, (a0), a1
# CHECK-INST: mls.st m15, (a0), a1
# CHECK-ENCODING: [0xab,0x07,0xb5,0xa8]

mls.tst m2, (a1), a2
# CHECK-INST: mls.tst m2, (a1), a2
# CHECK-ENCODING: [0x2b,0x81,0xc5,0xaa]

mss.st m15, (a0), a1
# CHECK-INST: mss.st m15, (a0), a1
# CHECK-ENCODING: [0xab,0x07,0xb5,0xac]

mss.tst m2, (a1), a2
# CHECK-INST: mss.tst m2, (a1), a2
# CHECK-ENCODING: [0x2b,0x81,0xc5,0xae]

mmulacc.2d acc3, m14, m15
# CHECK-INST: mmulacc.2d acc3, m14, m15
# CHECK-ENCODING: [0xab,0x01,0xf7,0x94]

mmov.m.a m15, acc3
# CHECK-INST: mmov.m.a m15, acc3
# CHECK-ENCODING: [0xab,0x87,0xc1,0xa3]

mmov.a.m acc3, m15
# CHECK-INST: mmov.a.m acc3, m15
# CHECK-ENCODING: [0xab,0x81,0xd7,0xa3]

mmov.m.m m0, m15
# CHECK-INST: mmov.m.m m0, m15
# CHECK-ENCODING: [0x2b,0x80,0xe7,0xa3]

mcolunzip.ew m2, m3
# CHECK-INST: mcolunzip.ew m2, m3
# CHECK-ENCODING: [0x2b,0x00,0x31,0xc2]

mcolzip.ew m2, m3
# CHECK-INST: mcolzip.ew m2, m3
# CHECK-ENCODING: [0x2b,0x00,0x31,0xc4]

mzero.2d.acc acc0
# CHECK-INST: mzero.2d.acc acc0
# CHECK-ENCODING: [0x2b,0x00,0x00,0xa6]

mzero.2d.m m0
# CHECK-INST: mzero.2d.m m0
# CHECK-ENCODING: [0x2b,0x80,0x00,0xa6]
