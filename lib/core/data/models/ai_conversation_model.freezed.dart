// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_conversation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AiConversationModel {

 String get id; String get companyId; String get userId; String? get title; String? get screenContext; bool get isArchived; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of AiConversationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiConversationModelCopyWith<AiConversationModel> get copyWith => _$AiConversationModelCopyWithImpl<AiConversationModel>(this as AiConversationModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiConversationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.screenContext, screenContext) || other.screenContext == screenContext)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,userId,title,screenContext,isArchived,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'AiConversationModel(id: $id, companyId: $companyId, userId: $userId, title: $title, screenContext: $screenContext, isArchived: $isArchived, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $AiConversationModelCopyWith<$Res>  {
  factory $AiConversationModelCopyWith(AiConversationModel value, $Res Function(AiConversationModel) _then) = _$AiConversationModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String userId, String? title, String? screenContext, bool isArchived, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$AiConversationModelCopyWithImpl<$Res>
    implements $AiConversationModelCopyWith<$Res> {
  _$AiConversationModelCopyWithImpl(this._self, this._then);

  final AiConversationModel _self;
  final $Res Function(AiConversationModel) _then;

/// Create a copy of AiConversationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? userId = null,Object? title = freezed,Object? screenContext = freezed,Object? isArchived = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,screenContext: freezed == screenContext ? _self.screenContext : screenContext // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiConversationModel].
extension AiConversationModelPatterns on AiConversationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiConversationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiConversationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiConversationModel value)  $default,){
final _that = this;
switch (_that) {
case _AiConversationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiConversationModel value)?  $default,){
final _that = this;
switch (_that) {
case _AiConversationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String userId,  String? title,  String? screenContext,  bool isArchived,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiConversationModel() when $default != null:
return $default(_that.id,_that.companyId,_that.userId,_that.title,_that.screenContext,_that.isArchived,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String userId,  String? title,  String? screenContext,  bool isArchived,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _AiConversationModel():
return $default(_that.id,_that.companyId,_that.userId,_that.title,_that.screenContext,_that.isArchived,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String userId,  String? title,  String? screenContext,  bool isArchived,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _AiConversationModel() when $default != null:
return $default(_that.id,_that.companyId,_that.userId,_that.title,_that.screenContext,_that.isArchived,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AiConversationModel implements AiConversationModel {
  const _AiConversationModel({required this.id, required this.companyId, required this.userId, this.title, this.screenContext, this.isArchived = false, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String userId;
@override final  String? title;
@override final  String? screenContext;
@override@JsonKey() final  bool isArchived;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of AiConversationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiConversationModelCopyWith<_AiConversationModel> get copyWith => __$AiConversationModelCopyWithImpl<_AiConversationModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiConversationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.screenContext, screenContext) || other.screenContext == screenContext)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,userId,title,screenContext,isArchived,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'AiConversationModel(id: $id, companyId: $companyId, userId: $userId, title: $title, screenContext: $screenContext, isArchived: $isArchived, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$AiConversationModelCopyWith<$Res> implements $AiConversationModelCopyWith<$Res> {
  factory _$AiConversationModelCopyWith(_AiConversationModel value, $Res Function(_AiConversationModel) _then) = __$AiConversationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String userId, String? title, String? screenContext, bool isArchived, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$AiConversationModelCopyWithImpl<$Res>
    implements _$AiConversationModelCopyWith<$Res> {
  __$AiConversationModelCopyWithImpl(this._self, this._then);

  final _AiConversationModel _self;
  final $Res Function(_AiConversationModel) _then;

/// Create a copy of AiConversationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? userId = null,Object? title = freezed,Object? screenContext = freezed,Object? isArchived = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_AiConversationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,screenContext: freezed == screenContext ? _self.screenContext : screenContext // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
