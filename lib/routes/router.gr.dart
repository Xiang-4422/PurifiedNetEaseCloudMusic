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
import 'package:auto_route/auto_route.dart' as _i21;
import 'package:flutter/material.dart' as _i22;

import '../pages/album/album_details.dart' as _i4;
import '../pages/artists/artists_view.dart' as _i5;
import '../pages/guide/guide_view.dart' as _i7;
import '../pages/home/view/home_page_view.dart' as _i2;
import '../pages/index/cloud_drive_view.dart' as _i16;
import '../pages/index/explore_page_view.dart' as _i10;
import '../pages/login/login_page_view.dart' as _i17;
import '../pages/mv/mv_view.dart' as _i6;
import '../pages/play_list/playlist_page_view.dart' as _i19;
import '../pages/radio/my_radio_view.dart' as _i14;
import '../pages/radio/radio_details_view.dart' as _i15;
import '../pages/search/search_view.dart' as _i3;
import '../pages/setting/coffee.dart' as _i12;
import '../pages/setting/setting_page_view.dart' as _i11;
import '../pages/setting/user_setting_view.dart' as _i18;
import '../pages/splash_page.dart' as _i1;
import '../pages/talk/comment_page_view.dart' as _i20;
import '../pages/today/today_page_view.dart' as _i13;
import '../pages/update/update_view.dart' as _i8;
import '../pages/user/personal_page_view.dart' as _i9;

class RootRouter extends _i21.RootStackRouter {
  RootRouter([_i22.GlobalKey<_i22.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i21.PageFactory> pagesMap = {
    SplashRoute.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i1.SplashPage(),
      );
    },
    HomeRouteView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i2.HomePageView(),
      );
    },
    SearchView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i3.SearchView(),
      );
    },
    AlbumDetails.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i4.AlbumDetails(),
      );
    },
    ArtistsView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i5.ArtistsView(),
      );
    },
    MvView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i6.MvView(),
      );
    },
    GuideView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i7.GuideView(),
      );
    },
    UpdateView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i8.UpdateView(),
      );
    },
    RouteOne.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i9.PageOne(),
      );
    },
    RouteTwo.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i10.PageTwo(),
      );
    },
    SettingRouteView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i11.SettingPageView(),
      );
    },
    CoffeeRoute.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i12.CoffeePage(),
      );
    },
    PersonalRouteView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i9.PersonalPageView(),
      );
    },
    TodayRouteView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i13.TodayPageView(),
      );
    },
    MyRadioView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i14.MyRadioView(),
      );
    },
    RadioDetailsView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i15.RadioDetailsView(),
      );
    },
    CloudDriveView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i16.CloudDriveView(),
      );
    },
    LoginRouteView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i17.LoginPageView(),
      );
    },
    UserSettingView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i18.UserSettingView(),
      );
    },
    PlayListRouteView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i19.PlayListPageView(),
      );
    },
    CommentRouteView.name: (routeData) {
      final args = routeData.argsAs<CommentRouteViewArgs>(
          orElse: () => const CommentRouteViewArgs());
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: _i20.CommentPageView(
          key: args.key,
          id: args.id,
          type: args.type,
        ),
      );
    },
    ExploreRouteView.name: (routeData) {
      return _i21.CupertinoPageX<dynamic>(
        routeData: routeData,
        child: const _i10.ExplorePageView(),
      );
    },
  };

  @override
  List<_i21.RouteConfig> get routes => [
        _i21.RouteConfig(
          '/#redirect',
          path: '/',
          redirectTo: '/splash',
          fullMatch: true,
        ),
        _i21.RouteConfig(
          SplashRoute.name,
          path: '/splash',
        ),
        _i21.RouteConfig(
          HomeRouteView.name,
          path: '/home',
          children: [
            _i21.RouteConfig(
              RouteOne.name,
              path: 'page_one',
              parent: HomeRouteView.name,
              children: [
                _i21.RouteConfig(
                  '#redirect',
                  path: '',
                  parent: RouteOne.name,
                  redirectTo: 'user',
                  fullMatch: true,
                ),
                _i21.RouteConfig(
                  PersonalRouteView.name,
                  path: 'user',
                  parent: RouteOne.name,
                ),
                _i21.RouteConfig(
                  TodayRouteView.name,
                  path: 'today',
                  parent: RouteOne.name,
                ),
                _i21.RouteConfig(
                  MyRadioView.name,
                  path: 'myRadio',
                  parent: RouteOne.name,
                ),
                _i21.RouteConfig(
                  RadioDetailsView.name,
                  path: 'radioDetails',
                  parent: RouteOne.name,
                ),
                _i21.RouteConfig(
                  CloudDriveView.name,
                  path: 'cloud',
                  parent: RouteOne.name,
                ),
                _i21.RouteConfig(
                  LoginRouteView.name,
                  path: 'login',
                  parent: RouteOne.name,
                ),
                _i21.RouteConfig(
                  UserSettingView.name,
                  path: 'userSetting',
                  parent: RouteOne.name,
                ),
                _i21.RouteConfig(
                  PlayListRouteView.name,
                  path: 'playlist',
                  parent: RouteOne.name,
                ),
                _i21.RouteConfig(
                  CommentRouteView.name,
                  path: 'talk',
                  parent: RouteOne.name,
                ),
              ],
            ),
            _i21.RouteConfig(
              RouteTwo.name,
              path: 'page_two',
              parent: HomeRouteView.name,
              children: [
                _i21.RouteConfig(
                  '#redirect',
                  path: '',
                  parent: RouteTwo.name,
                  redirectTo: 'index',
                  fullMatch: true,
                ),
                _i21.RouteConfig(
                  ExploreRouteView.name,
                  path: 'index',
                  parent: RouteTwo.name,
                ),
                _i21.RouteConfig(
                  PlayListRouteView.name,
                  path: 'playlist',
                  parent: RouteTwo.name,
                ),
                _i21.RouteConfig(
                  CommentRouteView.name,
                  path: 'talk',
                  parent: RouteTwo.name,
                ),
              ],
            ),
            _i21.RouteConfig(
              SettingRouteView.name,
              path: 'setting',
              parent: HomeRouteView.name,
            ),
            _i21.RouteConfig(
              CoffeeRoute.name,
              path: 'coffee',
              parent: HomeRouteView.name,
            ),
          ],
        ),
        _i21.RouteConfig(
          SearchView.name,
          path: '/search',
        ),
        _i21.RouteConfig(
          AlbumDetails.name,
          path: 'albumDetails',
        ),
        _i21.RouteConfig(
          ArtistsView.name,
          path: 'artists',
        ),
        _i21.RouteConfig(
          MvView.name,
          path: '/mv',
        ),
        _i21.RouteConfig(
          GuideView.name,
          path: '/guide',
        ),
        _i21.RouteConfig(
          UpdateView.name,
          path: '/update',
        ),
      ];
}

