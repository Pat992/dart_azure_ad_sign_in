// Copyright 2023 Patrick Hettich. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:io';

import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/http_server_datasource.dart';

/// Custom socket-exception for [HttpServerDatasource]
class HttpServerSocketException extends SocketException {
  HttpServerSocketException(
    super.message, {
    super.osError,
    super.address,
    super.port,
  });
}

/// Custom exception for [HttpServerDatasource]
class HttpServerException implements Exception {}
