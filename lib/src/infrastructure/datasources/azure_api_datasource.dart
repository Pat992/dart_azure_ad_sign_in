// Copyright 2023 Patrick Hettich. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:convert';
import 'dart:io';

import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/interfaces/i_azure_api_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/models/token_model.dart';

/// **Description:** Class to communicate with the Azure API.
class AzureApiDatasource implements IAzureApiDatasource {
  /// **Description:** Grant Type for the authorization flow.
  ///
  /// Must be [authorization_code] for the authorization code flow.
  final String grantType;

  /// **Description:** URI of the Azure API to get a token by code,
  /// or to refresh an existing token.
  ///
  /// **Default value:** ['https://login.microsoftonline.com/organizations/oauth2/token'].
  final String oauthUri;

  /// **Description:** HTTPClient to send requests to the Azure API.
  late HttpClient client;

  /// **Description:** Creates a [AzureApiDatasource] Object
  AzureApiDatasource({
    required this.grantType,
    required this.oauthUri,
  });

  @override
  Future<TokenModel> getToken({
    required String clientId,
    required String code,
    required int port,
  }) async {
    try {
      /// Body before transformation into [x-www-form-urlencoded]
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

      client.close(force: true);

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
    } on HttpException catch (e) {
      return TokenModel.fromMap({
        'error': 'http_exception',
        'error_description': e.message,
        'status': 1,
      });
    } catch (e) {
      return TokenModel.fromMap({
        'error': 'unknown_exception',
        'error_description': e.toString(),
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

      client.close(force: true);

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
    } on HttpException catch (e) {
      return TokenModel.fromMap({
        'error': 'http_exception',
        'error_description': e.message,
        'status': 1,
      });
    } catch (e) {
      print(e.toString());
      return TokenModel.fromMap({
        'error': 'unknown_exception',
        'error_description': e.toString(),
        'status': 1,
      });
    }
  }

  @override
  Future<void> cancelGetToken({required int port}) async {
    try {
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
      client.close(force: true);
    } catch (e) {
      return;
    }
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
