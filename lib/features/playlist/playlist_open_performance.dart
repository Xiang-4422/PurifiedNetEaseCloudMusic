import 'package:bujuan/features/playlist/playlist_page_controller.dart';
import 'package:flutter/foundation.dart';

/// 缓存歌单打开指标的数据来源。
enum CachedPlaylistOpenSource {
  /// 本地缓存直接给出首个可展示结果。
  local,

  /// 本地缓存不可展示，使用远程首屏兜底。
  remote,
}

/// 缓存歌单打开指标的展示结果。
enum CachedPlaylistOpenResult {
  /// 已展示完整歌曲列表。
  complete,

  /// 已展示部分歌曲列表，剩余歌曲继续补全。
  partial,

  /// 只展示歌单标题、封面或歌曲数量等元信息。
  metadataOnly,

  /// 没有可展示的缓存或远程歌曲。
  empty,

  /// 远程兜底失败。
  error,
}

/// 缓存歌单打开指标快照。
@immutable
class CachedPlaylistOpenSnapshot {
  /// 创建缓存歌单打开指标快照。
  const CachedPlaylistOpenSnapshot({
    required this.source,
    required this.result,
    required this.songs,
    required this.state,
    required this.hasMetadata,
    this.expectedTracks,
  });

  /// 从本地详情状态创建指标快照。
  factory CachedPlaylistOpenSnapshot.local({
    required PlaylistLocalDetailState state,
    required int songs,
    required bool hasMetadata,
    int? expectedTracks,
  }) {
    return CachedPlaylistOpenSnapshot(
      source: CachedPlaylistOpenSource.local,
      result: _localResult(
        state: state,
        songs: songs,
        hasMetadata: hasMetadata,
      ),
      songs: songs,
      state: state.name,
      hasMetadata: hasMetadata,
      expectedTracks: expectedTracks,
    );
  }

  /// 从远程兜底后的页面状态创建指标快照。
  factory CachedPlaylistOpenSnapshot.remote({
    required int songs,
    required String state,
    required bool hasMetadata,
    int? expectedTracks,
  }) {
    return CachedPlaylistOpenSnapshot(
      source: CachedPlaylistOpenSource.remote,
      result: _remoteResult(
        state: state,
        songs: songs,
      ),
      songs: songs,
      state: state,
      hasMetadata: hasMetadata,
      expectedTracks: expectedTracks,
    );
  }

  /// 数据来源。
  final CachedPlaylistOpenSource source;

  /// 首个可展示结果。
  final CachedPlaylistOpenResult result;

  /// 首屏可展示歌曲数。
  final int songs;

  /// 原始状态名，用于和页面状态机或本地完整性状态对齐。
  final String state;

  /// 是否已有可展示的歌单元信息。
  final bool hasMetadata;

  /// 已知歌单歌曲总数。
  final int? expectedTracks;

  /// 转为稳定日志详情。
  String toLogDetails() {
    final fields = <String>[
      'source=${source.logValue}',
      'result=${result.logValue}',
      'songs=$songs',
      'state=$state',
      'hasMetadata=$hasMetadata',
    ];
    final expected = expectedTracks;
    if (expected != null) {
      fields.add('expected=$expected');
    }
    return fields.join(' ');
  }

  static CachedPlaylistOpenResult _localResult({
    required PlaylistLocalDetailState state,
    required int songs,
    required bool hasMetadata,
  }) {
    if (state == PlaylistLocalDetailState.complete && songs > 0) {
      return CachedPlaylistOpenResult.complete;
    }
    if (state == PlaylistLocalDetailState.partial && songs > 0) {
      return CachedPlaylistOpenResult.partial;
    }
    if (hasMetadata) {
      return CachedPlaylistOpenResult.metadataOnly;
    }
    return CachedPlaylistOpenResult.empty;
  }

  static CachedPlaylistOpenResult _remoteResult({
    required String state,
    required int songs,
  }) {
    if (state == 'loadFailedEmpty' || state == 'loadFailedWithPartial') {
      return CachedPlaylistOpenResult.error;
    }
    if (state == 'showingFull' && songs > 0) {
      return CachedPlaylistOpenResult.complete;
    }
    if (songs > 0) {
      return CachedPlaylistOpenResult.partial;
    }
    return CachedPlaylistOpenResult.empty;
  }
}

extension on CachedPlaylistOpenSource {
  String get logValue {
    switch (this) {
      case CachedPlaylistOpenSource.local:
        return 'local';
      case CachedPlaylistOpenSource.remote:
        return 'remote';
    }
  }
}

extension on CachedPlaylistOpenResult {
  String get logValue {
    switch (this) {
      case CachedPlaylistOpenResult.complete:
        return 'complete';
      case CachedPlaylistOpenResult.partial:
        return 'partial';
      case CachedPlaylistOpenResult.metadataOnly:
        return 'metadata_only';
      case CachedPlaylistOpenResult.empty:
        return 'empty';
      case CachedPlaylistOpenResult.error:
        return 'error';
    }
  }
}
