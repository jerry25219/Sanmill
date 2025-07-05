import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_version_parameter.freezed.dart';
part 'check_version_parameter.g.dart';

@freezed
@JsonSerializable()
class CheckVersionParameter with _$CheckVersionParameter {
  final String appId;
  final String deviceType;
  final String deviceOs;
  final String appVersion;
  final String appBuildNumber;

  const CheckVersionParameter({required this.appId, required this.deviceType, required this.deviceOs, required this.appVersion, required this.appBuildNumber});

  factory CheckVersionParameter.fromJson(Map<String, dynamic> json) => _$CheckVersionParameterFromJson(json);
  Map<String, dynamic> toJson() => _$CheckVersionParameterToJson(this);
}
