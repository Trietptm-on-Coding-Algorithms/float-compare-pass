; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+ssse3 | FileCheck %s

; Test that the pshufb mask comment is correct.

define <16 x i8> @test1(<16 x i8> %V) {
; CHECK-LABEL: test1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[1,0,0,0,0,2,0,0,0,0,3,0,0,0,0,4]
; CHECK-NEXT:    retq
  %1 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %V, <16 x i8> <i8 1, i8 0, i8 0, i8 0, i8 0, i8 2, i8 0, i8 0, i8 0, i8 0, i8 3, i8 0, i8 0, i8 0, i8 0, i8 4>)
  ret <16 x i8> %1
}

; Test that indexes larger than the size of the vector are shown masked (bottom 4 bits).

define <16 x i8> @test2(<16 x i8> %V) {
; CHECK-LABEL: test2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[15,0,0,0,0,0,0,0,0,0,1,0,0,0,0,2]
; CHECK-NEXT:    retq
  %1 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %V, <16 x i8> <i8 15, i8 0, i8 0, i8 0, i8 0, i8 16, i8 0, i8 0, i8 0, i8 0, i8 17, i8 0, i8 0, i8 0, i8 0, i8 50>)
  ret <16 x i8> %1
}

; Test that indexes with bit seven set are shown as zero.

define <16 x i8> @test3(<16 x i8> %V) {
; CHECK-LABEL: test3:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[1,0,0,15,0,2,0,0],zero,xmm0[0,3,0,0],zero,xmm0[0,4]
; CHECK-NEXT:    retq
  %1 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %V, <16 x i8> <i8 1, i8 0, i8 0, i8 127, i8 0, i8 2, i8 0, i8 0, i8 128, i8 0, i8 3, i8 0, i8 0, i8 255, i8 0, i8 4>)
  ret <16 x i8> %1
}

; Test that we won't crash when the constant was reused for another instruction.

define <16 x i8> @test4(<16 x i8> %V, <2 x i64>* %P) {
; CHECK-LABEL: test4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movaps {{.*#+}} xmm1 = [1084818905618843912,506097522914230528]
; CHECK-NEXT:    movaps %xmm1, (%rdi)
; CHECK-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; CHECK-NEXT:    retq
  %1 = insertelement <2 x i64> undef, i64 1084818905618843912, i32 0
  %2 = insertelement <2 x i64>    %1, i64  506097522914230528, i32 1
  store <2 x i64> %2, <2 x i64>* %P, align 16
  %3 = bitcast <2 x i64> %2 to <16 x i8>
  %4 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %V, <16 x i8> %3)
  ret <16 x i8> %4
}

define <16 x i8> @test5(<16 x i8> %V) {
; CHECK-LABEL: test5:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl $1, %eax
; CHECK-NEXT:    movd %eax, %xmm1
; CHECK-NEXT:    movdqa %xmm1, (%rax)
; CHECK-NEXT:    movaps {{.*#+}} xmm1 = [1,1]
; CHECK-NEXT:    movaps %xmm1, (%rax)
; CHECK-NEXT:    pshufb (%rax), %xmm0
; CHECK-NEXT:    retq
  store <2 x i64> <i64 1, i64 0>, <2 x i64>* undef, align 16
  %l = load <2 x i64>, <2 x i64>* undef, align 16
  %shuffle = shufflevector <2 x i64> %l, <2 x i64> undef, <2 x i32> zeroinitializer
  store <2 x i64> %shuffle, <2 x i64>* undef, align 16
  %1 = load <16 x i8>, <16 x i8>* undef, align 16
  %2 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %V, <16 x i8> %1)
  ret <16 x i8> %2
}

; Test for a reused constant that would allow the pshufb to combine to a simpler instruction.

define <16 x i8> @test6(<16 x i8> %V, <2 x i64>* %P) {
; CHECK-LABEL: test6:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movaps {{.*#+}} xmm1 = [217019414673948672,506380106026255364]
; CHECK-NEXT:    movaps %xmm1, (%rdi)
; CHECK-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; CHECK-NEXT:    retq
  %1 = insertelement <2 x i64> undef, i64 217019414673948672, i32 0
  %2 = insertelement <2 x i64>    %1, i64 506380106026255364, i32 1
  store <2 x i64> %2, <2 x i64>* %P, align 16
  %3 = bitcast <2 x i64> %2 to <16 x i8>
  %4 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %V, <16 x i8> %3)
  ret <16 x i8> %4
}

declare <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8>, <16 x i8>) nounwind readnone
