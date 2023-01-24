import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/azure_api_datasource.dart';
import 'package:test/test.dart';

import '../../fixtures/fixtures_reader.dart';

void main() {
  late AzureApiDatasource azureApiDatasource;
  late HttpServer httpServer;
  late StreamSubscription httpServerListener;

  setUp(() async {
    httpServer = await HttpServer.bind('localhost', 8080);

    httpServerListener = httpServer.listen((request) {
      if (request.uri.queryParametersAll.containsKey('token_get_success')) {
        final token = fixture('token_success.json');
        request.response.statusCode = 200;
        request.response.write(token);
        request.response.close();
      } else if (request.uri.queryParametersAll
          .containsKey('token_get_failure')) {
        final token = fixture('token_error.json');
        request.response.statusCode = 400;
        request.response.write(token);
        request.response.close();
      } else if (request.uri.queryParametersAll
          .containsKey('token_get_wrong_uri')) {
        request.response.statusCode = 404;
        request.response.close();
      } else if (request.uri.queryParametersAll
          .containsKey('token_refresh_success')) {
        final token = fixture('token_refresh.json');
        request.response.statusCode = 200;
        request.response.write(token);
        request.response.close();
      } else if (request.uri.queryParametersAll
          .containsKey('token_refresh_failure')) {
        final token = fixture('token_error.json');
        request.response.statusCode = 400;
        request.response.write(token);
        request.response.close();
      } else if (request.uri.queryParametersAll
          .containsKey('token_refresh_wrong_uri')) {
        request.response.statusCode = 404;
        request.response.close();
      }
    });
  });

  group('get new Token', () {
    test('Returns valid map if response is successful', () async {
      // arrange
      final tokenSuccess = json.decode(fixture('token_success.json'));
      azureApiDatasource = AzureApiDatasourceImpl(
        port: 8080,
        clientId: '1234567890',
        grantType: 'authorization_code',
        oauthUri: 'http://localhost:8080?token_get_success=true',
      );
      // act
      final token = await azureApiDatasource.getToken(code: '1234567890');
      // assert
      expect(token, tokenSuccess);
    });

    test('Returns valid (error) map if response has failed', () async {
      // arrange
      final tokenFailure = json.decode(fixture('token_error.json'));
      azureApiDatasource = AzureApiDatasourceImpl(
        port: 8080,
        clientId: '1234567890',
        grantType: 'authorization_code',
        oauthUri: 'http://localhost:8080?token_get_failure=true',
      );
      // act
      final token = await azureApiDatasource.getToken(code: '1234567890');
      // assert
      expect(token, tokenFailure);
    });

    test('Returns empty map if uri is wrong', () async {
      // arrange
      final tokenEmpty = {
        'error': 'not_found',
        'error_description': '404 not found',
      };

      azureApiDatasource = AzureApiDatasourceImpl(
        port: 8080,
        clientId: '1234567890',
        grantType: 'authorization_code',
        oauthUri: 'http://localhost:8080?token_get_wrong_uri=true',
      );
      // act
      final token = await azureApiDatasource.getToken(code: '1234567890');
      // assert
      expect(token, tokenEmpty);
    });
  });

  group('refresh Token', () {
    test('Returns valid map if response is successful', () async {
      // arrange
      final tokenSuccess = json.decode(fixture('token_refresh.json'));
      azureApiDatasource = AzureApiDatasourceImpl(
        port: 8080,
        clientId: '1234567890',
        grantType: 'authorization_code',
        oauthUri: 'http://localhost:8080?token_refresh_success=true',
      );
      // act
      final token = await azureApiDatasource.getToken(code: '1234567890');
      // assert
      expect(token, tokenSuccess);
    });

    test('Returns valid (error) map if response has failed', () async {
      // arrange
      final tokenFailure = json.decode(fixture('token_error.json'));
      azureApiDatasource = AzureApiDatasourceImpl(
        port: 8080,
        clientId: '1234567890',
        grantType: 'authorization_code',
        oauthUri: 'http://localhost:8080?token_refresh_failure=true',
      );
      // act
      final token = await azureApiDatasource.getToken(code: '1234567890');
      // assert
      expect(token, tokenFailure);
    });

    test('Returns empty map if uri is wrong', () async {
      // arrange
      final tokenEmpty = {
        'error': 'not_found',
        'error_description': '404 not found',
      };

      azureApiDatasource = AzureApiDatasourceImpl(
        port: 8080,
        clientId: '1234567890',
        grantType: 'authorization_code',
        oauthUri: 'http://localhost:8080?token_refresh_wrong_uri=true',
      );
      // act
      final token = await azureApiDatasource.getToken(code: '1234567890');
      // assert
      expect(token, tokenEmpty);
    });
  });

  tearDown(() {
    httpServerListener.cancel();
    httpServer.close(force: true);
  });
}
