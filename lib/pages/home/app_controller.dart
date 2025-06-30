import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/common/lyric_parser/parser_lrc.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/pages/home/view/menu_view.dart';
import 'package:bujuan/widget/weslide/panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../common/bujuan_audio_handler.dart';
import '../../common/lyric_parser/lyrics_reader_model.dart';
import '../../common/netease_api/src/api/bean.dart';
import '../../routes/router.dart';
import '../../widget/custom_zoom_drawer/src/drawer_controller.dart';
import '../user/personal_page_controller.dart';

/// 所有Controller都放在HomeController中统一控制
class AppController extends SuperController with GetTickerProviderStateMixin {
  static AppController get to => Get.find();

  // --- 无功能分类 ---
  Box box = GetIt.instance<Box>();
  late BuildContext buildContext;
  /// 上次弹出时间（防止多次快速点击）
  var _lastPopTime = DateTime.now();

  // --- 用户信息 ---
  RxList<int> likeIds = <int>[].obs;
  Rx<LoginStatus> loginStatus = LoginStatus.noLogin.obs;
  Rx<NeteaseAccountInfoWrap> userData = NeteaseAccountInfoWrap().obs;

  // AppBar标题配置
  RxString curPageTitle = "初始化中...".obs;
  RxString curPageSubTitle = "".obs;
  NewAppBarTitleComingDirection comingDirection = NewAppBarTitleComingDirection.down;
  String _lastPageTile = "";
  String _pageTitleBeforePanelOpen = "";
  RxBool isInPlayListPage = false.obs;


  // --- APP 功能配置项 ---
  /// 是否渐变播放背景
  RxBool isGradientBackground = false.obs;
  // TODO YU4422 待实现
  /// 是否开启顶部歌词
  RxBool isTopLyricOpen = true.obs;
  /// 是否开启圆形专辑
  RxBool isRoundAlbumOpen = false.obs;
  /// 是否开启缓存
  RxBool isCacheOpen = false.obs;
  /// 是否开启高音质
  RxBool isHighSoundQualityOpen = false.obs;

  // --- 抽屉 ---
  /// Home页面侧滑抽屉
  ZoomDrawerController zoomDrawerController = ZoomDrawerController();
  /// 侧边抽屉Beans   // TODO YU4422 待规范
  final List<LeftMenuBean> leftMenus = [
    LeftMenuBean('个人中心', TablerIcons.user, Routes.user, '/home/user'),
    LeftMenuBean('推荐歌单', TablerIcons.smart_home, Routes.index, '/home/index'),
    // LeftMenuBean('本地歌曲', TablerIcons.file_music, Routes.local, '/home/local'),
    LeftMenuBean('个性设置', TablerIcons.settings, Routes.setting, '/home/settingL'),
    LeftMenuBean('捐赠', TablerIcons.coffee, Routes.coffee, ''),
  ];
  /// 抽屉开启状态
  RxBool isDrawerClosed = true.obs;
  /// 自动关闭抽屉倒计时（毫秒）
  double _timerCounter = 0.0;

  // --- Home页面PageView ---
  PageController homePageController = PageController();
  bool isHomePageControllerInited = false;
  RxInt curHomePageIndex = 0.obs;
  int _lastHomePageIndex = 0;

  // --- Panel ---
  PanelController panelController = PanelController();
  /// panel展开程度（0-1，1表示完全展开）
  RxBool panelFullyClosed = true.obs;
  RxBool panelOpened10 = false.obs;
  RxBool panelOpened50 = false.obs;
  RxBool panelOpened90 = false.obs;
  RxBool panelFullyOpened = false.obs;

  // --- 专辑封面 ---
  /// Home页面底部Panel中专辑封面的PageView
  PageController albumPageController = PageController(viewportFraction: 1/3,);
  RxBool isAlbumVisible = true.obs;
  bool isAlbumPageViewScrolling = false;
  bool isProgrammaticScrolling = false;
  Rx<Color> albumColor = Colors.white.obs;
  Rx<Color> panelWidgetColor = Colors.white.obs;

  late AnimationController panelAnimationController;

  // --- Panel中的pageview ---
  late PageController panelPageController;
  RxInt curPanelPageIndex = 1.obs;

  // --- Panel中的tabview
  late TabController panelTabController;
  late TabController panelCommentTabController;


