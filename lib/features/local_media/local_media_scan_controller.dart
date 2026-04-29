import 'package:bujuan/features/local_media/local_media_scan_repository.dart';

/// 本地扫描页动作入口，避免设置页直接持有扫描 repository。
class LocalMediaScanController {
  /// 创建 LocalMediaScanController。
  LocalMediaScanController({
    required LocalMediaScanRepository scanRepository,
  }) : _scanRepository = scanRepository;

  final LocalMediaScanRepository _scanRepository;

  /// importDirectories。
  Future<int> importDirectories(List<String> directoryPaths) {
    return _scanRepository.importDirectories(directoryPaths);
  }
}
