// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:_fe_analyzer_shared/src/exhaustiveness/static_type.dart';

import 'witness.dart';

/// Interface implemented by analyze/CFE to support type operations need for the
/// shared [StaticType]s.
abstract class TypeOperations<Type extends Object> {
  /// Returns the type for `Object`.
  Type get nullableObjectType;

  /// Returns `true` if [s] is a subtype of [t].
  bool isSubtypeOf(Type s, Type t);

  /// Returns a type that overapproximates the possible values of [type] by
  /// replacing all type variables with the default types.
  Type overapproximate(Type type);

  /// Returns `true` if [type] is a potentially nullable type.
  bool isNullable(Type type);

  /// Returns the non-nullable type corresponding to [type]. For instance
  /// `Foo` for `Foo?`. If [type] is already non-nullable, it itself is
  /// returned.
  Type getNonNullable(Type type);

  /// Returns `true` if [type] is the `Null` type.
  bool isNullType(Type type);

  /// Returns `true` if [type] is the `Never` type.
  bool isNeverType(Type type);

  /// Returns `true` if [type] is the `Object?` type.
  bool isNullableObject(Type type);

  /// Returns `true` if [type] is the `Object` type.
  bool isNonNullableObject(Type type);

  /// Returns `true` if [type] is the `dynamic` type.
  bool isDynamic(Type type);

  /// Returns `true` if [type] is the `bool` type.
  bool isBoolType(Type type);

  /// Returns the `bool` type.
  Type get boolType;

  /// Returns `true` if [type] is a record type.
  bool isRecordType(Type type);

  /// Returns `true` if [type] is a generic interface type.
  bool isGeneric(Type type);

  /// Returns the type `T` if [type] is `FutureOr<T>`. Returns `null` otherwise.
  Type? getFutureOrTypeArgument(Type type);

  /// Returns the non-nullable type `Future<T>` for [type] `T`.
  Type instantiateFuture(Type type);

  /// Returns a map of the field names and corresponding types available on
  /// [type]. For an interface type, these are the fields and getters, and for
  /// record types these are the record fields.
  Map<String, Type> getFieldTypes(Type type);

  /// Returns the value type `V` if [type] implements `Map<K, V>` or `null`
  /// otherwise.
  Type? getMapValueType(Type type);

  /// Returns the element type `E` if [type] implements `List<E>` or `null`
  /// otherwise.
  Type? getListElementType(Type type);

  /// Returns the list type `List<E>` if [type] implements `List<E>` or `null`
  /// otherwise.
  Type? getListType(Type type);

  /// Returns a human-readable representation of the [type].
  String typeToString(Type type);
}

/// Interface implemented by analyzer/CFE to support [StaticType]s for enums.
abstract class EnumOperations<Type extends Object, EnumClass extends Object,
    EnumElement extends Object, EnumElementValue extends Object> {
  /// Returns the enum class declaration for the [type] or `null` if
  /// [type] is not an enum type.
  EnumClass? getEnumClass(Type type);

  /// Returns the enum elements defined by [enumClass].
  Iterable<EnumElement> getEnumElements(EnumClass enumClass);

  /// Returns the value defined by the [enumElement]. The encoding is specific
  /// the implementation of this interface but must ensure constant value
  /// identity.
  EnumElementValue getEnumElementValue(EnumElement enumElement);

  /// Returns the declared name of the [enumElement].
  String getEnumElementName(EnumElement enumElement);

  /// Returns the static type of the [enumElement].
  Type getEnumElementType(EnumElement enumElement);
}

/// Interface implemented by analyzer/CFE to support [StaticType]s for sealed
/// classes.
abstract class SealedClassOperations<Type extends Object,
    Class extends Object> {
  /// Returns the sealed class declaration for [type] or `null` if [type] is not
  /// a sealed class type.
  Class? getSealedClass(Type type);

  /// Returns the direct subclasses of [sealedClass] that either extend,
  /// implement or mix it in.
  List<Class> getDirectSubclasses(Class sealedClass);

  /// Returns the instance of [subClass] that implements [sealedClassType].
  ///
  /// `null` might be returned if [subClass] cannot implement [sealedClassType].
  /// For instance
  ///
  ///     sealed class A<T> {}
  ///     class B<T> extends A<T> {}
  ///     class C extends A<int> {}
  ///
  /// here `C` has no implementation of `A<String>`.
  ///
  /// It is assumed that `TypeOperations.isSealedClass` is `true` for
  /// [sealedClassType] and that [subClass] is in `getDirectSubclasses` for
  /// `getSealedClass` of [sealedClassType].
  Type? getSubclassAsInstanceOf(Class subClass, Type sealedClassType);
}

/// Interface for looking up fields and their corresponding [StaticType]s of
/// a given type.
abstract class FieldLookup<Type extends Object> {
  /// Returns a map of the field names and corresponding [StaticType]s available
  /// on [type]. For an interface type, these are the fields and getters, and
  /// for record types these are the record fields.
  Map<String, StaticType> getFieldTypes(Type type);

  StaticType? getAdditionalFieldType(Type type, Key key);
}

