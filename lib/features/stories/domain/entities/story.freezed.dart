// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SceneHotspot {

/// Same names as layer kinds (`hero`, `lulu`), so cues can name it.
 String get kind; CanvasBox get box; Burst get burst;
/// Create a copy of SceneHotspot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneHotspotCopyWith<SceneHotspot> get copyWith => _$SceneHotspotCopyWithImpl<SceneHotspot>(this as SceneHotspot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneHotspot&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.box, box) || other.box == box)&&(identical(other.burst, burst) || other.burst == burst));
}


@override
int get hashCode => Object.hash(runtimeType,kind,box,burst);

@override
String toString() {
  return 'SceneHotspot(kind: $kind, box: $box, burst: $burst)';
}


}

/// @nodoc
abstract mixin class $SceneHotspotCopyWith<$Res>  {
  factory $SceneHotspotCopyWith(SceneHotspot value, $Res Function(SceneHotspot) _then) = _$SceneHotspotCopyWithImpl;
@useResult
$Res call({
 String kind, CanvasBox box, Burst burst
});




}
/// @nodoc
class _$SceneHotspotCopyWithImpl<$Res>
    implements $SceneHotspotCopyWith<$Res> {
  _$SceneHotspotCopyWithImpl(this._self, this._then);

  final SceneHotspot _self;
  final $Res Function(SceneHotspot) _then;

/// Create a copy of SceneHotspot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? box = null,Object? burst = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,box: null == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as CanvasBox,burst: null == burst ? _self.burst : burst // ignore: cast_nullable_to_non_nullable
as Burst,
  ));
}

}


/// Adds pattern-matching-related methods to [SceneHotspot].
extension SceneHotspotPatterns on SceneHotspot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SceneHotspot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SceneHotspot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SceneHotspot value)  $default,){
final _that = this;
switch (_that) {
case _SceneHotspot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SceneHotspot value)?  $default,){
final _that = this;
switch (_that) {
case _SceneHotspot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kind,  CanvasBox box,  Burst burst)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SceneHotspot() when $default != null:
return $default(_that.kind,_that.box,_that.burst);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kind,  CanvasBox box,  Burst burst)  $default,) {final _that = this;
switch (_that) {
case _SceneHotspot():
return $default(_that.kind,_that.box,_that.burst);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kind,  CanvasBox box,  Burst burst)?  $default,) {final _that = this;
switch (_that) {
case _SceneHotspot() when $default != null:
return $default(_that.kind,_that.box,_that.burst);case _:
  return null;

}
}

}

/// @nodoc


class _SceneHotspot implements SceneHotspot {
  const _SceneHotspot({required this.kind, required this.box, this.burst = Burst.sparkles});
  

/// Same names as layer kinds (`hero`, `lulu`), so cues can name it.
@override final  String kind;
@override final  CanvasBox box;
@override@JsonKey() final  Burst burst;

/// Create a copy of SceneHotspot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneHotspotCopyWith<_SceneHotspot> get copyWith => __$SceneHotspotCopyWithImpl<_SceneHotspot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SceneHotspot&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.box, box) || other.box == box)&&(identical(other.burst, burst) || other.burst == burst));
}


@override
int get hashCode => Object.hash(runtimeType,kind,box,burst);

@override
String toString() {
  return 'SceneHotspot(kind: $kind, box: $box, burst: $burst)';
}


}

/// @nodoc
abstract mixin class _$SceneHotspotCopyWith<$Res> implements $SceneHotspotCopyWith<$Res> {
  factory _$SceneHotspotCopyWith(_SceneHotspot value, $Res Function(_SceneHotspot) _then) = __$SceneHotspotCopyWithImpl;
@override @useResult
$Res call({
 String kind, CanvasBox box, Burst burst
});




}
/// @nodoc
class __$SceneHotspotCopyWithImpl<$Res>
    implements _$SceneHotspotCopyWith<$Res> {
  __$SceneHotspotCopyWithImpl(this._self, this._then);

  final _SceneHotspot _self;
  final $Res Function(_SceneHotspot) _then;

/// Create a copy of SceneHotspot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? box = null,Object? burst = null,}) {
  return _then(_SceneHotspot(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,box: null == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as CanvasBox,burst: null == burst ? _self.burst : burst // ignore: cast_nullable_to_non_nullable
as Burst,
  ));
}


}

/// @nodoc
mixin _$SceneLayer {

 String get asset;/// Same part with eyes closed, shown briefly to blink.
 String? get blinkAsset; String? get kind; CanvasPoint get pivot;/// Where a tap counts as touching this part.
 CanvasBox? get box;/// Where the picture sits when it is cropped to the part (cut AI
/// layers, `tool/layer_crop.py`); null = full-canvas picture. Shared
/// by all [poses].
 CanvasBox? get rect; PartIdle get idle;/// Reaction when tapped; null = not tappable.
 PartAction? get tap;/// Other pictures of the same part in the same spot (name → asset),
/// switched by `pose` cues. [asset] is [defaultPose].
 Map<String, String> get poses;
/// Create a copy of SceneLayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneLayerCopyWith<SceneLayer> get copyWith => _$SceneLayerCopyWithImpl<SceneLayer>(this as SceneLayer, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneLayer&&(identical(other.asset, asset) || other.asset == asset)&&(identical(other.blinkAsset, blinkAsset) || other.blinkAsset == blinkAsset)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.pivot, pivot) || other.pivot == pivot)&&(identical(other.box, box) || other.box == box)&&(identical(other.rect, rect) || other.rect == rect)&&(identical(other.idle, idle) || other.idle == idle)&&(identical(other.tap, tap) || other.tap == tap)&&const DeepCollectionEquality().equals(other.poses, poses));
}


@override
int get hashCode => Object.hash(runtimeType,asset,blinkAsset,kind,pivot,box,rect,idle,tap,const DeepCollectionEquality().hash(poses));

@override
String toString() {
  return 'SceneLayer(asset: $asset, blinkAsset: $blinkAsset, kind: $kind, pivot: $pivot, box: $box, rect: $rect, idle: $idle, tap: $tap, poses: $poses)';
}


}

