; RUN: not --crash llc -mtriple=riscv64 -mattr=+xame -verify-machineinstrs -o /dev/null %s 2>&1 | FileCheck %s

; Both matrix dimensions must match the selected fixed XAME profile.
define target("riscv.ztt.matrix", i32, 4, 4)
    @invalid_matrix_shape(
      target("riscv.ztt.matrix", i32, 4, 4) %m) {
  ret target("riscv.ztt.matrix", i32, 4, 4) %m
}

; CHECK: LLVM ERROR: ZTT matrix shape does not match the selected xame profile
