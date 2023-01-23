class Token {
  String tokenType;
  String scope;
  String expiresIn;
  String extExpiresIn;
  String expiresOn;
  String notBefore;
  String resource;
  String accessToken;
  String refreshToken;
  String idToken;
  String foci;
  int status;
  String error;
  String errorDescription;
  List<String> errorCodes;

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
