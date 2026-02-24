import 'package:teacher_app/core/data_state.dart';

abstract class FileUploadRepository {
  Future<DataState<String>> uploadFile({
    required String filePath,
    String? title,
  });
}
