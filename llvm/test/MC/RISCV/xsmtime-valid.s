# RUN: llvm-mc -triple=riscv64 -show-encoding --mattr=+v,+xsmtime %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INST
# RUN: llvm-mc -triple=riscv64 -filetype=obj --mattr=+v,+xsmtime %s \
# RUN:        | llvm-objdump -d --mattr=+v,+xsmtime - \
# RUN:        | FileCheck %s --check-prefix=CHECK-INST
# RUN: not llvm-mc -triple=riscv64 --mattr=+v,+xgemmini < %s 2>&1 \
# RUN:        | FileCheck %s --check-prefix=CHECK-NO-XSMTIME

vmadot v0, v4, v8
# CHECK-INST: vmadot v0, v4, v8
# CHECK-ENCODING: [0x2b,0x00,0x82,0xe2]
# CHECK-NO-XSMTIME: instruction requires the following: 'XSMTIME' (SpacemiT IME extension){{$}}

vmadotu v0, v4, v8
# CHECK-INST: vmadotu v0, v4, v8
# CHECK-ENCODING: [0x2b,0x30,0x82,0xe2]

vmadotsu v0, v4, v8
# CHECK-INST: vmadotsu v0, v4, v8
# CHECK-ENCODING: [0x2b,0x10,0x82,0xe2]

vmadotus v0, v4, v8
# CHECK-INST: vmadotus v0, v4, v8
# CHECK-ENCODING: [0x2b,0x20,0x82,0xe2]

vfmadot v0, v4, v8
# CHECK-INST: vfmadot v0, v4, v8
# CHECK-ENCODING: [0x2b,0x00,0x82,0xea]

vmadot1 v0, v8, v16
# CHECK-INST: vmadot1 v0, v8, v16
# CHECK-ENCODING: [0x2b,0x00,0x04,0xe5]

vmadot1u v0, v8, v16
# CHECK-INST: vmadot1u v0, v8, v16
# CHECK-ENCODING: [0x2b,0x30,0x04,0xe5]

vmadot1su v0, v8, v16
# CHECK-INST: vmadot1su v0, v8, v16
# CHECK-ENCODING: [0x2b,0x10,0x04,0xe5]

vmadot1us v0, v8, v16
# CHECK-INST: vmadot1us v0, v8, v16
# CHECK-ENCODING: [0x2b,0x20,0x04,0xe5]

vmadot2 v0, v8, v16
# CHECK-INST: vmadot2 v0, v8, v16
# CHECK-ENCODING: [0x2b,0x00,0x04,0xe7]

vmadot2u v0, v8, v16
# CHECK-INST: vmadot2u v0, v8, v16
# CHECK-ENCODING: [0x2b,0x30,0x04,0xe7]

vmadot2su v0, v8, v16
# CHECK-INST: vmadot2su v0, v8, v16
# CHECK-ENCODING: [0x2b,0x10,0x04,0xe7]

vmadot2us v0, v8, v16
# CHECK-INST: vmadot2us v0, v8, v16
# CHECK-ENCODING: [0x2b,0x20,0x04,0xe7]

vmadot3 v0, v8, v16
# CHECK-INST: vmadot3 v0, v8, v16
# CHECK-ENCODING: [0x2b,0x00,0x04,0xe9]

vmadot3u v0, v8, v16
# CHECK-INST: vmadot3u v0, v8, v16
# CHECK-ENCODING: [0x2b,0x30,0x04,0xe9]

vmadot3su v0, v8, v16
# CHECK-INST: vmadot3su v0, v8, v16
# CHECK-ENCODING: [0x2b,0x10,0x04,0xe9]

vmadot3us v0, v8, v16
# CHECK-INST: vmadot3us v0, v8, v16
# CHECK-ENCODING: [0x2b,0x20,0x04,0xe9]

vfmadot1 v0, v8, v16
# CHECK-INST: vfmadot1 v0, v8, v16
# CHECK-ENCODING: [0x2b,0x00,0x04,0xed]

vfmadot2 v0, v8, v16
# CHECK-INST: vfmadot2 v0, v8, v16
# CHECK-ENCODING: [0x2b,0x00,0x04,0xef]

vfmadot3 v0, v8, v16
# CHECK-INST: vfmadot3 v0, v8, v16
# CHECK-ENCODING: [0x2b,0x00,0x04,0xf1]
