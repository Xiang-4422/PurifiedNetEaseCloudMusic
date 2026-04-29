import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:bujuan/features/local_media/local_media_scan_repository.dart';
import 'package:get/get.dart';

/// 本地扫描页动作入口，避免设置页直接持有扫描 repository。
class LocalMediaScanController {
  LocalMediaScanController({
    required LocalMediaScanRepository scanRepository,
  }) : _scanRepository = scanRepository;

  factory LocalMediaScanController.create() {
    return LocalMediaScanController(
      scanRepository: LocalMediaScanRepository(
        localMediaRepository: Get.find<LocalMediaRepository>(),
      ),
    );
  }

  final LocalMediaScanRepository _scanRepository;

  Future<int> importDirectories(List<String> directoryPaths) {
    return _scanRepository.importDirectories(directoryPaths);
  }
}
