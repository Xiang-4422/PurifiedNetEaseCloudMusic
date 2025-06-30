import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/pages/home/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../routes/router.gr.dart';

class SettingPageView extends StatefulWidget {
  const SettingPageView({Key? key}) : super(key: key);

  @override
  State<SettingPageView> createState() => _SettingPageViewState();
}

class _SettingPageViewState extends State<SettingPageView> {
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

  @override
  Widget build(BuildContext context) {
    return Obx(() => AbsorbPointer(
        absorbing: !AppController.to.isDrawerClosed.value,
        child: ListView(
            padding: EdgeInsets.only(
                top: context.mediaQueryPadding.top + AppDimensions.appBarHeight,
                bottom: AppDimensions.bottomPanelHeaderHeight
            ),
            children: [
              _buildUiSetting(),
              _buildAppSetting(),
            ],
          ),
      ),
    );
  }

  Widget _buildUiSetting() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, borderRadius: BorderRadius.circular(22.5)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 10.w),
            alignment: Alignment.centerLeft,
            child: Text(
              'UI设置',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).cardColor.withOpacity(.4),
              ),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Text(
              '渐变播放背景(需开启智能取色)',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  AppController.to.isGradientBackground.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(AppController.to.isGradientBackground.value ? 0.7 : .4),
                )),
            onTap: () {
              AppController.to.isGradientBackground.value = !AppController.to.isGradientBackground.value;
              AppController.to.box.put(gradientBackgroundSp, AppController.to.isGradientBackground.value);
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Text(
              '顶部歌词',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  AppController.to.isTopLyricOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(AppController.to.isTopLyricOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              AppController.to.isTopLyricOpen.value = !AppController.to.isTopLyricOpen.value;
              AppController.to.box.put(topLyricSp, AppController.to.isTopLyricOpen.value);
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Text(
              '圆形专辑',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  AppController.to.isRoundAlbumOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(AppController.to.isRoundAlbumOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              AppController.to.isRoundAlbumOpen.value = !AppController.to.isRoundAlbumOpen.value;
              AppController.to.box.put(roundAlbumSp, AppController.to.isRoundAlbumOpen.value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSetting() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, borderRadius: BorderRadius.circular(22.5)),
      // padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 10.w),
            alignment: Alignment.centerLeft,
            child: Text(
              'App设置',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).cardColor.withOpacity(.4)
              ),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Text(
              '开启高音质(与会员有关)',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  AppController.to.isHighSoundQualityOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(AppController.to.isHighSoundQualityOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              AppController.to.isHighSoundQualityOpen.value = !AppController.to.isHighSoundQualityOpen.value;
              AppController.to.box.put(highSong, AppController.to.isHighSoundQualityOpen.value);
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Text(
              '开启缓存',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  AppController.to.isCacheOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(AppController.to.isCacheOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              AppController.to.isCacheOpen.value = !AppController.to.isCacheOpen.value;
              AppController.to.box.put(cacheSp, AppController.to.isCacheOpen.value);
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
        ],
      ),
    );
  }
}