/// @nodoc
abstract mixin class $SceneLayerCopyWith<$Res>  {
  factory $SceneLayerCopyWith(SceneLayer value, $Res Function(SceneLayer) _then) = _$SceneLayerCopyWithImpl;
@useResult
$Res call({
 String asset, String? blinkAsset, String? kind, CanvasPoint pivot, CanvasBox? box, CanvasBox? rect, PartIdle idle, PartAction? tap, Map<String, String> poses
});




}
/// @nodoc
class _$SceneLayerCopyWithImpl<$Res>
    implements $SceneLayerCopyWith<$Res> {
  _$SceneLayerCopyWithImpl(this._self, this._then);

  final SceneLayer _self;
  final $Res Function(SceneLayer) _then;

/// Create a copy of SceneLayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? asset = null,Object? blinkAsset = freezed,Object? kind = freezed,Object? pivot = null,Object? box = freezed,Object? rect = freezed,Object? idle = null,Object? tap = freezed,Object? poses = null,}) {
  return _then(_self.copyWith(
asset: null == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as String,blinkAsset: freezed == blinkAsset ? _self.blinkAsset : blinkAsset // ignore: cast_nullable_to_non_nullable
as String?,kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String?,pivot: null == pivot ? _self.pivot : pivot // ignore: cast_nullable_to_non_nullable
as CanvasPoint,box: freezed == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as CanvasBox?,rect: freezed == rect ? _self.rect : rect // ignore: cast_nullable_to_non_nullable
as CanvasBox?,idle: null == idle ? _self.idle : idle // ignore: cast_nullable_to_non_nullable
as PartIdle,tap: freezed == tap ? _self.tap : tap // ignore: cast_nullable_to_non_nullable
as PartAction?,poses: null == poses ? _self.poses : poses // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SceneLayer].
extension SceneLayerPatterns on SceneLayer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SceneLayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SceneLayer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SceneLayer value)  $default,){
final _that = this;
switch (_that) {
case _SceneLayer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SceneLayer value)?  $default,){
final _that = this;
switch (_that) {
case _SceneLayer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String asset,  String? blinkAsset,  String? kind,  CanvasPoint pivot,  CanvasBox? box,  CanvasBox? rect,  PartIdle idle,  PartAction? tap,  Map<String, String> poses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SceneLayer() when $default != null:
return $default(_that.asset,_that.blinkAsset,_that.kind,_that.pivot,_that.box,_that.rect,_that.idle,_that.tap,_that.poses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String asset,  String? blinkAsset,  String? kind,  CanvasPoint pivot,  CanvasBox? box,  CanvasBox? rect,  PartIdle idle,  PartAction? tap,  Map<String, String> poses)  $default,) {final _that = this;
switch (_that) {
case _SceneLayer():
return $default(_that.asset,_that.blinkAsset,_that.kind,_that.pivot,_that.box,_that.rect,_that.idle,_that.tap,_that.poses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String asset,  String? blinkAsset,  String? kind,  CanvasPoint pivot,  CanvasBox? box,  CanvasBox? rect,  PartIdle idle,  PartAction? tap,  Map<String, String> poses)?  $default,) {final _that = this;
switch (_that) {
case _SceneLayer() when $default != null:
return $default(_that.asset,_that.blinkAsset,_that.kind,_that.pivot,_that.box,_that.rect,_that.idle,_that.tap,_that.poses);case _:
  return null;

}
}

}

/// @nodoc


class _SceneLayer extends SceneLayer {
  const _SceneLayer({required this.asset, this.blinkAsset, this.kind, this.pivot = const (x: 0.5, y: 0.5), this.box, this.rect, this.idle = PartIdle.none, this.tap, final  Map<String, String> poses = const <String, String>{}}): _poses = poses,super._();
  

@override final  String asset;
/// Same part with eyes closed, shown briefly to blink.
@override final  String? blinkAsset;
@override final  String? kind;
@override@JsonKey() final  CanvasPoint pivot;
/// Where a tap counts as touching this part.
@override final  CanvasBox? box;
/// Where the picture sits when it is cropped to the part (cut AI
/// layers, `tool/layer_crop.py`); null = full-canvas picture. Shared
/// by all [poses].
@override final  CanvasBox? rect;
@override@JsonKey() final  PartIdle idle;
/// Reaction when tapped; null = not tappable.
@override final  PartAction? tap;
/// Other pictures of the same part in the same spot (name → asset),
/// switched by `pose` cues. [asset] is [defaultPose].
 final  Map<String, String> _poses;
/// Other pictures of the same part in the same spot (name → asset),
/// switched by `pose` cues. [asset] is [defaultPose].
@override@JsonKey() Map<String, String> get poses {
  if (_poses is EqualUnmodifiableMapView) return _poses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_poses);
}


/// Create a copy of SceneLayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneLayerCopyWith<_SceneLayer> get copyWith => __$SceneLayerCopyWithImpl<_SceneLayer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SceneLayer&&(identical(other.asset, asset) || other.asset == asset)&&(identical(other.blinkAsset, blinkAsset) || other.blinkAsset == blinkAsset)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.pivot, pivot) || other.pivot == pivot)&&(identical(other.box, box) || other.box == box)&&(identical(other.rect, rect) || other.rect == rect)&&(identical(other.idle, idle) || other.idle == idle)&&(identical(other.tap, tap) || other.tap == tap)&&const DeepCollectionEquality().equals(other._poses, _poses));
}


@override
int get hashCode => Object.hash(runtimeType,asset,blinkAsset,kind,pivot,box,rect,idle,tap,const DeepCollectionEquality().hash(_poses));

@override
String toString() {
  return 'SceneLayer(asset: $asset, blinkAsset: $blinkAsset, kind: $kind, pivot: $pivot, box: $box, rect: $rect, idle: $idle, tap: $tap, poses: $poses)';
}


}

