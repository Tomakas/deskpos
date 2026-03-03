// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_provider_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AiToolCall {

 String get id; String get name; Map<String, dynamic> get arguments;
/// Create a copy of AiToolCall
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiToolCallCopyWith<AiToolCall> get copyWith => _$AiToolCallCopyWithImpl<AiToolCall>(this as AiToolCall, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiToolCall&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.arguments, arguments));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(arguments));

@override
String toString() {
  return 'AiToolCall(id: $id, name: $name, arguments: $arguments)';
}


}

/// @nodoc
abstract mixin class $AiToolCallCopyWith<$Res>  {
  factory $AiToolCallCopyWith(AiToolCall value, $Res Function(AiToolCall) _then) = _$AiToolCallCopyWithImpl;
@useResult
$Res call({
 String id, String name, Map<String, dynamic> arguments
});




}
/// @nodoc
class _$AiToolCallCopyWithImpl<$Res>
    implements $AiToolCallCopyWith<$Res> {
  _$AiToolCallCopyWithImpl(this._self, this._then);

  final AiToolCall _self;
  final $Res Function(AiToolCall) _then;

/// Create a copy of AiToolCall
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? arguments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self.arguments : arguments // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [AiToolCall].
extension AiToolCallPatterns on AiToolCall {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiToolCall value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiToolCall() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiToolCall value)  $default,){
final _that = this;
switch (_that) {
case _AiToolCall():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiToolCall value)?  $default,){
final _that = this;
switch (_that) {
case _AiToolCall() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  Map<String, dynamic> arguments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiToolCall() when $default != null:
return $default(_that.id,_that.name,_that.arguments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  Map<String, dynamic> arguments)  $default,) {final _that = this;
switch (_that) {
case _AiToolCall():
return $default(_that.id,_that.name,_that.arguments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  Map<String, dynamic> arguments)?  $default,) {final _that = this;
switch (_that) {
case _AiToolCall() when $default != null:
return $default(_that.id,_that.name,_that.arguments);case _:
  return null;

}
}

}

/// @nodoc


class _AiToolCall implements AiToolCall {
  const _AiToolCall({required this.id, required this.name, required final  Map<String, dynamic> arguments}): _arguments = arguments;
  

@override final  String id;
@override final  String name;
 final  Map<String, dynamic> _arguments;
@override Map<String, dynamic> get arguments {
  if (_arguments is EqualUnmodifiableMapView) return _arguments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_arguments);
}


/// Create a copy of AiToolCall
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiToolCallCopyWith<_AiToolCall> get copyWith => __$AiToolCallCopyWithImpl<_AiToolCall>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiToolCall&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._arguments, _arguments));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_arguments));

@override
String toString() {
  return 'AiToolCall(id: $id, name: $name, arguments: $arguments)';
}


}

