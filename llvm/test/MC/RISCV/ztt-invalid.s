# RUN: not llvm-mc -triple=riscv64 --mattr=-experimental-ztt-ame-mregs-16,-experimental-ztt-ame-mregs-32 %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=CHECK-NO-M-CONFIG
# RUN: not llvm-mc -triple=riscv64 --mattr=+experimental-ztt-ame-mregs-16,+experimental-ztt-ame-mregs-32 %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=CHECK-CONFLICT-M

# CHECK-NO-M-CONFIG: error: AME subtarget extension requires a matrix register configuration width to be chosen
# CHECK-CONFLICT-M: error: Conflicting AME register bounds chosen: cannot enable both 16 and 32 matrix registers simultaneously

# RUN: not llvm-mc -triple=riscv64 --mattr=-experimental-ztt-ame-accregs-1,-experimental-ztt-ame-accregs-2,-experimental-ztt-ame-accregs-4 %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=CHECK-NO-ACC-CONFIG
# RUN: not llvm-mc -triple=riscv64 --mattr=+experimental-ztt-ame-accregs-1,+experimental-ztt-ame-accregs-2 %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=CHECK-CONFLICT-ACC

# CHECK-NO-ACC-CONFIG: error: AME subtarget extension requires an accumulator register configuration count to be chosen
# CHECK-CONFLICT-ACC: error: Conflicting AME accumulator bounds chosen: cannot enable multiple accumulator register configurations simultaneously

# RUN: not llvm-mc -triple=riscv64 -show-encoding --mattr=+experimental-ztt %s 2>&1 \
# RUN:   | FileCheck %s --check-prefixes=CHECK,CHECK-64
# RUN: not llvm-mc -triple=riscv32 -show-encoding --mattr=+experimental-ztt %s 2>&1 \
# RUN:   | FileCheck %s --check-prefixes=CHECK,CHECK-32
# RUN: not llvm-mc -triple=riscv64 -show-encoding --mattr=+experimental-ztt,+experimental-ztt-ame-mregs-16 %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=CHECK-M16
# RUN: not llvm-mc -triple=riscv64 -show-encoding --mattr=+experimental-ztt,+experimental-ztt-ame-accregs-1 %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=CHECK-ACC1
# RUN: not llvm-mc -triple=riscv64 -show-encoding --mattr=+experimental-ztt,+experimental-ztt-ame-accregs-2 %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=CHECK-ACC2

# Immediate underflow: Value falls below the 7-bit signed boundary
# CHECK: :[[@LINE+1]]:24: error: immediate must be an integer in the range [-64, 63]
mshift.ew m1, m2, -65

# Immediate overflow: Value exceeds the 7-bit signed boundary
# CHECK: :[[@LINE+1]]:23: error: immediate must be an integer in the range [-64, 63]
mshift.ew m1, m2, 64

# Base register mismatch: Instruction expects matrix register class 
# but gets scalar GPR.
# CHECK: :[[@LINE+1]]:13: error: invalid operand for instruction
mshift.ew x10, m2, 5

# Operand type mismatch: Instruction expects scalar register class but 
# gets accumulator register.
# CHECK: :[[@LINE+1]]:16: error: invalid operand for instruction
msettyp m1, acc1

# Destination target mismatch: Broadcast instruction targets accumulator 
# instead of matrix register.
# CHECK: :[[@LINE+1]]:13: error: invalid operand for instruction
mbcast.x acc1, a0

# Syntax error: Operand count is lower than instruction signature requirements
# CHECK: :[[@LINE+1]]:1: error: too few operands for instruction
mshift.ew m1, m2

# Matrix register out of bounds: Attempting to access m16 when constraint 
# drops limit down to 16.
# CHECK-M16: :[[@LINE+1]]:11: error: invalid operand for instruction
mabs.ew m16, m2

# Accumulator register out of bounds: Attempting to access acc1 when configuration 
# limits context to 1 accumulator (acc0).
# CHECK-ACC1: :[[@LINE+1]]:14: error: invalid operand for instruction
agettyp a0, acc1

# Accumulator register out of bounds: Attempting to access acc2 when configuration 
# limits context to 2 accumulators (acc0-acc1).
# CHECK-ACC2: :[[@LINE+1]]:14: error: invalid operand for instruction
agettyp a0, acc2
