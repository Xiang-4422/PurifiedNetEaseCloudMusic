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
import 'package:auto_route/auto_route.dart' as _i12;
import 'package:flutter/material.dart' as _i13;

import '../features/album/presentation/album_page_view.dart' as _i7;
import '../features/artist/presentation/artist_page_view.dart' as _i8;
import '../features/auth/presentation/login_page_view.dart' as _i1;
import '../features/cloud/presentation/cloud_drive_view.dart' as _i11;
import '../features/playlist/presentation/playlist_page_view.dart' as _i6;
import '../features/radio/presentation/my_radio_view.dart' as _i9;
import '../features/radio/presentation/radio_details_view.dart' as _i10;
import '../features/shell/presentation/app_body_page_view.dart' as _i4;
import '../features/shell/presentation/app_home_page_view.dart' as _i3;
import '../features/user/presentation/today_page_view.dart' as _i5;
import '../features/user/presentation/user_setting_view.dart' as _i2;

class RootRouter extends _i12.RootStackRouter {
  RootRouter([_i13.GlobalKey<_i13.NavigatorState>? navigatorKey]) : super(navigatorKey);

  @override
  final Map<String, _i12.PageFactory> pagesMap = {
    LoginRouteView.name: (routeData) {
      return _i12.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i1.LoginPageView(),
      );
    },
    UserProfileRouteView.name: (routeData) {
      return _i12.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i2.UserProfilePageView(),
      );
    },
    AppHomeRouteView.name: (routeData) {
      return _i12.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i3.AppHomePageView(),
      );
    },
    AppBodyRouteView.name: (routeData) {
      return _i12.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i4.AppBodyPageView(),
      );
    },
    TodayRouteView.name: (routeData) {
      return _i12.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i5.TodayPageView(),
      );
    },
    PlayListRouteView.name: (routeData) {
      final args = routeData.argsAs<PlayListRouteViewArgs>();
      return _i12.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: _i6.PlayListPageView(
          playlistId: args.playlistId,
          playlistName: args.playlistName,
          coverUrl: args.coverUrl,
          trackCount: args.trackCount,
          key: args.key,
        ),
      );
    },
    AlbumRouteView.name: (routeData) {
      return _i12.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i7.AlbumPageView(),
      );
    },
    ArtistRouteView.name: (routeData) {
      return _i12.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i8.ArtistPageView(),
      );
    },
    MyRadioView.name: (routeData) {
      return _i12.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i9.MyRadioView(),
      );
    },
    RadioDetailsView.name: (routeData) {
      return _i12.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i10.RadioDetailsView(),
      );
    },
    CloudDriveView.name: (routeData) {
      return _i12.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i11.CloudDriveView(),
      );
    },
  };

  @override
  List<_i12.RouteConfig> get routes => [
        _i12.RouteConfig(
          '/#redirect',
          path: '/',
          redirectTo: 'login',
          fullMatch: true,
        ),
        _i12.RouteConfig(
          LoginRouteView.name,
          path: 'login',
        ),
        _i12.RouteConfig(
          UserProfileRouteView.name,
          path: 'userProfile',
        ),
        _i12.RouteConfig(
          AppHomeRouteView.name,
          path: '/home',
          children: [
            _i12.RouteConfig(
              '#redirect',
              path: '',
              parent: AppHomeRouteView.name,
              redirectTo: 'local',
              fullMatch: true,
            ),
            _i12.RouteConfig(
              AppBodyRouteView.name,
              path: 'local',
              parent: AppHomeRouteView.name,
            ),
            _i12.RouteConfig(
              TodayRouteView.name,
              path: 'today',
              parent: AppHomeRouteView.name,
            ),
            _i12.RouteConfig(
              PlayListRouteView.name,
              path: 'playlist',
              parent: AppHomeRouteView.name,
            ),
            _i12.RouteConfig(
              AlbumRouteView.name,
              path: 'albumDetails',
              parent: AppHomeRouteView.name,
            ),
            _i12.RouteConfig(
              ArtistRouteView.name,
              path: 'artists',
              parent: AppHomeRouteView.name,
            ),
            _i12.RouteConfig(
              MyRadioView.name,
              path: 'myRadio',
              parent: AppHomeRouteView.name,
            ),
            _i12.RouteConfig(
              RadioDetailsView.name,
              path: 'radioDetails',
              parent: AppHomeRouteView.name,
            ),
            _i12.RouteConfig(
              CloudDriveView.name,
              path: 'cloud',
              parent: AppHomeRouteView.name,
            ),
          ],
        ),
      ];
}

