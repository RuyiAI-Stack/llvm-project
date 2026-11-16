# RUN: llvm-mc -triple=riscv64 -mattr=+xame -show-encoding %s | FileCheck %s --check-prefix=DEFAULT
# RUN: llvm-mc -triple=riscv64 -mattr=+xame -filetype=obj %s \
# RUN:   | llvm-objdump -d --mattr=+xame - \
# RUN:   | FileCheck %s --check-prefix=DEFAULT
# RUN: llvm-mc -triple=riscv64 -mattr=+xame -filetype=obj %s \
# RUN:   | llvm-objdump -d --mattr=+xame,+xame-gem5 - \
# RUN:   | FileCheck %s --check-prefix=GEM5-DECODE

madd.ew m15, m15, m15
mzero.2d.acc acc7

# DEFAULT: madd.ew m15, m15, m15
# DEFAULT: mzero.2d.acc acc7

# acc7 is outside the gem5 profile's four-register ACC file.
# GEM5-DECODE: madd.ew m15, m15, m15
# GEM5-DECODE-NEXT: {{.*}}a60003ab{{.*}}<unknown>
