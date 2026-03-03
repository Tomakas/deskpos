// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AiPendingConfirmation {

 String get conversationId; String get messageId; AiToolCall get toolCall; String get description; bool get isDestructive; DateTime get createdAt;
/// Create a copy of AiPendingConfirmation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiPendingConfirmationCopyWith<AiPendingConfirmation> get copyWith => _$AiPendingConfirmationCopyWithImpl<AiPendingConfirmation>(this as AiPendingConfirmation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiPendingConfirmation&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.toolCall, toolCall) || other.toolCall == toolCall)&&(identical(other.description, description) || other.description == description)&&(identical(other.isDestructive, isDestructive) || other.isDestructive == isDestructive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId,messageId,toolCall,description,isDestructive,createdAt);

@override
String toString() {
  return 'AiPendingConfirmation(conversationId: $conversationId, messageId: $messageId, toolCall: $toolCall, description: $description, isDestructive: $isDestructive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AiPendingConfirmationCopyWith<$Res>  {
  factory $AiPendingConfirmationCopyWith(AiPendingConfirmation value, $Res Function(AiPendingConfirmation) _then) = _$AiPendingConfirmationCopyWithImpl;
@useResult
$Res call({
 String conversationId, String messageId, AiToolCall toolCall, String description, bool isDestructive, DateTime createdAt
});


$AiToolCallCopyWith<$Res> get toolCall;

}
/// @nodoc
class _$AiPendingConfirmationCopyWithImpl<$Res>
    implements $AiPendingConfirmationCopyWith<$Res> {
  _$AiPendingConfirmationCopyWithImpl(this._self, this._then);

  final AiPendingConfirmation _self;
  final $Res Function(AiPendingConfirmation) _then;

/// Create a copy of AiPendingConfirmation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversationId = null,Object? messageId = null,Object? toolCall = null,Object? description = null,Object? isDestructive = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,toolCall: null == toolCall ? _self.toolCall : toolCall // ignore: cast_nullable_to_non_nullable
as AiToolCall,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isDestructive: null == isDestructive ? _self.isDestructive : isDestructive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of AiPendingConfirmation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiToolCallCopyWith<$Res> get toolCall {
  
  return $AiToolCallCopyWith<$Res>(_self.toolCall, (value) {
    return _then(_self.copyWith(toolCall: value));
  });
}
}


/// Adds pattern-matching-related methods to [AiPendingConfirmation].
extension AiPendingConfirmationPatterns on AiPendingConfirmation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiPendingConfirmation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiPendingConfirmation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiPendingConfirmation value)  $default,){
final _that = this;
switch (_that) {
case _AiPendingConfirmation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiPendingConfirmation value)?  $default,){
final _that = this;
switch (_that) {
case _AiPendingConfirmation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String conversationId,  String messageId,  AiToolCall toolCall,  String description,  bool isDestructive,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiPendingConfirmation() when $default != null:
return $default(_that.conversationId,_that.messageId,_that.toolCall,_that.description,_that.isDestructive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String conversationId,  String messageId,  AiToolCall toolCall,  String description,  bool isDestructive,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AiPendingConfirmation():
return $default(_that.conversationId,_that.messageId,_that.toolCall,_that.description,_that.isDestructive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String conversationId,  String messageId,  AiToolCall toolCall,  String description,  bool isDestructive,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AiPendingConfirmation() when $default != null:
return $default(_that.conversationId,_that.messageId,_that.toolCall,_that.description,_that.isDestructive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _AiPendingConfirmation extends AiPendingConfirmation {
  const _AiPendingConfirmation({required this.conversationId, required this.messageId, required this.toolCall, required this.description, required this.isDestructive, required this.createdAt}): super._();
  

@override final  String conversationId;
@override final  String messageId;
@override final  AiToolCall toolCall;
@override final  String description;
@override final  bool isDestructive;
@override final  DateTime createdAt;

/// Create a copy of AiPendingConfirmation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiPendingConfirmationCopyWith<_AiPendingConfirmation> get copyWith => __$AiPendingConfirmationCopyWithImpl<_AiPendingConfirmation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiPendingConfirmation&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.toolCall, toolCall) || other.toolCall == toolCall)&&(identical(other.description, description) || other.description == description)&&(identical(other.isDestructive, isDestructive) || other.isDestructive == isDestructive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId,messageId,toolCall,description,isDestructive,createdAt);

@override
String toString() {
  return 'AiPendingConfirmation(conversationId: $conversationId, messageId: $messageId, toolCall: $toolCall, description: $description, isDestructive: $isDestructive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AiPendingConfirmationCopyWith<$Res> implements $AiPendingConfirmationCopyWith<$Res> {
  factory _$AiPendingConfirmationCopyWith(_AiPendingConfirmation value, $Res Function(_AiPendingConfirmation) _then) = __$AiPendingConfirmationCopyWithImpl;
@override @useResult
$Res call({
 String conversationId, String messageId, AiToolCall toolCall, String description, bool isDestructive, DateTime createdAt
});


@override $AiToolCallCopyWith<$Res> get toolCall;

}
/// @nodoc
class __$AiPendingConfirmationCopyWithImpl<$Res>
    implements _$AiPendingConfirmationCopyWith<$Res> {
  __$AiPendingConfirmationCopyWithImpl(this._self, this._then);

  final _AiPendingConfirmation _self;
  final $Res Function(_AiPendingConfirmation) _then;

/// Create a copy of AiPendingConfirmation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? messageId = null,Object? toolCall = null,Object? description = null,Object? isDestructive = null,Object? createdAt = null,}) {
  return _then(_AiPendingConfirmation(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,toolCall: null == toolCall ? _self.toolCall : toolCall // ignore: cast_nullable_to_non_nullable
as AiToolCall,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isDestructive: null == isDestructive ? _self.isDestructive : isDestructive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of AiPendingConfirmation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiToolCallCopyWith<$Res> get toolCall {
  
  return $AiToolCallCopyWith<$Res>(_self.toolCall, (value) {
    return _then(_self.copyWith(toolCall: value));
  });
}
}

// dart format on
