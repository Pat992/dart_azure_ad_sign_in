class HttpServerEntity {
  final String code;
  final int status;
  final String error;
  final String errorDescription;
  final String errorUri;

  const HttpServerEntity({
    required this.code,
    required this.status,
    required this.error,
    required this.errorDescription,
    required this.errorUri,
  });
}