/// @nodoc
abstract mixin class _$SceneLayerCopyWith<$Res> implements $SceneLayerCopyWith<$Res> {
  factory _$SceneLayerCopyWith(_SceneLayer value, $Res Function(_SceneLayer) _then) = __$SceneLayerCopyWithImpl;
@override @useResult
$Res call({
 String asset, String? blinkAsset, String? kind, CanvasPoint pivot, CanvasBox? box, CanvasBox? rect, PartIdle idle, PartAction? tap, Map<String, String> poses
});




}
/// @nodoc
class __$SceneLayerCopyWithImpl<$Res>
    implements _$SceneLayerCopyWith<$Res> {
  __$SceneLayerCopyWithImpl(this._self, this._then);

  final _SceneLayer _self;
  final $Res Function(_SceneLayer) _then;

/// Create a copy of SceneLayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? asset = null,Object? blinkAsset = freezed,Object? kind = freezed,Object? pivot = null,Object? box = freezed,Object? rect = freezed,Object? idle = null,Object? tap = freezed,Object? poses = null,}) {
  return _then(_SceneLayer(
asset: null == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as String,blinkAsset: freezed == blinkAsset ? _self.blinkAsset : blinkAsset // ignore: cast_nullable_to_non_nullable
as String?,kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String?,pivot: null == pivot ? _self.pivot : pivot // ignore: cast_nullable_to_non_nullable
as CanvasPoint,box: freezed == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as CanvasBox?,rect: freezed == rect ? _self.rect : rect // ignore: cast_nullable_to_non_nullable
as CanvasBox?,idle: null == idle ? _self.idle : idle // ignore: cast_nullable_to_non_nullable
as PartIdle,tap: freezed == tap ? _self.tap : tap // ignore: cast_nullable_to_non_nullable
as PartAction?,poses: null == poses ? _self._poses : poses // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

/// @nodoc
mixin _$StoryCue {

 String get word;/// A layer `kind` in the node's picture, e.g. `lulu`, `hero`, `clock`.
 String get part; PartAction get action;/// With [PartAction.pose]: the pose to switch to.
 String? get pose;/// With [PartAction.move]: where the part's pivot goes.
 CanvasPoint? get to;/// When [word] is said, as a fraction of its clip (measured from the
/// recording); null = guess from the word's place in the text.
 double? get at;
/// Create a copy of StoryCue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryCueCopyWith<StoryCue> get copyWith => _$StoryCueCopyWithImpl<StoryCue>(this as StoryCue, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryCue&&(identical(other.word, word) || other.word == word)&&(identical(other.part, part) || other.part == part)&&(identical(other.action, action) || other.action == action)&&(identical(other.pose, pose) || other.pose == pose)&&(identical(other.to, to) || other.to == to)&&(identical(other.at, at) || other.at == at));
}


@override
int get hashCode => Object.hash(runtimeType,word,part,action,pose,to,at);

@override
String toString() {
  return 'StoryCue(word: $word, part: $part, action: $action, pose: $pose, to: $to, at: $at)';
}


}

/// @nodoc
abstract mixin class $StoryCueCopyWith<$Res>  {
  factory $StoryCueCopyWith(StoryCue value, $Res Function(StoryCue) _then) = _$StoryCueCopyWithImpl;
@useResult
$Res call({
 String word, String part, PartAction action, String? pose, CanvasPoint? to, double? at
});




}
/// @nodoc
class _$StoryCueCopyWithImpl<$Res>
    implements $StoryCueCopyWith<$Res> {
  _$StoryCueCopyWithImpl(this._self, this._then);

  final StoryCue _self;
  final $Res Function(StoryCue) _then;

/// Create a copy of StoryCue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? word = null,Object? part = null,Object? action = null,Object? pose = freezed,Object? to = freezed,Object? at = freezed,}) {
  return _then(_self.copyWith(
word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,part: null == part ? _self.part : part // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as PartAction,pose: freezed == pose ? _self.pose : pose // ignore: cast_nullable_to_non_nullable
as String?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as CanvasPoint?,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryCue].
extension StoryCuePatterns on StoryCue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryCue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryCue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryCue value)  $default,){
final _that = this;
switch (_that) {
case _StoryCue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryCue value)?  $default,){
final _that = this;
switch (_that) {
case _StoryCue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String word,  String part,  PartAction action,  String? pose,  CanvasPoint? to,  double? at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryCue() when $default != null:
return $default(_that.word,_that.part,_that.action,_that.pose,_that.to,_that.at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String word,  String part,  PartAction action,  String? pose,  CanvasPoint? to,  double? at)  $default,) {final _that = this;
switch (_that) {
case _StoryCue():
return $default(_that.word,_that.part,_that.action,_that.pose,_that.to,_that.at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String word,  String part,  PartAction action,  String? pose,  CanvasPoint? to,  double? at)?  $default,) {final _that = this;
switch (_that) {
case _StoryCue() when $default != null:
return $default(_that.word,_that.part,_that.action,_that.pose,_that.to,_that.at);case _:
  return null;

}
}

}

/// @nodoc


class _StoryCue implements StoryCue {
  const _StoryCue({required this.word, required this.part, required this.action, this.pose, this.to, this.at});
  

@override final  String word;
/// A layer `kind` in the node's picture, e.g. `lulu`, `hero`, `clock`.
@override final  String part;
@override final  PartAction action;
/// With [PartAction.pose]: the pose to switch to.
@override final  String? pose;
/// With [PartAction.move]: where the part's pivot goes.
@override final  CanvasPoint? to;
/// When [word] is said, as a fraction of its clip (measured from the
/// recording); null = guess from the word's place in the text.
@override final  double? at;

/// Create a copy of StoryCue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryCueCopyWith<_StoryCue> get copyWith => __$StoryCueCopyWithImpl<_StoryCue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryCue&&(identical(other.word, word) || other.word == word)&&(identical(other.part, part) || other.part == part)&&(identical(other.action, action) || other.action == action)&&(identical(other.pose, pose) || other.pose == pose)&&(identical(other.to, to) || other.to == to)&&(identical(other.at, at) || other.at == at));
}


@override
int get hashCode => Object.hash(runtimeType,word,part,action,pose,to,at);

@override
String toString() {
  return 'StoryCue(word: $word, part: $part, action: $action, pose: $pose, to: $to, at: $at)';
}


}

/// @nodoc
abstract mixin class _$StoryCueCopyWith<$Res> implements $StoryCueCopyWith<$Res> {
  factory _$StoryCueCopyWith(_StoryCue value, $Res Function(_StoryCue) _then) = __$StoryCueCopyWithImpl;
@override @useResult
$Res call({
 String word, String part, PartAction action, String? pose, CanvasPoint? to, double? at
});




}
/// @nodoc
class __$StoryCueCopyWithImpl<$Res>
    implements _$StoryCueCopyWith<$Res> {
  __$StoryCueCopyWithImpl(this._self, this._then);

  final _StoryCue _self;
  final $Res Function(_StoryCue) _then;

/// Create a copy of StoryCue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? word = null,Object? part = null,Object? action = null,Object? pose = freezed,Object? to = freezed,Object? at = freezed,}) {
  return _then(_StoryCue(
word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,part: null == part ? _self.part : part // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as PartAction,pose: freezed == pose ? _self.pose : pose // ignore: cast_nullable_to_non_nullable
as String?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as CanvasPoint?,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
mixin _$ChoiceOption {

 String get id; ChoiceKind get kind; String get iconAsset; String get label; String get nextId;/// Math stories: `"c"` (the right answer is the number c) or `"near:c"`
/// (one more or one less). Resolved into [count] for each play.
 String? get answer;/// The number this card stands for in this play (math stories): the
/// card draws that many objects, `{n}` in the label says it.
 int? get count;
/// Create a copy of ChoiceOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChoiceOptionCopyWith<ChoiceOption> get copyWith => _$ChoiceOptionCopyWithImpl<ChoiceOption>(this as ChoiceOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChoiceOption&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.iconAsset, iconAsset) || other.iconAsset == iconAsset)&&(identical(other.label, label) || other.label == label)&&(identical(other.nextId, nextId) || other.nextId == nextId)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,iconAsset,label,nextId,answer,count);

@override
String toString() {
  return 'ChoiceOption(id: $id, kind: $kind, iconAsset: $iconAsset, label: $label, nextId: $nextId, answer: $answer, count: $count)';
}


}

/// @nodoc
abstract mixin class $ChoiceOptionCopyWith<$Res>  {
  factory $ChoiceOptionCopyWith(ChoiceOption value, $Res Function(ChoiceOption) _then) = _$ChoiceOptionCopyWithImpl;
@useResult
$Res call({
 String id, ChoiceKind kind, String iconAsset, String label, String nextId, String? answer, int? count
});




}
/// @nodoc
class _$ChoiceOptionCopyWithImpl<$Res>
    implements $ChoiceOptionCopyWith<$Res> {
  _$ChoiceOptionCopyWithImpl(this._self, this._then);

  final ChoiceOption _self;
  final $Res Function(ChoiceOption) _then;

/// Create a copy of ChoiceOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? iconAsset = null,Object? label = null,Object? nextId = null,Object? answer = freezed,Object? count = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ChoiceKind,iconAsset: null == iconAsset ? _self.iconAsset : iconAsset // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,nextId: null == nextId ? _self.nextId : nextId // ignore: cast_nullable_to_non_nullable
as String,answer: freezed == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChoiceOption].
extension ChoiceOptionPatterns on ChoiceOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChoiceOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChoiceOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChoiceOption value)  $default,){
final _that = this;
switch (_that) {
case _ChoiceOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChoiceOption value)?  $default,){
final _that = this;
switch (_that) {
case _ChoiceOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ChoiceKind kind,  String iconAsset,  String label,  String nextId,  String? answer,  int? count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChoiceOption() when $default != null:
return $default(_that.id,_that.kind,_that.iconAsset,_that.label,_that.nextId,_that.answer,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ChoiceKind kind,  String iconAsset,  String label,  String nextId,  String? answer,  int? count)  $default,) {final _that = this;
switch (_that) {
case _ChoiceOption():
return $default(_that.id,_that.kind,_that.iconAsset,_that.label,_that.nextId,_that.answer,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ChoiceKind kind,  String iconAsset,  String label,  String nextId,  String? answer,  int? count)?  $default,) {final _that = this;
switch (_that) {
case _ChoiceOption() when $default != null:
return $default(_that.id,_that.kind,_that.iconAsset,_that.label,_that.nextId,_that.answer,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _ChoiceOption implements ChoiceOption {
  const _ChoiceOption({required this.id, required this.kind, required this.iconAsset, required this.label, required this.nextId, this.answer, this.count});
  

@override final  String id;
@override final  ChoiceKind kind;
@override final  String iconAsset;
@override final  String label;
@override final  String nextId;
/// Math stories: `"c"` (the right answer is the number c) or `"near:c"`
/// (one more or one less). Resolved into [count] for each play.
@override final  String? answer;
/// The number this card stands for in this play (math stories): the
/// card draws that many objects, `{n}` in the label says it.
@override final  int? count;

/// Create a copy of ChoiceOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChoiceOptionCopyWith<_ChoiceOption> get copyWith => __$ChoiceOptionCopyWithImpl<_ChoiceOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChoiceOption&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.iconAsset, iconAsset) || other.iconAsset == iconAsset)&&(identical(other.label, label) || other.label == label)&&(identical(other.nextId, nextId) || other.nextId == nextId)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,iconAsset,label,nextId,answer,count);

@override
String toString() {
  return 'ChoiceOption(id: $id, kind: $kind, iconAsset: $iconAsset, label: $label, nextId: $nextId, answer: $answer, count: $count)';
}


}

/// @nodoc
abstract mixin class _$ChoiceOptionCopyWith<$Res> implements $ChoiceOptionCopyWith<$Res> {
  factory _$ChoiceOptionCopyWith(_ChoiceOption value, $Res Function(_ChoiceOption) _then) = __$ChoiceOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, ChoiceKind kind, String iconAsset, String label, String nextId, String? answer, int? count
});




}
/// @nodoc
class __$ChoiceOptionCopyWithImpl<$Res>
    implements _$ChoiceOptionCopyWith<$Res> {
  __$ChoiceOptionCopyWithImpl(this._self, this._then);

  final _ChoiceOption _self;
  final $Res Function(_ChoiceOption) _then;

/// Create a copy of ChoiceOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? iconAsset = null,Object? label = null,Object? nextId = null,Object? answer = freezed,Object? count = freezed,}) {
  return _then(_ChoiceOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ChoiceKind,iconAsset: null == iconAsset ? _self.iconAsset : iconAsset // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,nextId: null == nextId ? _self.nextId : nextId // ignore: cast_nullable_to_non_nullable
as String,answer: freezed == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$StoryNode {

 String get id; String get imageAsset; String get text; Ambient get ambient; AmbientOrigin? get ambientOrigin; List<StoryCue> get cues;/// Starting pose per part kind (default otherwise).
 Map<String, String> get poses;/// Math stories: counted objects shown (see [Counted]).
 Counted? get counted;
/// Create a copy of StoryNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryNodeCopyWith<StoryNode> get copyWith => _$StoryNodeCopyWithImpl<StoryNode>(this as StoryNode, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryNode&&(identical(other.id, id) || other.id == id)&&(identical(other.imageAsset, imageAsset) || other.imageAsset == imageAsset)&&(identical(other.text, text) || other.text == text)&&(identical(other.ambient, ambient) || other.ambient == ambient)&&(identical(other.ambientOrigin, ambientOrigin) || other.ambientOrigin == ambientOrigin)&&const DeepCollectionEquality().equals(other.cues, cues)&&const DeepCollectionEquality().equals(other.poses, poses)&&(identical(other.counted, counted) || other.counted == counted));
}


@override
int get hashCode => Object.hash(runtimeType,id,imageAsset,text,ambient,ambientOrigin,const DeepCollectionEquality().hash(cues),const DeepCollectionEquality().hash(poses),counted);

@override
String toString() {
  return 'StoryNode(id: $id, imageAsset: $imageAsset, text: $text, ambient: $ambient, ambientOrigin: $ambientOrigin, cues: $cues, poses: $poses, counted: $counted)';
}


}

/// @nodoc
abstract mixin class $StoryNodeCopyWith<$Res>  {
  factory $StoryNodeCopyWith(StoryNode value, $Res Function(StoryNode) _then) = _$StoryNodeCopyWithImpl;
@useResult
$Res call({
 String id, String imageAsset, String text, Ambient ambient, ({double x, double y})? ambientOrigin, List<StoryCue> cues, Map<String, String> poses, ({String field, String? wait})? counted
});




}
/// @nodoc
class _$StoryNodeCopyWithImpl<$Res>
    implements $StoryNodeCopyWith<$Res> {
  _$StoryNodeCopyWithImpl(this._self, this._then);

  final StoryNode _self;
  final $Res Function(StoryNode) _then;

/// Create a copy of StoryNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? imageAsset = null,Object? text = null,Object? ambient = null,Object? ambientOrigin = freezed,Object? cues = null,Object? poses = null,Object? counted = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imageAsset: null == imageAsset ? _self.imageAsset : imageAsset // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,ambient: null == ambient ? _self.ambient : ambient // ignore: cast_nullable_to_non_nullable
as Ambient,ambientOrigin: freezed == ambientOrigin ? _self.ambientOrigin : ambientOrigin // ignore: cast_nullable_to_non_nullable
as ({double x, double y})?,cues: null == cues ? _self.cues : cues // ignore: cast_nullable_to_non_nullable
as List<StoryCue>,poses: null == poses ? _self.poses : poses // ignore: cast_nullable_to_non_nullable
as Map<String, String>,counted: freezed == counted ? _self.counted : counted // ignore: cast_nullable_to_non_nullable
as ({String field, String? wait})?,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryNode].
extension StoryNodePatterns on StoryNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SceneNode value)?  scene,TResult Function( ChoiceNode value)?  choice,TResult Function( EndingNode value)?  ending,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SceneNode() when scene != null:
return scene(_that);case ChoiceNode() when choice != null:
return choice(_that);case EndingNode() when ending != null:
return ending(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SceneNode value)  scene,required TResult Function( ChoiceNode value)  choice,required TResult Function( EndingNode value)  ending,}){
final _that = this;
switch (_that) {
case SceneNode():
return scene(_that);case ChoiceNode():
return choice(_that);case EndingNode():
return ending(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SceneNode value)?  scene,TResult? Function( ChoiceNode value)?  choice,TResult? Function( EndingNode value)?  ending,}){
final _that = this;
switch (_that) {
case SceneNode() when scene != null:
return scene(_that);case ChoiceNode() when choice != null:
return choice(_that);case EndingNode() when ending != null:
return ending(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String imageAsset,  String text,  String nextId,  String? offerRewindTo,  Ambient ambient,  AmbientOrigin? ambientOrigin,  List<StoryCue> cues,  Map<String, String> poses,  Counted? counted)?  scene,TResult Function( String id,  String imageAsset,  String text,  List<ChoiceOption> options,  Ambient ambient,  AmbientOrigin? ambientOrigin,  List<StoryCue> cues,  Map<String, String> poses,  Counted? counted)?  choice,TResult Function( String id,  String imageAsset,  String text,  String stickerAsset,  Ambient ambient,  AmbientOrigin? ambientOrigin,  List<StoryCue> cues,  Map<String, String> poses,  Counted? counted)?  ending,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SceneNode() when scene != null:
return scene(_that.id,_that.imageAsset,_that.text,_that.nextId,_that.offerRewindTo,_that.ambient,_that.ambientOrigin,_that.cues,_that.poses,_that.counted);case ChoiceNode() when choice != null:
return choice(_that.id,_that.imageAsset,_that.text,_that.options,_that.ambient,_that.ambientOrigin,_that.cues,_that.poses,_that.counted);case EndingNode() when ending != null:
return ending(_that.id,_that.imageAsset,_that.text,_that.stickerAsset,_that.ambient,_that.ambientOrigin,_that.cues,_that.poses,_that.counted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String imageAsset,  String text,  String nextId,  String? offerRewindTo,  Ambient ambient,  AmbientOrigin? ambientOrigin,  List<StoryCue> cues,  Map<String, String> poses,  Counted? counted)  scene,required TResult Function( String id,  String imageAsset,  String text,  List<ChoiceOption> options,  Ambient ambient,  AmbientOrigin? ambientOrigin,  List<StoryCue> cues,  Map<String, String> poses,  Counted? counted)  choice,required TResult Function( String id,  String imageAsset,  String text,  String stickerAsset,  Ambient ambient,  AmbientOrigin? ambientOrigin,  List<StoryCue> cues,  Map<String, String> poses,  Counted? counted)  ending,}) {final _that = this;
switch (_that) {
case SceneNode():
return scene(_that.id,_that.imageAsset,_that.text,_that.nextId,_that.offerRewindTo,_that.ambient,_that.ambientOrigin,_that.cues,_that.poses,_that.counted);case ChoiceNode():
return choice(_that.id,_that.imageAsset,_that.text,_that.options,_that.ambient,_that.ambientOrigin,_that.cues,_that.poses,_that.counted);case EndingNode():
return ending(_that.id,_that.imageAsset,_that.text,_that.stickerAsset,_that.ambient,_that.ambientOrigin,_that.cues,_that.poses,_that.counted);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String imageAsset,  String text,  String nextId,  String? offerRewindTo,  Ambient ambient,  AmbientOrigin? ambientOrigin,  List<StoryCue> cues,  Map<String, String> poses,  Counted? counted)?  scene,TResult? Function( String id,  String imageAsset,  String text,  List<ChoiceOption> options,  Ambient ambient,  AmbientOrigin? ambientOrigin,  List<StoryCue> cues,  Map<String, String> poses,  Counted? counted)?  choice,TResult? Function( String id,  String imageAsset,  String text,  String stickerAsset,  Ambient ambient,  AmbientOrigin? ambientOrigin,  List<StoryCue> cues,  Map<String, String> poses,  Counted? counted)?  ending,}) {final _that = this;
switch (_that) {
case SceneNode() when scene != null:
return scene(_that.id,_that.imageAsset,_that.text,_that.nextId,_that.offerRewindTo,_that.ambient,_that.ambientOrigin,_that.cues,_that.poses,_that.counted);case ChoiceNode() when choice != null:
return choice(_that.id,_that.imageAsset,_that.text,_that.options,_that.ambient,_that.ambientOrigin,_that.cues,_that.poses,_that.counted);case EndingNode() when ending != null:
return ending(_that.id,_that.imageAsset,_that.text,_that.stickerAsset,_that.ambient,_that.ambientOrigin,_that.cues,_that.poses,_that.counted);case _:
  return null;

}
}

}

/// @nodoc


class SceneNode implements StoryNode {
  const SceneNode({required this.id, required this.imageAsset, required this.text, required this.nextId, this.offerRewindTo, this.ambient = Ambient.none, this.ambientOrigin, final  List<StoryCue> cues = const <StoryCue>[], final  Map<String, String> poses = const <String, String>{}, this.counted}): _cues = cues,_poses = poses;
  

@override final  String id;
@override final  String imageAsset;
@override final  String text;
 final  String nextId;
 final  String? offerRewindTo;
@override@JsonKey() final  Ambient ambient;
@override final  AmbientOrigin? ambientOrigin;
 final  List<StoryCue> _cues;
@override@JsonKey() List<StoryCue> get cues {
  if (_cues is EqualUnmodifiableListView) return _cues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cues);
}

/// Starting pose per part kind (default otherwise).
 final  Map<String, String> _poses;
/// Starting pose per part kind (default otherwise).
@override@JsonKey() Map<String, String> get poses {
  if (_poses is EqualUnmodifiableMapView) return _poses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_poses);
}

/// Math stories: counted objects shown (see [Counted]).
@override final  Counted? counted;

/// Create a copy of StoryNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneNodeCopyWith<SceneNode> get copyWith => _$SceneNodeCopyWithImpl<SceneNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneNode&&(identical(other.id, id) || other.id == id)&&(identical(other.imageAsset, imageAsset) || other.imageAsset == imageAsset)&&(identical(other.text, text) || other.text == text)&&(identical(other.nextId, nextId) || other.nextId == nextId)&&(identical(other.offerRewindTo, offerRewindTo) || other.offerRewindTo == offerRewindTo)&&(identical(other.ambient, ambient) || other.ambient == ambient)&&(identical(other.ambientOrigin, ambientOrigin) || other.ambientOrigin == ambientOrigin)&&const DeepCollectionEquality().equals(other._cues, _cues)&&const DeepCollectionEquality().equals(other._poses, _poses)&&(identical(other.counted, counted) || other.counted == counted));
}


