import 'package:dart_azure_ad_sign_in/src/dart_azure_ad_sign_in_base.dart';

void main() async {
  final azureSignIn = AzureSignIn();

  print(azureSignIn.authUri);

  final token = await azureSignIn.signIn();

  print(token.errorDescription);
  print(token.accessToken);
}
