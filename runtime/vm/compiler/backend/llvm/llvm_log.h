// Copyright 2019 UCWeb Co., Ltd.
#ifndef LLVM_LOG_H
#define LLVM_LOG_H

#ifdef LLVMLOG_LEVEL
// always print LLVMLOGE
#define LLVMLOGE(...) __my_log('E', __VA_ARGS__)
#define EMASSERT(p)                                                            \
  if (!(p)) {                                                                  \
    __my_assert_fail(#p, __FILE__, __LINE__);                                  \
  }

#if LLVMLOG_LEVEL >= 10
#define LLVMLOGV(...) __my_log('V', __VA_ARGS__)
#endif  // DEFINING LLVMLOGV

#if LLVMLOG_LEVEL >= 4
// debug log
#define LLVMLOGD(...) __my_log('D', __VA_ARGS__)
#endif

#if LLVMLOG_LEVEL >= 5
// performance log
#define LOGP(...) __my_log('P', __VA_ARGS__)
#endif

#ifdef __cplusplus
extern "C" {
#endif  //__cplusplus
void __my_log(char type, const char* fmt, ...)
    __attribute__((format(printf, 2, 3)));
void __my_assert_fail(const char* msg, const char* file_name, int lineno)
    __attribute__((noreturn));
#ifdef __cplusplus
}
#endif  //__cplusplus
#endif  // LLVMLOG_LEVEL

#ifndef LLVMLOGE
#define LLVMLOGE(...)
#endif

#ifndef LLVMLOGV
#define LLVMLOGV(...)
#endif

#ifndef LLVMLOGD
#define LLVMLOGD(...)
#endif

#ifndef LOGP
#define LOGP(...)
#endif

#ifndef EMASSERT
#define EMASSERT(p)
#endif

#endif  // LLVM_LOG_H