@override
int get hashCode => Object.hash(runtimeType,id,imageAsset,text,nextId,offerRewindTo,ambient,ambientOrigin,const DeepCollectionEquality().hash(_cues),const DeepCollectionEquality().hash(_poses),counted);

@override
String toString() {
  return 'StoryNode.scene(id: $id, imageAsset: $imageAsset, text: $text, nextId: $nextId, offerRewindTo: $offerRewindTo, ambient: $ambient, ambientOrigin: $ambientOrigin, cues: $cues, poses: $poses, counted: $counted)';
}


}

/// @nodoc
abstract mixin class $SceneNodeCopyWith<$Res> implements $StoryNodeCopyWith<$Res> {
  factory $SceneNodeCopyWith(SceneNode value, $Res Function(SceneNode) _then) = _$SceneNodeCopyWithImpl;
@override @useResult
$Res call({
 String id, String imageAsset, String text, String nextId, String? offerRewindTo, Ambient ambient, AmbientOrigin? ambientOrigin, List<StoryCue> cues, Map<String, String> poses, Counted? counted
});




}
/// @nodoc
class _$SceneNodeCopyWithImpl<$Res>
    implements $SceneNodeCopyWith<$Res> {
  _$SceneNodeCopyWithImpl(this._self, this._then);

  final SceneNode _self;
  final $Res Function(SceneNode) _then;

/// Create a copy of StoryNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? imageAsset = null,Object? text = null,Object? nextId = null,Object? offerRewindTo = freezed,Object? ambient = null,Object? ambientOrigin = freezed,Object? cues = null,Object? poses = null,Object? counted = freezed,}) {
  return _then(SceneNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imageAsset: null == imageAsset ? _self.imageAsset : imageAsset // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,nextId: null == nextId ? _self.nextId : nextId // ignore: cast_nullable_to_non_nullable
as String,offerRewindTo: freezed == offerRewindTo ? _self.offerRewindTo : offerRewindTo // ignore: cast_nullable_to_non_nullable
as String?,ambient: null == ambient ? _self.ambient : ambient // ignore: cast_nullable_to_non_nullable
as Ambient,ambientOrigin: freezed == ambientOrigin ? _self.ambientOrigin : ambientOrigin // ignore: cast_nullable_to_non_nullable
as AmbientOrigin?,cues: null == cues ? _self._cues : cues // ignore: cast_nullable_to_non_nullable
as List<StoryCue>,poses: null == poses ? _self._poses : poses // ignore: cast_nullable_to_non_nullable
as Map<String, String>,counted: freezed == counted ? _self.counted : counted // ignore: cast_nullable_to_non_nullable
as Counted?,
  ));
}


}

