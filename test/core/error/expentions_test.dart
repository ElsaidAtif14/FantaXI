import 'package:dio/dio.dart';
import 'package:fantasy/core/error/expentions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('handleDioException', () {
    test('provides a helpful message for connection errors', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionError,
      );

      expect(
        () => handleDioException(exception),
        throwsA(
          isA<ConnectionErrorException>()
              .having(
                (error) => error.errorModel.errorMessage,
                'error message',
                'تعذر الاتصال بالإنترنت. تحقق من اتصالك ثم حاول مرة أخرى.',
              )
              .having(
                (error) => error.toString(),
                'toString',
                'تعذر الاتصال بالإنترنت. تحقق من اتصالك ثم حاول مرة أخرى.',
              ),
        ),
      );
    });
  });
}
