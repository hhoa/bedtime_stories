// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChildProfile {

 String get name; Gender get gender;
/// Create a copy of ChildProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildProfileCopyWith<ChildProfile> get copyWith => _$ChildProfileCopyWithImpl<ChildProfile>(this as ChildProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildProfile&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender));
}


@override
int get hashCode => Object.hash(runtimeType,name,gender);

@override
String toString() {
  return 'ChildProfile(name: $name, gender: $gender)';
}


}

/// @nodoc
abstract mixin class $ChildProfileCopyWith<$Res>  {
  factory $ChildProfileCopyWith(ChildProfile value, $Res Function(ChildProfile) _then) = _$ChildProfileCopyWithImpl;
@useResult
$Res call({
 String name, Gender gender
});




}
/// @nodoc
class _$ChildProfileCopyWithImpl<$Res>
    implements $ChildProfileCopyWith<$Res> {
  _$ChildProfileCopyWithImpl(this._self, this._then);

  final ChildProfile _self;
  final $Res Function(ChildProfile) _then;

/// Create a copy of ChildProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? gender = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,
  ));
}

}


/// Adds pattern-matching-related methods to [ChildProfile].
extension ChildProfilePatterns on ChildProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChildProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChildProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChildProfile value)  $default,){
final _that = this;
switch (_that) {
case _ChildProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChildProfile value)?  $default,){
final _that = this;
switch (_that) {
case _ChildProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  Gender gender)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChildProfile() when $default != null:
return $default(_that.name,_that.gender);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  Gender gender)  $default,) {final _that = this;
switch (_that) {
case _ChildProfile():
return $default(_that.name,_that.gender);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  Gender gender)?  $default,) {final _that = this;
switch (_that) {
case _ChildProfile() when $default != null:
return $default(_that.name,_that.gender);case _:
  return null;

}
}

}

/// @nodoc


class _ChildProfile implements ChildProfile {
  const _ChildProfile({required this.name, required this.gender});
  

@override final  String name;
@override final  Gender gender;

/// Create a copy of ChildProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChildProfileCopyWith<_ChildProfile> get copyWith => __$ChildProfileCopyWithImpl<_ChildProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChildProfile&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender));
}


@override
int get hashCode => Object.hash(runtimeType,name,gender);

@override
String toString() {
  return 'ChildProfile(name: $name, gender: $gender)';
}


}

/// @nodoc
abstract mixin class _$ChildProfileCopyWith<$Res> implements $ChildProfileCopyWith<$Res> {
  factory _$ChildProfileCopyWith(_ChildProfile value, $Res Function(_ChildProfile) _then) = __$ChildProfileCopyWithImpl;
@override @useResult
$Res call({
 String name, Gender gender
});




}
/// @nodoc
class __$ChildProfileCopyWithImpl<$Res>
    implements _$ChildProfileCopyWith<$Res> {
  __$ChildProfileCopyWithImpl(this._self, this._then);

  final _ChildProfile _self;
  final $Res Function(_ChildProfile) _then;

/// Create a copy of ChildProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? gender = null,}) {
  return _then(_ChildProfile(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,
  ));
}


}

// dart format on
