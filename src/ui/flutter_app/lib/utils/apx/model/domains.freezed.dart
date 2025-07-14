





part of 'domains.dart';






T _$identity<T>(T value) => value;


mixin _$Domains {

 List<String> get platform; String get android; String get ios;


@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainsCopyWith<Domains> get copyWith => _$DomainsCopyWithImpl<Domains>(this as Domains, _$identity);


  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Domains&&const DeepCollectionEquality().equals(other.platform, platform)&&(identical(other.android, android) || other.android == android)&&(identical(other.ios, ios) || other.ios == ios));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(platform),android,ios);

@override
String toString() {
  return 'Domains(platform: $platform, android: $android, ios: $ios)';
}


}


abstract mixin class $DomainsCopyWith<$Res>  {
  factory $DomainsCopyWith(Domains value, $Res Function(Domains) _then) = _$DomainsCopyWithImpl;
@useResult
$Res call({
 List<String> platform, String android, String ios
});




}

class _$DomainsCopyWithImpl<$Res>
    implements $DomainsCopyWith<$Res> {
  _$DomainsCopyWithImpl(this._self, this._then);

  final Domains _self;
  final $Res Function(Domains) _then;



@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? android = null,Object? ios = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as List<String>,android: null == android ? _self.android : android // ignore: cast_nullable_to_non_nullable
as String,ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}



@JsonSerializable()

class _Domains implements Domains {
  const _Domains({required final  List<String> platform, required this.android, required this.ios}): _platform = platform;
  factory _Domains.fromJson(Map<String, dynamic> json) => _$DomainsFromJson(json);

 final  List<String> _platform;
@override List<String> get platform {
  if (_platform is EqualUnmodifiableListView) return _platform;

  return EqualUnmodifiableListView(_platform);
}

@override final  String android;
@override final  String ios;



@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainsCopyWith<_Domains> get copyWith => __$DomainsCopyWithImpl<_Domains>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Domains&&const DeepCollectionEquality().equals(other._platform, _platform)&&(identical(other.android, android) || other.android == android)&&(identical(other.ios, ios) || other.ios == ios));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_platform),android,ios);

@override
String toString() {
  return 'Domains(platform: $platform, android: $android, ios: $ios)';
}


}


abstract mixin class _$DomainsCopyWith<$Res> implements $DomainsCopyWith<$Res> {
  factory _$DomainsCopyWith(_Domains value, $Res Function(_Domains) _then) = __$DomainsCopyWithImpl;
@override @useResult
$Res call({
 List<String> platform, String android, String ios
});




}

class __$DomainsCopyWithImpl<$Res>
    implements _$DomainsCopyWith<$Res> {
  __$DomainsCopyWithImpl(this._self, this._then);

  final _Domains _self;
  final $Res Function(_Domains) _then;



@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? android = null,Object? ios = null,}) {
  return _then(_Domains(
platform: null == platform ? _self._platform : platform // ignore: cast_nullable_to_non_nullable
as List<String>,android: null == android ? _self.android : android // ignore: cast_nullable_to_non_nullable
as String,ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


