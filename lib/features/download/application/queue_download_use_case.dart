import 'package:bujuan/features/download/download_repository.dart';

/// 批量加入下载队列用例。
class QueueDownloadUseCase {
  /// 创建批量加入下载队列用例。
  QueueDownloadUseCase({required DownloadRepository repository})
      : _repository = repository;

  final DownloadRepository _repository;

  /// 执行批量加入下载队列。
  Future<void> call(
    Iterable<String> trackIds, {
    bool preferHighQuality = true,
  }) {
    return _repository.queueTracks(
      trackIds,
      preferHighQuality: preferHighQuality,
    );
  }
}
