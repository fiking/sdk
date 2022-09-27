// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'context_collection_resolution.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(VariablePatternResolutionTest);
  });
}

@reflectiveTest
class VariablePatternResolutionTest extends PatternsResolutionTest {
  test_final_inside_castPattern() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case final y as Object:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
CastPattern
  pattern: VariablePattern
    keyword: final
    name: y
  asToken: as
  type: NamedType
    name: SimpleIdentifier
      token: Object
''');
  }

  test_final_inside_ifStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  if (x case final y) {}
}
''');
    final node = findNode.caseClause('case').pattern;
    assertParsedNodeText(node, r'''
VariablePattern
  keyword: final
  name: y
''');
  }

  test_final_inside_nullAssert() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case final y!:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: VariablePattern
    keyword: final
    name: y
  operator: !
''');
  }

  test_final_inside_nullCheck() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case final y?:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: VariablePattern
    keyword: final
    name: y
  operator: ?
''');
  }

  test_final_inside_switchStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case final y:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
VariablePattern
  keyword: final
  name: y
''');
  }

  test_final_typed_inside_castPattern() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case final int y as Object:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
CastPattern
  pattern: VariablePattern
    keyword: final
    type: NamedType
      name: SimpleIdentifier
        token: int
    name: y
  asToken: as
  type: NamedType
    name: SimpleIdentifier
      token: Object
''');
  }

  test_final_typed_inside_ifStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  if (x case final int y) {}
}
''');
    final node = findNode.caseClause('case').pattern;
    assertParsedNodeText(node, r'''
VariablePattern
  keyword: final
  type: NamedType
    name: SimpleIdentifier
      token: int
  name: y
''');
  }

  test_final_typed_inside_nullAssert() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case final int y!:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: VariablePattern
    keyword: final
    type: NamedType
      name: SimpleIdentifier
        token: int
    name: y
  operator: !
''');
  }

  test_final_typed_inside_nullCheck() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case final int y?:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: VariablePattern
    keyword: final
    type: NamedType
      name: SimpleIdentifier
        token: int
    name: y
  operator: ?
''');
  }

  test_final_typed_inside_switchStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case final int y:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
VariablePattern
  keyword: final
  type: NamedType
    name: SimpleIdentifier
      token: int
  name: y
''');
  }

  test_typed_inside_castPattern() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case int y as Object:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
CastPattern
  pattern: VariablePattern
    type: NamedType
      name: SimpleIdentifier
        token: int
    name: y
  asToken: as
  type: NamedType
    name: SimpleIdentifier
      token: Object
''');
  }

  test_typed_inside_ifStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  if (x case int y) {}
}
''');
    final node = findNode.caseClause('case').pattern;
    assertParsedNodeText(node, r'''
VariablePattern
  type: NamedType
    name: SimpleIdentifier
      token: int
  name: y
''');
  }

  test_typed_inside_nullAssert() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case int y!:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: VariablePattern
    type: NamedType
      name: SimpleIdentifier
        token: int
    name: y
  operator: !
''');
  }

  test_typed_inside_nullCheck() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case int y?:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: VariablePattern
    type: NamedType
      name: SimpleIdentifier
        token: int
    name: y
  operator: ?
''');
  }

  test_typed_inside_switchStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case int y:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
VariablePattern
  type: NamedType
    name: SimpleIdentifier
      token: int
  name: y
''');
  }

  test_typed_named_as_inside_castPattern() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case int as as Object:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
CastPattern
  pattern: VariablePattern
    type: NamedType
      name: SimpleIdentifier
        token: int
    name: as
  asToken: as
  type: NamedType
    name: SimpleIdentifier
      token: Object
''');
  }

  test_typed_named_as_inside_extractorPattern_namedExplicitly() async {
    await assertNoErrorsInCode(r'''
class C {
  int? f;
}

void f(x) {
  switch (x) {
    case C(f: int as):
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
ExtractorPattern
  typeName: SimpleIdentifier
    token: C
  leftParenthesis: (
  fields
    RecordPatternField
      fieldName: RecordPatternFieldName
        name: f
        colon: :
      pattern: VariablePattern
        type: NamedType
          name: SimpleIdentifier
            token: int
        name: as
  rightParenthesis: )
''');
  }

  test_typed_named_as_inside_extractorPattern_namedImplicitly() async {
    await assertNoErrorsInCode(r'''
class C {
  int? f;
}

void f(x) {
  switch (x) {
    case C(: int as):
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
ExtractorPattern
  typeName: SimpleIdentifier
    token: C
  leftParenthesis: (
  fields
    RecordPatternField
      fieldName: RecordPatternFieldName
        colon: :
      pattern: VariablePattern
        type: NamedType
          name: SimpleIdentifier
            token: int
        name: as
  rightParenthesis: )
''');
  }

  test_typed_named_as_inside_ifStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  if (x case int as) {}
}
''');
    final node = findNode.caseClause('case').pattern;
    assertParsedNodeText(node, r'''
VariablePattern
  type: NamedType
    name: SimpleIdentifier
      token: int
  name: as
