import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../utilities/crypto_utils.dart';

part 'register_data.freezed.dart';
part 'register_data.g.dart';

@freezed
@JsonSerializable()
class RegisterData with _$RegisterData {
  String? invitationCode;
  String? deviceId;

  RegisterData({this.invitationCode, this.deviceId});

  factory RegisterData.fromJson(Map<String, dynamic> json) => _$RegisterDataFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterDataToJson(this);

  String encrypt() {

    final jsonString = json.encode(toJson());


    return CryptoUtils().encrypt(jsonString);
  }
}
