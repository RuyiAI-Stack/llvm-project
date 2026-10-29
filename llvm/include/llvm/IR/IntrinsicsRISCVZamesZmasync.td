//===- IntrinsicsRISCVZamesZmasync.td - Zames/Zmasync intrinsics -*- tablegen -*-===//
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

let TargetPrefix = "riscv" in {
  class ZAMESSetCfgIntrinsic
      : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty],
                  [IntrNoMem, IntrHasSideEffects, ImmArg<ArgIndex<0>>,
                   Range<ArgIndex<0>, 0, 8>]>;
  class ZAMESGetCfgIntrinsic
      : Intrinsic<[llvm_i64_ty], [llvm_i64_ty],
                  [IntrNoMem, IntrHasSideEffects, ImmArg<ArgIndex<0>>,
                   Range<ArgIndex<0>, 0, 8>]>;
  class ZAMESSetTileIntrinsic
      : Intrinsic<[], [llvm_i64_ty],
                  [IntrNoMem, IntrHasSideEffects, ImmArg<ArgIndex<0>>,
                   Range<ArgIndex<0>, 0, 1024>]>;
  class ZAMESSetTileRegIntrinsic
      : Intrinsic<[], [llvm_i64_ty], [IntrNoMem, IntrHasSideEffects]>;
  class ZAMESInitIntrinsic
      : Intrinsic<[], [], [IntrNoMem, IntrHasSideEffects]>;

  class ZAMESMZeroIntrinsic
      : Intrinsic<[llvm_any_ty], [], [IntrNoMem]>;
  class ZAMESLoadIntrinsic
      : Intrinsic<[llvm_any_ty], [llvm_ptr_ty, llvm_i64_ty],
                  [NoCapture<ArgIndex<0>>, IntrReadMem], "",
                  [SDNPMemOperand]>;
  class ZAMESStoreIntrinsic
      : Intrinsic<[], [llvm_any_ty, llvm_ptr_ty, llvm_i64_ty],
                  [NoCapture<ArgIndex<1>>, IntrWriteMem], "",
                  [SDNPMemOperand]>;
  class ZAMESWholeLoadIntrinsic
      : Intrinsic<[llvm_any_ty], [llvm_ptr_ty],
                  [NoCapture<ArgIndex<0>>, IntrReadMem], "",
                  [SDNPMemOperand]>;
  class ZAMESWholeStoreIntrinsic
      : Intrinsic<[], [llvm_any_ty, llvm_ptr_ty],
                  [NoCapture<ArgIndex<1>>, IntrWriteMem], "",
                  [SDNPMemOperand]>;
  class ZAMESMMAccIntrinsic
      : Intrinsic<[llvm_any_ty],
                  [llvm_any_ty, llvm_any_ty, LLVMMatchType<0>],
                  [IntrNoMem]>;

  def int_riscv_zames_msetcfg : ZAMESSetCfgIntrinsic;
  def int_riscv_zames_mgetcfg : ZAMESGetCfgIntrinsic;
  def int_riscv_zames_msettilemi : ZAMESSetTileIntrinsic;
  def int_riscv_zames_msettileni : ZAMESSetTileIntrinsic;
  def int_riscv_zames_msettileki : ZAMESSetTileIntrinsic;
  def int_riscv_zames_msettilem : ZAMESSetTileRegIntrinsic;
  def int_riscv_zames_msettilen : ZAMESSetTileRegIntrinsic;
  def int_riscv_zames_msettilek : ZAMESSetTileRegIntrinsic;

  def int_riscv_zames_minit : ZAMESInitIntrinsic;

  def int_riscv_zames_mzero : ZAMESMZeroIntrinsic;
  def int_riscv_zames_mmacc : ZAMESMMAccIntrinsic;

  def int_riscv_zames_mla : ZAMESLoadIntrinsic;
  def int_riscv_zames_mlb : ZAMESLoadIntrinsic;
  def int_riscv_zames_mlc : ZAMESLoadIntrinsic;
  def int_riscv_zames_mlat : ZAMESLoadIntrinsic;
  def int_riscv_zames_mlbt : ZAMESLoadIntrinsic;
  def int_riscv_zames_mlct : ZAMESLoadIntrinsic;
  def int_riscv_zames_mla_whole : ZAMESWholeLoadIntrinsic;
  def int_riscv_zames_mlb_whole : ZAMESWholeLoadIntrinsic;
  def int_riscv_zames_mlc_whole : ZAMESWholeLoadIntrinsic;

  def int_riscv_zames_msa : ZAMESStoreIntrinsic;
  def int_riscv_zames_msb : ZAMESStoreIntrinsic;
  def int_riscv_zames_msc : ZAMESStoreIntrinsic;
  def int_riscv_zames_msat : ZAMESStoreIntrinsic;
  def int_riscv_zames_msbt : ZAMESStoreIntrinsic;
  def int_riscv_zames_msct : ZAMESStoreIntrinsic;
  def int_riscv_zames_msa_whole : ZAMESWholeStoreIntrinsic;
  def int_riscv_zames_msb_whole : ZAMESWholeStoreIntrinsic;
  def int_riscv_zames_msc_whole : ZAMESWholeStoreIntrinsic;

  class ZMASYNCSyncResetIntrinsic
      : Intrinsic<[llvm_any_ty], [], [IntrNoMem, IntrHasSideEffects]>;
  class ZMASYNCReleaseIntrinsic
      : Intrinsic<[llvm_any_ty], [LLVMMatchType<0>],
                  [IntrNoMem, IntrHasSideEffects]>;
  class ZMASYNCAcquireIntrinsic
      : Intrinsic<[], [llvm_any_ty, llvm_i64_ty],
                  [IntrNoMem, IntrHasSideEffects]>;
  class ZMASYNCFenceIntrinsic
      : Intrinsic<[], [], [IntrNoMem, IntrHasSideEffects]>;

  def int_riscv_zmasync_msyncregreset : ZMASYNCSyncResetIntrinsic;
  def int_riscv_zmasync_mrelease : ZMASYNCReleaseIntrinsic;
  def int_riscv_zmasync_macquire : ZMASYNCAcquireIntrinsic;
  def int_riscv_zmasync_mfence : ZMASYNCFenceIntrinsic;
}
