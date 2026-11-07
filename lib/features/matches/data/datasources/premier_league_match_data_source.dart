import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../models/premier_league_match_details_model.dart';

class PremierLeagueMatchPayload {
  const PremierLeagueMatchPayload({
    this.match,
    this.events,
    this.stats,
    this.lineups,
    this.officials,
    this.commentary,
    this.failedSections = const {},
  });

  final JsonMap? match;
  final JsonMap? events;
  final dynamic stats;
  final JsonMap? lineups;
  final JsonMap? officials;
  final JsonMap? commentary;
  final Set<String> failedSections;
}

class PremierLeagueMatchDataSource {
  PremierLeagueMatchDataSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl:
                  'https://sdp-prem-prod.premier-league-prod.pulselive.com',
              connectTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  Future<PremierLeagueMatchPayload> getMatch(int id) async {
    developer.log('requesting match=$id section=match', name: 'match_details');
    final match = await _getMap('/api/v2/matches/$id');
    final sections = await Future.wait<_Section>([
      _safe('events', () => _getMap('/api/v1/matches/$id/events')),
      _safe('stats', () => _getDynamic('/api/v3/matches/$id/stats')),
      _safe('lineups', () => _getMap('/api/v3/matches/$id/lineups')),
      _safe('officials', () => _getMap('/api/v1/matches/$id/officials')),
      _safe(
        'commentary',
        () => _getMap(
          '/api/v1/matches/$id/commentary',
          query: {'_limit': 20, '_sort': 'timestamp:desc'},
        ),
      ),
    ]);
    return PremierLeagueMatchPayload(
      match: match,
      events: sections[0].data as JsonMap?,
      stats: sections[1].data,
      lineups: sections[2].data as JsonMap?,
      officials: sections[3].data as JsonMap?,
      commentary: sections[4].data as JsonMap?,
      failedSections:
          sections
              .where((section) => section.failed)
              .map((section) => section.name)
              .toSet(),
    );
  }

  Future<_Section> _safe<T>(String name, Future<T> Function() load) async {
    developer.log('requesting section=$name', name: 'match_details');
    try {
      final value = await load();
      developer.log('section=$name accepted', name: 'match_details');
      return _Section(name, value, false);
    } catch (error, stackTrace) {
      developer.log(
        'section=$name rejected: $error',
        name: 'match_details',
        error: error,
        stackTrace: stackTrace,
      );
      return _Section(name, null, true);
    }
  }

  Future<JsonMap> _getMap(String path, {Map<String, dynamic>? query}) async {
    final response = await _request(path, query: query);
    if (response.data is! Map) {
      throw const FormatException('Expected JSON object.');
    }
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<dynamic> _getDynamic(String path) async => (await _request(path)).data;

  Future<Response<dynamic>> _request(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: query);
      developer.log(
        'completed path=$path status=${response.statusCode} elapsed_ms=${stopwatch.elapsedMilliseconds}',
        name: 'match_details.http',
      );
      return response;
    } on DioException catch (error, stackTrace) {
      developer.log(
        'failed path=$path status=${error.response?.statusCode} elapsed_ms=${stopwatch.elapsedMilliseconds} type=${error.type}: ${error.message}',
        name: 'match_details.http',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (error, stackTrace) {
      developer.log(
        'request failed path=$path elapsed_ms=${stopwatch.elapsedMilliseconds}: $error',
        name: 'match_details.http',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

class _Section {
  const _Section(this.name, this.data, this.failed);
  final String name;
  final dynamic data;
  final bool failed;
}
