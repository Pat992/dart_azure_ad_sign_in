import 'dart:async';

import 'package:dart_azure_ad_sign_in/src/dart_azure_ad_sign_in_base.dart';
import 'package:dart_azure_ad_sign_in/src/domain/entities/token_entity.dart';

Token? token;
late StreamSubscription<Token> signInSubscription;

void main(List<String> args) async {
  // Create instance of Azure SignIn, all parameters are optional.
  final azureSignIn = AzureSignIn();

  // Print the SignIn URL.
  print(azureSignIn.authUri);

  // Let the user to open the URL and signing in
  // can also b cancelled with azureSignIn.cancelSignIn();
  Token token = await azureSignIn.signIn();

  // Print the token information
  printToken(token: token, title: 'Initial Token');

  // refresh an expired token
  token = await azureSignIn.refreshToken(token: token);

  // Print the updated token information
  printToken(token: token, title: 'Refreshed Token');
}

void printToken({required Token token, required String title}) {
  print(
      '------------------------------------------------------------------------------------------------------------------------------------');
  print(title);
  print(
      '------------------------------------------------------------------------------------------------------------------------------------');
  print('Status: ${token.status}');
  print('Error: ${token.error}');
  print('Error Message: ${token.errorDescription}');
  print('Refresh Token:');
  print(token.accessToken);
  print('Refresh Token:');
  print(token.accessToken);
}
