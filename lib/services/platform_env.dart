/// `FLUTTER_TEST` detection that also compiles on web.
library;

export 'platform_env_stub.dart' if (dart.library.io) 'platform_env_io.dart';
