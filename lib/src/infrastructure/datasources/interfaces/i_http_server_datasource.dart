// Copyright 2023 Patrick Hettich. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dart_azure_ad_sign_in/src/infrastructure/models/http_server_model.dart';

/// **Description:** Datasource Interface/Abstract class to create a local Http server.
abstract class IHttpServerDatasource {
  /// **Description:** Starts a local Http server
  ///
  /// **Parameter:** int port
  ///
  /// **Returns:** Future<void>
  Future<void> startServer({required int port});

  /// **Description:** Stops the local Http server
  ///
  /// **Parameter:** None
  ///
  /// **Returns:** Future<void>
  Future<void> stopServer();

  /// **Description:** Listens for requests, either by Azure or by the [AzureApiDatasource] in case of a cancellation.
  ///
  /// **Parameter:** String serverSuccessResponse, String serverErrorResponse
  ///
  /// **Returns:** A [HttpServerModel], which will be used to check for errors,
  /// or to receive the code to send to the Azure API.
  Future<HttpServerModel> listenForRequest(
      {required String serverSuccessResponse,
      required String serverErrorResponse});

  /// **Description:** Creates a Map in case of success.
  ///
  /// **Parameter:** String body - The x-www-form-urlencoded request body.
  ///
  /// **Returns:** A Map with the values to create a [HttpServerModel].
  Map<String, dynamic> createSuccessResponse({required String body});

  /// **Description:** Creates a Map in case of failure or cancellation.
  ///
  /// **Parameter:** String body - The x-www-form-urlencoded request body.
  ///
  /// **Returns:** A Map with the values to create a [HttpServerModel].
  Map<String, dynamic> createErrorOrCancellationResponse(
      {required String body});
}
