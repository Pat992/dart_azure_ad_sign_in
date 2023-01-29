// Copyright 2023 Patrick Hettich. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:dart_azure_ad_sign_in/src/domain/entities/token_entity.dart';
import 'package:dart_azure_ad_sign_in/src/domain/repositories/i_sign_in_repository.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/azure_api_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/http_server_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/repositories/sign_in_repository.dart';

/// Sign user into [Azure] via [Active Directory], using [OAuth 2.0].
class AzureSignIn {
  /// **Description:** The Application (client) ID that the Azure portal – App registrations page assigned to your app.
  /// Uses the AZ CLI client ID by default, no app registration necessary.
  ///
  /// **Default value:** [04b07795-8ddb-461a-bbee-02f9e1bf7b46]
  final String clientId;

  /// **Description:** Grant Type for the authorization flow.
  ///
  /// Must be [authorization_code] for the authorization code flow.
  final String grantType = 'authorization_code';

  /// **Description:** Port of the Local HttpServer which will receive the code after sign in.
  ///
  /// **Default value:** 8080
  final int port;

  /// **Description:** Response of the Local HttpServer, which the user will see after successfully logging in.
  /// Can be simple Text or HTML.
  ///
  /// **Default value:** Sign In successful. This window can now be closed.
  final String serverSuccessResponse;

  /// **Description:** Response of the Local HttpServer, which the user will see after sign in failure.
  /// Can be simple Text or HTML.
  ///
  /// **Default value:** Sign In failed. Close this window and try again.
  final String serverErrorResponse;

  /// **Description:** Duration on how long the local HttpServer waits, for the user to sign in.
  /// Can be any Duration
  ///
  /// **Default value:** Duration(minutes: 5).
  final Duration signInTimeoutDuration;

  /// **Description:** Azure Auth URL used to Sign In via Web, can not be modified.
  ///
  /// **Default value:** *https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize?client_id=$clientId&response_type=code&redirect_uri=http://localhost:$port&scope=https://management.core.windows.net//.default+offline_access+openid+profile&response_mode=form_post*
  final String authUri;

  final String _oauthUri =
      'https://login.microsoftonline.com/organizations/oauth2/token';

  late final ISignInRepository _signInRepository;
  late final IAzureApiDatasource _azureApiDatasource;
  late final IHttpServerDatasource _httpServerDatasource;

  /// **Sign In user to Azure via Active Directory, using OAuth 2.0.**
  ///
  /// **clientId** The Application (client) ID that the Azure portal – App registrations page assigned to your app.
  ///
  /// [Type:] String *optional*
  ///
  /// [Default value:] '04b07795-8ddb-461a-bbee-02f9e1bf7b46' (AZ CLI client)
  ///
  /// **port** Port of the Local HttpServer which will receive the code after sign in.
  ///
  /// [Type:] int *optional*
  ///
  /// [Default value:] 8080
  ///
  /// **serverSuccessResponse** Response of the Local HttpServer, which the user will see after successfully logging in.
  /// Can be a Simple Text-String or a HTTP-String
  ///
  /// [Type:] String *optional*
  ///
  /// [Default value:] 'Sign In successful. This window can now be closed.'
  ///
  /// **serverErrorResponse** Response of the Local HttpServer, which the user will see after sign in failure.
  /// Can be a Simple Text-String or a HTTP-String
  ///
  /// [Type:] String *optional*
  ///
  /// [Default value:] 'Sign In failed. Close this window and try again'
  AzureSignIn({
    this.clientId = '04b07795-8ddb-461a-bbee-02f9e1bf7b46',
    this.port = 8080,
    this.serverSuccessResponse =
        'Sign In successful. This window can now be closed.',
    this.serverErrorResponse =
        'Sign In failed. Close this window and try again',
    this.signInTimeoutDuration = const Duration(minutes: 5),
  }) : authUri =
            'https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize?client_id=$clientId&response_type=code&redirect_uri=http://localhost:$port&scope=https://management.core.windows.net//.default+offline_access+openid+profile&response_mode=form_post' {
    _initAzureApiDatasource();
    _initHttpServerDatasource();
    _initSignInRepository();
  }

  /// **Description:** Sign In user to Azure.
  /// Starts a local HttpServer awaits the code from the authUri and sends it to the Azure API to get a token.
  /// Open the [AzureSignIn.authUri] in a Browser to Sign In.
  ///
  /// **Parameter:** None
  ///
  /// **Returns:** A new Token-Object, check the [Token.status] to check for error or success.
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
  Future<Token> signIn() async {
    return await _signInRepository.signIn();
  }

  /// **Description:** Refresh an existing Token.
  /// Sends the Refresh Token to the Azure API to receive a new one.
  /// Open the [AzureSignIn.authUri] in a Browser to Sign In.
  ///
  /// **Parameter:** [Token]
  ///
  /// **Returns:** A new Token-Object, check the [Token.status] to check for error or success.
  ///
  /// **Status codes:**
  ///
  /// 0: Success
  ///
  /// 1: Azure API error
  Future<Token> refreshToken({required Token token}) async {
    return await _signInRepository.refreshToken(token: token);
  }

  /// **Description:** Cancel an open Sign In, will also automatically called once [AzureSignIn.signInTimeoutDuration] is reached.
  /// Sends a request for cancelling to the local HttpServer, which then will return a new [Token]
  ///
  /// **Parameter:** None
  ///
  /// **Returns:** None.
  Future<void> cancelSignIn() async {
    await _signInRepository.cancelSignIn();
  }

  void _initAzureApiDatasource() {
    _azureApiDatasource = AzureApiDatasource(
      port: port,
      clientId: clientId,
      grantType: grantType,
      oauthUri: _oauthUri,
    );
  }

  void _initHttpServerDatasource() {
    _httpServerDatasource = HttpServerDatasource(
      port: port,
      serverSuccessResponse: serverSuccessResponse,
      serverErrorResponse: serverErrorResponse,
    );
  }

  void _initSignInRepository() {
    _signInRepository = SignInRepository(
      azureApiDatasource: _azureApiDatasource,
      httpServerDatasource: _httpServerDatasource,
      signInTimeoutDuration: signInTimeoutDuration,
    );
  }
}
