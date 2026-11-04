//===- IntrinsicsRISCVXSAIZamesZmasync.td - Zames/Zmasync intrinsics -*- tablegen -*-===//
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
  class XSAI_ZAMES_SetCfgIntrinsic
      : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty],
                  [IntrNoMem, IntrHasSideEffects, ImmArg<ArgIndex<0>>,
                   Range<ArgIndex<0>, 0, 8>]>;
  class XSAI_ZAMES_GetCfgIntrinsic
      : Intrinsic<[llvm_i64_ty], [llvm_i64_ty],
                  [IntrNoMem, IntrHasSideEffects, ImmArg<ArgIndex<0>>,
                   Range<ArgIndex<0>, 0, 8>]>;
  class XSAI_ZAMES_SetTileIntrinsic
      : Intrinsic<[], [llvm_i64_ty],
                  [IntrNoMem, IntrHasSideEffects, ImmArg<ArgIndex<0>>,
                   Range<ArgIndex<0>, 0, 1024>]>;
  class XSAI_ZAMES_SetTileRegIntrinsic
      : Intrinsic<[], [llvm_i64_ty], [IntrNoMem, IntrHasSideEffects]>;
  class XSAI_ZAMES_InitIntrinsic
      : Intrinsic<[], [], [IntrNoMem, IntrHasSideEffects]>;

  class XSAI_ZAMES_MZeroIntrinsic
      : Intrinsic<[llvm_any_ty], [], [IntrNoMem]>;
  class XSAI_ZAMES_LoadIntrinsic
      : Intrinsic<[llvm_any_ty], [llvm_ptr_ty, llvm_i64_ty],
                  [NoCapture<ArgIndex<0>>, IntrReadMem], "",
                  [SDNPMemOperand]>;
  class XSAI_ZAMES_StoreIntrinsic
      : Intrinsic<[], [llvm_any_ty, llvm_ptr_ty, llvm_i64_ty],
                  [NoCapture<ArgIndex<1>>, IntrWriteMem], "",
                  [SDNPMemOperand]>;
  class XSAI_ZAMES_WholeLoadIntrinsic
      : Intrinsic<[llvm_any_ty], [llvm_ptr_ty],
                  [NoCapture<ArgIndex<0>>, IntrReadMem], "",
                  [SDNPMemOperand]>;
  class XSAI_ZAMES_WholeStoreIntrinsic
      : Intrinsic<[], [llvm_any_ty, llvm_ptr_ty],
                  [NoCapture<ArgIndex<1>>, IntrWriteMem], "",
                  [SDNPMemOperand]>;
  class XSAI_ZAMES_MMAccIntrinsic
      : Intrinsic<[llvm_any_ty],
                  [llvm_any_ty, llvm_any_ty, LLVMMatchType<0>],
                  [IntrNoMem]>;

  def int_riscv_xsai_zames_msetcfg : XSAI_ZAMES_SetCfgIntrinsic;
  def int_riscv_xsai_zames_mgetcfg : XSAI_ZAMES_GetCfgIntrinsic;
  def int_riscv_xsai_zames_msettilemi : XSAI_ZAMES_SetTileIntrinsic;
  def int_riscv_xsai_zames_msettileni : XSAI_ZAMES_SetTileIntrinsic;
  def int_riscv_xsai_zames_msettileki : XSAI_ZAMES_SetTileIntrinsic;
  def int_riscv_xsai_zames_msettilem : XSAI_ZAMES_SetTileRegIntrinsic;
  def int_riscv_xsai_zames_msettilen : XSAI_ZAMES_SetTileRegIntrinsic;
  def int_riscv_xsai_zames_msettilek : XSAI_ZAMES_SetTileRegIntrinsic;

  def int_riscv_xsai_zames_minit : XSAI_ZAMES_InitIntrinsic;

  def int_riscv_xsai_zames_mzero : XSAI_ZAMES_MZeroIntrinsic;
  def int_riscv_xsai_zames_mmacc : XSAI_ZAMES_MMAccIntrinsic;

  def int_riscv_xsai_zames_mla : XSAI_ZAMES_LoadIntrinsic;
  def int_riscv_xsai_zames_mlb : XSAI_ZAMES_LoadIntrinsic;
  def int_riscv_xsai_zames_mlc : XSAI_ZAMES_LoadIntrinsic;
  def int_riscv_xsai_zames_mlat : XSAI_ZAMES_LoadIntrinsic;
  def int_riscv_xsai_zames_mlbt : XSAI_ZAMES_LoadIntrinsic;
  def int_riscv_xsai_zames_mlct : XSAI_ZAMES_LoadIntrinsic;
  def int_riscv_xsai_zames_mla_whole : XSAI_ZAMES_WholeLoadIntrinsic;
  def int_riscv_xsai_zames_mlb_whole : XSAI_ZAMES_WholeLoadIntrinsic;
  def int_riscv_xsai_zames_mlc_whole : XSAI_ZAMES_WholeLoadIntrinsic;

  def int_riscv_xsai_zames_msa : XSAI_ZAMES_StoreIntrinsic;
  def int_riscv_xsai_zames_msb : XSAI_ZAMES_StoreIntrinsic;
  def int_riscv_xsai_zames_msc : XSAI_ZAMES_StoreIntrinsic;
  def int_riscv_xsai_zames_msat : XSAI_ZAMES_StoreIntrinsic;
  def int_riscv_xsai_zames_msbt : XSAI_ZAMES_StoreIntrinsic;
  def int_riscv_xsai_zames_msct : XSAI_ZAMES_StoreIntrinsic;
  def int_riscv_xsai_zames_msa_whole : XSAI_ZAMES_WholeStoreIntrinsic;
  def int_riscv_xsai_zames_msb_whole : XSAI_ZAMES_WholeStoreIntrinsic;
  def int_riscv_xsai_zames_msc_whole : XSAI_ZAMES_WholeStoreIntrinsic;

  class XSAI_ZMASYNC_SyncResetIntrinsic
      : Intrinsic<[llvm_any_ty], [], [IntrNoMem, IntrHasSideEffects]>;
  class XSAI_ZMASYNC_ReleaseIntrinsic
      : Intrinsic<[llvm_any_ty], [LLVMMatchType<0>],
                  [IntrNoMem, IntrHasSideEffects]>;
  class XSAI_ZMASYNC_AcquireIntrinsic
      : Intrinsic<[], [llvm_any_ty, llvm_i64_ty],
                  [IntrNoMem, IntrHasSideEffects]>;
  class XSAI_ZMASYNC_FenceIntrinsic
      : Intrinsic<[], [], [IntrNoMem, IntrHasSideEffects]>;

  def int_riscv_xsai_zmasync_msyncregreset : XSAI_ZMASYNC_SyncResetIntrinsic;
  def int_riscv_xsai_zmasync_mrelease : XSAI_ZMASYNC_ReleaseIntrinsic;
  def int_riscv_xsai_zmasync_macquire : XSAI_ZMASYNC_AcquireIntrinsic;
  def int_riscv_xsai_zmasync_mfence : XSAI_ZMASYNC_FenceIntrinsic;
}
