//===- RISCVMatrixExt.td --------------------------------------------------===//
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
// This file contains shared matrix register definitions and instruction
// includes for vendor matrix extensions.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Vendor-Specific AME (RISC-V Matrix Extension) Register Definitions
//===----------------------------------------------------------------------===//
// Reference: Vendor-Specific RISC-V Matrix Extension Specifications
//
// Data Flow:
//   Memory → tr (via mlae/mlbe) → acc (via mma/mwma/mqma) → Memory (via msce)
//===----------------------------------------------------------------------===//

let Namespace = "RISCV" in {

  // Base class for BOSCAME Tile Registers (tr0-7)
  // Used for input matrices A and B
  // Size: MLEN bits per register (hardware-defined)
  class BOSCAMETileReg<bits<3> Enc, string n> : Register<n> {
    let HWEncoding{2 - 0} = Enc;
    let HWEncoding{4 - 3} = 0b00; // Distinguish from accumulation registers
  }

  // Define 8 BOSCAME Tile Registers: tr0-tr7
  def BOSCAMETR0 : BOSCAMETileReg<0, "tr0">;
  def BOSCAMETR1 : BOSCAMETileReg<1, "tr1">;
  def BOSCAMETR2 : BOSCAMETileReg<2, "tr2">;
  def BOSCAMETR3 : BOSCAMETileReg<3, "tr3">;
  def BOSCAMETR4 : BOSCAMETileReg<4, "tr4">;
  def BOSCAMETR5 : BOSCAMETileReg<5, "tr5">;
  def BOSCAMETR6 : BOSCAMETileReg<6, "tr6">;
  def BOSCAMETR7 : BOSCAMETileReg<7, "tr7">;

  // Base class for BOSCAME Accumulation Registers (acc0-acc7)
  // Used for output/accumulation matrix C
  // Size: MLEN × AMUL bits per register (hardware-defined)
  // Note: AMUL can be:
  //   - Fractional (1/8, 1/4, 1/2): For C = A × Bᵀ mode with large K
  //   - Integer (1, 2, 4, 8): For widening operations
  //     * AMUL=4: Required for mmi8i32 (int8→int32 quad-widen)
  //     * AMUL=2: Required for mmi16i32 (int16→int32 double-widen)
  //     * AMUL=8: Required for mmi4i32 (int4→int32 oct-widen)
  class BOSCAMEAccReg<bits<3> Enc, string n> : Register<n> {
    let HWEncoding{2 - 0} = Enc;
    let HWEncoding{4 - 3} = 0b01; // Distinguish from tile registers
  }

  // Define 8 BOSCAME Accumulation Registers: acc0-acc7
  def BOSCAMEACC0 : BOSCAMEAccReg<0, "acc0">;
  def BOSCAMEACC1 : BOSCAMEAccReg<1, "acc1">;
  def BOSCAMEACC2 : BOSCAMEAccReg<2, "acc2">;
  def BOSCAMEACC3 : BOSCAMEAccReg<3, "acc3">;
  def BOSCAMEACC4 : BOSCAMEAccReg<4, "acc4">;
  def BOSCAMEACC5 : BOSCAMEAccReg<5, "acc5">;
  def BOSCAMEACC6 : BOSCAMEAccReg<6, "acc6">;
  def BOSCAMEACC7 : BOSCAMEAccReg<7, "acc7">;

  // Base class for XuanTie AME Matrix Registers (m0-m7)
  class THeadAMEMatrixReg<bits<3> Enc, string n> : Register<n> {
    let HWEncoding{2 - 0} = Enc;
    let HWEncoding{4 - 3} = 0b10;
  }

  // Define 8 XuanTie AME Matrix Registers: m0-m7
  // Upstream RISCVRegisterInfo.td already defines M0-M7 as mask registers. Keep
  // the TableGen def names distinct while preserving the XTAME assembly names.
  def THeadAMEM0 : THeadAMEMatrixReg<0, "amem0">;
  def THeadAMEM1 : THeadAMEMatrixReg<1, "amem1">;
  def THeadAMEM2 : THeadAMEMatrixReg<2, "amem2">;
  def THeadAMEM3 : THeadAMEMatrixReg<3, "amem3">;
  def THeadAMEM4 : THeadAMEMatrixReg<4, "amem4">;
  def THeadAMEM5 : THeadAMEMatrixReg<5, "amem5">;
  def THeadAMEM6 : THeadAMEMatrixReg<6, "amem6">;
  def THeadAMEM7 : THeadAMEMatrixReg<7, "amem7">;

} // End Namespace = "RISCV"

//===----------------------------------------------------------------------===//
// AME Register Classes
//===----------------------------------------------------------------------===//
// These register classes define the operand types for AME instructions
//===----------------------------------------------------------------------===//

// Tile Register class (tr0-tr7)
// Used for input operands in matrix multiplication and load/store of input
// matrices Note: Size is set to 256 as a placeholder; actual size depends on
// MLEN
def BOSCAMETileReg
    : RegisterClass<"RISCV", [untyped], 256,
                    (add BOSCAMETR0, BOSCAMETR1, BOSCAMETR2, BOSCAMETR3,
                     BOSCAMETR4, BOSCAMETR5, BOSCAMETR6, BOSCAMETR7)> {
  let Size = 256; // Placeholder: actual MLEN is hardware-defined
}

// Accumulation Register class (acc0-acc7)
// Used for output/accumulator in matrix multiplication and load/store of
// output/accumulator Note: Size can be 256×AMUL where AMUL ∈ {1/8, 1/4, 1/2, 1,
// 2, 4, 8} We use 1024 as a reasonable upper bound (256 × 4 for int8→int32)
def BOSCAMEAccReg
    : RegisterClass<"RISCV", [untyped], 1024,
                    (add BOSCAMEACC0, BOSCAMEACC1, BOSCAMEACC2, BOSCAMEACC3,
                     BOSCAMEACC4, BOSCAMEACC5, BOSCAMEACC6, BOSCAMEACC7)> {
  let Size = 1024; // Placeholder: actual MLEN×AMUL is hardware-defined
}

// XuanTie AME matrix register class.
def THeadAMEMatrixReg
    : RegisterClass<"RISCV", [untyped], 1024,
                    (add THeadAMEM0, THeadAMEM1, THeadAMEM2, THeadAMEM3,
                     THeadAMEM4, THeadAMEM5, THeadAMEM6, THeadAMEM7)> {
  let Size = 1024; // Placeholder: actual MLEN is hardware-defined
}

include "RISCVInstrInfoXBOSCAME.td"
include "RISCVInstrInfoXTHeadAME.td"
