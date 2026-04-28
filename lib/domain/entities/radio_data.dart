class RadioSummaryData {
  const RadioSummaryData({
    required this.id,
    required this.name,
    required this.coverUrl,
    required this.lastProgramName,
  });

  final String id;
  final String name;
  final String coverUrl;
  final String lastProgramName;

  factory RadioSummaryData.fromJson(Map<String, dynamic> json) {
    return RadioSummaryData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      lastProgramName: json['lastProgramName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coverUrl': coverUrl,
      'lastProgramName': lastProgramName,
    };
  }
}

class RadioProgramData {
  const RadioProgramData({
    required this.id,
    required this.mainTrackId,
    required this.title,
    required this.coverUrl,
    required this.artistName,
    required this.albumTitle,
    required this.durationMs,
  });

  final String id;
  final String mainTrackId;
  final String title;
  final String coverUrl;
  final String artistName;
  final String albumTitle;
  final int durationMs;

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
