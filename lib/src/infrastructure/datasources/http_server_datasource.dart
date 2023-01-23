abstract class HttpServerDatasource {
  void startServer();
  void stopServer();
  String listenForRequest();
}

class HttpServerDatasourceImpl implements HttpServerDatasource {
  @override
  String listenForRequest() {
    // TODO: implement listenForRequest
    throw UnimplementedError();
  }

  @override
  void startServer() {
    // TODO: implement startServer
  }

  @override
  void stopServer() {
    // TODO: implement stopServer
  }
}
