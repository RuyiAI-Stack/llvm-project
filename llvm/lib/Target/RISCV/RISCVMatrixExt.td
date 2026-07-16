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
  foreach i = 0 - 7 in { def BOSCAMETR #i : BOSCAMETileReg<i, "tr" #i>; }

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
  foreach i = 0 - 7 in { def BOSCAMEACC #i : BOSCAMEAccReg<i, "acc" #i>; }

  // Base class for XuanTie AME Matrix Registers (m0-m7)
  class THeadAMEMatrixReg<bits<3> Enc, string n> : Register<n> {
    let HWEncoding{2 - 0} = Enc;
    let HWEncoding{4 - 3} = 0b10;
  }

  // Define 8 XuanTie AME Matrix Registers: m0-m7
  // Upstream RISCVRegisterInfo.td already defines M0-M7 as mask registers. Keep
  // the TableGen def names distinct while preserving the XTAME assembly names.
  foreach i = 0 - 7 in{def THeadAMEM #i: THeadAMEMatrixReg<i, "amem" #i>;
}
} // End Namespace = "RISCV"

//===----------------------------------------------------------------------===//
// AME Register Classes
//===----------------------------------------------------------------------===//
// These register classes define the operand types for AME instructions
//===----------------------------------------------------------------------===//

// Tile Register class (tr0-tr7)
// Used for input operands in matrix multiplication and load/store of input
// matrices
// Note: Size is set to 256 as a placeholder; actual size depends on
// MLEN
def BOSCAMETileReg : RegisterClass<"RISCV", [untyped], 256,
                                   (add(sequence "BOSCAMETR%u", 0, 7))> {
  let Size = 256; // Placeholder: actual MLEN is hardware-defined
}

// Accumulation Register class (acc0-acc7)
// Used for output/accumulator in matrix multiplication and load/store of
// output/accumulator
// Note: Size can be 256×AMUL where AMUL ∈ {1/8, 1/4, 1/2, 1,
// 2, 4, 8}.
// We use 1024 as a reasonable upper bound (256 × 4 for int8→int32)
def BOSCAMEAccReg : RegisterClass<"RISCV", [untyped], 1024,
                                  (add(sequence "BOSCAMEACC%u", 0, 7))> {
  let Size = 1024; // Placeholder: actual MLEN×AMUL is hardware-defined
}

// XuanTie AME Matrix Register class.
def THeadAMEMatrixReg : RegisterClass<"RISCV", [untyped], 1024,
                                      (add(sequence "THeadAMEM%u", 0, 7))> {
  let Size = 1024; // Placeholder: actual MLEN is hardware-defined
}

include "RISCVInstrInfoXBOSCAME.td"
include "RISCVInstrInfoXTHeadAME.td"
include "RISCVInstrInfoZtt.td"
