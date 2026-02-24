import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/activity/data/data_source/file_upload_api.dart';
import 'package:teacher_app/features/activity/domain/repository/file_upload_repository.dart';

@Singleton(as: FileUploadRepository, env: [Env.prod])
class FileUploadRepositoryImpl extends FileUploadRepository {
  final FileUploadApi fileUploadApi;

  FileUploadRepositoryImpl(this.fileUploadApi);

  @override
  Future<DataState<String>> uploadFile({
    required String filePath,
    String? title,
  }) async {
    try {
      final Response response = await fileUploadApi.uploadFile(
        filePath: filePath,
        title: title,
      );

      final String? fileId = response.data['data']?['id'] as String?;
      if (fileId != null && fileId.isNotEmpty) {
        return DataSuccess(fileId);
      } else {
        return DataFailed('Error uploading file');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  DataFailed<T> _handleDioError<T>(DioException e) {
    String errorMessage = 'Error uploading file';

    if (e.response != null) {
      errorMessage = e.response?.data['message'] ??
          e.response?.statusMessage ??
          'Error connecting to server';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Connection timeout';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'Error connecting to server';
    }

    return DataFailed(errorMessage);
  }
}
