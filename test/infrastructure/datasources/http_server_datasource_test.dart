import 'dart:convert';
import 'dart:io';

import 'package:dart_azure_ad_sign_in/src/domain/entities/http_server_entity.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/azure_api_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/http_server_datasource.dart';
import 'package:test/test.dart';

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
  final serverUrl = 'http://localhost:8080';
  late IHttpServerDatasource httpServerDatasource;
  late IAzureApiDatasource azureApiDatasource;
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

  Future<String> readResponse({
    required HttpClientResponse response,
  }) async {
    final contents = StringBuffer();
    await for (var data in response.transform(utf8.decoder)) {
      contents.write(data);
    }
    return contents.toString();
  }

  setUp(() async {
    httpServerDatasource = HttpServerDatasource(
      port: 8080,
      serverSuccessResponse: 'success',
      serverErrorResponse: 'error',
    );

    azureApiDatasource = AzureApiDatasource(
      port: 8080,
      clientId: '123456789',
      grantType: 'authorization_code',
      oauthUri: 'https://test.com',
    );
    client = HttpClient();
  });

  test('Get success in body if code has been sent in the body', () async {
    // arrange
    final formBytes = createFormData(formMap: successBody);
    // act
    await httpServerDatasource.startServer();
    final serverResultFuture = httpServerDatasource.listenForRequest();
    final request = await createRequest(formBytes: formBytes);
    final response = await request.close();
    final stringRes = await readResponse(response: response);
    await httpServerDatasource.stopServer();
    // assert
    expect(stringRes, 'success');
    expect(response.statusCode, 200);
    serverResultFuture.then((serverResult) {
      expect(serverResult.toMap(), successResponse);
      expect(serverResult, isA<HttpServerEntity>());
    });
  });

  test('Get error in body if error has been sent in the body', () async {
    // arrange
    final formBytes = createFormData(formMap: errorBody);
    // act
    await httpServerDatasource.startServer();
    final serverResultFuture = httpServerDatasource.listenForRequest();
    final request = await createRequest(formBytes: formBytes);
    final response = await request.close();
    final stringRes = await readResponse(response: response);
    await httpServerDatasource.stopServer();
    // assert
    expect(stringRes, 'error');
    expect(response.statusCode, 400);
    serverResultFuture.then((serverResult) {
      expect(serverResult.toMap(), errorResponse);
      expect(serverResult, isA<HttpServerEntity>());
    });
  });

  test('Get cancellation body if sign in has been cancelled', () async {
    // arrange
    // act
    await httpServerDatasource.startServer();
    final serverResultFuture = httpServerDatasource.listenForRequest();
    await azureApiDatasource.cancelGetToken();
    await httpServerDatasource.stopServer();
    // assert
    serverResultFuture.then((serverResult) {
      expect(serverResult.toMap(), cancellationResponse);
      expect(serverResult, isA<HttpServerEntity>());
    });
  });

  tearDown(() async {
    client.close();
  });
}
