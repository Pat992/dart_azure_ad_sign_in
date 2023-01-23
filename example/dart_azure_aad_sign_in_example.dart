import 'package:dart_azure_aad_sign_in/dart_azure_aad_sign_in.dart';

void main() async {
  final azureSignIn = AzureSignIn(serverTimeoutDuration: Duration(minutes: 10));

  print(azureSignIn.authUri);

  final token = await azureSignIn.signIn();
  final token2 = await azureSignIn.signIn();

  print(token.accessToken);

  return;
}
