import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_azure_ad_sign_in/src/infrastructure/models/http_server_model.dart';

abstract class IHttpServerDatasource {
  Future<void> startServer();
  Future<void> stopServer();
  Future<HttpServerModel> listenForRequest();
  Map<String, dynamic> createSuccessResponse({required String body});
  Map<String, dynamic> createErrorOrCancellationResponse(
      {required String body});
}

class HttpServerDatasource implements IHttpServerDatasource {
  final int port;
  final String serverSuccessResponse;
  final String serverErrorResponse;
  late HttpServer httpServer;
  late StreamSubscription httpServerListener;
  final String formSplitter;
  final String formCode;
  final String formError;
  final String formErrorDesc;
  final String formErrorUri;

  HttpServerDatasource({
    required this.port,
    required this.serverSuccessResponse,
    required this.serverErrorResponse,
    this.formSplitter = '&',
    this.formCode = 'code=',
    this.formError = 'error=',
    this.formErrorDesc = 'error_description=',
    this.formErrorUri = 'error_uri=',
  });

  @override
  Future<HttpServerModel> listenForRequest() async {
    final httpServerCompleter = Completer<Map<String, dynamic>>();
    httpServerListener = httpServer.listen((request) async {
      final body = await utf8.decodeStream(request);

      if (body.contains(formCode)) {
        final mappedResponse = createSuccessResponse(body: body);

        request.response.statusCode = 200;
        request.response.write(serverSuccessResponse);
        request.response.close();

        httpServerCompleter.complete(mappedResponse);
      } else if (body.contains(formError)) {
        final mappedResponse = createErrorOrCancellationResponse(body: body);

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
  Future<void> startServer() async {
    httpServer = await HttpServer.bind('localhost', port);
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
