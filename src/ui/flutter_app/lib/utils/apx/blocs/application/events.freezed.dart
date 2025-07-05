// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'events.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ApplicationBeginRegisterEvent {

 String? get invitationCode;
/// Create a copy of ApplicationBeginRegisterEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplicationBeginRegisterEventCopyWith<ApplicationBeginRegisterEvent> get copyWith => _$ApplicationBeginRegisterEventCopyWithImpl<ApplicationBeginRegisterEvent>(this as ApplicationBeginRegisterEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApplicationBeginRegisterEvent&&(identical(other.invitationCode, invitationCode) || other.invitationCode == invitationCode));
}


@override
int get hashCode => Object.hash(runtimeType,invitationCode);

@override
String toString() {
  return 'ApplicationBeginRegisterEvent(invitationCode: $invitationCode)';
}


}

/// @nodoc
abstract mixin class $ApplicationBeginRegisterEventCopyWith<$Res>  {
  factory $ApplicationBeginRegisterEventCopyWith(ApplicationBeginRegisterEvent value, $Res Function(ApplicationBeginRegisterEvent) _then) = _$ApplicationBeginRegisterEventCopyWithImpl;
@useResult
$Res call({
 String? invitationCode
});




}
/// @nodoc
class _$ApplicationBeginRegisterEventCopyWithImpl<$Res>
    implements $ApplicationBeginRegisterEventCopyWith<$Res> {
  _$ApplicationBeginRegisterEventCopyWithImpl(this._self, this._then);

  final ApplicationBeginRegisterEvent _self;
  final $Res Function(ApplicationBeginRegisterEvent) _then;

/// Create a copy of ApplicationBeginRegisterEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? invitationCode = freezed,}) {
  return _then(ApplicationBeginRegisterEvent(
invitationCode: freezed == invitationCode ? _self.invitationCode : invitationCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
mixin _$ApplicationBeginAuthenticateEvent {

 String get userId; String get password;
/// Create a copy of ApplicationBeginAuthenticateEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplicationBeginAuthenticateEventCopyWith<ApplicationBeginAuthenticateEvent> get copyWith => _$ApplicationBeginAuthenticateEventCopyWithImpl<ApplicationBeginAuthenticateEvent>(this as ApplicationBeginAuthenticateEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApplicationBeginAuthenticateEvent&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode => Object.hash(runtimeType,userId,password);

@override
String toString() {
  return 'ApplicationBeginAuthenticateEvent(userId: $userId, password: $password)';
}


}

/// @nodoc
abstract mixin class $ApplicationBeginAuthenticateEventCopyWith<$Res>  {
  factory $ApplicationBeginAuthenticateEventCopyWith(ApplicationBeginAuthenticateEvent value, $Res Function(ApplicationBeginAuthenticateEvent) _then) = _$ApplicationBeginAuthenticateEventCopyWithImpl;
@useResult
$Res call({
 String userId, String password
});




}
/// @nodoc
class _$ApplicationBeginAuthenticateEventCopyWithImpl<$Res>
    implements $ApplicationBeginAuthenticateEventCopyWith<$Res> {
  _$ApplicationBeginAuthenticateEventCopyWithImpl(this._self, this._then);

  final ApplicationBeginAuthenticateEvent _self;
  final $Res Function(ApplicationBeginAuthenticateEvent) _then;

/// Create a copy of ApplicationBeginAuthenticateEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? password = null,}) {
  return _then(ApplicationBeginAuthenticateEvent(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


// dart format on
