import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_user.dart';
import '../../data/models/prayer_log.dart';
import '../../providers/providers.dart';
import 'home_widget_bridge.dart';

/// Keeps native home widgets in sync with Firestore-backed today map + profile.
class HomeWidgetSyncer extends ConsumerWidget {
  const HomeWidgetSyncer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<Map<PrayerName, PrayerLog>>>(
      todayFardMapProvider,
      (previous, next) {
        HomeWidgetBridge.syncAllWidgets(ref);
      },
    );
    ref.listen<AsyncValue<AppUser?>>(
      appUserStreamProvider,
      (previous, next) {
        HomeWidgetBridge.syncAllWidgets(ref);
      },
    );
    return const SizedBox.shrink();
  }
}
