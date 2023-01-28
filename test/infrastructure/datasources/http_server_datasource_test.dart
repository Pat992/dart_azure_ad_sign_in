import 'dart:io';

import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/http_server_datasource.dart';
import 'package:test/test.dart';

void main() {
  late HttpServerDatasource httpServerDatasource;
  late HttpClient client;

  setUp(() async {
    httpServerDatasource = HttpServerDatasource(
      port: 8080,
      serverSuccessResponse: 'success',
      serverErrorResponse: 'error',
    );
    client = HttpClient();
  });

  test('Get success in body if code has been sent in the body', () async {
    // arrange
    // act
    // assert
  });

  test('Get error in body if error has been sent in the body', () async {
    // arrange
    // act
    // assert
  });

  test('Get error in body if body is empty', () async {
    // arrange
    // act
    // assert
  });

  tearDown(() {
    client.close();
  });
}
