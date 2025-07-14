




part of '../mill.dart';


abstract class ImportResponse {}

class ImportFormatException extends FormatException {
  const ImportFormatException([String? source, int? offset])
      : super(source ?? "Cannot import", null, offset);

  @override
  String toString() {

    return message;
  }
}
