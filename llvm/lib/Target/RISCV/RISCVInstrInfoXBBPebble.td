//===- RISCVInstrInfoXBBPebble.td -----------------------------------------===//
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
//
// Buckyball Pebble CNN Extension.
//
//===----------------------------------------------------------------------===//

let isCodeGenOnly = 1, Predicates = [HasVendorXBBPebble] in
def BB_MUL_WARP16 : RVInstR<0b1000000, 0b011, OPC_CUSTOM_3, (outs),
                            (ins GPR:$rs1, GPR:$rs2), "bb_mul_warp16",
                            "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBBPebble] in
def BB_RELU : RVInstR<0b0110010, 0b011, OPC_CUSTOM_3, (outs),
                      (ins GPR:$rs1, GPR:$rs2), "bb_relu", "$rs1, $rs2"> {
  let rd = 0;
}

let isCodeGenOnly = 1, Predicates = [HasVendorXBBPebble] in
def BB_TRANSPOSE : RVInstR<0b0110001, 0b011, OPC_CUSTOM_3, (outs),
                           (ins GPR:$rs1, GPR:$rs2), "bb_transpose",
                           "$rs1, $rs2"> {
  let rd = 0;
}

let isCodeGenOnly = 1, Predicates = [HasVendorXBBPebble] in
def BB_IM2COL : RVInstR<0b0110000, 0b011, OPC_CUSTOM_3, (outs),
                        (ins GPR:$rs1, GPR:$rs2), "bb_im2col",
                        "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBBPebble] in
def BB_FP2INT : RVInstR<0b0110011, 0b011, OPC_CUSTOM_3, (outs),
                        (ins GPR:$rs1, GPR:$rs2), "bb_quant", "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBBPebble] in
def BB_INT2FP : RVInstR<0b0110100, 0b011, OPC_CUSTOM_3, (outs),
                        (ins GPR:$rs1, GPR:$rs2), "bb_dequant",
                        "$rs1, $rs2"> {
  let rd = 0;
}

let Predicates = [HasVendorXBBPebble] in
def : Pat<(int_riscv_bb_mul_warp16 GPR:$rs1, GPR:$rs2),
          (BB_MUL_WARP16 GPR:$rs1, GPR:$rs2)>;

let Predicates = [HasVendorXBBPebble] in
def : Pat<(int_riscv_bb_relu GPR:$rs1, GPR:$rs2),
          (BB_RELU GPR:$rs1, GPR:$rs2)>;

let Predicates = [HasVendorXBBPebble] in
def : Pat<(int_riscv_bb_transpose GPR:$rs1, GPR:$rs2),
          (BB_TRANSPOSE GPR:$rs1, GPR:$rs2)>;

let Predicates = [HasVendorXBBPebble] in
def : Pat<(int_riscv_bb_im2col GPR:$rs1, GPR:$rs2),
          (BB_IM2COL GPR:$rs1, GPR:$rs2)>;

let Predicates = [HasVendorXBBPebble] in
def : Pat<(int_riscv_bb_fp2int GPR:$rs1, GPR:$rs2),
          (BB_FP2INT GPR:$rs1, GPR:$rs2)>;

let Predicates = [HasVendorXBBPebble] in
def : Pat<(int_riscv_bb_int2fp GPR:$rs1, GPR:$rs2),
          (BB_INT2FP GPR:$rs1, GPR:$rs2)>;
