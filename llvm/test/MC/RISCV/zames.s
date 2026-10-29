# RUN: llvm-mc %s -triple=riscv64 -mattr=+zames -show-encoding | FileCheck %s --check-prefix=CHECK-ASM
# RUN: llvm-mc %s -triple=riscv64 -mattr=+zames -filetype=obj | llvm-objdump --mattr=+zames -d - | FileCheck %s --check-prefix=CHECK-OBJ

# CHECK-ASM: msettilemi 4 # encoding: [0x2b,0x00,0x02,0x20]
# CHECK-OBJ: msettilemi 0x4
msettilemi 4

# CHECK-ASM: msettileni 4 # encoding: [0x2b,0x00,0x02,0x30]
# CHECK-OBJ: msettileni 0x4
msettileni 4

# CHECK-ASM: msettileki 8 # encoding: [0x2b,0x00,0x04,0x10]
# CHECK-OBJ: msettileki 0x8
msettileki 8

# CHECK-ASM: msettilem a0 # encoding: [0x2b,0x00,0x05,0x22]
# CHECK-OBJ: msettilem a0
msettilem a0

# CHECK-ASM: msettilen a1 # encoding: [0x2b,0x80,0x05,0x32]
# CHECK-OBJ: msettilen a1
msettilen a1

# CHECK-ASM: msettilek a2 # encoding: [0x2b,0x00,0x06,0x12]
# CHECK-OBJ: msettilek a2
msettilek a2

# CHECK-ASM: msetcfg mcfg0, a0 # encoding: [0x2b,0x00,0x05,0x42]
# CHECK-OBJ: msetcfg mcfg0, a0
msetcfg mcfg0, a0

# CHECK-ASM: msetcfg mcfg4, a1 # encoding: [0x2b,0x82,0x05,0x42]
# CHECK-OBJ: msetcfg mcfg4, a1
msetcfg mcfg4, a1

# CHECK-ASM: msetcfg mcfg7, a1 # encoding: [0xab,0x83,0x05,0x42]
# CHECK-OBJ: msetcfg mcfg7, a1
msetcfg mcfg7, a1

# CHECK-ASM: mgetcfg a0, mcfg5 # encoding: [0x2b,0x85,0x02,0x50]
# CHECK-OBJ: mgetcfg a0, mcfg5
mgetcfg a0, mcfg5

# CHECK-ASM: minit # encoding: [0x2b,0x00,0x00,0x00]
# CHECK-OBJ: minit
minit

# CHECK-ASM: mla tr0, (a0), a3 # encoding: [0x2b,0x10,0xd5,0x00]
# CHECK-OBJ: mla tr0, (a0), a3
mla tr0, (a0), a3

# CHECK-ASM: mlb tr2, (a0), a3 # encoding: [0x2b,0x11,0xd5,0x10]
# CHECK-OBJ: mlb tr2, (a0), a3
mlb tr2, (a0), a3

# CHECK-ASM: mlbt tr1, (a1), a4 # encoding: [0xab,0x90,0xe5,0x50]
# CHECK-OBJ: mlbt tr1, (a1), a4
mlbt tr1, (a1), a4

# CHECK-ASM: mlc acc2, (a0), a3 # encoding: [0x2b,0x13,0xd5,0x20]
# CHECK-OBJ: mlc acc2, (a0), a3
mlc acc2, (a0), a3

# CHECK-ASM: mzero acc0 # encoding: [0x2b,0x32,0x00,0x00]
# CHECK-OBJ: mzero acc0
mzero acc0

# CHECK-ASM: mzero tr0 # encoding: [0x2b,0x30,0x00,0x00]
# CHECK-OBJ: mzero tr0
mzero tr0

# CHECK-ASM: mzero tr3 # encoding: [0xab,0x31,0x00,0x00]
# CHECK-OBJ: mzero tr3
mzero tr3

