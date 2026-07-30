# RUN: llvm-mc -triple=riscv64 -show-encoding --mattr=+experimental-ztt %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INST
# RUN: llvm-mc -triple=riscv32 -show-encoding --mattr=+experimental-ztt %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INST
# RUN: llvm-mc -triple=riscv64 -filetype=obj --mattr=+experimental-ztt %s \
# RUN:        | llvm-objdump --no-print-imm-hex -d --mattr=+experimental-ztt - \
# RUN:        | FileCheck %s --check-prefix=CHECK-INST
# RUN: llvm-mc -triple=riscv32 -filetype=obj --mattr=+experimental-ztt %s \
# RUN:        | llvm-objdump --no-print-imm-hex -d --mattr=+experimental-ztt - \
# RUN:        | FileCheck %s --check-prefix=CHECK-INST

mabs.ew m1, m2
# CHECK-INST: mabs.ew m1, m2
# CHECK-ENCODING: [0xab,0x10,0x01,0x00]

mcolunzip.ew m1, m2
# CHECK-INST: mcolunzip.ew m1, m2
# CHECK-ENCODING: [0xab,0x10,0x01,0x08]

mcolzip.ew m1, m2
# CHECK-INST: mcolzip.ew m1, m2
# CHECK-ENCODING: [0xab,0x10,0x01,0x06]

mconv.ew m1, m2
# CHECK-INST: mconv.ew m1, m2
# CHECK-ENCODING: [0xab,0x50,0x01,0x00]

mexp2.ew m1, m2
# CHECK-INST: mexp2.ew m1, m2
# CHECK-ENCODING: [0xab,0x10,0x01,0x02]

mlog2.ew m1, m2
# CHECK-INST: mlog2.ew m1, m2
# CHECK-ENCODING: [0xab,0x10,0x01,0x04]

mprefixadd.col m1, m2
# CHECK-INST: mprefixadd.col m1, m2
# CHECK-ENCODING: [0xab,0x10,0x01,0x18]

mprefixadd.row m1, m2
# CHECK-INST: mprefixadd.row m1, m2
# CHECK-ENCODING: [0xab,0x10,0x01,0x10]

mprefixmax.col m1, m2
# CHECK-INST: mprefixmax.col m1, m2
# CHECK-ENCODING: [0xab,0x10,0x01,0x1a]

mprefixmax.row m1, m2
# CHECK-INST: mprefixmax.row m1, m2
# CHECK-ENCODING: [0xab,0x10,0x01,0x12]

mreduceadd.col m1, m2
# CHECK-INST: mreduceadd.col m1, m2
# CHECK-ENCODING: [0xab,0x10,0x01,0x14]

mreduceadd.row m1, m2
# CHECK-INST: mreduceadd.row m1, m2
# CHECK-ENCODING: [0xab,0x10,0x01,0x0c]

mreducemax.col m1, m2
# CHECK-INST: mreducemax.col m1, m2
# CHECK-ENCODING: [0xab,0x10,0x01,0x16]

mreducemax.row m1, m2
# CHECK-INST: mreducemax.row m1, m2
# CHECK-ENCODING: [0xab,0x10,0x01,0x0e]

mrowunzip.ew m1, m2
# CHECK-INST: mrowunzip.ew m1, m2
# CHECK-ENCODING: [0xab,0x10,0x01,0x0a]

mabsdiff.ew m1, m2, m3
# CHECK-INST: mabsdiff.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x08]

madd.ew m1, m2, m3
# CHECK-INST: madd.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x00]

mand.ew m1, m2, m3
# CHECK-INST: mand.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x0e]

mandnot.ew m1, m2, m3
# CHECK-INST: mandnot.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x10]

mcmovge.ew m1, m2, m3
# CHECK-INST: mcmovge.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x20]

mcmovlt.ew m1, m2, m3
# CHECK-INST: mcmovlt.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x22]

mcmpge.ew m1, m2, m3
# CHECK-INST: mcmpge.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x18]

mcmplt.ew m1, m2, m3
# CHECK-INST: mcmplt.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x1a]

mgather.ew m1, m2, m3
# CHECK-INST: mgather.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x30]

mhdiff.ew m1, m2, m3
# CHECK-INST: mhdiff.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x06]

mldexp.ew m1, m2, m3
# CHECK-INST: mldexp.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x24]

mldexpacc.ew m1, m2, m3
# CHECK-INST: mldexpacc.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x26]

mlog2sub.ew m1, m2, m3
# CHECK-INST: mlog2sub.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x2c]

