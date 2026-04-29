import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/home_shell_controller.dart';
import 'package:bujuan/features/user/application/user_home_application_service.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:get/get.dart';

/// 用户与设置相关控制器注册器。
class UserRegistrar {
  /// 禁止实例化用户注册器。
  const UserRegistrar._();

  /// 注册用户 session、用户资料、推荐和设置相关控制器。
  static void register() {
    Get.lazyPut(() => HomeShellController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.lazyPut(
      () => UserSessionController(
        repository: Get.find<UserRepository>(),
        box: CacheBox.instance,
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => UserLibraryController(
        repository: Get.find<UserRepository>(),
        sessionController: Get.find<UserSessionController>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => UserHomeApplicationService(
        repository: Get.find<UserRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => RecommendationController(
        homeService: Get.find<UserHomeApplicationService>(),
        sessionController: Get.find<UserSessionController>(),
        libraryController: Get.find<UserLibraryController>(),
        validateLoginStateInBackground: () =>
            Get.find<AuthController>().validateLoginStateInBackgroundIfNeeded(),
      ),
      fenix: true,
    );
  }
}
