import 'package:freezed_annotation/freezed_annotation.dart';

part 'events.freezed.dart';

sealed class ApplicationEvent {
  const ApplicationEvent();
}

@freezed
class ApplicationBeginRegisterEvent extends ApplicationEvent with _$ApplicationBeginRegisterEvent {
  final String? invitationCode;

  ApplicationBeginRegisterEvent({this.invitationCode});
}

@freezed
class ApplicationBeginAuthenticateEvent extends ApplicationEvent with _$ApplicationBeginAuthenticateEvent {
  final String userId;
  final String password;

  ApplicationBeginAuthenticateEvent({required this.userId, required this.password});
}
