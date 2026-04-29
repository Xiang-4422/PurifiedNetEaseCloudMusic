import 'package:bujuan/app/bootstrap/registrars/feature_controller_registrar.dart';
import 'package:bujuan/app/bootstrap/registrars/infrastructure_registrar.dart';
import 'package:bujuan/app/bootstrap/registrars/playback_registrar.dart';
import 'package:bujuan/app/bootstrap/registrars/presentation_adapter_registrar.dart';
import 'package:bujuan/app/bootstrap/registrars/user_registrar.dart';
import 'package:get/get.dart';

/// 应用级 GetX 组合根，统一注册基础设施、应用服务和控制器。
class AppBinding extends Bindings {
  /// 创建应用级依赖装配实例。
  AppBinding();

  /// 在 Flutter 首帧前初始化数据库、Hive 和 repository 基础设施。
  static Future<void> initInfrastructure() {
    return InfrastructureRegistrar.init();
  }

  @override
  void dependencies() {
    UserRegistrar.register();
    PlaybackRegistrar.register();
    PresentationAdapterRegistrar.register();
    FeatureControllerRegistrar.register();
  }
}
