// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_undo_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AiUndoLogModel {

 String get id; String get companyId; String get conversationId; String get messageId; String get toolCallId; String get operationType; String get entityType; String get entityId; String? get snapshotBefore; String? get snapshotAfter; bool get isUndone; DateTime? get undoneAt; DateTime get expiresAt; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of AiUndoLogModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiUndoLogModelCopyWith<AiUndoLogModel> get copyWith => _$AiUndoLogModelCopyWithImpl<AiUndoLogModel>(this as AiUndoLogModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiUndoLogModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.toolCallId, toolCallId) || other.toolCallId == toolCallId)&&(identical(other.operationType, operationType) || other.operationType == operationType)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.snapshotBefore, snapshotBefore) || other.snapshotBefore == snapshotBefore)&&(identical(other.snapshotAfter, snapshotAfter) || other.snapshotAfter == snapshotAfter)&&(identical(other.isUndone, isUndone) || other.isUndone == isUndone)&&(identical(other.undoneAt, undoneAt) || other.undoneAt == undoneAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,conversationId,messageId,toolCallId,operationType,entityType,entityId,snapshotBefore,snapshotAfter,isUndone,undoneAt,expiresAt,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'AiUndoLogModel(id: $id, companyId: $companyId, conversationId: $conversationId, messageId: $messageId, toolCallId: $toolCallId, operationType: $operationType, entityType: $entityType, entityId: $entityId, snapshotBefore: $snapshotBefore, snapshotAfter: $snapshotAfter, isUndone: $isUndone, undoneAt: $undoneAt, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $AiUndoLogModelCopyWith<$Res>  {
  factory $AiUndoLogModelCopyWith(AiUndoLogModel value, $Res Function(AiUndoLogModel) _then) = _$AiUndoLogModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String conversationId, String messageId, String toolCallId, String operationType, String entityType, String entityId, String? snapshotBefore, String? snapshotAfter, bool isUndone, DateTime? undoneAt, DateTime expiresAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$AiUndoLogModelCopyWithImpl<$Res>
    implements $AiUndoLogModelCopyWith<$Res> {
  _$AiUndoLogModelCopyWithImpl(this._self, this._then);

  final AiUndoLogModel _self;
  final $Res Function(AiUndoLogModel) _then;

/// Create a copy of AiUndoLogModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? conversationId = null,Object? messageId = null,Object? toolCallId = null,Object? operationType = null,Object? entityType = null,Object? entityId = null,Object? snapshotBefore = freezed,Object? snapshotAfter = freezed,Object? isUndone = null,Object? undoneAt = freezed,Object? expiresAt = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,toolCallId: null == toolCallId ? _self.toolCallId : toolCallId // ignore: cast_nullable_to_non_nullable
as String,operationType: null == operationType ? _self.operationType : operationType // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,snapshotBefore: freezed == snapshotBefore ? _self.snapshotBefore : snapshotBefore // ignore: cast_nullable_to_non_nullable
as String?,snapshotAfter: freezed == snapshotAfter ? _self.snapshotAfter : snapshotAfter // ignore: cast_nullable_to_non_nullable
as String?,isUndone: null == isUndone ? _self.isUndone : isUndone // ignore: cast_nullable_to_non_nullable
as bool,undoneAt: freezed == undoneAt ? _self.undoneAt : undoneAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiUndoLogModel].
extension AiUndoLogModelPatterns on AiUndoLogModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiUndoLogModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiUndoLogModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiUndoLogModel value)  $default,){
final _that = this;
switch (_that) {
case _AiUndoLogModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiUndoLogModel value)?  $default,){
final _that = this;
switch (_that) {
case _AiUndoLogModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String conversationId,  String messageId,  String toolCallId,  String operationType,  String entityType,  String entityId,  String? snapshotBefore,  String? snapshotAfter,  bool isUndone,  DateTime? undoneAt,  DateTime expiresAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiUndoLogModel() when $default != null:
return $default(_that.id,_that.companyId,_that.conversationId,_that.messageId,_that.toolCallId,_that.operationType,_that.entityType,_that.entityId,_that.snapshotBefore,_that.snapshotAfter,_that.isUndone,_that.undoneAt,_that.expiresAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String conversationId,  String messageId,  String toolCallId,  String operationType,  String entityType,  String entityId,  String? snapshotBefore,  String? snapshotAfter,  bool isUndone,  DateTime? undoneAt,  DateTime expiresAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _AiUndoLogModel():
return $default(_that.id,_that.companyId,_that.conversationId,_that.messageId,_that.toolCallId,_that.operationType,_that.entityType,_that.entityId,_that.snapshotBefore,_that.snapshotAfter,_that.isUndone,_that.undoneAt,_that.expiresAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String conversationId,  String messageId,  String toolCallId,  String operationType,  String entityType,  String entityId,  String? snapshotBefore,  String? snapshotAfter,  bool isUndone,  DateTime? undoneAt,  DateTime expiresAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _AiUndoLogModel() when $default != null:
return $default(_that.id,_that.companyId,_that.conversationId,_that.messageId,_that.toolCallId,_that.operationType,_that.entityType,_that.entityId,_that.snapshotBefore,_that.snapshotAfter,_that.isUndone,_that.undoneAt,_that.expiresAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AiUndoLogModel implements AiUndoLogModel {
  const _AiUndoLogModel({required this.id, required this.companyId, required this.conversationId, required this.messageId, required this.toolCallId, required this.operationType, required this.entityType, required this.entityId, this.snapshotBefore, this.snapshotAfter, this.isUndone = false, this.undoneAt, required this.expiresAt, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String conversationId;
@override final  String messageId;
@override final  String toolCallId;
@override final  String operationType;
@override final  String entityType;
@override final  String entityId;
@override final  String? snapshotBefore;
@override final  String? snapshotAfter;
@override@JsonKey() final  bool isUndone;
@override final  DateTime? undoneAt;
@override final  DateTime expiresAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of AiUndoLogModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiUndoLogModelCopyWith<_AiUndoLogModel> get copyWith => __$AiUndoLogModelCopyWithImpl<_AiUndoLogModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiUndoLogModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.toolCallId, toolCallId) || other.toolCallId == toolCallId)&&(identical(other.operationType, operationType) || other.operationType == operationType)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.snapshotBefore, snapshotBefore) || other.snapshotBefore == snapshotBefore)&&(identical(other.snapshotAfter, snapshotAfter) || other.snapshotAfter == snapshotAfter)&&(identical(other.isUndone, isUndone) || other.isUndone == isUndone)&&(identical(other.undoneAt, undoneAt) || other.undoneAt == undoneAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,conversationId,messageId,toolCallId,operationType,entityType,entityId,snapshotBefore,snapshotAfter,isUndone,undoneAt,expiresAt,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'AiUndoLogModel(id: $id, companyId: $companyId, conversationId: $conversationId, messageId: $messageId, toolCallId: $toolCallId, operationType: $operationType, entityType: $entityType, entityId: $entityId, snapshotBefore: $snapshotBefore, snapshotAfter: $snapshotAfter, isUndone: $isUndone, undoneAt: $undoneAt, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$AiUndoLogModelCopyWith<$Res> implements $AiUndoLogModelCopyWith<$Res> {
  factory _$AiUndoLogModelCopyWith(_AiUndoLogModel value, $Res Function(_AiUndoLogModel) _then) = __$AiUndoLogModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String conversationId, String messageId, String toolCallId, String operationType, String entityType, String entityId, String? snapshotBefore, String? snapshotAfter, bool isUndone, DateTime? undoneAt, DateTime expiresAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$AiUndoLogModelCopyWithImpl<$Res>
    implements _$AiUndoLogModelCopyWith<$Res> {
  __$AiUndoLogModelCopyWithImpl(this._self, this._then);

  final _AiUndoLogModel _self;
  final $Res Function(_AiUndoLogModel) _then;

/// Create a copy of AiUndoLogModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? conversationId = null,Object? messageId = null,Object? toolCallId = null,Object? operationType = null,Object? entityType = null,Object? entityId = null,Object? snapshotBefore = freezed,Object? snapshotAfter = freezed,Object? isUndone = null,Object? undoneAt = freezed,Object? expiresAt = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_AiUndoLogModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,toolCallId: null == toolCallId ? _self.toolCallId : toolCallId // ignore: cast_nullable_to_non_nullable
as String,operationType: null == operationType ? _self.operationType : operationType // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,snapshotBefore: freezed == snapshotBefore ? _self.snapshotBefore : snapshotBefore // ignore: cast_nullable_to_non_nullable
as String?,snapshotAfter: freezed == snapshotAfter ? _self.snapshotAfter : snapshotAfter // ignore: cast_nullable_to_non_nullable
as String?,isUndone: null == isUndone ? _self.isUndone : isUndone // ignore: cast_nullable_to_non_nullable
as bool,undoneAt: freezed == undoneAt ? _self.undoneAt : undoneAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