/// @nodoc


class ChoiceNode implements StoryNode {
  const ChoiceNode({required this.id, required this.imageAsset, required this.text, required final  List<ChoiceOption> options, this.ambient = Ambient.none, this.ambientOrigin, final  List<StoryCue> cues = const <StoryCue>[], final  Map<String, String> poses = const <String, String>{}, this.counted}): _options = options,_cues = cues,_poses = poses;
  

@override final  String id;
@override final  String imageAsset;
@override final  String text;
 final  List<ChoiceOption> _options;
 List<ChoiceOption> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

@override@JsonKey() final  Ambient ambient;
@override final  AmbientOrigin? ambientOrigin;
 final  List<StoryCue> _cues;
@override@JsonKey() List<StoryCue> get cues {
  if (_cues is EqualUnmodifiableListView) return _cues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cues);
}

/// Starting pose per part kind (default otherwise).
 final  Map<String, String> _poses;
/// Starting pose per part kind (default otherwise).
@override@JsonKey() Map<String, String> get poses {
  if (_poses is EqualUnmodifiableMapView) return _poses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_poses);
}

/// Math stories: counted objects shown (see [Counted]).
@override final  Counted? counted;

/// Create a copy of StoryNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChoiceNodeCopyWith<ChoiceNode> get copyWith => _$ChoiceNodeCopyWithImpl<ChoiceNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChoiceNode&&(identical(other.id, id) || other.id == id)&&(identical(other.imageAsset, imageAsset) || other.imageAsset == imageAsset)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.ambient, ambient) || other.ambient == ambient)&&(identical(other.ambientOrigin, ambientOrigin) || other.ambientOrigin == ambientOrigin)&&const DeepCollectionEquality().equals(other._cues, _cues)&&const DeepCollectionEquality().equals(other._poses, _poses)&&(identical(other.counted, counted) || other.counted == counted));
}


