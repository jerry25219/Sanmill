// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterResult {

 Domains get domains; bool get succeed;
/// Create a copy of RegisterResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterResultCopyWith<RegisterResult> get copyWith => _$RegisterResultCopyWithImpl<RegisterResult>(this as RegisterResult, _$identity);

  /// Serializes this RegisterResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterResult&&(identical(other.domains, domains) || other.domains == domains)&&(identical(other.succeed, succeed) || other.succeed == succeed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,domains,succeed);

@override
String toString() {
  return 'RegisterResult(domains: $domains, succeed: $succeed)';
}


}

/// @nodoc
abstract mixin class $RegisterResultCopyWith<$Res>  {
  factory $RegisterResultCopyWith(RegisterResult value, $Res Function(RegisterResult) _then) = _$RegisterResultCopyWithImpl;
@useResult
$Res call({
 Domains domains, bool succeed
});


$DomainsCopyWith<$Res> get domains;

}
/// @nodoc
class _$RegisterResultCopyWithImpl<$Res>
    implements $RegisterResultCopyWith<$Res> {
  _$RegisterResultCopyWithImpl(this._self, this._then);

  final RegisterResult _self;
  final $Res Function(RegisterResult) _then;

/// Create a copy of RegisterResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? domains = null,Object? succeed = null,}) {
  return _then(_self.copyWith(
domains: null == domains ? _self.domains : domains // ignore: cast_nullable_to_non_nullable
as Domains,succeed: null == succeed ? _self.succeed : succeed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of RegisterResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainsCopyWith<$Res> get domains {
  
  return $DomainsCopyWith<$Res>(_self.domains, (value) {
    return _then(_self.copyWith(domains: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _RegisterResult implements RegisterResult {
  const _RegisterResult({required this.domains, required this.succeed});
  factory _RegisterResult.fromJson(Map<String, dynamic> json) => _$RegisterResultFromJson(json);

@override final  Domains domains;
@override final  bool succeed;

/// Create a copy of RegisterResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterResultCopyWith<_RegisterResult> get copyWith => __$RegisterResultCopyWithImpl<_RegisterResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterResult&&(identical(other.domains, domains) || other.domains == domains)&&(identical(other.succeed, succeed) || other.succeed == succeed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,domains,succeed);

@override
String toString() {
  return 'RegisterResult(domains: $domains, succeed: $succeed)';
}


}

/// @nodoc
abstract mixin class _$RegisterResultCopyWith<$Res> implements $RegisterResultCopyWith<$Res> {
  factory _$RegisterResultCopyWith(_RegisterResult value, $Res Function(_RegisterResult) _then) = __$RegisterResultCopyWithImpl;
@override @useResult
$Res call({
 Domains domains, bool succeed
});


@override $DomainsCopyWith<$Res> get domains;

}
/// @nodoc
class __$RegisterResultCopyWithImpl<$Res>
    implements _$RegisterResultCopyWith<$Res> {
  __$RegisterResultCopyWithImpl(this._self, this._then);

  final _RegisterResult _self;
  final $Res Function(_RegisterResult) _then;

/// Create a copy of RegisterResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? domains = null,Object? succeed = null,}) {
  return _then(_RegisterResult(
domains: null == domains ? _self.domains : domains // ignore: cast_nullable_to_non_nullable
as Domains,succeed: null == succeed ? _self.succeed : succeed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of RegisterResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainsCopyWith<$Res> get domains {
  
  return $DomainsCopyWith<$Res>(_self.domains, (value) {
    return _then(_self.copyWith(domains: value));
  });
}
}

// dart format on
