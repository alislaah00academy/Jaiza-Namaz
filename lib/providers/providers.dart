// Riverpod wiring for Firebase services and Firestore streams.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/prayer_catalog.dart';
import '../core/utils/date_utils.dart';
import '../data/models/app_user.dart';
import '../data/models/child_profile.dart';
import '../data/models/organization.dart';
import '../data/models/prayer_log.dart';
import '../features/settings/data/prayer_settings.dart';
import '../data/models/streak_stats.dart';
import '../data/models/user_role.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/children_repository.dart';
import '../data/repositories/organization_repository.dart';
import '../data/repositories/prayer_repository.dart';
import '../data/repositories/streak_repository.dart';
import '../data/repositories/user_repository.dart';
import '../services/location_service.dart';
import '../services/prayer_times_service.dart';
import '../features/onboarding/data/onboarding_repository.dart';

/// Onboarding repository — overridden in `main()` with a ready
/// [OnboardingRepository] (its SharedPreferences is loaded before runApp so
/// the splash/router can read the flag synchronously).
final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

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

/// Effective prayer widget + notification settings (defaults when missing).
final prayerSettingsProvider = Provider<PrayerSettingsParsed>((ref) {
  return ref.watch(appUserStreamProvider).valueOrNull?.prayerSettingsParsed ??
      PrayerSettingsParsed.defaults();
});

/// Today's computed prayer schedule + which Fard window is active right
/// now (same GPS/manual-location resolution used by the home-screen
/// widgets in [HomeWidgetBridge]). Re-fetch via `ref.invalidate` to refresh
/// the "current prayer" countdown.
final currentPrayerCardProvider =
    FutureProvider.autoDispose<
      ({DailyPrayerSchedule today, PrayerWindowStatus status})
    >((ref) async {
      final settings = ref.watch(prayerSettingsProvider);

      double lat;
      double lon;
      if (settings.useGps) {
        final pos = await LocationService.getCurrentPosition();
        if (pos != null) {
          lat = pos.lat;
          lon = pos.lon;
        } else {
          final cached = await LocationService.readCachedCoords();
          lat = cached?.lat ?? settings.manualLat;
          lon = cached?.lon ?? settings.manualLon;
        }
      } else {
        lat = settings.manualLat;
        lon = settings.manualLon;
      }

      final now = DateTime.now();
      final base = DateTime(now.year, now.month, now.day);
      final today = PrayerTimesService.forLocalDay(
        localDay: base,
        latitude: lat,
        longitude: lon,
        settings: settings,
      );
      final tomorrow = PrayerTimesService.forLocalDay(
        localDay: base.add(const Duration(days: 1)),
        latitude: lat,
        longitude: lon,
        settings: settings,
      );
      final status = PrayerTimesService.currentWindowStatus(
        now: now,
        today: today,
        tomorrow: tomorrow,
      );
      return (today: today, status: status);
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

/// All Fard prayer logs for the signed-in user (for calendar / history).
final userFardLogsProvider = StreamProvider<List<PrayerLog>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) {
    return Stream.value([]);
  }
  return ref.watch(prayerRepositoryProvider).watchAllFard(uid);
});

/// Fard logs mapped by [PrayerName] for a single local calendar day.
final fardMapForDateProvider =
    Provider.family<Map<PrayerName, PrayerLog>, DateTime>((ref, day) {
      final logs = ref.watch(userFardLogsProvider).valueOrNull ?? [];
      final key = AppDateUtils.localDateKey(day);
      final map = <PrayerName, PrayerLog>{};
      for (final log in logs) {
        if (AppDateUtils.localDateKey(log.dateTime) == key) {
          map[log.prayerName] = log;
        }
      }
      return map;
    });

