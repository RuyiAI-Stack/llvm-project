# RUN: llvm-mc %s -triple=riscv64 -mattr=+zmasync -show-encoding | FileCheck %s --check-prefix=CHECK-ASM
# RUN: llvm-mc %s -triple=riscv64 -mattr=+zmasync -filetype=obj | llvm-objdump --mattr=+zmasync -d - | FileCheck %s --check-prefix=CHECK-OBJ

# CHECK-ASM: msyncregreset sync0 # encoding: [0x2b,0x40,0x00,0x80]
# CHECK-OBJ: msyncregreset sync0
msyncregreset sync0

# CHECK-ASM: msyncregreset sync15 # encoding: [0x2b,0x40,0xf0,0x80]
# CHECK-OBJ: msyncregreset sync15
msyncregreset sync15

# CHECK-ASM: mrelease sync1 # encoding: [0x2b,0x40,0x10,0x90]
# CHECK-OBJ: mrelease sync1
mrelease sync1

# CHECK-ASM: macquire sync15, a0 # encoding: [0x2b,0x40,0xf5,0xa0]
# CHECK-OBJ: macquire sync15, a0
macquire sync15, a0

# CHECK-ASM: mfence # encoding: [0x2b,0x40,0x00,0xb0]
# CHECK-OBJ: mfence
mfence
