// Copyright 2023 Patrick Hettich. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dart_azure_ad_sign_in/dart_azure_ad_sign_in.dart';

void main(List<String> args) async {
  // Create instance of Azure SignIn, all parameters are optional.
  final azureSignIn = AzureSignIn();

  // Print the SignIn URL.
  print(azureSignIn.signInUri);

  // Opens the HTTP-Server and waits for the user to sign-in.
  // can also be cancelled with azureSignIn.cancelSignIn();
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
