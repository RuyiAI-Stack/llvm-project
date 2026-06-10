# RUN: llvm-mc -triple=riscv64 -show-encoding --mattr=+xgemmini %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INST
# RUN: llvm-mc -triple=riscv64 -filetype=obj --mattr=+xgemmini %s \
# RUN:        | llvm-objdump -d --mattr=+xgemmini - \
# RUN:        | FileCheck %s --check-prefix=CHECK-INST
# RUN: not llvm-mc -triple=riscv64 --mattr=+xsmtime < %s 2>&1 \
# RUN:        | FileCheck %s --check-prefix=CHECK-NO-XGEMMINI

mvin ra, sp
# CHECK-INST: mvin ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x04]
# CHECK-NO-XGEMMINI: instruction requires the following: 'XGemmini' (Gemmini extension){{$}}

mvin2 ra, sp
# CHECK-INST: mvin2 ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x02]

mvin3 ra, sp
# CHECK-INST: mvin3 ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x1c]

mvout ra, sp
# CHECK-INST: mvout ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x06]

flush ra
# CHECK-INST: flush ra
# CHECK-ENCODING: [0x7b,0xb0,0x00,0x0e]

config ra, sp
# CHECK-INST: config ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x00]

preload ra, sp
# CHECK-INST: preload ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x0c]

compute_preloaded ra, sp
# CHECK-INST: compute_preloaded ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x08]

compute_accumulated ra, sp
# CHECK-INST: compute_accumulated ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x0a]

loop_ws_config_bounds ra, sp
# CHECK-INST: loop_ws_config_bounds ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x12]

loop_ws_config_addrs_ab ra, sp
# CHECK-INST: loop_ws_config_addrs_ab ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x14]

loop_ws_config_addrs_dc ra, sp
# CHECK-INST: loop_ws_config_addrs_dc ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x16]

loop_ws_config_strides_ab ra, sp
# CHECK-INST: loop_ws_config_strides_ab ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x18]

loop_ws_config_strides_dc ra, sp
# CHECK-INST: loop_ws_config_strides_dc ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x1a]

loop_ws ra, sp
# CHECK-INST: loop_ws ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x10]

loop_conv_ws ra, sp
# CHECK-INST: loop_conv_ws ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x1e]

loop_conv_ws_config1 ra, sp
# CHECK-INST: loop_conv_ws_config1 ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x20]

loop_conv_ws_config2 ra, sp
# CHECK-INST: loop_conv_ws_config2 ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x22]

loop_conv_ws_config3 ra, sp
# CHECK-INST: loop_conv_ws_config3 ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x24]

loop_conv_ws_config4 ra, sp
# CHECK-INST: loop_conv_ws_config4 ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x26]

loop_conv_ws_config5 ra, sp
# CHECK-INST: loop_conv_ws_config5 ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x28]

loop_conv_ws_config6 ra, sp
# CHECK-INST: loop_conv_ws_config6 ra, sp
# CHECK-ENCODING: [0x7b,0xb0,0x20,0x2a]
