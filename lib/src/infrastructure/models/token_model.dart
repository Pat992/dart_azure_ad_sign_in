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
  });

  Map<String, dynamic> toMap() {
    return {
      'tokenType': tokenType,
      'scope': scope,
      'expiresIn': expiresIn,
      'extExpiresIn': extExpiresIn,
      'expiresOn': expiresOn,
      'notBefore': notBefore,
      'resource': resource,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'idToken': idToken,
      'foci': foci,
      'status': status,
      'error': error,
      'errorDescription': errorDescription,
      'errorCodes': errorCodes,
    };
  }

  factory TokenModel.fromMap(Map<String, dynamic> map) {
    return TokenModel(
      tokenType: map['tokenType'] as String,
      scope: map['scope'] as String,
      expiresIn: map['expiresIn'] as String,
      extExpiresIn: map['extExpiresIn'] as String,
      expiresOn: map['expiresOn'] as String,
      notBefore: map['notBefore'] as String,
      resource: map['resource'] as String,
      accessToken: map['accessToken'] as String,
      refreshToken: map['refreshToken'] as String,
      idToken: map['idToken'] as String,
      foci: map['foci'] as String,
      status: map['status'] as int,
      error: map['error'] as String,
      errorDescription: map['errorDescription'] as String,
      errorCodes: map['errorCodes'] as List<String>,
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
    );
  }
}
