import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class FileUploadApi {
  final Dio httpclient;
  FileUploadApi(this.httpclient);

  Future<Response> uploadFile({
    required String filePath,
    String? title,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      if (title != null) 'title': title,
    });

    return await httpclient.post(
      '/files',
      data: formData,
    );
  }
}
