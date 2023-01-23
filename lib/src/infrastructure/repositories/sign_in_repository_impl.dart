import 'package:dart_azure_aad_sign_in/src/domain/entities/token_entity.dart';
import 'package:dart_azure_aad_sign_in/src/domain/repositories/sign_in_repository.dart';

class SignInRepositoryImpl implements SignInRepository {
  @override
  void cancelSignIn() {
    // TODO: implement cancelSignIn
  }

  @override
  Future<Token> refreshToken({required Token token}) {
    // TODO: implement refreshToken
    throw UnimplementedError();
  }

  @override
  Future<Token> signIn() {
    // TODO: implement signIn
    throw UnimplementedError();
  }
}
