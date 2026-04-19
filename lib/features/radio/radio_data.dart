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
}