# CHECK-ASM: mzero acc3 # encoding: [0xab,0x33,0x00,0x00]
# CHECK-OBJ: mzero acc3
mzero acc3

# CHECK-ASM: mmacc acc0, tr1, tr0 # encoding: [0x2b,0x22,0x10,0x00]
# CHECK-OBJ: mmacc acc0, tr1, tr0
mmacc acc0, tr1, tr0

# CHECK-ASM: mmacc acc3, tr2, tr1 # encoding: [0xab,0xa3,0x20,0x00]
# CHECK-OBJ: mmacc acc3, tr2, tr1
mmacc acc3, tr2, tr1

# CHECK-ASM: msc acc0, (a2), a5 # encoding: [0x2b,0x12,0xf6,0x22]
# CHECK-OBJ: msc acc0, (a2), a5
msc acc0, (a2), a5

# CHECK-ASM: msc acc3, (a2), a5 # encoding: [0xab,0x13,0xf6,0x22]
# CHECK-OBJ: msc acc3, (a2), a5
msc acc3, (a2), a5

# CHECK-ASM: mlat tr1, (a0), a3 # encoding: [0xab,0x10,0xd5,0x40]
# CHECK-OBJ: mlat tr1, (a0), a3
mlat tr1, (a0), a3

# CHECK-ASM: mlct acc1, (a0), a3 # encoding: [0xab,0x12,0xd5,0x60]
# CHECK-OBJ: mlct acc1, (a0), a3
mlct acc1, (a0), a3

# CHECK-ASM: msa tr0, (a2), a5 # encoding: [0x2b,0x10,0xf6,0x02]
# CHECK-OBJ: msa tr0, (a2), a5
msa tr0, (a2), a5

# CHECK-ASM: msb tr1, (a2), a5 # encoding: [0xab,0x10,0xf6,0x12]
# CHECK-OBJ: msb tr1, (a2), a5
msb tr1, (a2), a5

# CHECK-ASM: msat tr2, (a2), a5 # encoding: [0x2b,0x11,0xf6,0x42]
# CHECK-OBJ: msat tr2, (a2), a5
msat tr2, (a2), a5

# CHECK-ASM: msbt tr3, (a2), a5 # encoding: [0xab,0x11,0xf6,0x52]
# CHECK-OBJ: msbt tr3, (a2), a5
msbt tr3, (a2), a5

# CHECK-ASM: msct acc0, (a2), a5 # encoding: [0x2b,0x12,0xf6,0x62]
# CHECK-OBJ: msct acc0, (a2), a5
msct acc0, (a2), a5

# .whole loads/stores encode rs2 as zero.
# CHECK-ASM: mla.whole tr0, (a0) # encoding: [0x2b,0x10,0x05,0x80]
# CHECK-OBJ: mla.whole tr0, (a0)
mla.whole tr0, (a0)

# CHECK-ASM: mlb.whole tr1, (a0) # encoding: [0xab,0x10,0x05,0x90]
# CHECK-OBJ: mlb.whole tr1, (a0)
mlb.whole tr1, (a0)

# CHECK-ASM: mlc.whole acc0, (a0) # encoding: [0x2b,0x12,0x05,0xa0]
# CHECK-OBJ: mlc.whole acc0, (a0)
mlc.whole acc0, (a0)

# CHECK-ASM: msa.whole tr0, (a2) # encoding: [0x2b,0x10,0x06,0x82]
# CHECK-OBJ: msa.whole tr0, (a2)
msa.whole tr0, (a2)

# CHECK-ASM: msb.whole tr1, (a2) # encoding: [0xab,0x10,0x06,0x92]
# CHECK-OBJ: msb.whole tr1, (a2)
msb.whole tr1, (a2)

# CHECK-ASM: msc.whole acc0, (a2) # encoding: [0x2b,0x12,0x06,0xa2]
# CHECK-OBJ: msc.whole acc0, (a2)
msc.whole acc0, (a2)
