







class EnvironmentConfig {
  const EnvironmentConfig._();


  static bool test = const bool.fromEnvironment('test');


  static bool devMode = const bool.fromEnvironment('dev_mode');


  static bool devModeAsan = const bool.fromEnvironment('DEV_MODE');



  static bool catcher =
      const bool.fromEnvironment("catcher", defaultValue: true);



  static const int logLevel = int.fromEnvironment("log_level", defaultValue: 4);
}
