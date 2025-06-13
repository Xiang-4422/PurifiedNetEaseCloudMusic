import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/common/constants/platform_utils.dart';
import 'package:bujuan/common/lyric_parser/parser_lrc.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/pages/home/view/menu_view.dart';
import 'package:bujuan/widget/weslide/panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../common/bujuan_audio_handler.dart';
import '../../common/lyric_parser/lyrics_reader_model.dart';
import '../../common/netease_api/src/api/bean.dart';
import '../../routes/router.dart';
import '../../widget/custom_zoom_drawer/src/drawer_controller.dart';
import '../user/personal_page_controller.dart';

/// 所有Controller都放在HomeController中统一控制
class HomePageController extends SuperController with GetTickerProviderStateMixin {
  static HomePageController get to => Get.find();

  // --- 无功能分类 ---
  Box box = GetIt.instance<Box>();
  late BuildContext buildContext;
  /// 自动关闭抽屉倒计时（毫秒）
  double _timerCounter = 0.0;
  /// 上次弹出时间（防止多次快速点击）
  var _lastPopTime = DateTime.now();

  // AppBar标题配置
  RxString curPageTitle = "".obs;
  RxString curPageSubTitle = "".obs;
  NewAppBarTitleComingDirection comingDirection = NewAppBarTitleComingDirection.down;
  String _lastPageTile = "";
  String _pageTitleBeforePanelOpen = "";

  // TODO YU4422 待规范
  /// 侧边抽屉Beans
  final List<LeftMenuBean> leftMenus = [
    LeftMenuBean('个人中心', TablerIcons.user, Routes.user, '/home/user'),
    LeftMenuBean('推荐歌单', TablerIcons.smart_home, Routes.index, '/home/index'),
    // LeftMenuBean('本地歌曲', TablerIcons.file_music, Routes.local, '/home/local'),
    LeftMenuBean('个性设置', TablerIcons.settings, Routes.setting, '/home/settingL'),
    LeftMenuBean('捐赠', TablerIcons.coffee, Routes.coffee, ''),
  ];
  /// 抽屉开启状态
  RxBool isDrawerClosed = true.obs;

  /// homePageView的页面位置
  RxInt curHomePageIndex = 0.obs;
  int _lastHomePageIndex = 0;

  /// panelTab的页面位置
  RxInt curPanelPageIndex = 0.obs;

  // --- 滑动面板 ---
  /// 展开程度（0-1，1表示完全展开）
  RxDouble firstSlidePanelPosition = 0.0.obs;
  RxBool panelFullyClosed = true.obs;
  RxBool panelOpened10 = false.obs;
  RxBool panelOpened50 = false.obs;
  RxBool panelOpened90 = false.obs;
  RxBool panelFullyOpened = false.obs;

  // --- 专辑 ---
  RxBool isAlbumVisible = true.obs;
  RxBool isAlbumPageViewScrolling = false.obs;
  Rx<PaletteGenerator> albumColors = PaletteGenerator.fromColors([]).obs;
  Rx<Color> bodyColor = Colors.white.obs;
  bool _isAlbumPageViewScrollingListenerAdded = false;

  // --- APP 功能配置项 ---
  /// 是否渐变播放背景
  RxBool isGradientBackground = false.obs;
  /// 是否开启顶部歌词
  RxBool isTopLyricOpen = true.obs;
  /// 是否开启圆形专辑
  RxBool isRoundAlbumOpen = false.obs;
  /// 是否开启缓存
  RxBool isCacheOpen = false.obs;
  /// 是否开启高音质
  RxBool isHighSoundQualityOpen = false.obs;
  /// 自定义背景路径（空表示未设置自定义背景）
  RxString customBackgroundPath = ''.obs;

  // --- 控制器 ---
  /// Home页面侧滑抽屉
  ZoomDrawerController zoomDrawerController = ZoomDrawerController();
  /// Home页面PageView
  PageController homePageController = PageController();
  bool isHomePageControllerInited = false;
  /// Home页面Panel
  PanelController panelController = PanelController();
  late AnimationController panelAnimationController;
  /// Home页面底部Panel中专辑封面的PageView
  PageController albumPageController = PageController(viewportFraction: 1/3);

