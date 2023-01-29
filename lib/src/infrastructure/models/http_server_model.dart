// Copyright 2023 Patrick Hettich. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:dart_azure_ad_sign_in/src/domain/entities/http_server_entity.dart';

/// **Description:** Model of the [HttpServerEntity]
class HttpServerModel extends HttpServerEntity {
  /// **Description:** Creates an Object with either given [code] and a [status] of 0.
  /// In case of an error some further information and a [status] of either 2 or 3.
  ///
  /// **status**
  ///
  /// 0: Success
  ///
  /// 2: HttpServer error
  ///
  /// 3: Sign In cancelled
  HttpServerModel({
    required super.code,
    required super.status,
    required super.error,
    required super.errorDescription,
    required super.errorUri,
  });

  /// **Description:** Transforms Object to Map, with Keys, understood by the Azure API
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'status': status,
      'error': error,
      'error_description': errorDescription,
      'error_uri': errorUri,
    };
  }

  /// **Description:** Transforms a Map from the Azure API to the [HttpServerModel]
  factory HttpServerModel.fromMap(Map<String, dynamic> map) {
    return HttpServerModel(
      code: map['code'] as String,
      status: map['status'] as int,
      error: map['error'] as String,
      errorDescription: map['error_description'] as String,
      errorUri: map['error_uri'] as String,
    );
  }
}
