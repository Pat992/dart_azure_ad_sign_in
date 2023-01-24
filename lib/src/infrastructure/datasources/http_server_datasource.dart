import 'dart:async';
import 'dart:convert';
import 'dart:io';

abstract class HttpServerDatasource {
  Future<void> startServer();
  Future<void> stopServer();
  Future<String> listenForRequest();
}

class HttpServerDatasourceImpl implements HttpServerDatasource {
  final int port;
  final String serverSuccessResponse;
  final String serverErrorResponse;
  late HttpServer httpServer;
  late StreamSubscription httpServerListener;

  HttpServerDatasourceImpl({
    required this.port,
    required this.serverSuccessResponse,
    required this.serverErrorResponse,
  });

  // Todo: cancellation can be added here
  @override
  Future<String> listenForRequest() async {
    final httpServerCompleter = Completer<String>();

    httpServerListener = httpServer.listen((request) {
      utf8.decodeStream(request).then((data) async {
        if (data.contains('code=')) {
          var code = data;
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
    });

    final code = await httpServerCompleter.future;
    return code;
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
