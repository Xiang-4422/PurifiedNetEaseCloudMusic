/// Metadata keys that are represented by explicit [PlaybackQueueItem] fields or
/// are not part of the playback experience.
const Set<String> playbackQueueReservedMetadataKeys = {
  'albumId',
  'artistIds',
  'sourceType',
  'localLyricsPath',
  'availability',
  'mv',
  'fee',
  'publishTime',
  'cloudSongId',
  'cloudFileName',
  'cloudAddTime',
  'scanSource',
  'scannedAt',
};

/// Returns only caller-owned custom metadata for playback queue items.
Map<String, dynamic> playbackQueueCustomMetadata(
  Map<dynamic, dynamic> metadata, {
  Set<String> additionalReservedKeys = const {},
}) {
  final customMetadata = <String, dynamic>{};
  for (final entry in metadata.entries) {
    customMetadata['${entry.key}'] = entry.value;
  }
  for (final key in playbackQueueReservedMetadataKeys) {
    customMetadata.remove(key);
  }
  for (final key in additionalReservedKeys) {
    customMetadata.remove(key);
  }
  return customMetadata;
}
