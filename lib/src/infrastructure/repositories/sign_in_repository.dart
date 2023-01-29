import 'dart:async';

import 'package:dart_azure_ad_sign_in/src/domain/entities/token_entity.dart';
import 'package:dart_azure_ad_sign_in/src/domain/repositories/i_sign_in_repository.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/azure_api_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/http_server_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/exceptions/http_server_datasource_exceptions.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/models/token_model.dart';

// Todo: some more error handling
class SignInRepository implements ISignInRepository {
  final IAzureApiDatasource azureApiDatasource;
  final IHttpServerDatasource httpServerDatasource;
  final Duration signInTimeoutDuration;

  SignInRepository({
    required this.azureApiDatasource,
    required this.httpServerDatasource,
    required this.signInTimeoutDuration,
  });

  @override
  Future<Token> signIn() async {
    final timer = Timer(signInTimeoutDuration, () async {
      await cancelSignIn();
    });

    TokenModel tokenModel;
    try {
      await httpServerDatasource.startServer();

      final serverModel = await httpServerDatasource.listenForRequest();

      if (serverModel.code.isNotEmpty) {
        tokenModel = await azureApiDatasource.getToken(code: serverModel.code);
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
  Future<void> cancelSignIn() async {
    await azureApiDatasource.cancelGetToken();
  }
}
