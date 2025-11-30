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
import 'package:auto_route/auto_route.dart' as _i13;
import 'package:flutter/material.dart' as _i14;

import '../common/netease_api/src/api/play/bean.dart' as _i15;
import '../pages/album/album_page_view.dart' as _i8;
import '../pages/artist/artist_page_view.dart' as _i9;
import '../pages/cloud/cloud_drive_view.dart' as _i12;
import '../pages/home/app_home_page_view.dart' as _i3;
import '../pages/home/body/app_body_page_view.dart' as _i5;
import '../pages/login/login_page_view.dart' as _i1;
import '../pages/play_list/playlist_page_view.dart' as _i7;
import '../pages/radio/my_radio_view.dart' as _i10;
import '../pages/radio/radio_details_view.dart' as _i11;
import '../pages/setting/user_setting_view.dart' as _i2;
import '../pages/today/today_page_view.dart' as _i6;
import '../pages/update/update_view.dart' as _i4;

class RootRouter extends _i13.RootStackRouter {
  RootRouter([_i14.GlobalKey<_i14.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i13.PageFactory> pagesMap = {
    LoginRouteView.name: (routeData) {
      return _i13.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i1.LoginPageView(),
      );
    },
    UserSettingView.name: (routeData) {
      return _i13.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i2.UserSettingView(),
      );
    },
    AppRootRouteView.name: (routeData) {
      return _i13.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i3.AppRootPageView(),
      );
    },
    UpdateView.name: (routeData) {
      return _i13.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i4.UpdateView(),
      );
    },
    AppBodyRouteView.name: (routeData) {
      return _i13.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i5.AppBodyPageView(),
      );
    },
    TodayRouteView.name: (routeData) {
      return _i13.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i6.TodayPageView(),
      );
    },
    PlayListRouteView.name: (routeData) {
      final args = routeData.argsAs<PlayListRouteViewArgs>();
      return _i13.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: _i7.PlayListPageView(
          args.playList,
          key: args.key,
        ),
      );
    },
    AlbumRouteView.name: (routeData) {
      return _i13.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i8.AlbumPageView(),
      );
    },
    ArtistRouteView.name: (routeData) {
      return _i13.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i9.ArtistPageView(),
      );
    },
    MyRadioView.name: (routeData) {
      return _i13.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i10.MyRadioView(),
      );
    },
    RadioDetailsView.name: (routeData) {
      return _i13.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i11.RadioDetailsView(),
      );
    },
    CloudDriveView.name: (routeData) {
      return _i13.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i12.CloudDriveView(),
      );
    },
  };

  @override
  List<_i13.RouteConfig> get routes => [
        _i13.RouteConfig(
          '/#redirect',
          path: '/',
          redirectTo: '/home',
          fullMatch: true,
        ),
        _i13.RouteConfig(
          LoginRouteView.name,
          path: 'login',
        ),
        _i13.RouteConfig(
          UserSettingView.name,
          path: 'userSetting',
        ),
        _i13.RouteConfig(
          AppRootRouteView.name,
          path: '/home',
          children: [
            _i13.RouteConfig(
              '#redirect',
              path: '',
              parent: AppRootRouteView.name,
              redirectTo: 'local',
              fullMatch: true,
            ),
            _i13.RouteConfig(
              AppBodyRouteView.name,
              path: 'local',
              parent: AppRootRouteView.name,
            ),
            _i13.RouteConfig(
              TodayRouteView.name,
              path: 'today',
              parent: AppRootRouteView.name,
            ),
            _i13.RouteConfig(
              PlayListRouteView.name,
              path: 'playlist',
              parent: AppRootRouteView.name,
            ),
            _i13.RouteConfig(
              AlbumRouteView.name,
              path: 'albumDetails',
              parent: AppRootRouteView.name,
            ),
            _i13.RouteConfig(
              ArtistRouteView.name,
              path: 'artists',
              parent: AppRootRouteView.name,
            ),
            _i13.RouteConfig(
              MyRadioView.name,
              path: 'myRadio',
              parent: AppRootRouteView.name,
            ),
            _i13.RouteConfig(
              RadioDetailsView.name,
              path: 'radioDetails',
              parent: AppRootRouteView.name,
            ),
            _i13.RouteConfig(
              CloudDriveView.name,
              path: 'cloud',
              parent: AppRootRouteView.name,
            ),
          ],
        ),
        _i13.RouteConfig(
          UpdateView.name,
          path: '/update',
        ),
      ];
}