/// Cache used for computing [StaticType]s used for exhaustiveness checking.
///
/// This implementation is shared between analyzer and CFE, and implemented
/// using the analyzer/CFE implementations of [TypeOperations],
/// [EnumOperations], and [SealedClassOperations].
class ExhaustivenessCache<
    Type extends Object,
    Class extends Object,
    EnumClass extends Object,
    EnumElement extends Object,
    EnumElementValue extends Object> implements FieldLookup<Type> {
  final TypeOperations<Type> typeOperations;
  final EnumOperations<Type, EnumClass, EnumElement, EnumElementValue>
      enumOperations;
  final SealedClassOperations<Type, Class> _sealedClassOperations;

  /// Cache for [EnumInfo] for enum classes.
  Map<EnumClass, EnumInfo<Type, EnumClass, EnumElement, EnumElementValue>>
      _enumInfo = {};

  /// Cache for [SealedClassInfo] for sealed classes.
  Map<Class, SealedClassInfo<Type, Class>> _sealedClassInfo = {};

  /// Cache for [UniqueStaticType]s.
  Map<Object, StaticType> _uniqueTypeMap = {};

  /// Cache for the [StaticType] for `bool`.
  late BoolStaticType _boolStaticType =
      new BoolStaticType(typeOperations, this, typeOperations.boolType);

  /// Cache for [StaticType]s for fields available on a [Type].
  Map<Type, Map<String, StaticType>> _fieldCache = {};

  ExhaustivenessCache(
      this.typeOperations, this.enumOperations, this._sealedClassOperations);

  /// Returns the [EnumInfo] for [enumClass].
  EnumInfo<Type, EnumClass, EnumElement, EnumElementValue> _getEnumInfo(
      EnumClass enumClass) {
    return _enumInfo[enumClass] ??=
        new EnumInfo(typeOperations, this, enumOperations, enumClass);
  }

  /// Returns the [SealedClassInfo] for [sealedClass].
  SealedClassInfo<Type, Class> _getSealedClassInfo(Class sealedClass) {
    return _sealedClassInfo[sealedClass] ??=
        new SealedClassInfo(_sealedClassOperations, sealedClass);
  }

  /// Returns the [StaticType] for the boolean [value].
  StaticType getBoolValueStaticType(bool value) {
    return value ? _boolStaticType.trueType : _boolStaticType.falseType;
  }

  /// Returns the [StaticType] for [type].
  StaticType getStaticType(Type type) {
    if (typeOperations.isNeverType(type)) {
      return StaticType.neverType;
    } else if (typeOperations.isNullType(type)) {
      return StaticType.nullType;
    } else if (typeOperations.isNonNullableObject(type)) {
      return StaticType.nonNullableObject;
    } else if (typeOperations.isNullableObject(type) ||
        typeOperations.isDynamic(type)) {
      return StaticType.nullableObject;
    }

    StaticType staticType;
    Type nonNullable = typeOperations.getNonNullable(type);
    if (typeOperations.isBoolType(nonNullable)) {
      staticType = _boolStaticType;
    } else if (typeOperations.isRecordType(nonNullable)) {
      staticType = new RecordStaticType(typeOperations, this, nonNullable);
    } else {
      Type? futureOrTypeArgument =
          typeOperations.getFutureOrTypeArgument(nonNullable);
      if (futureOrTypeArgument != null) {
        StaticType typeArgument = getStaticType(futureOrTypeArgument);
        StaticType futureType = getStaticType(
            typeOperations.instantiateFuture(futureOrTypeArgument));
        staticType = new FutureOrStaticType(
            typeOperations, this, nonNullable, typeArgument, futureType);
      } else {
        EnumClass? enumClass = enumOperations.getEnumClass(nonNullable);
        if (enumClass != null) {
          staticType = new EnumStaticType(
              typeOperations, this, nonNullable, _getEnumInfo(enumClass));
        } else {
          Class? sealedClass =
              _sealedClassOperations.getSealedClass(nonNullable);
          if (sealedClass != null) {
            staticType = new SealedClassStaticType(
                typeOperations,
                this,
                nonNullable,
                this,
                _sealedClassOperations,
                _getSealedClassInfo(sealedClass));
          } else {
            Type? listType = typeOperations.getListType(nonNullable);
            if (listType == nonNullable) {
              staticType =
                  new ListTypeStaticType(typeOperations, this, nonNullable);
            } else {
              staticType =
                  new TypeBasedStaticType(typeOperations, this, nonNullable);
            }
          }
        }
      }
    }
    if (typeOperations.isNullable(type)) {
      staticType = staticType.nullable;
    }
    return staticType;
  }

  /// Returns the [StaticType] for the [enumElementValue] declared by
  /// [enumClass].
  StaticType getEnumElementStaticType(
      EnumClass enumClass, EnumElementValue enumElementValue) {
    return _getEnumInfo(enumClass).getEnumElement(enumElementValue);
  }

  /// Creates a new unique [StaticType].
  StaticType getUnknownStaticType() {
    return getUniqueStaticType<Object>(
        typeOperations.nullableObjectType, new Object(), '?');
  }

  /// Returns a [StaticType] of the given [type] with the given
  /// [textualRepresentation] that unique identifies the [uniqueValue].
  ///
  /// This is used for constants that are neither bool nor enum values.
  StaticType getUniqueStaticType<Identity extends Object>(
      Type type, Identity uniqueValue, String textualRepresentation) {
    Type nonNullable = typeOperations.getNonNullable(type);
    StaticType staticType = _uniqueTypeMap[uniqueValue] ??=
        new RestrictedStaticType(
            typeOperations,
            this,
            nonNullable,
            new IdentityRestriction<Identity>(uniqueValue),
            textualRepresentation);
    if (typeOperations.isNullable(type)) {
      staticType = staticType.nullable;
    }
    return staticType;
  }

  /// Returns a [StaticType] of the list [type] with the given [identity] .
  StaticType getListStaticType(Type type, ListTypeIdentity<Type> identity) {
    Type nonNullable = typeOperations.getNonNullable(type);
    StaticType staticType = _uniqueTypeMap[identity] ??=
        new ListPatternStaticType(
            typeOperations, this, nonNullable, identity, identity.toString());
    if (typeOperations.isNullable(type)) {
      staticType = staticType.nullable;
    }
    return staticType;
  }

  /// Returns a [StaticType] of the map [type] with the given [identity] .
  StaticType getMapStaticType(Type type, MapTypeIdentity<Type> identity) {
    Type nonNullable = typeOperations.getNonNullable(type);
    StaticType staticType = _uniqueTypeMap[identity] ??=
        new MapPatternStaticType(
            typeOperations, this, nonNullable, identity, identity.toString());
    if (typeOperations.isNullable(type)) {
      staticType = staticType.nullable;
    }
    return staticType;
  }

  @override
  Map<String, StaticType> getFieldTypes(Type type) {
    Map<String, StaticType>? fields = _fieldCache[type];
    if (fields == null) {
      _fieldCache[type] = fields = {};
      for (MapEntry<String, Type> entry
          in typeOperations.getFieldTypes(type).entries) {
        fields[entry.key] = getStaticType(entry.value);
      }
    }
    return fields;
  }

  @override
  StaticType? getAdditionalFieldType(Type type, Key key) {
    if (key is MapKey) {
      Type? valueType = typeOperations.getMapValueType(type);
      if (valueType != null) {
        return getStaticType(valueType);
      }
    } else if (key is HeadKey || key is TailKey) {
      Type? elementType = typeOperations.getListElementType(type);
      if (elementType != null) {
        return getStaticType(elementType);
      }
    } else if (key is RestKey) {
      Type? listType = typeOperations.getListType(type);
      if (listType != null) {
        return getStaticType(listType);
      }
    }
    return null;
  }
}

