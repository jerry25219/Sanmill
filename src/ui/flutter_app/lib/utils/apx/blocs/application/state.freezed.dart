// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ApplicationErrorState {

 String get error;
/// Create a copy of ApplicationErrorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplicationErrorStateCopyWith<ApplicationErrorState> get copyWith => _$ApplicationErrorStateCopyWithImpl<ApplicationErrorState>(this as ApplicationErrorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApplicationErrorState&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ApplicationErrorState(error: $error)';
}


}

/// @nodoc
abstract mixin class $ApplicationErrorStateCopyWith<$Res>  {
  factory $ApplicationErrorStateCopyWith(ApplicationErrorState value, $Res Function(ApplicationErrorState) _then) = _$ApplicationErrorStateCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$ApplicationErrorStateCopyWithImpl<$Res>
    implements $ApplicationErrorStateCopyWith<$Res> {
  _$ApplicationErrorStateCopyWithImpl(this._self, this._then);

  final ApplicationErrorState _self;
  final $Res Function(ApplicationErrorState) _then;

/// Create a copy of ApplicationErrorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? error = null,}) {
  return _then(ApplicationErrorState(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
mixin _$ApplicationReadyState {

 List<String>? get domains;
/// Create a copy of ApplicationReadyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplicationReadyStateCopyWith<ApplicationReadyState> get copyWith => _$ApplicationReadyStateCopyWithImpl<ApplicationReadyState>(this as ApplicationReadyState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApplicationReadyState&&const DeepCollectionEquality().equals(other.domains, domains));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(domains));

@override
String toString() {
  return 'ApplicationReadyState(domains: $domains)';
}


}

/// @nodoc
abstract mixin class $ApplicationReadyStateCopyWith<$Res>  {
  factory $ApplicationReadyStateCopyWith(ApplicationReadyState value, $Res Function(ApplicationReadyState) _then) = _$ApplicationReadyStateCopyWithImpl;
@useResult
$Res call({
 List<String>? domains
});




}
/// @nodoc
class _$ApplicationReadyStateCopyWithImpl<$Res>
    implements $ApplicationReadyStateCopyWith<$Res> {
  _$ApplicationReadyStateCopyWithImpl(this._self, this._then);

  final ApplicationReadyState _self;
  final $Res Function(ApplicationReadyState) _then;

/// Create a copy of ApplicationReadyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? domains = freezed,}) {
  return _then(ApplicationReadyState(
domains: freezed == domains ? _self.domains : domains // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


// dart format on
