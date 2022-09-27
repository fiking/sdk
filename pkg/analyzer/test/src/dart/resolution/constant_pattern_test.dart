// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'context_collection_resolution.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ConstantPattern_BooleanLiteral_ResolutionTest);
    defineReflectiveTests(ConstantPattern_DoubleLiteral_ResolutionTest);
    defineReflectiveTests(ConstantPattern_IntegerLiteral_ResolutionTest);
    defineReflectiveTests(ConstantPattern_NullLiteral_ResolutionTest);
    defineReflectiveTests(ConstantPattern_SimpleIdentifier_ResolutionTest);
    defineReflectiveTests(ConstantPattern_SimpleStringLiteral_ResolutionTest);
  });
}

@reflectiveTest
class ConstantPattern_BooleanLiteral_ResolutionTest
    extends PatternsResolutionTest {
  test_inside_castPattern() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case true as Object:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
CastPattern
  pattern: ConstantPattern
    expression: BooleanLiteral
      literal: true
  asToken: as
  type: NamedType
    name: SimpleIdentifier
      token: Object
''');
  }

  test_inside_ifStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  if (x case true) {}
}
''');
    final node = findNode.caseClause('case').pattern;
    assertParsedNodeText(node, r'''
ConstantPattern
  expression: BooleanLiteral
    literal: true
''');
  }

  test_inside_nullAssert() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case true!:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: ConstantPattern
    expression: BooleanLiteral
      literal: true
  operator: !
''');
  }

  test_inside_nullCheck() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case true?:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: ConstantPattern
    expression: BooleanLiteral
      literal: true
  operator: ?
''');
  }

  test_inside_switchStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case true:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
ConstantPattern
  expression: BooleanLiteral
    literal: true
''');
  }
}

@reflectiveTest
class ConstantPattern_DoubleLiteral_ResolutionTest
    extends PatternsResolutionTest {
  test_inside_castPattern() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case 1.0 as Object:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
CastPattern
  pattern: ConstantPattern
    expression: DoubleLiteral
      literal: 1.0
  asToken: as
  type: NamedType
    name: SimpleIdentifier
      token: Object
''');
  }

  test_inside_ifStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  if (x case 1.0) {}
}
''');
    final node = findNode.caseClause('case').pattern;
    assertParsedNodeText(node, r'''
ConstantPattern
  expression: DoubleLiteral
    literal: 1.0
''');
  }

  test_inside_nullAssert() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case 1.0!:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: ConstantPattern
    expression: DoubleLiteral
      literal: 1.0
  operator: !
''');
  }

  test_inside_nullCheck() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case 1.0?:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: ConstantPattern
    expression: DoubleLiteral
      literal: 1.0
  operator: ?
''');
  }

  test_inside_switchStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case 1.0:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
ConstantPattern
  expression: DoubleLiteral
    literal: 1.0
''');
  }
}

@reflectiveTest
class ConstantPattern_IntegerLiteral_ResolutionTest
    extends PatternsResolutionTest {
  test_inside_castPattern() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case 0 as Object:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
CastPattern
  pattern: ConstantPattern
    expression: IntegerLiteral
      literal: 0
  asToken: as
  type: NamedType
    name: SimpleIdentifier
      token: Object
''');
  }

  test_inside_ifStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  if (x case 0) {}
}
''');
    final node = findNode.caseClause('case').pattern;
    assertParsedNodeText(node, r'''
ConstantPattern
  expression: IntegerLiteral
    literal: 0
''');
  }

  test_inside_nullAssert() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case 0!:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: ConstantPattern
    expression: IntegerLiteral
      literal: 0
  operator: !
''');
  }

  test_inside_nullCheck() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case 0?:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: ConstantPattern
    expression: IntegerLiteral
      literal: 0
  operator: ?
''');
  }

  test_inside_switchStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case 0:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
ConstantPattern
  expression: IntegerLiteral
    literal: 0
''');
  }
}

@reflectiveTest
class ConstantPattern_NullLiteral_ResolutionTest
    extends PatternsResolutionTest {
  test_inside_castPattern() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case null as Object:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
CastPattern
  pattern: ConstantPattern
    expression: NullLiteral
      literal: null
  asToken: as
  type: NamedType
    name: SimpleIdentifier
      token: Object
''');
  }

  test_inside_ifStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  if (x case null) {}
}
''');
    final node = findNode.caseClause('case').pattern;
    assertParsedNodeText(node, r'''
ConstantPattern
  expression: NullLiteral
    literal: null
''');
  }

  test_inside_nullAssert() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case null!:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: ConstantPattern
    expression: NullLiteral
      literal: null
  operator: !
''');
  }

  test_inside_nullCheck() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case null?:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: ConstantPattern
    expression: NullLiteral
      literal: null
  operator: ?
''');
  }

  test_inside_switchStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case null:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
ConstantPattern
  expression: NullLiteral
    literal: null
''');
  }
}

@reflectiveTest
class ConstantPattern_SimpleIdentifier_ResolutionTest
    extends PatternsResolutionTest {
  test_inside_castPattern() async {
    await assertNoErrorsInCode(r'''
void f(x, y) {
  switch (x) {
    case y as Object:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
CastPattern
  pattern: ConstantPattern
    expression: SimpleIdentifier
      token: y
  asToken: as
  type: NamedType
    name: SimpleIdentifier
      token: Object
''');
  }

  test_inside_ifStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x, y) {
  if (x case y) {}
}
''');
    final node = findNode.caseClause('case').pattern;
    assertParsedNodeText(node, r'''
ConstantPattern
  expression: SimpleIdentifier
    token: y
''');
  }

  test_inside_nullAssert() async {
    await assertNoErrorsInCode(r'''
void f(x, y) {
  switch (x) {
    case y!:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: ConstantPattern
    expression: SimpleIdentifier
      token: y
  operator: !
''');
  }

  test_inside_nullCheck() async {
    await assertNoErrorsInCode(r'''
void f(x, y) {
  switch (x) {
    case y?:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: ConstantPattern
    expression: SimpleIdentifier
      token: y
  operator: ?
''');
  }

  test_inside_switchStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x, y) {
  switch (x) {
    case y:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
ConstantPattern
  expression: SimpleIdentifier
    token: y
''');
  }
}

@reflectiveTest
class ConstantPattern_SimpleStringLiteral_ResolutionTest
    extends PatternsResolutionTest {
  test_inside_castPattern() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case 'x' as Object:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
CastPattern
  pattern: ConstantPattern
    expression: SimpleStringLiteral
      literal: 'x'
  asToken: as
  type: NamedType
    name: SimpleIdentifier
      token: Object
''');
  }

  test_inside_ifStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  if (x case 'x') {}
}
''');
    final node = findNode.caseClause('case').pattern;
    assertParsedNodeText(node, r'''
ConstantPattern
  expression: SimpleStringLiteral
    literal: 'x'
''');
  }

  test_inside_nullAssert() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case 'x'!:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: ConstantPattern
    expression: SimpleStringLiteral
      literal: 'x'
  operator: !
''');
  }

  test_inside_nullCheck() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case 'x'?:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: ConstantPattern
    expression: SimpleStringLiteral
      literal: 'x'
  operator: ?
''');
  }

  test_inside_switchStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case 'x':
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
ConstantPattern
  expression: SimpleStringLiteral
    literal: 'x'
''');
  }
}
