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

  // --- 用户信息 ---
  RxList<int> likeIds = <int>[].obs;
  Rx<LoginStatus> loginStatus = LoginStatus.noLogin.obs;
  Rx<NeteaseAccountInfoWrap> userData = NeteaseAccountInfoWrap().obs;

  // AppBar标题配置
  RxString curPageTitle = "初始化中...".obs;
  RxString curPageSubTitle = "".obs;
  Rx<Color> curPageTitleColor = Colors.white.obs;
  NewAppBarTitleComingDirection comingDirection = NewAppBarTitleComingDirection.down;
  List _lastPageTitle = [];
  List _lastPageSubTitle = [];
  List<Color> _lastAppBarTitleColor = [];
  String _pageTitleBeforePanelOpen = "";
  Color _pageTitleColorBeforePanelOpen = Colors.white;

  RxBool isInPlayListPage = false.obs;

  // --- APP 功能配置项 ---
  /// 是否渐变播放背景
  RxBool isGradientBackground = false.obs;
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

  // --- 专辑封面 ---
  /// Home页面底部Panel中专辑封面的PageView
  PageController albumPageController = PageController(viewportFraction: 1/3,);
  RxBool isAlbumVisible = true.obs;
  bool isAlbumScrollingManully = false;
  bool isAlbumScrollingProgrammatic = false;
  Rx<Color> albumColor = Colors.white.obs;
  Rx<Color> panelWidgetColor = Colors.white.obs;

  // --- Panel ---
  PanelController panelController = PanelController();
  late AnimationController panelAnimationController;
  /// panel展开程度（0-1，1表示完全展开）
  RxBool panelFullyClosed = true.obs;
  RxBool panelOpened10 = false.obs;
  RxBool panelOpened50 = false.obs;
  RxBool panelOpened90 = false.obs;
  RxBool panelFullyOpened = false.obs;

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

  // --- 播放器状态 ---
  late final AudioServiceHandler audioHandler;
  /// 播放状态
  RxBool isPlaying = false.obs;
  /// 循环方式
  Rx<AudioServiceRepeatMode> curRepeatMode = AudioServiceRepeatMode.all.obs;
  /// FM状态
  RxBool isFmMode = false.obs;
  /// 当前播放列表
  RxList<MediaItem> curPlayList = <MediaItem>[].obs;
  /// 当前播放歌曲
  Rx<MediaItem> curMediaItem = const MediaItem(id: '', title: '暂无', duration: Duration(seconds: 10)).obs;
  /// 当前播放索引
  RxInt curPlayIndex = 0.obs;
  /// 当前播放进度
  Rx<Duration> curPlayDuration = Duration.zero.obs;
  // --- 歌词 ---
  /// 解析后的歌词数组
  RxList<LyricsLineModel> lyricsLineModels = <LyricsLineModel>[].obs;
  /// 是否有翻译歌词
  RxBool hasTransLyrics = false.obs;
  /// 当前歌词下标
  RxInt currLyricIndex = (-1).obs;
  
  @override
  void onInit() async {
    _initAppSetting();
    _initUserData();
    _initUIController();
    super.onInit();
  }
  _initUIController() {
    panelAnimationController = AnimationController(vsync: this, value: 0);

    panelTabController = TabController(length: 3, initialIndex: 1, vsync: this)..addListener(() {
      if (panelTabController.indexIsChanging) {
        panelPageController.animateToPage(panelTabController.index, duration: Duration(milliseconds: 300), curve: Curves.linear);
        if (panelTabController.index <= 1) {
          panelCommentTabController.index = 0;
          panelCommentTabController.offset = 0;
        }
      }
    });

    panelCommentTabController = TabController(length: 2, vsync: this)..addListener(() {
      if (panelCommentTabController.indexIsChanging) {
        panelPageController.animateToPage(panelCommentTabController.index + 2, duration: Duration(milliseconds: 300), curve: Curves.linear);
      }
    });

    panelPageController = PageController(initialPage: 1)..addListener(() async {
      int newPanelPageIndex = (panelPageController.page! + 0.5).toInt();

      if (curPanelPageIndex.value != newPanelPageIndex) {
        curPanelPageIndex.value = newPanelPageIndex;
        // 切换到正在播放列表页，滚动到当前播放
        if (newPanelPageIndex == 0) await _animatePlayListToCurSong();
      }
      // 避免循环监听
      if (panelTabController.indexIsChanging || panelCommentTabController.indexIsChanging) return;
      // 控制tab显示
      if (panelPageController.page! <= 2) {
        panelTabController.index = newPanelPageIndex;
        panelTabController.offset = panelPageController.page! - newPanelPageIndex;
      } else {
        panelCommentTabController.index = newPanelPageIndex - 2;
        panelCommentTabController.offset = panelPageController.page! - newPanelPageIndex;
      }
    });

    albumPageController = PageController(viewportFraction: 1/3);
  }
  _initUserData() {
    String userDataJson = box.get(loginData) ?? '';
    if (userDataJson.isNotEmpty) {
      loginStatus.value = LoginStatus.login;
      userData.value = NeteaseAccountInfoWrap.fromJson(jsonDecode(userDataJson));
      // changeAppBarTitle(title: userData.value.profile?.nickname ?? "", direction: NewAppBarTitleComingDirection.up);
    } else {
      loginStatus.value = LoginStatus.noLogin;
      // changeAppBarTitle(title: '扫码登录', direction: NewAppBarTitleComingDirection.up);
    }
  }
  _initAppSetting() async {
    isCacheOpen.value = box.get(cacheSp, defaultValue: false);
    isGradientBackground.value = box.get(gradientBackgroundSp, defaultValue: true);
    isHighSoundQualityOpen.value = box.get(highSong, defaultValue: false);
    isRoundAlbumOpen.value = box.get(roundAlbumSp, defaultValue: false);
  }

  @override
  Future<void> onReady() async {
    changeAppBarTitle(title: loginStatus.value == LoginStatus.login ? userData.value.profile?.nickname ?? "" : '扫码登录');
    await _initAudioHandler();
    super.onReady();
  }
  _initAudioHandler() async {
    audioHandler = await AudioService.init(
      builder: () => AudioServiceHandler(),
      config: const AudioServiceConfig(
        androidStopForegroundOnPause: false,
        androidNotificationChannelId: 'com.yu4422.purrr.channel.audio',
        androidNotificationChannelName: 'Music playback',
        androidNotificationIcon: 'drawable/audio_service_like',
      ),
    );
    // --- 初始化监听 ---
    // 监听播放列表切换
    audioHandler.queue.listen((mediaItems) async {
      curPlayList
        ..clear()
        ..addAll(mediaItems);
      // 处理仅更新播放列表的情况，重新计算并更新curPlayIndex
      await _updateCurPlayIndex(curMediaItemUpdated: false);
    });
    // 监听歌曲切换
    audioHandler.mediaItem.listen((mediaItem) async {
      // 更新当前歌曲信息
      if (mediaItem == null) return;
      curMediaItem.value = mediaItem;
      // 本地保存当前播放状态
      box.put(curPlaySongId, mediaItem.id);
      await _updateCurPlayIndex();
      // 私人FM模式 播放到最后一首拉取新的FM歌曲列表
      int newIndex = curPlayList.indexWhere((element) => element.id == curMediaItem.value.id);
      if (isFmMode.isTrue && newIndex == curPlayList.length - 1) {
         await _updateFmPlayList();
      }
    });
    // 监听播放状态变化
    audioHandler.playbackState.listen((playbackState) {
      isPlaying.value = playbackState.playing;
      if(playbackState.processingState == AudioProcessingState.completed) audioHandler.skipToNext();
    });
    // 监听播放进度变化
    AudioService.createPositionStream(minPeriod: const Duration(microseconds: 800), steps: 1000).listen((newCurPlayingDuration) async {
      curPlayDuration.value = newCurPlayingDuration;
      // 找不到当前时间对应的歌词，此时newLyricIndex为-1，表示为前奏阶段，刚好显示空白
      int newLyricIndex = lyricsLineModels.lastIndexWhere((element) => element.startTime! <= newCurPlayingDuration.inMilliseconds);
      // print("lyricIndexUpdate: " + newLyricIndex.toString());
      if (newLyricIndex != currLyricIndex.value) {
        currLyricIndex.value = newLyricIndex;
        await _animateLyricToCurLyric();
      }
    });
    // --- 从本地恢复上次关闭播放状态 ---
    await audioHandler.restoreLastPlayState();
  }
  _updateCurPlayIndex({bool curMediaItemUpdated = true}) async {
    int lastPlayIndex = curPlayIndex.value;
    int newIndex = curPlayList.indexWhere((element) =>
    element.id == curMediaItem.value.id);
    curPlayIndex.value = newIndex;
    if (curMediaItemUpdated) {
      // 更新背景
      await _updateAlbumColor();
      // 更新歌词
      await _updateLyric();
      // 更新歌曲标题
      _updateAppBarTitleToCurSong(lastPlayIndex);
    }
    // 切换专辑封面
    await _animateAlbumPageViewToCurSong();
    // 正在播放列表滚动到当前歌曲
    await _animatePlayListToCurSong();
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

        String title = "";
        // 更新appbar标题
        switch(updatedPageIndex)  {
          case 0:
            title = loginStatus.value == LoginStatus.login ? userData.value.profile?.nickname ?? "" : '扫码登录';
            break;
          case 1:
            title = "每日发现";
            break;
          case 2:
            title = "设置";
            break;
          case 3:
            title = "赞助开发者";
            break;
        }
        changeAppBarTitle(title: title, direction: direction);
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
  changeAppBarTitle({required String title, String subTitle = '', Color? appBarTitleColor, NewAppBarTitleComingDirection? direction, bool willRollBack  = false}) {
    if (willRollBack) {
      _lastPageTitle.add(curPageTitle.value);
      _lastPageSubTitle.add(curPageSubTitle.value.trim());
      _lastAppBarTitleColor.add(curPageTitleColor.value);
    }
    curPageTitle.value = title;
    curPageSubTitle.value = subTitle.isNotEmpty ? "\n$subTitle" : "";
    curPageTitleColor.value = appBarTitleColor ?? buildContext.theme.colorScheme.onPrimary;
    comingDirection = direction ?? NewAppBarTitleComingDirection.none;
  }

  _rollBackAppBarTitle({NewAppBarTitleComingDirection newAppBarTitleComingDirection = NewAppBarTitleComingDirection.left}) {
    changeAppBarTitle(title: _lastPageTitle.removeLast(), subTitle: _lastPageSubTitle.removeLast(), appBarTitleColor: _lastAppBarTitleColor.removeLast(), direction: newAppBarTitleComingDirection);
  }

  // --- 歌曲控制 ---

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
    if(isFmMode.isTrue) {
      // 处于FM模式，恢复播放
      if (isPlaying.isFalse) await playOrPause();
    } else {
      // 保存FM开启状态
      isFmMode.value = true;
      box.put(fmSp, true);
      await _updateFmPlayList(isInit: true);
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
  playNewPlayList(List<MediaItem> playList, int index, {String queueTitle = ""}) async {
    // 切歌单退出FM模式
    if (isFmMode.isTrue) {
      isFmMode.value = false;
      box.put(fmSp, false);
    }
    audioHandler.queueTitle.value = queueTitle;
    await audioHandler.changePlayList(playList, index: index, changePlayerSource: true, playNow: true);
  }
  /// 添加/删除歌曲到指定的歌单
  addOrDelSongToPlaylist(String playlistId, String songId, bool add) async{
    NeteaseMusicApi().playlistManipulateTracks(playlistId, songId, add);
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
        _pageTitleColorBeforePanelOpen = curPageTitleColor.value;
        changeAppBarTitle(title: curMediaItem.value.title, subTitle: curMediaItem.value.artist ?? '', appBarTitleColor: panelWidgetColor.value, direction: NewAppBarTitleComingDirection.down, willRollBack: true);
      } else {
        _rollBackAppBarTitle(newAppBarTitleComingDirection: NewAppBarTitleComingDirection.up);
      }
    }
    if (panelOpened90.value != (value > 0.9)) {
      panelOpened90.value = value > 0.9;
    }
    if (panelFullyOpened.value != (value == 1.0)){
      // 更新状态
      panelFullyOpened.value = (value == 1.0);
      // 根据状态变更图标颜色
      _updateStatusBarColor();
      // 打开Panel时在正在播放列表页，滚动到当前播放
      if (curPanelPageIndex.value == 0) {
        await _animatePlayListToCurSong();
      }
    }

  }

  /// 当按下返回键
  Future<bool> onWillPop() async {
    if (panelController.isPanelOpen) {
      panelController.close();
      return false;
    }
    if (buildContext.router.canPop()) {
      _rollBackAppBarTitle();
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
  _updateLyric() async {
    // 歌词清空
    lyricsLineModels.clear();
    hasTransLyrics.value = false;

    // 更新歌词
    String songId = curMediaItem.value.id;
    // 先从本地获取歌词
    String lyric = box.get('lyric_$songId') ?? '';
    String lyricTran = box.get('lyricTran_$songId') ?? '';
    // 本地为空则从网络获取，并缓存
    if (lyric.isEmpty) {
      SongLyricWrap songLyricWrap = await NeteaseMusicApi().songLyric(curMediaItem.value.id);
      lyric = songLyricWrap.lrc.lyric ?? "";
      lyricTran = songLyricWrap.tlyric.lyric ?? "";
      box.put('lyric_$songId', lyric);
      box.put('lyricTran_$songId', lyricTran);
    }
    // 解析歌词
    if (lyric.isNotEmpty) {
      var mainLyricsLineModels = ParserLrc(lyric).parseLines();
      if (lyricTran.isNotEmpty) {
        hasTransLyrics.value = true;
        var extLyricsLineModels = ParserLrc(lyricTran).parseLines();
        for(LyricsLineModel lyricsLineModel in extLyricsLineModels) {
          int index = mainLyricsLineModels.indexWhere((element) => element.startTime == lyricsLineModel.startTime);
          mainLyricsLineModels[index].extText = lyricsLineModel.mainText;
        }
      }
      lyricsLineModels.addAll(mainLyricsLineModels);
    } else {
      lyricsLineModels.add(LyricsLineModel()..mainText = "没歌词哦～"..startTime = 0);
    }

    // 歌词复位
    currLyricIndex.value = -1;
    await _animateLyricToCurLyric();
  }
  /// 获取专辑颜色
  _updateAlbumColor() async {
    await OtherUtils.getImageColor('${curMediaItem.value.extras?['image'] ?? ''}?param=500y500').then((paletteGenerator) {
      // 更新panel中的色调
      albumColor.value = paletteGenerator.darkMutedColor?.color
            ?? paletteGenerator.darkVibrantColor?.color
            ?? paletteGenerator.dominantColor?.color
            ?? Colors.black;
      panelWidgetColor.value = ThemeData.estimateBrightnessForColor(albumColor.value) == Brightness.light
          ? Colors.black
          : Colors.white;
      print("update4422Color");
      if (panelFullyOpened.isTrue) {
        _updateStatusBarColor();
      }
    });
  }
  _animateLyricToCurLyric() async {
    // 首尾添加栏空白行，避免滚动到空白行，index需要 +1 修正
    // currLyricIndex.value == -1 表示为前奏，滚动到第一行歌词
    int lyricListViewIndex = 1 + (currLyricIndex.value == -1 ? 0 : currLyricIndex.value);
    // 滚动到当前歌词
    if (panelFullyOpened.isTrue && !isLyricScrollingByUser) {
      isLyricScrollingByItself = true;
      lyricListViewIndex == 1
          ? lyricScrollController.jumpTo(index: lyricListViewIndex, alignment: 0.4)
          : await lyricScrollController.scrollTo(
              index: lyricListViewIndex,
              alignment: 0.4,
              duration: const Duration(milliseconds: 500),
              curve: Curves.decelerate
          );
    }
  }

  /// 滚动播放列表到当前播放歌曲
  _animatePlayListToCurSong() async {
    if (panelFullyOpened.isTrue && curPanelPageIndex.value == 0) {
      double offset = 60.0 * curPlayIndex.value;
      await playListScrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.linear);
    }
  }
  _animateAlbumPageViewToCurSong() async {
    if (!isAlbumScrollingManully) {
      isAlbumScrollingProgrammatic = true;
      bool isNearBy = (curPlayIndex.value - albumPageController.page!.toInt()).abs() <= 1;
      if (isNearBy && panelFullyOpened.isTrue) {
        await albumPageController.animateToPage(curPlayIndex.value , duration: const Duration(milliseconds: 300), curve: Curves.linear);
      } else {
        albumPageController.jumpToPage(curPlayIndex.value );
      }
      isAlbumScrollingProgrammatic = false;
    }
  }
  _updateAppBarTitleToCurSong(int lastPlayIndex) {
    bool isSkipToNext = curPlayIndex.value > lastPlayIndex;
    bool isNearBy = (curPlayIndex.value - lastPlayIndex) <= 1;
    // 切换AppBar标题
    if (panelFullyOpened.isTrue) {
      changeAppBarTitle(
          title: curPlayList[curPlayIndex.value].title,
          subTitle: curPlayList[curPlayIndex.value].artist ?? "",
          appBarTitleColor: panelWidgetColor.value,
          direction: !isNearBy
              ? NewAppBarTitleComingDirection.none
              : isSkipToNext
              ? NewAppBarTitleComingDirection.right
              : NewAppBarTitleComingDirection.left
      );
    }
  }
  _updateStatusBarColor() {
    bool isLight = panelFullyOpened.isTrue
        ? ThemeData.estimateBrightnessForColor(albumColor.value) == Brightness.light
        : !Get.isDarkMode;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ));
  }

  /// 获取 FM 歌曲列表
  _updateFmPlayList({bool isInit = false}) async {
    List<MediaItem> fmPlayList;
    SongListWrap2 songListWrap2 = await NeteaseMusicApi().userRadio();
    if (songListWrap2.code == 200) {
      fmPlayList = (songListWrap2.data ?? []).map((e) => MediaItem(
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
      fmPlayList = [];
    }
    if(isInit) {
      await audioHandler.changePlayList(fmPlayList, changePlayerSource: true, playNow: true);
    } else {
      await audioHandler.changePlayList(fmPlayList..insert(0, curMediaItem.value), index: curPlayIndex.value, playNow: false, changePlayerSource: false);
    }
  }
  _changePlayList(List<MediaItem> playList, {required bool changePlayerSource, required bool playNow, int index = 0, bool needStore = true}) async {
    // 更改播放列表
    await audioHandler.changePlayList(playList, index: index, changePlayerSource: changePlayerSource, playNow: playNow);

  }
}

enum NewAppBarTitleComingDirection {
  up,
  down,
  left,
  right,
  none
}
