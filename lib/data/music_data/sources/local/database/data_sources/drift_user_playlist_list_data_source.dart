import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';

import '../dao/playlist_dao.dart';
import 'user_scoped_data_source.dart';

/// Drift 实现的用户歌单列表数据源。
class DriftUserPlaylistListDataSource implements UserPlaylistListDataSource {
  /// 创建 Drift 用户歌单列表数据源。
  const DriftUserPlaylistListDataSource({
    required PlaylistDao dao,
  }) : _dao = dao;

  final PlaylistDao _dao;

  @override
  Future<List<PlaylistSummaryData>> loadPlaylistItems(
    String userId,
    UserPlaylistListKind kind, {
    String? keyword,
  }) {
    return _dao.loadUserPlaylistItems(
      userId,
      kind,
      keyword: keyword,
    );
  }

  @override
  Future<List<PlaylistSummaryData>> searchPlaylistItems(
    String userId,
    String keyword,
  ) {
    return _dao.searchUserPlaylistItems(userId, keyword);
  }

  @override
  Future<void> replacePlaylistItems(
    String userId,
    UserPlaylistListKind kind,
    List<PlaylistSummaryData> items,
  ) {
    return _dao.replaceUserPlaylistItems(
      userId,
      kind,
      items,
    );
  }

  @override
  Future<void> appendPlaylistItems(
    String userId,
    UserPlaylistListKind kind,
    List<PlaylistSummaryData> items, {
    required int startOrder,
  }) {
    return _dao.appendUserPlaylistItems(
      userId,
      kind,
      items,
      startOrder: startOrder,
    );
  }
}
