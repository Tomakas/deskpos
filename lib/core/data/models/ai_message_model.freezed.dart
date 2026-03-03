// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AiMessageModel {

 String get id; String get companyId; String get conversationId; AiMessageRole get role; String get content; String? get toolCalls; String? get toolResults; AiMessageStatus get status; String? get errorMessage; int? get tokenCount; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of AiMessageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiMessageModelCopyWith<AiMessageModel> get copyWith => _$AiMessageModelCopyWithImpl<AiMessageModel>(this as AiMessageModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&(identical(other.toolCalls, toolCalls) || other.toolCalls == toolCalls)&&(identical(other.toolResults, toolResults) || other.toolResults == toolResults)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.tokenCount, tokenCount) || other.tokenCount == tokenCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,conversationId,role,content,toolCalls,toolResults,status,errorMessage,tokenCount,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'AiMessageModel(id: $id, companyId: $companyId, conversationId: $conversationId, role: $role, content: $content, toolCalls: $toolCalls, toolResults: $toolResults, status: $status, errorMessage: $errorMessage, tokenCount: $tokenCount, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $AiMessageModelCopyWith<$Res>  {
  factory $AiMessageModelCopyWith(AiMessageModel value, $Res Function(AiMessageModel) _then) = _$AiMessageModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String conversationId, AiMessageRole role, String content, String? toolCalls, String? toolResults, AiMessageStatus status, String? errorMessage, int? tokenCount, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$AiMessageModelCopyWithImpl<$Res>
    implements $AiMessageModelCopyWith<$Res> {
  _$AiMessageModelCopyWithImpl(this._self, this._then);

  final AiMessageModel _self;
  final $Res Function(AiMessageModel) _then;

/// Create a copy of AiMessageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? conversationId = null,Object? role = null,Object? content = null,Object? toolCalls = freezed,Object? toolResults = freezed,Object? status = null,Object? errorMessage = freezed,Object? tokenCount = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as AiMessageRole,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,toolCalls: freezed == toolCalls ? _self.toolCalls : toolCalls // ignore: cast_nullable_to_non_nullable
as String?,toolResults: freezed == toolResults ? _self.toolResults : toolResults // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AiMessageStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,tokenCount: freezed == tokenCount ? _self.tokenCount : tokenCount // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiMessageModel].
extension AiMessageModelPatterns on AiMessageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiMessageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiMessageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiMessageModel value)  $default,){
final _that = this;
switch (_that) {
case _AiMessageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiMessageModel value)?  $default,){
final _that = this;
switch (_that) {
case _AiMessageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String conversationId,  AiMessageRole role,  String content,  String? toolCalls,  String? toolResults,  AiMessageStatus status,  String? errorMessage,  int? tokenCount,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiMessageModel() when $default != null:
return $default(_that.id,_that.companyId,_that.conversationId,_that.role,_that.content,_that.toolCalls,_that.toolResults,_that.status,_that.errorMessage,_that.tokenCount,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String conversationId,  AiMessageRole role,  String content,  String? toolCalls,  String? toolResults,  AiMessageStatus status,  String? errorMessage,  int? tokenCount,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _AiMessageModel():
return $default(_that.id,_that.companyId,_that.conversationId,_that.role,_that.content,_that.toolCalls,_that.toolResults,_that.status,_that.errorMessage,_that.tokenCount,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String conversationId,  AiMessageRole role,  String content,  String? toolCalls,  String? toolResults,  AiMessageStatus status,  String? errorMessage,  int? tokenCount,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _AiMessageModel() when $default != null:
return $default(_that.id,_that.companyId,_that.conversationId,_that.role,_that.content,_that.toolCalls,_that.toolResults,_that.status,_that.errorMessage,_that.tokenCount,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AiMessageModel implements AiMessageModel {
  const _AiMessageModel({required this.id, required this.companyId, required this.conversationId, required this.role, required this.content, this.toolCalls, this.toolResults, required this.status, this.errorMessage, this.tokenCount, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String conversationId;
@override final  AiMessageRole role;
@override final  String content;
@override final  String? toolCalls;
@override final  String? toolResults;
@override final  AiMessageStatus status;
@override final  String? errorMessage;
@override final  int? tokenCount;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of AiMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiMessageModelCopyWith<_AiMessageModel> get copyWith => __$AiMessageModelCopyWithImpl<_AiMessageModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&(identical(other.toolCalls, toolCalls) || other.toolCalls == toolCalls)&&(identical(other.toolResults, toolResults) || other.toolResults == toolResults)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.tokenCount, tokenCount) || other.tokenCount == tokenCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,conversationId,role,content,toolCalls,toolResults,status,errorMessage,tokenCount,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'AiMessageModel(id: $id, companyId: $companyId, conversationId: $conversationId, role: $role, content: $content, toolCalls: $toolCalls, toolResults: $toolResults, status: $status, errorMessage: $errorMessage, tokenCount: $tokenCount, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$AiMessageModelCopyWith<$Res> implements $AiMessageModelCopyWith<$Res> {
  factory _$AiMessageModelCopyWith(_AiMessageModel value, $Res Function(_AiMessageModel) _then) = __$AiMessageModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String conversationId, AiMessageRole role, String content, String? toolCalls, String? toolResults, AiMessageStatus status, String? errorMessage, int? tokenCount, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$AiMessageModelCopyWithImpl<$Res>
    implements _$AiMessageModelCopyWith<$Res> {
  __$AiMessageModelCopyWithImpl(this._self, this._then);

  final _AiMessageModel _self;
  final $Res Function(_AiMessageModel) _then;

/// Create a copy of AiMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? conversationId = null,Object? role = null,Object? content = null,Object? toolCalls = freezed,Object? toolResults = freezed,Object? status = null,Object? errorMessage = freezed,Object? tokenCount = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_AiMessageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as AiMessageRole,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,toolCalls: freezed == toolCalls ? _self.toolCalls : toolCalls // ignore: cast_nullable_to_non_nullable
as String?,toolResults: freezed == toolResults ? _self.toolResults : toolResults // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AiMessageStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,tokenCount: freezed == tokenCount ? _self.tokenCount : tokenCount // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
