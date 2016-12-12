// RUN: llvm-mc -filetype=obj -triple=x86_64-unknown-linux %s -o %t.o
// RUN: llvm-mc -filetype=obj -triple=x86_64-unknown-linux %p/Inputs/shared.s -o %t2.o
// RUN: ld.lld -shared %t2.o -o %t2.so
// RUN: ld.lld %t.o %t2.so -z now -z relro -o %t
// RUN: llvm-readobj -l --elf-output-style=GNU %t | FileCheck --check-prefix=CHECK --check-prefix=FULLRELRO %s
// RUN: ld.lld %t.o %t2.so -z relro -o %t
// RUN: llvm-readobj -l --elf-output-style=GNU %t | FileCheck --check-prefix=CHECK --check-prefix=PARTRELRO %s
// RUN: ld.lld %t.o %t2.so -z norelro -o %t
// RUN: llvm-readobj -l --elf-output-style=GNU %t | FileCheck --check-prefix=NORELRO %s
// REQUIRES: x86

// CHECK:      Program Headers:
// CHECK-NEXT: Type
// CHECK-NEXT: PHDR
// CHECK-NEXT: LOAD
// CHECK-NEXT: LOAD
// CHECK-NEXT: LOAD
// CHECK-NEXT: DYNAMIC
// CHECK-NEXT: GNU_RELRO
// CHECK: Section to Segment mapping:

// FULLRELRO:  05     .dynamic .got .got.plt {{$}}
// PARTRELRO:  05     .dynamic .got {{$}}


// NORELRO-NOT: GNU_RELRO

.global _start
_start:
  .long bar
  jmp *bar2@GOTPCREL(%rip)

.section .data,"aw"
.quad 0

.zero 4
.section .foo,"aw"
.section .bss,"",@nobits
