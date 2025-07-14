

import 'package:freezed_annotation/freezed_annotation.dart';

part 'domains.freezed.dart';
part 'domains.g.dart';

@freezed
sealed class Domains with _$Domains {
  const factory Domains({required List<String> platform, required String android, required String ios}) = _Domains;

  factory Domains.fromJson(Map<String, dynamic> json) => _$DomainsFromJson(json);
}
