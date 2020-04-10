; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -gvn < %s | FileCheck %s

define i32 @test(i32* %p, i32 %v) {
; CHECK-LABEL: @test(
; CHECK-NEXT:    [[LOAD:%.*]] = load i32, i32* [[P:%.*]]
; CHECK-NEXT:    [[C:%.*]] = icmp eq i32 [[LOAD]], [[V:%.*]]
; CHECK-NEXT:    call void @llvm.assume(i1 [[C]])
; CHECK-NEXT:    ret i32 [[V]]
;
  %load = load i32, i32* %p
  %c = icmp eq i32 %load, %v
  call void @llvm.assume(i1 %c)
  ret i32 %load
}

define i32 @reverse(i32* %p, i32 %v) {
; CHECK-LABEL: @reverse(
; CHECK-NEXT:    [[LOAD:%.*]] = load i32, i32* [[P:%.*]]
; CHECK-NEXT:    [[C:%.*]] = icmp eq i32 [[LOAD]], [[V:%.*]]
; CHECK-NEXT:    call void @llvm.assume(i1 [[C]])
; CHECK-NEXT:    ret i32 [[V]]
;
  %load = load i32, i32* %p
  %c = icmp eq i32 %load, %v
  call void @llvm.assume(i1 %c)
  ret i32 %v
}

; Lack of equivalance due to +0.0 vs -0.0
define float @neg_float_oeq(float* %p, float %v) {
; CHECK-LABEL: @neg_float_oeq(
; CHECK-NEXT:    [[LOAD:%.*]] = load float, float* [[P:%.*]]
; CHECK-NEXT:    [[C:%.*]] = fcmp oeq float [[LOAD]], [[V:%.*]]
; CHECK-NEXT:    call void @llvm.assume(i1 [[C]])
; CHECK-NEXT:    ret float [[LOAD]]
;
  %load = load float, float* %p
  %c = fcmp oeq float %load, %v
  call void @llvm.assume(i1 %c)
  ret float %load
}

; Lack of equivalance due to +0.0 vs -0.0
define float @neg_float_ueq(float* %p, float %v) {
; CHECK-LABEL: @neg_float_ueq(
; CHECK-NEXT:    [[LOAD:%.*]] = load float, float* [[P:%.*]]
; CHECK-NEXT:    [[C:%.*]] = fcmp ueq float [[LOAD]], [[V:%.*]]
; CHECK-NEXT:    call void @llvm.assume(i1 [[C]])
; CHECK-NEXT:    ret float [[LOAD]]
;
  %load = load float, float* %p
  %c = fcmp ueq float %load, %v
  call void @llvm.assume(i1 %c)
  ret float %load
}

define float @float_oeq_constant(float* %p) {
; CHECK-LABEL: @float_oeq_constant(
; CHECK-NEXT:    [[LOAD:%.*]] = load float, float* [[P:%.*]]
; CHECK-NEXT:    [[C:%.*]] = fcmp oeq float [[LOAD]], 5.000000e+00
; CHECK-NEXT:    call void @llvm.assume(i1 [[C]])
; CHECK-NEXT:    ret float 5.000000e+00
;
  %load = load float, float* %p
  %c = fcmp oeq float %load, 5.0
  call void @llvm.assume(i1 %c)
  ret float %load
}

; Lack of equivalance due to Nan
define float @neq_float_ueq_constant(float* %p) {
; CHECK-LABEL: @neq_float_ueq_constant(
; CHECK-NEXT:    [[LOAD:%.*]] = load float, float* [[P:%.*]]
; CHECK-NEXT:    [[C:%.*]] = fcmp ueq float [[LOAD]], 5.000000e+00
; CHECK-NEXT:    call void @llvm.assume(i1 [[C]])
; CHECK-NEXT:    ret float [[LOAD]]
;
  %load = load float, float* %p
  %c = fcmp ueq float %load, 5.0
  call void @llvm.assume(i1 %c)
  ret float %load
}

define float @float_ueq_constant_nnas(float* %p) {
; CHECK-LABEL: @float_ueq_constant_nnas(
; CHECK-NEXT:    [[LOAD:%.*]] = load float, float* [[P:%.*]]
; CHECK-NEXT:    [[C:%.*]] = fcmp nnan ueq float [[LOAD]], 5.000000e+00
; CHECK-NEXT:    call void @llvm.assume(i1 [[C]])
; CHECK-NEXT:    ret float 5.000000e+00
;
  %load = load float, float* %p
  %c = fcmp nnan ueq float %load, 5.0
  call void @llvm.assume(i1 %c)
  ret float %load
}

define i32 @test2(i32* %p, i32 %v) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[LOAD:%.*]] = load i32, i32* [[P:%.*]]
; CHECK-NEXT:    [[C:%.*]] = icmp eq i32 [[LOAD]], [[V:%.*]]
; CHECK-NEXT:    call void @llvm.assume(i1 [[C]])
; CHECK-NEXT:    ret i32 [[V]]
;
  %load = load i32, i32* %p
  %c = icmp eq i32 %load, %v
  call void @llvm.assume(i1 %c)
  %load2 = load i32, i32* %p
  ret i32 %load2
}

define i32 @test3(i32* %p, i32 %v) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[LOAD:%.*]] = load i32, i32* [[P:%.*]]
; CHECK-NEXT:    [[C:%.*]] = icmp eq i32 [[LOAD]], [[V:%.*]]
; CHECK-NEXT:    call void @llvm.assume(i1 [[C]])
; CHECK-NEXT:    br i1 undef, label [[TAKEN:%.*]], label [[MERGE:%.*]]
; CHECK:       taken:
; CHECK-NEXT:    br label [[MERGE]]
; CHECK:       merge:
; CHECK-NEXT:    ret i32 [[V]]
;
  %load = load i32, i32* %p
  %c = icmp eq i32 %load, %v
  call void @llvm.assume(i1 %c)
  br i1 undef, label %taken, label %merge
taken:
  br label %merge
merge:
  ret i32 %load
}

define i32 @trivial_constants(i32* %p) {
; CHECK-LABEL: @trivial_constants(
; CHECK-NEXT:    br i1 undef, label [[TAKEN:%.*]], label [[MERGE:%.*]]
; CHECK:       taken:
; CHECK-NEXT:    br label [[MERGE]]
; CHECK:       merge:
; CHECK-NEXT:    ret i32 0
;
  %c = icmp eq i32 0, 0
  call void @llvm.assume(i1 %c)
  br i1 undef, label %taken, label %merge
taken:
  br label %merge
merge:
  ret i32 0
}

define i32 @conflicting_constants(i32* %p) {
; CHECK-LABEL: @conflicting_constants(
; CHECK-NEXT:    store i8 undef, i8* null
; CHECK-NEXT:    br i1 undef, label [[TAKEN:%.*]], label [[MERGE:%.*]]
; CHECK:       taken:
; CHECK-NEXT:    br label [[MERGE]]
; CHECK:       merge:
; CHECK-NEXT:    ret i32 1
;
  %c = icmp eq i32 0, 5
  call void @llvm.assume(i1 %c)
  br i1 undef, label %taken, label %merge
taken:
  br label %merge
merge:
  ret i32 1
}

declare void @llvm.assume(i1)
