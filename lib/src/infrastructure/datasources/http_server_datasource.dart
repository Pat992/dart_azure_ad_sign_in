import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_azure_ad_sign_in/src/domain/entities/http_server_entity.dart';

abstract class IHttpServerDatasource {
  Future<void> startServer();
  Future<void> stopServer();
  Future<HttpServerEntity> listenForRequest();
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
  Future<HttpServerEntity> listenForRequest() async {
    final httpServerCompleter = Completer<String>();

    httpServerListener = httpServer.listen((request) async {
      final body = await utf8.decodeStream(request);
      if (body.contains('code=')) {
        var code = body;
        const start = 'code=';
        const end = '&';

        final startIndex = code.indexOf(start);
        final endIndex = code.indexOf(end, startIndex + start.length);

        code = code.substring(startIndex + start.length, endIndex);

        request.response.statusCode = 200;
        request.response.write(serverSuccessResponse);
        request.response.close();

        // await httpServerListener.cancel();
        // await httpServer.close(force: true);

        httpServerCompleter.complete(code);
      }
    });

    final code = await httpServerCompleter.future;

    return HttpServerEntity(
      code: code,
      status: 0,
      error: '',
      errorDescription: '',
    );
  }

  @override
  Future<void> startServer() async {
    httpServer = await HttpServer.bind('localhost', port);
  }

  @override
  Future<void> stopServer() async {
    await httpServerListener.cancel();
    await httpServer.close(force: true);
  }
}