  // --- 正在播放列表 ---
  ScrollController playListScrollController = ScrollController();


  // --- 歌词 ---
  ItemScrollController lyricScrollController = ItemScrollController();
  bool isLyricScrollingByUser = false;
  bool isLyricScrollingByItself = false;
  // TODO YU4422 沉浸式歌词，隐藏控件
  Timer? fullScreenLyricTimer;

  // --- 播放控制 ---
  /// 播放器handler
  late final BujuanAudioHandler audioHandler;
  // --- 播放器状态 ---
  /// 循环方式
  Rx<AudioServiceRepeatMode> curRepeatMode = AudioServiceRepeatMode.all.obs;
  /// 播放状态
  RxBool isPlaying = false.obs;
  /// FM状态
  RxBool isFmMode = false.obs;
  // --- 正在播放 ---
  /// 当前播放列表
  RxList<MediaItem> curPlayList = <MediaItem>[].obs;
  /// 当前播放歌曲
  Rx<MediaItem> curMediaItem = const MediaItem(id: '', title: '暂无', duration: Duration(seconds: 10)).obs;
  /// 当前播放索引
  RxInt curPlayIndex = 0.obs;
  // --- 歌词 ---
  /// 解析后的歌词数组
  RxList<LyricsLineModel> lyricsLineModels = <LyricsLineModel>[].obs;
  /// 是否有翻译歌词
  RxBool hasTransLyrics = false.obs;
  /// 当前播放进度
  Rx<Duration> curPlayDuration = Duration.zero.obs;
  /// 当前歌词下标
  RxInt currLyricIndex = (-2).obs;    // -2表示currLyricIndex未配置，-1表示前奏阶段无歌词
  /// 当前歌词（整行）
  RxString currLyric = ''.obs;
  
  @override
  void onInit() async {
    _initStorageState();
    _initUserData();
    _initUIController();
    super.onInit();
  }
  _initUIController() {
    panelAnimationController = AnimationController(vsync: this, value: 0);

    panelTabController = TabController(length: 3, initialIndex: 1, vsync: this)..addListener(() {
      if (panelTabController.indexIsChanging) {
        print('2page: ${panelTabController.indexIsChanging}');
        panelPageController.animateToPage(panelTabController.index, duration: Duration(milliseconds: 300), curve: Curves.linear);
      }
    });

    panelCommentTabController = TabController(length: 2, vsync: this)..addListener(() {
      if (panelCommentTabController.indexIsChanging) {
        panelPageController.animateToPage(panelCommentTabController.index + 2, duration: Duration(milliseconds: 300), curve: Curves.linear);
      }
    });

    panelPageController = PageController(initialPage: 1)..addListener(() {
      int curPage = (panelPageController.page! + 0.5).toInt();

      if (curPanelPageIndex.value != curPage) {
        curPanelPageIndex.value = curPage;
        if (curPage == 0) animatePlayListToCurPlayIndex();
      }

      // 避免循环监听
      if (panelTabController.indexIsChanging || panelCommentTabController.indexIsChanging) return;
      // 控制tab显示
      if (panelPageController.page! <= 2) {
        panelTabController.index = curPage;
        panelTabController.offset = panelPageController.page! - curPage;
      } else {
        panelCommentTabController.index = curPage - 2;
        panelCommentTabController.offset = panelPageController.page! - curPage;
      }
    });

    // 监听album封面滚动
    albumPageController = PageController(viewportFraction: 1/3)..addListener(() {
      isAlbumPageViewScrolling = true;
      if (albumPageController.page?.toInt() == albumPageController.page) {
        isAlbumPageViewScrolling = false;
      }
    });
  }
  _initUserData() {
    String userDataStr = box.get(loginData) ?? '';
    if (userDataStr.isNotEmpty) {
      loginStatus.value = LoginStatus.login;
      userData.value = NeteaseAccountInfoWrap.fromJson(jsonDecode(userDataStr));
      changeAppBarTitle(title: userData.value.profile?.nickname ?? "", direction: NewAppBarTitleComingDirection.up);
    } else {
      loginStatus.value = LoginStatus.noLogin;
      changeAppBarTitle(title: '扫码登录', direction: NewAppBarTitleComingDirection.up);
    }
  }
  _initStorageState() async {
    isCacheOpen.value = box.get(cacheSp, defaultValue: false);
    isGradientBackground.value = box.get(gradientBackgroundSp, defaultValue: true);
    isTopLyricOpen.value = box.get(topLyricSp, defaultValue: false);
    isFmMode.value = box.get(fmSp, defaultValue: false);
    isHighSoundQualityOpen.value = box.get(highSong, defaultValue: false);
    isRoundAlbumOpen.value = box.get(roundAlbumSp, defaultValue: false);
  }

