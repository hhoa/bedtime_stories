// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PathStep {

 String get nodeId; String get optionId; ChoiceKind get kind;
/// Create a copy of PathStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PathStepCopyWith<PathStep> get copyWith => _$PathStepCopyWithImpl<PathStep>(this as PathStep, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PathStep&&(identical(other.nodeId, nodeId) || other.nodeId == nodeId)&&(identical(other.optionId, optionId) || other.optionId == optionId)&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode => Object.hash(runtimeType,nodeId,optionId,kind);

@override
String toString() {
  return 'PathStep(nodeId: $nodeId, optionId: $optionId, kind: $kind)';
}


}

/// @nodoc
abstract mixin class $PathStepCopyWith<$Res>  {
  factory $PathStepCopyWith(PathStep value, $Res Function(PathStep) _then) = _$PathStepCopyWithImpl;
@useResult
$Res call({
 String nodeId, String optionId, ChoiceKind kind
});




}
/// @nodoc
class _$PathStepCopyWithImpl<$Res>
    implements $PathStepCopyWith<$Res> {
  _$PathStepCopyWithImpl(this._self, this._then);

  final PathStep _self;
  final $Res Function(PathStep) _then;

/// Create a copy of PathStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nodeId = null,Object? optionId = null,Object? kind = null,}) {
  return _then(_self.copyWith(
nodeId: null == nodeId ? _self.nodeId : nodeId // ignore: cast_nullable_to_non_nullable
as String,optionId: null == optionId ? _self.optionId : optionId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ChoiceKind,
  ));
}

}


/// Adds pattern-matching-related methods to [PathStep].
extension PathStepPatterns on PathStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PathStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PathStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PathStep value)  $default,){
final _that = this;
switch (_that) {
case _PathStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PathStep value)?  $default,){
final _that = this;
switch (_that) {
case _PathStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nodeId,  String optionId,  ChoiceKind kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PathStep() when $default != null:
return $default(_that.nodeId,_that.optionId,_that.kind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nodeId,  String optionId,  ChoiceKind kind)  $default,) {final _that = this;
switch (_that) {
case _PathStep():
return $default(_that.nodeId,_that.optionId,_that.kind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nodeId,  String optionId,  ChoiceKind kind)?  $default,) {final _that = this;
switch (_that) {
case _PathStep() when $default != null:
return $default(_that.nodeId,_that.optionId,_that.kind);case _:
  return null;

}
}

}

/// @nodoc


class _PathStep implements PathStep {
  const _PathStep({required this.nodeId, required this.optionId, required this.kind});
  

@override final  String nodeId;
@override final  String optionId;
@override final  ChoiceKind kind;

/// Create a copy of PathStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PathStepCopyWith<_PathStep> get copyWith => __$PathStepCopyWithImpl<_PathStep>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PathStep&&(identical(other.nodeId, nodeId) || other.nodeId == nodeId)&&(identical(other.optionId, optionId) || other.optionId == optionId)&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode => Object.hash(runtimeType,nodeId,optionId,kind);

@override
String toString() {
  return 'PathStep(nodeId: $nodeId, optionId: $optionId, kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$PathStepCopyWith<$Res> implements $PathStepCopyWith<$Res> {
  factory _$PathStepCopyWith(_PathStep value, $Res Function(_PathStep) _then) = __$PathStepCopyWithImpl;
@override @useResult
$Res call({
 String nodeId, String optionId, ChoiceKind kind
});




}
/// @nodoc
class __$PathStepCopyWithImpl<$Res>
    implements _$PathStepCopyWith<$Res> {
  __$PathStepCopyWithImpl(this._self, this._then);

  final _PathStep _self;
  final $Res Function(_PathStep) _then;

/// Create a copy of PathStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nodeId = null,Object? optionId = null,Object? kind = null,}) {
  return _then(_PathStep(
nodeId: null == nodeId ? _self.nodeId : nodeId // ignore: cast_nullable_to_non_nullable
as String,optionId: null == optionId ? _self.optionId : optionId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ChoiceKind,
  ));
}


}

/// @nodoc
mixin _$PartCue {

 String get part; PartAction get action; int get seq;/// See [StoryCue.pose] and [StoryCue.to].
 String? get pose; CanvasPoint? get to;
/// Create a copy of PartCue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartCueCopyWith<PartCue> get copyWith => _$PartCueCopyWithImpl<PartCue>(this as PartCue, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartCue&&(identical(other.part, part) || other.part == part)&&(identical(other.action, action) || other.action == action)&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.pose, pose) || other.pose == pose)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,part,action,seq,pose,to);

@override
String toString() {
  return 'PartCue(part: $part, action: $action, seq: $seq, pose: $pose, to: $to)';
}


}

/// @nodoc
abstract mixin class $PartCueCopyWith<$Res>  {
  factory $PartCueCopyWith(PartCue value, $Res Function(PartCue) _then) = _$PartCueCopyWithImpl;
@useResult
$Res call({
 String part, PartAction action, int seq, String? pose, CanvasPoint? to
});




}
/// @nodoc
class _$PartCueCopyWithImpl<$Res>
    implements $PartCueCopyWith<$Res> {
  _$PartCueCopyWithImpl(this._self, this._then);

  final PartCue _self;
  final $Res Function(PartCue) _then;

/// Create a copy of PartCue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? part = null,Object? action = null,Object? seq = null,Object? pose = freezed,Object? to = freezed,}) {
  return _then(_self.copyWith(
part: null == part ? _self.part : part // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as PartAction,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,pose: freezed == pose ? _self.pose : pose // ignore: cast_nullable_to_non_nullable
as String?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as CanvasPoint?,
  ));
}

}


