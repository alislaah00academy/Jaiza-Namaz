import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Remote Config (03 §architecture, 17 §7): parameters are set up here but
/// no `min_supported_build` value is pushed from the console yet — the
/// default of `0` means the gate never fires until that changes.
abstract final class RemoteConfigBootstrap {
  static Future<void> init() async {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await rc.setDefaults(const {'min_supported_build': 0});
  }

  /// Never awaited on the critical path (03 §6): offline or slow networks
  /// just keep the defaults, so this must not throw into the caller.
  static Future<void> fetchAndActivate() async {
    try {
      await FirebaseRemoteConfig.instance.fetchAndActivate();
    } catch (_) {
      // Keep defaults; try again on the next cold start.
    }
  }

  static int get minSupportedBuild =>
      FirebaseRemoteConfig.instance.getInt('min_supported_build');
}
