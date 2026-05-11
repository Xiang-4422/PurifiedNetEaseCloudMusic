import 'source_type.dart';

/// 音乐资源 id 规范化工具，集中处理应用内部 id 和来源侧 id 的前缀转换。
class MusicResourceId {
  const MusicResourceId._();

  /// 网易云资源前缀。
  static const String neteasePrefix = 'netease:';

  /// 本地资源前缀。
  static const String localPrefix = 'local:';

  /// 当前 id 是否已经带有应用内部来源前缀。
  static bool hasKnownPrefix(String id) {
    return id.startsWith(neteasePrefix) || id.startsWith(localPrefix);
  }

  /// 转为网易云应用内部 id；已带来源前缀时保持不变。
  static String toNeteaseEntityId(String id) {
    if (id.isEmpty || hasKnownPrefix(id)) {
      return id;
    }
    return '$neteasePrefix$id';
  }

  /// 转为网易云来源侧 id；只剥离网易云前缀，本地 id 保持不变。
  static String toNeteaseSourceId(String id) {
    if (id.startsWith(neteasePrefix)) {
      return id.substring(neteasePrefix.length);
    }
    return id;
  }

  /// 转为来源侧 id；会剥离当前已知来源前缀。
  static String toSourceId(String id) {
    if (id.startsWith(neteasePrefix)) {
      return id.substring(neteasePrefix.length);
    }
    if (id.startsWith(localPrefix)) {
      return id.substring(localPrefix.length);
    }
    return id;
  }

  /// 根据 id 前缀解析来源类型，裸 id 默认视为网易云资源。
  static SourceType sourceTypeOf(String id) {
    if (id.startsWith(localPrefix)) {
      return SourceType.local;
    }
    if (id.startsWith(neteasePrefix)) {
      return SourceType.netease;
    }
    return SourceType.netease;
  }
}
