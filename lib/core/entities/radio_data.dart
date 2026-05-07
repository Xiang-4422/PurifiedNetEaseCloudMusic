/// 电台摘要数据。
class RadioSummaryData {
  /// 创建电台摘要数据。
  const RadioSummaryData({
    required this.id,
    required this.name,
    required this.coverUrl,
    required this.lastProgramName,
  });

  /// 电台 id。
  final String id;

  /// 电台名称。
  final String name;

  /// 电台封面地址。
  final String coverUrl;

  /// 最近节目名称。
  final String lastProgramName;

  /// 从 JSON 创建电台摘要。
  factory RadioSummaryData.fromJson(Map<String, dynamic> json) {
    return RadioSummaryData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      lastProgramName: json['lastProgramName'] as String? ?? '',
    );
  }

  /// 转为可持久化 JSON。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coverUrl': coverUrl,
      'lastProgramName': lastProgramName,
    };
  }
}

/// 电台节目数据。
class RadioProgramData {
  /// 创建电台节目数据。
  const RadioProgramData({
    required this.id,
    required this.mainTrackId,
    required this.title,
    required this.coverUrl,
    required this.artistName,
    required this.albumTitle,
    required this.durationMs,
  });

  /// 节目 id。
  final String id;

  /// 主曲目 id。
  final String mainTrackId;

  /// 节目标题。
  final String title;

  /// 节目封面地址。
  final String coverUrl;

  /// 歌手名称。
  final String artistName;

  /// 专辑标题。
  final String albumTitle;

  /// 节目时长，单位毫秒。
  final int durationMs;

  /// 从 JSON 创建电台节目数据。
  factory RadioProgramData.fromJson(Map<String, dynamic> json) {
    return RadioProgramData(
      id: json['id'] as String? ?? '',
      mainTrackId: json['mainTrackId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      albumTitle: json['albumTitle'] as String? ?? '',
      durationMs: json['durationMs'] as int? ?? 0,
    );
  }

  /// 转为可持久化 JSON。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mainTrackId': mainTrackId,
      'title': title,
      'coverUrl': coverUrl,
      'artistName': artistName,
      'albumTitle': albumTitle,
      'durationMs': durationMs,
    };
  }
}
