import 'package:bujuan/features/download/download_repository.dart';

class RemoveDownloadUseCase {
  RemoveDownloadUseCase({required DownloadRepository repository})
      : _repository = repository;

  final DownloadRepository _repository;

  Future<void> call(String trackId) {
    return _repository.removeDownloadedTrack(trackId);
  }
}