/// generated route for
/// [_i1.SplashPage]
class SplashRoute extends _i21.PageRouteInfo<void> {
  const SplashRoute()
      : super(
          SplashRoute.name,
          path: '/splash',
        );

  static const String name = 'SplashRoute';
}

/// generated route for
/// [_i2.HomePageView]
class HomeRouteView extends _i21.PageRouteInfo<void> {
  const HomeRouteView({List<_i21.PageRouteInfo>? children})
      : super(
          HomeRouteView.name,
          path: '/home',
          initialChildren: children,
        );

  static const String name = 'HomeRouteView';
}

/// generated route for
/// [_i3.SearchView]
class SearchView extends _i21.PageRouteInfo<void> {
  const SearchView()
      : super(
          SearchView.name,
          path: '/search',
        );

  static const String name = 'SearchView';
}

/// generated route for
/// [_i4.AlbumDetails]
class AlbumDetails extends _i21.PageRouteInfo<void> {
  const AlbumDetails()
      : super(
          AlbumDetails.name,
          path: 'albumDetails',
        );

  static const String name = 'AlbumDetails';
}

/// generated route for
/// [_i5.ArtistsView]
class ArtistsView extends _i21.PageRouteInfo<void> {
  const ArtistsView()
      : super(
          ArtistsView.name,
          path: 'artists',
        );

  static const String name = 'ArtistsView';
}

/// generated route for
/// [_i6.MvView]
class MvView extends _i21.PageRouteInfo<void> {
  const MvView()
      : super(
          MvView.name,
          path: '/mv',
        );

  static const String name = 'MvView';
}

/// generated route for
/// [_i7.GuideView]
class GuideView extends _i21.PageRouteInfo<void> {
  const GuideView()
      : super(
          GuideView.name,
          path: '/guide',
        );

  static const String name = 'GuideView';
}

/// generated route for
/// [_i8.UpdateView]
class UpdateView extends _i21.PageRouteInfo<void> {
  const UpdateView()
      : super(
          UpdateView.name,
          path: '/update',
        );

  static const String name = 'UpdateView';
}