/// Local date keys in [focusedMonth] where every Fard prayer was recorded completed.
final fullFardDayKeysForMonthProvider = Provider.family<Set<String>, DateTime>((
  ref,
  focusedMonth,
) {
  final logs = ref.watch(userFardLogsProvider).valueOrNull ?? [];
  final y = focusedMonth.year;
  final m = focusedMonth.month;
  final byDay = <String, Map<PrayerName, PrayerStatus>>{};
  for (final log in logs) {
    final ld = log.dateTime.toLocal();
    if (ld.year != y || ld.month != m) continue;
    final dk = AppDateUtils.localDateKey(ld);
    byDay.putIfAbsent(dk, () => {});
    byDay[dk]![log.prayerName] = log.status;
  }
  final full = <String>{};
  for (final e in byDay.entries) {
    var ok = true;
    for (final def in kFardPrayerDefs) {
      if (e.value[def.name] != PrayerStatus.completed) ok = false;
    }
    if (ok) full.add(e.key);
  }
  return full;
});

final todayNawafilProvider = StreamProvider<List<PrayerLog>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) {
    return const Stream<List<PrayerLog>>.empty();
  }
  return ref.watch(prayerRepositoryProvider).watchTodayNawafil(uid);
});

/// All Nawafil/Qaza prayer logs for the signed-in user — same shape as
/// [userFardLogsProvider], for the unified History screen.
final userNawafilLogsProvider = StreamProvider<List<PrayerLog>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value([]);
  return ref
      .watch(prayerRepositoryProvider)
      .watchAllByType(uid, PrayerType.nawafil);
});

final userQazaLogsProvider = StreamProvider<List<PrayerLog>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value([]);
  return ref
      .watch(prayerRepositoryProvider)
      .watchAllByType(uid, PrayerType.qaza);
});

/// Nawafil logs mapped by [PrayerName] for a single local calendar day.
final nawafilMapForDateProvider =
    Provider.family<Map<PrayerName, PrayerLog>, DateTime>((ref, day) {
      final logs = ref.watch(userNawafilLogsProvider).valueOrNull ?? [];
      final key = AppDateUtils.localDateKey(day);
      final map = <PrayerName, PrayerLog>{};
      for (final log in logs) {
        if (AppDateUtils.localDateKey(log.dateTime) == key) {
          map[log.prayerName] = log;
        }
      }
      return map;
    });

/// Qaza logs for a single local calendar day (no per-name slot — qaza is
/// open-ended, so this is just the list of that day's qaza entries).
final qazaLogsForDateProvider = Provider.family<List<PrayerLog>, DateTime>((
  ref,
  day,
) {
  final logs = ref.watch(userQazaLogsProvider).valueOrNull ?? [];
  final key = AppDateUtils.localDateKey(day);
  return logs
      .where((log) => AppDateUtils.localDateKey(log.dateTime) == key)
      .toList();
});

/// All-time completed-Qaza count for one specific Fard prayer name (e.g.
/// how many Qaza Fajr instances this user has logged as made up).
final qazaCompletedForProvider = Provider.family<int, PrayerName>((ref, name) {
  final logs = ref.watch(userQazaLogsProvider).valueOrNull ?? [];
  return logs
      .where(
        (log) => log.prayerName == name && log.status == PrayerStatus.completed,
      )
      .length;
});

/// Today's completed-Qaza count for one specific Fard prayer name.
final qazaTodayCountForProvider = Provider.family<int, PrayerName>((ref, name) {
  final logs = ref.watch(userQazaLogsProvider).valueOrNull ?? [];
  final todayKey = AppDateUtils.localDateKey(DateTime.now());
  return logs
      .where(
        (log) =>
            log.prayerName == name &&
            log.status == PrayerStatus.completed &&
            AppDateUtils.localDateKey(log.dateTime) == todayKey,
      )
      .length;
});

// ---------------------------------------------------------------------------
// Role selection (Individual / Parent / Organization)
// ---------------------------------------------------------------------------

/// Account type of the signed-in user; `null` until they pick one.
final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(appUserStreamProvider).valueOrNull?.role;
});

/// True once signed in and no role has been chosen yet (legacy users included).
final needsRoleSelectionProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null &&
      ref.watch(userRoleProvider) == null;
});

// ---------------------------------------------------------------------------
// Parent role
// ---------------------------------------------------------------------------

