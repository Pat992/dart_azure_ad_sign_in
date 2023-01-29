// Copyright 2023 Patrick Hettich. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
/// Object used to get and refresh token.
import 'package:dart_azure_ad_sign_in/src/domain/entities/token_entity.dart';

/// **Description:** Interface/Abstract class of the SignInRepository
abstract class ISignInRepository {
  Future<Token> signIn();
  Future<Token> refreshToken({required Token token});
  Future<void> cancelSignIn();
}
