import 'dart:async';

import 'package:flutter/foundation.dart';

/// Notifies [GoRouter] when [stream] emits (e.g. Firebase [User.reload]).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscriptions = [stream.listen((_) => notifyListeners())];
  }

  /// Notifies on any emission from any of [streams] (e.g. auth changes plus
  /// the signed-in user's Firestore profile, so role-selection redirects
  /// fire as soon as a role is written).
  GoRouterRefreshStream.merged(List<Stream<dynamic>> streams) {
    notifyListeners();
    _subscriptions =
        streams.map((s) => s.listen((_) => notifyListeners())).toList();
  }

  late final List<StreamSubscription<dynamic>> _subscriptions;

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
