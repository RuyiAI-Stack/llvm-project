; RUN: llc -mtriple=riscv64 -mattr=+zmasync < %s \
; RUN:   | FileCheck %s --check-prefix=ASM
; RUN: llc -mtriple=riscv64 -mattr=+zmasync -filetype=obj -o %t.o < %s
; RUN: llvm-readelf -A %t.o | FileCheck %s --check-prefix=OBJ

; Pins the exact ELF arch-attribute string for ZMASYNC: +zmasync implies
; +zames and the canonical ordering lists zmasync before zames.

; ASM: .attribute 5, "rv64i2p1_zmasync1p0_zames1p0"

; OBJ:      TagName: arch
; OBJ-NEXT: Value: rv64i2p1_zmasync1p0_zames1p0

define void @empty() {
  ret void
}
