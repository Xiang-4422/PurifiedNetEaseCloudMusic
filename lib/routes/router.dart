import 'package:auto_route/auto_route.dart';
import 'package:bujuan/features/album/presentation/album_page_view.dart';
import 'package:bujuan/features/artist/presentation/artist_page_view.dart';
import 'package:bujuan/features/auth/presentation/login_page_view.dart';
import 'package:bujuan/features/cloud/presentation/cloud_drive_view.dart';
import 'package:bujuan/features/playlist/presentation/playlist_page_view.dart';
import 'package:bujuan/features/radio/presentation/my_radio_view.dart';
import 'package:bujuan/features/radio/presentation/radio_details_view.dart';
import 'package:bujuan/features/settings/presentation/update_view.dart';
import 'package:bujuan/features/shell/presentation/app_body_page_view.dart';
import 'package:bujuan/features/shell/presentation/app_home_page_view.dart';
import 'package:bujuan/features/user/presentation/today_page_view.dart';
import 'package:bujuan/features/user/presentation/user_setting_view.dart';

/// Routes。
abstract class Routes {
  Routes._();

  /// home。
  static const home = '/home';

  /// index。
  static const index = 'index';

  /// user。
  static const user = 'user';

  /// details。
  static const details = '/details';

  /// splash。
  static const splash = '/splash';

  /// setting。
  static const setting = 'setting';

  /// playlist。
  static const playlist = 'playlist';

  /// login。
  static const login = 'login';

  /// search。
  static const search = '/search';

  /// talk。
  static const talk = 'talk';

  /// today。
  static const today = 'today';

  /// cloud。
  static const cloud = 'cloud';

  /// artists。
  static const artists = 'artists';

  /// myRadio。
  static const myRadio = 'myRadio';

  /// guide。
  static const guide = '/guide';

  /// userProfile。
  static const userProfile = 'userProfile';

  /// mv。
  static const mv = '/mv';

  /// update。
  static const update = '/update';

  /// local。
  static const local = 'local';

  /// editSong。
  static const editSong = '/editSong';

  /// localSong。
  static const localSong = 'localSong';

  /// radioDetails。
  static const radioDetails = 'radioDetails';

  /// imageBlur。
  static const imageBlur = '/imageBlur';

  /// coffee。
  static const coffee = 'coffee';

  /// neteaseCache。
  static const neteaseCache = 'neteaseCache';

  /// localAlbum。
  static const localAlbum = 'localAlbum';

  /// localAr。
  static const localAr = 'localAr';

  /// albumDetails。
  static const albumDetails = 'albumDetails';

  /// playlistManager。
  static const playlistManager = 'playlistManager';
}

@CupertinoAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    // 登录
    AutoRoute(path: Routes.login, page: LoginPageView, initial: true),
    // 用户设置（注销登录）
    AutoRoute(path: Routes.userProfile, page: UserProfilePageView),
    // APP HOME
    AutoRoute(path: Routes.home, page: AppHomePageView, children: [
      // APP BODY
      AutoRoute(path: Routes.local, page: AppBodyPageView, initial: true),
      // 每日歌单
      AutoRoute(path: Routes.today, page: TodayPageView),
      // 歌单
      AutoRoute(path: Routes.playlist, page: PlayListPageView),
      // 专辑详情
      AutoRoute(path: Routes.albumDetails, page: AlbumPageView),
      // 歌手主页
      AutoRoute(path: Routes.artists, page: ArtistPageView),
      // 播客
      AutoRoute(path: Routes.myRadio, page: MyRadioView),
      // 播客详情
      AutoRoute(path: Routes.radioDetails, page: RadioDetailsView),
      // 云盘
      AutoRoute(path: Routes.cloud, page: CloudDriveView),
    ]),
    // 升级
    AutoRoute(path: Routes.update, page: UpdateView),
  ],
)

/// $RootRouter。
class $RootRouter {}
