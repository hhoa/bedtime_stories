// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_list_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoryListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'StoryListState()';
}


}

/// @nodoc
class $StoryListStateCopyWith<$Res>  {
$StoryListStateCopyWith(StoryListState _, $Res Function(StoryListState) __);
}


/// Adds pattern-matching-related methods to [StoryListState].
extension StoryListStatePatterns on StoryListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( StoryListLoading value)?  loading,TResult Function( StoryListLoaded value)?  loaded,TResult Function( StoryListFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case StoryListLoading() when loading != null:
return loading(_that);case StoryListLoaded() when loaded != null:
return loaded(_that);case StoryListFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( StoryListLoading value)  loading,required TResult Function( StoryListLoaded value)  loaded,required TResult Function( StoryListFailure value)  failure,}){
final _that = this;
switch (_that) {
case StoryListLoading():
return loading(_that);case StoryListLoaded():
return loaded(_that);case StoryListFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( StoryListLoading value)?  loading,TResult? Function( StoryListLoaded value)?  loaded,TResult? Function( StoryListFailure value)?  failure,}){
final _that = this;
switch (_that) {
case StoryListLoading() when loading != null:
return loading(_that);case StoryListLoaded() when loaded != null:
return loaded(_that);case StoryListFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( List<Story> stories)?  loaded,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case StoryListLoading() when loading != null:
return loading();case StoryListLoaded() when loaded != null:
return loaded(_that.stories);case StoryListFailure() when failure != null:
return failure(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( List<Story> stories)  loaded,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case StoryListLoading():
return loading();case StoryListLoaded():
return loaded(_that.stories);case StoryListFailure():
return failure(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( List<Story> stories)?  loaded,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case StoryListLoading() when loading != null:
return loading();case StoryListLoaded() when loaded != null:
return loaded(_that.stories);case StoryListFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class StoryListLoading implements StoryListState {
  const StoryListLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryListLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'StoryListState.loading()';
}


}




/// @nodoc


class StoryListLoaded implements StoryListState {
  const StoryListLoaded(final  List<Story> stories): _stories = stories;
  

 final  List<Story> _stories;
 List<Story> get stories {
  if (_stories is EqualUnmodifiableListView) return _stories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stories);
}


/// Create a copy of StoryListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryListLoadedCopyWith<StoryListLoaded> get copyWith => _$StoryListLoadedCopyWithImpl<StoryListLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryListLoaded&&const DeepCollectionEquality().equals(other._stories, _stories));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_stories));

@override
String toString() {
  return 'StoryListState.loaded(stories: $stories)';
}


}

/// @nodoc
abstract mixin class $StoryListLoadedCopyWith<$Res> implements $StoryListStateCopyWith<$Res> {
  factory $StoryListLoadedCopyWith(StoryListLoaded value, $Res Function(StoryListLoaded) _then) = _$StoryListLoadedCopyWithImpl;
@useResult
$Res call({
 List<Story> stories
});




}
/// @nodoc
class _$StoryListLoadedCopyWithImpl<$Res>
    implements $StoryListLoadedCopyWith<$Res> {
  _$StoryListLoadedCopyWithImpl(this._self, this._then);

  final StoryListLoaded _self;
  final $Res Function(StoryListLoaded) _then;

/// Create a copy of StoryListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stories = null,}) {
  return _then(StoryListLoaded(
null == stories ? _self._stories : stories // ignore: cast_nullable_to_non_nullable
as List<Story>,
  ));
}


}

/// @nodoc


class StoryListFailure implements StoryListState {
  const StoryListFailure(this.message);
  

 final  String message;

/// Create a copy of StoryListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryListFailureCopyWith<StoryListFailure> get copyWith => _$StoryListFailureCopyWithImpl<StoryListFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryListFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'StoryListState.failure(message: $message)';
}


}

/// @nodoc
abstract mixin class $StoryListFailureCopyWith<$Res> implements $StoryListStateCopyWith<$Res> {
  factory $StoryListFailureCopyWith(StoryListFailure value, $Res Function(StoryListFailure) _then) = _$StoryListFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$StoryListFailureCopyWithImpl<$Res>
    implements $StoryListFailureCopyWith<$Res> {
  _$StoryListFailureCopyWithImpl(this._self, this._then);

  final StoryListFailure _self;
  final $Res Function(StoryListFailure) _then;

/// Create a copy of StoryListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(StoryListFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
