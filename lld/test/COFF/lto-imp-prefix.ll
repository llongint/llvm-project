; REQUIRES: x86

; RUN: rm -rf %t.dir
; RUN: split-file %s %t.dir
; RUN: llvm-as %t.dir/main.ll -o %t.main.obj
; RUN: llvm-as %t.dir/other.ll -o %t.other.obj

; RUN: lld-link /entry:entry %t.main.obj %t.other.obj /out:%t.exe /subsystem:console /debug:symtab

;; The current implementation for handling __imp_ symbols retains all of them.
;; Observe that this currently produces __imp_unusedFunc even if nothing
;; references unusedFunc in any form.

; RUN: llvm-nm %t.exe | FileCheck %s

; CHECK: __imp_unusedFunc

;--- main.ll
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-w64-windows-gnu"

define void @entry() {
entry:
  tail call void @importedFunc()
  tail call void @other()
  ret void
}

declare dllimport void @importedFunc()

declare void @other()

;--- other.ll
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-w64-windows-gnu"

@__imp_importedFunc = global ptr @importedFuncReplacement

define internal void @importedFuncReplacement() {
entry:
  ret void
}

@__imp_unusedFunc = global ptr @unusedFuncReplacement

define internal void @unusedFuncReplacement() {
entry:
  ret void
}

define void @other() {
entry:
  ret void
}
