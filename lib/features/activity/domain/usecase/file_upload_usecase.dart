import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/activity/domain/repository/file_upload_repository.dart';

@singleton
class FileUploadUsecase {
  final FileUploadRepository fileUploadRepository;

  FileUploadUsecase(this.fileUploadRepository);

  Future<DataState<String>> uploadFile({
    required String filePath,
    String? title,
  }) async {
    return await fileUploadRepository.uploadFile(
      filePath: filePath,
      title: title,
    );
  }
}
