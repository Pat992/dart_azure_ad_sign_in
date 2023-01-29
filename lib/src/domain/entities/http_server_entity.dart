// Copyright 2023 Patrick Hettich. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
/// **Description:** Object returned by the Local HttpServer.
class HttpServerEntity {
  /// **Description:** Code that has been sent to the Server, after successful Sign In.
  /// In case of success a code, in case of an error, an empty String.
  final String code;

  /// **Description:** Status the local HttpServer returned:
  ///
  /// **Status codes:**
  ///
  /// 0: Success
  ///
  /// 2: HttpServer error
  ///
  /// 3: Sign In cancelled
  final int status;

  /// **Description:** In Case of success an empty String, in case of an error the title of the error.
  final String error;

  /// **Description:** In Case of success an empty String, in case of an error the description of the error.
  final String errorDescription;

  /// **Description:**
  ///
  /// In Case of success an empty String, in case of an error the URL to a specific Microsoft error documentation,
  /// or if not returned empty.
  final String errorUri;

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
  const HttpServerEntity({
    required this.code,
    required this.status,
    required this.error,
    required this.errorDescription,
    required this.errorUri,
  });
}
