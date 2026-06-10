# RUN: llvm-mc -triple=riscv64 -show-encoding --mattr=+xtheadame %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INST
# RUN: llvm-mc -triple=riscv64 -filetype=obj --mattr=+xtheadame %s \
# RUN:        | llvm-objdump --no-print-imm-hex -d --mattr=+xtheadame - \
# RUN:        | FileCheck %s --check-prefix=CHECK-INST

th.mmacc.w.b m0, m1, m2
# CHECK-INST: th.mmacc.w.b m0, m1, m2
# CHECK-ENCODING: [0x2b,0x00,0x28,0x20]

th.mmaccu.w.b m0, m1, m2
# CHECK-INST: th.mmaccu.w.b m0, m1, m2
# CHECK-ENCODING: [0xab,0x00,0x28,0x20]

th.mfmacc.s m0, m1, m2
# CHECK-INST: th.mfmacc.s m0, m1, m2
# CHECK-ENCODING: [0x2b,0x08,0x28,0x10]

th.mfmacc.d.s m0, m1, m2
# CHECK-INST: th.mfmacc.d.s m0, m1, m2
# CHECK-ENCODING: [0x2b,0x08,0x28,0x11]

th.mcfgk a0
# CHECK-INST: th.mcfgk a0
# CHECK-ENCODING: [0x2b,0x00,0x05,0x8e]

th.mcfgm a0
# CHECK-INST: th.mcfgm a0
# CHECK-ENCODING: [0x2b,0x00,0x05,0x9e]

th.mcfgn a0
# CHECK-INST: th.mcfgn a0
# CHECK-ENCODING: [0x2b,0x00,0x05,0xae]

th.mcfg a0
# CHECK-INST: th.mcfg a0
# CHECK-ENCODING: [0x2b,0x00,0x05,0xfe]

th.mcfgki 7
# CHECK-INST: th.mcfgki 7
# CHECK-ENCODING: [0x2b,0x00,0x1c,0x0e]

th.mcfgmi 7
# CHECK-INST: th.mcfgmi 7
# CHECK-ENCODING: [0x2b,0x00,0x1c,0x1e]

th.mcfgni 7
# CHECK-INST: th.mcfgni 7
# CHECK-ENCODING: [0x2b,0x00,0x1c,0x2e]

th.mlde8 m0, a1, a0
# CHECK-INST: th.mlde8 m0, a1, a0
# CHECK-ENCODING: [0x2b,0x00,0xb5,0x08]

th.mlde16 m0, a1, a0
# CHECK-INST: th.mlde16 m0, a1, a0
# CHECK-ENCODING: [0x2b,0x04,0xb5,0x08]

th.mlde32 m0, a1, a0
# CHECK-INST: th.mlde32 m0, a1, a0
# CHECK-ENCODING: [0x2b,0x08,0xb5,0x08]

th.mlde64 m0, a1, a0
# CHECK-INST: th.mlde64 m0, a1, a0
# CHECK-ENCODING: [0x2b,0x0c,0xb5,0x08]

th.mste8 m0, a1, a0
# CHECK-INST: th.mste8 m0, a1, a0
# CHECK-ENCODING: [0x2b,0x00,0xb5,0x0a]

th.mste16 m0, a1, a0
# CHECK-INST: th.mste16 m0, a1, a0
# CHECK-ENCODING: [0x2b,0x04,0xb5,0x0a]

th.mste32 m0, a1, a0
# CHECK-INST: th.mste32 m0, a1, a0
# CHECK-ENCODING: [0x2b,0x08,0xb5,0x0a]

th.mste64 m0, a1, a0
# CHECK-INST: th.mste64 m0, a1, a0
# CHECK-ENCODING: [0x2b,0x0c,0xb5,0x0a]

th.mldte8 m0, a1, a0
# CHECK-INST: th.mldte8 m0, a1, a0
# CHECK-ENCODING: [0x2b,0x00,0xb5,0x38]

th.mldte16 m0, a1, a0
# CHECK-INST: th.mldte16 m0, a1, a0
# CHECK-ENCODING: [0x2b,0x04,0xb5,0x38]

th.mldte32 m0, a1, a0
# CHECK-INST: th.mldte32 m0, a1, a0
# CHECK-ENCODING: [0x2b,0x08,0xb5,0x38]

th.mldte64 m0, a1, a0
# CHECK-INST: th.mldte64 m0, a1, a0
# CHECK-ENCODING: [0x2b,0x0c,0xb5,0x38]

th.mzero m0
# CHECK-INST: th.mzero m0
# CHECK-ENCODING: [0x2b,0x00,0x00,0xa0]

th.mzero2r m0
# CHECK-INST: th.mzero2r m0
# CHECK-ENCODING: [0xab,0x00,0x00,0xa0]

th.mzero4r m0
# CHECK-INST: th.mzero4r m0
# CHECK-ENCODING: [0xab,0x01,0x00,0xa0]

th.mzero8r m0
# CHECK-INST: th.mzero8r m0
# CHECK-ENCODING: [0xab,0x03,0x00,0xa0]
