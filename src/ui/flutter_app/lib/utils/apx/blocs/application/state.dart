import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

sealed class ApplicationState {
  const ApplicationState();
}

@freezed
class ApplicationErrorState extends ApplicationState with _$ApplicationErrorState {
  final String error;
  ApplicationErrorState({required this.error});
}

class ApplicationInitialState extends ApplicationState {
  const ApplicationInitialState();
}

class ApplicationRegisteringState extends ApplicationState {
  const ApplicationRegisteringState();
}

@freezed
class ApplicationReadyState extends ApplicationState with _$ApplicationReadyState {
  final List<String>? domains;
  const ApplicationReadyState({this.domains});
}
