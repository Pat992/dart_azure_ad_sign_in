import 'package:dart_azure_ad_sign_in/src/domain/entities/token_entity.dart';
import 'package:dart_azure_ad_sign_in/src/domain/repositories/i_sign_in_repository.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/azure_api_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/datasources/http_server_datasource.dart';
import 'package:dart_azure_ad_sign_in/src/infrastructure/repositories/sign_in_repository.dart';

/// Checks if you are awesome. Spoiler: you are.
class AzureSignIn {
  final String clientId;
  final String grantType;
  final int port;
  final String serverSuccessResponse;
  final String serverErrorResponse;
  final String authUri;
  final Duration signInTimeoutDuration;

  final String _oauthUri =
      'https://login.microsoftonline.com/organizations/oauth2/token';

  late final ISignInRepository _signInRepository;
  late final IAzureApiDatasource _azureApiDatasource;
  late final IHttpServerDatasource _httpServerDatasource;

  AzureSignIn({
    this.clientId = '04b07795-8ddb-461a-bbee-02f9e1bf7b46',
    this.port = 8080,
    this.serverSuccessResponse =
        'Sign In successful. This window can now be closed.',
    this.serverErrorResponse =
        'Sign In failed. Close this window and try again',
    this.grantType = 'authorization_code',
    this.signInTimeoutDuration = const Duration(minutes: 5),
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
