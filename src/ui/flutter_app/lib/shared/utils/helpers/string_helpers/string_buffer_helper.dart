




import '../../../database/database.dart';




extension CustomStringBuffer on StringBuffer {
  void writeComma([Object? content = ""]) =>
      writeln(DB().generalSettings.screenReaderSupport ? "$content," : content);

  void writePeriod([Object? content = ""]) =>
      writeln(DB().generalSettings.screenReaderSupport ? "$content." : content);

  void writeSpace([Object? content = ""]) => write("$content ");



  void writeNumber(int number) => write(number < 10 ? " $number." : "$number.");
}