@override
int get hashCode => Object.hash(runtimeType,id,imageAsset,text,const DeepCollectionEquality().hash(_options),ambient,ambientOrigin,const DeepCollectionEquality().hash(_cues),const DeepCollectionEquality().hash(_poses),counted);

@override
String toString() {
  return 'StoryNode.choice(id: $id, imageAsset: $imageAsset, text: $text, options: $options, ambient: $ambient, ambientOrigin: $ambientOrigin, cues: $cues, poses: $poses, counted: $counted)';
}


}

/// @nodoc
abstract mixin class $ChoiceNodeCopyWith<$Res> implements $StoryNodeCopyWith<$Res> {
  factory $ChoiceNodeCopyWith(ChoiceNode value, $Res Function(ChoiceNode) _then) = _$ChoiceNodeCopyWithImpl;
@override @useResult
$Res call({
 String id, String imageAsset, String text, List<ChoiceOption> options, Ambient ambient, AmbientOrigin? ambientOrigin, List<StoryCue> cues, Map<String, String> poses, Counted? counted
});




}
/// @nodoc
class _$ChoiceNodeCopyWithImpl<$Res>
    implements $ChoiceNodeCopyWith<$Res> {
  _$ChoiceNodeCopyWithImpl(this._self, this._then);

  final ChoiceNode _self;
  final $Res Function(ChoiceNode) _then;

/// Create a copy of StoryNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? imageAsset = null,Object? text = null,Object? options = null,Object? ambient = null,Object? ambientOrigin = freezed,Object? cues = null,Object? poses = null,Object? counted = freezed,}) {
  return _then(ChoiceNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imageAsset: null == imageAsset ? _self.imageAsset : imageAsset // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<ChoiceOption>,ambient: null == ambient ? _self.ambient : ambient // ignore: cast_nullable_to_non_nullable
as Ambient,ambientOrigin: freezed == ambientOrigin ? _self.ambientOrigin : ambientOrigin // ignore: cast_nullable_to_non_nullable
as AmbientOrigin?,cues: null == cues ? _self._cues : cues // ignore: cast_nullable_to_non_nullable
as List<StoryCue>,poses: null == poses ? _self._poses : poses // ignore: cast_nullable_to_non_nullable
as Map<String, String>,counted: freezed == counted ? _self.counted : counted // ignore: cast_nullable_to_non_nullable
as Counted?,
  ));
}


}

/// @nodoc


class EndingNode implements StoryNode {
  const EndingNode({required this.id, required this.imageAsset, required this.text, required this.stickerAsset, this.ambient = Ambient.none, this.ambientOrigin, final  List<StoryCue> cues = const <StoryCue>[], final  Map<String, String> poses = const <String, String>{}, this.counted}): _cues = cues,_poses = poses;
  

@override final  String id;
@override final  String imageAsset;
@override final  String text;
 final  String stickerAsset;
@override@JsonKey() final  Ambient ambient;
@override final  AmbientOrigin? ambientOrigin;
 final  List<StoryCue> _cues;
@override@JsonKey() List<StoryCue> get cues {
  if (_cues is EqualUnmodifiableListView) return _cues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cues);
}

/// Starting pose per part kind (default otherwise).
 final  Map<String, String> _poses;
/// Starting pose per part kind (default otherwise).
@override@JsonKey() Map<String, String> get poses {
  if (_poses is EqualUnmodifiableMapView) return _poses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_poses);
}

/// Math stories: counted objects shown (see [Counted]).
@override final  Counted? counted;

/// Create a copy of StoryNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EndingNodeCopyWith<EndingNode> get copyWith => _$EndingNodeCopyWithImpl<EndingNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EndingNode&&(identical(other.id, id) || other.id == id)&&(identical(other.imageAsset, imageAsset) || other.imageAsset == imageAsset)&&(identical(other.text, text) || other.text == text)&&(identical(other.stickerAsset, stickerAsset) || other.stickerAsset == stickerAsset)&&(identical(other.ambient, ambient) || other.ambient == ambient)&&(identical(other.ambientOrigin, ambientOrigin) || other.ambientOrigin == ambientOrigin)&&const DeepCollectionEquality().equals(other._cues, _cues)&&const DeepCollectionEquality().equals(other._poses, _poses)&&(identical(other.counted, counted) || other.counted == counted));
}