/// [EnumInfo] stores information to compute the static type for and the type
/// of and enum class and its enum elements.
class EnumInfo<Type extends Object, EnumClass extends Object,
    EnumElement extends Object, EnumElementValue extends Object> {
  final TypeOperations<Type> _typeOperations;
  final FieldLookup<Type> _fieldLookup;
  final EnumOperations<Type, EnumClass, EnumElement, EnumElementValue>
      _enumOperations;
  final EnumClass _enumClass;
  Map<EnumElementValue, EnumElementStaticType<Type, EnumElement>>?
      _enumElements;

  EnumInfo(this._typeOperations, this._fieldLookup, this._enumOperations,
      this._enumClass);

  /// Returns a map of the enum elements and their corresponding [StaticType]s
  /// declared by [_enumClass].
  Map<EnumElementValue, EnumElementStaticType<Type, EnumElement>>
      get enumElements => _enumElements ??= _createEnumElements();

  /// Returns the [StaticType] corresponding to [enumElementValue].
  EnumElementStaticType<Type, EnumElement> getEnumElement(
      EnumElementValue enumElementValue) {
    return enumElements[enumElementValue]!;
  }

  Map<EnumElementValue, EnumElementStaticType<Type, EnumElement>>
      _createEnumElements() {
    Map<EnumElementValue, EnumElementStaticType<Type, EnumElement>> elements =
        {};
    for (EnumElement element in _enumOperations.getEnumElements(_enumClass)) {
      EnumElementValue value = _enumOperations.getEnumElementValue(element);
      elements[value] = new EnumElementStaticType<Type, EnumElement>(
          _typeOperations,
          _fieldLookup,
          _enumOperations.getEnumElementType(element),
          new IdentityRestriction<EnumElement>(element),
          _enumOperations.getEnumElementName(element));
    }
    return elements;
  }
}

/// [SealedClassInfo] stores information to compute the static type for a
/// sealed class.
class SealedClassInfo<Type extends Object, Class extends Object> {
  final SealedClassOperations<Type, Class> _sealedClassOperations;
  final Class _sealedClass;
  List<Class>? _subClasses;

  SealedClassInfo(this._sealedClassOperations, this._sealedClass);

  /// Returns the classes that directly extends, implements or mix in
  /// [_sealedClass].
  Iterable<Class> get subClasses =>
      _subClasses ??= _sealedClassOperations.getDirectSubclasses(_sealedClass);
}

/// [StaticType] based on a non-nullable [Type].
///
/// All [StaticType] implementation in this library are based on [Type] through
/// this class. Additionally, the `static_type.dart` library has fixed
/// [StaticType] implementations for `Object`, `Null`, `Never` and nullable
/// types.
class TypeBasedStaticType<Type extends Object> extends NonNullableStaticType {
  final TypeOperations<Type> _typeOperations;
  final FieldLookup<Type> _fieldLookup;
  final Type _type;

  TypeBasedStaticType(this._typeOperations, this._fieldLookup, this._type);

  @override
  Map<String, StaticType> get fields => _fieldLookup.getFieldTypes(_type);

  @override
  StaticType? getAdditionalField(Key key) =>
      _fieldLookup.getAdditionalFieldType(_type, key);

  /// Returns a [Restriction] value for static types the determines subtypes of
  /// the [_type]. For instance individual elements of an enum.
  Restriction get restriction => const Unrestricted();

  @override
  bool isSubtypeOfInternal(StaticType other) {
    return other is TypeBasedStaticType<Type> &&
        _typeOperations.isSubtypeOf(_type, other._type) &&
        restriction.isSubtypeOf(_typeOperations, other.restriction);
  }

  @override
  bool get isSealed => false;

  @override
  String get name => _typeOperations.typeToString(_type);

  @override
  int get hashCode => Object.hash(_type, restriction);

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return other is TypeBasedStaticType<Type> &&
        _type == other._type &&
        restriction == other.restriction;
  }

  Type get typeForTesting => _type;
}

