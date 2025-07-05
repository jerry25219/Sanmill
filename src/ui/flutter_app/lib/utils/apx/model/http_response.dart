import 'package:freezed_annotation/freezed_annotation.dart';

part 'http_response.freezed.dart';
part 'http_response.g.dart';

@freezed
@JsonSerializable()
class HttpResponse with _$HttpResponse {
  final int code;
  final String? msg;
  final String? detail;
  final String? rq;
  final dynamic data;

  HttpResponse({required this.code, this.msg, this.detail, this.rq, this.data});
  factory HttpResponse.fromJson(Map<String, dynamic> json) => _$HttpResponseFromJson(json);
}
