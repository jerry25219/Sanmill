





part of 'register_data.dart';






T _$identity<T>(T value) => value;


mixin _$RegisterData {

 String? get invitationCode; set invitationCode(String? value); String? get deviceId; set deviceId(String? value);


@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterDataCopyWith<RegisterData> get copyWith => _$RegisterDataCopyWithImpl<RegisterData>(this as RegisterData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterData&&(identical(other.invitationCode, invitationCode) || other.invitationCode == invitationCode)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,invitationCode,deviceId);

@override
String toString() {
  return 'RegisterData(invitationCode: $invitationCode, deviceId: $deviceId)';
}


}


abstract mixin class $RegisterDataCopyWith<$Res>  {
  factory $RegisterDataCopyWith(RegisterData value, $Res Function(RegisterData) _then) = _$RegisterDataCopyWithImpl;
@useResult
$Res call({
 String? invitationCode, String? deviceId
});




}

class _$RegisterDataCopyWithImpl<$Res>
    implements $RegisterDataCopyWith<$Res> {
  _$RegisterDataCopyWithImpl(this._self, this._then);

  final RegisterData _self;
  final $Res Function(RegisterData) _then;



@pragma('vm:prefer-inline') @override $Res call({Object? invitationCode = freezed,Object? deviceId = freezed,}) {
  return _then(RegisterData(
invitationCode: freezed == invitationCode ? _self.invitationCode : invitationCode // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



