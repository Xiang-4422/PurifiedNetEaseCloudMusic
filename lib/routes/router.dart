import 'package:auto_route/auto_route.dart';
import 'package:bujuan/pages/home/app_home_page_view.dart';
import 'package:bujuan/pages/home/body/app_body_page_view.dart';
import 'package:bujuan/pages/radio/my_radio_view.dart';
import 'package:bujuan/pages/radio/radio_details_view.dart';
import 'package:bujuan/pages/setting/user_setting_view.dart';
import 'package:bujuan/pages/today/today_page_view.dart';

import '../pages/album/album_page_view.dart';
import '../pages/artist/artist_page_view.dart';
import '../pages/cloud/cloud_drive_view.dart';
import '../pages/login/login_page_view.dart';
import '../pages/play_list/playlist_page_view.dart';
import '../pages/update/update_view.dart';

abstract class Routes {
  Routes._();

  static const home = '/home';
  static const index = 'index';
  static const user = 'user';
  static const details = '/details';
  static const splash = '/splash';
  static const setting = 'setting';
  static const playlist = 'playlist';
  static const login = 'login';
  static const search = '/search';
  static const talk = 'talk';
  static const today = 'today';
  static const cloud = 'cloud';
  static const artists = 'artists';
  static const myRadio = 'myRadio';
  static const guide = '/guide';
  static const userSetting = 'userSetting';
  static const mv = '/mv';
  static const update = '/update';
  static const local = 'local';
  static const editSong = '/editSong';
  static const localSong = 'localSong';
  static const radioDetails = 'radioDetails';
  static const imageBlur = '/imageBlur';
  static const coffee = 'coffee';
  static const neteaseCache = 'neteaseCache';
  static const localAlbum = 'localAlbum';
  static const localAr = 'localAr';
  static const albumDetails = 'albumDetails';
  static const playlistManager = 'playlistManager';
}

 

@CupertinoAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    // 登录
    AutoRoute(path: Routes.login, page: LoginPageView),
    // 用户设置（注销登录）
    AutoRoute(path: Routes.userSetting, page: UserSettingView),
    // APP HOME
    AutoRoute(path: Routes.home, page: AppHomePageView, initial: true, children: [
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
class $RootRouter {}