  late PageController panelPageController;
  late TabController panelTabController;
  late TabController panelCommentTabController;



  /// 歌词滚动控制器
  ItemScrollController lyricScrollController = ItemScrollController();
  ItemPositionsListener lyricScrollListener = ItemPositionsListener.create();
  /// 播放列表滚动控制器
  ScrollController playListScrollController = ScrollController();

  // --- 播放控制 ---
  /// 播放器handler
  final BujuanAudioHandler audioServeHandler = GetIt.instance<BujuanAudioHandler>();
  /// 循环方式
  Rx<AudioServiceRepeatMode> audioServiceRepeatMode = AudioServiceRepeatMode.all.obs;
  RxBool isPlaying = false.obs;
  RxBool isFmMode = false.obs;

  // --- 当前播放 ---
  /// 当前播放列表
  RxList<MediaItem> curPlayList = <MediaItem>[].obs;
  /// 当前播放歌曲
  Rx<MediaItem> curMediaItem = const MediaItem(id: '', title: '暂无', duration: Duration(seconds: 10)).obs;
  /// 当前播放歌曲在列表中的位置（由 BujuanAudioHandler 更新）
  RxInt curPlayIndex = 0.obs;
  RxInt lastPlayIndex = 0.obs;
  /// 相似歌单
  RxList<Play> simiSongCollectionList = <Play>[].obs;

  // --- 歌词 ---
  /// 解析后的歌词数组
  List<LyricsLineModel> lyricsLineModels = <LyricsLineModel>[].obs;
  /// 是否有翻译歌词
  RxBool hasTransLyrics = false.obs;
  /// 歌词是否被用户滚动中
  RxBool isLyricsMoving = false.obs;
  /// 当前歌词下标
  RxInt currLyricIndex = (-2).obs;    // -2表示currLyricIndex未配置，-1表示前奏阶段无歌词
  /// 当前歌词（整行）
  RxString currLyric = ''.obs;
  /// 当前播放进度
  Rx<Duration> curPlayDuration = Duration.zero.obs;
  Duration lastPlayDuration = Duration.zero;

  // --- 滚动状态（歌词和播放列表共用） ---
  /// 滚动起始的y位置
  RxDouble scrollDown = 0.0.obs;
  /// 是否可以滚动
  RxBool canScroll = true.obs;

  // --- 用户信息 ---
  RxList<int> likeIds = <int>[].obs;
  Rx<LoginStatus> loginStatus = LoginStatus.noLogin.obs;
  Rx<NeteaseAccountInfoWrap> userData = NeteaseAccountInfoWrap().obs;
  
