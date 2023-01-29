import 'package:dart_azure_ad_sign_in/src/domain/entities/http_server_entity.dart';

class HttpServerModel extends HttpServerEntity {
  HttpServerModel({
    required super.code,
    required super.status,
    required super.error,
    required super.errorDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'status': status,
      'error': error,
      'errorDescription': errorDescription,
    };
  }

  factory HttpServerModel.fromMap(Map<String, dynamic> map) {
    return HttpServerModel(
      code: map['code'] as String,
      status: map['status'] as int,
      error: map['error'] as String,
      errorDescription: map['error_description'] as String,
    );
  }
}
