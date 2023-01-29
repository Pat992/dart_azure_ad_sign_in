import 'package:dart_azure_ad_sign_in/dart_azure_ad_sign_in.dart';

void main() async {
  final azureSignIn = AzureSignIn();

  print(azureSignIn.authUri);

  final token = await azureSignIn.signIn();

  print(token.errorDescription);
  print(token.accessToken);
}
