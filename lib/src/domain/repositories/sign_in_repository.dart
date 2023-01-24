import 'package:dart_azure_ad_sign_in/src/domain/entities/token_entity.dart';

abstract class SignInRepository {
  Future<Token> signIn();
  Future<Token> refreshToken({required Token token});
  void cancelSignIn();
}
