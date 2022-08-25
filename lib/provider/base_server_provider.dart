import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:universal_io/io.dart';

import 'base_provider.dart';

abstract class BaseServerProvider extends BaseProvider {
  abstract String apiUrl;

  Future<String> getUserAgent();

  Future<Dio> dio() async {
    return Dio(BaseOptions(
      baseUrl: 'https://$apiUrl/',
      headers: await getHeaders(),
      connectTimeout: 15000,
      contentType: 'application/json; charset=utf-8',
    ));
  }

  Future<String> uploadFile(String model, String id, File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap(<String, dynamic>{
      'model': model,
      'id': id,
      'media_type': 'file',
      'collection': 'images',
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    var response = await (await dio()).post<Map<dynamic, dynamic>>('/api/upload', data: formData);
    return response.data!['id'] as String;
  }

  String getImageUrl(String uuid) {
    return 'https://$apiUrl/api/fetch_file/$uuid';
  }

  Future<Map<String, dynamic>> getHeaders() async {
    var headers = {
      'accept': 'application/json',
      'user-agent': await getUserAgent(),
      'authorization': accessToken != null ? 'Bearer $accessToken' : 'Bearer null',
    };
    return headers;
  }

  String? get accessToken {
    final login = Hive.box<dynamic>('settings');
    return login.get('accessToken', defaultValue: null) as String?;
  }

  set accessToken(String? value) {
    final login = Hive.box<dynamic>('settings');
    login.put('accessToken', value);
  }

  String? get refreshToken {
    final login = Hive.box<dynamic>('settings');
    return login.get('refreshToken', defaultValue: null) as String?;
  }

  set refreshToken(String? value) {
    final login = Hive.box<dynamic>('settings');
    login.put('refreshToken', value);
  }

  DateTime? get expiresIn {
    final login = Hive.box<dynamic>('settings');
    return DateTime.fromMillisecondsSinceEpoch((login.get('expiresIn', defaultValue: 0) as int?) ?? 0);
  }

  set expiresIn(DateTime? value) {
    final login = Hive.box<dynamic>('settings');
    login.put('expiresIn', value?.millisecondsSinceEpoch);
  }
}
