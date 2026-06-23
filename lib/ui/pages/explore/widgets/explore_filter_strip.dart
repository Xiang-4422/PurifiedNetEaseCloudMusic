import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:flutter/material.dart';

/// 探索页横向筛选条。
class ExploreFilterStrip<T> extends StatelessWidget {
  /// 创建横向筛选条。
  const ExploreFilterStrip({
    super.key,
    required this.items,
    required this.height,
    required this.labelOf,
    required this.isSelected,
    required this.onSelected,
  });

  /// 筛选项集合。
  final List<T> items;

  /// 筛选条高度。
  final double height;

  /// 筛选项显示文案。
  final String Function(T item) labelOf;

  /// 当前筛选项是否选中。
  final bool Function(T item) isSelected;

  /// 选择筛选项。
  final void Function(T item) onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(9999),
      ),
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = isSelected(item);
          return GestureDetector(
            onTap: () => onSelected(item),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.headerHeight / 4,
              ),
              decoration: BoxDecoration(
                color: selected ? Colors.black12 : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.headerHeight / 2),
              ),
              child: Text(labelOf(item)),
            ),
          );
        },
      ),
    );
  }
}
