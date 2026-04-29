import 'package:bujuan/domain/entities/download_task.dart';
import 'package:bujuan/features/download/download_repository.dart';

/// 恢复下载任务用例。
class RecoverDownloadsUseCase {
  /// 创建恢复下载任务用例。
  RecoverDownloadsUseCase({required DownloadRepository repository})
      : _repository = repository;

  final DownloadRepository _repository;

  /// 执行下载任务恢复。
  Future<List<DownloadTask>> call() {
    return _repository.recoverInterruptedTasks();
  }
}
