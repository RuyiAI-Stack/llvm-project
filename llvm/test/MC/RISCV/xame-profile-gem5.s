# RUN: llvm-mc -triple=riscv64 -mattr=+xame,+xame-gem5 -show-encoding %s | FileCheck %s
# RUN: llvm-mc -triple=riscv64 -mattr=+xame,+xame-gem5 -filetype=obj %s \
# RUN:   | llvm-objdump -d --mattr=+xame,+xame-gem5 - \
# RUN:   | FileCheck %s
# RUN: llvm-mc -triple=riscv64 -mattr=+xame,+xame-gem5 -filetype=obj %s \
# RUN:   | llvm-objdump -d --mattr=+xame,-xame-gem5 - \
# RUN:   | FileCheck %s --check-prefix=DEFAULT-DECODE

madd.ew m31, m31, m31
mzero.2d.acc acc3

# CHECK: madd.ew m31, m31, m31
# CHECK: mzero.2d.acc acc3

# m31 is outside the default profile's sixteen-register M file.
# DEFAULT-DECODE: 05ff8fab{{.*}}<unknown>
# DEFAULT-DECODE-NEXT: {{.*}}mzero.2d.acc acc3
