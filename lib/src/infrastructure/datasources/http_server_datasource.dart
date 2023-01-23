import 'dart:io';

abstract class HttpServerDatasource {
  Future<void> startServer();
  void stopServer();
  Future<String> listenForRequest();
}

class HttpServerDatasourceImpl implements HttpServerDatasource {
  final int port;
  final String serverSuccessResponse;
  final String serverErrorResponse;
  HttpServer? httpServer;

  HttpServerDatasourceImpl({
    required this.port,
    required this.serverSuccessResponse,
    required this.serverErrorResponse,
  });

  @override
  Future<String> listenForRequest() async {
    String code = '';
    await httpServer?.forEach((request) {
      // Todo: Error handling
      code = request.uri.queryParameters['code']!;
    });

    return code;
  }

  @override
  Future<void> startServer() async {
    httpServer ??= await HttpServer.bind('localhost', port);
  }

  @override
  void stopServer() {
    if (httpServer != null) {
      httpServer?.close();
      httpServer = null;
    }
  }
}