/// [StaticType] for an instantiation of an enum that support access to the
/// enum values that populate its type through the [subtypes] property.
class EnumStaticType<Type extends Object, EnumElement extends Object>
    extends TypeBasedStaticType<Type> {
  final EnumInfo<Type, Object, EnumElement, Object> _enumInfo;
  List<StaticType>? _enumElements;

  EnumStaticType(
      super.typeOperations, super.fieldLookup, super.type, this._enumInfo);

  @override
  bool get isSealed => true;

  @override
  Iterable<StaticType> getSubtypes(Set<Key> keysOfInterest) => enumElements;

  List<StaticType> get enumElements => _enumElements ??= _createEnumElements();

  List<StaticType> _createEnumElements() {
    List<StaticType> elements = [];
    for (EnumElementStaticType<Type, EnumElement> enumElement
        in _enumInfo.enumElements.values) {
      // For generic enums, the individual enum elements might not be subtypes
      // of the concrete enum type. For instance
      //
      //    enum E<T> {
      //      a<int>(),
      //      b<String>(),
      //      c<bool>(),
      //    }
      //
      //    method<T extends num>(E<T> e) {
      //      switch (e) { ... }
      //    }
      //
      // Here the enum elements `E.b` and `E.c` cannot be actual values of `e`
      // because of the bound `num` on `T`.
      //
      // We detect this by checking whether the enum element type is a subtype
      // of the overapproximation of [_type], in this case whether the element
      // types are subtypes of `E<num>`.
      //
      // Since all type arguments on enum values are fixed, we don't have to
      // avoid the trivial subtype instantiation `E<Never>`.
      if (_typeOperations.isSubtypeOf(
          enumElement._type, _typeOperations.overapproximate(_type))) {
        // Since the type of the enum element might not itself be a subtype of
        // [_type], for instance in the example above the type of `Enum.a`,
        // `Enum<int>`, is not a subtype of `Enum<T>`, we wrap the static type
        // to establish the subtype relation between the [StaticType] for the
        // enum element and this [StaticType].
        elements.add(new WrappedStaticType(enumElement, this));
      }
    }
    return elements;
  }
}

/// [StaticType] for a single enum element.
///
/// In the [StaticType] model, individual enum elements are represented as
/// unique subtypes of the enum type, modelled using [EnumStaticType].
class EnumElementStaticType<Type extends Object, EnumElement extends Object>
    extends RestrictedStaticType<Type, IdentityRestriction<EnumElement>> {
  EnumElementStaticType(super.typeOperations, super.fieldLookup, super.type,
      super.restriction, super.name);
}

/// [StaticType] for a sealed class type.
class SealedClassStaticType<Type extends Object, Class extends Object>
    extends TypeBasedStaticType<Type> {
  final ExhaustivenessCache<Type, dynamic, dynamic, dynamic, Class> _cache;
  final SealedClassOperations<Type, Class> _sealedClassOperations;
  final SealedClassInfo<Type, Class> _sealedInfo;
  Iterable<StaticType>? _subtypes;

  SealedClassStaticType(super.typeOperations, super.fieldLookup, super.type,
      this._cache, this._sealedClassOperations, this._sealedInfo);

  @override
  bool get isSealed => true;

  @override
  Iterable<StaticType> getSubtypes(Set<Key> keysOfInterest) =>
      _subtypes ??= _createSubtypes();

  List<StaticType> _createSubtypes() {
    List<StaticType> subtypes = [];
    for (Class subClass in _sealedInfo.subClasses) {
      Type? subtype =
          _sealedClassOperations.getSubclassAsInstanceOf(subClass, _type);
      if (subtype != null) {
        if (!_typeOperations.isGeneric(subtype)) {
          // If the subtype is not generic, we can test whether it can be an
          // actual value of [_type] by testing whether it is a subtype of the
          // overapproximation of [_type].
          //
          // For instance
          //
          //     sealed class A<T> {}
          //     class B extends A<num> {}
          //     class C<T extends num> A<T> {}
          //
          //     method<T extends String>(A<T> a) {
          //       switch (a) {
          //         case B: // Not needed, B cannot inhabit A<T>.
          //         case C: // Needed, C<Never> inhabits A<T>.
          //       }
          //     }
          if (!_typeOperations.isSubtypeOf(
              subtype, _typeOperations.overapproximate(_type))) {
            continue;
          }
        }
        StaticType staticType = _cache.getStaticType(subtype);
        // Since the type of the [subtype] might not itself be a subtype of
        // [_type], for instance in the example above the type of `case C:`,
        // `C<num>`, is not a subtype of `A<T>`, we wrap the static type
        // to establish the subtype relation between the [StaticType] for the
        // enum element and this [StaticType].
        subtypes.add(new WrappedStaticType(staticType, this));
      }
    }
    return subtypes;
  }
}

/// [StaticType] for an object restricted by its [restriction].
class RestrictedStaticType<Type extends Object, Identity extends Restriction>
    extends TypeBasedStaticType<Type> {
  @override
  final Identity restriction;

  @override
  final String name;

  RestrictedStaticType(super.typeOperations, super.fieldLookup, super.type,
      this.restriction, this.name);
}

/// Interface for a restriction within a subtype relation.
///
/// This is used for instance to model enum values within an enum type and
/// map patterns within a map type.
abstract class Restriction<Type extends Object> {
  /// Returns `true` if this [Restriction] covers the whole type.
  bool get isUnrestricted;

  /// Returns `true` if this restriction is a subtype of [other].
  bool isSubtypeOf(TypeOperations<Type> typeOperations, Restriction other);
}

/// The unrestricted [Restriction] that covers all values of a type.
class Unrestricted implements Restriction<Object> {
  const Unrestricted();

  @override
  bool get isUnrestricted => true;

  @override
  bool isSubtypeOf(TypeOperations<Object> typeOperations, Restriction other) =>
      other.isUnrestricted;
}

/// [Restriction] based a unique [identity] value.
class IdentityRestriction<Identity extends Object>
    implements Restriction<Object> {
  final Identity identity;

  const IdentityRestriction(this.identity);

  @override
  bool get isUnrestricted => false;

  @override
  bool isSubtypeOf(TypeOperations<Object> typeOperations, Restriction other) =>
      other.isUnrestricted ||
      other is IdentityRestriction<Identity> && identity == other.identity;
}

/// [StaticType] for the `bool` type.
class BoolStaticType<Type extends Object> extends TypeBasedStaticType<Type> {
  BoolStaticType(super.typeOperations, super.fieldLookup, super.type);

  @override
  bool get isSealed => true;

  late StaticType trueType =
      new RestrictedStaticType<Type, IdentityRestriction<bool>>(_typeOperations,
          _fieldLookup, _type, const IdentityRestriction<bool>(true), 'true');

