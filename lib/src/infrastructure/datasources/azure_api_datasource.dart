import 'dart:convert';
import 'dart:io';

import 'package:dart_azure_ad_sign_in/src/infrastructure/models/token_model.dart';

abstract class IAzureApiDatasource {
  Future<TokenModel> getToken({required String code});
  Future<TokenModel> refreshToken({required String refreshToken});
  Future<void> cancelGetToken();
  List<int> createFormData({required Map<String, dynamic> formMap});
  Future<HttpClientRequest> createRequest(
      {required List<int> formBytes, required String uri});
  Future<String> readResponse({required HttpClientResponse response});
}

// Todo: error handling

class AzureApiDatasource implements IAzureApiDatasource {
  final int port;
  final String clientId;
  final String grantType;
  final String oauthUri;
  late HttpClient client;

  AzureApiDatasource({
    required this.port,
    required this.clientId,
    required this.grantType,
    required this.oauthUri,
  });

  @override
  Future<TokenModel> getToken({
    required String code,
  }) async {
    try {
      final Map<String, dynamic> formMap = {
        'code': code,
        'redirect_uri': 'http://localhost:$port',
        'grant_type': grantType,
        'client_id': clientId
      };

      client = HttpClient();

      final formBytes = createFormData(formMap: formMap);
      final request = await createRequest(
        formBytes: formBytes,
        uri: oauthUri,
      );
      final response = await request.close();

      client.close();

      if (response.statusCode != 404) {
        final stringRes = await readResponse(response: response);
        final responseMap = json.decode(stringRes);
        return TokenModel.fromMap(responseMap);
      } else {
        return TokenModel.fromMap({
          'error': 'not_found',
          'error_description': '404 not found',
          'status': 1,
        });
      }
    } on SocketException catch (e) {
      return TokenModel.fromMap({
        'error': 'socket_exception',
        'error_description': e.message,
        'status': 1,
      });
    } catch (e) {
      return TokenModel.fromMap({
        'error': 'unknown_exception',
        'error_description': 'Unknown exception, error getting token',
        'status': 1,
      });
    }
  }

  @override
  Future<TokenModel> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final Map<String, dynamic> formMap = {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      };

      client = HttpClient();

      final formBytes = createFormData(formMap: formMap);
      final request = await createRequest(
        formBytes: formBytes,
        uri: oauthUri,
      );
      final response = await request.close();

      client.close();

      if (response.statusCode != 404) {
        final stringRes = await readResponse(response: response);
        final responseMap = json.decode(stringRes);
        return TokenModel.fromMap(responseMap);
      } else {
        return TokenModel.fromMap({
          'error': 'not_found',
          'error_description': '404 not found',
          'status': 1,
        });
      }
    } on SocketException catch (e) {
      return TokenModel.fromMap({
        'error': 'socket_exception',
        'error_description': e.message,
        'status': 1,
      });
    } catch (e) {
      return TokenModel.fromMap({
        'error': 'unknown_exception',
        'error_description': 'Unknown exception, error refreshing token',
        'status': 1,
      });
    }
  }

  @override
  Future<void> cancelGetToken() async {
    const Map<String, dynamic> formMap = {
      'error': 'cancellation',
      'error_description': 'Sign In was cancelled',
    };

    client = HttpClient();

    final formBytes = createFormData(formMap: formMap);

    final request = await createRequest(
      formBytes: formBytes,
      uri: 'http://localhost:$port',
    );
    await request.close();
    client.close();
  }

  @override
  List<int> createFormData({required Map<String, dynamic> formMap}) {
    final List<String> parts = [];

    formMap.forEach((key, value) {
      parts.add('${Uri.encodeQueryComponent(key)}='
          '${Uri.encodeQueryComponent(value)}');
    });

    final formData = parts.join('&');

    return utf8.encode(formData);
  }

  @override
  Future<HttpClientRequest> createRequest({
    required List<int> formBytes,
    required String uri,
  }) async {
    final request = await client.postUrl(Uri.parse(uri));

    request.headers.set('Content-Length', formBytes.length.toString());
    request.headers.set('Content-Type', 'application/x-www-form-urlencoded');

    request.add(formBytes);

    return request;
  }

  @override
  Future<String> readResponse({
    required HttpClientResponse response,
  }) async {
    final contents = StringBuffer();
    await for (var data in response.transform(utf8.decoder)) {
      contents.write(data);
    }
    return contents.toString();
  }
}
