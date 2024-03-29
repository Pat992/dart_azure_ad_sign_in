import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_azure_ad_sign_in/src/domain/entities/token_entity.dart';
import 'package:dart_azure_ad_sign_in/src/domain/repositories/i_sign_in_repository.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/azure_api_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/http_server_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/interfaces/i_azure_api_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/interfaces/i_http_server_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/models/token_model.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/repositories/sign_in_repository.dart';
import 'package:test/test.dart';

import '../../fixtures/fixtures_reader.dart';

void main() {
  final successBody = {
    'code': '1234567890',
  };
  final successResponse = {
    'code': '1234567890',
    'error': '',
    'error_description': '',
    'status': 0,
    'error_uri': ''
  };
  final errorBody = {
    'error': 'error-message',
    'error_description': 'error-description',
    'error_uri': 'https://test.com',
  };
  final errorResponse = {
    'code': '',
    'error': 'error-message',
    'error_description': 'error-description',
    'status': 2,
    'error_uri': 'https://test.com',
  };
  final cancellationResponse = {
    'code': '',
    'error': 'cancellation',
    'error_description': 'Sign In was cancelled',
    'status': 3,
    'error_uri': ''
  };
  final refreshBody = {
    'refresh_token': 'test',
  };
  final serverUrl = 'http://localhost:5000';
  IAzureApiDatasource azureApiDatasource;
  IHttpServerDatasource httpServerDatasource;

  late ISignInRepository signInRepository;
  late ISignInRepository signInRepositoryTimeoutError;
  late HttpServer httpAuthServer;
  late StreamSubscription httpServerListener;
  late HttpClient client;

  List<int> createFormData({required Map<String, dynamic> formMap}) {
    final List<String> parts = [];

    formMap.forEach((key, value) {
      parts.add('${Uri.encodeQueryComponent(key)}='
          '${Uri.encodeQueryComponent(value)}');
    });

    final formData = parts.join('&');

    return utf8.encode(formData);
  }

  Future<HttpClientRequest> createRequest({
    required List<int> formBytes,
  }) async {
    final request = await client.postUrl(Uri.parse(serverUrl));

    request.headers.set('Content-Length', formBytes.length.toString());
    request.headers.set('Content-Type', 'application/x-www-form-urlencoded');

    request.add(formBytes);

    return request;
  }

  setUp(() async {
    azureApiDatasource = AzureApiDatasource(
      grantType: 'authorization_code',
      oauthUri: 'http://localhost:5000',
    );

    httpServerDatasource = HttpServerDatasource();

    signInRepository = SignInRepository(
      azureApiDatasource: azureApiDatasource,
      httpServerDatasource: httpServerDatasource,
    );

    signInRepositoryTimeoutError = SignInRepository(
      azureApiDatasource: azureApiDatasource,
      httpServerDatasource: httpServerDatasource,
    );

    client = HttpClient();

    httpAuthServer = await HttpServer.bind('localhost', 5000);

    httpServerListener = httpAuthServer.listen((request) async {
      final body = await utf8.decodeStream(request);

      if (body.contains('code=')) {
        final token = fixture('token_success.json');
        request.response.statusCode = 200;
        request.response.write(token);
        request.response.close();
      } else if (body.contains('refresh_token')) {
        final token = fixture('token_refresh.json');
        request.response.statusCode = 200;
        request.response.write(token);
        request.response.close();
      } else if (body.contains('error=')) {
        String token;
        if (body.contains('cancellation')) {
          token = fixture('token_cancellation.json');
        } else {
          token = fixture('token_error.json');
        }
        request.response.statusCode = 400;
        request.response.write(token);
        request.response.close();
      }
    });
  });

  group('getToken function', () {
    test('Get valid Token if sign in successful', () async {
      // arrange
      final formBytes = createFormData(formMap: successBody);
      // act
      final tokenFuture = signInRepository.signIn(
        clientId: '04b07795-8ddb-461a-bbee-02f9e1bf7b46',
        port: 5050,
        serverSuccessResponse: 'success',
        serverErrorResponse: 'error',
        signInTimeoutDuration: Duration(minutes: 5),
      );
      final request = await createRequest(formBytes: formBytes);
      final response = await request.close();
      // assert
      expect(response.statusCode, 200);
      tokenFuture.then((tokenResult) {
        expect((tokenResult as TokenModel).toMap(), successResponse);
        expect(tokenResult, isA<Token>());
      });
    });

    test('Get Token with error if sign in has failed', () async {
      // arrange
      final formBytes = createFormData(formMap: errorBody);
      // act
      final tokenFuture = signInRepository.signIn(
        clientId: '04b07795-8ddb-461a-bbee-02f9e1bf7b46',
        port: 5050,
        serverSuccessResponse: 'success',
        serverErrorResponse: 'error',
        signInTimeoutDuration: Duration(minutes: 5),
      );
      final request = await createRequest(formBytes: formBytes);
      final response = await request.close();
      // assert
      expect(response.statusCode, 400);
      tokenFuture.then((tokenResult) {
        expect((tokenResult as TokenModel).toMap(), errorResponse);
        expect(tokenResult, isA<Token>());
      });
    });

    test('Get Token with cancelling error if sign in has been cancelled',
        () async {
      // arrange
      final formBytes = createFormData(formMap: errorBody);
      // act
      final tokenFuture = signInRepository.signIn(
        clientId: '04b07795-8ddb-461a-bbee-02f9e1bf7b46',
        port: 5050,
        serverSuccessResponse: 'success',
        serverErrorResponse: 'error',
        signInTimeoutDuration: Duration(minutes: 5),
      );
      final request = await createRequest(formBytes: formBytes);
      final response = await request.close();
      // assert
      expect(response.statusCode, 400);
      tokenFuture.then((tokenResult) {
        expect((tokenResult as TokenModel).toMap(), cancellationResponse);
        expect(tokenResult, isA<Token>());
      });
    });

    test(
        'Cancel Sign In by reaching the 5 second timeout, get Token with cancelling error',
        () async {
      // arrange
      // act
      final tokenFuture = signInRepositoryTimeoutError.signIn(
        clientId: '04b07795-8ddb-461a-bbee-02f9e1bf7b46',
        port: 5050,
        serverSuccessResponse: 'success',
        serverErrorResponse: 'error',
        signInTimeoutDuration: Duration(seconds: 2),
      );
      // assert
      tokenFuture.then((tokenResult) {
        expect((tokenResult as TokenModel).toMap(), cancellationResponse);
        expect(tokenResult, isA<Token>());
      });
    });
  });

  group('refreshToken function', () {
    test('Get valid Token if refresh has been successful', () async {
      // arrange
      final formBytes = createFormData(formMap: refreshBody);
      final token =
          TokenModel.fromMap(json.decode(fixture('token_refresh.json')));
      // act
      final tokenFuture = signInRepository.refreshToken(token: token);
      final request = await createRequest(formBytes: formBytes);
      final response = await request.close();
      // assert
      expect(response.statusCode, 200);
      tokenFuture.then((tokenResult) {
        expect((tokenResult as TokenModel).toMap(), token.toMap());
        expect(tokenResult, isA<Token>());
      });
    });

    test(
        'Get valid Token with error if no token object or refresh token is given',
        () async {
      // arrange
      final token = TokenModel.fromMap(
          json.decode(fixture('token_not_given_error.json')));
      // act
      final tokenFuture = signInRepository.refreshToken();
      // assert
      tokenFuture.then((tokenResult) {
        expect((tokenResult as TokenModel).toMap(), token.toMap());
        expect(tokenResult, isA<Token>());
      });
    });

    test(
        'Get valid Token with error if token object does not contain a refresh token',
        () async {
      // arrange
      final token = TokenModel.fromMap(
          json.decode(fixture('token_no_ref_token_error.json')));
      // act
      final tokenFuture = signInRepository.refreshToken(token: token);
      // assert
      tokenFuture.then((tokenResult) {
        expect((tokenResult as TokenModel).toMap(), token.toMap());
        expect(tokenResult, isA<Token>());
      });
    });
  });

  tearDown(() {
    httpServerListener.cancel();
    httpAuthServer.close(force: true);
  });
}