@override
int get hashCode => Object.hash(runtimeType,id,imageAsset,text,stickerAsset,ambient,ambientOrigin,const DeepCollectionEquality().hash(_cues),const DeepCollectionEquality().hash(_poses),counted);

@override
String toString() {
  return 'StoryNode.ending(id: $id, imageAsset: $imageAsset, text: $text, stickerAsset: $stickerAsset, ambient: $ambient, ambientOrigin: $ambientOrigin, cues: $cues, poses: $poses, counted: $counted)';
}


}

/// @nodoc
abstract mixin class $EndingNodeCopyWith<$Res> implements $StoryNodeCopyWith<$Res> {
  factory $EndingNodeCopyWith(EndingNode value, $Res Function(EndingNode) _then) = _$EndingNodeCopyWithImpl;
@override @useResult
$Res call({
 String id, String imageAsset, String text, String stickerAsset, Ambient ambient, AmbientOrigin? ambientOrigin, List<StoryCue> cues, Map<String, String> poses, Counted? counted
});




}
/// @nodoc
class _$EndingNodeCopyWithImpl<$Res>
    implements $EndingNodeCopyWith<$Res> {
  _$EndingNodeCopyWithImpl(this._self, this._then);

  final EndingNode _self;
  final $Res Function(EndingNode) _then;

/// Create a copy of StoryNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? imageAsset = null,Object? text = null,Object? stickerAsset = null,Object? ambient = null,Object? ambientOrigin = freezed,Object? cues = null,Object? poses = null,Object? counted = freezed,}) {
  return _then(EndingNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imageAsset: null == imageAsset ? _self.imageAsset : imageAsset // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,stickerAsset: null == stickerAsset ? _self.stickerAsset : stickerAsset // ignore: cast_nullable_to_non_nullable
as String,ambient: null == ambient ? _self.ambient : ambient // ignore: cast_nullable_to_non_nullable
as Ambient,ambientOrigin: freezed == ambientOrigin ? _self.ambientOrigin : ambientOrigin // ignore: cast_nullable_to_non_nullable
as AmbientOrigin?,cues: null == cues ? _self._cues : cues // ignore: cast_nullable_to_non_nullable
as List<StoryCue>,poses: null == poses ? _self._poses : poses // ignore: cast_nullable_to_non_nullable
as Map<String, String>,counted: freezed == counted ? _self.counted : counted // ignore: cast_nullable_to_non_nullable
as Counted?,
  ));
}


}

/// @nodoc
mixin _$Story {

 String get id; String get theme; StorySection get section; AppLanguage get language; StoryHero get hero; String get title; String get coverAsset; String get startId; Map<String, StoryNode> get nodes; String get audioDir;/// Layered pictures keyed by node `imageAsset`. Pictures not in here
/// are drawn flat.
 Map<String, List<SceneLayer>> get layers;/// Tappable areas of flat pictures, keyed by node `imageAsset`.
 Map<String, List<SceneHotspot>> get hotspots;/// Math stories: numbers drawn per play (see `docs/math.md`).
 MathSpec? get math;/// This play's numbers (empty until [withNumbers]).
 Map<String, int> get values;
/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryCopyWith<Story> get copyWith => _$StoryCopyWithImpl<Story>(this as Story, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Story&&(identical(other.id, id) || other.id == id)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.section, section) || other.section == section)&&(identical(other.language, language) || other.language == language)&&(identical(other.hero, hero) || other.hero == hero)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverAsset, coverAsset) || other.coverAsset == coverAsset)&&(identical(other.startId, startId) || other.startId == startId)&&const DeepCollectionEquality().equals(other.nodes, nodes)&&(identical(other.audioDir, audioDir) || other.audioDir == audioDir)&&const DeepCollectionEquality().equals(other.layers, layers)&&const DeepCollectionEquality().equals(other.hotspots, hotspots)&&(identical(other.math, math) || other.math == math)&&const DeepCollectionEquality().equals(other.values, values));
}


@override
int get hashCode => Object.hash(runtimeType,id,theme,section,language,hero,title,coverAsset,startId,const DeepCollectionEquality().hash(nodes),audioDir,const DeepCollectionEquality().hash(layers),const DeepCollectionEquality().hash(hotspots),math,const DeepCollectionEquality().hash(values));

@override
String toString() {
  return 'Story(id: $id, theme: $theme, section: $section, language: $language, hero: $hero, title: $title, coverAsset: $coverAsset, startId: $startId, nodes: $nodes, audioDir: $audioDir, layers: $layers, hotspots: $hotspots, math: $math, values: $values)';
}


}

/// @nodoc
abstract mixin class $StoryCopyWith<$Res>  {
  factory $StoryCopyWith(Story value, $Res Function(Story) _then) = _$StoryCopyWithImpl;
@useResult
$Res call({
 String id, String theme, StorySection section, AppLanguage language, StoryHero hero, String title, String coverAsset, String startId, Map<String, StoryNode> nodes, String audioDir, Map<String, List<SceneLayer>> layers, Map<String, List<SceneHotspot>> hotspots, MathSpec? math, Map<String, int> values
});




}
/// @nodoc
class _$StoryCopyWithImpl<$Res>
    implements $StoryCopyWith<$Res> {
  _$StoryCopyWithImpl(this._self, this._then);

  final Story _self;
  final $Res Function(Story) _then;

/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? theme = null,Object? section = null,Object? language = null,Object? hero = null,Object? title = null,Object? coverAsset = null,Object? startId = null,Object? nodes = null,Object? audioDir = null,Object? layers = null,Object? hotspots = null,Object? math = freezed,Object? values = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as StorySection,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as AppLanguage,hero: null == hero ? _self.hero : hero // ignore: cast_nullable_to_non_nullable
as StoryHero,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverAsset: null == coverAsset ? _self.coverAsset : coverAsset // ignore: cast_nullable_to_non_nullable
as String,startId: null == startId ? _self.startId : startId // ignore: cast_nullable_to_non_nullable
as String,nodes: null == nodes ? _self.nodes : nodes // ignore: cast_nullable_to_non_nullable
as Map<String, StoryNode>,audioDir: null == audioDir ? _self.audioDir : audioDir // ignore: cast_nullable_to_non_nullable
as String,layers: null == layers ? _self.layers : layers // ignore: cast_nullable_to_non_nullable
as Map<String, List<SceneLayer>>,hotspots: null == hotspots ? _self.hotspots : hotspots // ignore: cast_nullable_to_non_nullable
as Map<String, List<SceneHotspot>>,math: freezed == math ? _self.math : math // ignore: cast_nullable_to_non_nullable
as MathSpec?,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [Story].
extension StoryPatterns on Story {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Story value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Story() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Story value)  $default,){
final _that = this;
switch (_that) {
case _Story():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Story value)?  $default,){
final _that = this;
switch (_that) {
case _Story() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String theme,  StorySection section,  AppLanguage language,  StoryHero hero,  String title,  String coverAsset,  String startId,  Map<String, StoryNode> nodes,  String audioDir,  Map<String, List<SceneLayer>> layers,  Map<String, List<SceneHotspot>> hotspots,  MathSpec? math,  Map<String, int> values)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Story() when $default != null:
return $default(_that.id,_that.theme,_that.section,_that.language,_that.hero,_that.title,_that.coverAsset,_that.startId,_that.nodes,_that.audioDir,_that.layers,_that.hotspots,_that.math,_that.values);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String theme,  StorySection section,  AppLanguage language,  StoryHero hero,  String title,  String coverAsset,  String startId,  Map<String, StoryNode> nodes,  String audioDir,  Map<String, List<SceneLayer>> layers,  Map<String, List<SceneHotspot>> hotspots,  MathSpec? math,  Map<String, int> values)  $default,) {final _that = this;
switch (_that) {
case _Story():
return $default(_that.id,_that.theme,_that.section,_that.language,_that.hero,_that.title,_that.coverAsset,_that.startId,_that.nodes,_that.audioDir,_that.layers,_that.hotspots,_that.math,_that.values);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String theme,  StorySection section,  AppLanguage language,  StoryHero hero,  String title,  String coverAsset,  String startId,  Map<String, StoryNode> nodes,  String audioDir,  Map<String, List<SceneLayer>> layers,  Map<String, List<SceneHotspot>> hotspots,  MathSpec? math,  Map<String, int> values)?  $default,) {final _that = this;
switch (_that) {
case _Story() when $default != null:
return $default(_that.id,_that.theme,_that.section,_that.language,_that.hero,_that.title,_that.coverAsset,_that.startId,_that.nodes,_that.audioDir,_that.layers,_that.hotspots,_that.math,_that.values);case _:
  return null;

}
}

}