/// Adds pattern-matching-related methods to [PartCue].
extension PartCuePatterns on PartCue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartCue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartCue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartCue value)  $default,){
final _that = this;
switch (_that) {
case _PartCue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartCue value)?  $default,){
final _that = this;
switch (_that) {
case _PartCue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String part,  PartAction action,  int seq,  String? pose,  CanvasPoint? to)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartCue() when $default != null:
return $default(_that.part,_that.action,_that.seq,_that.pose,_that.to);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String part,  PartAction action,  int seq,  String? pose,  CanvasPoint? to)  $default,) {final _that = this;
switch (_that) {
case _PartCue():
return $default(_that.part,_that.action,_that.seq,_that.pose,_that.to);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String part,  PartAction action,  int seq,  String? pose,  CanvasPoint? to)?  $default,) {final _that = this;
switch (_that) {
case _PartCue() when $default != null:
return $default(_that.part,_that.action,_that.seq,_that.pose,_that.to);case _:
  return null;

}
}

}

/// @nodoc


class _PartCue implements PartCue {
  const _PartCue({required this.part, required this.action, required this.seq, this.pose, this.to});
  

@override final  String part;
@override final  PartAction action;
@override final  int seq;
/// See [StoryCue.pose] and [StoryCue.to].
@override final  String? pose;
@override final  CanvasPoint? to;

/// Create a copy of PartCue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartCueCopyWith<_PartCue> get copyWith => __$PartCueCopyWithImpl<_PartCue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartCue&&(identical(other.part, part) || other.part == part)&&(identical(other.action, action) || other.action == action)&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.pose, pose) || other.pose == pose)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,part,action,seq,pose,to);

@override
String toString() {
  return 'PartCue(part: $part, action: $action, seq: $seq, pose: $pose, to: $to)';
}


}

/// @nodoc
abstract mixin class _$PartCueCopyWith<$Res> implements $PartCueCopyWith<$Res> {
  factory _$PartCueCopyWith(_PartCue value, $Res Function(_PartCue) _then) = __$PartCueCopyWithImpl;
@override @useResult
$Res call({
 String part, PartAction action, int seq, String? pose, CanvasPoint? to
});




}
/// @nodoc
class __$PartCueCopyWithImpl<$Res>
    implements _$PartCueCopyWith<$Res> {
  __$PartCueCopyWithImpl(this._self, this._then);

  final _PartCue _self;
  final $Res Function(_PartCue) _then;

/// Create a copy of PartCue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? part = null,Object? action = null,Object? seq = null,Object? pose = freezed,Object? to = freezed,}) {
  return _then(_PartCue(
part: null == part ? _self.part : part // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as PartAction,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,pose: freezed == pose ? _self.pose : pose // ignore: cast_nullable_to_non_nullable
as String?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as CanvasPoint?,
  ));
}


}

/// @nodoc
mixin _$PlayerState {

 PlayerPhase get phase; Story? get story; String? get nodeId;/// Option being read aloud right now (glows on screen).
 int? get highlightedOption;/// Option just tapped (plays a short celebration before moving on).
 String? get selectedOptionId; List<PathStep> get path;/// First option kind picked at each choice node (kept across rewinds).
 Map<String, ChoiceKind> get firstPicks;/// Latest narration cue (picture part to move).
 PartCue? get cue; String? get errorMessage;
/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerStateCopyWith<PlayerState> get copyWith => _$PlayerStateCopyWithImpl<PlayerState>(this as PlayerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.story, story) || other.story == story)&&(identical(other.nodeId, nodeId) || other.nodeId == nodeId)&&(identical(other.highlightedOption, highlightedOption) || other.highlightedOption == highlightedOption)&&(identical(other.selectedOptionId, selectedOptionId) || other.selectedOptionId == selectedOptionId)&&const DeepCollectionEquality().equals(other.path, path)&&const DeepCollectionEquality().equals(other.firstPicks, firstPicks)&&(identical(other.cue, cue) || other.cue == cue)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,phase,story,nodeId,highlightedOption,selectedOptionId,const DeepCollectionEquality().hash(path),const DeepCollectionEquality().hash(firstPicks),cue,errorMessage);

