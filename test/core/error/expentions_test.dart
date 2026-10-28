import 'package:dio/dio.dart';
import 'package:fantasy/core/error/expentions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('handleDioException', () {
    test('provides the English connection message used by the app', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionError,
      );

      expect(
        () => handleDioException(exception),
        throwsA(
          isA<ConnectionErrorException>().having(
            (error) => error.errorModel.errorMessage,
            'error message',
            'Unable to connect to the internet. Check your connection and try again.',
          ),
        ),
      );
    });

    test('maps connection timeouts without losing the transport message', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
        message: 'timed out',
      );

      expect(
        () => handleDioException(exception),
        throwsA(isA<ConnectionTimeoutException>()),
      );
    });

    test('maps server response status and message', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 503,
          data: {'detail': 'Unavailable', 'status': 503},
        ),
      );

      expect(
        () => handleDioException(exception),
        throwsA(
          isA<ServerException>().having(
            (e) => e.toString(),
            'message',
            'Unavailable',
          ),
        ),
      );
    });

    test('maps unexpected transport errors', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.unknown,
        message: 'unexpected',
      );

      expect(
        () => handleDioException(exception),
        throwsA(
          isA<UnknownException>().having(
            (e) => e.toString(),
            'message',
            'unexpected',
          ),
        ),
      );
    });
  });
}
