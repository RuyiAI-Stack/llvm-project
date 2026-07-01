//===- RISCVInstrInfoXBBMeteor.td -----------------------------------------===//
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
// Buckyball Meteor Large Language Model Extension.
//
//===----------------------------------------------------------------------===//

let isCodeGenOnly = 1, Predicates = [HasVendorXBBMeteor] in
def BB_BBFP_MUL : RVInstR<0b1000001, 0b011, OPC_CUSTOM_3, (outs),
                          (ins GPR:$rs1, GPR:$rs2), "bb_bbfp_mul",
                          "$rs1, $rs2"> {
  let rd = 0;
}

let Predicates = [HasVendorXBBMeteor] in
def : Pat<(int_riscv_bb_bbfp_mul GPR:$rs1, GPR:$rs2),
          (BB_BBFP_MUL GPR:$rs1, GPR:$rs2)>;
