import 'dart:async';

import 'package:fantasy/core/network/successful_request_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reuses successful values until TTL expiry', () async {
    var now = DateTime(2026, 1, 1);
    var requests = 0;
    final cache = SuccessfulRequestCache<String, int>(
      ttl: const Duration(minutes: 5),
      clock: () => now,
    );
    Future<int> load() async => ++requests;

    expect(await cache.get('bootstrap', load), 1);
    expect(await cache.get('bootstrap', load), 1);
    expect(requests, 1);
    now = now.add(const Duration(minutes: 6));
    expect(await cache.get('bootstrap', load), 2);
    expect(requests, 2);
  });

  test('shares concurrent loads by key and isolates different keys', () async {
    final cache = SuccessfulRequestCache<(int, int), int>(
      ttl: const Duration(seconds: 20),
    );
    final first = Completer<int>();
    var firstRequests = 0;
    var otherRequests = 0;
    Future<int> loadFirst() {
      firstRequests++;
      return first.future;
    }

    final one = cache.get((9, 3), loadFirst);
    final same = cache.get((9, 3), loadFirst);
    final other = cache.get((9, 4), () async => ++otherRequests);
    expect(await other, 1);
    expect(firstRequests, 1);
    first.complete(42);
    expect(await Future.wait([one, same]), [42, 42]);
    expect(firstRequests, 1);
    expect(cache.inFlightCount, 0);
  });

  test(
    'refresh bypasses completed cache and shares an equivalent in-flight load',
    () async {
      final cache = SuccessfulRequestCache<String, int>(
        ttl: const Duration(minutes: 5),
      );
      var requests = 0;
      Future<int> load() async => ++requests;
      expect(await cache.get('key', load), 1);
      expect(await cache.get('key', load, refresh: true), 2);
      expect(requests, 2);

      final pending = Completer<int>();
      final first = cache.get('key', () => pending.future, refresh: true);
      final second = cache.get('key', load, refresh: true);
      pending.complete(3);
      expect(await Future.wait([first, second]), [3, 3]);
      expect(requests, 2);
    },
  );

  test('failed load is removed and may be retried', () async {
    final cache = SuccessfulRequestCache<String, int>(
      ttl: const Duration(minutes: 5),
    );
    var requests = 0;
    Future<int> load() async {
      requests++;
      if (requests == 1) throw StateError('failure');
      return 7;
    }

    await expectLater(cache.get('key', load), throwsStateError);
    expect(cache.inFlightCount, 0);
    expect(cache.cachedCount, 0);
    expect(await cache.get('key', load), 7);
    expect(requests, 2);
  });

  test('invalidation clears completed values', () async {
    final cache = SuccessfulRequestCache<int, int>(
      ttl: const Duration(minutes: 5),
    );
    var requests = 0;
    Future<int> load() async => ++requests;
    await cache.get(1, load);
    cache.invalidate(1);
    await cache.get(1, load);
    expect(requests, 2);
  });
}
