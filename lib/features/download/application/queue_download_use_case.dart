import 'package:bujuan/features/download/download_repository.dart';

class QueueDownloadUseCase {
  QueueDownloadUseCase({required DownloadRepository repository})
      : _repository = repository;

  final DownloadRepository _repository;

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
