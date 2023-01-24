import 'package:dart_azure_aad_sign_in/src/infrastructure/models/token_model.dart';

void main() {
  final TokenModel tokenModel = TokenModel(
    tokenType: 'Bearer',
    scope: 'user_impersonation',
    expiresIn: '5084',
    extExpiresIn: '5084',
    expiresOn: '1674580651',
    notBefore: '1674575266',
    resource: 'https://management.core.windows.net/',
    accessToken: '58941a59-fc3d-45cb-a93a-d04ec5a04097',
    refreshToken: 'f6b69ee5-b13c-4b38-b946-808a61e11eb3',
    idToken: '92ab37e6-be6c-4c40-b3f1-38b50243c4bd',
    foci: '1',
    status: 0,
    error: '',
    errorDescription: '',
    errorCodes: [],
    errorUri: '',
  );
}
