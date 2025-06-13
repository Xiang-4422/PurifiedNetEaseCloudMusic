// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i23;
import 'package:flutter/material.dart' as _i24;

import '../pages/album/album_details.dart' as _i4;
import '../pages/artists/artists_view.dart' as _i5;
import '../pages/guide/guide_view.dart' as _i7;
import '../pages/home/view/home_page_view.dart' as _i2;
import '../pages/index/cloud_drive_view.dart' as _i17;
import '../pages/index/explore_page_view.dart' as _i11;
import '../pages/login/login.dart' as _i18;
import '../pages/mv/mv_view.dart' as _i6;
import '../pages/play_list/playlist_view.dart' as _i20;
import '../pages/playlist_manager/playlist_manager_view.dart' as _i21;
import '../pages/radio/my_radio_view.dart' as _i15;
import '../pages/radio/radio_details_view.dart' as _i16;
import '../pages/search/search_view.dart' as _i3;
import '../pages/setting/coffee.dart' as _i13;
import '../pages/setting/image_blur.dart' as _i9;
import '../pages/setting/setting_page_view.dart' as _i12;
import '../pages/setting/user_setting_view.dart' as _i19;
import '../pages/splash_page.dart' as _i1;
import '../pages/talk/comment_page_view.dart' as _i22;
import '../pages/today/today_view.dart' as _i14;
import '../pages/update/update_view.dart' as _i8;
import '../pages/user/personal_page_view.dart' as _i10;

class RootRouter extends _i23.RootStackRouter {
  RootRouter([_i24.GlobalKey<_i24.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i23.PageFactory> pagesMap = {
    SplashRoute.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i1.SplashPage(),
      );
    },
    HomeRouteView.name: (routeData) {
      final args = routeData.argsAs<HomeRouteViewArgs>(
          orElse: () => const HomeRouteViewArgs());
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: _i2.HomePageView(
          key: args.key,
          body: args.body,
        ),
      );
    },
    SearchView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i3.SearchView(),
      );
    },
    AlbumDetails.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i4.AlbumDetails(),
      );
    },
    ArtistsView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i5.ArtistsView(),
      );
    },
    MvView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i6.MvView(),
      );
    },
    GuideView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i7.GuideView(),
      );
    },
    UpdateView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i8.UpdateView(),
      );
    },
    ImageBlur.name: (routeData) {
      final args = routeData.argsAs<ImageBlurArgs>();
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: _i9.ImageBlur(
          key: args.key,
          path: args.path,
        ),
      );
    },
    RouteOne.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i10.PageOne(),
      );
    },
    RouteTwo.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i11.PageTwo(),
      );
    },
    SettingRouteView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i12.SettingPageView(),
      );
    },
    CoffeeRoute.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i13.CoffeePage(),
      );
    },
    PersonalRouteView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i10.PersonalPageView(),
      );
    },
    TodayView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i14.TodayView(),
      );
    },
    MyRadioView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i15.MyRadioView(),
      );
    },
    RadioDetailsView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i16.RadioDetailsView(),
      );
    },
    CloudDriveView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i17.CloudDriveView(),
      );
    },
    LoginView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i18.LoginView(),
      );
    },
    UserSettingView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i19.UserSettingView(),
      );
    },
    PlayListView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i20.PlayListView(),
      );
    },
    PlaylistManagerView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i21.PlaylistManagerView(),
      );
    },
    TalkView.name: (routeData) {
      final args =
          routeData.argsAs<TalkViewArgs>(orElse: () => const TalkViewArgs());
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: _i22.CommentPageView(
          key: args.key,
          id: args.id,
          type: args.type,
        ),
      );
    },
    ExploreRouteView.name: (routeData) {
      return _i23.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i11.ExplorePageView(),
      );
    },
  };

  @override
  List<_i23.RouteConfig> get routes => [
        _i23.RouteConfig(
          '/#redirect',
          path: '/',
          redirectTo: '/splash',
          fullMatch: true,
        ),
        _i23.RouteConfig(
          SplashRoute.name,
          path: '/splash',
        ),
        _i23.RouteConfig(
          HomeRouteView.name,
          path: '/home',
          children: [
            _i23.RouteConfig(
              RouteOne.name,
              path: 'page_one',
              parent: HomeRouteView.name,
              children: [
                _i23.RouteConfig(
                  '#redirect',
                  path: '',
                  parent: RouteOne.name,
                  redirectTo: 'user',
                  fullMatch: true,
                ),
                _i23.RouteConfig(
                  PersonalRouteView.name,
                  path: 'user',
                  parent: RouteOne.name,
                ),
                _i23.RouteConfig(
                  TodayView.name,
                  path: 'today',
                  parent: RouteOne.name,
                ),
                _i23.RouteConfig(
                  MyRadioView.name,
                  path: 'myRadio',
                  parent: RouteOne.name,
                ),
                _i23.RouteConfig(
                  RadioDetailsView.name,
                  path: 'radioDetails',
                  parent: RouteOne.name,
                ),
                _i23.RouteConfig(
                  CloudDriveView.name,
                  path: 'cloud',
                  parent: RouteOne.name,
                ),
                _i23.RouteConfig(
                  LoginView.name,
                  path: 'login',
                  parent: RouteOne.name,
                ),
                _i23.RouteConfig(
                  UserSettingView.name,
                  path: 'userSetting',
                  parent: RouteOne.name,
                ),
                _i23.RouteConfig(
                  PlayListView.name,
                  path: 'playlist',
                  parent: RouteOne.name,
                ),
                _i23.RouteConfig(
                  PlaylistManagerView.name,
                  path: 'playlistManager',
                  parent: RouteOne.name,
                ),
                _i23.RouteConfig(
                  TalkView.name,
                  path: 'talk',
                  parent: RouteOne.name,
                ),
              ],
            ),
            _i23.RouteConfig(
              RouteTwo.name,
              path: 'page_two',
              parent: HomeRouteView.name,
              children: [
                _i23.RouteConfig(
                  '#redirect',
                  path: '',
                  parent: RouteTwo.name,
                  redirectTo: 'index',
                  fullMatch: true,
                ),
                _i23.RouteConfig(
                  ExploreRouteView.name,
                  path: 'index',
                  parent: RouteTwo.name,
                ),
                _i23.RouteConfig(
                  PlayListView.name,
                  path: 'playlist',
                  parent: RouteTwo.name,
                ),
                _i23.RouteConfig(
                  TalkView.name,
                  path: 'talk',
                  parent: RouteTwo.name,
                ),
              ],
            ),
            _i23.RouteConfig(
              SettingRouteView.name,
              path: 'setting',
              parent: HomeRouteView.name,
            ),
            _i23.RouteConfig(
              CoffeeRoute.name,
              path: 'coffee',
              parent: HomeRouteView.name,
            ),
          ],
        ),
        _i23.RouteConfig(
          SearchView.name,
          path: 'search',
        ),
        _i23.RouteConfig(
          AlbumDetails.name,
          path: 'albumDetails',
        ),
        _i23.RouteConfig(
          ArtistsView.name,
          path: 'artists',
        ),
        _i23.RouteConfig(
          MvView.name,
          path: '/mv',
        ),
        _i23.RouteConfig(
          GuideView.name,
          path: '/guide',
        ),
        _i23.RouteConfig(
          UpdateView.name,
          path: '/update',
        ),
        _i23.RouteConfig(
          ImageBlur.name,
          path: '/imageBlur',
        ),
      ];
}

