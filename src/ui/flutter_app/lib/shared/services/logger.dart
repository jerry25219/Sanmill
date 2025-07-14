




import 'package:logger/logger.dart';

import 'environment_config.dart';

final Logger logger = Logger(level: Level.values[EnvironmentConfig.logLevel]);
