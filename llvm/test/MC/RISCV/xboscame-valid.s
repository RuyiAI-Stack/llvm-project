# RUN: llvm-mc -triple=riscv64 -show-encoding --mattr=+xboscame %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INST
# RUN: llvm-mc -triple=riscv32 -show-encoding --mattr=+xboscame %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INST
# RUN: llvm-mc -triple=riscv64 -filetype=obj --mattr=+xboscame %s \
# RUN:        | llvm-objdump --no-print-imm-hex -d --mattr=+xboscame - \
# RUN:        | FileCheck %s --check-prefix=CHECK-INST
# RUN: llvm-mc -triple=riscv32 -filetype=obj --mattr=+xboscame %s \
# RUN:        | llvm-objdump --no-print-imm-hex -d --mattr=+xboscame - \
# RUN:        | FileCheck %s --check-prefix=CHECK-INST
# RUN: echo "mma.h.mm acc0, tr1, tr2" \
# RUN:        | not llvm-mc -triple=riscv64 --mattr=+xtheadame 2>&1 \
# RUN:        | FileCheck %s --check-prefix=CHECK-NO-XBOSCAME

mma.h.mm acc0, tr1, tr2
# CHECK-INST: mma.h.mm acc0, tr1, tr2
# CHECK-ENCODING: [0x77,0x9c,0x28,0x20]

mma.w.mm acc0, tr1, tr2
# CHECK-INST: mma.w.mm acc0, tr1, tr2
# CHECK-ENCODING: [0x77,0xac,0x28,0x20]

mma.dw.mm acc0, tr1, tr2
# CHECK-INST: mma.dw.mm acc0, tr1, tr2
# CHECK-ENCODING: [0x77,0xbc,0x28,0x20]

msettilem a0, a1
# CHECK-INST: msettilem a0, a1
# CHECK-ENCODING: [0x77,0xd5,0x05,0x04]

msettilemi a0, 7
# CHECK-INST: msettilemi a0, 7
# CHECK-ENCODING: [0x77,0xd5,0x03,0x06]

msettilen a0, a1
# CHECK-INST: msettilen a0, a1
# CHECK-ENCODING: [0x77,0xc5,0x05,0x04]

msettileni a0, 7
# CHECK-INST: msettileni a0, 7
# CHECK-ENCODING: [0x77,0xc5,0x03,0x06]

msettilek a0, a1
# CHECK-INST: msettilek a0, a1
# CHECK-ENCODING: [0x77,0xe5,0x05,0x04]

msettileki a0, 7
# CHECK-INST: msettileki a0, 7
# CHECK-ENCODING: [0x77,0xe5,0x03,0x06]

mlae8.m tr0, (a0), a1
# CHECK-INST: mlae8.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x00,0xb5,0x04]

mlae16.m tr0, (a0), a1
# CHECK-INST: mlae16.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x10,0xb5,0x04]

mlae32.m tr0, (a0), a1
# CHECK-INST: mlae32.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x20,0xb5,0x04]

mlae64.m tr0, (a0), a1
# CHECK-INST: mlae64.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x30,0xb5,0x04]

mlbe8.m tr0, (a0), a1
# CHECK-INST: mlbe8.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x00,0xb5,0x08]

mlbe16.m tr0, (a0), a1
# CHECK-INST: mlbe16.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x10,0xb5,0x08]

mlbe32.m tr0, (a0), a1
# CHECK-INST: mlbe32.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x20,0xb5,0x08]

mlbe64.m tr0, (a0), a1
# CHECK-INST: mlbe64.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x30,0xb5,0x08]

mlce8.m acc0, (a0), a1
# CHECK-INST: mlce8.m acc0, (a0), a1
# CHECK-ENCODING: [0x77,0x04,0xb5,0x00]

mlce16.m acc0, (a0), a1
# CHECK-INST: mlce16.m acc0, (a0), a1
# CHECK-ENCODING: [0x77,0x14,0xb5,0x00]

mlce32.m acc0, (a0), a1
# CHECK-INST: mlce32.m acc0, (a0), a1
# CHECK-ENCODING: [0x77,0x24,0xb5,0x00]

mlce64.m acc0, (a0), a1
# CHECK-INST: mlce64.m acc0, (a0), a1
# CHECK-ENCODING: [0x77,0x34,0xb5,0x00]

msae8.m tr0, (a0), a1
# CHECK-INST: msae8.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x00,0xb5,0x06]

msae16.m tr0, (a0), a1
# CHECK-INST: msae16.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x10,0xb5,0x06]

msae32.m tr0, (a0), a1
# CHECK-INST: msae32.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x20,0xb5,0x06]

msae64.m tr0, (a0), a1
# CHECK-INST: msae64.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x30,0xb5,0x06]

msbe8.m tr0, (a0), a1
# CHECK-INST: msbe8.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x00,0xb5,0x0a]

msbe16.m tr0, (a0), a1
# CHECK-INST: msbe16.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x10,0xb5,0x0a]

msbe32.m tr0, (a0), a1
# CHECK-INST: msbe32.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x20,0xb5,0x0a]

msbe64.m tr0, (a0), a1
# CHECK-INST: msbe64.m tr0, (a0), a1
# CHECK-ENCODING: [0x77,0x30,0xb5,0x0a]

msce8.m acc0, (a0), a1
# CHECK-INST: msce8.m acc0, (a0), a1
# CHECK-ENCODING: [0x77,0x04,0xb5,0x02]

msce16.m acc0, (a0), a1
# CHECK-INST: msce16.m acc0, (a0), a1
# CHECK-ENCODING: [0x77,0x14,0xb5,0x02]

msce32.m acc0, (a0), a1
# CHECK-INST: msce32.m acc0, (a0), a1
# CHECK-ENCODING: [0x77,0x24,0xb5,0x02]

msce64.m acc0, (a0), a1
# CHECK-INST: msce64.m acc0, (a0), a1
# CHECK-ENCODING: [0x77,0x34,0xb5,0x02]
