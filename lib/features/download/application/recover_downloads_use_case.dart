import 'package:bujuan/domain/entities/download_task.dart';
import 'package:bujuan/features/download/download_repository.dart';

class RecoverDownloadsUseCase {
  RecoverDownloadsUseCase({required DownloadRepository repository})
      : _repository = repository;

  final DownloadRepository _repository;

  Future<List<DownloadTask>> call() {
    return _repository.recoverInterruptedTasks();
  }
}