  late StaticType falseType =
      new RestrictedStaticType<Type, IdentityRestriction<bool>>(_typeOperations,
          _fieldLookup, _type, const IdentityRestriction<bool>(false), 'false');

  @override
  Iterable<StaticType> getSubtypes(Set<Key> keysOfInterest) =>
      [trueType, falseType];
}

/// [StaticType] for a record type.
///
/// This models that type aspect of the record using only the structure of the
/// record type. This means that the type for `(Object, String)` and
/// `(String, int)` will be subtypes of each other.
///
/// This is necessary to avoid invalid conclusions on the disjointness of
/// spaces base on the their types. For instance in
///
///     method((String, Object) o) {
///       if (o case (Object _, String s)) {}
///     }
///
/// the case is not empty even though `(String, Object)` and `(Object, String)`
/// are not related type-wise.
///
/// Not that the fields of the record types _are_ using the type, so that
/// the `$1` field of `(String, Object)` is known to contain only `String`s.
class RecordStaticType<Type extends Object> extends TypeBasedStaticType<Type> {
  RecordStaticType(super.typeOperations, super.fieldLookup, super.type);

  @override
  bool get isRecord => true;

  @override
  bool isSubtypeOfInternal(StaticType other) {
    if (other is! RecordStaticType<Type>) {
      return false;
    }
    if (fields.length != other.fields.length) {
      return false;
    }
    for (MapEntry<String, StaticType> field in fields.entries) {
      StaticType? type = other.fields[field.key];
      if (type == null) {
        return false;
      }
    }
    return true;
  }

  @override
  String spaceToText(
      Map<String, Space> spaceFields, Map<Key, Space> additionalSpaceFields) {
    StringBuffer buffer = new StringBuffer();
    buffer.write('(');
    bool first = true;
    fields.forEach((String name, StaticType staticType) {
      if (!first) buffer.write(', ');
      // TODO(johnniwinther): Ensure using Dart syntax for positional fields.
      buffer.write('$name: ${spaceFields[name] ?? staticType}');
      first = false;
    });

    buffer.write(')');
    return buffer.toString();
  }
}

/// [StaticType] for a `FutureOr<T>` type for some type `T`.
///
/// This is a sealed type where the subtypes for are `T` and `Future<T>`.
class FutureOrStaticType<Type extends Object>
    extends TypeBasedStaticType<Type> {
  /// The type for `T`.
  final StaticType _typeArgument;

  /// The type for `Future<T>`.
  final StaticType _futureType;

  FutureOrStaticType(super.typeOperations, super.fieldLookup, super.type,
      this._typeArgument, this._futureType);

  @override
  bool get isSealed => true;

  @override
  Iterable<StaticType> getSubtypes(Set<Key> keysOfInterest) =>
      [_typeArgument, _futureType];
}

/// [StaticType] for a map pattern type using a [MapTypeIdentity] for its
/// uniqueness.
class MapPatternStaticType<Type extends Object>
    extends RestrictedStaticType<Type, MapTypeIdentity<Type>> {
  MapPatternStaticType(super.typeOperations, super.fieldLookup, super.type,
      super.restriction, super.name);

  @override
  String spaceToText(
      Map<String, Space> spaceFields, Map<Key, Space> additionalSpaceFields) {
    StringBuffer buffer = new StringBuffer();
    buffer.write(restriction.typeArgumentsText);
    buffer.write('{');

    bool first = true;
    additionalSpaceFields.forEach((Key key, Space space) {
      if (!first) buffer.write(', ');
      buffer.write('$key: $space');
      first = false;
    });
    if (restriction.hasRest) {
      if (!first) buffer.write(', ');
      buffer.write('...');
    }

    buffer.write('}');
    return buffer.toString();
  }
}

/// Identity object used for creating a unique [MapPatternStaticType] for a
/// map pattern.
///
/// The uniqueness is defined by the key and value types, the key values of
/// the map pattern, and whether the map pattern has a rest element.
///
/// This identity ensures that we can detect overlap between map patterns with
/// the same set of keys.
class MapTypeIdentity<Type extends Object> implements Restriction<Type> {
  final Type keyType;
  final Type valueType;
  final Set<MapKey> keys;
  final bool hasRest;
  final String typeArgumentsText;

  MapTypeIdentity(
      this.keyType, this.valueType, this.keys, this.typeArgumentsText,
      {required this.hasRest});

  @override
  late final int hashCode =
      Object.hash(keyType, valueType, Object.hashAllUnordered(keys), hasRest);

  @override
  bool get isUnrestricted {
    // The map pattern containing only a rest pattern covers the whole type.
    return hasRest && keys.isEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MapTypeIdentity<Type>) return false;
    if (keyType != other.keyType ||
        valueType != other.valueType ||
        hasRest != other.hasRest) {
      return false;
    }
    if (keys.length != other.keys.length) return false;
    return keys.containsAll(other.keys);
  }

  @override
  bool isSubtypeOf(TypeOperations<Type> typeOperations, Restriction other) {
    if (other.isUnrestricted) return true;
    if (other is! MapTypeIdentity<Type>) return false;
    if (!typeOperations.isSubtypeOf(keyType, other.keyType)) return false;
    if (!typeOperations.isSubtypeOf(valueType, other.valueType)) return false;
    if (other.hasRest) {
      return keys.containsAll(other.keys);
    } else if (hasRest) {
      return false;
    } else {
      return keys.length == other.keys.length && keys.containsAll(other.keys);
    }
  }

  @override
  String toString() {
    StringBuffer sb = new StringBuffer();
    sb.write(typeArgumentsText);
    sb.write('{');
    String comma = '';
    for (MapKey key in keys) {
      sb.write(comma);
      sb.write(key);
      sb.write(': ()');
      comma = ', ';
    }
    if (hasRest) {
      sb.write(comma);
      sb.write('...');
      comma = ', ';
    }
    sb.write('}');
    return sb.toString();
  }
}

