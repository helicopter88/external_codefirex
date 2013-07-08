# Copyright (C) 2012 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


LOCAL_PREBUILT_LIBS := \
    libLLVMInterpreter.a   \
    libclangFormat.a   \
    libLLVMBitReader.a   \
    libLLVMCodeGen.a   \
    libclangSerialization.a   \
    libLLVMInstrumentation.a   \
    libclang.a   \
    libLLVMX86Info.a   \
    libLLVMVectorize.a   \
    libclangRewriteFrontend.a   \
    clang/3.4/lib/linux/libclang_rt.tsan-x86_64.a   \
    clang/3.4/lib/linux/libclang_rt.a   \san-i386.a   \
    clang/3.4/lib/linux/libclang_rt.ubsan_cxx-i386.a   \
    clang/3.4/lib/linux/libclang_rt.ubsan-i386.a   \
    clang/3.4/lib/linux/libclang_rt.profile-x86_64.a   \
    clang/3.4/lib/linux/libclang_rt.full-x86_64.a   \
    clang/3.4/lib/linux/libclang_rt.ubsan_cxx-x86_64.a   \
    clang/3.4/lib/linux/libclang_rt.full-i386.a   \
    clang/3.4/lib/linux/libclang_rt.san-x86_64.a   \
    clang/3.4/lib/linux/libclang_rt.profile-i386.a   \
    clang/3.4/lib/linux/libclang_rt.a   \san-x86_64.a   \
    clang/3.4/lib/linux/libclang_rt.ubsan-x86_64.a   \
    clang/3.4/lib/linux/libclang_rt.san-i386.a   \
    clang/3.4/lib/linux/libclang_rt.msan-x86_64.a   \
    libclangStaticAnalyzerCheckers.a   \
    libLLVMCppBackendCodeGen.a   \
    libLLVMTableGen.a   \
    libclangARCMigrate.a   \
    libLLVMLinker.a   \
    libLLVMObject.a   \
    libclangAST.a   \
    libprofile_rt.a   \
    libLLVMX86AsmParser.a   \
    libclangSema.a   \
    libclangStaticAnalyzerFrontend.a   \
    libclangDriver.a   \
    libLLVMRuntimeDyld.a   \
    libLLVMX86Utils.a   \
    libLTO.a   \
    libLLVMTransformUtils.a   \
    libLLVMX86CodeGen.a   \
    libLLVMDebugInfo.a   \
    libLLVMX86AsmPrinter.a   \
    libLLVMMCParser.a   \
    libLLVMCppBackendInfo.a   \
    libLLVMIRReader.a   \
    libclangDynamicASTMatchers.a   \
    libLLVMObjCARCOpts.a   \
    libclangAnalysis.a   \
    libclangTooling.a   \
    libLLVMAnalysis.a   \
    libLLVMMCJIT.a   \
    libclangStaticAnalyzerCore.a   \
    libLLVMExecutionEngine.a   \
    libclangCodeGen.a   \
    libLLVMScalarOpts.a   \
    libsample.a   \
    libclangLex.a   \
    libclangFrontend.a   \
    libLLVMMC.a   \
    libLLVMSelectionDAG.a   \
    libclangFrontendTool.a   \
    libclangEdit.a   \
    libclangASTMatchers.a   \
    libLLVMTarget.a   \
    libLLVMMCDisassembler.a   \
    libLLVMJIT.a   \
    libLLVMipo.a   \
    libclangRewriteCore.a   \
    libLLVMipa.a   \
    libclangParse.a   \
    libLLVMCore.a   \
    libLLVMBitWriter.a   \
    libLLVMAsmPrinter.a   \
    libLLVMX86Disassembler.a   \
    libclangBasic.a   \
    libLLVMAsmParser.a   \
    libLLVMSupport.a   \
    libLLVMX86Desc.a   \
    libLLVMInstCombine.a   \
    libLLVMOption.a   

LOCAL_MODULE_TAGS := optional
include $(BUILD_HOST_PREBUILT)