/// @nodoc


class _Story extends Story {
  const _Story({required this.id, required this.theme, this.section = StorySection.behavior, required this.language, required this.hero, required this.title, required this.coverAsset, required this.startId, required final  Map<String, StoryNode> nodes, required this.audioDir, final  Map<String, List<SceneLayer>> layers = const <String, List<SceneLayer>>{}, final  Map<String, List<SceneHotspot>> hotspots = const <String, List<SceneHotspot>>{}, this.math, final  Map<String, int> values = const <String, int>{}}): _nodes = nodes,_layers = layers,_hotspots = hotspots,_values = values,super._();
  

@override final  String id;
@override final  String theme;
@override@JsonKey() final  StorySection section;
@override final  AppLanguage language;
@override final  StoryHero hero;
@override final  String title;
@override final  String coverAsset;
@override final  String startId;
 final  Map<String, StoryNode> _nodes;
@override Map<String, StoryNode> get nodes {
  if (_nodes is EqualUnmodifiableMapView) return _nodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_nodes);
}

@override final  String audioDir;
/// Layered pictures keyed by node `imageAsset`. Pictures not in here
/// are drawn flat.
 final  Map<String, List<SceneLayer>> _layers;
/// Layered pictures keyed by node `imageAsset`. Pictures not in here
/// are drawn flat.
@override@JsonKey() Map<String, List<SceneLayer>> get layers {
  if (_layers is EqualUnmodifiableMapView) return _layers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_layers);
}

/// Tappable areas of flat pictures, keyed by node `imageAsset`.
 final  Map<String, List<SceneHotspot>> _hotspots;
/// Tappable areas of flat pictures, keyed by node `imageAsset`.
@override@JsonKey() Map<String, List<SceneHotspot>> get hotspots {
  if (_hotspots is EqualUnmodifiableMapView) return _hotspots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_hotspots);
}

/// Math stories: numbers drawn per play (see `docs/math.md`).
@override final  MathSpec? math;
/// This play's numbers (empty until [withNumbers]).
 final  Map<String, int> _values;
/// This play's numbers (empty until [withNumbers]).
@override@JsonKey() Map<String, int> get values {
  if (_values is EqualUnmodifiableMapView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_values);
}


/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryCopyWith<_Story> get copyWith => __$StoryCopyWithImpl<_Story>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Story&&(identical(other.id, id) || other.id == id)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.section, section) || other.section == section)&&(identical(other.language, language) || other.language == language)&&(identical(other.hero, hero) || other.hero == hero)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverAsset, coverAsset) || other.coverAsset == coverAsset)&&(identical(other.startId, startId) || other.startId == startId)&&const DeepCollectionEquality().equals(other._nodes, _nodes)&&(identical(other.audioDir, audioDir) || other.audioDir == audioDir)&&const DeepCollectionEquality().equals(other._layers, _layers)&&const DeepCollectionEquality().equals(other._hotspots, _hotspots)&&(identical(other.math, math) || other.math == math)&&const DeepCollectionEquality().equals(other._values, _values));
}


@override
int get hashCode => Object.hash(runtimeType,id,theme,section,language,hero,title,coverAsset,startId,const DeepCollectionEquality().hash(_nodes),audioDir,const DeepCollectionEquality().hash(_layers),const DeepCollectionEquality().hash(_hotspots),math,const DeepCollectionEquality().hash(_values));

@override
String toString() {
  return 'Story(id: $id, theme: $theme, section: $section, language: $language, hero: $hero, title: $title, coverAsset: $coverAsset, startId: $startId, nodes: $nodes, audioDir: $audioDir, layers: $layers, hotspots: $hotspots, math: $math, values: $values)';
}


}

/// @nodoc
abstract mixin class _$StoryCopyWith<$Res> implements $StoryCopyWith<$Res> {
  factory _$StoryCopyWith(_Story value, $Res Function(_Story) _then) = __$StoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String theme, StorySection section, AppLanguage language, StoryHero hero, String title, String coverAsset, String startId, Map<String, StoryNode> nodes, String audioDir, Map<String, List<SceneLayer>> layers, Map<String, List<SceneHotspot>> hotspots, MathSpec? math, Map<String, int> values
});




}
/// @nodoc
class __$StoryCopyWithImpl<$Res>
    implements _$StoryCopyWith<$Res> {
  __$StoryCopyWithImpl(this._self, this._then);

  final _Story _self;
  final $Res Function(_Story) _then;

/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? theme = null,Object? section = null,Object? language = null,Object? hero = null,Object? title = null,Object? coverAsset = null,Object? startId = null,Object? nodes = null,Object? audioDir = null,Object? layers = null,Object? hotspots = null,Object? math = freezed,Object? values = null,}) {
  return _then(_Story(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as StorySection,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as AppLanguage,hero: null == hero ? _self.hero : hero // ignore: cast_nullable_to_non_nullable
as StoryHero,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverAsset: null == coverAsset ? _self.coverAsset : coverAsset // ignore: cast_nullable_to_non_nullable
as String,startId: null == startId ? _self.startId : startId // ignore: cast_nullable_to_non_nullable
as String,nodes: null == nodes ? _self._nodes : nodes // ignore: cast_nullable_to_non_nullable
as Map<String, StoryNode>,audioDir: null == audioDir ? _self.audioDir : audioDir // ignore: cast_nullable_to_non_nullable
as String,layers: null == layers ? _self._layers : layers // ignore: cast_nullable_to_non_nullable
as Map<String, List<SceneLayer>>,hotspots: null == hotspots ? _self._hotspots : hotspots // ignore: cast_nullable_to_non_nullable
as Map<String, List<SceneHotspot>>,math: freezed == math ? _self.math : math // ignore: cast_nullable_to_non_nullable
as MathSpec?,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
