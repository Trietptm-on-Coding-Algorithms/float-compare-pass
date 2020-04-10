; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -loop-vectorize -S -o - | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; This test checks that the given loop still beneficial for vecotization
; even if it contains scalarized load (gather on AVX2)

; Function Attrs: norecurse nounwind readonly uwtable
define i32 @matrix_row_col([100 x i32]* nocapture readonly %data, i32 %i, i32 %j) local_unnamed_addr #0 {
; CHECK-LABEL: @matrix_row_col(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[IDXPROM:%.*]] = sext i32 [[I:%.*]] to i64
; CHECK-NEXT:    [[IDXPROM5:%.*]] = sext i32 [[J:%.*]] to i64
; CHECK-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <4 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP21:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT:%.*]] = insertelement <4 x i64> undef, i64 [[INDEX]], i32 0
; CHECK-NEXT:    [[BROADCAST_SPLAT:%.*]] = shufflevector <4 x i64> [[BROADCAST_SPLATINSERT]], <4 x i64> undef, <4 x i32> zeroinitializer
; CHECK-NEXT:    [[INDUCTION:%.*]] = add <4 x i64> [[BROADCAST_SPLAT]], <i64 0, i64 1, i64 2, i64 3>
; CHECK-NEXT:    [[TMP0:%.*]] = add i64 [[INDEX]], 0
; CHECK-NEXT:    [[TMP1:%.*]] = add i64 [[INDEX]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = add i64 [[INDEX]], 2
; CHECK-NEXT:    [[TMP3:%.*]] = add i64 [[INDEX]], 3
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [100 x i32], [100 x i32]* [[DATA:%.*]], i64 [[IDXPROM]], i64 [[TMP0]]
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr inbounds i32, i32* [[TMP4]], i32 0
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast i32* [[TMP5]] to <4 x i32>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x i32>, <4 x i32>* [[TMP6]], align 4, !tbaa !1
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr inbounds [100 x i32], [100 x i32]* [[DATA]], i64 [[TMP0]], i64 [[IDXPROM5]]
; CHECK-NEXT:    [[TMP8:%.*]] = getelementptr inbounds [100 x i32], [100 x i32]* [[DATA]], i64 [[TMP1]], i64 [[IDXPROM5]]
; CHECK-NEXT:    [[TMP9:%.*]] = getelementptr inbounds [100 x i32], [100 x i32]* [[DATA]], i64 [[TMP2]], i64 [[IDXPROM5]]
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr inbounds [100 x i32], [100 x i32]* [[DATA]], i64 [[TMP3]], i64 [[IDXPROM5]]
; CHECK-NEXT:    [[TMP11:%.*]] = load i32, i32* [[TMP7]], align 4, !tbaa !1
; CHECK-NEXT:    [[TMP12:%.*]] = load i32, i32* [[TMP8]], align 4, !tbaa !1
; CHECK-NEXT:    [[TMP13:%.*]] = load i32, i32* [[TMP9]], align 4, !tbaa !1
; CHECK-NEXT:    [[TMP14:%.*]] = load i32, i32* [[TMP10]], align 4, !tbaa !1
; CHECK-NEXT:    [[TMP15:%.*]] = insertelement <4 x i32> undef, i32 [[TMP11]], i32 0
; CHECK-NEXT:    [[TMP16:%.*]] = insertelement <4 x i32> [[TMP15]], i32 [[TMP12]], i32 1
; CHECK-NEXT:    [[TMP17:%.*]] = insertelement <4 x i32> [[TMP16]], i32 [[TMP13]], i32 2
; CHECK-NEXT:    [[TMP18:%.*]] = insertelement <4 x i32> [[TMP17]], i32 [[TMP14]], i32 3
; CHECK-NEXT:    [[TMP19:%.*]] = mul nsw <4 x i32> [[TMP18]], [[WIDE_LOAD]]
; CHECK-NEXT:    [[TMP20:%.*]] = add <4 x i32> [[VEC_PHI]], <i32 4, i32 4, i32 4, i32 4>
; CHECK-NEXT:    [[TMP21]] = add <4 x i32> [[TMP20]], [[TMP19]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add i64 [[INDEX]], 4
; CHECK-NEXT:    [[TMP22:%.*]] = icmp eq i64 [[INDEX_NEXT]], 100
; CHECK-NEXT:    br i1 [[TMP22]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop !5
; CHECK:       middle.block:
; CHECK-NEXT:    [[RDX_SHUF:%.*]] = shufflevector <4 x i32> [[TMP21]], <4 x i32> undef, <4 x i32> <i32 2, i32 3, i32 undef, i32 undef>
; CHECK-NEXT:    [[BIN_RDX:%.*]] = add <4 x i32> [[TMP21]], [[RDX_SHUF]]
; CHECK-NEXT:    [[RDX_SHUF1:%.*]] = shufflevector <4 x i32> [[BIN_RDX]], <4 x i32> undef, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
; CHECK-NEXT:    [[BIN_RDX2:%.*]] = add <4 x i32> [[BIN_RDX]], [[RDX_SHUF1]]
; CHECK-NEXT:    [[TMP23:%.*]] = extractelement <4 x i32> [[BIN_RDX2]], i32 0
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 100, 100
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_COND_CLEANUP:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ 100, [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX:%.*]] = phi i32 [ 0, [[ENTRY]] ], [ [[TMP23]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    [[ADD7_LCSSA:%.*]] = phi i32 [ [[ADD7:%.*]], [[FOR_BODY]] ], [ [[TMP23]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    ret i32 [[ADD7_LCSSA]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[SUM_015:%.*]] = phi i32 [ [[BC_MERGE_RDX]], [[SCALAR_PH]] ], [ [[ADD7]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[ARRAYIDX2:%.*]] = getelementptr inbounds [100 x i32], [100 x i32]* [[DATA]], i64 [[IDXPROM]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP24:%.*]] = load i32, i32* [[ARRAYIDX2]], align 4, !tbaa !1
; CHECK-NEXT:    [[ARRAYIDX6:%.*]] = getelementptr inbounds [100 x i32], [100 x i32]* [[DATA]], i64 [[INDVARS_IV]], i64 [[IDXPROM5]]
; CHECK-NEXT:    [[TMP25:%.*]] = load i32, i32* [[ARRAYIDX6]], align 4, !tbaa !1
; CHECK-NEXT:    [[MUL:%.*]] = mul nsw i32 [[TMP25]], [[TMP24]]
; CHECK-NEXT:    [[ADD:%.*]] = add i32 [[SUM_015]], 4
; CHECK-NEXT:    [[ADD7]] = add i32 [[ADD]], [[MUL]]
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[INDVARS_IV_NEXT]], 100
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_COND_CLEANUP]], label [[FOR_BODY]], !llvm.loop !7
;
entry:
  %idxprom = sext i32 %i to i64
  %idxprom5 = sext i32 %j to i64
  br label %for.body

  for.cond.cleanup:                                 ; preds = %for.body
  ret i32 %add7

  for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %sum.015 = phi i32 [ 0, %entry ], [ %add7, %for.body ]
  ; first consecutive load as vector load
  %arrayidx2 = getelementptr inbounds [100 x i32], [100 x i32]* %data, i64 %idxprom, i64 %indvars.iv
  %0 = load i32, i32* %arrayidx2, align 4, !tbaa !1
  ; second strided load scalarized
  %arrayidx6 = getelementptr inbounds [100 x i32], [100 x i32]* %data, i64 %indvars.iv, i64 %idxprom5
  %1 = load i32, i32* %arrayidx6, align 4, !tbaa !1
  %mul = mul nsw i32 %1, %0
  %add = add i32 %sum.015, 4
  %add7 = add i32 %add, %mul
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 100
  br i1 %exitcond, label %for.cond.cleanup, label %for.body
}

attributes #0 = { "target-cpu"="core-avx2" "target-features"="+avx,+avx2,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (cfe/trunk 284570)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}