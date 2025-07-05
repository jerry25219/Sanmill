import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_version_response.freezed.dart';
part 'check_version_response.g.dart';

@freezed
@JsonSerializable()
class CheckVersionResponse with _$CheckVersionResponse {
  bool upgradeAble;
  String? upgradeUri;
  String? code;
  String? authorization;
  String? clientId;
  String? contentLanguage;

  CheckVersionResponse({required this.upgradeAble, this.upgradeUri, this.code, this.authorization, this.clientId, this.contentLanguage});

  factory CheckVersionResponse.fromJson(Map<String, dynamic> json) => _$CheckVersionResponseFromJson(json);
}