/// @nodoc
abstract mixin class _$AiToolCallCopyWith<$Res> implements $AiToolCallCopyWith<$Res> {
  factory _$AiToolCallCopyWith(_AiToolCall value, $Res Function(_AiToolCall) _then) = __$AiToolCallCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Map<String, dynamic> arguments
});




}
/// @nodoc
class __$AiToolCallCopyWithImpl<$Res>
    implements _$AiToolCallCopyWith<$Res> {
  __$AiToolCallCopyWithImpl(this._self, this._then);

  final _AiToolCall _self;
  final $Res Function(_AiToolCall) _then;

/// Create a copy of AiToolCall
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? arguments = null,}) {
  return _then(_AiToolCall(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self._arguments : arguments // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc
mixin _$AiToolDefinition {

 String get name; String get description; Map<String, dynamic> get parameters;
/// Create a copy of AiToolDefinition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiToolDefinitionCopyWith<AiToolDefinition> get copyWith => _$AiToolDefinitionCopyWithImpl<AiToolDefinition>(this as AiToolDefinition, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiToolDefinition&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.parameters, parameters));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,const DeepCollectionEquality().hash(parameters));

@override
String toString() {
  return 'AiToolDefinition(name: $name, description: $description, parameters: $parameters)';
}


}

/// @nodoc
abstract mixin class $AiToolDefinitionCopyWith<$Res>  {
  factory $AiToolDefinitionCopyWith(AiToolDefinition value, $Res Function(AiToolDefinition) _then) = _$AiToolDefinitionCopyWithImpl;
@useResult
$Res call({
 String name, String description, Map<String, dynamic> parameters
});




}
/// @nodoc
class _$AiToolDefinitionCopyWithImpl<$Res>
    implements $AiToolDefinitionCopyWith<$Res> {
  _$AiToolDefinitionCopyWithImpl(this._self, this._then);

  final AiToolDefinition _self;
  final $Res Function(AiToolDefinition) _then;

/// Create a copy of AiToolDefinition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? parameters = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,parameters: null == parameters ? _self.parameters : parameters // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [AiToolDefinition].
extension AiToolDefinitionPatterns on AiToolDefinition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiToolDefinition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiToolDefinition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiToolDefinition value)  $default,){
final _that = this;
switch (_that) {
case _AiToolDefinition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiToolDefinition value)?  $default,){
final _that = this;
switch (_that) {
case _AiToolDefinition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String description,  Map<String, dynamic> parameters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiToolDefinition() when $default != null:
return $default(_that.name,_that.description,_that.parameters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String description,  Map<String, dynamic> parameters)  $default,) {final _that = this;
switch (_that) {
case _AiToolDefinition():
return $default(_that.name,_that.description,_that.parameters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String description,  Map<String, dynamic> parameters)?  $default,) {final _that = this;
switch (_that) {
case _AiToolDefinition() when $default != null:
return $default(_that.name,_that.description,_that.parameters);case _:
  return null;

}
}

}

/// @nodoc


class _AiToolDefinition implements AiToolDefinition {
  const _AiToolDefinition({required this.name, required this.description, required final  Map<String, dynamic> parameters}): _parameters = parameters;
  

@override final  String name;
@override final  String description;
 final  Map<String, dynamic> _parameters;
@override Map<String, dynamic> get parameters {
  if (_parameters is EqualUnmodifiableMapView) return _parameters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_parameters);
}


/// Create a copy of AiToolDefinition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiToolDefinitionCopyWith<_AiToolDefinition> get copyWith => __$AiToolDefinitionCopyWithImpl<_AiToolDefinition>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiToolDefinition&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._parameters, _parameters));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,const DeepCollectionEquality().hash(_parameters));

@override
String toString() {
  return 'AiToolDefinition(name: $name, description: $description, parameters: $parameters)';
}


}

/// @nodoc
abstract mixin class _$AiToolDefinitionCopyWith<$Res> implements $AiToolDefinitionCopyWith<$Res> {
  factory _$AiToolDefinitionCopyWith(_AiToolDefinition value, $Res Function(_AiToolDefinition) _then) = __$AiToolDefinitionCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, Map<String, dynamic> parameters
});




}
/// @nodoc
class __$AiToolDefinitionCopyWithImpl<$Res>
    implements _$AiToolDefinitionCopyWith<$Res> {
  __$AiToolDefinitionCopyWithImpl(this._self, this._then);

  final _AiToolDefinition _self;
  final $Res Function(_AiToolDefinition) _then;

/// Create a copy of AiToolDefinition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? parameters = null,}) {
  return _then(_AiToolDefinition(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,parameters: null == parameters ? _self._parameters : parameters // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc
mixin _$AiProviderResponse {

 String? get content; List<AiToolCall>? get toolCalls; int get promptTokens; int get completionTokens; String get finishReason;
/// Create a copy of AiProviderResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiProviderResponseCopyWith<AiProviderResponse> get copyWith => _$AiProviderResponseCopyWithImpl<AiProviderResponse>(this as AiProviderResponse, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiProviderResponse&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.toolCalls, toolCalls)&&(identical(other.promptTokens, promptTokens) || other.promptTokens == promptTokens)&&(identical(other.completionTokens, completionTokens) || other.completionTokens == completionTokens)&&(identical(other.finishReason, finishReason) || other.finishReason == finishReason));
}


@override
int get hashCode => Object.hash(runtimeType,content,const DeepCollectionEquality().hash(toolCalls),promptTokens,completionTokens,finishReason);

@override
String toString() {
  return 'AiProviderResponse(content: $content, toolCalls: $toolCalls, promptTokens: $promptTokens, completionTokens: $completionTokens, finishReason: $finishReason)';
}


}

/// @nodoc
abstract mixin class $AiProviderResponseCopyWith<$Res>  {
  factory $AiProviderResponseCopyWith(AiProviderResponse value, $Res Function(AiProviderResponse) _then) = _$AiProviderResponseCopyWithImpl;
@useResult
$Res call({
 String? content, List<AiToolCall>? toolCalls, int promptTokens, int completionTokens, String finishReason
});




}
/// @nodoc
class _$AiProviderResponseCopyWithImpl<$Res>
    implements $AiProviderResponseCopyWith<$Res> {
  _$AiProviderResponseCopyWithImpl(this._self, this._then);

  final AiProviderResponse _self;
  final $Res Function(AiProviderResponse) _then;

/// Create a copy of AiProviderResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = freezed,Object? toolCalls = freezed,Object? promptTokens = null,Object? completionTokens = null,Object? finishReason = null,}) {
  return _then(_self.copyWith(
content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,toolCalls: freezed == toolCalls ? _self.toolCalls : toolCalls // ignore: cast_nullable_to_non_nullable
as List<AiToolCall>?,promptTokens: null == promptTokens ? _self.promptTokens : promptTokens // ignore: cast_nullable_to_non_nullable
as int,completionTokens: null == completionTokens ? _self.completionTokens : completionTokens // ignore: cast_nullable_to_non_nullable
as int,finishReason: null == finishReason ? _self.finishReason : finishReason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AiProviderResponse].
extension AiProviderResponsePatterns on AiProviderResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiProviderResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiProviderResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiProviderResponse value)  $default,){
final _that = this;
switch (_that) {
case _AiProviderResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiProviderResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AiProviderResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? content,  List<AiToolCall>? toolCalls,  int promptTokens,  int completionTokens,  String finishReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiProviderResponse() when $default != null:
return $default(_that.content,_that.toolCalls,_that.promptTokens,_that.completionTokens,_that.finishReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? content,  List<AiToolCall>? toolCalls,  int promptTokens,  int completionTokens,  String finishReason)  $default,) {final _that = this;
switch (_that) {
case _AiProviderResponse():
return $default(_that.content,_that.toolCalls,_that.promptTokens,_that.completionTokens,_that.finishReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? content,  List<AiToolCall>? toolCalls,  int promptTokens,  int completionTokens,  String finishReason)?  $default,) {final _that = this;
switch (_that) {
case _AiProviderResponse() when $default != null:
return $default(_that.content,_that.toolCalls,_that.promptTokens,_that.completionTokens,_that.finishReason);case _:
  return null;

}
}

}

/// @nodoc


class _AiProviderResponse implements AiProviderResponse {
  const _AiProviderResponse({this.content, final  List<AiToolCall>? toolCalls, required this.promptTokens, required this.completionTokens, required this.finishReason}): _toolCalls = toolCalls;
  

@override final  String? content;
 final  List<AiToolCall>? _toolCalls;
@override List<AiToolCall>? get toolCalls {
  final value = _toolCalls;
  if (value == null) return null;
  if (_toolCalls is EqualUnmodifiableListView) return _toolCalls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int promptTokens;
@override final  int completionTokens;
@override final  String finishReason;

/// Create a copy of AiProviderResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiProviderResponseCopyWith<_AiProviderResponse> get copyWith => __$AiProviderResponseCopyWithImpl<_AiProviderResponse>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiProviderResponse&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._toolCalls, _toolCalls)&&(identical(other.promptTokens, promptTokens) || other.promptTokens == promptTokens)&&(identical(other.completionTokens, completionTokens) || other.completionTokens == completionTokens)&&(identical(other.finishReason, finishReason) || other.finishReason == finishReason));
}


@override
int get hashCode => Object.hash(runtimeType,content,const DeepCollectionEquality().hash(_toolCalls),promptTokens,completionTokens,finishReason);

@override
String toString() {
  return 'AiProviderResponse(content: $content, toolCalls: $toolCalls, promptTokens: $promptTokens, completionTokens: $completionTokens, finishReason: $finishReason)';
}


}

/// @nodoc
abstract mixin class _$AiProviderResponseCopyWith<$Res> implements $AiProviderResponseCopyWith<$Res> {
  factory _$AiProviderResponseCopyWith(_AiProviderResponse value, $Res Function(_AiProviderResponse) _then) = __$AiProviderResponseCopyWithImpl;
@override @useResult
$Res call({
 String? content, List<AiToolCall>? toolCalls, int promptTokens, int completionTokens, String finishReason
});




}
/// @nodoc
class __$AiProviderResponseCopyWithImpl<$Res>
    implements _$AiProviderResponseCopyWith<$Res> {
  __$AiProviderResponseCopyWithImpl(this._self, this._then);

  final _AiProviderResponse _self;
  final $Res Function(_AiProviderResponse) _then;

/// Create a copy of AiProviderResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = freezed,Object? toolCalls = freezed,Object? promptTokens = null,Object? completionTokens = null,Object? finishReason = null,}) {
  return _then(_AiProviderResponse(
content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,toolCalls: freezed == toolCalls ? _self._toolCalls : toolCalls // ignore: cast_nullable_to_non_nullable
as List<AiToolCall>?,promptTokens: null == promptTokens ? _self.promptTokens : promptTokens // ignore: cast_nullable_to_non_nullable
as int,completionTokens: null == completionTokens ? _self.completionTokens : completionTokens // ignore: cast_nullable_to_non_nullable
as int,finishReason: null == finishReason ? _self.finishReason : finishReason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
