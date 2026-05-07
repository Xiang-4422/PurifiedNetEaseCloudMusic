import 'package:bujuan/app/routing/app_root_router.dart';
import 'package:flutter/widgets.dart';

/// 应用根组件，承接全局路由、主题、滚动行为和依赖装配入口。
class App extends StatelessWidget {
  /// 创建应用根组件。
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return AppRootRouter();
  }
}
