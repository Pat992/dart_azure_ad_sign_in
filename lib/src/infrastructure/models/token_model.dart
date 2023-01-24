import 'package:dart_azure_aad_sign_in/src/domain/entities/token_entity.dart';

class TokenModel extends Token {
  TokenModel({
    required super.tokenType,
    required super.scope,
    required super.expiresIn,
    required super.extExpiresIn,
    required super.expiresOn,
    required super.notBefore,
    required super.resource,
    required super.accessToken,
    required super.refreshToken,
    required super.idToken,
    required super.foci,
    required super.status,
    required super.error,
    required super.errorDescription,
    required super.errorCodes,
    required super.errorUri,
  });

  Map<String, dynamic> toMap() {
    return {
      'token_type': tokenType,
      'scope': scope,
      'expires_in': expiresIn,
      'ext_expires_in': extExpiresIn,
      'expires_on': expiresOn,
      'not_before': notBefore,
      'resource': resource,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'id_token': idToken,
      'foci': foci,
      'status': status,
      'error': error,
      'error_description': errorDescription,
      'error_codes': errorCodes,
      'error_uri': errorUri,
    };
  }

  factory TokenModel.fromMap(Map<String, dynamic> map) {
    return TokenModel(
      tokenType: map['token_type'] ?? '',
      scope: map['scope'] ?? '',
      expiresIn: map['expires_in'] ?? '',
      extExpiresIn: map['ext_expires_in'] ?? '',
      expiresOn: map['expires_on'] ?? '',
      notBefore: map['not_before'] ?? '',
      resource: map['resource'] ?? '',
      accessToken: map['access_token'] ?? '',
      refreshToken: map['refresh_token'] ?? '',
      idToken: map['id_token'] ?? '',
      foci: map['foci'] ?? '',
      status: map['status'] ?? 0,
      error: map['error'] ?? '',
      errorDescription: map['error_description'] ?? '',
      errorCodes: map['error_codes'] ?? [],
      errorUri: map['error_uri'] ?? '',
    );
  }

  TokenModel copyWith({
    String? tokenType,
    String? scope,
    String? expiresIn,
    String? extExpiresIn,
    String? expiresOn,
    String? notBefore,
    String? resource,
    String? accessToken,
    String? refreshToken,
    String? idToken,
    String? foci,
    int? status,
    String? error,
    String? errorDescription,
    List<String>? errorCodes,
    String? errorUri,
  }) {
    return TokenModel(
      tokenType: tokenType ?? this.tokenType,
      scope: scope ?? this.scope,
      expiresIn: expiresIn ?? this.expiresIn,
      extExpiresIn: extExpiresIn ?? this.extExpiresIn,
      expiresOn: expiresOn ?? this.expiresOn,
      notBefore: notBefore ?? this.notBefore,
      resource: resource ?? this.resource,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      idToken: idToken ?? this.idToken,
      foci: foci ?? this.foci,
      status: status ?? this.status,
      error: error ?? this.error,
      errorDescription: errorDescription ?? this.errorDescription,
      errorCodes: errorCodes ?? this.errorCodes,
      errorUri: errorUri ?? this.errorUri,
    );
  }
}