/// generated route for
/// [_i1.SplashPage]
class SplashRoute extends _i23.PageRouteInfo<void> {
  const SplashRoute()
      : super(
          SplashRoute.name,
          path: '/splash',
        );

  static const String name = 'SplashRoute';
}

/// generated route for
/// [_i2.HomePageView]
class HomeRouteView extends _i23.PageRouteInfo<HomeRouteViewArgs> {
  HomeRouteView({
    _i24.Key? key,
    _i24.Widget? body,
    List<_i23.PageRouteInfo>? children,
  }) : super(
          HomeRouteView.name,
          path: '/home',
          args: HomeRouteViewArgs(
            key: key,
            body: body,
          ),
          initialChildren: children,
        );

  static const String name = 'HomeRouteView';
}

class HomeRouteViewArgs {
  const HomeRouteViewArgs({
    this.key,
    this.body,
  });

  final _i24.Key? key;

  final _i24.Widget? body;

  @override
  String toString() {
    return 'HomeRouteViewArgs{key: $key, body: $body}';
  }
}

/// generated route for
/// [_i3.SearchView]
class SearchView extends _i23.PageRouteInfo<void> {
  const SearchView()
      : super(
          SearchView.name,
          path: 'search',
        );

  static const String name = 'SearchView';
}

/// generated route for
/// [_i4.AlbumDetails]
class AlbumDetails extends _i23.PageRouteInfo<void> {
  const AlbumDetails()
      : super(
          AlbumDetails.name,
          path: 'albumDetails',
        );

  static const String name = 'AlbumDetails';
}

/// generated route for
/// [_i5.ArtistsView]
class ArtistsView extends _i23.PageRouteInfo<void> {
  const ArtistsView()
      : super(
          ArtistsView.name,
          path: 'artists',
        );

  static const String name = 'ArtistsView';
}

/// generated route for
/// [_i6.MvView]
class MvView extends _i23.PageRouteInfo<void> {
  const MvView()
      : super(
          MvView.name,
          path: '/mv',
        );

  static const String name = 'MvView';
}

/// generated route for
/// [_i7.GuideView]
class GuideView extends _i23.PageRouteInfo<void> {
  const GuideView()
      : super(
          GuideView.name,
          path: '/guide',
        );

  static const String name = 'GuideView';
}

/// generated route for
/// [_i8.UpdateView]
class UpdateView extends _i23.PageRouteInfo<void> {
  const UpdateView()
      : super(
          UpdateView.name,
          path: '/update',
        );

  static const String name = 'UpdateView';
}

