// Copyright 2023 Patrick Hettich. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:dart_azure_ad_sign_in/src/domain/entities/token_entity.dart';
import 'package:dart_azure_ad_sign_in/src/domain/repositories/i_sign_in_repository.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/azure_api_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/http_server_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/exceptions/http_server_datasource_exceptions.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/models/token_model.dart';

/// **Description:** Class to sign in and refresh tokens.
class SignInRepository implements ISignInRepository {
  final IAzureApiDatasource azureApiDatasource;
  final IHttpServerDatasource httpServerDatasource;

  SignInRepository({
    required this.azureApiDatasource,
    required this.httpServerDatasource,
  });

  @override
  Future<Token> signIn({
    required String clientId,
    required int port,
    required String serverSuccessResponse,
    required String serverErrorResponse,
    required Duration signInTimeoutDuration,
  }) async {
    final timer = Timer(signInTimeoutDuration, () async {
      await cancelSignIn(port: port);
    });

    TokenModel tokenModel;
    try {
      await httpServerDatasource.startServer(port: port);

      final serverModel = await httpServerDatasource.listenForRequest(
        serverSuccessResponse: serverSuccessResponse,
        serverErrorResponse: serverErrorResponse,
      );

      if (serverModel.code.isNotEmpty) {
        tokenModel = await azureApiDatasource.getToken(
          clientId: clientId,
          code: serverModel.code,
          port: port,
        );
      } else {
        tokenModel = TokenModel.fromMap(serverModel.toMap());
      }
    } on HttpServerSocketException catch (e) {
      tokenModel = TokenModel.fromMap({
        'error': 'http_server_socket_exception',
        'status': 2,
        'error_description':
            '${e.message} - OS-Error ${e.osError} - Address ${e.address} - Port ${e.port}'
      });
    } on HttpServerException catch (_) {
      tokenModel = TokenModel.fromMap({
        'error': 'http_server_exception',
        'status': 2,
        'error_description': 'Error opening Http Server'
      });
    } catch (_) {
      tokenModel = TokenModel.fromMap({
        'error': 'unknown_error',
        'status': 2,
        'error_description': 'Unknown error'
      });
    } finally {
      timer.cancel();
      await httpServerDatasource.stopServer();
    }
    return tokenModel;
  }

  @override
  Future<Token> refreshToken({required Token token}) async {
    final tokenModel = token as TokenModel;

    final refreshedToken =
        await azureApiDatasource.refreshToken(refreshToken: token.refreshToken);

    return tokenModel.copyWith(
      expiresIn: refreshedToken.expiresIn,
      extExpiresIn: refreshedToken.extExpiresIn,
      expiresOn: refreshedToken.expiresOn,
      notBefore: refreshedToken.notBefore,
      accessToken: refreshedToken.accessToken,
      refreshToken: refreshedToken.refreshToken,
    );
  }

  @override
  Future<void> cancelSignIn({required int port}) async {
    await azureApiDatasource.cancelGetToken(port: port);
  }
}