@override
String toString() {
  return 'PlayerState(phase: $phase, story: $story, nodeId: $nodeId, highlightedOption: $highlightedOption, selectedOptionId: $selectedOptionId, path: $path, firstPicks: $firstPicks, cue: $cue, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $PlayerStateCopyWith<$Res>  {
  factory $PlayerStateCopyWith(PlayerState value, $Res Function(PlayerState) _then) = _$PlayerStateCopyWithImpl;
@useResult
$Res call({
 PlayerPhase phase, Story? story, String? nodeId, int? highlightedOption, String? selectedOptionId, List<PathStep> path, Map<String, ChoiceKind> firstPicks, PartCue? cue, String? errorMessage
});


$StoryCopyWith<$Res>? get story;$PartCueCopyWith<$Res>? get cue;

}
/// @nodoc
class _$PlayerStateCopyWithImpl<$Res>
    implements $PlayerStateCopyWith<$Res> {
  _$PlayerStateCopyWithImpl(this._self, this._then);

  final PlayerState _self;
  final $Res Function(PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? story = freezed,Object? nodeId = freezed,Object? highlightedOption = freezed,Object? selectedOptionId = freezed,Object? path = null,Object? firstPicks = null,Object? cue = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as PlayerPhase,story: freezed == story ? _self.story : story // ignore: cast_nullable_to_non_nullable
as Story?,nodeId: freezed == nodeId ? _self.nodeId : nodeId // ignore: cast_nullable_to_non_nullable
as String?,highlightedOption: freezed == highlightedOption ? _self.highlightedOption : highlightedOption // ignore: cast_nullable_to_non_nullable
as int?,selectedOptionId: freezed == selectedOptionId ? _self.selectedOptionId : selectedOptionId // ignore: cast_nullable_to_non_nullable
as String?,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as List<PathStep>,firstPicks: null == firstPicks ? _self.firstPicks : firstPicks // ignore: cast_nullable_to_non_nullable
as Map<String, ChoiceKind>,cue: freezed == cue ? _self.cue : cue // ignore: cast_nullable_to_non_nullable
as PartCue?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StoryCopyWith<$Res>? get story {
    if (_self.story == null) {
    return null;
  }

  return $StoryCopyWith<$Res>(_self.story!, (value) {
    return _then(_self.copyWith(story: value));
  });
}/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartCueCopyWith<$Res>? get cue {
    if (_self.cue == null) {
    return null;
  }

  return $PartCueCopyWith<$Res>(_self.cue!, (value) {
    return _then(_self.copyWith(cue: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayerState].
extension PlayerStatePatterns on PlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerState value)  $default,){
final _that = this;
switch (_that) {
case _PlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlayerPhase phase,  Story? story,  String? nodeId,  int? highlightedOption,  String? selectedOptionId,  List<PathStep> path,  Map<String, ChoiceKind> firstPicks,  PartCue? cue,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.phase,_that.story,_that.nodeId,_that.highlightedOption,_that.selectedOptionId,_that.path,_that.firstPicks,_that.cue,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlayerPhase phase,  Story? story,  String? nodeId,  int? highlightedOption,  String? selectedOptionId,  List<PathStep> path,  Map<String, ChoiceKind> firstPicks,  PartCue? cue,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _PlayerState():
return $default(_that.phase,_that.story,_that.nodeId,_that.highlightedOption,_that.selectedOptionId,_that.path,_that.firstPicks,_that.cue,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlayerPhase phase,  Story? story,  String? nodeId,  int? highlightedOption,  String? selectedOptionId,  List<PathStep> path,  Map<String, ChoiceKind> firstPicks,  PartCue? cue,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.phase,_that.story,_that.nodeId,_that.highlightedOption,_that.selectedOptionId,_that.path,_that.firstPicks,_that.cue,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerState extends PlayerState {
  const _PlayerState({this.phase = PlayerPhase.loading, this.story, this.nodeId, this.highlightedOption, this.selectedOptionId, final  List<PathStep> path = const <PathStep>[], final  Map<String, ChoiceKind> firstPicks = const <String, ChoiceKind>{}, this.cue, this.errorMessage}): _path = path,_firstPicks = firstPicks,super._();
  

@override@JsonKey() final  PlayerPhase phase;
@override final  Story? story;
@override final  String? nodeId;
/// Option being read aloud right now (glows on screen).
@override final  int? highlightedOption;
/// Option just tapped (plays a short celebration before moving on).
@override final  String? selectedOptionId;
 final  List<PathStep> _path;
@override@JsonKey() List<PathStep> get path {
  if (_path is EqualUnmodifiableListView) return _path;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_path);
}

/// First option kind picked at each choice node (kept across rewinds).
 final  Map<String, ChoiceKind> _firstPicks;
/// First option kind picked at each choice node (kept across rewinds).
@override@JsonKey() Map<String, ChoiceKind> get firstPicks {
  if (_firstPicks is EqualUnmodifiableMapView) return _firstPicks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_firstPicks);
}

/// Latest narration cue (picture part to move).
@override final  PartCue? cue;
@override final  String? errorMessage;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerStateCopyWith<_PlayerState> get copyWith => __$PlayerStateCopyWithImpl<_PlayerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.story, story) || other.story == story)&&(identical(other.nodeId, nodeId) || other.nodeId == nodeId)&&(identical(other.highlightedOption, highlightedOption) || other.highlightedOption == highlightedOption)&&(identical(other.selectedOptionId, selectedOptionId) || other.selectedOptionId == selectedOptionId)&&const DeepCollectionEquality().equals(other._path, _path)&&const DeepCollectionEquality().equals(other._firstPicks, _firstPicks)&&(identical(other.cue, cue) || other.cue == cue)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,phase,story,nodeId,highlightedOption,selectedOptionId,const DeepCollectionEquality().hash(_path),const DeepCollectionEquality().hash(_firstPicks),cue,errorMessage);

@override
String toString() {
  return 'PlayerState(phase: $phase, story: $story, nodeId: $nodeId, highlightedOption: $highlightedOption, selectedOptionId: $selectedOptionId, path: $path, firstPicks: $firstPicks, cue: $cue, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$PlayerStateCopyWith<$Res> implements $PlayerStateCopyWith<$Res> {
  factory _$PlayerStateCopyWith(_PlayerState value, $Res Function(_PlayerState) _then) = __$PlayerStateCopyWithImpl;
@override @useResult
$Res call({
 PlayerPhase phase, Story? story, String? nodeId, int? highlightedOption, String? selectedOptionId, List<PathStep> path, Map<String, ChoiceKind> firstPicks, PartCue? cue, String? errorMessage
});


@override $StoryCopyWith<$Res>? get story;@override $PartCueCopyWith<$Res>? get cue;

}
/// @nodoc
class __$PlayerStateCopyWithImpl<$Res>
    implements _$PlayerStateCopyWith<$Res> {
  __$PlayerStateCopyWithImpl(this._self, this._then);

  final _PlayerState _self;
  final $Res Function(_PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? story = freezed,Object? nodeId = freezed,Object? highlightedOption = freezed,Object? selectedOptionId = freezed,Object? path = null,Object? firstPicks = null,Object? cue = freezed,Object? errorMessage = freezed,}) {
  return _then(_PlayerState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as PlayerPhase,story: freezed == story ? _self.story : story // ignore: cast_nullable_to_non_nullable
as Story?,nodeId: freezed == nodeId ? _self.nodeId : nodeId // ignore: cast_nullable_to_non_nullable
as String?,highlightedOption: freezed == highlightedOption ? _self.highlightedOption : highlightedOption // ignore: cast_nullable_to_non_nullable
as int?,selectedOptionId: freezed == selectedOptionId ? _self.selectedOptionId : selectedOptionId // ignore: cast_nullable_to_non_nullable
as String?,path: null == path ? _self._path : path // ignore: cast_nullable_to_non_nullable
as List<PathStep>,firstPicks: null == firstPicks ? _self._firstPicks : firstPicks // ignore: cast_nullable_to_non_nullable
as Map<String, ChoiceKind>,cue: freezed == cue ? _self.cue : cue // ignore: cast_nullable_to_non_nullable
as PartCue?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StoryCopyWith<$Res>? get story {
    if (_self.story == null) {
    return null;
  }

  return $StoryCopyWith<$Res>(_self.story!, (value) {
    return _then(_self.copyWith(story: value));
  });
}/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartCueCopyWith<$Res>? get cue {
    if (_self.cue == null) {
    return null;
  }

  return $PartCueCopyWith<$Res>(_self.cue!, (value) {
    return _then(_self.copyWith(cue: value));
  });
}
}

// dart format on