mmax.ew m1, m2, m3
# CHECK-INST: mmax.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x0a]

mmean.ew m1, m2, m3
# CHECK-INST: mmean.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x04]

mmin.ew m1, m2, m3
# CHECK-INST: mmin.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x0c]

mmul.ew m1, m2, m3
# CHECK-INST: mmul.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x38]

mmulacc.ew m1, m2, m3
# CHECK-INST: mmulacc.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x3a]

mmulaccneg.ew m1, m2, m3
# CHECK-INST: mmulaccneg.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x40]

mmuladd.ew m1, m2, m3
# CHECK-INST: mmuladd.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x3c]

mmulneg.ew m1, m2, m3
# CHECK-INST: mmulneg.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x42]

mmulsub.ew m1, m2, m3
# CHECK-INST: mmulsub.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x3e]

mor.ew m1, m2, m3
# CHECK-INST: mor.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x12]

mornot.ew m1, m2, m3
# CHECK-INST: mornot.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x14]

mrdexp.ew m1, m2, m3
# CHECK-INST: mrdexp.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x28]

mrdexpacc.ew m1, m2, m3
# CHECK-INST: mrdexpacc.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x2a]

mrowzip.ew m1, m2, m3
# CHECK-INST: mrowzip.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x36]

mscatadd.col m1, m2, m3
# CHECK-INST: mscatadd.col m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x44]

mscatadd.row m1, m2, m3
# CHECK-INST: mscatadd.row m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x32]

mscatmax.col m1, m2, m3
# CHECK-INST: mscatmax.col m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x46]

mscatmax.row m1, m2, m3
# CHECK-INST: mscatmax.row m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x34]

mselge.ew m1, m2, m3
# CHECK-INST: mselge.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x1c]

msellt.ew m1, m2, m3
# CHECK-INST: msellt.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x1e]

msub.ew m1, m2, m3
# CHECK-INST: msub.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x02]

msublog2.ew m1, m2, m3
# CHECK-INST: msublog2.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x2e]

mxor.ew m1, m2, m3
# CHECK-INST: mxor.ew m1, m2, m3
# CHECK-ENCODING: [0xab,0x00,0x31,0x16]

mabsdiff.ew.x m1, a0, m3
# CHECK-INST: mabsdiff.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x0a]

madd.ew.x m1, a0, m3
# CHECK-INST: madd.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x00]

mand.ew.x m1, a0, m3
# CHECK-INST: mand.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x0e]

mandnot.ew.x m1, a0, m3
# CHECK-INST: mandnot.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x10]

mcmpge.ew.x m1, a0, m3
# CHECK-INST: mcmpge.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x18]

mcmplt.ew.x m1, a0, m3
# CHECK-INST: mcmplt.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x1a]

mhdiff.ew.x m1, a0, m3
# CHECK-INST: mhdiff.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x0c]

mldexp.ew.x m1, a0, m3
# CHECK-INST: mldexp.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x20]

mldexpacc.ew.x m1, a0, m3
# CHECK-INST: mldexpacc.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x22]

mlog2sub.ew.x m1, a0, m3
# CHECK-INST: mlog2sub.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x1c]

mmax.ew.x m1, a0, m3
# CHECK-INST: mmax.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x06]

mmean.ew.x m1, a0, m3
# CHECK-INST: mmean.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x08]

mmin.ew.x m1, a0, m3
# CHECK-INST: mmin.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x04]

mmul.ew.x m1, a0, m3
# CHECK-INST: mmul.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x24]

mmulacc.ew.x m1, a0, m3
# CHECK-INST: mmulacc.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x26]

mmulaccneg.ew.x m1, a0, m3
# CHECK-INST: mmulaccneg.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x2c]

mmuladd.ew.x m1, a0, m3
# CHECK-INST: mmuladd.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x28]

mmulneg.ew.x m1, a0, m3
# CHECK-INST: mmulneg.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x2e]

mmulsub.ew.x m1, a0, m3
# CHECK-INST: mmulsub.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x2a]

mor.ew.x m1, a0, m3
# CHECK-INST: mor.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x12]

mornot.ew.x m1, a0, m3
# CHECK-INST: mornot.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x14]

msub.ew.x m1, a0, m3
# CHECK-INST: msub.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x02]

msublog2.ew.x m1, a0, m3
# CHECK-INST: msublog2.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x1e]

mxor.ew.x m1, a0, m3
# CHECK-INST: mxor.ew.x m1, a0, m3
# CHECK-ENCODING: [0xab,0x20,0x35,0x16]

