import 'dart:async';

import 'package:fantasy/core/network/dio_client.dart';
import 'package:fantasy/features/manager/data/repositories/manager_repository_impl.dart';
import 'package:fantasy/features/picks/data/repositories/picks_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _CountingDioClient extends DioClient {
  final requests = <String>[];
  final _pending = <Completer<Map<String, dynamic>>>[];

  @override
  Future get(String endpoint, {Map<String, dynamic>? queryParams}) {
    final identity = '$endpoint|${queryParams ?? const {}}';
    requests.add(identity);
    final completer = Completer<Map<String, dynamic>>();
    _pending.add(completer);
    return completer.future;
  }

  void completeAll(Map<String, dynamic> response) {
    for (final completer in _pending) {
      if (!completer.isCompleted) completer.complete(response);
    }
    _pending.clear();
  }
}

void main() {
  test(
    'concurrent identical Manager calls issue one data-source request',
    () async {
      final dio = _CountingDioClient();
      final repository = ManagerRepositoryImpl(dio);
      final first = repository.getManager(123);
      final same = repository.getManager(123);
      await Future<void>.delayed(Duration.zero);
      expect(dio.requests, ['/entry/123/|{}']);
      dio.completeAll(const {});
      await Future.wait([first, same]);

      final retry = repository.getManager(123);
      await Future<void>.delayed(Duration.zero);
      expect(dio.requests, ['/entry/123/|{}', '/entry/123/|{}']);
      dio.completeAll(const {});
      await retry;
    },
  );

  test('different Manager IDs do not share in-flight requests', () async {
    final dio = _CountingDioClient();
    final repository = ManagerRepositoryImpl(dio);
    final first = repository.getManager(123);
    final other = repository.getManager(456);
    await Future<void>.delayed(Duration.zero);
    expect(dio.requests, ['/entry/123/|{}', '/entry/456/|{}']);
    dio.completeAll(const {});
    await Future.wait([first, other]);
  });

  test(
    'concurrent identical Picks calls share work; different gameweeks do not',
    () async {
      final dio = _CountingDioClient();
      final repository = PicksRepositoryImpl(dio);
      final first = repository.getPicks(123, 8);
      final same = repository.getPicks(123, 8);
      final otherGameweek = repository.getPicks(123, 9);
      await Future<void>.delayed(Duration.zero);
      expect(dio.requests, [
        '/entry/123/event/8/picks/|{}',
        '/entry/123/event/9/picks/|{}',
      ]);
      dio.completeAll(const {});
      await Future.wait([first, same, otherGameweek]);
    },
  );
}
