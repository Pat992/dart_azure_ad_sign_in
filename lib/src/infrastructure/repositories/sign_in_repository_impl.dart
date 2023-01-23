import 'package:dart_azure_aad_sign_in/src/domain/entities/token_entity.dart';
import 'package:dart_azure_aad_sign_in/src/domain/repositories/sign_in_repository.dart';
import 'package:dart_azure_aad_sign_in/src/infrastructure/datasources/azure_api_datasource.dart';
import 'package:dart_azure_aad_sign_in/src/infrastructure/datasources/http_server_datasource.dart';
import 'package:dart_azure_aad_sign_in/src/infrastructure/models/token_model.dart';

// Todo: some more error handling
class SignInRepositoryImpl implements SignInRepository {
  final int port;
  final String clientId;
  final String grantType;
  final String oauthUri;
  final String serverSuccessResponse;
  final String serverErrorResponse;
  final AzureApiDatasource azureApiDatasource;
  final HttpServerDatasource httpServerDatasource;

  const SignInRepositoryImpl({
    required this.port,
    required this.clientId,
    required this.grantType,
    required this.oauthUri,
    required this.serverSuccessResponse,
    required this.serverErrorResponse,
    required this.azureApiDatasource,
    required this.httpServerDatasource,
  });

  @override
  Future<Token> signIn() async {
    await httpServerDatasource.startServer();

    final code = await httpServerDatasource.listenForRequest();

    final token = await azureApiDatasource.getToken(code: code);

    httpServerDatasource.stopServer();

    return TokenModel.fromMap(token);
  }

  @override
  Future<Token> refreshToken({required Token token}) async {
    final tokenModel = token as TokenModel;
    final refreshedToken =
        await azureApiDatasource.refreshToken(refreshToken: token.refreshToken);

    return tokenModel.copyWith(
      expiresIn: refreshedToken['expires_in'],
      extExpiresIn: refreshedToken['ext_expires_in'],
      expiresOn: refreshedToken['expires_on'],
      notBefore: refreshedToken['not_before'],
      accessToken: refreshedToken['access_token'],
      refreshToken: refreshedToken['refresh_token'],
    );
  }

  @override
  void cancelSignIn() {
    httpServerDatasource.stopServer();
  }
}
