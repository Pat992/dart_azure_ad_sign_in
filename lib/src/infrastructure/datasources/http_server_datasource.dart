// Copyright 2023 Patrick Hettich. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/interfaces/i_http_server_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/exceptions/http_server_datasource_exceptions.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/models/http_server_model.dart';

/// **Description:** Class to create and control a local Http server.
class HttpServerDatasource implements IHttpServerDatasource {
  late HttpServer httpServer;
  late StreamSubscription httpServerListener;

  /// **Description:** Value to split between items in the x-www-form-urlencoded string body.
  ///
  /// **Default value:** ['&'].
  final String formSplitter;

  /// **Description:** Key of the code in the x-www-form-urlencoded string body.
  ///
  /// **Default value:** ['code='].
  final String formCode;

  /// **Description:** Key of an error in the x-www-form-urlencoded string body.
  ///
  /// **Default value:** ['error='].
  final String formError;

  /// **Description:** Key of an error description in the x-www-form-urlencoded string body.
  ///
  /// **Default value:** ['error_description='].
  final String formErrorDesc;

  /// **Description:** Key of an error url in the x-www-form-urlencoded string body.
  ///
  /// **Default value:** ['error_uri='].
  final String formErrorUri;

  /// **Description:** Creates a [HttpServerDatasource] Object
  HttpServerDatasource({
    this.formSplitter = '&',
    this.formCode = 'code=',
    this.formError = 'error=',
    this.formErrorDesc = 'error_description=',
    this.formErrorUri = 'error_uri=',
  });

  @override
  Future<HttpServerModel> listenForRequest({
    required String serverSuccessResponse,
    required String serverErrorResponse,
  }) async {
    final httpServerCompleter = Completer<Map<String, dynamic>>();
    httpServerListener = httpServer.listen((request) async {
      final body = await utf8.decodeStream(request);

      if (body.contains(formCode)) {
        final mappedResponse = createSuccessResponse(body: body);
        request.response.headers.contentType = ContentType.html;
        request.response.statusCode = 200;
        request.response.write(serverSuccessResponse);
        request.response.close();

        httpServerCompleter.complete(mappedResponse);
      } else if (body.contains(formError)) {
        final mappedResponse = createErrorOrCancellationResponse(body: body);
        request.response.headers.contentType = ContentType.html;
        request.response.statusCode = 400;
        request.response.write(serverErrorResponse);
        request.response.close();

        httpServerCompleter.complete(mappedResponse);
      }
    });

    final response = await httpServerCompleter.future;

    return HttpServerModel.fromMap(response);
  }

  @override
  Map<String, dynamic> createSuccessResponse({required String body}) {
    final responseArray = body.split(formSplitter);

    final response = responseArray
        .firstWhere((element) => element.contains(formCode), orElse: () => '')
        .replaceFirst(formCode, '');

    return {
      'code': response,
      'status': 0,
      'error': '',
      'error_description': '',
      'error_uri': ''
    };
  }

  @override
  Map<String, dynamic> createErrorOrCancellationResponse(
      {required String body}) {
    final responseArray = body.split(formSplitter);

    final error = Uri.decodeFull(
      responseArray
          .firstWhere(
            (element) => element.contains(formError),
            orElse: () => '',
          )
          .replaceFirst(formError, '')
          .replaceAll('+', ' '),
    );

    final errorDescription = Uri.decodeFull(
      responseArray
          .firstWhere(
            (element) => element.contains(formErrorDesc),
            orElse: () => '',
          )
          .replaceFirst(formErrorDesc, '')
          .replaceAll('+', ' '),
    );

    final errorUri = Uri.decodeFull(
      responseArray
          .firstWhere(
            (element) => element.contains(formErrorUri),
            orElse: () => '',
          )
          .replaceFirst(formErrorUri, ''),
    );

    return {
      'code': '',
      'status': error.contains('cancellation') ? 3 : 2,
      'error': error,
      'error_description': errorDescription,
      'error_uri': errorUri,
    };
  }

  @override
  Future<void> startServer({required int port}) async {
    try {
      httpServer = await HttpServer.bind('localhost', port, shared: true);
    } on SocketException catch (e) {
      throw HttpServerSocketException(e.message,
          address: e.address, osError: e.osError, port: e.port);
    } catch (e) {
      throw HttpServerException();
    }
  }

  @override
  Future<void> stopServer() async {
    try {
      await httpServerListener.cancel();
      await httpServer.close(force: true);
    } catch (e) {
      return;
    }
  }
}
