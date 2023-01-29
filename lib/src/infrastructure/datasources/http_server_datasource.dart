import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_azure_ad_sign_in/src/infrastructure/models/http_server_model.dart';

abstract class IHttpServerDatasource {
  Future<void> startServer();
  Future<void> stopServer();
  Future<HttpServerModel> listenForRequest();
}

class HttpServerDatasource implements IHttpServerDatasource {
  final int port;
  final String serverSuccessResponse;
  final String serverErrorResponse;
  late HttpServer httpServer;
  late StreamSubscription httpServerListener;

  HttpServerDatasource({
    required this.port,
    required this.serverSuccessResponse,
    required this.serverErrorResponse,
  });

  // Todo: cancellation can be added here
  @override
  Future<HttpServerModel> listenForRequest() async {
    const formSplitter = '&';
    const formCode = 'code=';
    const formError = 'error=';
    const formErrorDesc = 'error_description=';
    const formErrorUri = 'error_uri=';

    final httpServerCompleter = Completer<Map<String, dynamic>>();
    httpServerListener = httpServer.listen((request) async {
      final body = await utf8.decodeStream(request);

      if (body.contains(formCode)) {
        final responseArray = body.split(formSplitter);

        final response = responseArray
            .firstWhere((element) => element.contains(formCode))
            .replaceFirst(formCode, '');

        request.response.statusCode = 200;
        request.response.write(serverSuccessResponse);
        request.response.close();

        httpServerCompleter.complete({
          'code': response,
          'status': 0,
          'error': '',
          'error_description': '',
          'error_uri': ''
        });
      } else if (body.contains(formError)) {
        final responseArray = body.split(formSplitter);

        final error = responseArray
            .firstWhere(
              (element) => element.contains(formError),
              orElse: () => '',
            )
            .replaceFirst(formError, '');

        final errorDescription = responseArray
            .firstWhere(
              (element) => element.contains(formErrorDesc),
              orElse: () => '',
            )
            .replaceFirst(formErrorDesc, '');

        final errorUri = Uri.decodeFull(
          responseArray
              .firstWhere(
                (element) => element.contains(formErrorUri),
                orElse: () => '',
              )
              .replaceFirst(formErrorUri, ''),
        );

        print(body);

        request.response.statusCode = 400;
        request.response.write(serverErrorResponse);
        request.response.close();

        httpServerCompleter.complete({
          'code': '',
          'status': 3,
          'error': error,
          'error_description': errorDescription,
          'error_uri': errorUri,
        });
      }
    });

    final response = await httpServerCompleter.future;

    return HttpServerModel.fromMap(response);
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
