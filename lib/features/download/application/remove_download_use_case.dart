import 'package:bujuan/features/download/download_repository.dart';

/// 删除下载资源用例。
class RemoveDownloadUseCase {
  /// 创建删除下载资源用例。
  RemoveDownloadUseCase({required DownloadRepository repository})
      : _repository = repository;

  final DownloadRepository _repository;

  /// 执行删除下载资源。
  Future<void> call(String trackId) {
    return _repository.removeDownloadedTrack(trackId);
  }
}