mmul.2d acc1, m2, m3
# CHECK-INST: mmul.2d acc1, m2, m3
# CHECK-ENCODING: [0x2b,0x21,0x31,0x00]

mmulacc.2d acc1, m2, m3
# CHECK-INST: mmulacc.2d acc1, m2, m3
# CHECK-ENCODING: [0x2b,0x21,0x31,0x02]

mmulaccneg.2d acc1, m2, m3
# CHECK-INST: mmulaccneg.2d acc1, m2, m3
# CHECK-ENCODING: [0x2b,0x21,0x31,0x06]

mmulat.2d acc1, m2, m3
# CHECK-INST: mmulat.2d acc1, m2, m3
# CHECK-ENCODING: [0x2b,0x21,0x31,0x08]

mmulatacc.2d acc1, m2, m3
# CHECK-INST: mmulatacc.2d acc1, m2, m3
# CHECK-ENCODING: [0x2b,0x21,0x31,0x0a]

mmulbt.2d acc1, m2, m3
# CHECK-INST: mmulbt.2d acc1, m2, m3
# CHECK-ENCODING: [0x2b,0x21,0x31,0x0c]

mmulbtacc.2d acc1, m2, m3
# CHECK-INST: mmulbtacc.2d acc1, m2, m3
# CHECK-ENCODING: [0x2b,0x21,0x31,0x0e]

mmulneg.2d acc1, m2, m3
# CHECK-INST: mmulneg.2d acc1, m2, m3
# CHECK-ENCODING: [0x2b,0x21,0x31,0x04]

# Interoperability loads (md, xs1:address)
mls m1, a0
# CHECK-INST: mls m1, a0
# CHECK-ENCODING: [0xab,0x30,0x05,0x04]

mls.cm m1, a0
# CHECK-INST: mls.cm m1, a0
# CHECK-ENCODING: [0xab,0x30,0x05,0x02]

mls.rm m1, a0
# CHECK-INST: mls.rm m1, a0
# CHECK-ENCODING: [0xab,0x30,0x05,0x00]

# Interoperability stores (ms1, xs1:address)
mss m1, a0
# CHECK-INST: mss m1, a0
# CHECK-ENCODING: [0xab,0x30,0x05,0x0a]

mss.cm m1, a0
# CHECK-INST: mss.cm m1, a0
# CHECK-ENCODING: [0xab,0x30,0x05,0x08]

mss.rm m1, a0
# CHECK-INST: mss.rm m1, a0
# CHECK-ENCODING: [0xab,0x30,0x05,0x06]

mzero.2d acc1
# CHECK-INST: mzero.2d acc1
# CHECK-ENCODING: [0x2b,0x45,0x00,0x10]

mmov.a.m m1, acc2
# CHECK-INST: mmov.a.m m1, acc2
# CHECK-ENCODING: [0xab,0x40,0x20,0x06]

mmov.m.m m1, m2
# CHECK-INST: mmov.m.m m1, m2
# CHECK-ENCODING: [0xab,0x40,0x20,0x04]

mgettyp a0, m1
# CHECK-INST: mgettyp a0, m1
# CHECK-ENCODING: [0x2b,0xd5,0x00,0x04]

agettyp a0, acc1
# CHECK-INST: agettyp a0, acc1
# CHECK-ENCODING: [0x2b,0xd5,0x00,0x08]

msettyp m1, a0
# CHECK-INST: msettyp m1, a0
# CHECK-ENCODING: [0xab,0x50,0x05,0x02]

asettyp acc1, a0
# CHECK-INST: asettyp acc1, a0
# CHECK-ENCODING: [0x2b,0x51,0x05,0x06]

mbcast.x m1, a0
# CHECK-INST: mbcast.x m1, a0
# CHECK-ENCODING: [0xab,0x40,0x05,0x00]

mshift.ew m1, m2, 5
# CHECK-INST: mshift.ew m1, m2, 5
# CHECK-ENCODING: [0xab,0x60,0x51,0x00]

mshift.ew m1, m2, -3
# CHECK-INST: mshift.ew m1, m2, -3
# CHECK-ENCODING: [0xab,0x60,0xd1,0x07]

mshift.m1 m1, m2
# CHECK-INST: mshift.m1 m1, m2
# CHECK-ENCODING: [0xab,0x60,0xf1,0x07]

mshift.p1 m1, m2
# CHECK-INST: mshift.p1 m1, m2
# CHECK-ENCODING: [0xab,0x60,0x11,0x00]
