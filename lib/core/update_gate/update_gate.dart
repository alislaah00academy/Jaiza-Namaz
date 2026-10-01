import 'package:flutter_riverpod/flutter_riverpod.dart';
// TODO(riverpod3): migrate off legacy providers (04 §8 step 3).
import 'package:flutter_riverpod/legacy.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../bootstrap/remote_config_bootstrap.dart';
import '../logging/app_log.dart';

/// True once a fetched `min_supported_build` is higher than this install's
/// build number (17 §7). Flipped from [checkUpdateGate]; the app shows a
/// blocking "Update Jaiza" screen while this is true.
final updateRequiredProvider = StateProvider<bool>((ref) => false);

/// Runs after the first frame (03 §6) — never on the startup critical path.
/// Fetch failures (offline, first run) leave [updateRequiredProvider] as is.
Future<void> checkUpdateGate(WidgetRef ref) async {
  try {
    await RemoteConfigBootstrap.fetchAndActivate();
    final minBuild = RemoteConfigBootstrap.minSupportedBuild;
    if (minBuild <= 0) return; // not configured — never gate.

    final info = await PackageInfo.fromPlatform();
    final build = int.tryParse(info.buildNumber) ?? 0;
    if (build <= 0) return; // can't tell, fail open.

    if (build < minBuild) {
      ref.read(updateRequiredProvider.notifier).state = true;
    }
  } catch (e, st) {
    appLog('checkUpdateGate', error: e, stackTrace: st);
  }
}