/// generated route for
/// [_i9.ImageBlur]
class ImageBlur extends _i23.PageRouteInfo<ImageBlurArgs> {
  ImageBlur({
    _i24.Key? key,
    required String path,
  }) : super(
          ImageBlur.name,
          path: '/imageBlur',
          args: ImageBlurArgs(
            key: key,
            path: path,
          ),
        );

  static const String name = 'ImageBlur';
}

class ImageBlurArgs {
  const ImageBlurArgs({
    this.key,
    required this.path,
  });

  final _i24.Key? key;

  final String path;

  @override
  String toString() {
    return 'ImageBlurArgs{key: $key, path: $path}';
  }
}

/// generated route for
/// [_i10.PageOne]
class RouteOne extends _i23.PageRouteInfo<void> {
  const RouteOne({List<_i23.PageRouteInfo>? children})
      : super(
          RouteOne.name,
          path: 'page_one',
          initialChildren: children,
        );

  static const String name = 'RouteOne';
}

/// generated route for
/// [_i11.PageTwo]
class RouteTwo extends _i23.PageRouteInfo<void> {
  const RouteTwo({List<_i23.PageRouteInfo>? children})
      : super(
          RouteTwo.name,
          path: 'page_two',
          initialChildren: children,
        );

  static const String name = 'RouteTwo';
}

/// generated route for
/// [_i12.SettingPageView]
class SettingRouteView extends _i23.PageRouteInfo<void> {
  const SettingRouteView()
      : super(
          SettingRouteView.name,
          path: 'setting',
        );

  static const String name = 'SettingRouteView';
}

/// generated route for
/// [_i13.CoffeePage]
class CoffeeRoute extends _i23.PageRouteInfo<void> {
  const CoffeeRoute()
      : super(
          CoffeeRoute.name,
          path: 'coffee',
        );

  static const String name = 'CoffeeRoute';
}

/// generated route for
/// [_i10.PersonalPageView]
class PersonalRouteView extends _i23.PageRouteInfo<void> {
  const PersonalRouteView()
      : super(
          PersonalRouteView.name,
          path: 'user',
        );

  static const String name = 'PersonalRouteView';
}

/// generated route for
/// [_i14.TodayView]
class TodayView extends _i23.PageRouteInfo<void> {
  const TodayView()
      : super(
          TodayView.name,
          path: 'today',
        );

  static const String name = 'TodayView';
}

/// generated route for
/// [_i15.MyRadioView]
class MyRadioView extends _i23.PageRouteInfo<void> {
  const MyRadioView()
      : super(
          MyRadioView.name,
          path: 'myRadio',
        );

  static const String name = 'MyRadioView';
}

/// generated route for
/// [_i16.RadioDetailsView]
class RadioDetailsView extends _i23.PageRouteInfo<void> {
  const RadioDetailsView()
      : super(
          RadioDetailsView.name,
          path: 'radioDetails',
        );

  static const String name = 'RadioDetailsView';
}

/// generated route for
/// [_i17.CloudDriveView]
class CloudDriveView extends _i23.PageRouteInfo<void> {
  const CloudDriveView()
      : super(
          CloudDriveView.name,
          path: 'cloud',
        );

  static const String name = 'CloudDriveView';
}

/// generated route for
/// [_i18.LoginView]
class LoginView extends _i23.PageRouteInfo<void> {
  const LoginView()
      : super(
          LoginView.name,
          path: 'login',
        );

  static const String name = 'LoginView';
}

/// generated route for
/// [_i19.UserSettingView]
class UserSettingView extends _i23.PageRouteInfo<void> {
  const UserSettingView()
      : super(
          UserSettingView.name,
          path: 'userSetting',
        );

  static const String name = 'UserSettingView';
}

/// generated route for
/// [_i20.PlayListView]
class PlayListView extends _i23.PageRouteInfo<void> {
  const PlayListView()
      : super(
          PlayListView.name,
          path: 'playlist',
        );

  static const String name = 'PlayListView';
}

/// generated route for
/// [_i21.PlaylistManagerView]
class PlaylistManagerView extends _i23.PageRouteInfo<void> {
  const PlaylistManagerView()
      : super(
          PlaylistManagerView.name,
          path: 'playlistManager',
        );

  static const String name = 'PlaylistManagerView';
}

/// generated route for
/// [_i22.CommentPageView]
class TalkView extends _i23.PageRouteInfo<TalkViewArgs> {
  TalkView({
    _i24.Key? key,
    String id = "",
    String type = "",
  }) : super(
          TalkView.name,
          path: 'talk',
          args: TalkViewArgs(
            key: key,
            id: id,
            type: type,
          ),
        );

  static const String name = 'TalkView';
}

class TalkViewArgs {
  const TalkViewArgs({
    this.key,
    this.id = "",
    this.type = "",
  });

  final _i24.Key? key;

  final String id;

  final String type;

  @override
  String toString() {
    return 'TalkViewArgs{key: $key, id: $id, type: $type}';
  }
}

/// generated route for
/// [_i11.ExplorePageView]
class ExploreRouteView extends _i23.PageRouteInfo<void> {
  const ExploreRouteView()
      : super(
          ExploreRouteView.name,
          path: 'index',
        );

  static const String name = 'ExploreRouteView';
}
