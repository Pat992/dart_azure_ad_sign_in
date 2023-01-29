// Copyright 2023 Patrick Hettich. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:convert';
import 'dart:io';

import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/http_server_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/models/token_model.dart';

/// **Description:** Datasource Interface/Abstract class to communicate with the Azure API.
abstract class IAzureApiDatasource {
  /// **Description:** Get a new token from the Azure API.
  ///
  /// **Parameter:** String code - Code generated by sign in via Web.
  ///
  /// **Returns:** A newly created [Token].
  Future<TokenModel> getToken({required String code});

  /// **Description:** Refresh an existing token via the Azure API.
  ///
  /// **Parameter:** [Token] - Existing token, uses its refreshToken value.
  ///
  /// **Returns:** The given [Token] with updates from Azure, will be used for updating a token.
  Future<TokenModel> refreshToken({required String refreshToken});

  /// **Description:** Cancel the current [HttpServerDatasource.listenForRequest] by sending it a cancellation request.
  Future<void> cancelGetToken();

  /// **Description:** Create Form-data from a Map.
  List<int> createFormData({required Map<String, dynamic> formMap});

  /// **Description:** Create a request to the Azure API.
  Future<HttpClientRequest> createRequest(
      {required List<int> formBytes, required String uri});

  /// **Description:** Read a response from the Azure API.
  Future<String> readResponse({required HttpClientResponse response});
}

/// **Description:** Class to communicate with the Azure API.
class AzureApiDatasource implements IAzureApiDatasource {
  /// **Description:** Port of the Local HttpServer which will receive the code after sign in.
  ///
  /// **Default value:** 8080
  final int port;

  /// **Description:** The Application (client) ID that the Azure portal – App registrations page assigned to your app.
  /// Uses the AZ CLI client ID by default, no app registration necessary.
  ///
  /// **Default value:** [04b07795-8ddb-461a-bbee-02f9e1bf7b46]
  final String clientId;

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
      print(e.toString());
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
  Future<void> cancelGetToken() async {
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
