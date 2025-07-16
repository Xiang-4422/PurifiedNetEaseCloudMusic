import 'package:auto_route/auto_route.dart';
import 'package:bujuan/pages/guide/guide_view.dart';
import 'package:bujuan/pages/home/app_home_page_view.dart';
import 'package:bujuan/pages/home/body/app_body_page_view.dart';
import 'package:bujuan/pages/radio/my_radio_view.dart';
import 'package:bujuan/pages/radio/radio_details_view.dart';
import 'package:bujuan/pages/setting/user_setting_view.dart';
import 'package:bujuan/pages/today/today_page_view.dart';

import '../pages/album/album_page_view.dart';
import '../pages/artist/artist_page_view.dart';
import '../pages/cloud/cloud_drive_view.dart';
import '../pages/home/body/body_pages/coffee_page.dart';
import '../pages/home/body/body_pages/explore_page.dart';
import '../pages/home/body/body_pages/personal_page.dart';
import '../pages/home/body/body_pages/setting_page.dart';
import '../pages/login/login_page_view.dart';
import '../pages/play_list/playlist_page_view.dart';
import '../pages/splash_page.dart';
import '../pages/update/update_view.dart';

abstract class Routes {
  Routes._();

  static const home = _Paths.home;
  static const index = _Paths.index;
  static const user = _Paths.user;
  static const details = _Paths.details;
  static const splash = _Paths.splash;
  static const setting = _Paths.setting;
  static const playlist = _Paths.playlist;
  static const login = _Paths.login;
  static const search = _Paths.search;
  static const talk = _Paths.talk;
  static const today = _Paths.today;
  static const cloud = _Paths.cloud;
  static const artists = _Paths.artists;
  static const myRadio = _Paths.myRadio;
  static const guide = _Paths.guide;
  static const userSetting = _Paths.userSetting;
  static const mv = _Paths.mv;
  static const update = _Paths.update;
  static const local = _Paths.local;
  static const editSong = _Paths.editSong;
  static const localSong = _Paths.localSong;
  static const radioDetails = _Paths.radioDetails;
  static const imageBlur = _Paths.imageBlur;
  static const coffee = _Paths.coffee;
  static const neteaseCache = _Paths.neteaseCache;
  static const localAlbum = _Paths.localAlbum;
  static const localAr = _Paths.localAr;
  static const albumDetails = _Paths.albumDetails;
  static const playlistManager = _Paths.playlistManager;
}

abstract class _Paths {
  _Paths._();

  static const home = '/home';
  static const index = 'index';
  static const user = 'user';
  static const local = 'local';
  static const search = '/search';
  static const playlist = 'playlist';
  static const details = '/details';
  static const setting = 'setting';
  static const splash = '/splash';
  static const login = 'login';
  static const talk = 'talk';
  static const today = 'today';
  static const cloud = 'cloud';
  static const artists = 'artists';
  static const myRadio = 'myRadio';
  static const radioDetails = 'radioDetails';
  static const guide = '/guide';
  static const userSetting = 'userSetting';
  static const mv = '/mv';
  static const update = '/update';
  static const editSong = '/editSong';
  static const localSong = 'localSong';
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
    // 开屏页
    AutoRoute(path: Routes.splash, page: SplashPage),
    // 引导
    AutoRoute(path: Routes.guide, page: GuideView),
    // 登录
    AutoRoute(path: Routes.login, page: LoginPageView),
    // 用户设置（注销登录）
    AutoRoute(path: Routes.userSetting, page: UserSettingView),
    // APP HOME
    AutoRoute(path: Routes.home, page: AppRootPageView, initial: true, children: [
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
