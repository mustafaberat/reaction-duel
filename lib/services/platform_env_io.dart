import 'dart:io' show Platform;

final bool isFlutterTest = Platform.environment.containsKey('FLUTTER_TEST');
