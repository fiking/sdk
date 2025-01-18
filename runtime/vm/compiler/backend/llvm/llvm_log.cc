// Copyright 2019 UCWeb Co., Ltd.
#ifdef DART_PRECOMPILER

#include "vm/compiler/backend/llvm/llvm_log.h"

#include <stdarg.h>
#include <stdio.h>
#include <sys/syscall.h> /* For SYS_xxx definitions */
#include <time.h>
#include <unistd.h>
#include <thread>

#include <memory>
#ifdef __ANDROID__
#include <android/log.h>
#define TAG "dart_llvm"
#endif

#ifdef LLVMLOG_LEVEL
static FILE* g_log = stdout;

void __my_log(char type, const char* fmt, ...) {
  if (!g_log) return;
  va_list args;
  va_start(args, fmt);
  int bytes = vsnprintf(nullptr, 0, fmt, args);
  va_end(args);
  std::unique_ptr<char[]> buf_storage(new char[bytes + 2]);
  char* buf = buf_storage.get();
  va_start(args, fmt);
  vsnprintf(buf, bytes + 1, fmt, args);
  va_end(args);
  if (buf[bytes - 1] != '\n') {
    buf[bytes] = '\n';
    buf[bytes + 1] = '\0';
  }
#ifndef __ANDROID__
  std::ostringstream oss;
  oss << std::this_thread::get_id();
  fprintf(g_log, "%c:%s:%lu: ", type, oss.str().c_str(),
          (long)clock());
  fputs(buf, g_log);
  fflush(g_log);
#else
  int android_type;
  switch (type) {
    case 'V':
      android_type = ANDROID_LOG_VERBOSE;
      break;
    case 'P':
    case 'D':
      android_type = ANDROID_LOG_DEBUG;
      break;
    case 'E':
      android_type = ANDROID_LOG_ERROR;
      break;
    default:
      android_type = ANDROID_LOG_INFO;
      break;
  }
  __android_log_write(android_type, TAG, buf);
#endif
}

void __my_assert_fail(const char* msg, const char* file_name, int lineno) {
#ifndef __ANDROID__
  if (!g_log) {
    __builtin_trap();
  }
  std::ostringstream oss;
  oss << std::this_thread::get_id();
  fprintf(g_log, "%s:%lu: ASSERT FAILED:%s:%s:%d.\n",
          oss.str().c_str(), (long)clock(), msg, file_name, lineno);
  fflush(g_log);
#else
  __android_log_print(ANDROID_LOG_ERROR, TAG, "ASSERT FAILED:%s:%s:%d.", msg,
                      file_name, lineno);
#endif
  __builtin_trap();
}
#endif
#endif  // DART_PRECOMPILED_RUNTIME
