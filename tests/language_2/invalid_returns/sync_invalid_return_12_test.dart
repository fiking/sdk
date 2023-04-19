// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

import 'dart:async';

/*
* `return exp;` where `exp` has static type `S` is an error if `S` is `void` and
  `T` is not `void`, or `dynamic` or `Null`.
*/
void v = null;
int test() {
  return v;
  //     ^
  // [analyzer] COMPILE_TIME_ERROR.RETURN_OF_INVALID_TYPE
  // [cfe] This expression has type 'void' and can't be used.
}

void main() {
  test();
}