/// generated route for
/// [_i1.LoginPageView]
class LoginRouteView extends _i12.PageRouteInfo<void> {
  const LoginRouteView()
      : super(
          LoginRouteView.name,
          path: 'login',
        );

  static const String name = 'LoginRouteView';
}

/// generated route for
/// [_i2.UserProfilePageView]
class UserProfileRouteView extends _i12.PageRouteInfo<void> {
  const UserProfileRouteView()
      : super(
          UserProfileRouteView.name,
          path: 'userProfile',
        );

  static const String name = 'UserProfileRouteView';
}

/// generated route for
/// [_i3.AppHomePageView]
class AppHomeRouteView extends _i12.PageRouteInfo<void> {
  const AppHomeRouteView({List<_i12.PageRouteInfo>? children})
      : super(
          AppHomeRouteView.name,
          path: '/home',
          initialChildren: children,
        );

  static const String name = 'AppHomeRouteView';
}

/// generated route for
/// [_i4.AppBodyPageView]
class AppBodyRouteView extends _i12.PageRouteInfo<void> {
  const AppBodyRouteView()
      : super(
          AppBodyRouteView.name,
          path: 'local',
        );

  static const String name = 'AppBodyRouteView';
}

/// generated route for
/// [_i5.TodayPageView]
class TodayRouteView extends _i12.PageRouteInfo<void> {
  const TodayRouteView()
      : super(
          TodayRouteView.name,
          path: 'today',
        );

  static const String name = 'TodayRouteView';
}

/// generated route for
/// [_i6.PlayListPageView]
class PlayListRouteView extends _i12.PageRouteInfo<PlayListRouteViewArgs> {
  PlayListRouteView({
    required String playlistId,
    required String playlistName,
    String? coverUrl,
    int? trackCount,
    _i13.Key? key,
  }) : super(
          PlayListRouteView.name,
          path: 'playlist',
          args: PlayListRouteViewArgs(
            playlistId: playlistId,
            playlistName: playlistName,
            coverUrl: coverUrl,
            trackCount: trackCount,
            key: key,
          ),
        );

  static const String name = 'PlayListRouteView';
}

class PlayListRouteViewArgs {
  const PlayListRouteViewArgs({
    required this.playlistId,
    required this.playlistName,
    this.coverUrl,
    this.trackCount,
    this.key,
  });

  final String playlistId;

  final String playlistName;

  final String? coverUrl;

  final int? trackCount;

  final _i13.Key? key;

  @override
  String toString() {
    return 'PlayListRouteViewArgs{playlistId: $playlistId, playlistName: $playlistName, coverUrl: $coverUrl, trackCount: $trackCount, key: $key}';
  }
}

/// generated route for
/// [_i7.AlbumPageView]
class AlbumRouteView extends _i12.PageRouteInfo<void> {
  const AlbumRouteView()
      : super(
          AlbumRouteView.name,
          path: 'albumDetails',
        );

  static const String name = 'AlbumRouteView';
}

/// generated route for
/// [_i8.ArtistPageView]
class ArtistRouteView extends _i12.PageRouteInfo<void> {
  const ArtistRouteView()
      : super(
          ArtistRouteView.name,
          path: 'artists',
        );

  static const String name = 'ArtistRouteView';
}

/// generated route for
/// [_i9.MyRadioView]
class MyRadioView extends _i12.PageRouteInfo<void> {
  const MyRadioView()
      : super(
          MyRadioView.name,
          path: 'myRadio',
        );

  static const String name = 'MyRadioView';
}

/// generated route for
/// [_i10.RadioDetailsView]
class RadioDetailsView extends _i12.PageRouteInfo<void> {
  const RadioDetailsView()
      : super(
          RadioDetailsView.name,
          path: 'radioDetails',
        );

  static const String name = 'RadioDetailsView';
}

/// generated route for
/// [_i11.CloudDriveView]
class CloudDriveView extends _i12.PageRouteInfo<void> {
  const CloudDriveView()
      : super(
          CloudDriveView.name,
          path: 'cloud',
        );

  static const String name = 'CloudDriveView';
}
