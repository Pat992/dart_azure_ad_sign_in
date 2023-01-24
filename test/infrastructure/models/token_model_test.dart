import 'dart:convert';

import 'package:dart_azure_aad_sign_in/src/domain/entities/token_entity.dart';
import 'package:dart_azure_aad_sign_in/src/infrastructure/models/token_model.dart';
import 'package:test/test.dart';

import '../../fixtures/fixtures_reader.dart';

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

  final errorTokenModel = TokenModel(
    tokenType: '',
    scope: '',
    expiresIn: '',
    extExpiresIn: '',
    expiresOn: '',
    notBefore: '',
    resource: '',
    accessToken: '',
    refreshToken: '',
    idToken: '',
    foci: '',
    status: 0,
    error: 'invalid_request',
    errorDescription:
        "AADSTS900144: The request body must contain the following parameter: 'code'.\r\nTrace ID: f6b69ee5-b13c-4b38-b946-808a61e11eb3\r\nCorrelation ID: 92ab37e6-be6c-4c40-b3f1-38b50243c4bd\r\nTimestamp: 2023-01-24 16:03:14Z",
    errorCodes: [900144],
    errorUri: 'https://login.microsoftonline.com/error?code=900144',
  );

  final refreshToken = TokenModel(
    tokenType: 'Bearer',
    scope: 'user_impersonation',
    expiresIn: '5084',
    extExpiresIn: '5084',
    expiresOn: '1674580651',
    notBefore: '1674575266',
    resource: 'https://management.core.windows.net/',
    accessToken:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
    refreshToken:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IlJlZnJlc2ggdG9rZW4iLCJpYXQiOjE1MTYyMzkwMjJ9.cQkCwQMKS_7f7OnYGiSuhXzg3nAugUvPNfYoquPoB5k',
    idToken: '',
    foci: '1',
    status: 0,
    error: '',
    errorDescription: '',
    errorCodes: [],
    errorUri: '',
  );

  test('Model is subclass of Token entity', () {
    // arrange
    // act
    // assert
    expect(tokenModel, isA<Token>());
  });

  group('fromMap factory', () {
    test('Returns valid model if response is successful', () {
      // arrange
      Map<String, dynamic> token = json.decode(fixture('token_success.json'));
      // act
      final res = TokenModel.fromMap(token);
      // assert
      expect(res.toMap(), tokenModel.toMap());
    });

    test('Returns valid model if response has failed', () {
      // arrange
      Map<String, dynamic> token = json.decode(fixture('token_error.json'));
      // act
      final res = TokenModel.fromMap(token);
      // assert
      expect(res.toMap(), errorTokenModel.toMap());
    });

    test('Returns updated model if token has been refreshed', () {
      // arrange
      Map<String, dynamic> token = json.decode(fixture('token_refresh.json'));
      // act
      final res = TokenModel.fromMap(token);
      // assert
      expect(res.toMap(), refreshToken.toMap());
    });
  });
}
