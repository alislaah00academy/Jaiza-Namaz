// Riverpod wiring for Firebase services and Firestore streams.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_user.dart';
import '../data/models/prayer_log.dart';
import '../data/models/streak_stats.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/prayer_repository.dart';
import '../data/repositories/streak_repository.dart';
import '../data/repositories/user_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(firebaseAuthProvider)),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(firestoreProvider)),
);

final streakRepositoryProvider = Provider<StreakRepository>(
  (ref) => StreakRepository(ref.watch(firestoreProvider)),
);

final prayerRepositoryProvider = Provider<PrayerRepository>(
  (ref) => PrayerRepository(
    ref.watch(firestoreProvider),
    streakRepository: ref.watch(streakRepositoryProvider),
  ),
);

/// Emits on profile/token/user changes so email verification updates UI.
final authUserStreamProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).userChanges(),
);

final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authUserStreamProvider).valueOrNull,
);

final appUserStreamProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) {
    return const Stream<AppUser?>.empty();
  }
  return ref.watch(userRepositoryProvider).watchUser(uid);
});

final streakStreamProvider = StreamProvider<StreakStats?>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) {
    return const Stream<StreakStats?>.empty();
  }
  return ref.watch(streakRepositoryProvider).watchStreaks(uid);
});

final todayFardMapProvider = StreamProvider<Map<PrayerName, PrayerLog>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) {
    return const Stream<Map<PrayerName, PrayerLog>>.empty();
  }
  return ref.watch(prayerRepositoryProvider).watchTodayFard(uid);
});

final todayNawafilProvider = StreamProvider<List<PrayerLog>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) {
    return const Stream<List<PrayerLog>>.empty();
  }
  return ref.watch(prayerRepositoryProvider).watchTodayNawafil(uid);
});
