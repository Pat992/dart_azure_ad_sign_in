abstract class AzureApiDatasource {
  Future<Map<String, dynamic>> getToken();
  Future<Map<String, dynamic>> refreshToken();
}

class AzureApiDatasourceImpl implements AzureApiDatasource {
  @override
  Future<Map<String, dynamic>> getToken() {
    // TODO: implement getToken
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> refreshToken() {
    // TODO: implement refreshToken
    throw UnimplementedError();
  }
}