/// generated route for
/// [_i1.LoginPageView]
class LoginRouteView extends _i13.PageRouteInfo<void> {
  const LoginRouteView()
      : super(
          LoginRouteView.name,
          path: 'login',
        );

  static const String name = 'LoginRouteView';
}

/// generated route for
/// [_i2.UserSettingView]
class UserSettingView extends _i13.PageRouteInfo<void> {
  const UserSettingView()
      : super(
          UserSettingView.name,
          path: 'userSetting',
        );

  static const String name = 'UserSettingView';
}

/// generated route for
/// [_i3.AppRootPageView]
class AppRootRouteView extends _i13.PageRouteInfo<void> {
  const AppRootRouteView({List<_i13.PageRouteInfo>? children})
      : super(
          AppRootRouteView.name,
          path: '/home',
          initialChildren: children,
        );

  static const String name = 'AppRootRouteView';
}

/// generated route for
/// [_i4.UpdateView]
class UpdateView extends _i13.PageRouteInfo<void> {
  const UpdateView()
      : super(
          UpdateView.name,
          path: '/update',
        );

  static const String name = 'UpdateView';
}

/// generated route for
/// [_i5.AppBodyPageView]
class AppBodyRouteView extends _i13.PageRouteInfo<void> {
  const AppBodyRouteView()
      : super(
          AppBodyRouteView.name,
          path: 'local',
        );

  static const String name = 'AppBodyRouteView';
}

/// generated route for
/// [_i6.TodayPageView]
class TodayRouteView extends _i13.PageRouteInfo<void> {
  const TodayRouteView()
      : super(
          TodayRouteView.name,
          path: 'today',
        );

  static const String name = 'TodayRouteView';
}

/// generated route for
/// [_i7.PlayListPageView]
class PlayListRouteView extends _i13.PageRouteInfo<PlayListRouteViewArgs> {
  PlayListRouteView({
    required _i15.PlayList playList,
    _i14.Key? key,
  }) : super(
          PlayListRouteView.name,
          path: 'playlist',
          args: PlayListRouteViewArgs(
            playList: playList,
            key: key,
          ),
        );

  static const String name = 'PlayListRouteView';
}

class PlayListRouteViewArgs {
  const PlayListRouteViewArgs({
    required this.playList,
    this.key,
  });

  final _i15.PlayList playList;

  final _i14.Key? key;

  @override
  String toString() {
    return 'PlayListRouteViewArgs{playList: $playList, key: $key}';
  }
}

/// generated route for
/// [_i8.AlbumPageView]
class AlbumRouteView extends _i13.PageRouteInfo<void> {
  const AlbumRouteView()
      : super(
          AlbumRouteView.name,
          path: 'albumDetails',
        );

  static const String name = 'AlbumRouteView';
}

/// generated route for
/// [_i9.ArtistPageView]
class ArtistRouteView extends _i13.PageRouteInfo<void> {
  const ArtistRouteView()
      : super(
          ArtistRouteView.name,
          path: 'artists',
        );

  static const String name = 'ArtistRouteView';
}

/// generated route for
/// [_i10.MyRadioView]
class MyRadioView extends _i13.PageRouteInfo<void> {
  const MyRadioView()
      : super(
          MyRadioView.name,
          path: 'myRadio',
        );

  static const String name = 'MyRadioView';
}

/// generated route for
/// [_i11.RadioDetailsView]
class RadioDetailsView extends _i13.PageRouteInfo<void> {
  const RadioDetailsView()
      : super(
          RadioDetailsView.name,
          path: 'radioDetails',
        );

  static const String name = 'RadioDetailsView';
}

/// generated route for
/// [_i12.CloudDriveView]
class CloudDriveView extends _i13.PageRouteInfo<void> {
  const CloudDriveView()
      : super(
          CloudDriveView.name,
          path: 'cloud',
        );

  static const String name = 'CloudDriveView';
}
