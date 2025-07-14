





part of 'check_version_response.dart';






T _$identity<T>(T value) => value;


mixin _$CheckVersionResponse {

 bool get upgradeAble; set upgradeAble(bool value); String? get upgradeUri; set upgradeUri(String? value); String? get code; set code(String? value); String? get authorization; set authorization(String? value); String? get clientId; set clientId(String? value); String? get contentLanguage; set contentLanguage(String? value);


@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckVersionResponseCopyWith<CheckVersionResponse> get copyWith => _$CheckVersionResponseCopyWithImpl<CheckVersionResponse>(this as CheckVersionResponse, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckVersionResponse&&(identical(other.upgradeAble, upgradeAble) || other.upgradeAble == upgradeAble)&&(identical(other.upgradeUri, upgradeUri) || other.upgradeUri == upgradeUri)&&(identical(other.code, code) || other.code == code)&&(identical(other.authorization, authorization) || other.authorization == authorization)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.contentLanguage, contentLanguage) || other.contentLanguage == contentLanguage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,upgradeAble,upgradeUri,code,authorization,clientId,contentLanguage);

@override
String toString() {
  return 'CheckVersionResponse(upgradeAble: $upgradeAble, upgradeUri: $upgradeUri, code: $code, authorization: $authorization, clientId: $clientId, contentLanguage: $contentLanguage)';
}


}


abstract mixin class $CheckVersionResponseCopyWith<$Res>  {
  factory $CheckVersionResponseCopyWith(CheckVersionResponse value, $Res Function(CheckVersionResponse) _then) = _$CheckVersionResponseCopyWithImpl;
@useResult
$Res call({
 bool upgradeAble, String? upgradeUri, String? code, String? authorization, String? clientId, String? contentLanguage
});




}

class _$CheckVersionResponseCopyWithImpl<$Res>
    implements $CheckVersionResponseCopyWith<$Res> {
  _$CheckVersionResponseCopyWithImpl(this._self, this._then);

  final CheckVersionResponse _self;
  final $Res Function(CheckVersionResponse) _then;



@pragma('vm:prefer-inline') @override $Res call({Object? upgradeAble = null,Object? upgradeUri = freezed,Object? code = freezed,Object? authorization = freezed,Object? clientId = freezed,Object? contentLanguage = freezed,}) {
  return _then(CheckVersionResponse(
upgradeAble: null == upgradeAble ? _self.upgradeAble : upgradeAble // ignore: cast_nullable_to_non_nullable
as bool,upgradeUri: freezed == upgradeUri ? _self.upgradeUri : upgradeUri // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,authorization: freezed == authorization ? _self.authorization : authorization // ignore: cast_nullable_to_non_nullable
as String?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,contentLanguage: freezed == contentLanguage ? _self.contentLanguage : contentLanguage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



