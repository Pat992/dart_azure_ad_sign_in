// Copyright 2023 Patrick Hettich. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
/// Object used to get and refresh token.
import 'package:dart_azure_ad_sign_in/src/domain/entities/token_entity.dart';

/// **Description:** Interface/Abstract class of the SignInRepository
abstract class ISignInRepository {
  /// **Description:** Signs in the user, by using the [HttpServerDatasource] and [AzureApiDatasource].
  ///
  /// **Parameter:** String clientId - The Application (client) ID
  /// int port - Port of the local http server,
  /// String serverSuccessResponse - http server response if sign in successful,
  /// String serverErrorResponse - http server response if sign in failed,
  /// Duration signInTimeoutDuration - Duration on how long the local HttpServer waits for sign in
  ///
  /// **Returns:** A newly created [Token].
  Future<Token> signIn({
    required String clientId,
    required int port,
    required String serverSuccessResponse,
    required String serverErrorResponse,
    required Duration signInTimeoutDuration,
  });

  /// **Description:** Refreshes an existing token, by using the[AzureApiDatasource].
  ///
  /// **Parameter:** either use [Token] - Existing token, uses its refreshToken value,
  /// refreshToken - the refresh token if token is not accessible
  ///
  /// **Returns:** The given [Token] with updates from Azure, will be used for updating a token.
  Future<Token> refreshToken({Token? token, refreshToken = ''});

  /// **Description:** Cancel an open Sign In, will also automatically called once [AzureSignIn.signInTimeoutDuration] is reached.
  /// Sends a request for cancelling to the local HttpServer, which then will return a new [Token]
  ///
  /// **Parameter:** int port - Port of the local http server
  ///
  /// **Returns:** Future<void>
  Future<void> cancelSignIn({required int port});
}
