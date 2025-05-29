import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/pages/home/root_controller.dart';
import 'package:bujuan/widget/commen_widget/my_appbar_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../common/netease_api/src/dio_ext.dart';
import '../../routes/router.dart';
import '../../routes/router.gr.dart';
import '../../widget/simple_extended_image.dart';
import '../user/user_controller.dart';

class SettingView extends StatefulWidget {
  const SettingView({Key? key}) : super(key: key);

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  String version = '1.0.0';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _getVersion());
  }

  @override
  dispose() {
    super.dispose();
  }

  _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  _update() async {
    WidgetUtil.showLoadingDialog(context);
    try {
      Response value = await Https.dioProxy.get('https://gitee.com/yasengsuoai/bujuan_version/raw/master/version.json');
      if (mounted) Navigator.of(context).pop();
      Map<String, dynamic> versionData = value.data..putIfAbsent('oldVersion', () => version);
      if (int.parse((versionData['version'] ?? '0').replaceAll('.', '')) > int.parse(version.replaceAll('.', ''))) {
        if (mounted) AutoRouter.of(context).push(const UpdateView().copyWith(queryParams: versionData));
      } else {
        WidgetUtil.showToast('已是最新版本');
      }
    } on DioError catch (e) {
      WidgetUtil.showToast('网络错误');
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('设置'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [_buildUiSetting(), _buildAppSetting()],
        ),
      ),
    );
  }

  Widget _buildUiSetting() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.w),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, borderRadius: BorderRadius.circular(25.w)),
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 10.w),
            alignment: Alignment.centerLeft,
            child: Text(
              'UI设置',
              style: TextStyle(fontSize: 28.sp, color: Theme.of(context).cardColor.withOpacity(.4)),
            ),
          ),
          ListTile(
            title: Text(
              '渐变播放背景(需开启智能取色)',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  RootController.to.isGradientBackground.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(RootController.to.isGradientBackground.value ? 0.7 : .4),
                )),
            onTap: () {
              RootController.to.isGradientBackground.value = !RootController.to.isGradientBackground.value;
              RootController.to.box.put(gradientBackgroundSp, RootController.to.isGradientBackground.value);
            },
          ),
          ListTile(
            title: Text(
              '顶部歌词',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  RootController.to.isTopLyricOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(RootController.to.isTopLyricOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              RootController.to.isTopLyricOpen.value = !RootController.to.isTopLyricOpen.value;
              RootController.to.box.put(topLyricSp, RootController.to.isTopLyricOpen.value);
            },
          ),
          ListTile(
            title: Text(
              '圆形专辑',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  RootController.to.isRoundAlbumOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(RootController.to.isRoundAlbumOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              RootController.to.isRoundAlbumOpen.value = !RootController.to.isRoundAlbumOpen.value;
              RootController.to.box.put(roundAlbumSp, RootController.to.isRoundAlbumOpen.value);
            },
          ),
          ListTile(
            title: Text(
              '自定义背景',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Icon(
              TablerIcons.chevron_right,
              size: 42.w,
              color: Theme.of(context).cardColor.withOpacity(.6),
            ),
            onTap: () async {
              XFile? x = await _picker.pickImage(source: ImageSource.gallery, requestFullMetadata: false);
              if (x != null && mounted) {
                context.router.push(ImageBlur(path: x.path));
              }
            },
          ),
          ListTile(
            title: Text(
              '清除自定义背景',
              style: TextStyle(fontSize: 30.sp),
            ),
            // trailing: Icon(
            //   TablerIcons.chevron_right,
            //   size: 42.w,
            //   color: Theme.of(context).cardColor.withOpacity(.6),
            // ),
            onTap: () async {
              if (RootController.to.customBackgroundPath.value.isEmpty) {
                WidgetUtil.showToast('没有设置背景');
                return;
              }
              RootController.to.customBackgroundPath.value = '';
              RootController.to.box.put(backgroundSp, '');
              WidgetUtil.showToast('清除成功');
            },
          ),
          ListTile(
            title: Text(
              '自定义启动图',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Icon(
              TablerIcons.chevron_right,
              size: 42.w,
              color: Theme.of(context).cardColor.withOpacity(.6),
            ),
            onTap: () async {
              XFile? x = await _picker.pickImage(source: ImageSource.gallery, requestFullMetadata: false);
              if (x != null && mounted) {
                RootController.to.box.put(splashBackgroundSp, x.path);
              }
            },
          ),
          ListTile(
            title: Text(
              '清除启动图',
              style: TextStyle(fontSize: 30.sp),
            ),
            onTap: () async {
              RootController.to.box.put(splashBackgroundSp, '');
              WidgetUtil.showToast('清除成功');
            },
          )
        ],
      ),
    );
  }

  Widget _buildAppSetting() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.w),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, borderRadius: BorderRadius.circular(25.w)),
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 10.w),
            alignment: Alignment.centerLeft,
            child: Text(
              'App设置',
              style: TextStyle(fontSize: 28.sp, color: Theme.of(context).cardColor.withOpacity(.4)),
            ),
          ),
          ListTile(
            title: Text(
              '开启高音质(与会员有关)',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  RootController.to.isHighSoundQualityOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(RootController.to.isHighSoundQualityOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              RootController.to.isHighSoundQualityOpen.value = !RootController.to.isHighSoundQualityOpen.value;
              RootController.to.box.put(highSong, RootController.to.isHighSoundQualityOpen.value);
            },
          ),
          ListTile(
            title: Text(
              '开启缓存',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  RootController.to.isCacheOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(RootController.to.isCacheOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              RootController.to.isCacheOpen.value = !RootController.to.isCacheOpen.value;
              RootController.to.box.put(cacheSp, RootController.to.isCacheOpen.value);
            },
          ),
          // ListTile(
          //   title: Text(
          //     '清理缓存',
          //     style: TextStyle(fontSize: 30.sp),
          //   ),
          //   trailing: Icon(
          //     TablerIcons.chevron_right,
          //     size: 42.w,
          //     color: Theme.of(context).cardColor.withOpacity(.6),
          //   ),
          //   onTap: () async {
          //     WidgetUtil.showLoadingDialog(context);
          //     await Downloader.clearCachedFiles();
          //     if (mounted) Navigator.of(context).pop();
          //   },
          // ),
          ListTile(
            title: Text(
              '检测更新',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Text(version),
            onTap: () => _update(),
          ),
        ],
      ),
    );
  }
}

