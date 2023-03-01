// TODO(multitest): This was automatically migrated from a multitest and may
// contain strange or dead code.

// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO(51557): Decide if the mixins being applied in this test should be
// "mixin", "mixin class" or the test should be left at 2.19.
// @dart=2.19

// Test that parameter types are checked correctly in the face of
// mixin application upon a generic constructor.

import '../dynamic_type_helper.dart';

class A<X> {
  A(X x);
}

class B {}

class C {}

class D<Y> = A<Y> with B, C;

void main() {
  var v = 0;
  checkNoDynamicTypeError(() => new D<int>(v));

}
