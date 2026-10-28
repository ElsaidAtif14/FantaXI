import 'package:fantasy/core/error/error_model.dart';
import 'package:fantasy/core/error/expentions.dart';
import 'package:fantasy/core/network/dio_client.dart';
import 'package:fantasy/features/matches/data/repositories/matches_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads and parses the requested matchweek fixtures', () async {
    final client = _FakeDioClient([
      {
        'id': 15,
        'event': 3,
        'team_h': 1,
        'team_a': 2,
        'team_h_score': 2,
        'team_a_score': 1,
        'finished': true,
        'started': true,
      },
    ]);
    final repository = MatchesRepositoryImpl(client);

    final result = await repository.getFixtures(3);

    expect(result.isRight(), isTrue);
    expect(result.getOrElse(() => []).single.id, 15);
    expect(client.lastQuery, {'event': 3});
  });

  test('returns repository failure for API errors', () async {
    final client = _FakeDioClient.failure();
    final repository = MatchesRepositoryImpl(client);

    final result = await repository.getFixtures(3);

    expect(
      result.fold((failure) => failure.errMessage, (_) => ''),
      'Unavailable',
    );
  });
}

class _FakeDioClient extends DioClient {
  _FakeDioClient(this.response);

  _FakeDioClient.failure() : response = null;

  final List<Map<String, dynamic>>? response;
  Map<String, dynamic>? lastQuery;

  @override
  Future<List<Map<String, dynamic>>> getList(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    lastQuery = queryParams;
    if (response == null) {
      throw ServerException(
        ErrorModel(status: 503, errorMessage: 'Unavailable'),
      );
    }
    return response!;
  }
}
