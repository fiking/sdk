// Copyright 2019 UCWeb Co., Ltd.
#ifndef LLVM_HEADERS_H
#define LLVM_HEADERS_H
#include "vm/compiler/backend/llvm/llvm_config.h"
#if defined(DART_ENABLE_LLVM_COMPILER)
#include <llvm-c/Analysis.h>
#include <llvm-c/Core.h>
#include <llvm-c/Disassembler.h>
#include <llvm-c/ExecutionEngine.h>
#include <llvm-c/Initialization.h>
#include <llvm-c/Target.h>
#include <llvm-c/TargetMachine.h>
#include <llvm-c/Transforms/PassManagerBuilder.h>
#endif
#endif  // LLVM_HEADERS_H
