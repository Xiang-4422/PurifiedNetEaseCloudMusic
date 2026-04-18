import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:bujuan/controllers/player_controller.dart';
import 'package:bujuan/controllers/settings_controller.dart';
import 'package:bujuan/controllers/user_controller.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/common/lyric_parser/lyrics_reader_model.dart';
import 'package:bujuan/features/shell/controller/home_shell_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../common/bujuan_audio_handler.dart';
import '../widget/custom_zoom_drawer/src/drawer_controller.dart';

/// 所有Controller都放在HomeController中统一控制
///
/// **代理 Getters 以保持向后兼容**
class AppController extends SuperController
    with GetTickerProviderStateMixin, WidgetsBindingObserver {
  static AppController get to => Get.find();
  late final HomeShellController shellController;

  late final SettingsController settingsController;
  late final UserController userController;
  late final PlayerController playerController;

  RxBool get isGradientBackground => settingsController.isGradientBackground;
  RxBool get isRoundAlbumOpen => settingsController.isRoundAlbumOpen;
  RxBool get isCacheOpen => settingsController.isCacheOpen;
  RxBool get isHighSoundQualityOpen =>
      settingsController.isHighSoundQualityOpen;
  Rx<Color> get albumColor => settingsController.albumColor;
  Rx<Color> get panelWidgetColor => settingsController.panelWidgetColor;

  Rx<NeteaseAccountInfoWrap> get userInfo => userController.userInfo;
  List<PlayList> get userPlayLists => userController.userPlayLists;
  RxList<PlayList> get recoPlayLists => userController.recoPlayLists;
  Rx<PlayList> get userLikedSongPlayList =>
      userController.userLikedSongPlayList;
  RxList<int> get likedSongIds => userController.likedSongIds;
  RxList<MediaItem> get likedSongs => userController.likedSongs;
  RxList<MediaItem> get fmSongs => userController.fmSongs;
  RxList<MediaItem> get todayRecommendSongs =>
      userController.todayRecommendSongs;

  RxBool get isPlaying => playerController.isPlaying;
  Rx<AudioServiceRepeatMode> get curRepeatMode =>
      playerController.curRepeatMode;
  RxBool get isFmMode => playerController.isFmMode;
  RxBool get isHeartBeatMode => playerController.isHeartBeatMode;
  RxBool get isPlayingLikedSongs => playerController.isPlayingLikedSongs;
  RxList<MediaItem> get curPlayingSongs => playerController.curPlayingSongs;
  RxString get curPlayListName => playerController.curPlayListName;
  RxString get curPlayListNameHeader => playerController.curPlayListNameHeader;
  Rx<MediaItem> get curPlayingSong => playerController.curPlayingSong;
  RxInt get curPlayIndex => playerController.curPlayIndex;
  Rx<Duration> get curPlayDuration => playerController.curPlayDuration;
  RxList<LyricsLineModel> get lyricsLineModels =>
      playerController.lyricsLineModels;
  RxBool get hasTransLyrics => playerController.hasTransLyrics;
  RxInt get currLyricIndex => playerController.currLyricIndex;
  RxBool get isFullScreenLyricOpen => playerController.isFullScreenLyricOpen;
  AudioServiceHandler get audioHandler => playerController.audioHandler;

  late BuildContext buildContext;

  RxBool dateLoaded = false.obs;

  RxString get randomLikedSongAlbumUrl =>
      userController.randomLikedSongAlbumUrl;
  RxString get randomLikedSongId => userController.randomLikedSongId;

  RefreshController refreshController = RefreshController();

  List<LeftMenuBean> get leftMenus => userController.leftMenus;
  ZoomDrawerController get zoomDrawerController =>
      shellController.zoomDrawerController;
  RxBool get isDrawerClosed => shellController.isDrawerClosed;
  PageController get homePageController => shellController.homePageController;
  RxInt get curHomePageIndex => shellController.curHomePageIndex;
  RxString get curHomePageTitle => shellController.curHomePageTitle;

  late PageController albumPageController;
  RxBool isBigAlbum = true.obs;
  RxBool isAlbumScaleEnded = true.obs;
  bool isAlbumScrollingManully = false;
  bool isAlbumScrollingProgrammatic = false;
  RxBool isAlbumScrolling = false.obs;

  PanelController bottomPanelController = PanelController();
  late AnimationController bottomPanelAnimationController;
  RxBool bottomPanelFullyClosed = true.obs;
  RxBool bottomPanelOpened50 = false.obs;
  RxBool bottomPanelFullyOpened = false.obs;
  late PageController bottomPanelPageController;
  RxInt curPanelPageIndex = 1.obs;
  late TabController bottomPanelTabController;
  late TabController bottomPanelCommentTabController;
  ScrollController playListScrollController = ScrollController();

  PanelController get topPanelController => shellController.topPanelController;
  AnimationController get topPanelAnimationController =>
      shellController.topPanelAnimationController;
  TextEditingController get searchTextEditingController =>
      shellController.searchTextEditingController;
  RxBool get topPanelFullyOpened => shellController.topPanelFullyOpened;
  RxBool get topPanelFullyClosed => shellController.topPanelFullyClosed;
  RxString get searchContent => shellController.searchContent;
  FocusNode get searchFocusNode => shellController.searchFocusNode;
  RxDouble get keyBoardHeight => shellController.keyBoardHeight;

  ItemScrollController lyricScrollController = ItemScrollController();
  bool isLyricScrollingByUser = false;
  bool isLyricScrollingByItself = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    shellController = Get.put(HomeShellController());
    settingsController = Get.put(SettingsController());
    userController = Get.put(UserController());
    playerController = Get.put(PlayerController());

    _initUIController();
    WidgetsBinding.instance.addObserver(this);

    ever(currLyricIndex, (index) {
      if (index >= 0 &&
          !isLyricScrollingByUser &&
          lyricScrollController.isAttached) {
        try {
          lyricScrollController.scrollTo(
              index: index, duration: const Duration(milliseconds: 300));
        } catch (e) {
          // 歌词滚动失败只会影响跟随体验，不能反过来打断播放状态更新。
        }
      }
    });

    ever(curPlayIndex, (index) {
      _animatePlayListToCurSong();
      _animateAlbumPageViewToCurSong();
    });
  }

  Timer? _albumDebounceTimer;

  void onAlbumPageChanged(int index) {
    if (isAlbumScrollingProgrammatic) return;
    _albumDebounceTimer?.cancel();
    _albumDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (curPlayIndex.value != index) {
        audioHandler.playIndex(audioSourceIndex: index, playNow: true);
      }
    });
  }

  void _initUIController() {
    shellController.init(initialTitle: userInfo.value.profile?.nickname ?? '');
    bottomPanelAnimationController = AnimationController(vsync: this);
    bottomPanelTabController =
        TabController(length: 3, initialIndex: 1, vsync: this)
          ..addListener(() {
            if (bottomPanelTabController.indexIsChanging) {
              bottomPanelPageController.animateToPage(
                  bottomPanelTabController.index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.linear);
              if (bottomPanelTabController.index <= 1) {
                bottomPanelCommentTabController.index = 0;
                bottomPanelCommentTabController.offset = 0;
              }
            }
          });
    bottomPanelCommentTabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (bottomPanelCommentTabController.indexIsChanging) {
          bottomPanelPageController.animateToPage(
              bottomPanelCommentTabController.index + 2,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear);
        }
      });
    bottomPanelPageController = PageController(initialPage: 1)
      ..addListener(() async {
        int newPanelPageIndex = (bottomPanelPageController.page! + 0.5).toInt();

        if (curPanelPageIndex.value != newPanelPageIndex) {
          curPanelPageIndex.value = newPanelPageIndex;
          // 切换到正在播放列表页，滚动到当前播放
          if (newPanelPageIndex == 0) await _animatePlayListToCurSong();
          if (isFullScreenLyricOpen.isFalse) {
            playerController.updateFullScreenLyricTimerCounter(
                cancelTimer:
                    newPanelPageIndex != 1 && isFullScreenLyricOpen.isFalse);
          }
        }
        // 避免循环监听
        if (bottomPanelTabController.indexIsChanging ||
            bottomPanelCommentTabController.indexIsChanging) {
          return;
        }
        // 控制tab显示
        if (bottomPanelPageController.page! <= 2) {
          bottomPanelTabController.index = newPanelPageIndex;
          bottomPanelTabController.offset =
              bottomPanelPageController.page! - newPanelPageIndex;
        } else {
          bottomPanelCommentTabController.index = newPanelPageIndex - 2;
          bottomPanelCommentTabController.offset =
              bottomPanelPageController.page! - newPanelPageIndex;
        }
      });
    albumPageController = PageController();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    updateData();
  }

  Future<void> initZoomDrawerListener() async {
    shellController.initZoomDrawerListener();
  }

  updateData() async {
    await userController.updateUserData();
    dateLoaded.value = true;

    refreshController.refreshCompleted();
    refreshController.resetNoData();
  }

  updateRecoPlayLists({bool getMore = false}) async {
    await userController.updateRecoPlayLists(getMore: getMore);
    refreshController.loadComplete();
  }

  @override
  void onDetached() {}
  @override
  void onInactive() {}
  @override
  void onPaused() {}
  @override
  void onResumed() {}
  @override
  void onHidden() {}
  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      shellController.updateKeyboardHeight(buildContext);
    });
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (bottomPanelFullyOpened.isTrue) return;
    bool isDarkMode = buildContext.isDarkMode;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarIconBrightness:
          isDarkMode ? Brightness.dark : Brightness.light,
      statusBarBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ));
  }

  IconData getRepeatIcon() => playerController.getRepeatIcon();

  openFmMode() async {
    bottomPanelPageController.jumpToPage(1);
    bottomPanelController.open();
    await playerController.switchMode(PlaybackMode.roaming);
  }

  quitFmMode({bool showToast = true}) async {
    if (showToast) WidgetUtil.showToast('已经退出漫游模式');
    if (playerController.playbackMode.value == PlaybackMode.roaming) {
      playerController.playbackMode.value = PlaybackMode.playlist;
    }
  }

  openHeartBeatMode(String startSongId, bool fromPlayAll) async {
    if (startSongId.isEmpty) {
      return;
    }
    bottomPanelPageController.jumpToPage(1);
    bottomPanelController.open();

    await playerController.switchMode(PlaybackMode.heartbeat,
        contextData: {'startSongId': startSongId, 'fromPlayAll': fromPlayAll});
  }

  quitHeartBeatMode({bool showToast = true}) async {
    if (showToast) WidgetUtil.showToast('已经退出心动模式');
    if (playerController.playbackMode.value == PlaybackMode.heartbeat) {
      playerController.playbackMode.value = PlaybackMode.playlist;
    }
  }

  playOrPause() => playerController.playOrPause();

  playNewPlayList(List<MediaItem> playList, int index,
      {String playListName = "无名歌单", String playListNameHeader = ""}) async {
    if (isFmMode.isTrue) quitFmMode();
    if (isHeartBeatMode.isTrue) quitHeartBeatMode();
    await audioHandler.changePlayList(playList,
        index: index,
        playListName: playListName,
        playListNameHeader: playListNameHeader,
        changePlayerSource: true,
        playNow: true);
  }

  playUserLikedSongs() async {
    int playIndex;
    List<MediaItem> playList = [...likedSongs];
    // 正在播放红心歌曲
    if (likedSongIds.contains(int.parse(curPlayingSong.value.id))) {
      playIndex =
          likedSongs.indexWhere((song) => song.id == curPlayingSong.value.id);
      // 正在播放非红心歌曲
    } else {
      playIndex = 0;
      playList.insert(0, curPlayingSong.value);
    }
    await audioHandler.changePlayList(playList,
        index: playIndex,
        playListName: "喜欢的音乐",
        changePlayerSource: false,
        playNow: false);
  }

  onBottomPanelSlide(double openDegree) {
    bottomPanelAnimationController.value = openDegree;

    if (bottomPanelFullyClosed.value != (openDegree == 0.0)) {
      bottomPanelFullyClosed.value = (openDegree == 0.0);
    }
    if (bottomPanelOpened50.value != (openDegree > 0.5)) {
      bottomPanelOpened50.value = openDegree > 0.5;
    }
    if (bottomPanelFullyOpened.value != (openDegree == 1.0)) {
      bottomPanelFullyOpened.value = (openDegree == 1.0);
      if (curPanelPageIndex.value == 0) {
        _animatePlayListToCurSong();
      }
    }
  }

  onTopPanelSlide(double openDegree) {
    shellController.onTopPanelSlide(openDegree);
  }

  onWillPop() {
    if (!shellController.handleWillPop(
        bottomPanelController: bottomPanelController)) {
      SystemNavigator.pop();
    }
  }

  updateFullScreenLyricTimerCounter({bool cancelTimer = false}) {
    playerController.updateFullScreenLyricTimerCounter(
        cancelTimer: cancelTimer);
  }

  _animatePlayListToCurSong() {
    if (playListScrollController.hasClients) {
      double offset = curPlayIndex.value * 55.0;
      playListScrollController.animateTo(offset,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    }
  }

  syncAlbumPage() => _animateAlbumPageViewToCurSong();

  _animateAlbumPageViewToCurSong() {
    if (albumPageController.hasClients) {
      if (isAlbumScrollingManully) return;
      double currentPage = albumPageController.page ?? 0;
      if ((currentPage - curPlayIndex.value).abs() < 0.01) return;

      isAlbumScrollingProgrammatic = true;
      albumPageController.animateToPage(curPlayIndex.value,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    }
  }
}
