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
  Future<Map<String, dynamic>> getToken({required String code}) async {
    final Map<String, dynamic> formMap = {
      'code': code,
      'redirect_uri': 'http://localhost:$port',
      'grant_type': grantType,
      'client_id': clientId
    };

    client = HttpClient();

    final formBytes = _createFormData(formMap: formMap);

    final request = await _createRequest(formBytes: formBytes);

    final response = await request.close();

    client.close();

    final stringRes = await _readResponse(response);

    final stringMap = json.decode(stringRes);

    return stringMap;
  }

  @override
  Future<Map<String, dynamic>> refreshToken(
      {required String refreshToken}) async {
    final Map<String, dynamic> formMap = {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    };

    client = HttpClient();

    final formBytes = _createFormData(formMap: formMap);

    final request = await _createRequest(formBytes: formBytes);

    final response = await request.close();

    client.close();

    final stringRes = await _readResponse(response);

    final stringMap = json.decode(stringRes);

    return stringMap;
  }

  List<int> _createFormData({required Map<String, dynamic> formMap}) {
    final List<String> parts = [];

    formMap.forEach((key, value) {
      parts.add('${Uri.encodeQueryComponent(key)}='
          '${Uri.encodeQueryComponent(value)}');
    });

    final formData = parts.join('&');

    return utf8.encode(formData);
  }

  Future<HttpClientRequest> _createRequest(
      {required List<int> formBytes}) async {
    final request = await client.postUrl(Uri.parse(oauthUri));

    request.headers.set('Content-Length', formBytes.length.toString());
    request.headers.set('Content-Type', 'application/x-www-form-urlencoded');

    request.add(formBytes);

    return request;
  }

  Future<String> _readResponse(HttpClientResponse response) async {
    final contents = StringBuffer();
    await for (var data in response.transform(utf8.decoder)) {
      contents.write(data);
    }
    return contents.toString();
  }
}