final childrenRepositoryProvider = Provider<ChildrenRepository>(
  (ref) => ChildrenRepository(ref.watch(firestoreProvider)),
);

final childrenStreamProvider = StreamProvider<List<ChildProfile>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return const Stream<List<ChildProfile>>.empty();
  return ref.watch(childrenRepositoryProvider).watchChildren(uid);
});

/// Currently selected child on the Parent dashboard (null = none picked yet).
final selectedChildIdProvider = StateProvider<String?>((ref) => null);

/// Today's Fard logs for one child, scoped by passing [childId] as the
/// `userId` of the existing flat `prayers` collection (see [PrayerRepository]).
final childTodayFardMapProvider =
    StreamProvider.family<Map<PrayerName, PrayerLog>, String>((ref, childId) {
      return ref.watch(prayerRepositoryProvider).watchTodayFard(childId);
    });

final childAllFardProvider = StreamProvider.family<List<PrayerLog>, String>((
  ref,
  childId,
) {
  return ref.watch(prayerRepositoryProvider).watchAllFard(childId);
});

final childFardMapForDateProvider =
    Provider.family<
      Map<PrayerName, PrayerLog>,
      ({String childId, DateTime day})
    >((ref, args) {
      final logs =
          ref.watch(childAllFardProvider(args.childId)).valueOrNull ?? [];
      final key = AppDateUtils.localDateKey(args.day);
      final map = <PrayerName, PrayerLog>{};
      for (final log in logs) {
        if (AppDateUtils.localDateKey(log.dateTime) == key) {
          map[log.prayerName] = log;
        }
      }
      return map;
    });

// ---------------------------------------------------------------------------
// Organization role
// ---------------------------------------------------------------------------

final organizationRepositoryProvider = Provider<OrganizationRepository>(
  (ref) => OrganizationRepository(ref.watch(firestoreProvider)),
);

/// The org this uid administers, if any.
final myOrgProvider = StreamProvider<Organization?>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return const Stream<Organization?>.empty();
  return ref.watch(organizationRepositoryProvider).watchOrgForAdmin(uid);
});

/// The org this uid teaches under, if any (resolved via AppUser.orgId).
final myTeacherMembershipProvider = StreamProvider<TeacherMembership?>((ref) {
  final user = ref.watch(appUserStreamProvider).valueOrNull;
  final uid = user?.uid;
  final orgId = user?.orgId;
  if (uid == null || orgId == null) {
    return const Stream<TeacherMembership?>.empty();
  }
  return ref
      .watch(organizationRepositoryProvider)
      .watchTeacherMembership(orgId: orgId, uid: uid);
});

final classesForTeacherProvider = StreamProvider<List<SchoolClass>>((ref) {
  final user = ref.watch(appUserStreamProvider).valueOrNull;
  final uid = user?.uid;
  final orgId = user?.orgId;
  if (uid == null || orgId == null) {
    return const Stream<List<SchoolClass>>.empty();
  }
  return ref
      .watch(organizationRepositoryProvider)
      .watchClassesForTeacher(orgId: orgId, teacherUid: uid);
});

final selectedClassIdProvider = StateProvider<String?>((ref) => null);

final studentsForClassProvider =
    StreamProvider.family<List<Student>, ({String orgId, String classId})>((
      ref,
      args,
    ) {
      return ref
          .watch(organizationRepositoryProvider)
          .watchStudentsForClass(orgId: args.orgId, classId: args.classId);
    });

/// Admin-only aggregate views.
final allTeachersForOrgProvider =
    StreamProvider.family<List<TeacherMembership>, String>((ref, orgId) {
      return ref.watch(organizationRepositoryProvider).watchTeachers(orgId);
    });

final allClassesForOrgProvider =
    StreamProvider.family<List<SchoolClass>, String>((ref, orgId) {
      return ref
          .watch(organizationRepositoryProvider)
          .watchAllClassesForOrg(orgId);
    });

final studentTodayFardMapProvider =
    StreamProvider.family<Map<PrayerName, PrayerLog>, String>((ref, studentId) {
      return ref.watch(prayerRepositoryProvider).watchTodayFard(studentId);
    });
