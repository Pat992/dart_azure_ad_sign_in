// Copyright 2023 Patrick Hettich. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
/// **Description:** Object used to get and refresh token.
class Token {
  /// **Description:** Indicates the token type value. The only type that Azure AD supports is [Bearer].
  final String tokenType;

  /// **Description:** The scopes that the [access_token] is valid for. Optional.
  /// This parameter is non-standard and, if omitted, the token is for the scopes requested on the initial leg of the flow.
  ///
  /// **Example:** '[user_impersonation]'
  final String scope;

  /// **Description:** How long the access token is valid, in seconds.
  ///
  /// **Example:** '[5084]'
  final String expiresIn;

  /// **Description:** Used to indicate an extended lifetime for the access token and to support resiliency when the token issuance service is not responding.
  ///
  /// **Example:** '[5084]'
  final String extExpiresIn;

  /// **Description:** Timestamp when the token expires.
  ///
  /// **Example:** '[1674580651]'
  final String expiresOn;

  /// **Description:** The time at which the token becomes valid, represented in epoch time.
  /// This time is usually the same as the time the token was issued. Azure AD B2C validates this value, and rejects the token if the token lifetime is not valid.
  ///
  /// **Example:** '[1674575266]'
  final String notBefore;

  /// **Description:** Resource the token has access to.
  ///
  /// **Example:** '[https://management.core.windows.net/]'
  final String resource;

  /// **Description:** The requested access token. The app can use this token to authenticate to the secured resource, such as a web API.
  ///
  /// **Example:** '[eyJ0eXAiOiJKV1QiLCJhbGciOiJS...]'
  final String accessToken;

  /// **Description:** An OAuth 2.0 refresh token. The app can use this token to acquire other access tokens after the current access token expires.
  /// Refresh tokens are long-lived. They can maintain access to resources for extended periods.
  ///
  /// **Example:** '[0.AQUAjHBCWE0CK06v4qgD88sl3Z...]'
  final String refreshToken;

  /// **Description:** A JSON Web Token. The app can decode the segments of this token to request information about the user who signed in.
  /// The app can cache the values and display them, and confidential clients can use this token for authorization.
  ///
  /// **Example:** '[eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIs...]'
  final String idToken;

  /// **Description:** Signs in to a second Microsoft Office app while they have a session on a mobile device using FOCI (Family of Client IDs).
  ///
  /// **Example:** '[1]'
  final String foci;

  /// **Description:** Status of the Token authorization code flow:
  ///
  /// **Status codes:**
  ///
  /// 0: Success
  ///
  /// 1: Azure API error
  ///
  /// 2: HttpServer error
  ///
  /// 3: Sign In cancelled
  final int status;

  /// **Description:** An error code string that can be used to classify types of errors, and to react to errors.
  ///
  /// **Example:** '[invalid_grant]'
  final String error;

  /// **Description:** A specific error message that can help a developer identify the root cause of an authentication error.
  ///
  /// **Example:** '[AADSTS900144: The request body must contain the following parameter: 'code'...]'
  final String errorDescription;

  /// **Description:** A list of STS-specific error codes that can help in diagnostics.
  ///
  /// **Example:** '[[900144]]'
  final List<dynamic> errorCodes;

  /// **Description:** URL to a Microsoft documentation, concerning the emerged error.
  ///
  /// **Example:** '[https://login.microsoftonline.com/error?code=900144]'
  final String errorUri;

  /// **Description:** Creates a [Token] Object
  Token({
    required this.tokenType,
    required this.scope,
    required this.expiresIn,
    required this.extExpiresIn,
    required this.expiresOn,
    required this.notBefore,
    required this.resource,
    required this.accessToken,
    required this.refreshToken,
    required this.idToken,
    required this.foci,
    required this.status,
    required this.error,
    required this.errorDescription,
    required this.errorCodes,
    required this.errorUri,
  });
}
