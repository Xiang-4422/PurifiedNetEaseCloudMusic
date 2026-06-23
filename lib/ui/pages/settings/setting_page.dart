import 'package:bujuan/ui/services/dialog_service.dart';
import 'package:bujuan/ui/services/toast_service.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/features/local_media/local_media_scan_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/ui/pages/settings/widgets/settings_sections.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 设置页，承接主题、缓存、本地扫描和调试入口。
class SettingPageView extends StatefulWidget {
  /// 创建设置页。
  const SettingPageView({Key? key}) : super(key: key);

  @override
  State<SettingPageView> createState() => _SettingPageViewState();
}

class _SettingPageViewState extends State<SettingPageView> {
  late final LocalMediaScanController _localMediaScanController = Get.find<LocalMediaScanController>();
  late final SettingsController _settingsController = Get.find<SettingsController>();

  String version = '1.0.0';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _getVersion());
  }

  Future<void> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  Future<void> _scanLocalMedia() async {
    final preparation = await _localMediaScanController.prepareDefaultDirectoryImport();
    if (!mounted) {
      return;
    }

    if (preparation.status == LocalMediaDefaultScanPreparationStatus.permissionDenied) {
      ToastService.show('未获得本地音频读取权限');
      return;
    }

    if (preparation.status == LocalMediaDefaultScanPreparationStatus.noDirectories) {
      ToastService.show('未找到可扫描的本地目录');
      return;
    }

    if (!preparation.isReady) {
      return;
    }
    DialogService.showLoading(context);
    try {
      final importedCount = await _localMediaScanController.importDirectories(
        preparation.directoryPaths,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      if (importedCount <= 0) {
        ToastService.show('未发现可导入的本地音频');
        return;
      }
      ToastService.show('已导入 $importedCount 首本地音乐');
    } catch (_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ToastService.show('扫描本地音乐失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(
        top: context.mediaQueryPadding.top,
        bottom: AppDimensions.bottomPanelHeaderHeight,
        left: AppDimensions.paddingSmall,
        right: AppDimensions.paddingSmall,
      ),
      children: [
        SettingsSectionsList(
          settingsController: _settingsController,
          onScanLocalMedia: _scanLocalMedia,
        ),
      ],
    );
  }
}
