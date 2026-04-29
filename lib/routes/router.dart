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

/// 应用路由路径常量。
abstract class Routes {
  Routes._();

  /// 首页根路径。
  static const home = '/home';

  /// 首页默认索引子路径。
  static const index = 'index';

  /// 用户页子路径。
  static const user = 'user';

  /// 详情页根路径。
  static const details = '/details';

  /// 启动页根路径。
  static const splash = '/splash';

  /// 设置页子路径。
  static const setting = 'setting';

  /// 歌单页子路径。
  static const playlist = 'playlist';

  /// 登录页路径。
  static const login = 'login';

  /// 搜索页根路径。
  static const search = '/search';

  /// 评论会话页子路径。
  static const talk = 'talk';

  /// 每日推荐页子路径。
  static const today = 'today';

  /// 云盘页子路径。
  static const cloud = 'cloud';

  /// 歌手页子路径。
  static const artists = 'artists';

  /// 我的播客页子路径。
  static const myRadio = 'myRadio';

  /// 引导页根路径。
  static const guide = '/guide';

  /// 用户资料页子路径。
  static const userProfile = 'userProfile';

  /// MV 页根路径。
  static const mv = '/mv';

  /// 应用升级页根路径。
  static const update = '/update';

  /// 本地音乐页子路径。
  static const local = 'local';

  /// 编辑歌曲页根路径。
  static const editSong = '/editSong';

  /// 本地歌曲页子路径。
  static const localSong = 'localSong';

  /// 播客详情页子路径。
  static const radioDetails = 'radioDetails';

  /// 图片模糊设置页根路径。
  static const imageBlur = '/imageBlur';

  /// 咖啡入口子路径。
  static const coffee = 'coffee';

  /// 网易云缓存页子路径。
  static const neteaseCache = 'neteaseCache';

  /// 本地专辑页子路径。
  static const localAlbum = 'localAlbum';

  /// 本地歌手页子路径。
  static const localAr = 'localAr';

  /// 专辑详情页子路径。
  static const albumDetails = 'albumDetails';

  /// 歌单管理页子路径。
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

/// auto_route 生成器使用的根路由声明。
class $RootRouter {}