/// generated route for
/// [_i9.PageOne]
class RouteOne extends _i21.PageRouteInfo<void> {
  const RouteOne({List<_i21.PageRouteInfo>? children})
      : super(
          RouteOne.name,
          path: 'page_one',
          initialChildren: children,
        );

  static const String name = 'RouteOne';
}

/// generated route for
/// [_i10.PageTwo]
class RouteTwo extends _i21.PageRouteInfo<void> {
  const RouteTwo({List<_i21.PageRouteInfo>? children})
      : super(
          RouteTwo.name,
          path: 'page_two',
          initialChildren: children,
        );

  static const String name = 'RouteTwo';
}

/// generated route for
/// [_i11.SettingPageView]
class SettingRouteView extends _i21.PageRouteInfo<void> {
  const SettingRouteView()
      : super(
          SettingRouteView.name,
          path: 'setting',
        );

  static const String name = 'SettingRouteView';
}

/// generated route for
/// [_i12.CoffeePage]
class CoffeeRoute extends _i21.PageRouteInfo<void> {
  const CoffeeRoute()
      : super(
          CoffeeRoute.name,
          path: 'coffee',
        );

  static const String name = 'CoffeeRoute';
}

/// generated route for
/// [_i9.PersonalPageView]
class PersonalRouteView extends _i21.PageRouteInfo<void> {
  const PersonalRouteView()
      : super(
          PersonalRouteView.name,
          path: 'user',
        );

  static const String name = 'PersonalRouteView';
}

/// generated route for
/// [_i13.TodayPageView]
class TodayRouteView extends _i21.PageRouteInfo<void> {
  const TodayRouteView()
      : super(
          TodayRouteView.name,
          path: 'today',
        );

  static const String name = 'TodayRouteView';
}

/// generated route for
/// [_i14.MyRadioView]
class MyRadioView extends _i21.PageRouteInfo<void> {
  const MyRadioView()
      : super(
          MyRadioView.name,
          path: 'myRadio',
        );

  static const String name = 'MyRadioView';
}

/// generated route for
/// [_i15.RadioDetailsView]
class RadioDetailsView extends _i21.PageRouteInfo<void> {
  const RadioDetailsView()
      : super(
          RadioDetailsView.name,
          path: 'radioDetails',
        );

  static const String name = 'RadioDetailsView';
}

/// generated route for
/// [_i16.CloudDriveView]
class CloudDriveView extends _i21.PageRouteInfo<void> {
  const CloudDriveView()
      : super(
          CloudDriveView.name,
          path: 'cloud',
        );

  static const String name = 'CloudDriveView';
}

/// generated route for
/// [_i17.LoginPageView]
class LoginRouteView extends _i21.PageRouteInfo<void> {
  const LoginRouteView()
      : super(
          LoginRouteView.name,
          path: 'login',
        );

  static const String name = 'LoginRouteView';
}

/// generated route for
/// [_i18.UserSettingView]
class UserSettingView extends _i21.PageRouteInfo<void> {
  const UserSettingView()
      : super(
          UserSettingView.name,
          path: 'userSetting',
        );

  static const String name = 'UserSettingView';
}

/// generated route for
/// [_i19.PlayListPageView]
class PlayListRouteView extends _i21.PageRouteInfo<void> {
  const PlayListRouteView()
      : super(
          PlayListRouteView.name,
          path: 'playlist',
        );

  static const String name = 'PlayListRouteView';
}

/// generated route for
/// [_i20.CommentPageView]
class CommentRouteView extends _i21.PageRouteInfo<CommentRouteViewArgs> {
  CommentRouteView({
    _i22.Key? key,
    String id = "",
    String type = "",
  }) : super(
          CommentRouteView.name,
          path: 'talk',
          args: CommentRouteViewArgs(
            key: key,
            id: id,
            type: type,
          ),
        );

  static const String name = 'CommentRouteView';
}

class CommentRouteViewArgs {
  const CommentRouteViewArgs({
    this.key,
    this.id = "",
    this.type = "",
  });

  final _i22.Key? key;

  final String id;

  final String type;

  @override
  String toString() {
    return 'CommentRouteViewArgs{key: $key, id: $id, type: $type}';
  }
}

/// generated route for
/// [_i10.ExplorePageView]
class ExploreRouteView extends _i21.PageRouteInfo<void> {
  const ExploreRouteView()
      : super(
          ExploreRouteView.name,
          path: 'index',
        );

  static const String name = 'ExploreRouteView';
}
