import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dart_azure_ad_sign_in/src/domain/entities/token_entity.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/azure_api_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/models/token_model.dart';
import 'package:test/test.dart';

import '../../fixtures/fixtures_reader.dart';

void main() {
  late IAzureApiDatasource azureApiDatasource;
  late HttpServer httpServer;
  late StreamSubscription httpServerListener;

  setUp(() async {
    httpServer = await HttpServer.bind('localhost', 8000, shared: true);

    httpServerListener = httpServer.listen((request) async {
      try {
        if (request.uri.queryParametersAll.containsKey('token_get_success')) {
          final token = fixture('token_success.json');
          request.response.statusCode = 200;
          request.response.write(token);
          await request.response.close();
        } else if (request.uri.queryParametersAll
            .containsKey('token_get_failure')) {
          final token = fixture('token_error.json');
          request.response.statusCode = 400;
          request.response.write(token);
          await request.response.close();
        } else if (request.uri.queryParametersAll
            .containsKey('token_get_wrong_uri')) {
          request.response.statusCode = 404;
          await request.response.close();
        } else if (request.uri.queryParametersAll
            .containsKey('token_refresh_success')) {
          final token = fixture('token_refresh.json');
          request.response.statusCode = 200;
          request.response.write(token);
          await request.response.close();
        } else if (request.uri.queryParametersAll
            .containsKey('token_refresh_failure')) {
          final token = fixture('token_error.json');
          request.response.statusCode = 400;
          request.response.write(token);
          await request.response.close();
        } else if (request.uri.queryParametersAll
            .containsKey('token_refresh_wrong_uri')) {
          request.response.statusCode = 404;
          await request.response.close();
        }
      } catch (e) {
        print(e);
      }
    });
  });

  group('get new Token', () {
    test('Returns valid map if response is successful', () async {
      // arrange
      final tokenSuccess = json.decode(fixture('token_success.json'));
      azureApiDatasource = AzureApiDatasource(
        grantType: 'authorization_code',
        oauthUri: 'http://localhost:8000?token_get_success=true',
      );
      // act
      final token = await azureApiDatasource.getToken(
        code: '1234567890',
        port: 8000,
        clientId: '1234567890',
      );
      // assert
      expect(token.toMap(), TokenModel.fromMap(tokenSuccess).toMap());
      expect(token, isA<Token>());
    });

    test('Returns valid (error) map if response has failed', () async {
      // arrange
      final tokenFailure = json.decode(fixture('token_error.json'));
      azureApiDatasource = AzureApiDatasource(
        grantType: 'authorization_code',
        oauthUri: 'http://localhost:8000?token_get_failure=true',
      );
      // act
      final token = await azureApiDatasource.getToken(
        code: '1234567890',
        port: 8000,
        clientId: '1234567890',
      );
      // assert
      expect(token.toMap(), TokenModel.fromMap(tokenFailure).toMap());
      expect(token, isA<Token>());
    });

    test('Returns error message if azure-uri path is wrong', () async {
      // arrange
      final tokenEmpty = {
        'error': 'not_found',
        'error_description': '404 not found',
        'status': 1,
      };

      azureApiDatasource = AzureApiDatasource(
        grantType: 'authorization_code',
        oauthUri: 'http://localhost:8000?token_get_wrong_uri=true',
      );
      // act
      final token = await azureApiDatasource.getToken(
        code: '1234567890',
        port: 8000,
        clientId: '1234567890',
      );
      // assert
      expect(token.toMap(), TokenModel.fromMap(tokenEmpty).toMap());
    });

    test('Returns error message if uri is wrong in general', () async {
      // arrange
      final tokenEmpty = {
        'error': 'socket_exception',
        'error_description': 'Failed host lookup: \'test.test\'',
        'status': 1,
      };

      azureApiDatasource = AzureApiDatasource(
        grantType: 'authorization_code',
        oauthUri: 'http://test.test',
      );
      // act
      final token = await azureApiDatasource.getToken(
        code: '1234567890',
        port: 8000,
        clientId: '1234567890',
      );
      // assert
      expect(token.toMap(), TokenModel.fromMap(tokenEmpty).toMap());
      expect(token, isA<Token>());
    });
  });

  group('refresh Token', () {
    test('Returns valid map if response is successful', () async {
      // arrange
      final tokenSuccess = json.decode(fixture('token_refresh.json'));
      azureApiDatasource = AzureApiDatasource(
        grantType: 'authorization_code',
        oauthUri: 'http://localhost:8000?token_refresh_success=true',
      );
      // act
      final token = await azureApiDatasource.getToken(
        code: '1234567890',
        port: 8000,
        clientId: '1234567890',
      );
      // assert
      expect(token.toMap(), TokenModel.fromMap(tokenSuccess).toMap());
      expect(token, isA<Token>());
    });

    test('Returns valid (error) map if response has failed', () async {
      // arrange
      final tokenFailure = json.decode(fixture('token_error.json'));
      azureApiDatasource = AzureApiDatasource(
        grantType: 'authorization_code',
        oauthUri: 'http://localhost:8000?token_refresh_failure=true',
      );
      // act
      final token = await azureApiDatasource.getToken(
        code: '1234567890',
        port: 8000,
        clientId: '1234567890',
      );
      // assert
      expect(token.toMap(), TokenModel.fromMap(tokenFailure).toMap());
      expect(token, isA<Token>());
    });

    test('Returns error message if azure-uri path is wrong', () async {
      // arrange
      final tokenEmpty = {
        'error': 'not_found',
        'error_description': '404 not found',
        'status': 1,
      };

      azureApiDatasource = AzureApiDatasource(
        grantType: 'authorization_code',
        oauthUri: 'http://localhost:8000?token_refresh_wrong_uri=true',
      );
      // act
      final token = await azureApiDatasource.getToken(
        code: '1234567890',
        port: 8000,
        clientId: '1234567890',
      );
      // assert
      expect(token.toMap(), TokenModel.fromMap(tokenEmpty).toMap());
      expect(token, isA<Token>());
    });

    test('Returns error message if uri is wrong in general', () async {
      // arrange
      final tokenEmpty = {
        'error': 'socket_exception',
        'error_description': 'Failed host lookup: \'test.test\'',
        'status': 1,
      };

      azureApiDatasource = AzureApiDatasource(
        grantType: 'authorization_code',
        oauthUri: 'http://test.test',
      );
      // act
      final token = await azureApiDatasource.getToken(
        code: '1234567890',
        port: 8000,
        clientId: '1234567890',
      );
      // assert
      expect(token.toMap(), TokenModel.fromMap(tokenEmpty).toMap());
      expect(token, isA<Token>());
    });
  });

  tearDown(() async {
    await httpServerListener.cancel();
    await httpServer.close(force: true);
  });
}
