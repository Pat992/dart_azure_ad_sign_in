import 'package:dart_azure_ad_sign_in/src/domain/entities/http_server_entity.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/models/http_server_model.dart';
import 'package:test/test.dart';

void main() {
  final HttpServerModel httpServerModel = HttpServerModel(
    code: '123456',
    status: 0,
    error: '',
    errorDescription: '',
    errorUri: '',
  );

  test('Model is subclass of Http Server entity', () {
    // arrange
    // act
    // assert
    expect(httpServerModel, isA<HttpServerEntity>());
  });
}
