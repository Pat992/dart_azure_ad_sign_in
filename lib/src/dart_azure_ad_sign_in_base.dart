import 'package:dart_azure_ad_sign_in/src/domain/entities/token_entity.dart';
import 'package:dart_azure_ad_sign_in/src/domain/repositories/sign_in_repository.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/azure_api_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/http_server_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/repositories/sign_in_repository_impl.dart';

/// Checks if you are awesome. Spoiler: you are.
class AzureSignIn {
  final String clientId;
  final String grantType;
  final int port;
  final Duration serverTimeoutDuration;
  final String serverSuccessResponse;
  final String serverErrorResponse;

  final String authUri;
  final String _oauthUri =
      'https://login.microsoftonline.com/organizations/oauth2/token';
  late final SignInRepository _signInRepository;
  late final AzureApiDatasource _azureApiDatasource;
  late final HttpServerDatasource _httpServerDatasource;

  AzureSignIn({
    this.clientId = '04b07795-8ddb-461a-bbee-02f9e1bf7b46',
    this.port = 59133,
    this.serverTimeoutDuration = const Duration(minutes: 5),
    this.serverSuccessResponse =
        'SignIn successful. This window can now be closed.',
    this.serverErrorResponse = 'SignIn failed. Close this window and try again',
    this.grantType = 'authorization_code',
  }) : authUri =
            'https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize?client_id=$clientId&response_type=code&redirect_uri=http://localhost:$port&scope=https://management.core.windows.net//.default+offline_access+openid+profile&response_mode=form_post' {
    _initAzureApiDatasource();
    _initHttpServerDatasource();
    _initSignInRepository();
  }

  Future<Token> signIn() async {
    return await _signInRepository.signIn();
  }

  Future<Token> refreshToken({required Token token}) async {
    return await _signInRepository.refreshToken(token: token);
  }

  void cancelSignIn() {
    _signInRepository.cancelSignIn();
  }

  void _initAzureApiDatasource() {
    _azureApiDatasource = AzureApiDatasourceImpl(
      port: port,
      clientId: clientId,
      grantType: grantType,
      oauthUri: _oauthUri,
    );
  }

  void _initHttpServerDatasource() {
    _httpServerDatasource = HttpServerDatasourceImpl(
      port: port,
      serverSuccessResponse: serverSuccessResponse,
      serverErrorResponse: serverErrorResponse,
    );
  }

  void _initSignInRepository() {
    _signInRepository = SignInRepositoryImpl(
      port: port,
      clientId: clientId,
      grantType: grantType,
      oauthUri: _oauthUri,
      serverSuccessResponse: serverSuccessResponse,
      serverErrorResponse: serverErrorResponse,
      serverTimeoutDuration: serverTimeoutDuration,
      azureApiDatasource: _azureApiDatasource,
      httpServerDatasource: _httpServerDatasource,
    );
  }
}
