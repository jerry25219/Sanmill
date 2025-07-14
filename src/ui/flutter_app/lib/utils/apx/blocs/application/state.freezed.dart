





part of 'state.dart';






T _$identity<T>(T value) => value;

mixin _$ApplicationErrorState {

 String get error;


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


abstract mixin class $ApplicationErrorStateCopyWith<$Res>  {
  factory $ApplicationErrorStateCopyWith(ApplicationErrorState value, $Res Function(ApplicationErrorState) _then) = _$ApplicationErrorStateCopyWithImpl;
@useResult
$Res call({
 String error
});




}

class _$ApplicationErrorStateCopyWithImpl<$Res>
    implements $ApplicationErrorStateCopyWith<$Res> {
  _$ApplicationErrorStateCopyWithImpl(this._self, this._then);

  final ApplicationErrorState _self;
  final $Res Function(ApplicationErrorState) _then;



@pragma('vm:prefer-inline') @override $Res call({Object? error = null,}) {
  return _then(ApplicationErrorState(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}



mixin _$ApplicationReadyState {

 List<String>? get domains;


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


abstract mixin class $ApplicationReadyStateCopyWith<$Res>  {
  factory $ApplicationReadyStateCopyWith(ApplicationReadyState value, $Res Function(ApplicationReadyState) _then) = _$ApplicationReadyStateCopyWithImpl;
@useResult
$Res call({
 List<String>? domains
});




}

class _$ApplicationReadyStateCopyWithImpl<$Res>
    implements $ApplicationReadyStateCopyWith<$Res> {
  _$ApplicationReadyStateCopyWithImpl(this._self, this._then);

  final ApplicationReadyState _self;
  final $Res Function(ApplicationReadyState) _then;



@pragma('vm:prefer-inline') @override $Res call({Object? domains = freezed,}) {
  return _then(ApplicationReadyState(
domains: freezed == domains ? _self.domains : domains // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}