class SettingViewL extends StatefulWidget {
  const SettingViewL({Key? key}) : super(key: key);

  @override
  State<SettingViewL> createState() => _SettingViewStateL();
}

class _SettingViewStateL extends State<SettingViewL> {
  String version = '1.0.0';
  final ImagePicker _picker = ImagePicker();
  bool unblock = RootController.to.box.get(unblockSp, defaultValue: false);
  bool unblockVip = RootController.to.box.get(unblockVipSp, defaultValue: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _getVersion());
  }

  @override
  dispose() {
    super.dispose();
  }

  _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  _update() async {
    WidgetUtil.showLoadingDialog(context);
    try {
      Response value = await Https.dioProxy.get('https://gitee.com/yasengsuoai/bujuan_version/raw/master/version.json');
      if (mounted) Navigator.of(context).pop();
      Map<String, dynamic> versionData = value.data..putIfAbsent('oldVersion', () => version);
      if (int.parse((versionData['version'] ?? '0').replaceAll('.', '')) > int.parse(version.replaceAll('.', ''))) {
        if (mounted) AutoRouter.of(context).push(const UpdateView().copyWith(queryParams: versionData));
      } else {
        WidgetUtil.showToast('已是最新版本');
      }
    } on DioError catch (e) {
      WidgetUtil.showToast('网络错误');
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: RootController.to.landscape
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              centerTitle: false,
              leading: IconButton(
                  onPressed: () {
                    if (RootController.to.loginStatus.value == LoginStatus.login) {
                      RootController.to.zoomDrawerController.open!();
                      return;
                    }
                    AutoRouter.of(context).pushNamed(Routes.login);
                  },
                  icon: Obx(() => SimpleExtendedImage.avatar(
                        RootController.to.userData.value.profile?.avatarUrl ?? '',
                        width: 80.w,
                      ))),
              title: RichText(
                  text: TextSpan(style: TextStyle(fontSize: 36.sp, color: Colors.grey, fontWeight: FontWeight.bold), text: 'Here  ', children: [
                TextSpan(text: '设置～', style: TextStyle(color: Theme.of(context).primaryColor.withOpacity(.9))),
              ])),
            ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [_buildUiSetting(), _buildAppSetting(), _buildOtherSetting()],
        ),
      ),
    );
  }

  Widget _buildUiSetting() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.w),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary.withOpacity(.5), borderRadius: BorderRadius.circular(25.w)),
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 10.w),
            alignment: Alignment.centerLeft,
            child: Text(
              'UI设置',
              style: TextStyle(fontSize: 28.sp, color: Theme.of(context).cardColor.withOpacity(.4)),
            ),
          ),
          ListTile(
            title: Text(
              '渐变播放背景(需开启智能取色)',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  RootController.to.isGradientBackground.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(RootController.to.isGradientBackground.value ? 0.7 : .4),
                )),
            onTap: () {
              RootController.to.isGradientBackground.value = !RootController.to.isGradientBackground.value;
              RootController.to.box.put(gradientBackgroundSp, RootController.to.isGradientBackground.value);
            },
          ),
          ListTile(
            title: Text(
              '顶部歌词',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  RootController.to.isTopLyricOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(RootController.to.isTopLyricOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              RootController.to.isTopLyricOpen.value = !RootController.to.isTopLyricOpen.value;
              RootController.to.box.put(topLyricSp, RootController.to.isTopLyricOpen.value);
            },
          ),
          ListTile(
            title: Text(
              '圆形专辑',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  RootController.to.isRoundAlbumOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(RootController.to.isRoundAlbumOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              RootController.to.isRoundAlbumOpen.value = !RootController.to.isRoundAlbumOpen.value;
              RootController.to.box.put(roundAlbumSp, RootController.to.isRoundAlbumOpen.value);
            },
          ),
          ListTile(
            title: Text(
              '自定义背景',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Icon(
              TablerIcons.chevron_right,
              size: 42.w,
              color: Theme.of(context).cardColor.withOpacity(.6),
            ),
            onTap: () async {
              XFile? x = await _picker.pickImage(source: ImageSource.gallery, requestFullMetadata: false);
              if (x != null && mounted) {
                context.router.push(ImageBlur(path: x.path));
              }
            },
          ),
          ListTile(
            title: Text(
              '清除自定义背景',
              style: TextStyle(fontSize: 30.sp),
            ),
            // trailing: Icon(
            //   TablerIcons.chevron_right,
            //   size: 42.w,
            //   color: Theme.of(context).cardColor.withOpacity(.6),
            // ),
            onTap: () async {
              if (RootController.to.customBackgroundPath.value.isEmpty) {
                WidgetUtil.showToast('没有设置背景');
                return;
              }
              RootController.to.customBackgroundPath.value = '';
              RootController.to.box.put(backgroundSp, '');
              WidgetUtil.showToast('清除成功');
            },
          ),
          ListTile(
            title: Text(
              '自定义启动图',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Icon(
              TablerIcons.chevron_right,
              size: 42.w,
              color: Theme.of(context).cardColor.withOpacity(.6),
            ),
            onTap: () async {
              XFile? x = await _picker.pickImage(source: ImageSource.gallery, requestFullMetadata: false);
              if (x != null && mounted) {
                RootController.to.box.put(splashBackgroundSp, x.path);
              }
            },
          ),
          ListTile(
            title: Text(
              '清除启动图',
              style: TextStyle(fontSize: 30.sp),
            ),
            onTap: () async {
              RootController.to.box.put(splashBackgroundSp, '');
              WidgetUtil.showToast('清除成功');
            },
          )
        ],
      ),
    );
  }

  Widget _buildAppSetting() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.w),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary.withOpacity(.5), borderRadius: BorderRadius.circular(25.w)),
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 10.w),
            alignment: Alignment.centerLeft,
            child: Text(
              'App设置',
              style: TextStyle(fontSize: 28.sp, color: Theme.of(context).cardColor.withOpacity(.4)),
            ),
          ),
          ListTile(
            title: Text(
              '开启高音质(与会员有关)',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  RootController.to.isHighSoundQualityOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(RootController.to.isHighSoundQualityOpen.value ? 0.7 : .4),
                )),
            onTap: () {},
          ),
          ListTile(
            title: Text(
              '开启高音质(与会员有关)',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  RootController.to.isHighSoundQualityOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(RootController.to.isHighSoundQualityOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              RootController.to.isHighSoundQualityOpen.value = !RootController.to.isHighSoundQualityOpen.value;
              RootController.to.box.put(highSong, RootController.to.isHighSoundQualityOpen.value);
            },
          ),
          ListTile(
            title: Text(
              '开启缓存',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  RootController.to.isCacheOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(RootController.to.isCacheOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              RootController.to.isCacheOpen.value = !RootController.to.isCacheOpen.value;
              RootController.to.box.put(cacheSp, RootController.to.isCacheOpen.value);
            },
          ),
          // ListTile(
          //   title: Text(
          //     '清理缓存',
          //     style: TextStyle(fontSize: 30.sp),
          //   ),
          //   trailing: Icon(
          //     TablerIcons.chevron_right,
          //     size: 42.w,
          //     color: Theme.of(context).cardColor.withOpacity(.6),
          //   ),
          //   onTap: () async {
          //     WidgetUtil.showLoadingDialog(context);
          //     await Downloader.clearCachedFiles();
          //     if (mounted) Navigator.of(context).pop();
          //   },
          // ),
          ListTile(
            title: Text(
              '检测更新',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Text(version),
            onTap: () => _update(),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSetting() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.w),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary.withOpacity(.5), borderRadius: BorderRadius.circular(25.w)),
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 10.w),
            alignment: Alignment.centerLeft,
            child: Text(
              '试验性功能',
              style: TextStyle(fontSize: 28.sp, color: Theme.of(context).cardColor.withOpacity(.4)),
            ),
          ),
          ListTile(
            title: Text(
              'Unblock获取灰色音乐',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Icon(
              unblock ? TablerIcons.toggle_right : TablerIcons.toggle_left,
              size: 56.w,
              color: Theme.of(context).cardColor.withOpacity(unblock ? 0.7 : .4),
            ),
            onTap: () {
              setState(() {
                unblock = !unblock;
              });
              RootController.to.box.put(unblockSp, unblock);
            },
          ),
          ListTile(
            title: Text(
              'Unblock获取Vip音乐（会员勿开）',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Icon(
              unblockVip ? TablerIcons.toggle_right : TablerIcons.toggle_left,
              size: 56.w,
              color: Theme.of(context).cardColor.withOpacity(unblockVip ? 0.7 : .4),
            ),
            onTap: () {
              setState(() {
                unblockVip = !unblockVip;
              });
              RootController.to.box.put(unblockVipSp, unblockVip);
            },
          ),
        ],
      ),
    );
  }
}
