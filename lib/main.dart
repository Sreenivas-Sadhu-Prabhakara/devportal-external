import 'package:flutter/material.dart';

import 'app.dart';
import 'di/app_dependencies.dart';

void main() {
  final deps = AppDependencies.bootstrap();
  runApp(DevPortalApp(deps: deps));
}
