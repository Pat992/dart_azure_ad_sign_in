import 'dart:io';

class HttpServerSocketException extends SocketException {
  HttpServerSocketException(
    super.message, {
    super.osError,
    super.address,
    super.port,
  });
}

class HttpServerException implements Exception {}
