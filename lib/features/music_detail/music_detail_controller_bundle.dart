import 'package:bujuan/features/album/album_page_controller_factory.dart';
import 'package:bujuan/features/artist/artist_page_controller_factory.dart';
import 'package:bujuan/features/cloud/cloud_page_controller_factory.dart';
import 'package:bujuan/features/music_detail/music_page_playback_actions.dart';
import 'package:bujuan/features/playlist/playlist_page_controller_factory.dart';
import 'package:bujuan/features/radio/radio_controller_factory.dart';

/// 音乐详情类页面需要的控制器工厂和动作组合。
class MusicDetailControllerBundle {
  /// 创建音乐详情页面控制器组合。
  const MusicDetailControllerBundle({
    required this.albumControllerFactory,
    required this.artistControllerFactory,
    required this.cloudControllerFactory,
    required this.playbackActions,
    required this.playlistControllerFactory,
    required this.radioControllerFactory,
  });

  /// 专辑页控制器工厂。
  final AlbumPageControllerFactory albumControllerFactory;

  /// 歌手页控制器工厂。
  final ArtistPageControllerFactory artistControllerFactory;

  /// 云盘页控制器工厂。
  final CloudPageControllerFactory cloudControllerFactory;

  /// 详情页播放动作。
  final MusicPagePlaybackActions playbackActions;

  /// 歌单页控制器工厂。
  final PlaylistPageControllerFactory playlistControllerFactory;

  /// 播客页控制器工厂。
  final RadioControllerFactory radioControllerFactory;
}
