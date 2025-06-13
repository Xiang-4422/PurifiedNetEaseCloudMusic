import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
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
        absorbing: !HomePageController.to.isDrawerClosed.value,
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
                  HomePageController.to.isGradientBackground.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(HomePageController.to.isGradientBackground.value ? 0.7 : .4),
                )),
            onTap: () {
              HomePageController.to.isGradientBackground.value = !HomePageController.to.isGradientBackground.value;
              HomePageController.to.box.put(gradientBackgroundSp, HomePageController.to.isGradientBackground.value);
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Text(
              '顶部歌词',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  HomePageController.to.isTopLyricOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(HomePageController.to.isTopLyricOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              HomePageController.to.isTopLyricOpen.value = !HomePageController.to.isTopLyricOpen.value;
              HomePageController.to.box.put(topLyricSp, HomePageController.to.isTopLyricOpen.value);
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Text(
              '圆形专辑',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  HomePageController.to.isRoundAlbumOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(HomePageController.to.isRoundAlbumOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              HomePageController.to.isRoundAlbumOpen.value = !HomePageController.to.isRoundAlbumOpen.value;
              HomePageController.to.box.put(roundAlbumSp, HomePageController.to.isRoundAlbumOpen.value);
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
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
            contentPadding: const EdgeInsets.all(0),
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
              if (HomePageController.to.customBackgroundPath.value.isEmpty) {
                WidgetUtil.showToast('没有设置背景');
                return;
              }
              HomePageController.to.customBackgroundPath.value = '';
              HomePageController.to.box.put(backgroundSp, '');
              WidgetUtil.showToast('清除成功');
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
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
                HomePageController.to.box.put(splashBackgroundSp, x.path);
              }
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Text(
              '清除启动图',
              style: TextStyle(fontSize: 30.sp),
            ),
            onTap: () async {
              HomePageController.to.box.put(splashBackgroundSp, '');
              WidgetUtil.showToast('清除成功');
            },
          )
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
                  HomePageController.to.isHighSoundQualityOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(HomePageController.to.isHighSoundQualityOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              HomePageController.to.isHighSoundQualityOpen.value = !HomePageController.to.isHighSoundQualityOpen.value;
              HomePageController.to.box.put(highSong, HomePageController.to.isHighSoundQualityOpen.value);
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Text(
              '开启缓存',
              style: TextStyle(fontSize: 30.sp),
            ),
            trailing: Obx(() => Icon(
                  HomePageController.to.isCacheOpen.value ? TablerIcons.toggle_right : TablerIcons.toggle_left,
                  size: 56.w,
                  color: Theme.of(context).cardColor.withOpacity(HomePageController.to.isCacheOpen.value ? 0.7 : .4),
                )),
            onTap: () {
              HomePageController.to.isCacheOpen.value = !HomePageController.to.isCacheOpen.value;
              HomePageController.to.box.put(cacheSp, HomePageController.to.isCacheOpen.value);
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
