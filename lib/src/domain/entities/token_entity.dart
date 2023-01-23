class Token {
  final String tokenType;
  final String scope;
  final String expiresIn;
  final String extExpiresIn;
  final String expiresOn;
  final String notBefore;
  final String resource;
  final String accessToken;
  final String refreshToken;
  final String idToken;
  final String foci;
  final int status;
  final String error;
  final String errorDescription;
  final List<String> errorCodes;

  Token({
    required this.tokenType,
    required this.scope,
    required this.expiresIn,
    required this.extExpiresIn,
    required this.expiresOn,
    required this.notBefore,
    required this.resource,
    required this.accessToken,
    required this.refreshToken,
    required this.idToken,
    required this.foci,
    required this.status,
    required this.error,
    required this.errorDescription,
    required this.errorCodes,
  });
}
