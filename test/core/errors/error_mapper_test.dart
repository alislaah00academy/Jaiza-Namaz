import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaiza_namaz/core/errors/error_mapper.dart';

void main() {
  test('unwrapError returns the error a provider threw', () async {
    final failing = FutureProvider<int>((ref) => throw StateError('boom'));
    final container = ProviderContainer.test(retry: (_, _) => null);
    final error = await container
        .read(failing.future)
        .then<Object?>((_) => null, onError: (Object e) => e);
    expect(unwrapError(error!), isA<StateError>());
  });

  group('providerRetry', () {
    test('backs off 1s, 2s, 4s, then stops', () {
      final e = Exception('flaky');
      expect(providerRetry(0, e), const Duration(seconds: 1));
      expect(providerRetry(1, e), const Duration(seconds: 2));
      expect(providerRetry(2, e), const Duration(seconds: 4));
      expect(providerRetry(3, e), isNull);
    });

    test('never retries permission-denied', () {
      final e = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
      expect(providerRetry(0, e), isNull);
    });

    test('retries transient Firebase errors', () {
      final e = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
      );
      expect(providerRetry(0, e), const Duration(seconds: 1));
    });
  });
}