  @override
  Future<void> onReady() async {
    audioHandler = await AudioService.init(
      builder: () => BujuanAudioHandler(),
      config: const AudioServiceConfig(
        androidStopForegroundOnPause: false,
        androidNotificationChannelId: 'com.yu4422.purrr.channel.audio',
        androidNotificationChannelName: 'Music playback',
        androidNotificationIcon: 'drawable/audio_service_icon',
      ),
    );
    _initAudioStateListener();
    await _restoreAudioHandlerState();
    super.onReady();
  }
  _restoreAudioHandlerState() async {
    // 恢复播放模式
    String repeatMode = box.get(repeatModeSp, defaultValue: 'all');
    curRepeatMode.value = AudioServiceRepeatMode.values.firstWhereOrNull((element) => element.name == repeatMode) ?? AudioServiceRepeatMode.all;
    await audioHandler.setRepeatMode(curRepeatMode.value);
    // 恢复播放列表
    List<String> stringPlayList = box.get(playQueue, defaultValue: <String>[]);
    if (stringPlayList.isNotEmpty) {
      List<MediaItem> playlist = await compute(stringToPlayList, stringPlayList);
      String curSongId = box.get(curPlaySongId, defaultValue: '');
      int index = playlist.indexWhere((element) => element.id == curSongId);
      await _changePlayList(playlist, playNow: false, index: index, changePlayerSource: true, needStore: false);
    }
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
    bool isDarkMode = buildContext.isDarkMode;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      statusBarBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ));
  }

  initHomePageController(PageController controller) {
    isHomePageControllerInited = true;
    homePageController = controller..addListener(() {
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
    // 监听抽屉展开状态
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
  changeRepeatMode() async {
    AudioServiceRepeatMode newRepeatMode;
    switch (curRepeatMode.value) {
      // 单曲 -> 随机
      case AudioServiceRepeatMode.one:
        newRepeatMode = AudioServiceRepeatMode.none;
        await audioHandler.reorderPlayList(shufflePlayList: true);
        break;
      // 随机 -> 全部
      case AudioServiceRepeatMode.none:
        newRepeatMode = AudioServiceRepeatMode.all;
        await audioHandler.reorderPlayList(shufflePlayList: false);
        break;
      // 全部 -> 单曲
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
      newRepeatMode = AudioServiceRepeatMode.one;
        break;
    }
    audioHandler.setRepeatMode(newRepeatMode);
    curRepeatMode.value = newRepeatMode;
    box.put(repeatModeSp, newRepeatMode.name);
  }
  /// 获取当前循环icon
  IconData getRepeatIcon() {
    IconData icon;
    if(isFmMode.value) {
      icon = TablerIcons.radio;
    } else {
      switch (curRepeatMode.value) {
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
  /// 打开FM模式
  openFmMode() async {
    panelPageController.jumpToPage(1);
    panelController.open();
    if(isFmMode.value) {
      if (isPlaying.isFalse) await playOrPause();
    } else {
      _getFmSongList().then((value) async {
        await _changePlayList(value, playNow: true, changePlayerSource: true);
      });
      // 保存FM开启状态
      isFmMode.value = true;
      box.put(fmSp, true);
    }
  }
  /// 播放/暂停
  playOrPause() async {
    isPlaying.value
        ? await audioHandler.pause()
        : await audioHandler.play();
  }
  /// 喜欢歌曲
  toggleLikeStatus() async {
    bool isLiked = !likeIds.contains(int.parse(curMediaItem.value.id));

    NeteaseMusicApi().likeSong(curMediaItem.value.id, isLiked).then((serverStatusBean) async {
      if (serverStatusBean.code == 200) {
        // 修改状态栏
        await audioHandler.updateMediaItem(curMediaItem.value..extras?['liked'] = isLiked);
        // 显示提示
        WidgetUtil.showToast(isLiked ? '取消喜欢成功' : '喜欢成功');
        // 修改喜欢列表
        isLiked
            ? likeIds.add(int.parse(curMediaItem.value.id))
            : likeIds.remove(int.parse(curMediaItem.value.id));

      }
    });
  }
  /// 根据下标播放歌曲
  playNewPlayListByIndex(List<MediaItem> playList, int index, {String queueTitle = ""}) async {
    // 切歌单退出FM模式
    if (isFmMode.value) {
      isFmMode.value = false;
      box.put(fmSp, false);
    }
    audioHandler.queueTitle.value = queueTitle;
    await _changePlayList(playList ?? [], index: index, changePlayerSource: true, playNow: true);
  }
  /// 添加/删除歌曲到指定的歌单
  addOrDelSongToPlaylist(String playlistId, String songId, bool add) async{
    NeteaseMusicApi().playlistManipulateTracks(playlistId, songId, add);
  }
  /// 当按下返回键
  Future<bool> onWillPop() async {
    if (panelController.isPanelOpen) {
      panelController.close();
      return false;
    }
    if (buildContext.router.canPop()) {
      rollbackAppBarTitle();
      return true;
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
    if (DateTime.now().difference(_lastPopTime) > Duration(milliseconds: gapClickTime)) {
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
  // --- UI控制方法 ---

  updateCurPlayIndex(int newIndex) async {
    // 更新UI
    bool isSkipToNext = newIndex > curPlayIndex.value;
    bool isNearBy = (newIndex - curPlayIndex.value).abs() <= 1;
    curPlayIndex.value = newIndex;
    // 切换专辑封面
    if (!isAlbumPageViewScrolling) {
      isProgrammaticScrolling = true;
      if (isNearBy && panelFullyOpened.isTrue) {
        albumPageController.animateToPage(newIndex, duration: const Duration(milliseconds: 300), curve: Curves.linear).then(((_) {
          isProgrammaticScrolling = false;
        }));
      } else {
        albumPageController.jumpToPage(newIndex);
        isProgrammaticScrolling = false;
      }
    }
    // 切换AppBar标题
    if (panelFullyOpened.isTrue) {
      changeAppBarTitle(
          title: curPlayList[curPlayIndex.value].title,
          subTitle: curPlayList[curPlayIndex.value].artist ?? "",
          direction: !isNearBy
              ? NewAppBarTitleComingDirection.none
              : isSkipToNext
              ? NewAppBarTitleComingDirection.right
              : NewAppBarTitleComingDirection.left
      );
    }

    // 私人FM模式 播放到最后一首拉取新的FM歌曲列表
    if (isFmMode.isTrue && newIndex == curPlayList.length - 1) {
      _getFmSongList().then((value) {
        _changePlayList(value..insert(0, curMediaItem.value), playNow: false, changePlayerSource: false);
      });
    }
  }
  /// 滚动播放列表到当前播放歌曲
  animatePlayListToCurPlayIndex() async {
    bool isScrolledToBottom = playListScrollController.position.pixels >= playListScrollController.position.maxScrollExtent;
    int index = curPlayList.indexWhere((element) => element.id == curMediaItem.value.id);
    if (index != -1 && !isScrolledToBottom) {
      double offset = 60.0 * index;
      print('XYXYoffset: $offset');
      await playListScrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.linear);
    }
  }
  /// 改变panel位置
  changeSlidePosition(double value) async {
    if (value == 2.086162576020456e-9) {
      return;
    }
    panelAnimationController.value = value;

    // 如果当前的状态改变
    if (panelFullyClosed.value != (value == 0.0)){
      // 更新状态
      panelFullyClosed.value = (value == 0.0);
    }
    if (panelOpened10.value != (value > 0.1)){
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
      if (curPanelPageIndex.value == 0) {
        await animatePlayListToCurPlayIndex();
      }
    }

  }

  _initAudioStateListener() {
    // 监听播放列表切换
    audioHandler.queue.listen((mediaItems) {
      curPlayList
        ..clear()
        ..addAll(mediaItems);
    });
    // 监听歌曲切换
    audioHandler.mediaItem.listen((mediaItem) async {
      // 更新当前歌曲信息
      if (mediaItem == null) return;
      curMediaItem.value = mediaItem;
      // 本地保存当前播放状态
      box.put(curPlaySongId, mediaItem.id);

      await _updateAlbumColor();
      await _getLyric();

      // 播放列表滚动到当前歌曲
      if (panelFullyOpened.isTrue && curPanelPageIndex.value == 0) {
        await animatePlayListToCurPlayIndex();
      }

      // 歌词复位
      curPlayDuration.value = Duration.zero;
      currLyricIndex.value = -2;
      currLyric.value = '';
      if (panelFullyOpened.isTrue && curPanelPageIndex.value == 1 && isAlbumVisible.isFalse) {
        lyricScrollController.jumpTo(index: 0);
      }

    });
    // 监听播放状态变化
    audioHandler.playbackState.listen((playbackState) {
      print("xxxxxx" + playbackState.toString());
      isPlaying.value = playbackState.playing;
      if(playbackState.processingState == AudioProcessingState.completed) audioHandler.skipToNext();
    });
    //监听实时进度变化
    AudioService.createPositionStream(minPeriod: const Duration(microseconds: 800), steps: 1000).listen((newCurPlayingDuration) {
      //如果没有展示播放页面就先不监听（节省资源）
      if (panelFullyOpened.isFalse) return;
      //如果监听到的毫秒大于歌曲的总时长 置0并stop
      if (newCurPlayingDuration.inMilliseconds > (curMediaItem.value.duration?.inMilliseconds ?? 0)) {
        curPlayDuration.value = Duration.zero;
        return;
      }
      curPlayDuration.value = newCurPlayingDuration;
      if (lyricsLineModels.isNotEmpty && !isAlbumVisible.value) {
        // 找不到当前时间对应的歌词，此时realTimeLyricIndex为-1，表示为前奏阶段，刚好显示空白
        int realTimeLyricIndex = lyricsLineModels.lastIndexWhere((element) => element.startTime! <= curPlayDuration.value.inMilliseconds);
        if (realTimeLyricIndex != currLyricIndex.value) {
          currLyricIndex.value = realTimeLyricIndex;
          if (isTopLyricOpen.value) currLyric.value = lyricsLineModels[currLyricIndex.value].mainText ?? '';
          if (!isLyricScrollingByUser) {
            isLyricScrollingByItself = true;
            lyricScrollController.scrollTo(
                index: realTimeLyricIndex == -1 ? 1 : realTimeLyricIndex + 1,
                alignment: 0.4,
                duration: const Duration(milliseconds: 500),
                curve: Curves.decelerate
            ).then((_) => isLyricScrollingByItself = false);
          }
        }
      }
    });
  }
  /// 获取 FM 歌曲列表
  Future<List<MediaItem>> _getFmSongList() async {
    SongListWrap2 songListWrap2 = await NeteaseMusicApi().userRadio();
    if (songListWrap2.code == 200) {
      List<Song> songs = songListWrap2.data ?? [];
      return songs.map((e) => MediaItem(
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
          artist: (e.artists ?? []).map((e) => e.name).toList().join(' / ')
      )).toList();
    } else {
      return [];
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
  /// 更新歌词
  _getLyric() async {
    // 更新 lyricsLineModels
    lyricsLineModels.clear();
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
    if (lyric.isNotEmpty) {
      var list = ParserLrc(lyric).parseLines();
      var listTran = ParserLrc(lyricTran).parseLines();
      if (lyricTran.isNotEmpty) {
        hasTransLyrics.value = true;
        list = list.map((e) {
          int index = listTran.indexWhere((element) => element.startTime == e.startTime);
          if (index != -1) e.extText = listTran[index].mainText;
          return e;
        }).toList();
      }
      lyricsLineModels.addAll(list);
    } else {
      // TODO YU4422 没有歌词的时候，加入提示
      lyricsLineModels.add(LyricsLineModel()..mainText = "没有歌词哦～");
    }
    // lyricScrollController.jumpTo(index: 1, alignment: 0.4);
  }
  /// 获取专辑颜色
  _updateAlbumColor() async {
    OtherUtils.getImageColor('${curMediaItem.value.extras?['image'] ?? ''}?param=500y500').then((paletteGenerator) {
      // 更新panel中的色调
      albumColor.value = paletteGenerator.darkMutedColor?.color
            ?? paletteGenerator.darkVibrantColor?.color
            ?? paletteGenerator.dominantColor?.color
            ?? Colors.black;

      panelWidgetColor.value = ThemeData.estimateBrightnessForColor(albumColor.value) == Brightness.light
          ? Colors.black
          : Colors.white;

      if (panelFullyOpened.isTrue) {
        _changeStatusIconColor(true);
      }
    });
  }
  // TODO YU4422 待完善
  /// 改变状态栏图标颜色
  _changeStatusIconColor(bool changeByAlbumColor) {
    bool isLight = changeByAlbumColor
        ? ThemeData.estimateBrightnessForColor(albumColor.value) == Brightness.light
        : !Get.isPlatformDarkMode;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ));
  }
  _changePlayList(List<MediaItem> playList, {required bool changePlayerSource, required bool playNow, int index = 0, bool needStore = true}) async {
    // 更改播放列表
    await audioHandler.changePlayList(playList, index);
    // 是否更改播放源
    if (changePlayerSource) {
      // 是否直接开始播放
      await audioHandler.changePlayerSource(playNow: playNow);
    }
    if (needStore) {
      box.put(playQueue, await compute(playListToString, playList));
    }
  }
}

class MediaItemBean {
  /// A unique id.
  final String id;

  /// The title of this media item.
  final String title;

  /// The album this media item belongs to.
  final String? album;

  /// The artist of this media item.
  final String? artist;

  /// The genre of this media item.
  final String? genre;

  /// The duration of this media item.
  final Duration? duration;

  /// The artwork for this media item as a uri.
  final Uri? artUri;

  /// Whether this is playable (i.e. not a folder).
  final bool? playable;

  /// Override the default title for display purposes.
  final String? displayTitle;

  /// Override the default subtitle for display purposes.
  final String? displaySubtitle;

  /// Override the default description for display purposes.
  final String? displayDescription;

  /// The rating of the MediaItemMessage.

  /// A map of additional metadata for the media item.
  ///
  /// The values must be integers or strings.
  final Map<String, dynamic>? extras;

  /// Creates a [MediaItemBean].
  ///
  /// The [id] must be unique for each instance.
  const MediaItemBean({
    required this.id,
    required this.title,
    this.album,
    this.artist,
    this.genre,
    this.duration,
    this.artUri,
    this.playable = true,
    this.displayTitle,
    this.displaySubtitle,
    this.displayDescription,
    this.extras,
  });

  /// Creates a [MediaItemBean] from a map of key/value pairs corresponding to
  /// fields of this class.
  factory MediaItemBean.fromMap(Map<String, dynamic> raw) => MediaItemBean(
    id: raw['id'] as String,
    title: raw['title'] as String,
    album: raw['album'] as String?,
    artist: raw['artist'] as String?,
    genre: raw['genre'] as String?,
    duration: raw['duration'] != null ? Duration(milliseconds: raw['duration'] as int) : null,
    artUri: raw['artUri'] != null ? Uri.parse(raw['artUri'] as String) : null,
    playable: raw['playable'] as bool?,
    displayTitle: raw['displayTitle'] as String?,
    displaySubtitle: raw['displaySubtitle'] as String?,
    displayDescription: raw['displayDescription'] as String?,
    extras: castMap(raw['extras'] as Map?),
  );

  /// Converts this [MediaItemBean] to a map of key/value pairs corresponding to
  /// the fields of this class.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'album': album,
    'artist': artist,
    'genre': genre,
    'duration': duration?.inMilliseconds,
    'artUri': artUri?.toString(),
    'playable': playable,
    'displayTitle': displayTitle,
    'displaySubtitle': displaySubtitle,
    'displayDescription': displayDescription,
    'extras': extras,
  };
}
Future<List<MediaItem>> stringToPlayList(List<String> cachedPlayList) async {
  return cachedPlayList.map((e) {
    var mediaItemBean = MediaItemBean.fromMap(jsonDecode(e));
    return MediaItem(
      id: mediaItemBean.id,
      duration: mediaItemBean.duration,
      artUri: mediaItemBean.artUri,
      extras: mediaItemBean.extras,
      title: mediaItemBean.title,
      artist: mediaItemBean.artist,
      album: mediaItemBean.album,
    );
  }).toList();
}
Future<List<String>> playListToString(List<MediaItem> playList) async {
  return playList.map((e) => jsonEncode(MediaItemBean(
    id: e.id,
    album: e.album,
    title: e.title,
    artist: e.artist,
    duration: e.duration,
    artUri: e.artUri,
    extras: e.extras,
  ).toMap())).toList();
}

enum NewAppBarTitleComingDirection {
  up,
  down,
  left,
  right,
  none
}
