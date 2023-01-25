import 'dart:convert';
import 'dart:io';

abstract class AzureApiDatasource {
  Future<Map<String, dynamic>> getToken({required String code});
  Future<Map<String, dynamic>> refreshToken({required String refreshToken});
}

// Todo: error handling

class AzureApiDatasourceImpl implements AzureApiDatasource {
  final int port;
  final String clientId;
  final String grantType;
  final String oauthUri;
  late HttpClient client;

  AzureApiDatasourceImpl({
    required this.port,
    required this.clientId,
    required this.grantType,
    required this.oauthUri,
  });

  @override
  Future<Map<String, dynamic>> getToken({
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
      final request = await createRequest(formBytes: formBytes);
      final response = await request.close();

      client.close();

      if (response.statusCode != 404) {
        final stringRes = await readResponse(response: response);
        final stringMap = json.decode(stringRes);
        return stringMap;
      } else {
        return {
          'error': 'not_found',
          'error_description': '404 not found',
        };
      }
    } on SocketException catch (e) {
      return {
        'error': 'socket_exception',
        'error_description': e.message,
      };
    } catch (e) {
      return {
        'error': 'unknown_exception',
        'error_description': 'Unknown exception',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final Map<String, dynamic> formMap = {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      };

      client = HttpClient();

      final formBytes = createFormData(formMap: formMap);
      final request = await createRequest(formBytes: formBytes);
      final response = await request.close();

      client.close();

      if (response.statusCode != 404) {
        final stringRes = await readResponse(response: response);
        final stringMap = json.decode(stringRes);
        return stringMap;
      } else {
        return {
          'error': 'not_found',
          'error_description': '404 not found',
        };
      }
    } on SocketException catch (e) {
      return {
        'error': 'socket_exception',
        'error_description': e.message,
      };
    } catch (e) {
      return {
        'error': 'unknown_exception',
        'error_description': 'Unknown exception',
      };
    }
  }

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
    final request = await client.postUrl(Uri.parse(oauthUri));

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
}
