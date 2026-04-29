import 'package:bujuan/features/local_media/local_media_scan_repository.dart';

/// 本地扫描页动作入口，避免设置页直接持有扫描 repository。
class LocalMediaScanController {
  /// 创建本地媒体扫描控制器。
  LocalMediaScanController({
    required LocalMediaScanRepository scanRepository,
  }) : _scanRepository = scanRepository;

  final LocalMediaScanRepository _scanRepository;

  /// 扫描并导入目录中的支持音频文件。
  Future<int> importDirectories(List<String> directoryPaths) {
    return _scanRepository.importDirectories(directoryPaths);
  }
}
