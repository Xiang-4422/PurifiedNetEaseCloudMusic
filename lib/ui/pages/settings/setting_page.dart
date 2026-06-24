import 'package:bujuan/ui/services/dialog_service.dart';
import 'package:bujuan/ui/services/toast_service.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/features/local_media/local_media_scan_controller.dart';
import 'package:bujuan/features/settings/settings_page_controller_bundle.dart';
import 'package:bujuan/ui/pages/settings/widgets/settings_sections.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 设置页，承接主题、缓存、本地扫描和调试入口。
class SettingPageView extends StatelessWidget {
  /// 创建设置页。
  const SettingPageView({super.key});

  static Future<void> _scanLocalMedia(
    BuildContext context,
    LocalMediaScanController localMediaScanController,
  ) async {
    final preparation = await localMediaScanController.prepareDefaultDirectoryImport();
    if (!context.mounted) {
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
      final importedCount = await localMediaScanController.importDirectories(
        preparation.directoryPaths,
      );
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop();
      if (importedCount <= 0) {
        ToastService.show('未发现可导入的本地音频');
        return;
      }
      ToastService.show('已导入 $importedCount 首本地音乐');
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop();
      ToastService.show('扫描本地音乐失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllers = Get.find<SettingsPageControllerBundle>();
    final localMediaScanController = controllers.localMediaScanController;
    final playerController = controllers.playerController;
    final settingsController = controllers.settingsController;
    return ListView(
      padding: EdgeInsets.only(
        top: context.mediaQueryPadding.top,
        bottom: AppDimensions.bottomPanelHeaderHeight,
        left: AppDimensions.paddingSmall,
        right: AppDimensions.paddingSmall,
      ),
      children: [
        SettingsSectionsList(
          settingsController: settingsController,
          playerController: playerController,
          onScanLocalMedia: () => _scanLocalMedia(
            context,
            localMediaScanController,
          ),
        ),
      ],
    );
  }
}
