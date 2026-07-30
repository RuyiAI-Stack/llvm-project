  # RUN: not llvm-mc -triple=riscv64 --mattr=-experimental-ztt-ame-mregs-16,-experimental-ztt-ame-mregs-32 %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=CHECK-NO-M-CONFIG
# RUN: not llvm-mc -triple=riscv64 --mattr=+experimental-ztt-ame-mregs-16,+experimental-ztt-ame-mregs-32 %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=CHECK-CONFLICT-M

# CHECK-NO-M-CONFIG: error: no ztt (AME) matrix register count feature enabled
# CHECK-CONFLICT-M: error: conflicting ztt (AME) matrix register bounds chosen; cannot enable both 16 and 32 matrix registers simultaneously

# RUN: not llvm-mc -triple=riscv64 --mattr=-experimental-ztt-ame-accregs-1,-experimental-ztt-ame-accregs-2,-experimental-ztt-ame-accregs-4 %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=CHECK-NO-ACC-CONFIG
# RUN: not llvm-mc -triple=riscv64 --mattr=+experimental-ztt-ame-accregs-1,+experimental-ztt-ame-accregs-2 %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=CHECK-CONFLICT-ACC

# CHECK-NO-ACC-CONFIG: error: no ztt (AME) accumulator register count feature enabled
# CHECK-CONFLICT-ACC: error: conflicting ztt (AME) accumulator register bounds chosen; cannot enable multiple accumulator register configurations simultaneously

# RUN: not llvm-mc -triple=riscv64 -show-encoding --mattr=+experimental-ztt %s 2>&1 \
# RUN:   | FileCheck %s --check-prefixes=CHECK
# RUN: not llvm-mc -triple=riscv32 -show-encoding --mattr=+experimental-ztt %s 2>&1 \
# RUN:   | FileCheck %s --check-prefixes=CHECK
# RUN: not llvm-mc -triple=riscv64 -show-encoding --mattr=+experimental-ztt,+experimental-ztt-ame-mregs-16,-experimental-ztt-ame-mregs-32 %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=CHECK-M16
# RUN: not llvm-mc -triple=riscv64 -show-encoding --mattr=+experimental-ztt,+experimental-ztt-ame-accregs-1,-experimental-ztt-ame-accregs-2,-experimental-ztt-ame-accregs-4 %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=CHECK-ACC1
# RUN: not llvm-mc -triple=riscv64 -show-encoding --mattr=+experimental-ztt,+experimental-ztt-ame-accregs-2,-experimental-ztt-ame-accregs-4 %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=CHECK-ACC2

# Immediate underflow: Value falls below the 7-bit signed boundary
# CHECK: {{.*}}:{{[0-9]+}}:{{[0-9]+}}: error: {{invalid operand for instruction|invalid instruction}}
mshift.ew m1, m2, -65

# Immediate overflow: Value exceeds the 7-bit signed boundary
# CHECK: {{.*}}:{{[0-9]+}}:{{[0-9]+}}: error: {{invalid operand for instruction|invalid instruction}}
mshift.ew m1, m2, 64

# Base register mismatch: Instruction expects matrix register class 
# but gets scalar GPR.
# CHECK: {{.*}}:{{[0-9]+}}:{{[0-9]+}}: error: {{invalid operand for instruction|invalid instruction}}
mshift.ew x10, m2, 5

# Operand type mismatch: Instruction expects scalar register class but 
# gets accumulator register.
# CHECK: {{.*}}:{{[0-9]+}}:{{[0-9]+}}: error: register must be a GPR
msettyp m1, acc1

# Destination target mismatch: Broadcast instruction targets accumulator 
# instead of matrix register.
# CHECK: {{.*}}:{{[0-9]+}}:{{[0-9]+}}: error: {{invalid operand for instruction|invalid instruction}}
mbcast.x acc1, a0

# Syntax error: Operand count is lower than instruction signature requirements
# CHECK: {{.*}}:{{[0-9]+}}:{{[0-9]+}}: error: too few operands for instruction
mshift.ew m1, m2

# Matrix register out of bounds: Attempting to access m16 when constraint 
# drops limit down to 16.
# CHECK-M16: {{.*}}:{{[0-9]+}}:{{[0-9]+}}: error: {{invalid operand for instruction|invalid instruction}}
mabs.ew m16, m2

# Accumulator register out of bounds: Attempting to access acc1 when configuration 
# limits context to 1 accumulator (acc0).
# CHECK-ACC1: {{.*}}:{{[0-9]+}}:{{[0-9]+}}: error: {{invalid operand for instruction|invalid instruction}}
agettyp a0, acc1

# Accumulator register out of bounds: Attempting to access acc2 when configuration 
# limits context to 2 accumulators (acc0-acc1).
# CHECK-ACC2: {{.*}}:{{[0-9]+}}:{{[0-9]+}}: error: {{invalid operand for instruction|invalid instruction}}
agettyp a0, acc2
