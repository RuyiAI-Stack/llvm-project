//===- IntrinsicsRISCVXBBPebble.td ----------------------------------------===//
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//===----------------------------------------------------------------------===//

let TargetPrefix = "riscv" in
def int_riscv_bb_mul_warp16 : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], []>;

let TargetPrefix = "riscv" in
def int_riscv_bb_relu : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], []>;

let TargetPrefix = "riscv" in
def int_riscv_bb_transpose : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], []>;

let TargetPrefix = "riscv" in
def int_riscv_bb_im2col : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], []>;

let TargetPrefix = "riscv" in
def int_riscv_bb_fp2int : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], []>;

let TargetPrefix = "riscv" in
def int_riscv_bb_int2fp : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], []>;
