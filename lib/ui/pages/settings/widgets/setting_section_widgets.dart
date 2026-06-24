import 'package:bujuan/ui/layout/adaptive_layout_metrics.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/layout/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

/// 设置页分组容器，统一承接分区标题和设置项列表。
class SettingSection extends StatelessWidget {
  /// 创建设置页分组。
  const SettingSection({
    super.key,
    required this.title,
    required this.children,
  });

  /// 分组标题。
  final String title;

  /// 分组内设置项。
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header(title),
        ...children,
      ],
    );
  }
}

/// 设置页跳转设置项。
class SettingNavigationTile extends StatelessWidget {
  /// 创建跳转设置项。
  const SettingNavigationTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  /// 左侧图标。
  final IconData icon;

  /// 主标题。
  final String title;

  /// 副标题。
  final String subtitle;

  /// 点击行为。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final metrics = AdaptiveLayoutMetrics.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: metrics.listTileMinHeight),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          icon,
          size: AppDimensions.iconSizeMedium,
          color: Theme.of(context).cardColor.withValues(alpha: .65),
        ),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleLarge,
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).cardColor.withValues(alpha: .5),
          ),
        ),
        trailing: Icon(
          TablerIcons.chevron_right,
          size: AppDimensions.iconSizeLarge,
          color: Theme.of(context).cardColor.withValues(alpha: .5),
        ),
        onTap: onTap,
      ),
    );
  }
}

/// 设置页开关设置项。
class SettingToggleTile extends StatelessWidget {
  /// 创建开关设置项。
  const SettingToggleTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isEnabled,
    required this.onTap,
  });

  /// 左侧图标。
  final IconData icon;

  /// 主标题。
  final String title;

  /// 副标题。
  final String? subtitle;

  /// 当前是否开启。
  final bool Function() isEnabled;

  /// 点击行为。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final metrics = AdaptiveLayoutMetrics.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: metrics.listTileMinHeight),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          icon,
          size: AppDimensions.iconSizeMedium,
          color: Theme.of(context).cardColor.withValues(alpha: .65),
        ),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleLarge,
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).cardColor.withValues(alpha: .5),
                ),
              ),
        trailing: Obx(() {
          final enabled = isEnabled();
          return Tooltip(
            message: settingToggleControlLabel(
              title: title,
              isEnabled: enabled,
            ),
            child: Switch.adaptive(
              value: enabled,
              onChanged: (_) => onTap(),
            ),
          );
        }),
        onTap: onTap,
      ),
    );
  }
}

/// 生成设置页开关控件的辅助语义标签。
@visibleForTesting
String settingToggleControlLabel({
  required String title,
  required bool isEnabled,
}) {
  final resolvedTitle = title.trim().isEmpty ? '设置项' : title.trim();
  return '$resolvedTitle：${isEnabled ? '已开启' : '已关闭'}';
}