''');
  }

  test_typed_named_as_inside_listPattern() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case [int as]:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
ListPattern
  leftBracket: [
  elements
    VariablePattern
      type: NamedType
        name: SimpleIdentifier
          token: int
      name: as
  rightBracket: ]
''');
  }

  test_typed_named_as_inside_logicalAnd_left() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case int as & 2:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
BinaryPattern
  leftOperand: VariablePattern
    type: NamedType
      name: SimpleIdentifier
        token: int
    name: as
  operator: &
  rightOperand: ConstantPattern
    expression: IntegerLiteral
      literal: 2
''');
  }

  test_typed_named_as_inside_logicalAnd_right() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case 1 & int as:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
BinaryPattern
  leftOperand: ConstantPattern
    expression: IntegerLiteral
      literal: 1
  operator: &
  rightOperand: VariablePattern
    type: NamedType
      name: SimpleIdentifier
        token: int
    name: as
''');
  }

  test_typed_named_as_inside_logicalOr_left() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case int as | 2:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
BinaryPattern
  leftOperand: VariablePattern
    type: NamedType
      name: SimpleIdentifier
        token: int
    name: as
  operator: |
  rightOperand: ConstantPattern
    expression: IntegerLiteral
      literal: 2
''');
  }

  test_typed_named_as_inside_logicalOr_right() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case 1 | int as:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
BinaryPattern
  leftOperand: ConstantPattern
    expression: IntegerLiteral
      literal: 1
  operator: |
  rightOperand: VariablePattern
    type: NamedType
      name: SimpleIdentifier
        token: int
    name: as
''');
  }

  test_typed_named_as_inside_mapPattern() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case {'a': int as}:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
MapPattern
  leftBracket: {
  entries
    MapPatternEntry
      key: SimpleStringLiteral
        literal: 'a'
      separator: :
      value: VariablePattern
        type: NamedType
          name: SimpleIdentifier
            token: int
        name: as
  rightBracket: }
''');
  }

  test_typed_named_as_inside_nullAssert() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case int as!:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: VariablePattern
    type: NamedType
      name: SimpleIdentifier
        token: int
    name: as
  operator: !
''');
  }

  test_typed_named_as_inside_nullCheck() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case int as?:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: VariablePattern
    type: NamedType
      name: SimpleIdentifier
        token: int
    name: as
  operator: ?
''');
  }

  test_typed_named_as_inside_parenthesizedPattern() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case (int as):
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
ParenthesizedPattern
  leftParenthesis: (
  pattern: VariablePattern
    type: NamedType
      name: SimpleIdentifier
        token: int
    name: as
  rightParenthesis: )
''');
  }

  test_typed_named_as_inside_recordPattern_namedExplicitly() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case (n: int as, 2):
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
RecordPattern
  leftParenthesis: (
  fields
    RecordPatternField
      fieldName: RecordPatternFieldName
        name: n
        colon: :
      pattern: VariablePattern
        type: NamedType
          name: SimpleIdentifier
            token: int
        name: as
    RecordPatternField
      pattern: ConstantPattern
        expression: IntegerLiteral
          literal: 2
  rightParenthesis: )
''');
  }

  test_typed_named_as_inside_recordPattern_namedImplicitly() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case (: int as, 2):
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
RecordPattern
  leftParenthesis: (
  fields
    RecordPatternField
      fieldName: RecordPatternFieldName
        colon: :
      pattern: VariablePattern
        type: NamedType
          name: SimpleIdentifier
            token: int
        name: as
    RecordPatternField
      pattern: ConstantPattern
        expression: IntegerLiteral
          literal: 2
  rightParenthesis: )
''');
  }

  test_typed_named_as_inside_recordPattern_unnamed() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case (int as, 2):
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
RecordPattern
  leftParenthesis: (
  fields
    RecordPatternField
      pattern: VariablePattern
        type: NamedType
          name: SimpleIdentifier
            token: int
        name: as
    RecordPatternField
      pattern: ConstantPattern
        expression: IntegerLiteral
          literal: 2
  rightParenthesis: )
''');
  }

  test_typed_named_as_inside_switchStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case int as:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
VariablePattern
  type: NamedType
    name: SimpleIdentifier
      token: int
  name: as
''');
  }

  test_var_inside_castPattern() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case var y as Object:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
CastPattern
  pattern: VariablePattern
    keyword: var
    name: y
  asToken: as
  type: NamedType
    name: SimpleIdentifier
      token: Object
''');
  }

  test_var_inside_ifStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  if (x case var y) {}
}
''');
    final node = findNode.caseClause('case').pattern;
    assertParsedNodeText(node, r'''
VariablePattern
  keyword: var
  name: y
''');
  }

  test_var_inside_nullAssert() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case var y!:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: VariablePattern
    keyword: var
    name: y
  operator: !
''');
  }

  test_var_inside_nullCheck() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case var y?:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
PostfixPattern
  operand: VariablePattern
    keyword: var
    name: y
  operator: ?
''');
  }

  test_var_inside_switchStatement_case() async {
    await assertNoErrorsInCode(r'''
void f(x) {
  switch (x) {
    case var y:
      break;
  }
}
''');
    final node = findNode.switchPatternCase('case').pattern;
    assertParsedNodeText(node, r'''
VariablePattern
  keyword: var
  name: y
''');
  }
}