  @override
  void onInit() async {
    panelAnimationController = AnimationController(vsync: this, value: 0);

    panelTabController = TabController(
        length: 3,
        initialIndex: 1,
        vsync: this
    );
    panelTabController.addListener(() {
      if (panelTabController.indexIsChanging) {
        print('2page: ${panelTabController.indexIsChanging}');
        panelPageController.animateToPage(panelTabController.index, duration: Duration(milliseconds: 300), curve: Curves.linear);
      }
    });

    panelCommentTabController = TabController(length: 2, vsync: this);
    panelCommentTabController.addListener(() {
      if (panelCommentTabController.indexIsChanging) {
        print('2page: ${panelTabController.indexIsChanging}');
        panelPageController.animateToPage(panelCommentTabController.index + 2, duration: Duration(milliseconds: 300), curve: Curves.linear);
      }
    });

    panelPageController = PageController(initialPage: 1);
    panelPageController.addListener(() {
      int curPage = (panelPageController.page! + 0.5).toInt();
      curPanelPageIndex.value = curPage;

      // 避免循环监听
      if (panelTabController.indexIsChanging || panelCommentTabController.indexIsChanging) return;

      if (panelPageController.page! <= 2) {
        panelTabController.index = curPage;
        panelTabController.offset = panelPageController.page! - curPage;
      } else {
        panelCommentTabController.index = curPage - 2;
        panelCommentTabController.offset = panelPageController.page! - curPage;
      }
    });

    box.get(noFirstOpen, defaultValue: false);
    customBackgroundPath.value = box.get(backgroundSp, defaultValue: '');
    isCacheOpen.value = box.get(cacheSp, defaultValue: false);
    isGradientBackground.value = box.get(gradientBackgroundSp, defaultValue: true);
    isTopLyricOpen.value = box.get(topLyricSp, defaultValue: false);
    isFmMode.value = box.get(fmSp, defaultValue: false);
    isHighSoundQualityOpen.value = box.get(highSong, defaultValue: false);
    isRoundAlbumOpen.value = box.get(roundAlbumSp, defaultValue: false);
    String repeatMode = box.get(repeatModeSp, defaultValue: 'all');

    audioServiceRepeatMode.value = AudioServiceRepeatMode.values.firstWhereOrNull((element) => element.name == repeatMode) ?? AudioServiceRepeatMode.all;
    // audioServeHandler.setRepeatMode(audioServiceRepeatMode.value);
    super.onInit();
  }
  @override
  void onReady() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initUserData();
      _initListener();
    });
    super.onReady();
  }
  @override
  void onDetached() {
    // TODO: implement onDetached
    // WidgetUtil.showToast('onDetached');
  }
  @override
  void onInactive() {
    // TODO: implement onInactive
    // WidgetUtil.showToast('onInactive');
  }
  @override
  void onPaused() {
    // TODO: implement onPaused
    // WidgetUtil.showToast('onPaused');
  }
  @override
  void onResumed() {
    // WidgetUtil.showToast('onResumed');
  }
  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  @override
  void didChangeMetrics() {
    // TODO: implement didChangeMetrics
    super.didChangeMetrics();
    // print('objectdidChangeMetrics');
  }
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (panelFullyOpened.isTrue) return;

    // 状态栏颜色控制
    bool isDarkMode = Theme.of(buildContext).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      statusBarBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ));
  }

  void initHomePageController(PageController controller) {
    isHomePageControllerInited = true;
    homePageController = controller;
    // 监听页面切换
    homePageController.addListener(() {
      int updatedPageIndex = (homePageController.page! + 0.5).toInt();

      // 页面切换了
      if (updatedPageIndex != curHomePageIndex.value) {
        // 启动倒计时器关闭抽屉
        _updateCloseDrawerTimer(1000);

        // 更新变量
        _lastHomePageIndex = curHomePageIndex.value;
        curHomePageIndex.value = updatedPageIndex;
        bool isSlidingUp = curHomePageIndex.value > _lastHomePageIndex;
        var direction = isSlidingUp ? NewAppBarTitleComingDirection.down : NewAppBarTitleComingDirection.up;

        // 更新appbar标题
        switch(updatedPageIndex)  {
          case 0:
            changeAppBarTitle(title: userData.value.profile?.nickname ?? "", direction: direction);
            break;
          case 1:
            changeAppBarTitle(title: "每日发现", direction: direction);
            break;
          case 2:
            changeAppBarTitle(title: "设置", direction: direction);
            break;
          case 3:
            changeAppBarTitle(title: "赞助开发者", direction: direction);
            break;
        }
      }
    });
  }

  // --- appbar 标题切换 ---
  changeAppBarTitle({required String title, String subTitle = '', required NewAppBarTitleComingDirection direction, bool willRollBack  = false}) {
    if (willRollBack) _lastPageTile = curPageTitle.value;
    curPageTitle.value = title;
    comingDirection = direction;
    curPageSubTitle.value =
    subTitle != "" ? "\n$subTitle" : "";
  }
  rollbackAppBarTitle() {
    curPageTitle.value = _lastPageTile;
    changeAppBarTitle(title: curPageTitle.value, direction: NewAppBarTitleComingDirection.left);
  }

  // --- 歌曲控制 ---
  /// 改变循环模式
  changeRepeatMode() {
    switch (audioServiceRepeatMode.value) {
      case AudioServiceRepeatMode.one:
        audioServiceRepeatMode.value = AudioServiceRepeatMode.none;
        break;
      case AudioServiceRepeatMode.none:
        audioServiceRepeatMode.value = AudioServiceRepeatMode.all;
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        audioServiceRepeatMode.value = AudioServiceRepeatMode.one;
        break;
    }
    audioServeHandler.setRepeatMode(audioServiceRepeatMode.value);
    box.put(repeatModeSp, audioServiceRepeatMode.value.name);
  }
  /// 播放/暂停
  playOrPause() async {
    // isPlaying.value = !isPlaying.value;
    isPlaying.value
        ? await audioServeHandler.pause()
        : await audioServeHandler.play();
  }
  /// 喜欢歌曲
  likeSong({bool? liked}) async {
    bool isLiked = likeIds.contains(int.parse(curMediaItem.value.id));
    if (liked != null) {
      isLiked = liked;
    }
    ServerStatusBean serverStatusBean = await NeteaseMusicApi().likeSong(curMediaItem.value.id, !isLiked);
    if (serverStatusBean.code == 200) {
      await audioServeHandler.updateMediaItem(curMediaItem.value..extras?['liked'] = !isLiked);
      if (PlatformUtils.isAndroid) {
        audioServeHandler.playbackState.add(audioServeHandler.playbackState.value.copyWith(
          controls: [
            (curMediaItem.value.extras?['liked'] ?? false)
                ? const MediaControl(label: 'fastForward', action: MediaAction.fastForward, androidIcon: 'drawable/audio_service_like')
                : const MediaControl(label: 'rewind', action: MediaAction.rewind, androidIcon: 'drawable/audio_service_unlike'),
            MediaControl.skipToPrevious,
            if (isPlaying.value) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop
          ],
          systemActions: {MediaAction.playPause, MediaAction.seek, MediaAction.skipToPrevious, MediaAction.skipToNext},
          androidCompactActionIndices: [1, 2, 3],
          processingState: AudioProcessingState.completed,
        ));
      }
      WidgetUtil.showToast(isLiked ? '取消喜欢成功' : '喜欢成功');
      if (isLiked) {
        likeIds.remove(int.parse(curMediaItem.value.id));
      } else {
        likeIds.add(int.parse(curMediaItem.value.id));
      }
    }
  }
  /// 根据下标播放歌曲
  playByIndex(int index, String queueTitle, {List<MediaItem>? playList}) async {
    audioServeHandler.queueTitle.value = queueTitle;
    audioServeHandler.changeQueueLists(playList ?? [], index: index);
  }
  /// 获取 FM 歌曲列表
  getFmSongList() async {
    SongListWrap2 songListWrap2 = await NeteaseMusicApi().userRadio();
    if (songListWrap2.code == 200) {
      List<Song> songs = songListWrap2.data ?? [];
      List<MediaItem> medias = songs
          .map((e) => MediaItem(
          id: e.id,
          duration: Duration(milliseconds: e.duration ?? 0),
          artUri: Uri.parse('${e.album?.picUrl ?? ''}?param=500y500'),
          extras: {
            'image': e.album?.picUrl ?? '',
            'liked': likeIds.contains(int.tryParse(e.id)),
            'artist': (e.artists ?? []).map((e) => jsonEncode(e.toJson())).toList().join(' / '),
            'type': MediaType.fm.name,
            'size': ''
          },
          title: e.name ?? "",
          album: e.album?.name ?? '',
          artist: (e.artists ?? []).map((e) => e.name).toList().join(' / ')))
          .toList();
      audioServeHandler.addFmItems(medias);
    }
  }
  /// 添加/删除歌曲到指定的歌单
  addOrDelSongToPlaylist(String playlistId, String songId, bool add) async{
    NeteaseMusicApi().playlistManipulateTracks(playlistId, songId, add);
  }

  /// 获取当前循环icon
  IconData getRepeatIcon() {
    IconData icon;
    if(isFmMode.value) {
      icon = TablerIcons.radio;
    } else {
      switch (audioServiceRepeatMode.value) {
        case AudioServiceRepeatMode.one:
          icon = TablerIcons.repeat_once;
          break;
        case AudioServiceRepeatMode.none:
          icon = TablerIcons.arrows_shuffle;
          break;
        case AudioServiceRepeatMode.all:
        case AudioServiceRepeatMode.group:
          icon = TablerIcons.repeat;
          break;
      }
    }
    return icon;
  }
  /// 改变panel位置
  changeSlidePosition(double value) {
    if (value == 2.086162576020456e-9) {
      return;
    }
    panelAnimationController.value = value;
    firstSlidePanelPosition.value = value;

    // 如果当前的状态改变
    if (panelFullyClosed.value != (value == 0.0)){
      // 更新状态
      panelFullyClosed.value = (value == 0.0);
    }
    if (panelOpened10.value != (value > 0.1)){
      // 更新状态
      panelOpened10.value = value > 0.1;
    }
    if (panelOpened50.value != (value > 0.5)) {
      panelOpened50.value = value > 0.5;
      if (panelOpened50.value) {
        _pageTitleBeforePanelOpen = curPageTitle.value;
        changeAppBarTitle(title: curMediaItem.value.title, subTitle: curMediaItem.value.artist ?? '', direction: NewAppBarTitleComingDirection.down);
      } else {
        changeAppBarTitle(title: _pageTitleBeforePanelOpen, direction: NewAppBarTitleComingDirection.up);
      }
    }
    if (panelOpened90.value != (value > 0.9)) {
      panelOpened90.value = value > 0.9;
    }
    if (panelFullyOpened.value != (value == 1.0)){
      // 更新状态
      panelFullyOpened.value = (value == 1.0);
      // 根据状态变更图标颜色
      _changeStatusIconColor(panelFullyOpened.value);
    }

  }
  /// 当按下返回键
  Future<bool> onWillPop() async {
    if (buildContext.router.canPop()) {
      rollbackAppBarTitle();
      return true;
    }
    if (panelController.isPanelOpen) {
      panelController.close();
      return false;
    }
    if (zoomDrawerController.isOpen!()) {
      zoomDrawerController.close!();
      return false;
    }
    if (homePageController.page != 0) {
      homePageController.animateToPage(0, duration: Duration(milliseconds: 100 * (homePageController.page)!.toInt()), curve: Curves.linear);
      return false;
    } else {
      SystemNavigator.pop();
    }
    return true;
  }
  bool intervalClick(int gapClickTime) {
    // 防重复提交
    if (DateTime.now().difference(_lastPopTime) > Duration(seconds: gapClickTime)) {
      _lastPopTime = DateTime.now();
      return true;
    } else {
      return false;
    }
  }
  List<MediaItem> song2ToMedia(List<Song2> songs) {
    return songs
        .map((e) => MediaItem(
        id: e.id,
        duration: Duration(milliseconds: e.dt ?? 0),
        artUri: Uri.parse('${e.al?.picUrl ?? ''}?param=500y500'),
        extras: {
          'type': MediaType.playlist.name,
          'image': e.al?.picUrl ?? '',
          'liked': likeIds.contains(int.tryParse(e.id)),
          'artist': (e.ar ?? []).map((e) => jsonEncode(e.toJson())).toList().join(' / '),
          'album': jsonEncode(e.al?.toJson()),
          'mv': e.mv,
          'fee': e.fee
        },
        title: e.name ?? "",
        album: e.al?.name,
        artist: (e.ar ?? []).map((e) => e.name).toList().join(' / ')))
        .toList();
  }


  _initUserData() {
    String userDataStr = box.get(loginData) ?? '';
    if (userDataStr.isNotEmpty) {
      loginStatus.value = LoginStatus.login;
      userData.value = NeteaseAccountInfoWrap.fromJson(jsonDecode(userDataStr));
      changeAppBarTitle(title: userData.value.profile?.nickname ?? "", direction: NewAppBarTitleComingDirection.up);
    }
  }
  _initListener() {
    // 监听歌词滚动
    lyricScrollListener.itemPositions.addListener(() {});
    // 监听抽屉展开程度
    zoomDrawerController.addListener!((drawerOpenDegree) {
      //  抽屉状态改变
      if ((drawerOpenDegree == 0.0) != isDrawerClosed.value) {
        // 刷新抽屉状态
        isDrawerClosed.value = drawerOpenDegree == 0.0;
        if (!isDrawerClosed.value) {
          // 启动倒计时器关闭抽屉
          _updateCloseDrawerTimer(3000);
        } else {
          _updateCloseDrawerTimer(0);
        }

      }
    });
    // 监听album封面滚动
    albumPageController.addListener(() {
      if(!_isAlbumPageViewScrollingListenerAdded && albumPageController.hasClients) {
        albumPageController.position.isScrollingNotifier.addListener(() {
          debugPrint('isScrolling: ${albumPageController.position.isScrollingNotifier.value}');
          isAlbumPageViewScrolling.value = albumPageController.position.isScrollingNotifier.value;
        });
        _isAlbumPageViewScrollingListenerAdded = true;
      }
    });

    // 监听播放列表切换
    audioServeHandler.queue.listen((mediaItems) {
      curPlayList
        ..clear()
        ..addAll(mediaItems);
    });
    // 监听歌曲切换
    audioServeHandler.mediaItem.listen((mediaItem) async {
      // 状态清空
      lyricsLineModels.clear();
      curPlayDuration.value = Duration.zero;
      currLyricIndex.value = -2;
      currLyric.value = '';

      // 更新当前歌曲信息
      if (mediaItem == null) return;
      curMediaItem.value = mediaItem;
      _updateAlbumColor();
      _getLyric();
      _animatePlayListToCurPlayIndex();
    });
    // 监听播放状态变化
    audioServeHandler.playbackState.listen((playbackState) {
      debugPrint('playbackState: ${playbackState.playing}');
      isPlaying.value = playbackState.playing;
    });
    //监听实时进度变化
    AudioService.createPositionStream(minPeriod: const Duration(microseconds: 800), steps: 1000).listen((newCurPlayingDuration) {
      //如果没有展示播放页面就先不监听（节省资源）
      if (panelFullyClosed.isTrue) return;
      //如果监听到的毫秒大于歌曲的总时长 置0并stop
      if (newCurPlayingDuration.inMilliseconds > (curMediaItem.value.duration?.inMilliseconds ?? 0)) {
        curPlayDuration.value = Duration.zero;
        return;
      }
      curPlayDuration.value = newCurPlayingDuration;
      if (!isLyricsMoving.value && lyricsLineModels.isNotEmpty && !isAlbumVisible.value) {
        // 找不到当前时间对应的歌词，此时realTimeLyricIndex为-1，表示为前奏阶段，刚好显示空白
        int realTimeLyricIndex = lyricsLineModels.lastIndexWhere((element) => element.startTime! <= curPlayDuration.value.inMilliseconds);
        print('realTimeLyricIndex: $realTimeLyricIndex');
        if (realTimeLyricIndex != currLyricIndex.value) {
          currLyricIndex.value = realTimeLyricIndex;
          lyricScrollController.scrollTo(index: realTimeLyricIndex == -1 ? 1 : realTimeLyricIndex + 1, alignment: 0.4, duration: const Duration(milliseconds: 500));
          if (isTopLyricOpen.value) currLyric.value = lyricsLineModels[currLyricIndex.value].mainText ?? '';
        }
      }
    });
  }
  /// 滚动播放列表到当前播放歌曲
  _animatePlayListToCurPlayIndex() async {
    bool isScrolledToBottom = playListScrollController.position.pixels >= playListScrollController.position.maxScrollExtent;
    int index = curPlayList.indexWhere((element) => element.id == curMediaItem.value.id);
    if (index != -1 && !isScrolledToBottom) {
      double offset = 110.w * index;
      print('XYXYoffset: $offset');
      await playListScrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.linear);
    }
  }

  _updateCloseDrawerTimer(double timeValue) {
    if (_timerCounter == 0) {
      _timerCounter = timeValue;
      Timer.periodic(const Duration(milliseconds: 50), (timer) {
        _timerCounter -= 50;
        if (_timerCounter <= 0) {
          _timerCounter = 0;
          timer.cancel();
          if (zoomDrawerController.isOpen!()) {
            zoomDrawerController.close!();
          }
        }
      });
    } else {
      _timerCounter = timeValue;
    }
  }
  /// 获取歌词
  _getLyric() async {
    hasTransLyrics.value = false;

    // 先从本地获取歌词
    String lyric = box.get('lyric_${curMediaItem.value.id}') ?? '';
    String lyricTran = box.get('lyricTran_${curMediaItem.value.id}') ?? '';
    // 本地为空则从网络获取，并缓存
    if (lyric.isEmpty) {
      SongLyricWrap songLyricWrap = await NeteaseMusicApi().songLyric(curMediaItem.value.id);
      lyric = songLyricWrap.lrc.lyric ?? "";
      lyricTran = songLyricWrap.tlyric.lyric ?? "";
      box.put('lyric_${curMediaItem.value.id}', lyric);
      box.put('lyricTran_${curMediaItem.value.id}', lyricTran);
    }

    // 更新 lyricsLineModels
    if (lyric.isNotEmpty) {
      var list = ParserLrc(lyric).parseLines();
      var listTran = ParserLrc(lyricTran).parseLines();
      if (lyricTran.isNotEmpty) {
        hasTransLyrics.value = true;
        lyricsLineModels.addAll(list.map((e) {
          int index = listTran.indexWhere((element) => element.startTime == e.startTime);
          if (index != -1) e.extText = listTran[index].mainText;
          return e;
        }).toList());
      } else {
        lyricsLineModels.addAll(list);
      }
      lyricScrollController.jumpTo(index: 1, alignment: 0.4);
    }
  }
  /// 获取专辑颜色
  _updateAlbumColor() async {
    OtherUtils.getImageColor('${curMediaItem.value.extras?['image'] ?? ''}?param=500y500').then((paletteGenerator) {
      albumColors.value = paletteGenerator;

      // 更新panel中的色调
      var color = albumColors.value.darkMutedColor?.color
          ?? albumColors.value.darkVibrantColor?.color
          ?? albumColors.value.dominantColor?.color
          ?? Colors.white;
      bodyColor.value = ThemeData.estimateBrightnessForColor(color) == Brightness.light
          ? Colors.black.withOpacity(.6)
          : Colors.white.withOpacity(.7);

      if (panelFullyOpened.isTrue) {
        _changeStatusIconColor(true);
      }
    });
  }
  // TODO YU4422 待完善
  /// 改变状态栏图标颜色
  _changeStatusIconColor(bool changeByAlbumColor) {
    bool isLight;
    if (changeByAlbumColor) {
      var color = albumColors.value.darkMutedColor?.color
          ?? albumColors.value.darkVibrantColor?.color
          ?? albumColors.value.dominantColor?.color
          ?? Colors.white;
      // 获取 Album 颜色亮度
      Brightness brightness = ThemeData.estimateBrightnessForColor(color);
      isLight = brightness == Brightness.light;
    } else {
      isLight = !Get.isPlatformDarkMode;
    }
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ));
  }
  // TODO YU4422 相似歌单功能
  /// 获取相似歌单
  _getSimiSheet() async {
    //获取相似歌曲
    MultiPlayListWrap songListWrap = await NeteaseMusicApi().playListSimiList(curMediaItem.value.id);
    simiSongCollectionList
      ..clear()
      ..addAll(songListWrap.playlists ?? []);
  }
}

enum NewAppBarTitleComingDirection {
  up,
  down,
  left,
  right
}
