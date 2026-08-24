//===- RISCVInstrInfoXBuckyballExt.td -------------------------------------===//
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
// Buckyball v0.1.0 base instructions.
//
//===----------------------------------------------------------------------===//

class RVInstRBuckyballCustom<bits<3> funct3, RISCVOpcode opcode, dag outs,
                             dag ins, string opcodestr, string argstr>
    : RVInstRBase<funct3, opcode, outs, ins, opcodestr, argstr> {
  bits<7> funct7;
  let Inst{31-25} = funct7;
}

def bb_tuimm7 : RISCVOp<i32>, TImmLeaf<i32, [{return isUInt<7>(Imm);}]> {
  let OperandType = "OPERAND_UIMM7";
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBuckyballBase] in
def BB_FENCE : RVInstR<0b0000000, 0b011, OPC_CUSTOM_3, (outs),
                       (ins GPR:$rs1, GPR:$rs2), "bb_fence", "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBuckyballBase] in
def BB_BARRIER : RVInstR<0b0000001, 0b011, OPC_CUSTOM_3, (outs),
                         (ins GPR:$rs1, GPR:$rs2), "bb_barrier",
                         "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBuckyballBase] in
def BB_MVOUT : RVInstR<0b0010000, 0b011, OPC_CUSTOM_3, (outs),
                       (ins GPR:$rs1, GPR:$rs2), "bb_mvout", "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBuckyballBase] in
def BB_MSET : RVInstR<0b0100000, 0b011, OPC_CUSTOM_3, (outs),
                      (ins GPR:$rs1, GPR:$rs2), "bb_mset", "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBuckyballBase] in
def BB_MVIN : RVInstR<0b0100001, 0b011, OPC_CUSTOM_3, (outs),
                      (ins GPR:$rs1, GPR:$rs2), "bb_mvin", "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBuckyballBase] in
def BB_MVIN_MMIO : RVInstR<0b0100011, 0b011, OPC_CUSTOM_3, (outs),
                           (ins GPR:$rs1, GPR:$rs2), "bb_mvin_mmio",
                           "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 1, mayLoad = 1, mayStore = 1, isCodeGenOnly = 1,
    Predicates = [HasVendorXBuckyball] in
def BB_CUSTOM : RVInstRBuckyballCustom<0b011, OPC_CUSTOM_3, (outs),
                                       (ins GPR:$rs1, GPR:$rs2,
                                            bb_tuimm7:$funct7),
                                       "bb_custom",
                                       "$funct7, $rs1, $rs2"> {
  let rd = 0;
}

let Predicates = [HasVendorXBuckyballBase] in {
  def : Pat<(int_riscv_bb_fence GPR:$rs1, GPR:$rs2),
            (BB_FENCE GPR:$rs1, GPR:$rs2)>;
  def : Pat<(int_riscv_bb_barrier GPR:$rs1, GPR:$rs2),
            (BB_BARRIER GPR:$rs1, GPR:$rs2)>;
  def : Pat<(int_riscv_bb_mvout GPR:$rs1, GPR:$rs2),
            (BB_MVOUT GPR:$rs1, GPR:$rs2)>;
  def : Pat<(int_riscv_bb_mset GPR:$rs1, GPR:$rs2),
            (BB_MSET GPR:$rs1, GPR:$rs2)>;
  def : Pat<(int_riscv_bb_mvin GPR:$rs1, GPR:$rs2),
            (BB_MVIN GPR:$rs1, GPR:$rs2)>;
  def : Pat<(int_riscv_bb_mvin_mmio GPR:$rs1, GPR:$rs2),
            (BB_MVIN_MMIO GPR:$rs1, GPR:$rs2)>;
}

let Predicates = [HasVendorXBuckyball] in
def : Pat<(int_riscv_buckyball_custom GPR:$rs1, GPR:$rs2, bb_tuimm7:$funct7),
          (BB_CUSTOM GPR:$rs1, GPR:$rs2, bb_tuimm7:$funct7)>;

include "RISCVInstrInfoXBBPebble.td"
