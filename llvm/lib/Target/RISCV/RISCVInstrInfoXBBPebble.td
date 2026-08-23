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
// Named encodings for the Pebble core ballISA.
// funct7 matches examples/cores/pebble/configs/balldomains/default.toml.
// Compiler still emits Ball ops via bb_custom; these exist for MC/asm.
//
//   IM2COL          48 = 0b0110000  enable=011 (1rd+1wr)
//   TRANSPOSE       49 = 0b0110001
//   FP2INT          51 = 0b0110011
//   INT2FP_TENSOR   52 = 0b0110100
//   INT2FP_CHANNEL  54 = 0b0110110
//   SMATMUL_OS      65 = 0b1000001  enable=100 (2rd+1wr)
//   SMATMUL_WS      68 = 0b1000100
//
//===----------------------------------------------------------------------===//

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBBPebble] in
def BB_IM2COL : RVInstR<0b0110000, 0b011, OPC_CUSTOM_3, (outs),
                        (ins GPR:$rs1, GPR:$rs2), "bb_im2col",
                        "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBBPebble] in
def BB_TRANSPOSE : RVInstR<0b0110001, 0b011, OPC_CUSTOM_3, (outs),
                           (ins GPR:$rs1, GPR:$rs2), "bb_transpose",
                           "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBBPebble] in
def BB_FP2INT : RVInstR<0b0110011, 0b011, OPC_CUSTOM_3, (outs),
                        (ins GPR:$rs1, GPR:$rs2), "bb_fp2int",
                        "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBBPebble] in
def BB_INT2FP_TENSOR : RVInstR<0b0110100, 0b011, OPC_CUSTOM_3, (outs),
                               (ins GPR:$rs1, GPR:$rs2),
                               "bb_int2fp_tensor", "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBBPebble] in
def BB_INT2FP_CHANNEL : RVInstR<0b0110110, 0b011, OPC_CUSTOM_3, (outs),
                                (ins GPR:$rs1, GPR:$rs2),
                                "bb_int2fp_channel", "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBBPebble] in
def BB_SMATMUL_OS : RVInstR<0b1000001, 0b011, OPC_CUSTOM_3, (outs),
                            (ins GPR:$rs1, GPR:$rs2), "bb_smatmul_os",
                            "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBBPebble] in
def BB_SMATMUL_WS : RVInstR<0b1000100, 0b011, OPC_CUSTOM_3, (outs),
                            (ins GPR:$rs1, GPR:$rs2), "bb_smatmul_ws",
                            "$rs1, $rs2"> {
  let rd = 0;
}

let Predicates = [HasVendorXBBPebble] in {
  def : Pat<(int_riscv_bb_im2col GPR:$rs1, GPR:$rs2),
            (BB_IM2COL GPR:$rs1, GPR:$rs2)>;
  def : Pat<(int_riscv_bb_transpose GPR:$rs1, GPR:$rs2),
            (BB_TRANSPOSE GPR:$rs1, GPR:$rs2)>;
  def : Pat<(int_riscv_bb_fp2int GPR:$rs1, GPR:$rs2),
            (BB_FP2INT GPR:$rs1, GPR:$rs2)>;
  def : Pat<(int_riscv_bb_int2fp_tensor GPR:$rs1, GPR:$rs2),
            (BB_INT2FP_TENSOR GPR:$rs1, GPR:$rs2)>;
  def : Pat<(int_riscv_bb_int2fp_channel GPR:$rs1, GPR:$rs2),
            (BB_INT2FP_CHANNEL GPR:$rs1, GPR:$rs2)>;
  def : Pat<(int_riscv_bb_smatmul_os GPR:$rs1, GPR:$rs2),
            (BB_SMATMUL_OS GPR:$rs1, GPR:$rs2)>;
  def : Pat<(int_riscv_bb_smatmul_ws GPR:$rs1, GPR:$rs2),
            (BB_SMATMUL_WS GPR:$rs1, GPR:$rs2)>;
}
