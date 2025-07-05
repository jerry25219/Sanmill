// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'http_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HttpResponse {

 int get code; String? get msg; String? get detail; String? get rq; dynamic get data;
/// Create a copy of HttpResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HttpResponseCopyWith<HttpResponse> get copyWith => _$HttpResponseCopyWithImpl<HttpResponse>(this as HttpResponse, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HttpResponse&&(identical(other.code, code) || other.code == code)&&(identical(other.msg, msg) || other.msg == msg)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.rq, rq) || other.rq == rq)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,msg,detail,rq,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'HttpResponse(code: $code, msg: $msg, detail: $detail, rq: $rq, data: $data)';
}


}

/// @nodoc
abstract mixin class $HttpResponseCopyWith<$Res>  {
  factory $HttpResponseCopyWith(HttpResponse value, $Res Function(HttpResponse) _then) = _$HttpResponseCopyWithImpl;
@useResult
$Res call({
 int code, String? msg, String? detail, String? rq, dynamic data
});




}
/// @nodoc
class _$HttpResponseCopyWithImpl<$Res>
    implements $HttpResponseCopyWith<$Res> {
  _$HttpResponseCopyWithImpl(this._self, this._then);

  final HttpResponse _self;
  final $Res Function(HttpResponse) _then;

/// Create a copy of HttpResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? msg = freezed,Object? detail = freezed,Object? rq = freezed,Object? data = freezed,}) {
  return _then(HttpResponse(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,rq: freezed == rq ? _self.rq : rq // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


// dart format on
