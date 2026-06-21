import 'package:auto_route/auto_route.dart';
import 'package:bujuan/app/routing/router.gr.dart' as gr;
import 'package:bujuan/ui/pages/download/download_task_page_view.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

/// 个人页资料库区域的轻量快捷入口。
class LibraryShortcutBar extends StatelessWidget {
  /// 创建资料库快捷入口栏。
  const LibraryShortcutBar({super.key});

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      _LibraryShortcutAction(
        label: '本地音乐',
        icon: TablerIcons.music,
        onTap: () => _openDownloadTaskPage(
          context,
          DownloadTaskPageView.tabLocalImport,
        ),
      ),
      _LibraryShortcutAction(
        label: '已下载',
        icon: TablerIcons.download,
        onTap: () => _openDownloadTaskPage(
          context,
          DownloadTaskPageView.tabDownloaded,
        ),
      ),
      _LibraryShortcutAction(
        label: '云盘',
        icon: TablerIcons.cloud,
        onTap: () => context.router.push(const gr.CloudDriveView()),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
      ),
      child: SizedBox(
        height: 72,
        child: Row(
          children: [
            for (var index = 0; index < shortcuts.length; index++) ...[
              if (index > 0) const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: _LibraryShortcutButton(action: shortcuts[index]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openDownloadTaskPage(BuildContext context, int initialTabIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DownloadTaskPageView(initialTabIndex: initialTabIndex),
      ),
    );
  }
}

class _LibraryShortcutAction {
  const _LibraryShortcutAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _LibraryShortcutButton extends StatelessWidget {
  const _LibraryShortcutButton({required this.action});

  final _LibraryShortcutAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: 0.08),
      colorScheme.surface,
    );

    return Tooltip(
      message: action.label,
      child: Semantics(
        button: true,
        label: action.label,
        child: Material(
          color: backgroundColor,
          borderRadius: AppDimensions.borderRadiusMedium,
          child: InkWell(
            borderRadius: AppDimensions.borderRadiusMedium,
            onTap: action.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall / 2,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    action.icon,
                    size: AppDimensions.iconSizeMedium,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