/// [StaticType] for a list type which can be divided into subtypes of
/// [ListPatternStaticType].
///
/// This is used to support exhaustiveness checking for list types by
/// contextually dividing the list into relevant cases for checking.
///
/// For instance, the exhaustiveness can be achieved by a single pattern
///
///     case [...]:
///
/// or by two disjoint patterns:
///
///     case []:
///     case [_, ...]:
///
/// When checking for exhaustiveness, witness candidates are created and tested
/// against the available cases. This means that the chosen candidates must be
/// matched by at least one case or the candidate is considered a witness of
/// non-exhaustiveness.
///
/// Looking at the first example, we could choose `[...]`, the list of
/// arbitrary size, as a candidate. This works for the first example, since the
/// case `[...]` matches the list of arbitrary size. But if we tried to use this
/// on the second example it would fail, since neither `[]` nor `[_, ...]` fully
/// matches the list of arbitrary size.
///
/// A solution could be to choose candidates `[]` and `[_, ...]`, the empty list
/// and the list of 1 or more elements. This would work for the first example,
/// since `[...]` matches both the empty list and the list of 1 or more
/// elements. It also works for the second example, since `[]` matches the empty
/// list and `[_, ...]` matches the list of 1 or more elements.
///
/// But now comes a third way of exhaustively matching a list:
///
///     case []:
///     case [_]:
///     case [_, _, ...]:
///
/// and our candidates no longer work, since while `[]` does match the empty
/// list, neither `[_]` nor `[_, _, ...]` matches the list of 1 or more
/// elements.
///
/// This shows us that there can be no fixed set of witness candidates that we
/// can use to match a list type.
///
/// What we do instead, is to create the set of witness candidates based on the
/// cases that should match it. We find the maximal number, n, of fixed, i.e.
/// non-rest, elements in the cases, and then create the lists of sizes 0 to n-1
/// and the list of n or more elements as the witness candidates.
class ListTypeStaticType<Type extends Object>
    extends TypeBasedStaticType<Type> {
  ListTypeStaticType(super.typeOperations, super.fieldLookup, super.type);

  @override
  bool get isSealed => true;

  @override
  Iterable<StaticType> getSubtypes(Set<Key> keysOfInterest) {
    int maxHeadSize = 0;
    int maxTailSize = 0;
    for (Key key in keysOfInterest) {
      if (key is HeadKey) {
        if (key.index >= maxHeadSize) {
          maxHeadSize = key.index + 1;
        }
      } else if (key is TailKey) {
        if (key.index >= maxTailSize) {
          maxTailSize = key.index + 1;
        }
      }
    }
    int maxSize = maxHeadSize + maxTailSize;
    List<StaticType> subtypes = [];
    Type elementType = _typeOperations.getListElementType(_type)!;
    String typeArgumentText;
    if (_typeOperations.isDynamic(elementType)) {
      typeArgumentText = '';
    } else {
      typeArgumentText = '<${_typeOperations.typeToString(elementType)}>';
    }
    for (int size = 0; size < maxSize; size++) {
      ListTypeIdentity<Type> identity = new ListTypeIdentity(
          elementType, typeArgumentText,
          size: size, hasRest: false);
      subtypes.add(new ListPatternStaticType<Type>(
          _typeOperations, _fieldLookup, _type, identity, identity.toString()));
    }
    ListTypeIdentity<Type> identity = new ListTypeIdentity(
        elementType, typeArgumentText,
        size: maxSize, hasRest: true);
    subtypes.add(new ListPatternStaticType<Type>(
        _typeOperations, _fieldLookup, _type, identity, identity.toString()));
    return subtypes;
  }
}

/// [StaticType] for a list pattern type using a [ListTypeIdentity] for its
/// uniqueness.
class ListPatternStaticType<Type extends Object>
    extends RestrictedStaticType<Type, ListTypeIdentity<Type>> {
  ListPatternStaticType(super.typeOperations, super.fieldLookup, super.type,
      super.restriction, super.name);

  @override
  String spaceToText(
      Map<String, Space> spaceFields, Map<Key, Space> additionalSpaceFields) {
    StringBuffer buffer = new StringBuffer();
    buffer.write(restriction.typeArgumentText);
    buffer.write('[');

    bool first = true;
    additionalSpaceFields.forEach((Key key, Space space) {
      if (!first) buffer.write(', ');
      if (key is RestKey) {
        buffer.write('...');
      }
      buffer.write(space);
      first = false;
    });

    buffer.write(']');
    return buffer.toString();
  }
}

/// Identity object used for creating a unique [ListPatternStaticType] for a
/// list pattern.
///
/// The uniqueness is defined by the element type, the number of elements at the
/// start of the list, whether the list pattern has a rest element, and the
/// number elements at the end of the list, after the rest element.
class ListTypeIdentity<Type extends Object> implements Restriction<Type> {
  final Type elementType;
  final int size;
  final bool hasRest;
  final String typeArgumentText;

  ListTypeIdentity(this.elementType, this.typeArgumentText,
      {required this.size, required this.hasRest});

  @override
  late final int hashCode = Object.hash(elementType, size, hasRest);

  @override
  bool get isUnrestricted {
    // The map pattern containing only a rest pattern covers the whole type.
    return hasRest && size == 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListTypeIdentity<Type> &&
        elementType == other.elementType &&
        size == other.size &&
        hasRest == other.hasRest;
  }

  @override
  bool isSubtypeOf(TypeOperations<Type> typeOperations, Restriction other) {
    if (other.isUnrestricted) return true;
    if (other is! ListTypeIdentity<Type>) return false;
    if (!typeOperations.isSubtypeOf(elementType, other.elementType)) {
      return false;
    }
    if (other.hasRest) {
      return size >= other.size;
    } else if (hasRest) {
      return false;
    } else {
      return size == other.size;
    }
  }

