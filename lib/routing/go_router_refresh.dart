import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a Bloc/Cubit [Stream] to a [Listenable] so GoRouter re-evaluates
/// redirects when auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
