
import 'package:freezed_annotation/freezed_annotation.dart';

import 'domains.dart';

part 'register_result.freezed.dart';
part 'register_result.g.dart';

@freezed
abstract class RegisterResult with _$RegisterResult {
  const factory RegisterResult({required Domains domains, required bool succeed}) = _RegisterResult;

  factory RegisterResult.fromJson(Map<String, dynamic> json) => _$RegisterResultFromJson(json);
}