  @override
  String toString() {
    StringBuffer sb = new StringBuffer();
    sb.write(typeArgumentText);
    sb.write('[');
    String comma = '';
    for (int i = 0; i < size; i++) {
      sb.write(comma);
      sb.write('()');
      comma = ', ';
    }
    if (hasRest) {
      sb.write(comma);
      sb.write('...');
      comma = ', ';
    }
    sb.write(']');
    return sb.toString();
  }
}

/// Mixin for creating [Space]s from [Pattern]s.
mixin SpaceCreator<Pattern extends Object, Type extends Object> {
  TypeOperations<Type> get typeOperations;

  /// Creates a [StaticType] for an unknown type.
  ///
  /// This is used when the type of the pattern is unknown or can't be
  /// represented as a [StaticType]. This type is unique and ensures that it
  /// is neither matches anything nor is matched by anything.
  StaticType createUnknownStaticType();

  /// Creates the [StaticType] for [type]. If [nonNull] is `true`, the created
  /// type is non-nullable.
  StaticType createStaticType(Type type, {required bool nonNull});

  /// Creates the [StaticType] for the list [type] with the given [identity].
  StaticType createListType(Type type, ListTypeIdentity<Type> identity);

  /// Creates the [StaticType] for the map [type] with the given [identity].
  StaticType createMapType(Type type, MapTypeIdentity<Type> identity);

  /// Creates the [Space] for [pattern] at the given [path].
  ///
  /// If [nonNull] is `true`, the space is implicitly non-nullable.
  Space dispatchPattern(Path path, Pattern pattern, {required bool nonNull});

  /// Creates the root space for [pattern].
  Space createRootSpace(Pattern pattern, {required bool hasGuard}) {
    if (hasGuard) {
      return createUnknownSpace(const Path.root());
    } else {
      return dispatchPattern(const Path.root(), pattern, nonNull: false);
    }
  }

  /// Creates the [Space] at [path] for a variable pattern of the declared
  /// [type].
  ///
  /// If [nonNull] is `true`, the space is implicitly non-nullable.
  Space createVariableSpace(Path path, Type type, {required bool nonNull}) {
    return new Space(path, createStaticType(type, nonNull: nonNull));
  }

  /// Creates the [Space] at [path] for an object pattern of the required [type]
  /// and [fieldPatterns].
  ///
  /// If [nonNull] is `true`, the space is implicitly non-nullable.
  Space createObjectSpace(
      Path path, Type type, Map<String, Pattern> fieldPatterns,
      {required bool nonNull}) {
    Map<String, Space> fields = <String, Space>{};
    for (MapEntry<String, Pattern> entry in fieldPatterns.entries) {
      String name = entry.key;
      fields[name] =
          dispatchPattern(path.add(name), entry.value, nonNull: false);
    }
    StaticType staticType = createStaticType(type, nonNull: nonNull);
    return new Space(path, staticType, fields: fields);
  }

  /// Creates the [Space] at [path] for a record pattern of the required [type],
  /// [positionalFields], and [namedFields].
  Space createRecordSpace(Path path, Type recordType,
      List<Pattern> positionalFields, Map<String, Pattern> namedFields) {
    Map<String, Space> fields = <String, Space>{};
    for (int index = 0; index < positionalFields.length; index++) {
      String name = '\$${index + 1}';
      fields[name] = dispatchPattern(path.add(name), positionalFields[index],
          nonNull: false);
    }
    for (MapEntry<String, Pattern> entry in namedFields.entries) {
      String name = entry.key;
      fields[name] =
          dispatchPattern(path.add(name), entry.value, nonNull: false);
    }
    return new Space(path, createStaticType(recordType, nonNull: true),
        fields: fields);
  }

  /// Creates the [Space] at [path] for a wildcard pattern with the declared
  /// [type].
  ///
  /// If [nonNull] is `true`, the space is implicitly non-nullable.
  Space createWildcardSpace(Path path, Type? type, {required bool nonNull}) {
    if (type == null) {
      if (nonNull) {
        return new Space(path, StaticType.nonNullableObject);
      } else {
        return new Space(path, StaticType.nullableObject);
      }
    } else {
      StaticType staticType = createStaticType(type, nonNull: nonNull);
      return new Space(path, staticType);
    }
  }

  /// Creates the [Space] at [path] for a relational pattern.
  Space createRelationalSpace(Path path) {
    // This pattern do not add to the exhaustiveness coverage.
    return createUnknownSpace(path);
  }

  /// Creates the [Space] at [path] for a cast pattern with the given
  /// [subPattern].
  ///
  /// If [nonNull] is `true`, the space is implicitly non-nullable.
  Space createCastSpace(Path path, Pattern subPattern,
      {required bool nonNull}) {
    // TODO(johnniwinther): Handle types (sibling sealed types?) implicitly
    // handled by the throw of the invalid cast.
    return dispatchPattern(path, subPattern, nonNull: nonNull);
  }

  /// Creates the [Space] at [path] for a null check pattern with the given
  /// [subPattern].
  Space createNullCheckSpace(Path path, Pattern subPattern) {
    return dispatchPattern(path, subPattern, nonNull: true);
  }

  /// Creates the [Space] at [path] for a null assert pattern with the given
  /// [subPattern].
  Space createNullAssertSpace(Path path, Pattern subPattern) {
    Space space = dispatchPattern(path, subPattern, nonNull: true);
    return space.union(new Space(path, StaticType.nullType));
  }

  /// Creates the [Space] at [path] for a logical or pattern with the given
  /// [left] and [right] subpatterns.
  ///
  /// If [nonNull] is `true`, the space is implicitly non-nullable.
  Space createLogicalOrSpace(Path path, Pattern left, Pattern right,
      {required bool nonNull}) {
    Space aSpace = dispatchPattern(path, left, nonNull: nonNull);
    Space bSpace = dispatchPattern(path, right, nonNull: nonNull);
    return aSpace.union(bSpace);
  }

  /// Creates the [Space] at [path] for a logical and pattern with the given
  /// [left] and [right] subpatterns.
  ///
  /// If [nonNull] is `true`, the space is implicitly non-nullable.
  Space createLogicalAndSpace(Path path, Pattern left, Pattern right,
      {required bool nonNull}) {
    Space aSpace = dispatchPattern(path, left, nonNull: nonNull);
    Space bSpace = dispatchPattern(path, right, nonNull: nonNull);
    return _createSpaceIntersection(path, aSpace, bSpace);
  }

  /// Creates the [Space] at [path] for a list pattern.
  Space createListSpace(Path path,
      {required Type type,
      required Type elementType,
      required List<Pattern> headElements,
      required Pattern? restElement,
      required List<Pattern> tailElements,
      required bool hasRest,
      required bool hasExplicitTypeArgument}) {
    Map<Key, Space> additionalFields = {};
    int headSize = headElements.length;
    int tailSize = tailElements.length;
    for (int index = 0; index < headSize; index++) {
      Key key = new HeadKey(index);
      additionalFields[key] = dispatchPattern(
          path.add(key.name), headElements[index],
          nonNull: false);
    }
    if (hasRest) {
      Key key = new RestKey(headSize, tailSize);
      if (restElement != null) {
        additionalFields[key] =
            dispatchPattern(path.add(key.name), restElement, nonNull: false);
      } else {
        additionalFields[key] =
            new Space(path.add(key.name), StaticType.nullableObject);
      }
    }
    for (int index = 0; index < tailSize; index++) {
      Key key = new TailKey(index);
      additionalFields[key] = dispatchPattern(
          path.add(key.name), tailElements[tailElements.length - index - 1],
          nonNull: false);
    }
    String typeArgumentText;
    if (hasExplicitTypeArgument) {
      StringBuffer sb = new StringBuffer();
      sb.write('<');
      sb.write(typeOperations.typeToString(elementType));
      sb.write('>');
      typeArgumentText = sb.toString();
    } else {
      typeArgumentText = '';
    }

    ListTypeIdentity<Type> identity = new ListTypeIdentity(
        elementType, typeArgumentText,
        size: headSize + tailSize, hasRest: hasRest);
    return new Space(path, createListType(type, identity),
        additionalFields: additionalFields);
  }

  /// Creates the [Space] at [path] for a map pattern.
  Space createMapSpace(Path path,
      {required Type type,
      required Type keyType,
      required Type valueType,
      required Map<MapKey, Pattern> entries,
      required bool hasRest,
      required bool hasExplicitTypeArguments}) {
    Map<Key, Space> additionalFields = {};
    for (MapEntry<Key, Pattern> entry in entries.entries) {
      Key key = entry.key;
      additionalFields[key] =
          dispatchPattern(path.add(key.name), entry.value, nonNull: false);
    }
    String typeArgumentsText;
    if (hasExplicitTypeArguments) {
      StringBuffer sb = new StringBuffer();
      sb.write('<');
      sb.write(typeOperations.typeToString(keyType));
      sb.write(', ');
      sb.write(typeOperations.typeToString(valueType));
      sb.write('>');
      typeArgumentsText = sb.toString();
    } else {
      typeArgumentsText = '';
    }

    MapTypeIdentity<Type> identity = new MapTypeIdentity(
        keyType, valueType, entries.keys.toSet(), typeArgumentsText,
        hasRest: hasRest);
    return new Space(path, createMapType(type, identity),
        additionalFields: additionalFields);
  }

  /// Creates the [Space] at [path] for a pattern with unknown space.
  ///
  /// This is used when the space of the pattern is unknown or can't be
  /// represented precisely as a union of [SingleSpace]s. This space is unique
  /// and ensures that it is neither matches anything nor is matched by
  /// anything.
  Space createUnknownSpace(Path path) {
    return new Space(path, createUnknownStaticType());
  }

  /// Creates an approximation of the intersection of the single spaces [a] and
  /// [b].
  SingleSpace? _createSingleSpaceIntersection(
      Path path, SingleSpace a, SingleSpace b) {
    StaticType? type;
    if (a.type.isSubtypeOf(b.type)) {
      type = a.type;
    } else if (b.type.isSubtypeOf(a.type)) {
      type = b.type;
    }
    if (type == null) {
      return null;
    }
    Map<String, Space> fields = {};
    for (MapEntry<String, Space> entry in a.fields.entries) {
      String name = entry.key;
      Space aSpace = entry.value;
      Space? bSpace = b.fields[name];
      if (bSpace != null) {
        fields[name] = _createSpaceIntersection(path.add(name), aSpace, bSpace);
      } else {
        fields[name] = aSpace;
      }
    }
    for (MapEntry<String, Space> entry in b.fields.entries) {
      String name = entry.key;
      fields[name] ??= entry.value;
    }
    return new SingleSpace(type, fields: fields);
  }

  /// Creates an approximation of the intersection of spaces [a] and [b].
  Space _createSpaceIntersection(Path path, Space a, Space b) {
    assert(
        path == a.path, "Unexpected path. Expected $path, actual ${a.path}.");
    assert(
        path == b.path, "Unexpected path. Expected $path, actual ${b.path}.");
    List<SingleSpace> singleSpaces = [];
    bool hasUnknownSpace = false;
    for (SingleSpace aSingleSpace in a.singleSpaces) {
      for (SingleSpace bSingleSpace in b.singleSpaces) {
        SingleSpace? space =
            _createSingleSpaceIntersection(path, aSingleSpace, bSingleSpace);
        if (space != null) {
          singleSpaces.add(space);
        } else {
          hasUnknownSpace = true;
        }
      }
    }
    if (hasUnknownSpace) {
      singleSpaces.add(new SingleSpace(createUnknownStaticType()));
    }
    return new Space.fromSingleSpaces(path, singleSpaces);
  }
}
