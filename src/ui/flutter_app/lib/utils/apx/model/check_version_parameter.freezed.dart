





part of 'check_version_parameter.dart';






T _$identity<T>(T value) => value;


mixin _$CheckVersionParameter {

 String get appId; String get deviceType; String get deviceOs; String get appVersion; String get appBuildNumber;


@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckVersionParameterCopyWith<CheckVersionParameter> get copyWith => _$CheckVersionParameterCopyWithImpl<CheckVersionParameter>(this as CheckVersionParameter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckVersionParameter&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType)&&(identical(other.deviceOs, deviceOs) || other.deviceOs == deviceOs)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.appBuildNumber, appBuildNumber) || other.appBuildNumber == appBuildNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appId,deviceType,deviceOs,appVersion,appBuildNumber);

@override
String toString() {
  return 'CheckVersionParameter(appId: $appId, deviceType: $deviceType, deviceOs: $deviceOs, appVersion: $appVersion, appBuildNumber: $appBuildNumber)';
}


}


abstract mixin class $CheckVersionParameterCopyWith<$Res>  {
  factory $CheckVersionParameterCopyWith(CheckVersionParameter value, $Res Function(CheckVersionParameter) _then) = _$CheckVersionParameterCopyWithImpl;
@useResult
$Res call({
 String appId, String deviceType, String deviceOs, String appVersion, String appBuildNumber
});




}

class _$CheckVersionParameterCopyWithImpl<$Res>
    implements $CheckVersionParameterCopyWith<$Res> {
  _$CheckVersionParameterCopyWithImpl(this._self, this._then);

  final CheckVersionParameter _self;
  final $Res Function(CheckVersionParameter) _then;



@pragma('vm:prefer-inline') @override $Res call({Object? appId = null,Object? deviceType = null,Object? deviceOs = null,Object? appVersion = null,Object? appBuildNumber = null,}) {
  return _then(CheckVersionParameter(
appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String,deviceType: null == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as String,deviceOs: null == deviceOs ? _self.deviceOs : deviceOs // ignore: cast_nullable_to_non_nullable
as String,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,appBuildNumber: null == appBuildNumber ? _self.appBuildNumber : appBuildNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}



